#!/usr/bin/env python3
import argparse
import csv
import datetime
import os
import re
import sys
from collections import defaultdict

try:
    import matplotlib.pyplot as plt
except ImportError:
    plt = None


THERMAL_RE = re.compile(
    r"\[THERMAL\]\s+Temp:\s*(?P<temp>\d+)\s+\[(?P<zone>\w+)\]\s*\|\s*PID:\s*(?P<pid>\d+)\s*\|\s*Heat:\s*(?P<heat>\d+)\s*\|\s*(?P<name>\S+)(?:\s*\|\s*(?P<skipped>\d+)\s+skipped)?"
)
COOLING_RE = re.compile(r"\[COOLING\]\s+Temp:\s*(?P<temp>\d+)")
MATRIX_CHILD_RE = re.compile(
    r"(?:matrix: )?Child\s+(?P<child_id>\d+)\s+\(PID\s+(?P<pid>\d+)\):\s*(?P<rounds>\d+)\s+rounds,"
)
FORK_RE = re.compile(r"Parent: Forked child\s+(?P<child_id>\d+)\s+with PID\s+(?P<pid>\d+)")
CONST_RE = re.compile(r"^#define\s+(?P<name>NCHILD|N|ROUNDS)\s+(?P<value>\d+)")


def parse_matrix_constants(path):
    result = {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                m = CONST_RE.match(line.strip())
                if m:
                    result[m.group("name")] = int(m.group("value"))
        if len(result) == 3:
            return result
    except FileNotFoundError:
        pass
    return None


def parse_schedtest_output(lines):
    records = []
    pid_to_child = {}
    pid_to_name = {}

    for line in lines:
        line = line.strip()
        if not line:
            continue

        m = THERMAL_RE.search(line)
        if m:
            pid = int(m.group("pid"))
            temp = int(m.group("temp"))
            heat = int(m.group("heat"))
            name = m.group("name")
            skipped = int(m.group("skipped")) if m.group("skipped") else 0
            records.append(
                {
                    "type": "run",
                    "temp": temp,
                    "pid": pid,
                    "heat": heat,
                    "name": name,
                    "zone": m.group("zone"),
                    "skipped": skipped,
                }
            )
            pid_to_name[pid] = name
            continue

        m = COOLING_RE.search(line)
        if m:
            records.append(
                {
                    "type": "cooling",
                    "temp": int(m.group("temp")),
                    "pid": 0,
                    "heat": 0,
                    "name": "idle",
                    "zone": "COOL",
                    "skipped": 0,
                }
            )
            continue

        m = MATRIX_CHILD_RE.search(line)
        if m:
            pid = int(m.group("pid"))
            child_id = int(m.group("child_id"))
            pid_to_child[pid] = child_id
            continue

        m = FORK_RE.search(line)
        if m:
            pid = int(m.group("pid"))
            child_id = int(m.group("child_id"))
            pid_to_child[pid] = child_id
            continue

    return records, pid_to_child, pid_to_name


def summarize(records, pid_to_child):
    summary = {
        "total_samples": 0,
        "cpu_temps": [],
        "pid_stats": {},
        "pids": set(),
    }
    for record in records:
        if record["type"] not in {"run", "cooling"}:
            continue
        summary["total_samples"] += 1
        summary["cpu_temps"].append(record["temp"])

        if record["type"] != "run":
            continue

        pid = record["pid"]
        if pid not in summary["pid_stats"]:
            summary["pid_stats"][pid] = {
                "name": record["name"],
                "count": 0,
                "heat_sum": 0,
                "heat_min": None,
                "heat_max": None,
            }
        stats = summary["pid_stats"][pid]
        stats["count"] += 1
        stats["heat_sum"] += record["heat"]
        stats["heat_min"] = record["heat"] if stats["heat_min"] is None else min(stats["heat_min"], record["heat"])
        stats["heat_max"] = record["heat"] if stats["heat_max"] is None else max(stats["heat_max"], record["heat"])
        summary["pids"].add(pid)
    return summary


def format_bytes(value):
    return f"{value}" if value is not None else "-"


def print_analysis(summary, matrix_constants, pid_to_child):
    temps = summary["cpu_temps"]
    print("\n=== schedtest analysis summary ===")
    print(f"Total thermal samples: {summary['total_samples']}")
    if temps:
        print(f"CPU temp: avg={sum(temps)/len(temps):.1f}, min={min(temps)}, max={max(temps)}")

    if matrix_constants:
        nchild = matrix_constants["NCHILD"]
        rounds = matrix_constants["ROUNDS"]
        print("\nMatrix test constants from user/matrix.c:")
        print(f"  NCHILD = {nchild}, N = {matrix_constants['N']}, ROUNDS = {rounds}")
        print("  Expected rounds per child id:")
        for child_id in range(1, nchild + 1):
            expected = rounds + (nchild - child_id + 1)
            print(f"    child {child_id}: {expected}")

    if summary["pid_stats"]:
        print("\nPer-PID summary:")
        header = "PID   Child   Count   AvgHeat   MinHeat   MaxHeat   Name"
        print(header)
        print("-" * len(header))
        for pid in sorted(summary["pid_stats"].keys()):
            stats = summary["pid_stats"][pid]
            avg_heat = stats["heat_sum"] / stats["count"] if stats["count"] else 0
            child = pid_to_child.get(pid, "-")
            print(
                f"{pid:5} {child:7} {stats['count']:7} {avg_heat:8.1f} {format_bytes(stats['heat_min']):8} {format_bytes(stats['heat_max']):8}   {stats['name']}"
            )

    if matrix_constants and pid_to_child:
        print("\nWorkload vs observed heat trend:")
        comparisons = []
        for pid, child_id in sorted(pid_to_child.items(), key=lambda p: p[1]):
            stats = summary["pid_stats"].get(pid)
            if not stats or stats["count"] == 0:
                continue
            avg_heat = stats["heat_sum"] / stats["count"]
            expected_rounds = matrix_constants["ROUNDS"] + (matrix_constants["NCHILD"] - child_id + 1)
            comparisons.append((child_id, expected_rounds, avg_heat, pid))
        if comparisons:
            print("  Ordered by child id:")
            for child_id, exp_rounds, avg_heat, pid in comparisons:
                print(f"    child {child_id} (PID {pid}): expected rounds={exp_rounds}, avg heat={avg_heat:.1f}")

            is_non_increasing = all(
                comparisons[i][2] >= comparisons[i + 1][2] for i in range(len(comparisons) - 1)
            )
            heaviest = comparisons[0]
            lightest = comparisons[-1]
            if len(comparisons) > 1 and is_non_increasing:
                print(
                    "  Observation: lower child IDs stay hotter on average, which matches matrix.c where child 1 has the heaviest workload."
                )
            else:
                print(
                    "  Observation: the heat trend does not strictly follow the expected heavy-to-light child order from matrix.c."
                )
                if len(comparisons) > 1:
                    print(
                        f"  Heaviest child {heaviest[0]} avg heat={heaviest[2]:.1f}; lightest child {lightest[0]} avg heat={lightest[2]:.1f}."
                    )


def write_csv(records, filename, pid_to_child):
    fieldnames = ["sample", "type", "temp", "pid", "child", "heat", "name", "zone", "skipped"]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for i, record in enumerate(records, 1):
            row = {**record}
            row["sample"] = i
            row["child"] = pid_to_child.get(record["pid"], "")
            writer.writerow(row)


def build_plots(records, output_prefix, show, pid_to_child):
    if plt is None:
        print("\nMatplotlib is not installed. Install it with 'pip install matplotlib' to generate plots.")
        return False

    # Build time series
    steps = []
    temps = []
    pid_lines = defaultdict(list)
    for idx, record in enumerate(records, 1):
        steps.append(idx)
        temps.append(record["temp"])
        if record["type"] == "run":
            pid_lines[record["pid"]].append((idx, record["heat"]))

    fig, ax = plt.subplots(figsize=(14, 7))
    ax.plot(steps, temps, label="CPU temp", color="#d62728", linewidth=2.5)

    color_map = plt.cm.get_cmap("tab10")
    pid_colors = {}
    for idx, pid in enumerate(sorted(pid_lines.keys())):
        pid_colors[pid] = color_map(idx % 10)

    pid_xs = []
    pid_ys = []
    for pid, series in sorted(pid_lines.items()):
        xs, ys = zip(*series)
        child = pid_to_child.get(pid)
        label = f"Child {child} (PID {pid})" if child is not None else f"PID {pid}"
        ax.plot(
            xs,
            ys,
            marker="o",
            linestyle="--",
            linewidth=1.4,
            markersize=4,
            color=pid_colors[pid],
            label=label,
        )
        pid_xs.extend(xs)
        pid_ys.extend([pid] * len(xs))

    # Scatter plot showing which PID ran at each thermal sample.
    ax2 = ax.twinx()
    ax2.scatter(
        pid_xs,
        pid_ys,
        color="#555555",
        marker="x",
        s=36,
        alpha=0.8,
        label="PID run",
    )

    ax.set_title("schedtest thermal trace: CPU temperature and process heat over time")
    ax.set_xlabel("Thermal log sample")
    ax.set_ylabel("Temperature / Heat")
    ax2.set_ylabel("PID")
    ax.set_ylim(0, 105)
    max_pid = max(pid_lines.keys()) if pid_lines else 1
    ax2.set_ylim(0.5, max_pid + 0.5)
    ax2.set_yticks(sorted(pid_lines.keys()))
    ax.grid(True, alpha=0.25)
    ax.legend(loc="upper left", fontsize="small", ncol=2, frameon=False)
    fig.tight_layout(rect=[0, 0, 0.78, 1])

    figure_file = f"{output_prefix}.png"
    fig.savefig(figure_file, dpi=200)
    print(f"Saved plot: {figure_file}")
    if show:
        plt.show()
    plt.close(fig)
    return True


def main():
    parser = argparse.ArgumentParser(
        description="Parse schedtest/matrix thermal scheduler output and generate CPU temp / heat graphs."
    )
    parser.add_argument(
        "--input",
        "-i",
        help="Path to the schedtest output text file. Use '-' for stdin.",
        default="-",
    )
    parser.add_argument(
        "--output-prefix",
        "-o",
        help="Output path prefix for generated plot and CSV files.",
    )
    parser.add_argument(
        "--matrix-file",
        default="user/matrix.c",
        help="Path to matrix.c for workload range constants.",
    )
    parser.add_argument(
        "--csv",
        action="store_true",
        help="Write parsed sample data to a CSV file.",
    )
    parser.add_argument(
        "--show",
        action="store_true",
        help="Display the generated plot after creating it.",
    )
    args = parser.parse_args()

    if args.input == "-":
        lines = [line.rstrip("\n") for line in sys.stdin]
        base_input = "schedtest"
    else:
        with open(args.input, "r", encoding="utf-8", errors="replace") as f:
            lines = [line.rstrip("\n") for line in f]
        base_input = os.path.splitext(os.path.basename(args.input))[0]

    records, pid_to_child, pid_to_name = parse_schedtest_output(lines)
    if not records:
        print("No thermal or matrix records found in input. Check that the log contains [THERMAL] or matrix child lines.")
        return 1

    matrix_constants = parse_matrix_constants(args.matrix_file)
    summary = summarize(records, pid_to_child)
    print_analysis(summary, matrix_constants, pid_to_child)

    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    prefix = args.output_prefix or f"{base_input}_{timestamp}"

    if args.csv:
        csv_file = f"{prefix}.csv"
        write_csv(records, csv_file, pid_to_child)
        print(f"Saved CSV: {csv_file}")

    build_plots(records, prefix, args.show, pid_to_child)
    return 0


if __name__ == "__main__":
    sys.exit(main())
