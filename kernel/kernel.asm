
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	3d813103          	ld	sp,984(sp) # 8000a3d8 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb0d7>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2a78793          	addi	a5,a5,-470 # 80000eae <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	2e2020ef          	jal	800023fc <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7b4000ef          	jal	800008da <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	00012517          	auipc	a0,0x12
    80000196:	28e50513          	addi	a0,a0,654 # 80012420 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00012497          	auipc	s1,0x12
    800001a2:	28248493          	addi	s1,s1,642 # 80012420 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00012917          	auipc	s2,0x12
    800001aa:	31290913          	addi	s2,s2,786 # 800124b8 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	7da010ef          	jal	80001998 <myproc>
    800001c2:	0d2020ef          	jal	80002294 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	68d010ef          	jal	80002058 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00012717          	auipc	a4,0x12
    800001e2:	24270713          	addi	a4,a4,578 # 80012420 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	1a2020ef          	jal	800023b2 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	00012517          	auipc	a0,0x12
    8000022c:	1f850513          	addi	a0,a0,504 # 80012420 <cons>
    80000230:	28d000ef          	jal	80000cbc <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	00012717          	auipc	a4,0x12
    80000252:	26f72523          	sw	a5,618(a4) # 800124b8 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00012517          	auipc	a0,0x12
    80000268:	1bc50513          	addi	a0,a0,444 # 80012420 <cons>
    8000026c:	251000ef          	jal	80000cbc <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6e4000ef          	jal	8000096e <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6d6000ef          	jal	8000096e <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6ce000ef          	jal	8000096e <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6c8000ef          	jal	8000096e <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00012517          	auipc	a0,0x12
    800002bc:	16850513          	addi	a0,a0,360 # 80012420 <cons>
    800002c0:	169000ef          	jal	80000c28 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48d63          	beq	s1,a5,80000360 <consoleintr+0xb4>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48263          	beq	s1,a5,800003b4 <consoleintr+0x108>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49363          	bne	s1,a5,800003dc <consoleintr+0x130>
  case C('P'):  // Print process list.
    procdump();
    800002da:	16c020ef          	jal	80002446 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00012517          	auipc	a0,0x12
    800002e2:	14250513          	addi	a0,a0,322 # 80012420 <cons>
    800002e6:	1d7000ef          	jal	80000cbc <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0af48e63          	beq	s1,a5,800003b4 <consoleintr+0x108>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	00012717          	auipc	a4,0x12
    80000300:	12470713          	addi	a4,a4,292 # 80012420 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48563          	beq	s1,a5,800003e2 <consoleintr+0x136>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	00012717          	auipc	a4,0x12
    80000326:	0fe70713          	addi	a4,a4,254 # 80012420 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	c371                	beqz	a4,8000040a <consoleintr+0x15e>
    80000348:	14f1                	addi	s1,s1,-4
    8000034a:	c0e1                	beqz	s1,8000040a <consoleintr+0x15e>
    8000034c:	00012717          	auipc	a4,0x12
    80000350:	16c72703          	lw	a4,364(a4) # 800124b8 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00012717          	auipc	a4,0x12
    80000366:	0be70713          	addi	a4,a4,190 # 80012420 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00012497          	auipc	s1,0x12
    80000376:	0ae48493          	addi	s1,s1,174 # 80012420 <cons>
    while(cons.e != cons.w &&
    8000037a:	4929                	li	s2,10
    8000037c:	02f70863          	beq	a4,a5,800003ac <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000380:	37fd                	addiw	a5,a5,-1
    80000382:	07f7f713          	andi	a4,a5,127
    80000386:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000388:	01874703          	lbu	a4,24(a4)
    8000038c:	03270263          	beq	a4,s2,800003b0 <consoleintr+0x104>
      cons.e--;
    80000390:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000394:	10000513          	li	a0,256
    80000398:	ee3ff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    8000039c:	0a04a783          	lw	a5,160(s1)
    800003a0:	09c4a703          	lw	a4,156(s1)
    800003a4:	fcf71ee3          	bne	a4,a5,80000380 <consoleintr+0xd4>
    800003a8:	6902                	ld	s2,0(sp)
    800003aa:	bf15                	j	800002de <consoleintr+0x32>
    800003ac:	6902                	ld	s2,0(sp)
    800003ae:	bf05                	j	800002de <consoleintr+0x32>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b4:	00012717          	auipc	a4,0x12
    800003b8:	06c70713          	addi	a4,a4,108 # 80012420 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00012717          	auipc	a4,0x12
    800003ce:	0ef72b23          	sw	a5,246(a4) # 800124c0 <cons+0xa0>
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	ea5ff0ef          	jal	8000027a <consputc>
    800003da:	b711                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003dc:	f00481e3          	beqz	s1,800002de <consoleintr+0x32>
    800003e0:	bf31                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003e2:	4529                	li	a0,10
    800003e4:	e97ff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003e8:	00012797          	auipc	a5,0x12
    800003ec:	03878793          	addi	a5,a5,56 # 80012420 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00012797          	auipc	a5,0x12
    8000040e:	0ac7a923          	sw	a2,178(a5) # 800124bc <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00012517          	auipc	a0,0x12
    80000416:	0a650513          	addi	a0,a0,166 # 800124b8 <cons+0x98>
    8000041a:	48b010ef          	jal	800020a4 <wakeup>
    8000041e:	b5c1                	j	800002de <consoleintr+0x32>

0000000080000420 <consoleinit>:

void
consoleinit(void)
{
    80000420:	1141                	addi	sp,sp,-16
    80000422:	e406                	sd	ra,8(sp)
    80000424:	e022                	sd	s0,0(sp)
    80000426:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000428:	00007597          	auipc	a1,0x7
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80007000 <etext>
    80000430:	00012517          	auipc	a0,0x12
    80000434:	ff050513          	addi	a0,a0,-16 # 80012420 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00022797          	auipc	a5,0x22
    80000444:	15078793          	addi	a5,a5,336 # 80022590 <devsw>
    80000448:	00000717          	auipc	a4,0x0
    8000044c:	d2e70713          	addi	a4,a4,-722 # 80000176 <consoleread>
    80000450:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000452:	00000717          	auipc	a4,0x0
    80000456:	c8270713          	addi	a4,a4,-894 # 800000d4 <consolewrite>
    8000045a:	ef98                	sd	a4,24(a5)
}
    8000045c:	60a2                	ld	ra,8(sp)
    8000045e:	6402                	ld	s0,0(sp)
    80000460:	0141                	addi	sp,sp,16
    80000462:	8082                	ret

0000000080000464 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000464:	7139                	addi	sp,sp,-64
    80000466:	fc06                	sd	ra,56(sp)
    80000468:	f822                	sd	s0,48(sp)
    8000046a:	f04a                	sd	s2,32(sp)
    8000046c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000046e:	c219                	beqz	a2,80000474 <printint+0x10>
    80000470:	08054163          	bltz	a0,800004f2 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000474:	4301                	li	t1,0

  i = 0;
    80000476:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000047a:	86ca                	mv	a3,s2
  i = 0;
    8000047c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007817          	auipc	a6,0x7
    80000482:	35a80813          	addi	a6,a6,858 # 800077d8 <digits>
    80000486:	88ba                	mv	a7,a4
    80000488:	0017061b          	addiw	a2,a4,1
    8000048c:	8732                	mv	a4,a2
    8000048e:	02b577b3          	remu	a5,a0,a1
    80000492:	97c2                	add	a5,a5,a6
    80000494:	0007c783          	lbu	a5,0(a5)
    80000498:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    8000049c:	87aa                	mv	a5,a0
    8000049e:	02b55533          	divu	a0,a0,a1
    800004a2:	0685                	addi	a3,a3,1
    800004a4:	feb7f1e3          	bgeu	a5,a1,80000486 <printint+0x22>

  if(sign)
    800004a8:	00030c63          	beqz	t1,800004c0 <printint+0x5c>
    buf[i++] = '-';
    800004ac:	fe060793          	addi	a5,a2,-32
    800004b0:	00878633          	add	a2,a5,s0
    800004b4:	02d00793          	li	a5,45
    800004b8:	fef60423          	sb	a5,-24(a2)
    800004bc:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c0:	02e05463          	blez	a4,800004e8 <printint+0x84>
    800004c4:	f426                	sd	s1,40(sp)
    800004c6:	377d                	addiw	a4,a4,-1
    800004c8:	00e904b3          	add	s1,s2,a4
    800004cc:	197d                	addi	s2,s2,-1
    800004ce:	993a                	add	s2,s2,a4
    800004d0:	1702                	slli	a4,a4,0x20
    800004d2:	9301                	srli	a4,a4,0x20
    800004d4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004d8:	0004c503          	lbu	a0,0(s1)
    800004dc:	d9fff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x74>
    800004e6:	74a2                	ld	s1,40(sp)
}
    800004e8:	70e2                	ld	ra,56(sp)
    800004ea:	7442                	ld	s0,48(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4305                	li	t1,1
    x = -xx;
    800004f8:	bfbd                	j	80000476 <printint+0x12>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	f0ca                	sd	s2,96(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	892a                	mv	s2,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	edc7a783          	lw	a5,-292(a5) # 8000a3f4 <panicking>
    80000520:	cf9d                	beqz	a5,8000055e <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	00094503          	lbu	a0,0(s2)
    8000052e:	22050663          	beqz	a0,8000075a <printf+0x260>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	ecce                	sd	s3,88(sp)
    80000536:	e8d2                	sd	s4,80(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	fc5e                	sd	s7,56(sp)
    8000053e:	f862                	sd	s8,48(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4a01                	li	s4,0
    if(cx != '%'){
    80000546:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000054a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000054e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000552:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000556:	4b29                	li	s6,10
    if(c0 == 'd'){
    80000558:	06400b93          	li	s7,100
    8000055c:	a015                	j	80000580 <printf+0x86>
    acquire(&pr.lock);
    8000055e:	00012517          	auipc	a0,0x12
    80000562:	f6a50513          	addi	a0,a0,-150 # 800124c8 <pr>
    80000566:	6c2000ef          	jal	80000c28 <acquire>
    8000056a:	bf65                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056c:	d0fff0ef          	jal	8000027a <consputc>
      continue;
    80000570:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000572:	2485                	addiw	s1,s1,1
    80000574:	8a26                	mv	s4,s1
    80000576:	94ca                	add	s1,s1,s2
    80000578:	0004c503          	lbu	a0,0(s1)
    8000057c:	1c050663          	beqz	a0,80000748 <printf+0x24e>
    if(cx != '%'){
    80000580:	ff3516e3          	bne	a0,s3,8000056c <printf+0x72>
    i++;
    80000584:	001a079b          	addiw	a5,s4,1
    80000588:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058a:	00f90733          	add	a4,s2,a5
    8000058e:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000592:	200a8963          	beqz	s5,800007a4 <printf+0x2aa>
    80000596:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059a:	1e068c63          	beqz	a3,80000792 <printf+0x298>
    if(c0 == 'd'){
    8000059e:	037a8863          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a2:	f94a8713          	addi	a4,s5,-108
    800005a6:	00173713          	seqz	a4,a4
    800005aa:	f9c68613          	addi	a2,a3,-100
    800005ae:	ee05                	bnez	a2,800005e6 <printf+0xec>
    800005b0:	cb1d                	beqz	a4,800005e6 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005b2:	f8843783          	ld	a5,-120(s0)
    800005b6:	00878713          	addi	a4,a5,8
    800005ba:	f8e43423          	sd	a4,-120(s0)
    800005be:	4605                	li	a2,1
    800005c0:	85da                	mv	a1,s6
    800005c2:	6388                	ld	a0,0(a5)
    800005c4:	ea1ff0ef          	jal	80000464 <printint>
      i += 1;
    800005c8:	002a049b          	addiw	s1,s4,2
    800005cc:	b75d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005ce:	f8843783          	ld	a5,-120(s0)
    800005d2:	00878713          	addi	a4,a5,8
    800005d6:	f8e43423          	sd	a4,-120(s0)
    800005da:	4605                	li	a2,1
    800005dc:	85da                	mv	a1,s6
    800005de:	4388                	lw	a0,0(a5)
    800005e0:	e85ff0ef          	jal	80000464 <printint>
    800005e4:	b779                	j	80000572 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005e6:	97ca                	add	a5,a5,s2
    800005e8:	8636                	mv	a2,a3
    800005ea:	0027c683          	lbu	a3,2(a5)
    800005ee:	a2c9                	j	800007b0 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    800005f0:	f8843783          	ld	a5,-120(s0)
    800005f4:	00878713          	addi	a4,a5,8
    800005f8:	f8e43423          	sd	a4,-120(s0)
    800005fc:	4605                	li	a2,1
    800005fe:	45a9                	li	a1,10
    80000600:	6388                	ld	a0,0(a5)
    80000602:	e63ff0ef          	jal	80000464 <printint>
      i += 2;
    80000606:	003a049b          	addiw	s1,s4,3
    8000060a:	b7a5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4601                	li	a2,0
    8000061a:	85da                	mv	a1,s6
    8000061c:	0007e503          	lwu	a0,0(a5)
    80000620:	e45ff0ef          	jal	80000464 <printint>
    80000624:	b7b9                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000626:	f8843783          	ld	a5,-120(s0)
    8000062a:	00878713          	addi	a4,a5,8
    8000062e:	f8e43423          	sd	a4,-120(s0)
    80000632:	4601                	li	a2,0
    80000634:	85da                	mv	a1,s6
    80000636:	6388                	ld	a0,0(a5)
    80000638:	e2dff0ef          	jal	80000464 <printint>
      i += 1;
    8000063c:	002a049b          	addiw	s1,s4,2
    80000640:	bf0d                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e11ff0ef          	jal	80000464 <printint>
      i += 2;
    80000658:	003a049b          	addiw	s1,s4,3
    8000065c:	bf19                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	df3ff0ef          	jal	80000464 <printint>
    80000676:	bdf5                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	dddff0ef          	jal	80000464 <printint>
      i += 1;
    8000068c:	002a049b          	addiw	s1,s4,2
    80000690:	b5cd                	j	80000572 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4601                	li	a2,0
    800006a0:	45c1                	li	a1,16
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	dc1ff0ef          	jal	80000464 <printint>
      i += 2;
    800006a8:	003a049b          	addiw	s1,s4,3
    800006ac:	b5d9                	j	80000572 <printf+0x78>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	106c8c93          	addi	s9,s9,262 # 800077d8 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1e0>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	b541                	j	80000572 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5b5                	j	80000572 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	e40509e3          	beqz	a0,80000572 <printf+0x78>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x22a>
    80000730:	b589                	j	80000572 <printf+0x78>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b535                	j	80000572 <printf+0x78>
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	0000a797          	auipc	a5,0xa
    8000075e:	c9a7a783          	lw	a5,-870(a5) # 8000a3f4 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	7906                	ld	s2,96(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	74a6                	ld	s1,104(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x260>
    release(&pr.lock);
    80000784:	00012517          	auipc	a0,0x12
    80000788:	d4450513          	addi	a0,a0,-700 # 800124c8 <pr>
    8000078c:	530000ef          	jal	80000cbc <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x26a>
    if(c0 == 'd'){
    80000792:	e37a8ee3          	beq	s5,s7,800005ce <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8713          	addi	a4,s5,-108
    8000079a:	00173713          	seqz	a4,a4
    8000079e:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4781                	li	a5,0
    800007a2:	a00d                	j	800007c4 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8713          	addi	a4,s5,-108
    800007a8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460793          	addi	a5,a2,-108
    800007b4:	0017b793          	seqz	a5,a5
    800007b8:	8ff9                	and	a5,a5,a4
    800007ba:	f9c68593          	addi	a1,a3,-100
    800007be:	e199                	bnez	a1,800007c4 <printf+0x2ca>
    800007c0:	e20798e3          	bnez	a5,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800007c4:	e58a84e3          	beq	s5,s8,8000060c <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007c8:	f8b60593          	addi	a1,a2,-117
    800007cc:	e199                	bnez	a1,800007d2 <printf+0x2d8>
    800007ce:	e4071ce3          	bnez	a4,80000626 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007d2:	f8b68593          	addi	a1,a3,-117
    800007d6:	e199                	bnez	a1,800007dc <printf+0x2e2>
    800007d8:	e60795e3          	bnez	a5,80000642 <printf+0x148>
    } else if(c0 == 'x'){
    800007dc:	e9aa81e3          	beq	s5,s10,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    800007e0:	f8860613          	addi	a2,a2,-120
    800007e4:	e219                	bnez	a2,800007ea <printf+0x2f0>
    800007e6:	e80719e3          	bnez	a4,80000678 <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007ea:	f8868693          	addi	a3,a3,-120
    800007ee:	e299                	bnez	a3,800007f4 <printf+0x2fa>
    800007f0:	ea0791e3          	bnez	a5,80000692 <printf+0x198>
    } else if(c0 == 'p'){
    800007f4:	ebba8de3          	beq	s5,s11,800006ae <printf+0x1b4>
    } else if(c0 == 'c'){
    800007f8:	06300793          	li	a5,99
    800007fc:	eefa8ce3          	beq	s5,a5,800006f4 <printf+0x1fa>
    } else if(c0 == 's'){
    80000800:	07300793          	li	a5,115
    80000804:	f0fa82e3          	beq	s5,a5,80000708 <printf+0x20e>
    } else if(c0 == '%'){
    80000808:	02500793          	li	a5,37
    8000080c:	f2fa8ae3          	beq	s5,a5,80000740 <printf+0x246>
    } else if(c0 == 0){
    80000810:	f60a80e3          	beqz	s5,80000770 <printf+0x276>
      consputc('%');
    80000814:	02500513          	li	a0,37
    80000818:	a63ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    8000081c:	8556                	mv	a0,s5
    8000081e:	a5dff0ef          	jal	8000027a <consputc>
    80000822:	bb81                	j	80000572 <printf+0x78>

0000000080000824 <panic>:

void
panic(char *s)
{
    80000824:	1101                	addi	sp,sp,-32
    80000826:	ec06                	sd	ra,24(sp)
    80000828:	e822                	sd	s0,16(sp)
    8000082a:	e426                	sd	s1,8(sp)
    8000082c:	e04a                	sd	s2,0(sp)
    8000082e:	1000                	addi	s0,sp,32
    80000830:	892a                	mv	s2,a0
  panicking = 1;
    80000832:	4485                	li	s1,1
    80000834:	0000a797          	auipc	a5,0xa
    80000838:	bc97a023          	sw	s1,-1088(a5) # 8000a3f4 <panicking>
  printf("panic: ");
    8000083c:	00006517          	auipc	a0,0x6
    80000840:	7dc50513          	addi	a0,a0,2012 # 80007018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00006517          	auipc	a0,0x6
    8000084e:	7d650513          	addi	a0,a0,2006 # 80007020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000a797          	auipc	a5,0xa
    8000085a:	b897ad23          	sw	s1,-1126(a5) # 8000a3f0 <panicked>
  for(;;)
    8000085e:	a001                	j	8000085e <panic+0x3a>

0000000080000860 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000860:	1141                	addi	sp,sp,-16
    80000862:	e406                	sd	ra,8(sp)
    80000864:	e022                	sd	s0,0(sp)
    80000866:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000868:	00006597          	auipc	a1,0x6
    8000086c:	7c058593          	addi	a1,a1,1984 # 80007028 <etext+0x28>
    80000870:	00012517          	auipc	a0,0x12
    80000874:	c5850513          	addi	a0,a0,-936 # 800124c8 <pr>
    80000878:	326000ef          	jal	80000b9e <initlock>
}
    8000087c:	60a2                	ld	ra,8(sp)
    8000087e:	6402                	ld	s0,0(sp)
    80000880:	0141                	addi	sp,sp,16
    80000882:	8082                	ret

0000000080000884 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000884:	1141                	addi	sp,sp,-16
    80000886:	e406                	sd	ra,8(sp)
    80000888:	e022                	sd	s0,0(sp)
    8000088a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000088c:	100007b7          	lui	a5,0x10000
    80000890:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000894:	10000737          	lui	a4,0x10000
    80000898:	f8000693          	li	a3,-128
    8000089c:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a0:	468d                	li	a3,3
    800008a2:	10000637          	lui	a2,0x10000
    800008a6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008aa:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008ae:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008b2:	8732                	mv	a4,a2
    800008b4:	461d                	li	a2,7
    800008b6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ba:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008be:	00006597          	auipc	a1,0x6
    800008c2:	77258593          	addi	a1,a1,1906 # 80007030 <etext+0x30>
    800008c6:	00012517          	auipc	a0,0x12
    800008ca:	c1a50513          	addi	a0,a0,-998 # 800124e0 <tx_lock>
    800008ce:	2d0000ef          	jal	80000b9e <initlock>
}
    800008d2:	60a2                	ld	ra,8(sp)
    800008d4:	6402                	ld	s0,0(sp)
    800008d6:	0141                	addi	sp,sp,16
    800008d8:	8082                	ret

00000000800008da <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008da:	715d                	addi	sp,sp,-80
    800008dc:	e486                	sd	ra,72(sp)
    800008de:	e0a2                	sd	s0,64(sp)
    800008e0:	fc26                	sd	s1,56(sp)
    800008e2:	ec56                	sd	s5,24(sp)
    800008e4:	0880                	addi	s0,sp,80
    800008e6:	8aaa                	mv	s5,a0
    800008e8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008ea:	00012517          	auipc	a0,0x12
    800008ee:	bf650513          	addi	a0,a0,-1034 # 800124e0 <tx_lock>
    800008f2:	336000ef          	jal	80000c28 <acquire>

  int i = 0;
  while(i < n){ 
    800008f6:	06905063          	blez	s1,80000956 <uartwrite+0x7c>
    800008fa:	f84a                	sd	s2,48(sp)
    800008fc:	f44e                	sd	s3,40(sp)
    800008fe:	f052                	sd	s4,32(sp)
    80000900:	e85a                	sd	s6,16(sp)
    80000902:	e45e                	sd	s7,8(sp)
    80000904:	8a56                	mv	s4,s5
    80000906:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    80000908:	0000a497          	auipc	s1,0xa
    8000090c:	af448493          	addi	s1,s1,-1292 # 8000a3fc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00012997          	auipc	s3,0x12
    80000914:	bd098993          	addi	s3,s3,-1072 # 800124e0 <tx_lock>
    80000918:	0000a917          	auipc	s2,0xa
    8000091c:	ae090913          	addi	s2,s2,-1312 # 8000a3f8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000920:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000924:	4b05                	li	s6,1
    80000926:	a005                	j	80000946 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000928:	85ce                	mv	a1,s3
    8000092a:	854a                	mv	a0,s2
    8000092c:	72c010ef          	jal	80002058 <sleep>
    while(tx_busy != 0){
    80000930:	409c                	lw	a5,0(s1)
    80000932:	fbfd                	bnez	a5,80000928 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000934:	000a4783          	lbu	a5,0(s4)
    80000938:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000093c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000940:	0a05                	addi	s4,s4,1
    80000942:	015a0563          	beq	s4,s5,8000094c <uartwrite+0x72>
    while(tx_busy != 0){
    80000946:	409c                	lw	a5,0(s1)
    80000948:	f3e5                	bnez	a5,80000928 <uartwrite+0x4e>
    8000094a:	b7ed                	j	80000934 <uartwrite+0x5a>
    8000094c:	7942                	ld	s2,48(sp)
    8000094e:	79a2                	ld	s3,40(sp)
    80000950:	7a02                	ld	s4,32(sp)
    80000952:	6b42                	ld	s6,16(sp)
    80000954:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000956:	00012517          	auipc	a0,0x12
    8000095a:	b8a50513          	addi	a0,a0,-1142 # 800124e0 <tx_lock>
    8000095e:	35e000ef          	jal	80000cbc <release>
}
    80000962:	60a6                	ld	ra,72(sp)
    80000964:	6406                	ld	s0,64(sp)
    80000966:	74e2                	ld	s1,56(sp)
    80000968:	6ae2                	ld	s5,24(sp)
    8000096a:	6161                	addi	sp,sp,80
    8000096c:	8082                	ret

000000008000096e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000096e:	1101                	addi	sp,sp,-32
    80000970:	ec06                	sd	ra,24(sp)
    80000972:	e822                	sd	s0,16(sp)
    80000974:	e426                	sd	s1,8(sp)
    80000976:	1000                	addi	s0,sp,32
    80000978:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000097a:	0000a797          	auipc	a5,0xa
    8000097e:	a7a7a783          	lw	a5,-1414(a5) # 8000a3f4 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000a797          	auipc	a5,0xa
    80000988:	a6c7a783          	lw	a5,-1428(a5) # 8000a3f0 <panicked>
    8000098c:	ef85                	bnez	a5,800009c4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000098e:	10000737          	lui	a4,0x10000
    80000992:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000994:	00074783          	lbu	a5,0(a4)
    80000998:	0207f793          	andi	a5,a5,32
    8000099c:	dfe5                	beqz	a5,80000994 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000099e:	0ff4f513          	zext.b	a0,s1
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009aa:	0000a797          	auipc	a5,0xa
    800009ae:	a4a7a783          	lw	a5,-1462(a5) # 8000a3f4 <panicking>
    800009b2:	cb91                	beqz	a5,800009c6 <uartputc_sync+0x58>
    pop_off();
}
    800009b4:	60e2                	ld	ra,24(sp)
    800009b6:	6442                	ld	s0,16(sp)
    800009b8:	64a2                	ld	s1,8(sp)
    800009ba:	6105                	addi	sp,sp,32
    800009bc:	8082                	ret
    push_off();
    800009be:	226000ef          	jal	80000be4 <push_off>
    800009c2:	b7c9                	j	80000984 <uartputc_sync+0x16>
    for(;;)
    800009c4:	a001                	j	800009c4 <uartputc_sync+0x56>
    pop_off();
    800009c6:	2a6000ef          	jal	80000c6c <pop_off>
}
    800009ca:	b7ed                	j	800009b4 <uartputc_sync+0x46>

00000000800009cc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009cc:	1141                	addi	sp,sp,-16
    800009ce:	e406                	sd	ra,8(sp)
    800009d0:	e022                	sd	s0,0(sp)
    800009d2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009dc:	8b85                	andi	a5,a5,1
    800009de:	cb89                	beqz	a5,800009f0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009e0:	100007b7          	lui	a5,0x10000
    800009e4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009e8:	60a2                	ld	ra,8(sp)
    800009ea:	6402                	ld	s0,0(sp)
    800009ec:	0141                	addi	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfdd                	j	800009e8 <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009fe:	100007b7          	lui	a5,0x10000
    80000a02:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a06:	00012517          	auipc	a0,0x12
    80000a0a:	ada50513          	addi	a0,a0,-1318 # 800124e0 <tx_lock>
    80000a0e:	21a000ef          	jal	80000c28 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a1a:	0207f793          	andi	a5,a5,32
    80000a1e:	ef99                	bnez	a5,80000a3c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a20:	00012517          	auipc	a0,0x12
    80000a24:	ac050513          	addi	a0,a0,-1344 # 800124e0 <tx_lock>
    80000a28:	294000ef          	jal	80000cbc <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a2c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a2e:	f9fff0ef          	jal	800009cc <uartgetc>
    if(c == -1)
    80000a32:	02950063          	beq	a0,s1,80000a52 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a36:	877ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a3a:	bfd5                	j	80000a2e <uartintr+0x3a>
    tx_busy = 0;
    80000a3c:	0000a797          	auipc	a5,0xa
    80000a40:	9c07a023          	sw	zero,-1600(a5) # 8000a3fc <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000a517          	auipc	a0,0xa
    80000a48:	9b450513          	addi	a0,a0,-1612 # 8000a3f8 <tx_chan>
    80000a4c:	658010ef          	jal	800020a4 <wakeup>
    80000a50:	bfc1                	j	80000a20 <uartintr+0x2c>
  }
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret

0000000080000a5c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a5c:	1101                	addi	sp,sp,-32
    80000a5e:	ec06                	sd	ra,24(sp)
    80000a60:	e822                	sd	s0,16(sp)
    80000a62:	e426                	sd	s1,8(sp)
    80000a64:	e04a                	sd	s2,0(sp)
    80000a66:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a68:	00023797          	auipc	a5,0x23
    80000a6c:	cc078793          	addi	a5,a5,-832 # 80023728 <end>
    80000a70:	00f53733          	sltu	a4,a0,a5
    80000a74:	47c5                	li	a5,17
    80000a76:	07ee                	slli	a5,a5,0x1b
    80000a78:	17fd                	addi	a5,a5,-1
    80000a7a:	00a7b7b3          	sltu	a5,a5,a0
    80000a7e:	8fd9                	or	a5,a5,a4
    80000a80:	ef95                	bnez	a5,80000abc <kfree+0x60>
    80000a82:	84aa                	mv	s1,a0
    80000a84:	03451793          	slli	a5,a0,0x34
    80000a88:	eb95                	bnez	a5,80000abc <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a8a:	6605                	lui	a2,0x1
    80000a8c:	4585                	li	a1,1
    80000a8e:	26a000ef          	jal	80000cf8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a92:	00012917          	auipc	s2,0x12
    80000a96:	a6690913          	addi	s2,s2,-1434 # 800124f8 <kmem>
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	18c000ef          	jal	80000c28 <acquire>
  r->next = kmem.freelist;
    80000aa0:	01893783          	ld	a5,24(s2)
    80000aa4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aa6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	210000ef          	jal	80000cbc <release>
}
    80000ab0:	60e2                	ld	ra,24(sp)
    80000ab2:	6442                	ld	s0,16(sp)
    80000ab4:	64a2                	ld	s1,8(sp)
    80000ab6:	6902                	ld	s2,0(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    panic("kfree");
    80000abc:	00006517          	auipc	a0,0x6
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80007038 <etext+0x38>
    80000ac4:	d61ff0ef          	jal	80000824 <panic>

0000000080000ac8 <freerange>:
{
    80000ac8:	7179                	addi	sp,sp,-48
    80000aca:	f406                	sd	ra,40(sp)
    80000acc:	f022                	sd	s0,32(sp)
    80000ace:	ec26                	sd	s1,24(sp)
    80000ad0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ad2:	6785                	lui	a5,0x1
    80000ad4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad8:	00e504b3          	add	s1,a0,a4
    80000adc:	777d                	lui	a4,0xfffff
    80000ade:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0295e263          	bltu	a1,s1,80000b06 <freerange+0x3e>
    80000ae6:	e84a                	sd	s2,16(sp)
    80000ae8:	e44e                	sd	s3,8(sp)
    80000aea:	e052                	sd	s4,0(sp)
    80000aec:	892e                	mv	s2,a1
    kfree(p);
    80000aee:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	89be                	mv	s3,a5
    kfree(p);
    80000af2:	01448533          	add	a0,s1,s4
    80000af6:	f67ff0ef          	jal	80000a5c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000afa:	94ce                	add	s1,s1,s3
    80000afc:	fe997be3          	bgeu	s2,s1,80000af2 <freerange+0x2a>
    80000b00:	6942                	ld	s2,16(sp)
    80000b02:	69a2                	ld	s3,8(sp)
    80000b04:	6a02                	ld	s4,0(sp)
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <kinit>:
{
    80000b10:	1141                	addi	sp,sp,-16
    80000b12:	e406                	sd	ra,8(sp)
    80000b14:	e022                	sd	s0,0(sp)
    80000b16:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b18:	00006597          	auipc	a1,0x6
    80000b1c:	52858593          	addi	a1,a1,1320 # 80007040 <etext+0x40>
    80000b20:	00012517          	auipc	a0,0x12
    80000b24:	9d850513          	addi	a0,a0,-1576 # 800124f8 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00023517          	auipc	a0,0x23
    80000b34:	bf850513          	addi	a0,a0,-1032 # 80023728 <end>
    80000b38:	f91ff0ef          	jal	80000ac8 <freerange>
}
    80000b3c:	60a2                	ld	ra,8(sp)
    80000b3e:	6402                	ld	s0,0(sp)
    80000b40:	0141                	addi	sp,sp,16
    80000b42:	8082                	ret

0000000080000b44 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b44:	1101                	addi	sp,sp,-32
    80000b46:	ec06                	sd	ra,24(sp)
    80000b48:	e822                	sd	s0,16(sp)
    80000b4a:	e426                	sd	s1,8(sp)
    80000b4c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4e:	00012517          	auipc	a0,0x12
    80000b52:	9aa50513          	addi	a0,a0,-1622 # 800124f8 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00012497          	auipc	s1,0x12
    80000b5e:	9b64b483          	ld	s1,-1610(s1) # 80012510 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00012717          	auipc	a4,0x12
    80000b6a:	9af73523          	sd	a5,-1622(a4) # 80012510 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00012517          	auipc	a0,0x12
    80000b72:	98a50513          	addi	a0,a0,-1654 # 800124f8 <kmem>
    80000b76:	146000ef          	jal	80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7a:	6605                	lui	a2,0x1
    80000b7c:	4595                	li	a1,5
    80000b7e:	8526                	mv	a0,s1
    80000b80:	178000ef          	jal	80000cf8 <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	00012517          	auipc	a0,0x12
    80000b94:	96850513          	addi	a0,a0,-1688 # 800124f8 <kmem>
    80000b98:	124000ef          	jal	80000cbc <release>
  if(r)
    80000b9c:	b7e5                	j	80000b84 <kalloc+0x40>

0000000080000b9e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b9e:	1141                	addi	sp,sp,-16
    80000ba0:	e406                	sd	ra,8(sp)
    80000ba2:	e022                	sd	s0,0(sp)
    80000ba4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bac:	00053823          	sd	zero,16(a0)
}
    80000bb0:	60a2                	ld	ra,8(sp)
    80000bb2:	6402                	ld	s0,0(sp)
    80000bb4:	0141                	addi	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	addi	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	691c                	ld	a5,16(a0)
    80000bcc:	84be                	mv	s1,a5
    80000bce:	5ab000ef          	jal	80001978 <mycpu>
    80000bd2:	40a48533          	sub	a0,s1,a0
    80000bd6:	00153513          	seqz	a0,a0
}
    80000bda:	60e2                	ld	ra,24(sp)
    80000bdc:	6442                	ld	s0,16(sp)
    80000bde:	64a2                	ld	s1,8(sp)
    80000be0:	6105                	addi	sp,sp,32
    80000be2:	8082                	ret

0000000080000be4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bee:	100027f3          	csrr	a5,sstatus
    80000bf2:	84be                	mv	s1,a5
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000bfe:	57b000ef          	jal	80001978 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	573000ef          	jal	80001978 <mycpu>
    80000c0a:	5d3c                	lw	a5,120(a0)
    80000c0c:	2785                	addiw	a5,a5,1
    80000c0e:	dd3c                	sw	a5,120(a0)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    mycpu()->intena = old;
    80000c1a:	55f000ef          	jal	80001978 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c1e:	0014d793          	srli	a5,s1,0x1
    80000c22:	8b85                	andi	a5,a5,1
    80000c24:	dd7c                	sw	a5,124(a0)
    80000c26:	b7c5                	j	80000c06 <push_off+0x22>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	fb1ff0ef          	jal	80000be4 <push_off>
  if(holding(lk))
    80000c38:	8526                	mv	a0,s1
    80000c3a:	f7fff0ef          	jal	80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c3e:	4705                	li	a4,1
  if(holding(lk))
    80000c40:	e105                	bnez	a0,80000c60 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c42:	87ba                	mv	a5,a4
    80000c44:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c48:	2781                	sext.w	a5,a5
    80000c4a:	ffe5                	bnez	a5,80000c42 <acquire+0x1a>
  __sync_synchronize();
    80000c4c:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c50:	529000ef          	jal	80001978 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00006517          	auipc	a0,0x6
    80000c64:	3e850513          	addi	a0,a0,1000 # 80007048 <etext+0x48>
    80000c68:	bbdff0ef          	jal	80000824 <panic>

0000000080000c6c <pop_off>:

void
pop_off(void)
{
    80000c6c:	1141                	addi	sp,sp,-16
    80000c6e:	e406                	sd	ra,8(sp)
    80000c70:	e022                	sd	s0,0(sp)
    80000c72:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c74:	505000ef          	jal	80001978 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c78:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c7c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7e:	e39d                	bnez	a5,80000ca4 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c80:	5d3c                	lw	a5,120(a0)
    80000c82:	02f05763          	blez	a5,80000cb0 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c86:	37fd                	addiw	a5,a5,-1
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb89                	bnez	a5,80000c9c <pop_off+0x30>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00006517          	auipc	a0,0x6
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80007050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3b850513          	addi	a0,a0,952 # 80007068 <etext+0x68>
    80000cb8:	b6dff0ef          	jal	80000824 <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	ef1ff0ef          	jal	80000bb8 <holding>
    80000ccc:	c105                	beqz	a0,80000cec <release+0x30>
  lk->cpu = 0;
    80000cce:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000cd6:	0310000f          	fence	rw,w
    80000cda:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cde:	f8fff0ef          	jal	80000c6c <pop_off>
}
    80000ce2:	60e2                	ld	ra,24(sp)
    80000ce4:	6442                	ld	s0,16(sp)
    80000ce6:	64a2                	ld	s1,8(sp)
    80000ce8:	6105                	addi	sp,sp,32
    80000cea:	8082                	ret
    panic("release");
    80000cec:	00006517          	auipc	a0,0x6
    80000cf0:	38450513          	addi	a0,a0,900 # 80007070 <etext+0x70>
    80000cf4:	b31ff0ef          	jal	80000824 <panic>

0000000080000cf8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e406                	sd	ra,8(sp)
    80000cfc:	e022                	sd	s0,0(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1e>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x14>
  }
  return dst;
}
    80000d16:	60a2                	ld	ra,8(sp)
    80000d18:	6402                	ld	s0,0(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e406                	sd	ra,8(sp)
    80000d22:	e022                	sd	s0,0(sp)
    80000d24:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d26:	c61d                	beqz	a2,80000d54 <memcmp+0x36>
    80000d28:	1602                	slli	a2,a2,0x20
    80000d2a:	9201                	srli	a2,a2,0x20
    80000d2c:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x12>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x2e>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	60a2                	ld	ra,8(sp)
    80000d4e:	6402                	ld	s0,0(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfdd                	j	80000d4c <memcmp+0x2e>

0000000080000d58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e406                	sd	ra,8(sp)
    80000d5c:	e022                	sd	s0,0(sp)
    80000d5e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d60:	c205                	beqz	a2,80000d80 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d62:	02a5e363          	bltu	a1,a0,80000d88 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d66:	1602                	slli	a2,a2,0x20
    80000d68:	9201                	srli	a2,a2,0x20
    80000d6a:	00c587b3          	add	a5,a1,a2
{
    80000d6e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0705                	addi	a4,a4,1
    80000d74:	fff5c683          	lbu	a3,-1(a1)
    80000d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7c:	feb79ae3          	bne	a5,a1,80000d70 <memmove+0x18>

  return dst;
}
    80000d80:	60a2                	ld	ra,8(sp)
    80000d82:	6402                	ld	s0,0(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
  if(s < d && s + n > d){
    80000d88:	02061693          	slli	a3,a2,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	00d58733          	add	a4,a1,a3
    80000d92:	fce57ae3          	bgeu	a0,a4,80000d66 <memmove+0xe>
    d += n;
    80000d96:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d98:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d9c:	1782                	slli	a5,a5,0x20
    80000d9e:	9381                	srli	a5,a5,0x20
    80000da0:	fff7c793          	not	a5,a5
    80000da4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000da6:	177d                	addi	a4,a4,-1
    80000da8:	16fd                	addi	a3,a3,-1
    80000daa:	00074603          	lbu	a2,0(a4)
    80000dae:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000db2:	fee79ae3          	bne	a5,a4,80000da6 <memmove+0x4e>
    80000db6:	b7e9                	j	80000d80 <memmove+0x28>

0000000080000db8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e406                	sd	ra,8(sp)
    80000dbc:	e022                	sd	s0,0(sp)
    80000dbe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc0:	f99ff0ef          	jal	80000d58 <memmove>
}
    80000dc4:	60a2                	ld	ra,8(sp)
    80000dc6:	6402                	ld	s0,0(sp)
    80000dc8:	0141                	addi	sp,sp,16
    80000dca:	8082                	ret

0000000080000dcc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dcc:	1141                	addi	sp,sp,-16
    80000dce:	e406                	sd	ra,8(sp)
    80000dd0:	e022                	sd	s0,0(sp)
    80000dd2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd4:	ce11                	beqz	a2,80000df0 <strncmp+0x24>
    80000dd6:	00054783          	lbu	a5,0(a0)
    80000dda:	cf89                	beqz	a5,80000df4 <strncmp+0x28>
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	00f71a63          	bne	a4,a5,80000df4 <strncmp+0x28>
    n--, p++, q++;
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	0505                	addi	a0,a0,1
    80000de8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dea:	f675                	bnez	a2,80000dd6 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000dec:	4501                	li	a0,0
    80000dee:	a801                	j	80000dfe <strncmp+0x32>
    80000df0:	4501                	li	a0,0
    80000df2:	a031                	j	80000dfe <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000df4:	00054503          	lbu	a0,0(a0)
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	9d1d                	subw	a0,a0,a5
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e0e:	87aa                	mv	a5,a0
    80000e10:	a011                	j	80000e14 <strncpy+0xe>
    80000e12:	8636                	mv	a2,a3
    80000e14:	02c05863          	blez	a2,80000e44 <strncpy+0x3e>
    80000e18:	fff6069b          	addiw	a3,a2,-1
    80000e1c:	8836                	mv	a6,a3
    80000e1e:	0785                	addi	a5,a5,1
    80000e20:	0005c703          	lbu	a4,0(a1)
    80000e24:	fee78fa3          	sb	a4,-1(a5)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f765                	bnez	a4,80000e12 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2c:	873e                	mv	a4,a5
    80000e2e:	01005b63          	blez	a6,80000e44 <strncpy+0x3e>
    80000e32:	9fb1                	addw	a5,a5,a2
    80000e34:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e36:	0705                	addi	a4,a4,1
    80000e38:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3c:	40e786bb          	subw	a3,a5,a4
    80000e40:	fed04be3          	bgtz	a3,80000e36 <strncpy+0x30>
  return os;
}
    80000e44:	60a2                	ld	ra,8(sp)
    80000e46:	6402                	ld	s0,0(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e406                	sd	ra,8(sp)
    80000e50:	e022                	sd	s0,0(sp)
    80000e52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e54:	02c05363          	blez	a2,80000e7a <safestrcpy+0x2e>
    80000e58:	fff6069b          	addiw	a3,a2,-1
    80000e5c:	1682                	slli	a3,a3,0x20
    80000e5e:	9281                	srli	a3,a3,0x20
    80000e60:	96ae                	add	a3,a3,a1
    80000e62:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e64:	00d58963          	beq	a1,a3,80000e76 <safestrcpy+0x2a>
    80000e68:	0585                	addi	a1,a1,1
    80000e6a:	0785                	addi	a5,a5,1
    80000e6c:	fff5c703          	lbu	a4,-1(a1)
    80000e70:	fee78fa3          	sb	a4,-1(a5)
    80000e74:	fb65                	bnez	a4,80000e64 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e76:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret

0000000080000e82 <strlen>:

int
strlen(const char *s)
{
    80000e82:	1141                	addi	sp,sp,-16
    80000e84:	e406                	sd	ra,8(sp)
    80000e86:	e022                	sd	s0,0(sp)
    80000e88:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8a:	00054783          	lbu	a5,0(a0)
    80000e8e:	cf91                	beqz	a5,80000eaa <strlen+0x28>
    80000e90:	00150793          	addi	a5,a0,1
    80000e94:	86be                	mv	a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	ff65                	bnez	a4,80000e94 <strlen+0x12>
    80000e9e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea2:	60a2                	ld	ra,8(sp)
    80000ea4:	6402                	ld	s0,0(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eaa:	4501                	li	a0,0
    80000eac:	bfdd                	j	80000ea2 <strlen+0x20>

0000000080000eae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eae:	1141                	addi	sp,sp,-16
    80000eb0:	e406                	sd	ra,8(sp)
    80000eb2:	e022                	sd	s0,0(sp)
    80000eb4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb6:	2af000ef          	jal	80001964 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00009717          	auipc	a4,0x9
    80000ebe:	54670713          	addi	a4,a4,1350 # 8000a400 <started>
  if(cpuid() == 0){
    80000ec2:	c51d                	beqz	a0,80000ef0 <main+0x42>
    while(started == 0)
    80000ec4:	431c                	lw	a5,0(a4)
    80000ec6:	2781                	sext.w	a5,a5
    80000ec8:	dff5                	beqz	a5,80000ec4 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	297000ef          	jal	80001964 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	792010ef          	jal	80002676 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	041040ef          	jal	80005728 <plicinithart>
  }

  scheduler();        
    80000eec:	727000ef          	jal	80001e12 <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	187000ef          	jal	800018ae <procinit>
    trapinit();      // trap vectors
    80000f2c:	726010ef          	jal	80002652 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	746010ef          	jal	80002676 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	7da040ef          	jal	8000570e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	7f0040ef          	jal	80005728 <plicinithart>
    binit();         // buffer cache
    80000f3c:	61f010ef          	jal	80002d5a <binit>
    iinit();         // inode table
    80000f40:	370020ef          	jal	800032b0 <iinit>
    fileinit();      // file table
    80000f44:	29c030ef          	jal	800041e0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	0d1040ef          	jal	80005818 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	51b000ef          	jal	80001c66 <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00009717          	auipc	a4,0x9
    80000f5a:	4af72523          	sw	a5,1194(a4) # 8000a400 <started>
    80000f5e:	b779                	j	80000eec <main+0x3e>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00009797          	auipc	a5,0x9
    80000f70:	49c7b783          	ld	a5,1180(a5) # 8000a408 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	04b7e263          	bltu	a5,a1,80000ff2 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
    80000fc6:	cf85                	beqz	a5,80000ffe <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc8:	80a9                	srli	s1,s1,0xa
    80000fca:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000fcc:	3a5d                	addiw	s4,s4,-9
    80000fce:	ff5a12e3          	bne	s4,s5,80000fb2 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fd2:	00c9d513          	srli	a0,s3,0xc
    80000fd6:	1ff57513          	andi	a0,a0,511
    80000fda:	050e                	slli	a0,a0,0x3
    80000fdc:	9526                	add	a0,a0,s1
}
    80000fde:	70e2                	ld	ra,56(sp)
    80000fe0:	7442                	ld	s0,48(sp)
    80000fe2:	74a2                	ld	s1,40(sp)
    80000fe4:	7902                	ld	s2,32(sp)
    80000fe6:	69e2                	ld	s3,24(sp)
    80000fe8:	6a42                	ld	s4,16(sp)
    80000fea:	6aa2                	ld	s5,8(sp)
    80000fec:	6b02                	ld	s6,0(sp)
    80000fee:	6121                	addi	sp,sp,64
    80000ff0:	8082                	ret
    panic("walk");
    80000ff2:	00006517          	auipc	a0,0x6
    80000ff6:	0be50513          	addi	a0,a0,190 # 800070b0 <etext+0xb0>
    80000ffa:	82bff0ef          	jal	80000824 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	020b0263          	beqz	s6,80001022 <walk+0x96>
    80001002:	b43ff0ef          	jal	80000b44 <kalloc>
    80001006:	84aa                	mv	s1,a0
    80001008:	d979                	beqz	a0,80000fde <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    8000100a:	6605                	lui	a2,0x1
    8000100c:	4581                	li	a1,0
    8000100e:	cebff0ef          	jal	80000cf8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
    80001020:	b775                	j	80000fcc <walk+0x40>
        return 0;
    80001022:	4501                	li	a0,0
    80001024:	bf6d                	j	80000fde <walk+0x52>

0000000080001026 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001026:	57fd                	li	a5,-1
    80001028:	83e9                	srli	a5,a5,0x1a
    8000102a:	00b7f463          	bgeu	a5,a1,80001032 <walkaddr+0xc>
    return 0;
    8000102e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001030:	8082                	ret
{
    80001032:	1141                	addi	sp,sp,-16
    80001034:	e406                	sd	ra,8(sp)
    80001036:	e022                	sd	s0,0(sp)
    80001038:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000103a:	4601                	li	a2,0
    8000103c:	f51ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    80001040:	c901                	beqz	a0,80001050 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001042:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001044:	0117f693          	andi	a3,a5,17
    80001048:	4745                	li	a4,17
    return 0;
    8000104a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000104c:	00e68663          	beq	a3,a4,80001058 <walkaddr+0x32>
}
    80001050:	60a2                	ld	ra,8(sp)
    80001052:	6402                	ld	s0,0(sp)
    80001054:	0141                	addi	sp,sp,16
    80001056:	8082                	ret
  pa = PTE2PA(*pte);
    80001058:	83a9                	srli	a5,a5,0xa
    8000105a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000105e:	bfcd                	j	80001050 <walkaddr+0x2a>

0000000080001060 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001060:	715d                	addi	sp,sp,-80
    80001062:	e486                	sd	ra,72(sp)
    80001064:	e0a2                	sd	s0,64(sp)
    80001066:	fc26                	sd	s1,56(sp)
    80001068:	f84a                	sd	s2,48(sp)
    8000106a:	f44e                	sd	s3,40(sp)
    8000106c:	f052                	sd	s4,32(sp)
    8000106e:	ec56                	sd	s5,24(sp)
    80001070:	e85a                	sd	s6,16(sp)
    80001072:	e45e                	sd	s7,8(sp)
    80001074:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001076:	03459793          	slli	a5,a1,0x34
    8000107a:	eba1                	bnez	a5,800010ca <mappages+0x6a>
    8000107c:	8a2a                	mv	s4,a0
    8000107e:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001080:	03461793          	slli	a5,a2,0x34
    80001084:	eba9                	bnez	a5,800010d6 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    80001086:	ce31                	beqz	a2,800010e2 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001088:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000108c:	80060613          	addi	a2,a2,-2048
    80001090:	00b60933          	add	s2,a2,a1
  a = va;
    80001094:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	4b05                	li	s6,1
    80001098:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000109c:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    8000109e:	865a                	mv	a2,s6
    800010a0:	85a6                	mv	a1,s1
    800010a2:	8552                	mv	a0,s4
    800010a4:	ee9ff0ef          	jal	80000f8c <walk>
    800010a8:	c929                	beqz	a0,800010fa <mappages+0x9a>
    if(*pte & PTE_V)
    800010aa:	611c                	ld	a5,0(a0)
    800010ac:	8b85                	andi	a5,a5,1
    800010ae:	e3a1                	bnez	a5,800010ee <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010b0:	013487b3          	add	a5,s1,s3
    800010b4:	83b1                	srli	a5,a5,0xc
    800010b6:	07aa                	slli	a5,a5,0xa
    800010b8:	0157e7b3          	or	a5,a5,s5
    800010bc:	0017e793          	ori	a5,a5,1
    800010c0:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010c2:	05248863          	beq	s1,s2,80001112 <mappages+0xb2>
    a += PGSIZE;
    800010c6:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c8:	bfd9                	j	8000109e <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ca:	00006517          	auipc	a0,0x6
    800010ce:	fee50513          	addi	a0,a0,-18 # 800070b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00006517          	auipc	a0,0x6
    800010da:	00250513          	addi	a0,a0,2 # 800070d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00006517          	auipc	a0,0x6
    800010e6:	01650513          	addi	a0,a0,22 # 800070f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00006517          	auipc	a0,0x6
    800010f2:	01a50513          	addi	a0,a0,26 # 80007108 <etext+0x108>
    800010f6:	f2eff0ef          	jal	80000824 <panic>
      return -1;
    800010fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010fc:	60a6                	ld	ra,72(sp)
    800010fe:	6406                	ld	s0,64(sp)
    80001100:	74e2                	ld	s1,56(sp)
    80001102:	7942                	ld	s2,48(sp)
    80001104:	79a2                	ld	s3,40(sp)
    80001106:	7a02                	ld	s4,32(sp)
    80001108:	6ae2                	ld	s5,24(sp)
    8000110a:	6b42                	ld	s6,16(sp)
    8000110c:	6ba2                	ld	s7,8(sp)
    8000110e:	6161                	addi	sp,sp,80
    80001110:	8082                	ret
  return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7e5                	j	800010fc <mappages+0x9c>

0000000080001116 <kvmmap>:
{
    80001116:	1141                	addi	sp,sp,-16
    80001118:	e406                	sd	ra,8(sp)
    8000111a:	e022                	sd	s0,0(sp)
    8000111c:	0800                	addi	s0,sp,16
    8000111e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001120:	86b2                	mv	a3,a2
    80001122:	863e                	mv	a2,a5
    80001124:	f3dff0ef          	jal	80001060 <mappages>
    80001128:	e509                	bnez	a0,80001132 <kvmmap+0x1c>
}
    8000112a:	60a2                	ld	ra,8(sp)
    8000112c:	6402                	ld	s0,0(sp)
    8000112e:	0141                	addi	sp,sp,16
    80001130:	8082                	ret
    panic("kvmmap");
    80001132:	00006517          	auipc	a0,0x6
    80001136:	fe650513          	addi	a0,a0,-26 # 80007118 <etext+0x118>
    8000113a:	eeaff0ef          	jal	80000824 <panic>

000000008000113e <kvmmake>:
{
    8000113e:	1101                	addi	sp,sp,-32
    80001140:	ec06                	sd	ra,24(sp)
    80001142:	e822                	sd	s0,16(sp)
    80001144:	e426                	sd	s1,8(sp)
    80001146:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001148:	9fdff0ef          	jal	80000b44 <kalloc>
    8000114c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000114e:	6605                	lui	a2,0x1
    80001150:	4581                	li	a1,0
    80001152:	ba7ff0ef          	jal	80000cf8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001156:	4719                	li	a4,6
    80001158:	6685                	lui	a3,0x1
    8000115a:	10000637          	lui	a2,0x10000
    8000115e:	85b2                	mv	a1,a2
    80001160:	8526                	mv	a0,s1
    80001162:	fb5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001166:	4719                	li	a4,6
    80001168:	6685                	lui	a3,0x1
    8000116a:	10001637          	lui	a2,0x10001
    8000116e:	85b2                	mv	a1,a2
    80001170:	8526                	mv	a0,s1
    80001172:	fa5ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001176:	4719                	li	a4,6
    80001178:	040006b7          	lui	a3,0x4000
    8000117c:	0c000637          	lui	a2,0xc000
    80001180:	85b2                	mv	a1,a2
    80001182:	8526                	mv	a0,s1
    80001184:	f93ff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001188:	4729                	li	a4,10
    8000118a:	80006697          	auipc	a3,0x80006
    8000118e:	e7668693          	addi	a3,a3,-394 # 7000 <_entry-0x7fff9000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00006697          	auipc	a3,0x6
    800011a4:	e6068693          	addi	a3,a3,-416 # 80007000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00006617          	auipc	a2,0x6
    800011b4:	e5060613          	addi	a2,a2,-432 # 80007000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00005617          	auipc	a2,0x5
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80006000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	62e000ef          	jal	8000180a <proc_mapstacks>
}
    800011e0:	8526                	mv	a0,s1
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <kvminit>:
{
    800011ec:	1141                	addi	sp,sp,-16
    800011ee:	e406                	sd	ra,8(sp)
    800011f0:	e022                	sd	s0,0(sp)
    800011f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011f4:	f4bff0ef          	jal	8000113e <kvmmake>
    800011f8:	00009797          	auipc	a5,0x9
    800011fc:	20a7b823          	sd	a0,528(a5) # 8000a408 <kernel_pagetable>
}
    80001200:	60a2                	ld	ra,8(sp)
    80001202:	6402                	ld	s0,0(sp)
    80001204:	0141                	addi	sp,sp,16
    80001206:	8082                	ret

0000000080001208 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001208:	1101                	addi	sp,sp,-32
    8000120a:	ec06                	sd	ra,24(sp)
    8000120c:	e822                	sd	s0,16(sp)
    8000120e:	e426                	sd	s1,8(sp)
    80001210:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001212:	933ff0ef          	jal	80000b44 <kalloc>
    80001216:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001218:	c509                	beqz	a0,80001222 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000121a:	6605                	lui	a2,0x1
    8000121c:	4581                	li	a1,0
    8000121e:	adbff0ef          	jal	80000cf8 <memset>
  return pagetable;
}
    80001222:	8526                	mv	a0,s1
    80001224:	60e2                	ld	ra,24(sp)
    80001226:	6442                	ld	s0,16(sp)
    80001228:	64a2                	ld	s1,8(sp)
    8000122a:	6105                	addi	sp,sp,32
    8000122c:	8082                	ret

000000008000122e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001236:	03459793          	slli	a5,a1,0x34
    8000123a:	e38d                	bnez	a5,8000125c <uvmunmap+0x2e>
    8000123c:	f04a                	sd	s2,32(sp)
    8000123e:	ec4e                	sd	s3,24(sp)
    80001240:	e852                	sd	s4,16(sp)
    80001242:	e456                	sd	s5,8(sp)
    80001244:	e05a                	sd	s6,0(sp)
    80001246:	8a2a                	mv	s4,a0
    80001248:	892e                	mv	s2,a1
    8000124a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000124c:	0632                	slli	a2,a2,0xc
    8000124e:	00b609b3          	add	s3,a2,a1
    80001252:	6b05                	lui	s6,0x1
    80001254:	0535f963          	bgeu	a1,s3,800012a6 <uvmunmap+0x78>
    80001258:	f426                	sd	s1,40(sp)
    8000125a:	a015                	j	8000127e <uvmunmap+0x50>
    8000125c:	f426                	sd	s1,40(sp)
    8000125e:	f04a                	sd	s2,32(sp)
    80001260:	ec4e                	sd	s3,24(sp)
    80001262:	e852                	sd	s4,16(sp)
    80001264:	e456                	sd	s5,8(sp)
    80001266:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    80001268:	00006517          	auipc	a0,0x6
    8000126c:	eb850513          	addi	a0,a0,-328 # 80007120 <etext+0x120>
    80001270:	db4ff0ef          	jal	80000824 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001274:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	995a                	add	s2,s2,s6
    8000127a:	03397563          	bgeu	s2,s3,800012a4 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000127e:	4601                	li	a2,0
    80001280:	85ca                	mv	a1,s2
    80001282:	8552                	mv	a0,s4
    80001284:	d09ff0ef          	jal	80000f8c <walk>
    80001288:	84aa                	mv	s1,a0
    8000128a:	d57d                	beqz	a0,80001278 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    8000128c:	611c                	ld	a5,0(a0)
    8000128e:	0017f713          	andi	a4,a5,1
    80001292:	d37d                	beqz	a4,80001278 <uvmunmap+0x4a>
    if(do_free){
    80001294:	fe0a80e3          	beqz	s5,80001274 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001298:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000129a:	00c79513          	slli	a0,a5,0xc
    8000129e:	fbeff0ef          	jal	80000a5c <kfree>
    800012a2:	bfc9                	j	80001274 <uvmunmap+0x46>
    800012a4:	74a2                	ld	s1,40(sp)
    800012a6:	7902                	ld	s2,32(sp)
    800012a8:	69e2                	ld	s3,24(sp)
    800012aa:	6a42                	ld	s4,16(sp)
    800012ac:	6aa2                	ld	s5,8(sp)
    800012ae:	6b02                	ld	s6,0(sp)
  }
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	6121                	addi	sp,sp,64
    800012b6:	8082                	ret

00000000800012b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012c4:	00b67d63          	bgeu	a2,a1,800012de <uvmdealloc+0x26>
    800012c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012ca:	6785                	lui	a5,0x1
    800012cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012ce:	00f60733          	add	a4,a2,a5
    800012d2:	76fd                	lui	a3,0xfffff
    800012d4:	8f75                	and	a4,a4,a3
    800012d6:	97ae                	add	a5,a5,a1
    800012d8:	8ff5                	and	a5,a5,a3
    800012da:	00f76863          	bltu	a4,a5,800012ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012de:	8526                	mv	a0,s1
    800012e0:	60e2                	ld	ra,24(sp)
    800012e2:	6442                	ld	s0,16(sp)
    800012e4:	64a2                	ld	s1,8(sp)
    800012e6:	6105                	addi	sp,sp,32
    800012e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012ea:	8f99                	sub	a5,a5,a4
    800012ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012ee:	4685                	li	a3,1
    800012f0:	0007861b          	sext.w	a2,a5
    800012f4:	85ba                	mv	a1,a4
    800012f6:	f39ff0ef          	jal	8000122e <uvmunmap>
    800012fa:	b7d5                	j	800012de <uvmdealloc+0x26>

00000000800012fc <uvmalloc>:
  if(newsz < oldsz)
    800012fc:	0ab66163          	bltu	a2,a1,8000139e <uvmalloc+0xa2>
{
    80001300:	715d                	addi	sp,sp,-80
    80001302:	e486                	sd	ra,72(sp)
    80001304:	e0a2                	sd	s0,64(sp)
    80001306:	f84a                	sd	s2,48(sp)
    80001308:	f052                	sd	s4,32(sp)
    8000130a:	ec56                	sd	s5,24(sp)
    8000130c:	e45e                	sd	s7,8(sp)
    8000130e:	0880                	addi	s0,sp,80
    80001310:	8aaa                	mv	s5,a0
    80001312:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001314:	6785                	lui	a5,0x1
    80001316:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001318:	95be                	add	a1,a1,a5
    8000131a:	77fd                	lui	a5,0xfffff
    8000131c:	00f5f933          	and	s2,a1,a5
    80001320:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001322:	08c97063          	bgeu	s2,a2,800013a2 <uvmalloc+0xa6>
    80001326:	fc26                	sd	s1,56(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000132c:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000132e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001332:	813ff0ef          	jal	80000b44 <kalloc>
    80001336:	84aa                	mv	s1,a0
    if(mem == 0){
    80001338:	c50d                	beqz	a0,80001362 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000133a:	864e                	mv	a2,s3
    8000133c:	4581                	li	a1,0
    8000133e:	9bbff0ef          	jal	80000cf8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001342:	875a                	mv	a4,s6
    80001344:	86a6                	mv	a3,s1
    80001346:	864e                	mv	a2,s3
    80001348:	85ca                	mv	a1,s2
    8000134a:	8556                	mv	a0,s5
    8000134c:	d15ff0ef          	jal	80001060 <mappages>
    80001350:	e915                	bnez	a0,80001384 <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001352:	994e                	add	s2,s2,s3
    80001354:	fd496fe3          	bltu	s2,s4,80001332 <uvmalloc+0x36>
  return newsz;
    80001358:	8552                	mv	a0,s4
    8000135a:	74e2                	ld	s1,56(sp)
    8000135c:	79a2                	ld	s3,40(sp)
    8000135e:	6b42                	ld	s6,16(sp)
    80001360:	a811                	j	80001374 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001362:	865e                	mv	a2,s7
    80001364:	85ca                	mv	a1,s2
    80001366:	8556                	mv	a0,s5
    80001368:	f51ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    8000136c:	4501                	li	a0,0
    8000136e:	74e2                	ld	s1,56(sp)
    80001370:	79a2                	ld	s3,40(sp)
    80001372:	6b42                	ld	s6,16(sp)
}
    80001374:	60a6                	ld	ra,72(sp)
    80001376:	6406                	ld	s0,64(sp)
    80001378:	7942                	ld	s2,48(sp)
    8000137a:	7a02                	ld	s4,32(sp)
    8000137c:	6ae2                	ld	s5,24(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
    80001380:	6161                	addi	sp,sp,80
    80001382:	8082                	ret
      kfree(mem);
    80001384:	8526                	mv	a0,s1
    80001386:	ed6ff0ef          	jal	80000a5c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000138a:	865e                	mv	a2,s7
    8000138c:	85ca                	mv	a1,s2
    8000138e:	8556                	mv	a0,s5
    80001390:	f29ff0ef          	jal	800012b8 <uvmdealloc>
      return 0;
    80001394:	4501                	li	a0,0
    80001396:	74e2                	ld	s1,56(sp)
    80001398:	79a2                	ld	s3,40(sp)
    8000139a:	6b42                	ld	s6,16(sp)
    8000139c:	bfe1                	j	80001374 <uvmalloc+0x78>
    return oldsz;
    8000139e:	852e                	mv	a0,a1
}
    800013a0:	8082                	ret
  return newsz;
    800013a2:	8532                	mv	a0,a2
    800013a4:	bfc1                	j	80001374 <uvmalloc+0x78>

00000000800013a6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013a6:	7179                	addi	sp,sp,-48
    800013a8:	f406                	sd	ra,40(sp)
    800013aa:	f022                	sd	s0,32(sp)
    800013ac:	ec26                	sd	s1,24(sp)
    800013ae:	e84a                	sd	s2,16(sp)
    800013b0:	e44e                	sd	s3,8(sp)
    800013b2:	1800                	addi	s0,sp,48
    800013b4:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013b6:	84aa                	mv	s1,a0
    800013b8:	6905                	lui	s2,0x1
    800013ba:	992a                	add	s2,s2,a0
    800013bc:	a811                	j	800013d0 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013be:	00006517          	auipc	a0,0x6
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80007138 <etext+0x138>
    800013c6:	c5eff0ef          	jal	80000824 <panic>
  for(int i = 0; i < 512; i++){
    800013ca:	04a1                	addi	s1,s1,8
    800013cc:	03248163          	beq	s1,s2,800013ee <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013d0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d2:	0017f713          	andi	a4,a5,1
    800013d6:	db75                	beqz	a4,800013ca <freewalk+0x24>
    800013d8:	00e7f713          	andi	a4,a5,14
    800013dc:	f36d                	bnez	a4,800013be <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013e0:	00c79513          	slli	a0,a5,0xc
    800013e4:	fc3ff0ef          	jal	800013a6 <freewalk>
      pagetable[i] = 0;
    800013e8:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013ec:	bff9                	j	800013ca <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013ee:	854e                	mv	a0,s3
    800013f0:	e6cff0ef          	jal	80000a5c <kfree>
}
    800013f4:	70a2                	ld	ra,40(sp)
    800013f6:	7402                	ld	s0,32(sp)
    800013f8:	64e2                	ld	s1,24(sp)
    800013fa:	6942                	ld	s2,16(sp)
    800013fc:	69a2                	ld	s3,8(sp)
    800013fe:	6145                	addi	sp,sp,48
    80001400:	8082                	ret

0000000080001402 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001402:	1101                	addi	sp,sp,-32
    80001404:	ec06                	sd	ra,24(sp)
    80001406:	e822                	sd	s0,16(sp)
    80001408:	e426                	sd	s1,8(sp)
    8000140a:	1000                	addi	s0,sp,32
    8000140c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000140e:	e989                	bnez	a1,80001420 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001410:	8526                	mv	a0,s1
    80001412:	f95ff0ef          	jal	800013a6 <freewalk>
}
    80001416:	60e2                	ld	ra,24(sp)
    80001418:	6442                	ld	s0,16(sp)
    8000141a:	64a2                	ld	s1,8(sp)
    8000141c:	6105                	addi	sp,sp,32
    8000141e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	4685                	li	a3,1
    80001428:	00c5d613          	srli	a2,a1,0xc
    8000142c:	4581                	li	a1,0
    8000142e:	e01ff0ef          	jal	8000122e <uvmunmap>
    80001432:	bff9                	j	80001410 <uvmfree+0xe>

0000000080001434 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001434:	ca59                	beqz	a2,800014ca <uvmcopy+0x96>
{
    80001436:	715d                	addi	sp,sp,-80
    80001438:	e486                	sd	ra,72(sp)
    8000143a:	e0a2                	sd	s0,64(sp)
    8000143c:	fc26                	sd	s1,56(sp)
    8000143e:	f84a                	sd	s2,48(sp)
    80001440:	f44e                	sd	s3,40(sp)
    80001442:	f052                	sd	s4,32(sp)
    80001444:	ec56                	sd	s5,24(sp)
    80001446:	e85a                	sd	s6,16(sp)
    80001448:	e45e                	sd	s7,8(sp)
    8000144a:	0880                	addi	s0,sp,80
    8000144c:	8b2a                	mv	s6,a0
    8000144e:	8bae                	mv	s7,a1
    80001450:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001452:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001454:	6a05                	lui	s4,0x1
    80001456:	a021                	j	8000145e <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001458:	94d2                	add	s1,s1,s4
    8000145a:	0554fc63          	bgeu	s1,s5,800014b2 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85a6                	mv	a1,s1
    80001462:	855a                	mv	a0,s6
    80001464:	b29ff0ef          	jal	80000f8c <walk>
    80001468:	d965                	beqz	a0,80001458 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    8000146a:	00053983          	ld	s3,0(a0)
    8000146e:	0019f793          	andi	a5,s3,1
    80001472:	d3fd                	beqz	a5,80001458 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001474:	ed0ff0ef          	jal	80000b44 <kalloc>
    80001478:	892a                	mv	s2,a0
    8000147a:	c11d                	beqz	a0,800014a0 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000147c:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001480:	8652                	mv	a2,s4
    80001482:	05b2                	slli	a1,a1,0xc
    80001484:	8d5ff0ef          	jal	80000d58 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001488:	3ff9f713          	andi	a4,s3,1023
    8000148c:	86ca                	mv	a3,s2
    8000148e:	8652                	mv	a2,s4
    80001490:	85a6                	mv	a1,s1
    80001492:	855e                	mv	a0,s7
    80001494:	bcdff0ef          	jal	80001060 <mappages>
    80001498:	d161                	beqz	a0,80001458 <uvmcopy+0x24>
      kfree(mem);
    8000149a:	854a                	mv	a0,s2
    8000149c:	dc0ff0ef          	jal	80000a5c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a0:	4685                	li	a3,1
    800014a2:	00c4d613          	srli	a2,s1,0xc
    800014a6:	4581                	li	a1,0
    800014a8:	855e                	mv	a0,s7
    800014aa:	d85ff0ef          	jal	8000122e <uvmunmap>
  return -1;
    800014ae:	557d                	li	a0,-1
    800014b0:	a011                	j	800014b4 <uvmcopy+0x80>
  return 0;
    800014b2:	4501                	li	a0,0
}
    800014b4:	60a6                	ld	ra,72(sp)
    800014b6:	6406                	ld	s0,64(sp)
    800014b8:	74e2                	ld	s1,56(sp)
    800014ba:	7942                	ld	s2,48(sp)
    800014bc:	79a2                	ld	s3,40(sp)
    800014be:	7a02                	ld	s4,32(sp)
    800014c0:	6ae2                	ld	s5,24(sp)
    800014c2:	6b42                	ld	s6,16(sp)
    800014c4:	6ba2                	ld	s7,8(sp)
    800014c6:	6161                	addi	sp,sp,80
    800014c8:	8082                	ret
  return 0;
    800014ca:	4501                	li	a0,0
}
    800014cc:	8082                	ret

00000000800014ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ce:	1141                	addi	sp,sp,-16
    800014d0:	e406                	sd	ra,8(sp)
    800014d2:	e022                	sd	s0,0(sp)
    800014d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d6:	4601                	li	a2,0
    800014d8:	ab5ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014dc:	c901                	beqz	a0,800014ec <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014de:	611c                	ld	a5,0(a0)
    800014e0:	9bbd                	andi	a5,a5,-17
    800014e2:	e11c                	sd	a5,0(a0)
}
    800014e4:	60a2                	ld	ra,8(sp)
    800014e6:	6402                	ld	s0,0(sp)
    800014e8:	0141                	addi	sp,sp,16
    800014ea:	8082                	ret
    panic("uvmclear");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80007148 <etext+0x148>
    800014f4:	b30ff0ef          	jal	80000824 <panic>

00000000800014f8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014f8:	cac5                	beqz	a3,800015a8 <copyinstr+0xb0>
{
    800014fa:	715d                	addi	sp,sp,-80
    800014fc:	e486                	sd	ra,72(sp)
    800014fe:	e0a2                	sd	s0,64(sp)
    80001500:	fc26                	sd	s1,56(sp)
    80001502:	f84a                	sd	s2,48(sp)
    80001504:	f44e                	sd	s3,40(sp)
    80001506:	f052                	sd	s4,32(sp)
    80001508:	ec56                	sd	s5,24(sp)
    8000150a:	e85a                	sd	s6,16(sp)
    8000150c:	e45e                	sd	s7,8(sp)
    8000150e:	0880                	addi	s0,sp,80
    80001510:	8aaa                	mv	s5,a0
    80001512:	84ae                	mv	s1,a1
    80001514:	8bb2                	mv	s7,a2
    80001516:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001518:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000151a:	6a05                	lui	s4,0x1
    8000151c:	a82d                	j	80001556 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000151e:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001522:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001524:	0017c793          	xori	a5,a5,1
    80001528:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000152c:	60a6                	ld	ra,72(sp)
    8000152e:	6406                	ld	s0,64(sp)
    80001530:	74e2                	ld	s1,56(sp)
    80001532:	7942                	ld	s2,48(sp)
    80001534:	79a2                	ld	s3,40(sp)
    80001536:	7a02                	ld	s4,32(sp)
    80001538:	6ae2                	ld	s5,24(sp)
    8000153a:	6b42                	ld	s6,16(sp)
    8000153c:	6ba2                	ld	s7,8(sp)
    8000153e:	6161                	addi	sp,sp,80
    80001540:	8082                	ret
    80001542:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001546:	9726                	add	a4,a4,s1
      --max;
    80001548:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    8000154c:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001550:	04e58463          	beq	a1,a4,80001598 <copyinstr+0xa0>
{
    80001554:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001556:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8556                	mv	a0,s5
    8000155e:	ac9ff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0)
    80001562:	cd0d                	beqz	a0,8000159c <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001564:	417906b3          	sub	a3,s2,s7
    80001568:	96d2                	add	a3,a3,s4
    if(n > max)
    8000156a:	00d9f363          	bgeu	s3,a3,80001570 <copyinstr+0x78>
    8000156e:	86ce                	mv	a3,s3
    while(n > 0){
    80001570:	ca85                	beqz	a3,800015a0 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001572:	01750633          	add	a2,a0,s7
    80001576:	41260633          	sub	a2,a2,s2
    8000157a:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000157c:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000157e:	96a6                	add	a3,a3,s1
    80001580:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001582:	00f60733          	add	a4,a2,a5
    80001586:	00074703          	lbu	a4,0(a4)
    8000158a:	db51                	beqz	a4,8000151e <copyinstr+0x26>
        *dst = *p;
    8000158c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001590:	0785                	addi	a5,a5,1
    while(n > 0){
    80001592:	fed797e3          	bne	a5,a3,80001580 <copyinstr+0x88>
    80001596:	b775                	j	80001542 <copyinstr+0x4a>
    80001598:	4781                	li	a5,0
    8000159a:	b769                	j	80001524 <copyinstr+0x2c>
      return -1;
    8000159c:	557d                	li	a0,-1
    8000159e:	b779                	j	8000152c <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015a0:	6b85                	lui	s7,0x1
    800015a2:	9bca                	add	s7,s7,s2
    800015a4:	87a6                	mv	a5,s1
    800015a6:	b77d                	j	80001554 <copyinstr+0x5c>
  int got_null = 0;
    800015a8:	4781                	li	a5,0
  if(got_null){
    800015aa:	0017c793          	xori	a5,a5,1
    800015ae:	40f0053b          	negw	a0,a5
}
    800015b2:	8082                	ret

00000000800015b4 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015b4:	1141                	addi	sp,sp,-16
    800015b6:	e406                	sd	ra,8(sp)
    800015b8:	e022                	sd	s0,0(sp)
    800015ba:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015bc:	4601                	li	a2,0
    800015be:	9cfff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015c2:	c119                	beqz	a0,800015c8 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015c4:	6108                	ld	a0,0(a0)
    800015c6:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015c8:	60a2                	ld	ra,8(sp)
    800015ca:	6402                	ld	s0,0(sp)
    800015cc:	0141                	addi	sp,sp,16
    800015ce:	8082                	ret

00000000800015d0 <vmfault>:
{
    800015d0:	7179                	addi	sp,sp,-48
    800015d2:	f406                	sd	ra,40(sp)
    800015d4:	f022                	sd	s0,32(sp)
    800015d6:	e84a                	sd	s2,16(sp)
    800015d8:	e44e                	sd	s3,8(sp)
    800015da:	1800                	addi	s0,sp,48
    800015dc:	89aa                	mv	s3,a0
    800015de:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015e0:	3b8000ef          	jal	80001998 <myproc>
  if (va >= p->sz)
    800015e4:	653c                	ld	a5,72(a0)
    800015e6:	00f96a63          	bltu	s2,a5,800015fa <vmfault+0x2a>
    return 0;
    800015ea:	4981                	li	s3,0
}
    800015ec:	854e                	mv	a0,s3
    800015ee:	70a2                	ld	ra,40(sp)
    800015f0:	7402                	ld	s0,32(sp)
    800015f2:	6942                	ld	s2,16(sp)
    800015f4:	69a2                	ld	s3,8(sp)
    800015f6:	6145                	addi	sp,sp,48
    800015f8:	8082                	ret
    800015fa:	ec26                	sd	s1,24(sp)
    800015fc:	e052                	sd	s4,0(sp)
    800015fe:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001600:	77fd                	lui	a5,0xfffff
    80001602:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001606:	85d2                	mv	a1,s4
    80001608:	854e                	mv	a0,s3
    8000160a:	fabff0ef          	jal	800015b4 <ismapped>
    return 0;
    8000160e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001610:	c501                	beqz	a0,80001618 <vmfault+0x48>
    80001612:	64e2                	ld	s1,24(sp)
    80001614:	6a02                	ld	s4,0(sp)
    80001616:	bfd9                	j	800015ec <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001618:	d2cff0ef          	jal	80000b44 <kalloc>
    8000161c:	892a                	mv	s2,a0
  if(mem == 0)
    8000161e:	c905                	beqz	a0,8000164e <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001620:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001622:	6605                	lui	a2,0x1
    80001624:	4581                	li	a1,0
    80001626:	ed2ff0ef          	jal	80000cf8 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000162a:	4759                	li	a4,22
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85d2                	mv	a1,s4
    80001632:	68a8                	ld	a0,80(s1)
    80001634:	a2dff0ef          	jal	80001060 <mappages>
    80001638:	e501                	bnez	a0,80001640 <vmfault+0x70>
    8000163a:	64e2                	ld	s1,24(sp)
    8000163c:	6a02                	ld	s4,0(sp)
    8000163e:	b77d                	j	800015ec <vmfault+0x1c>
    kfree((void *)mem);
    80001640:	854a                	mv	a0,s2
    80001642:	c1aff0ef          	jal	80000a5c <kfree>
    return 0;
    80001646:	4981                	li	s3,0
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	b745                	j	800015ec <vmfault+0x1c>
    8000164e:	64e2                	ld	s1,24(sp)
    80001650:	6a02                	ld	s4,0(sp)
    80001652:	bf69                	j	800015ec <vmfault+0x1c>

0000000080001654 <copyout>:
  while(len > 0){
    80001654:	cad1                	beqz	a3,800016e8 <copyout+0x94>
{
    80001656:	711d                	addi	sp,sp,-96
    80001658:	ec86                	sd	ra,88(sp)
    8000165a:	e8a2                	sd	s0,80(sp)
    8000165c:	e4a6                	sd	s1,72(sp)
    8000165e:	e0ca                	sd	s2,64(sp)
    80001660:	fc4e                	sd	s3,56(sp)
    80001662:	f852                	sd	s4,48(sp)
    80001664:	f456                	sd	s5,40(sp)
    80001666:	f05a                	sd	s6,32(sp)
    80001668:	ec5e                	sd	s7,24(sp)
    8000166a:	e862                	sd	s8,16(sp)
    8000166c:	e466                	sd	s9,8(sp)
    8000166e:	e06a                	sd	s10,0(sp)
    80001670:	1080                	addi	s0,sp,96
    80001672:	8baa                	mv	s7,a0
    80001674:	8a2e                	mv	s4,a1
    80001676:	8b32                	mv	s6,a2
    80001678:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000167c:	5cfd                	li	s9,-1
    8000167e:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001682:	6c05                	lui	s8,0x1
    80001684:	a005                	j	800016a4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001686:	409a0533          	sub	a0,s4,s1
    8000168a:	0009061b          	sext.w	a2,s2
    8000168e:	85da                	mv	a1,s6
    80001690:	954e                	add	a0,a0,s3
    80001692:	ec6ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001696:	412a8ab3          	sub	s5,s5,s2
    src += n;
    8000169a:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000169c:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016a0:	040a8263          	beqz	s5,800016e4 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016a4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016a8:	049ce263          	bltu	s9,s1,800016ec <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016ac:	85a6                	mv	a1,s1
    800016ae:	855e                	mv	a0,s7
    800016b0:	977ff0ef          	jal	80001026 <walkaddr>
    800016b4:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016b6:	e901                	bnez	a0,800016c6 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016b8:	4601                	li	a2,0
    800016ba:	85a6                	mv	a1,s1
    800016bc:	855e                	mv	a0,s7
    800016be:	f13ff0ef          	jal	800015d0 <vmfault>
    800016c2:	89aa                	mv	s3,a0
    800016c4:	c139                	beqz	a0,8000170a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016c6:	4601                	li	a2,0
    800016c8:	85a6                	mv	a1,s1
    800016ca:	855e                	mv	a0,s7
    800016cc:	8c1ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d0:	611c                	ld	a5,0(a0)
    800016d2:	8b91                	andi	a5,a5,4
    800016d4:	cf8d                	beqz	a5,8000170e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800016d6:	41448933          	sub	s2,s1,s4
    800016da:	9962                	add	s2,s2,s8
    if(n > len)
    800016dc:	fb2af5e3          	bgeu	s5,s2,80001686 <copyout+0x32>
    800016e0:	8956                	mv	s2,s5
    800016e2:	b755                	j	80001686 <copyout+0x32>
  return 0;
    800016e4:	4501                	li	a0,0
    800016e6:	a021                	j	800016ee <copyout+0x9a>
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret
      return -1;
    800016ec:	557d                	li	a0,-1
}
    800016ee:	60e6                	ld	ra,88(sp)
    800016f0:	6446                	ld	s0,80(sp)
    800016f2:	64a6                	ld	s1,72(sp)
    800016f4:	6906                	ld	s2,64(sp)
    800016f6:	79e2                	ld	s3,56(sp)
    800016f8:	7a42                	ld	s4,48(sp)
    800016fa:	7aa2                	ld	s5,40(sp)
    800016fc:	7b02                	ld	s6,32(sp)
    800016fe:	6be2                	ld	s7,24(sp)
    80001700:	6c42                	ld	s8,16(sp)
    80001702:	6ca2                	ld	s9,8(sp)
    80001704:	6d02                	ld	s10,0(sp)
    80001706:	6125                	addi	sp,sp,96
    80001708:	8082                	ret
        return -1;
    8000170a:	557d                	li	a0,-1
    8000170c:	b7cd                	j	800016ee <copyout+0x9a>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	bff9                	j	800016ee <copyout+0x9a>

0000000080001712 <copyin>:
  while(len > 0){
    80001712:	c6c9                	beqz	a3,8000179c <copyin+0x8a>
{
    80001714:	715d                	addi	sp,sp,-80
    80001716:	e486                	sd	ra,72(sp)
    80001718:	e0a2                	sd	s0,64(sp)
    8000171a:	fc26                	sd	s1,56(sp)
    8000171c:	f84a                	sd	s2,48(sp)
    8000171e:	f44e                	sd	s3,40(sp)
    80001720:	f052                	sd	s4,32(sp)
    80001722:	ec56                	sd	s5,24(sp)
    80001724:	e85a                	sd	s6,16(sp)
    80001726:	e45e                	sd	s7,8(sp)
    80001728:	e062                	sd	s8,0(sp)
    8000172a:	0880                	addi	s0,sp,80
    8000172c:	8baa                	mv	s7,a0
    8000172e:	8aae                	mv	s5,a1
    80001730:	8932                	mv	s2,a2
    80001732:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001734:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001736:	6b05                	lui	s6,0x1
    80001738:	a035                	j	80001764 <copyin+0x52>
    8000173a:	412984b3          	sub	s1,s3,s2
    8000173e:	94da                	add	s1,s1,s6
    if(n > len)
    80001740:	009a7363          	bgeu	s4,s1,80001746 <copyin+0x34>
    80001744:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	413905b3          	sub	a1,s2,s3
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	95aa                	add	a1,a1,a0
    80001750:	8556                	mv	a0,s5
    80001752:	e06ff0ef          	jal	80000d58 <memmove>
    len -= n;
    80001756:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000175a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000175c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001760:	020a0163          	beqz	s4,80001782 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001764:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001768:	85ce                	mv	a1,s3
    8000176a:	855e                	mv	a0,s7
    8000176c:	8bbff0ef          	jal	80001026 <walkaddr>
    if(pa0 == 0) {
    80001770:	f569                	bnez	a0,8000173a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001772:	4601                	li	a2,0
    80001774:	85ce                	mv	a1,s3
    80001776:	855e                	mv	a0,s7
    80001778:	e59ff0ef          	jal	800015d0 <vmfault>
    8000177c:	fd5d                	bnez	a0,8000173a <copyin+0x28>
        return -1;
    8000177e:	557d                	li	a0,-1
    80001780:	a011                	j	80001784 <copyin+0x72>
  return 0;
    80001782:	4501                	li	a0,0
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret
  return 0;
    8000179c:	4501                	li	a0,0
}
    8000179e:	8082                	ret

00000000800017a0 <update_cpu_temp>:
extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

void update_cpu_temp(int is_running) {
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  if (is_running) {
    800017a8:	c905                	beqz	a0,800017d8 <update_cpu_temp+0x38>
    cpu_temp += (cpu_temp > 70) ? 3 : 2;
    800017aa:	00009797          	auipc	a5,0x9
    800017ae:	c1a7a783          	lw	a5,-998(a5) # 8000a3c4 <cpu_temp>
    800017b2:	04600713          	li	a4,70
    800017b6:	00f72733          	slt	a4,a4,a5
    800017ba:	0709                	addi	a4,a4,2
    800017bc:	9fb9                	addw	a5,a5,a4
  }else{
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
  }

  // max and min clamp value
  if(cpu_temp > 100) {
    800017be:	06400713          	li	a4,100
    800017c2:	02f75663          	bge	a4,a5,800017ee <update_cpu_temp+0x4e>
    cpu_temp = 100;
    800017c6:	87ba                	mv	a5,a4
    800017c8:	00009717          	auipc	a4,0x9
    800017cc:	bef72e23          	sw	a5,-1028(a4) # 8000a3c4 <cpu_temp>
    cpu_temp = 20;
  }

  //uncomment to print cpu temp every time it changes
  //printf("CPU Temp: %d\n", cpu_temp);
}
    800017d0:	60a2                	ld	ra,8(sp)
    800017d2:	6402                	ld	s0,0(sp)
    800017d4:	0141                	addi	sp,sp,16
    800017d6:	8082                	ret
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
    800017d8:	00009797          	auipc	a5,0x9
    800017dc:	bec7a783          	lw	a5,-1044(a5) # 8000a3c4 <cpu_temp>
    800017e0:	03200713          	li	a4,50
    800017e4:	00f72733          	slt	a4,a4,a5
    800017e8:	0705                	addi	a4,a4,1
    800017ea:	9f99                	subw	a5,a5,a4
    800017ec:	bfc9                	j	800017be <update_cpu_temp+0x1e>
  }else if(cpu_temp < 20) {
    800017ee:	474d                	li	a4,19
    800017f0:	00f75763          	bge	a4,a5,800017fe <update_cpu_temp+0x5e>
    cpu_temp += (cpu_temp > 70) ? 3 : 2;
    800017f4:	00009717          	auipc	a4,0x9
    800017f8:	bcf72823          	sw	a5,-1072(a4) # 8000a3c4 <cpu_temp>
    800017fc:	bfd1                	j	800017d0 <update_cpu_temp+0x30>
    cpu_temp = 20;
    800017fe:	47d1                	li	a5,20
    80001800:	00009717          	auipc	a4,0x9
    80001804:	bcf72223          	sw	a5,-1084(a4) # 8000a3c4 <cpu_temp>
}
    80001808:	b7e1                	j	800017d0 <update_cpu_temp+0x30>

000000008000180a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000180a:	715d                	addi	sp,sp,-80
    8000180c:	e486                	sd	ra,72(sp)
    8000180e:	e0a2                	sd	s0,64(sp)
    80001810:	fc26                	sd	s1,56(sp)
    80001812:	f84a                	sd	s2,48(sp)
    80001814:	f44e                	sd	s3,40(sp)
    80001816:	f052                	sd	s4,32(sp)
    80001818:	ec56                	sd	s5,24(sp)
    8000181a:	e85a                	sd	s6,16(sp)
    8000181c:	e45e                	sd	s7,8(sp)
    8000181e:	e062                	sd	s8,0(sp)
    80001820:	0880                	addi	s0,sp,80
    80001822:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001824:	00011497          	auipc	s1,0x11
    80001828:	12448493          	addi	s1,s1,292 # 80012948 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182c:	8c26                	mv	s8,s1
    8000182e:	000a57b7          	lui	a5,0xa5
    80001832:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001836:	07b2                	slli	a5,a5,0xc
    80001838:	fa578793          	addi	a5,a5,-91
    8000183c:	4fa50937          	lui	s2,0x4fa50
    80001840:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001844:	1902                	slli	s2,s2,0x20
    80001846:	993e                	add	s2,s2,a5
    80001848:	040009b7          	lui	s3,0x4000
    8000184c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000184e:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001850:	4b99                	li	s7,6
    80001852:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00017a97          	auipc	s5,0x17
    80001858:	af4a8a93          	addi	s5,s5,-1292 # 80018348 <tickslock>
    char *pa = kalloc();
    8000185c:	ae8ff0ef          	jal	80000b44 <kalloc>
    80001860:	862a                	mv	a2,a0
    if(pa == 0)
    80001862:	c121                	beqz	a0,800018a2 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    80001864:	418485b3          	sub	a1,s1,s8
    80001868:	858d                	srai	a1,a1,0x3
    8000186a:	032585b3          	mul	a1,a1,s2
    8000186e:	05b6                	slli	a1,a1,0xd
    80001870:	6789                	lui	a5,0x2
    80001872:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001874:	875e                	mv	a4,s7
    80001876:	86da                	mv	a3,s6
    80001878:	40b985b3          	sub	a1,s3,a1
    8000187c:	8552                	mv	a0,s4
    8000187e:	899ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001882:	16848493          	addi	s1,s1,360
    80001886:	fd549be3          	bne	s1,s5,8000185c <proc_mapstacks+0x52>
  }
}
    8000188a:	60a6                	ld	ra,72(sp)
    8000188c:	6406                	ld	s0,64(sp)
    8000188e:	74e2                	ld	s1,56(sp)
    80001890:	7942                	ld	s2,48(sp)
    80001892:	79a2                	ld	s3,40(sp)
    80001894:	7a02                	ld	s4,32(sp)
    80001896:	6ae2                	ld	s5,24(sp)
    80001898:	6b42                	ld	s6,16(sp)
    8000189a:	6ba2                	ld	s7,8(sp)
    8000189c:	6c02                	ld	s8,0(sp)
    8000189e:	6161                	addi	sp,sp,80
    800018a0:	8082                	ret
      panic("kalloc");
    800018a2:	00006517          	auipc	a0,0x6
    800018a6:	8b650513          	addi	a0,a0,-1866 # 80007158 <etext+0x158>
    800018aa:	f7bfe0ef          	jal	80000824 <panic>

00000000800018ae <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018ae:	7139                	addi	sp,sp,-64
    800018b0:	fc06                	sd	ra,56(sp)
    800018b2:	f822                	sd	s0,48(sp)
    800018b4:	f426                	sd	s1,40(sp)
    800018b6:	f04a                	sd	s2,32(sp)
    800018b8:	ec4e                	sd	s3,24(sp)
    800018ba:	e852                	sd	s4,16(sp)
    800018bc:	e456                	sd	s5,8(sp)
    800018be:	e05a                	sd	s6,0(sp)
    800018c0:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018c2:	00006597          	auipc	a1,0x6
    800018c6:	89e58593          	addi	a1,a1,-1890 # 80007160 <etext+0x160>
    800018ca:	00011517          	auipc	a0,0x11
    800018ce:	c4e50513          	addi	a0,a0,-946 # 80012518 <pid_lock>
    800018d2:	accff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800018d6:	00006597          	auipc	a1,0x6
    800018da:	89258593          	addi	a1,a1,-1902 # 80007168 <etext+0x168>
    800018de:	00011517          	auipc	a0,0x11
    800018e2:	c5250513          	addi	a0,a0,-942 # 80012530 <wait_lock>
    800018e6:	ab8ff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ea:	00011497          	auipc	s1,0x11
    800018ee:	05e48493          	addi	s1,s1,94 # 80012948 <proc>
      initlock(&p->lock, "proc");
    800018f2:	00006b17          	auipc	s6,0x6
    800018f6:	886b0b13          	addi	s6,s6,-1914 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800018fa:	8aa6                	mv	s5,s1
    800018fc:	000a57b7          	lui	a5,0xa5
    80001900:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001904:	07b2                	slli	a5,a5,0xc
    80001906:	fa578793          	addi	a5,a5,-91
    8000190a:	4fa50937          	lui	s2,0x4fa50
    8000190e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001912:	1902                	slli	s2,s2,0x20
    80001914:	993e                	add	s2,s2,a5
    80001916:	040009b7          	lui	s3,0x4000
    8000191a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000191c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191e:	00017a17          	auipc	s4,0x17
    80001922:	a2aa0a13          	addi	s4,s4,-1494 # 80018348 <tickslock>
      initlock(&p->lock, "proc");
    80001926:	85da                	mv	a1,s6
    80001928:	8526                	mv	a0,s1
    8000192a:	a74ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    8000192e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001932:	415487b3          	sub	a5,s1,s5
    80001936:	878d                	srai	a5,a5,0x3
    80001938:	032787b3          	mul	a5,a5,s2
    8000193c:	07b6                	slli	a5,a5,0xd
    8000193e:	6709                	lui	a4,0x2
    80001940:	9fb9                	addw	a5,a5,a4
    80001942:	40f987b3          	sub	a5,s3,a5
    80001946:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001948:	16848493          	addi	s1,s1,360
    8000194c:	fd449de3          	bne	s1,s4,80001926 <procinit+0x78>
  }
}
    80001950:	70e2                	ld	ra,56(sp)
    80001952:	7442                	ld	s0,48(sp)
    80001954:	74a2                	ld	s1,40(sp)
    80001956:	7902                	ld	s2,32(sp)
    80001958:	69e2                	ld	s3,24(sp)
    8000195a:	6a42                	ld	s4,16(sp)
    8000195c:	6aa2                	ld	s5,8(sp)
    8000195e:	6b02                	ld	s6,0(sp)
    80001960:	6121                	addi	sp,sp,64
    80001962:	8082                	ret

0000000080001964 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001964:	1141                	addi	sp,sp,-16
    80001966:	e406                	sd	ra,8(sp)
    80001968:	e022                	sd	s0,0(sp)
    8000196a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000196c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000196e:	2501                	sext.w	a0,a0
    80001970:	60a2                	ld	ra,8(sp)
    80001972:	6402                	ld	s0,0(sp)
    80001974:	0141                	addi	sp,sp,16
    80001976:	8082                	ret

0000000080001978 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001978:	1141                	addi	sp,sp,-16
    8000197a:	e406                	sd	ra,8(sp)
    8000197c:	e022                	sd	s0,0(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00011517          	auipc	a0,0x11
    8000198a:	bc250513          	addi	a0,a0,-1086 # 80012548 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	60a2                	ld	ra,8(sp)
    80001992:	6402                	ld	s0,0(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001998:	1101                	addi	sp,sp,-32
    8000199a:	ec06                	sd	ra,24(sp)
    8000199c:	e822                	sd	s0,16(sp)
    8000199e:	e426                	sd	s1,8(sp)
    800019a0:	1000                	addi	s0,sp,32
  push_off();
    800019a2:	a42ff0ef          	jal	80000be4 <push_off>
    800019a6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019a8:	2781                	sext.w	a5,a5
    800019aa:	079e                	slli	a5,a5,0x7
    800019ac:	00011717          	auipc	a4,0x11
    800019b0:	b6c70713          	addi	a4,a4,-1172 # 80012518 <pid_lock>
    800019b4:	97ba                	add	a5,a5,a4
    800019b6:	7b9c                	ld	a5,48(a5)
    800019b8:	84be                	mv	s1,a5
  pop_off();
    800019ba:	ab2ff0ef          	jal	80000c6c <pop_off>
  return p;
}
    800019be:	8526                	mv	a0,s1
    800019c0:	60e2                	ld	ra,24(sp)
    800019c2:	6442                	ld	s0,16(sp)
    800019c4:	64a2                	ld	s1,8(sp)
    800019c6:	6105                	addi	sp,sp,32
    800019c8:	8082                	ret

00000000800019ca <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ca:	7179                	addi	sp,sp,-48
    800019cc:	f406                	sd	ra,40(sp)
    800019ce:	f022                	sd	s0,32(sp)
    800019d0:	ec26                	sd	s1,24(sp)
    800019d2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019d4:	fc5ff0ef          	jal	80001998 <myproc>
    800019d8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019da:	ae2ff0ef          	jal	80000cbc <release>

  if (first) {
    800019de:	00009797          	auipc	a5,0x9
    800019e2:	9e27a783          	lw	a5,-1566(a5) # 8000a3c0 <first.2>
    800019e6:	cf95                	beqz	a5,80001a22 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019e8:	4505                	li	a0,1
    800019ea:	583010ef          	jal	8000376c <fsinit>

    first = 0;
    800019ee:	00009797          	auipc	a5,0x9
    800019f2:	9c07a923          	sw	zero,-1582(a5) # 8000a3c0 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019f6:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    800019fa:	00005797          	auipc	a5,0x5
    800019fe:	78678793          	addi	a5,a5,1926 # 80007180 <etext+0x180>
    80001a02:	fcf43823          	sd	a5,-48(s0)
    80001a06:	fc043c23          	sd	zero,-40(s0)
    80001a0a:	fd040593          	addi	a1,s0,-48
    80001a0e:	853e                	mv	a0,a5
    80001a10:	727020ef          	jal	80004936 <kexec>
    80001a14:	6cbc                	ld	a5,88(s1)
    80001a16:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001a18:	6cbc                	ld	a5,88(s1)
    80001a1a:	7bb8                	ld	a4,112(a5)
    80001a1c:	57fd                	li	a5,-1
    80001a1e:	02f70d63          	beq	a4,a5,80001a58 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a22:	471000ef          	jal	80002692 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a26:	68a8                	ld	a0,80(s1)
    80001a28:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a2a:	04000737          	lui	a4,0x4000
    80001a2e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a30:	0732                	slli	a4,a4,0xc
    80001a32:	00004797          	auipc	a5,0x4
    80001a36:	66a78793          	addi	a5,a5,1642 # 8000609c <userret>
    80001a3a:	00004697          	auipc	a3,0x4
    80001a3e:	5c668693          	addi	a3,a3,1478 # 80006000 <_trampoline>
    80001a42:	8f95                	sub	a5,a5,a3
    80001a44:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a46:	577d                	li	a4,-1
    80001a48:	177e                	slli	a4,a4,0x3f
    80001a4a:	8d59                	or	a0,a0,a4
    80001a4c:	9782                	jalr	a5
}
    80001a4e:	70a2                	ld	ra,40(sp)
    80001a50:	7402                	ld	s0,32(sp)
    80001a52:	64e2                	ld	s1,24(sp)
    80001a54:	6145                	addi	sp,sp,48
    80001a56:	8082                	ret
      panic("exec");
    80001a58:	00005517          	auipc	a0,0x5
    80001a5c:	73050513          	addi	a0,a0,1840 # 80007188 <etext+0x188>
    80001a60:	dc5fe0ef          	jal	80000824 <panic>

0000000080001a64 <allocpid>:
{
    80001a64:	1101                	addi	sp,sp,-32
    80001a66:	ec06                	sd	ra,24(sp)
    80001a68:	e822                	sd	s0,16(sp)
    80001a6a:	e426                	sd	s1,8(sp)
    80001a6c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a6e:	00011517          	auipc	a0,0x11
    80001a72:	aaa50513          	addi	a0,a0,-1366 # 80012518 <pid_lock>
    80001a76:	9b2ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a7a:	00009797          	auipc	a5,0x9
    80001a7e:	94e78793          	addi	a5,a5,-1714 # 8000a3c8 <nextpid>
    80001a82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a84:	0014871b          	addiw	a4,s1,1
    80001a88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8a:	00011517          	auipc	a0,0x11
    80001a8e:	a8e50513          	addi	a0,a0,-1394 # 80012518 <pid_lock>
    80001a92:	a2aff0ef          	jal	80000cbc <release>
}
    80001a96:	8526                	mv	a0,s1
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <proc_pagetable>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
    80001aae:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab0:	f58ff0ef          	jal	80001208 <uvmcreate>
    80001ab4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ab6:	cd05                	beqz	a0,80001aee <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ab8:	4729                	li	a4,10
    80001aba:	00004697          	auipc	a3,0x4
    80001abe:	54668693          	addi	a3,a3,1350 # 80006000 <_trampoline>
    80001ac2:	6605                	lui	a2,0x1
    80001ac4:	040005b7          	lui	a1,0x4000
    80001ac8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aca:	05b2                	slli	a1,a1,0xc
    80001acc:	d94ff0ef          	jal	80001060 <mappages>
    80001ad0:	02054663          	bltz	a0,80001afc <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ad4:	4719                	li	a4,6
    80001ad6:	05893683          	ld	a3,88(s2)
    80001ada:	6605                	lui	a2,0x1
    80001adc:	020005b7          	lui	a1,0x2000
    80001ae0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae2:	05b6                	slli	a1,a1,0xd
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	d7aff0ef          	jal	80001060 <mappages>
    80001aea:	00054f63          	bltz	a0,80001b08 <proc_pagetable+0x66>
}
    80001aee:	8526                	mv	a0,s1
    80001af0:	60e2                	ld	ra,24(sp)
    80001af2:	6442                	ld	s0,16(sp)
    80001af4:	64a2                	ld	s1,8(sp)
    80001af6:	6902                	ld	s2,0(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	903ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b04:	4481                	li	s1,0
    80001b06:	b7e5                	j	80001aee <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b08:	4681                	li	a3,0
    80001b0a:	4605                	li	a2,1
    80001b0c:	040005b7          	lui	a1,0x4000
    80001b10:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b12:	05b2                	slli	a1,a1,0xc
    80001b14:	8526                	mv	a0,s1
    80001b16:	f18ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b1a:	4581                	li	a1,0
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	8e5ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	b7e9                	j	80001aee <proc_pagetable+0x4c>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	eecff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b46:	4681                	li	a3,0
    80001b48:	4605                	li	a2,1
    80001b4a:	020005b7          	lui	a1,0x2000
    80001b4e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b50:	05b6                	slli	a1,a1,0xd
    80001b52:	8526                	mv	a0,s1
    80001b54:	edaff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b58:	85ca                	mv	a1,s2
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	8a7ff0ef          	jal	80001402 <uvmfree>
}
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	64a2                	ld	s1,8(sp)
    80001b66:	6902                	ld	s2,0(sp)
    80001b68:	6105                	addi	sp,sp,32
    80001b6a:	8082                	ret

0000000080001b6c <freeproc>:
{
    80001b6c:	1101                	addi	sp,sp,-32
    80001b6e:	ec06                	sd	ra,24(sp)
    80001b70:	e822                	sd	s0,16(sp)
    80001b72:	e426                	sd	s1,8(sp)
    80001b74:	1000                	addi	s0,sp,32
    80001b76:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b78:	6d28                	ld	a0,88(a0)
    80001b7a:	c119                	beqz	a0,80001b80 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b7c:	ee1fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b80:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b84:	68a8                	ld	a0,80(s1)
    80001b86:	c501                	beqz	a0,80001b8e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b88:	64ac                	ld	a1,72(s1)
    80001b8a:	f9dff0ef          	jal	80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001b8e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b92:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b96:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b9e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001baa:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bae:	0004ac23          	sw	zero,24(s1)
}
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6105                	addi	sp,sp,32
    80001bba:	8082                	ret

0000000080001bbc <allocproc>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	e04a                	sd	s2,0(sp)
    80001bc6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc8:	00011497          	auipc	s1,0x11
    80001bcc:	d8048493          	addi	s1,s1,-640 # 80012948 <proc>
    80001bd0:	00016917          	auipc	s2,0x16
    80001bd4:	77890913          	addi	s2,s2,1912 # 80018348 <tickslock>
    acquire(&p->lock);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	84eff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001bde:	4c9c                	lw	a5,24(s1)
    80001be0:	cb91                	beqz	a5,80001bf4 <allocproc+0x38>
      release(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	8d8ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be8:	16848493          	addi	s1,s1,360
    80001bec:	ff2496e3          	bne	s1,s2,80001bd8 <allocproc+0x1c>
  return 0;
    80001bf0:	4481                	li	s1,0
    80001bf2:	a099                	j	80001c38 <allocproc+0x7c>
  p->pid = allocpid();
    80001bf4:	e71ff0ef          	jal	80001a64 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001bfe:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c02:	f43fe0ef          	jal	80000b44 <kalloc>
    80001c06:	892a                	mv	s2,a0
    80001c08:	eca8                	sd	a0,88(s1)
    80001c0a:	cd15                	beqz	a0,80001c46 <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	e95ff0ef          	jal	80001aa2 <proc_pagetable>
    80001c12:	892a                	mv	s2,a0
    80001c14:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c16:	c121                	beqz	a0,80001c56 <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001c18:	07000613          	li	a2,112
    80001c1c:	4581                	li	a1,0
    80001c1e:	06048513          	addi	a0,s1,96
    80001c22:	8d6ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001c26:	00000797          	auipc	a5,0x0
    80001c2a:	da478793          	addi	a5,a5,-604 # 800019ca <forkret>
    80001c2e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c30:	60bc                	ld	a5,64(s1)
    80001c32:	6705                	lui	a4,0x1
    80001c34:	97ba                	add	a5,a5,a4
    80001c36:	f4bc                	sd	a5,104(s1)
}
    80001c38:	8526                	mv	a0,s1
    80001c3a:	60e2                	ld	ra,24(sp)
    80001c3c:	6442                	ld	s0,16(sp)
    80001c3e:	64a2                	ld	s1,8(sp)
    80001c40:	6902                	ld	s2,0(sp)
    80001c42:	6105                	addi	sp,sp,32
    80001c44:	8082                	ret
    freeproc(p);
    80001c46:	8526                	mv	a0,s1
    80001c48:	f25ff0ef          	jal	80001b6c <freeproc>
    release(&p->lock);
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	86eff0ef          	jal	80000cbc <release>
    return 0;
    80001c52:	84ca                	mv	s1,s2
    80001c54:	b7d5                	j	80001c38 <allocproc+0x7c>
    freeproc(p);
    80001c56:	8526                	mv	a0,s1
    80001c58:	f15ff0ef          	jal	80001b6c <freeproc>
    release(&p->lock);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	85eff0ef          	jal	80000cbc <release>
    return 0;
    80001c62:	84ca                	mv	s1,s2
    80001c64:	bfd1                	j	80001c38 <allocproc+0x7c>

0000000080001c66 <userinit>:
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c70:	f4dff0ef          	jal	80001bbc <allocproc>
    80001c74:	84aa                	mv	s1,a0
  initproc = p;
    80001c76:	00008797          	auipc	a5,0x8
    80001c7a:	78a7bd23          	sd	a0,1946(a5) # 8000a410 <initproc>
  p->cwd = namei("/");
    80001c7e:	00005517          	auipc	a0,0x5
    80001c82:	51250513          	addi	a0,a0,1298 # 80007190 <etext+0x190>
    80001c86:	020020ef          	jal	80003ca6 <namei>
    80001c8a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c8e:	478d                	li	a5,3
    80001c90:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	828ff0ef          	jal	80000cbc <release>
}
    80001c98:	60e2                	ld	ra,24(sp)
    80001c9a:	6442                	ld	s0,16(sp)
    80001c9c:	64a2                	ld	s1,8(sp)
    80001c9e:	6105                	addi	sp,sp,32
    80001ca0:	8082                	ret

0000000080001ca2 <growproc>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	e04a                	sd	s2,0(sp)
    80001cac:	1000                	addi	s0,sp,32
    80001cae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001cb0:	ce9ff0ef          	jal	80001998 <myproc>
    80001cb4:	892a                	mv	s2,a0
  sz = p->sz;
    80001cb6:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001cb8:	02905963          	blez	s1,80001cea <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001cbc:	00b48633          	add	a2,s1,a1
    80001cc0:	020007b7          	lui	a5,0x2000
    80001cc4:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001cc6:	07b6                	slli	a5,a5,0xd
    80001cc8:	02c7ea63          	bltu	a5,a2,80001cfc <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ccc:	4691                	li	a3,4
    80001cce:	6928                	ld	a0,80(a0)
    80001cd0:	e2cff0ef          	jal	800012fc <uvmalloc>
    80001cd4:	85aa                	mv	a1,a0
    80001cd6:	c50d                	beqz	a0,80001d00 <growproc+0x5e>
  p->sz = sz;
    80001cd8:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cdc:	4501                	li	a0,0
}
    80001cde:	60e2                	ld	ra,24(sp)
    80001ce0:	6442                	ld	s0,16(sp)
    80001ce2:	64a2                	ld	s1,8(sp)
    80001ce4:	6902                	ld	s2,0(sp)
    80001ce6:	6105                	addi	sp,sp,32
    80001ce8:	8082                	ret
  } else if(n < 0){
    80001cea:	fe04d7e3          	bgez	s1,80001cd8 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cee:	00b48633          	add	a2,s1,a1
    80001cf2:	6928                	ld	a0,80(a0)
    80001cf4:	dc4ff0ef          	jal	800012b8 <uvmdealloc>
    80001cf8:	85aa                	mv	a1,a0
    80001cfa:	bff9                	j	80001cd8 <growproc+0x36>
      return -1;
    80001cfc:	557d                	li	a0,-1
    80001cfe:	b7c5                	j	80001cde <growproc+0x3c>
      return -1;
    80001d00:	557d                	li	a0,-1
    80001d02:	bff1                	j	80001cde <growproc+0x3c>

0000000080001d04 <kfork>:
{
    80001d04:	7139                	addi	sp,sp,-64
    80001d06:	fc06                	sd	ra,56(sp)
    80001d08:	f822                	sd	s0,48(sp)
    80001d0a:	f426                	sd	s1,40(sp)
    80001d0c:	e456                	sd	s5,8(sp)
    80001d0e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d10:	c89ff0ef          	jal	80001998 <myproc>
    80001d14:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d16:	ea7ff0ef          	jal	80001bbc <allocproc>
    80001d1a:	0e050a63          	beqz	a0,80001e0e <kfork+0x10a>
    80001d1e:	e852                	sd	s4,16(sp)
    80001d20:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d22:	048ab603          	ld	a2,72(s5)
    80001d26:	692c                	ld	a1,80(a0)
    80001d28:	050ab503          	ld	a0,80(s5)
    80001d2c:	f08ff0ef          	jal	80001434 <uvmcopy>
    80001d30:	04054863          	bltz	a0,80001d80 <kfork+0x7c>
    80001d34:	f04a                	sd	s2,32(sp)
    80001d36:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d38:	048ab783          	ld	a5,72(s5)
    80001d3c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d40:	058ab683          	ld	a3,88(s5)
    80001d44:	87b6                	mv	a5,a3
    80001d46:	058a3703          	ld	a4,88(s4)
    80001d4a:	12068693          	addi	a3,a3,288
    80001d4e:	6388                	ld	a0,0(a5)
    80001d50:	678c                	ld	a1,8(a5)
    80001d52:	6b90                	ld	a2,16(a5)
    80001d54:	e308                	sd	a0,0(a4)
    80001d56:	e70c                	sd	a1,8(a4)
    80001d58:	eb10                	sd	a2,16(a4)
    80001d5a:	6f90                	ld	a2,24(a5)
    80001d5c:	ef10                	sd	a2,24(a4)
    80001d5e:	02078793          	addi	a5,a5,32
    80001d62:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d66:	fed794e3          	bne	a5,a3,80001d4e <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d6a:	058a3783          	ld	a5,88(s4)
    80001d6e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d72:	0d0a8493          	addi	s1,s5,208
    80001d76:	0d0a0913          	addi	s2,s4,208
    80001d7a:	150a8993          	addi	s3,s5,336
    80001d7e:	a831                	j	80001d9a <kfork+0x96>
    freeproc(np);
    80001d80:	8552                	mv	a0,s4
    80001d82:	debff0ef          	jal	80001b6c <freeproc>
    release(&np->lock);
    80001d86:	8552                	mv	a0,s4
    80001d88:	f35fe0ef          	jal	80000cbc <release>
    return -1;
    80001d8c:	54fd                	li	s1,-1
    80001d8e:	6a42                	ld	s4,16(sp)
    80001d90:	a885                	j	80001e00 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d92:	04a1                	addi	s1,s1,8
    80001d94:	0921                	addi	s2,s2,8
    80001d96:	01348963          	beq	s1,s3,80001da8 <kfork+0xa4>
    if(p->ofile[i])
    80001d9a:	6088                	ld	a0,0(s1)
    80001d9c:	d97d                	beqz	a0,80001d92 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d9e:	4c4020ef          	jal	80004262 <filedup>
    80001da2:	00a93023          	sd	a0,0(s2)
    80001da6:	b7f5                	j	80001d92 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001da8:	150ab503          	ld	a0,336(s5)
    80001dac:	696010ef          	jal	80003442 <idup>
    80001db0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001db4:	4641                	li	a2,16
    80001db6:	158a8593          	addi	a1,s5,344
    80001dba:	158a0513          	addi	a0,s4,344
    80001dbe:	88eff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001dc2:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001dc6:	8552                	mv	a0,s4
    80001dc8:	ef5fe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001dcc:	00010517          	auipc	a0,0x10
    80001dd0:	76450513          	addi	a0,a0,1892 # 80012530 <wait_lock>
    80001dd4:	e55fe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001dd8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ddc:	00010517          	auipc	a0,0x10
    80001de0:	75450513          	addi	a0,a0,1876 # 80012530 <wait_lock>
    80001de4:	ed9fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001de8:	8552                	mv	a0,s4
    80001dea:	e3ffe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001dee:	478d                	li	a5,3
    80001df0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001df4:	8552                	mv	a0,s4
    80001df6:	ec7fe0ef          	jal	80000cbc <release>
  return pid;
    80001dfa:	7902                	ld	s2,32(sp)
    80001dfc:	69e2                	ld	s3,24(sp)
    80001dfe:	6a42                	ld	s4,16(sp)
}
    80001e00:	8526                	mv	a0,s1
    80001e02:	70e2                	ld	ra,56(sp)
    80001e04:	7442                	ld	s0,48(sp)
    80001e06:	74a2                	ld	s1,40(sp)
    80001e08:	6aa2                	ld	s5,8(sp)
    80001e0a:	6121                	addi	sp,sp,64
    80001e0c:	8082                	ret
    return -1;
    80001e0e:	54fd                	li	s1,-1
    80001e10:	bfc5                	j	80001e00 <kfork+0xfc>

0000000080001e12 <scheduler>:
{
    80001e12:	715d                	addi	sp,sp,-80
    80001e14:	e486                	sd	ra,72(sp)
    80001e16:	e0a2                	sd	s0,64(sp)
    80001e18:	fc26                	sd	s1,56(sp)
    80001e1a:	f84a                	sd	s2,48(sp)
    80001e1c:	f44e                	sd	s3,40(sp)
    80001e1e:	f052                	sd	s4,32(sp)
    80001e20:	ec56                	sd	s5,24(sp)
    80001e22:	e85a                	sd	s6,16(sp)
    80001e24:	e45e                	sd	s7,8(sp)
    80001e26:	e062                	sd	s8,0(sp)
    80001e28:	0880                	addi	s0,sp,80
    80001e2a:	8792                	mv	a5,tp
  int id = r_tp();
    80001e2c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e2e:	00779693          	slli	a3,a5,0x7
    80001e32:	00010717          	auipc	a4,0x10
    80001e36:	6e670713          	addi	a4,a4,1766 # 80012518 <pid_lock>
    80001e3a:	9736                	add	a4,a4,a3
    80001e3c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &chosen->context);
    80001e40:	00010717          	auipc	a4,0x10
    80001e44:	71070713          	addi	a4,a4,1808 # 80012550 <cpus+0x8>
    80001e48:	9736                	add	a4,a4,a3
    80001e4a:	8c3a                	mv	s8,a4
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001e4c:	498d                	li	s3,3
    80001e4e:	4aa5                	li	s5,9
    for(p=proc; p<&proc[NPROC]; p++){
    80001e50:	00016917          	auipc	s2,0x16
    80001e54:	4f890913          	addi	s2,s2,1272 # 80018348 <tickslock>
        c->proc = chosen;
    80001e58:	00010b17          	auipc	s6,0x10
    80001e5c:	6c0b0b13          	addi	s6,s6,1728 # 80012518 <pid_lock>
    80001e60:	9b36                	add	s6,s6,a3
    80001e62:	a84d                	j	80001f14 <scheduler+0x102>
          chosen = p;
    80001e64:	8a26                	mv	s4,s1
      release(&p->lock);
    80001e66:	8526                	mv	a0,s1
    80001e68:	e55fe0ef          	jal	80000cbc <release>
    for(p=proc; p<&proc[NPROC]; p++){
    80001e6c:	16848493          	addi	s1,s1,360
    80001e70:	03248a63          	beq	s1,s2,80001ea4 <scheduler+0x92>
      acquire(&p->lock);
    80001e74:	8526                	mv	a0,s1
    80001e76:	db3fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001e7a:	4c9c                	lw	a5,24(s1)
    80001e7c:	ff3795e3          	bne	a5,s3,80001e66 <scheduler+0x54>
    80001e80:	7c88                	ld	a0,56(s1)
    80001e82:	d175                	beqz	a0,80001e66 <scheduler+0x54>
    80001e84:	8656                	mv	a2,s5
    80001e86:	85de                	mv	a1,s7
    80001e88:	15850513          	addi	a0,a0,344
    80001e8c:	f41fe0ef          	jal	80000dcc <strncmp>
    80001e90:	f979                	bnez	a0,80001e66 <scheduler+0x54>
        if(chosen == 0 || p->pid < chosen->pid){
    80001e92:	fc0a09e3          	beqz	s4,80001e64 <scheduler+0x52>
    80001e96:	5898                	lw	a4,48(s1)
    80001e98:	030a2783          	lw	a5,48(s4)
    80001e9c:	fcf755e3          	bge	a4,a5,80001e66 <scheduler+0x54>
          chosen = p;
    80001ea0:	8a26                	mv	s4,s1
    80001ea2:	b7d1                	j	80001e66 <scheduler+0x54>
      found = 1;
    80001ea4:	4b85                	li	s7,1
    if(chosen != 0)
    80001ea6:	000a0763          	beqz	s4,80001eb4 <scheduler+0xa2>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eaa:	00011497          	auipc	s1,0x11
    80001eae:	a9e48493          	addi	s1,s1,-1378 # 80012948 <proc>
    80001eb2:	a089                	j	80001ef4 <scheduler+0xe2>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001eb4:	00011497          	auipc	s1,0x11
    80001eb8:	a9448493          	addi	s1,s1,-1388 # 80012948 <proc>
        acquire(&p->lock);
    80001ebc:	8526                	mv	a0,s1
    80001ebe:	d6bfe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE) {
    80001ec2:	4c9c                	lw	a5,24(s1)
    80001ec4:	01378b63          	beq	a5,s3,80001eda <scheduler+0xc8>
        release(&p->lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	df3fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001ece:	16848493          	addi	s1,s1,360
    80001ed2:	ff2495e3          	bne	s1,s2,80001ebc <scheduler+0xaa>
    80001ed6:	4b81                	li	s7,0
    80001ed8:	bfc9                	j	80001eaa <scheduler+0x98>
          release(&p->lock);
    80001eda:	8526                	mv	a0,s1
    80001edc:	de1fe0ef          	jal	80000cbc <release>
          chosen = p;
    80001ee0:	8a26                	mv	s4,s1
          found = 1;
    80001ee2:	4b85                	li	s7,1
          break;
    80001ee4:	b7d9                	j	80001eaa <scheduler+0x98>
      release(&p->lock);
    80001ee6:	8526                	mv	a0,s1
    80001ee8:	dd5fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eec:	16848493          	addi	s1,s1,360
    80001ef0:	01248e63          	beq	s1,s2,80001f0c <scheduler+0xfa>
      acquire(&p->lock);
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	d33fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen) {
    80001efa:	4c9c                	lw	a5,24(s1)
    80001efc:	17f5                	addi	a5,a5,-3
    80001efe:	f7e5                	bnez	a5,80001ee6 <scheduler+0xd4>
    80001f00:	fe9a03e3          	beq	s4,s1,80001ee6 <scheduler+0xd4>
        p->waiting_tick++;
    80001f04:	58dc                	lw	a5,52(s1)
    80001f06:	2785                	addiw	a5,a5,1
    80001f08:	d8dc                	sw	a5,52(s1)
    80001f0a:	bff1                	j	80001ee6 <scheduler+0xd4>
    if(found == 0) {
    80001f0c:	020b9963          	bnez	s7,80001f3e <scheduler+0x12c>
      asm volatile("wfi");
    80001f10:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f1c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f20:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001f24:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f26:	10079073          	csrw	sstatus,a5
    chosen = 0;
    80001f2a:	4a01                	li	s4,0
    for(p=proc; p<&proc[NPROC]; p++){
    80001f2c:	00011497          	auipc	s1,0x11
    80001f30:	a1c48493          	addi	s1,s1,-1508 # 80012948 <proc>
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001f34:	00005b97          	auipc	s7,0x5
    80001f38:	264b8b93          	addi	s7,s7,612 # 80007198 <etext+0x198>
    80001f3c:	bf25                	j	80001e74 <scheduler+0x62>
      acquire(&chosen->lock);
    80001f3e:	84d2                	mv	s1,s4
    80001f40:	8552                	mv	a0,s4
    80001f42:	ce7fe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    80001f46:	018a2783          	lw	a5,24(s4)
    80001f4a:	01378663          	beq	a5,s3,80001f56 <scheduler+0x144>
      release(&chosen->lock);
    80001f4e:	8526                	mv	a0,s1
    80001f50:	d6dfe0ef          	jal	80000cbc <release>
    80001f54:	b7c1                	j	80001f14 <scheduler+0x102>
        chosen->state = RUNNING;
    80001f56:	4791                	li	a5,4
    80001f58:	00fa2c23          	sw	a5,24(s4)
        c->proc = chosen;
    80001f5c:	034b3823          	sd	s4,48(s6)
        swtch(&c->context, &chosen->context);
    80001f60:	060a0593          	addi	a1,s4,96
    80001f64:	8562                	mv	a0,s8
    80001f66:	682000ef          	jal	800025e8 <swtch>
        c->proc = 0;
    80001f6a:	020b3823          	sd	zero,48(s6)
    80001f6e:	b7c5                	j	80001f4e <scheduler+0x13c>

0000000080001f70 <sched>:
{
    80001f70:	7179                	addi	sp,sp,-48
    80001f72:	f406                	sd	ra,40(sp)
    80001f74:	f022                	sd	s0,32(sp)
    80001f76:	ec26                	sd	s1,24(sp)
    80001f78:	e84a                	sd	s2,16(sp)
    80001f7a:	e44e                	sd	s3,8(sp)
    80001f7c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f7e:	a1bff0ef          	jal	80001998 <myproc>
    80001f82:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f84:	c35fe0ef          	jal	80000bb8 <holding>
    80001f88:	c935                	beqz	a0,80001ffc <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f8c:	2781                	sext.w	a5,a5
    80001f8e:	079e                	slli	a5,a5,0x7
    80001f90:	00010717          	auipc	a4,0x10
    80001f94:	58870713          	addi	a4,a4,1416 # 80012518 <pid_lock>
    80001f98:	97ba                	add	a5,a5,a4
    80001f9a:	0a87a703          	lw	a4,168(a5)
    80001f9e:	4785                	li	a5,1
    80001fa0:	06f71463          	bne	a4,a5,80002008 <sched+0x98>
  if(p->state == RUNNING)
    80001fa4:	4c98                	lw	a4,24(s1)
    80001fa6:	4791                	li	a5,4
    80001fa8:	06f70663          	beq	a4,a5,80002014 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fac:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fb0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fb2:	e7bd                	bnez	a5,80002020 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fb4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fb6:	00010917          	auipc	s2,0x10
    80001fba:	56290913          	addi	s2,s2,1378 # 80012518 <pid_lock>
    80001fbe:	2781                	sext.w	a5,a5
    80001fc0:	079e                	slli	a5,a5,0x7
    80001fc2:	97ca                	add	a5,a5,s2
    80001fc4:	0ac7a983          	lw	s3,172(a5)
    80001fc8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	07a1                	addi	a5,a5,8
    80001fd0:	00010597          	auipc	a1,0x10
    80001fd4:	57858593          	addi	a1,a1,1400 # 80012548 <cpus>
    80001fd8:	95be                	add	a1,a1,a5
    80001fda:	06048513          	addi	a0,s1,96
    80001fde:	60a000ef          	jal	800025e8 <swtch>
    80001fe2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	993e                	add	s2,s2,a5
    80001fea:	0b392623          	sw	s3,172(s2)
}
    80001fee:	70a2                	ld	ra,40(sp)
    80001ff0:	7402                	ld	s0,32(sp)
    80001ff2:	64e2                	ld	s1,24(sp)
    80001ff4:	6942                	ld	s2,16(sp)
    80001ff6:	69a2                	ld	s3,8(sp)
    80001ff8:	6145                	addi	sp,sp,48
    80001ffa:	8082                	ret
    panic("sched p->lock");
    80001ffc:	00005517          	auipc	a0,0x5
    80002000:	1ac50513          	addi	a0,a0,428 # 800071a8 <etext+0x1a8>
    80002004:	821fe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80002008:	00005517          	auipc	a0,0x5
    8000200c:	1b050513          	addi	a0,a0,432 # 800071b8 <etext+0x1b8>
    80002010:	815fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80002014:	00005517          	auipc	a0,0x5
    80002018:	1b450513          	addi	a0,a0,436 # 800071c8 <etext+0x1c8>
    8000201c:	809fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80002020:	00005517          	auipc	a0,0x5
    80002024:	1b850513          	addi	a0,a0,440 # 800071d8 <etext+0x1d8>
    80002028:	ffcfe0ef          	jal	80000824 <panic>

000000008000202c <yield>:
{
    8000202c:	1101                	addi	sp,sp,-32
    8000202e:	ec06                	sd	ra,24(sp)
    80002030:	e822                	sd	s0,16(sp)
    80002032:	e426                	sd	s1,8(sp)
    80002034:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002036:	963ff0ef          	jal	80001998 <myproc>
    8000203a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000203c:	bedfe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002040:	478d                	li	a5,3
    80002042:	cc9c                	sw	a5,24(s1)
  sched();
    80002044:	f2dff0ef          	jal	80001f70 <sched>
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	c73fe0ef          	jal	80000cbc <release>
}
    8000204e:	60e2                	ld	ra,24(sp)
    80002050:	6442                	ld	s0,16(sp)
    80002052:	64a2                	ld	s1,8(sp)
    80002054:	6105                	addi	sp,sp,32
    80002056:	8082                	ret

0000000080002058 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002058:	7179                	addi	sp,sp,-48
    8000205a:	f406                	sd	ra,40(sp)
    8000205c:	f022                	sd	s0,32(sp)
    8000205e:	ec26                	sd	s1,24(sp)
    80002060:	e84a                	sd	s2,16(sp)
    80002062:	e44e                	sd	s3,8(sp)
    80002064:	1800                	addi	s0,sp,48
    80002066:	89aa                	mv	s3,a0
    80002068:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206a:	92fff0ef          	jal	80001998 <myproc>
    8000206e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002070:	bb9fe0ef          	jal	80000c28 <acquire>
  release(lk);
    80002074:	854a                	mv	a0,s2
    80002076:	c47fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    8000207a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000207e:	4789                	li	a5,2
    80002080:	cc9c                	sw	a5,24(s1)

  sched();
    80002082:	eefff0ef          	jal	80001f70 <sched>

  // Tidy up.
  p->chan = 0;
    80002086:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000208a:	8526                	mv	a0,s1
    8000208c:	c31fe0ef          	jal	80000cbc <release>
  acquire(lk);
    80002090:	854a                	mv	a0,s2
    80002092:	b97fe0ef          	jal	80000c28 <acquire>
}
    80002096:	70a2                	ld	ra,40(sp)
    80002098:	7402                	ld	s0,32(sp)
    8000209a:	64e2                	ld	s1,24(sp)
    8000209c:	6942                	ld	s2,16(sp)
    8000209e:	69a2                	ld	s3,8(sp)
    800020a0:	6145                	addi	sp,sp,48
    800020a2:	8082                	ret

00000000800020a4 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    800020a4:	7139                	addi	sp,sp,-64
    800020a6:	fc06                	sd	ra,56(sp)
    800020a8:	f822                	sd	s0,48(sp)
    800020aa:	f426                	sd	s1,40(sp)
    800020ac:	f04a                	sd	s2,32(sp)
    800020ae:	ec4e                	sd	s3,24(sp)
    800020b0:	e852                	sd	s4,16(sp)
    800020b2:	e456                	sd	s5,8(sp)
    800020b4:	0080                	addi	s0,sp,64
    800020b6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020b8:	00011497          	auipc	s1,0x11
    800020bc:	89048493          	addi	s1,s1,-1904 # 80012948 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020c0:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020c2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020c4:	00016917          	auipc	s2,0x16
    800020c8:	28490913          	addi	s2,s2,644 # 80018348 <tickslock>
    800020cc:	a801                	j	800020dc <wakeup+0x38>
      }
      release(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	bedfe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d4:	16848493          	addi	s1,s1,360
    800020d8:	03248263          	beq	s1,s2,800020fc <wakeup+0x58>
    if(p != myproc()){
    800020dc:	8bdff0ef          	jal	80001998 <myproc>
    800020e0:	fe950ae3          	beq	a0,s1,800020d4 <wakeup+0x30>
      acquire(&p->lock);
    800020e4:	8526                	mv	a0,s1
    800020e6:	b43fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800020ea:	4c9c                	lw	a5,24(s1)
    800020ec:	ff3791e3          	bne	a5,s3,800020ce <wakeup+0x2a>
    800020f0:	709c                	ld	a5,32(s1)
    800020f2:	fd479ee3          	bne	a5,s4,800020ce <wakeup+0x2a>
        p->state = RUNNABLE;
    800020f6:	0154ac23          	sw	s5,24(s1)
    800020fa:	bfd1                	j	800020ce <wakeup+0x2a>
    }
  }
}
    800020fc:	70e2                	ld	ra,56(sp)
    800020fe:	7442                	ld	s0,48(sp)
    80002100:	74a2                	ld	s1,40(sp)
    80002102:	7902                	ld	s2,32(sp)
    80002104:	69e2                	ld	s3,24(sp)
    80002106:	6a42                	ld	s4,16(sp)
    80002108:	6aa2                	ld	s5,8(sp)
    8000210a:	6121                	addi	sp,sp,64
    8000210c:	8082                	ret

000000008000210e <reparent>:
{
    8000210e:	7179                	addi	sp,sp,-48
    80002110:	f406                	sd	ra,40(sp)
    80002112:	f022                	sd	s0,32(sp)
    80002114:	ec26                	sd	s1,24(sp)
    80002116:	e84a                	sd	s2,16(sp)
    80002118:	e44e                	sd	s3,8(sp)
    8000211a:	e052                	sd	s4,0(sp)
    8000211c:	1800                	addi	s0,sp,48
    8000211e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002120:	00011497          	auipc	s1,0x11
    80002124:	82848493          	addi	s1,s1,-2008 # 80012948 <proc>
      pp->parent = initproc;
    80002128:	00008a17          	auipc	s4,0x8
    8000212c:	2e8a0a13          	addi	s4,s4,744 # 8000a410 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002130:	00016997          	auipc	s3,0x16
    80002134:	21898993          	addi	s3,s3,536 # 80018348 <tickslock>
    80002138:	a029                	j	80002142 <reparent+0x34>
    8000213a:	16848493          	addi	s1,s1,360
    8000213e:	01348b63          	beq	s1,s3,80002154 <reparent+0x46>
    if(pp->parent == p){
    80002142:	7c9c                	ld	a5,56(s1)
    80002144:	ff279be3          	bne	a5,s2,8000213a <reparent+0x2c>
      pp->parent = initproc;
    80002148:	000a3503          	ld	a0,0(s4)
    8000214c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000214e:	f57ff0ef          	jal	800020a4 <wakeup>
    80002152:	b7e5                	j	8000213a <reparent+0x2c>
}
    80002154:	70a2                	ld	ra,40(sp)
    80002156:	7402                	ld	s0,32(sp)
    80002158:	64e2                	ld	s1,24(sp)
    8000215a:	6942                	ld	s2,16(sp)
    8000215c:	69a2                	ld	s3,8(sp)
    8000215e:	6a02                	ld	s4,0(sp)
    80002160:	6145                	addi	sp,sp,48
    80002162:	8082                	ret

0000000080002164 <kexit>:
{
    80002164:	7179                	addi	sp,sp,-48
    80002166:	f406                	sd	ra,40(sp)
    80002168:	f022                	sd	s0,32(sp)
    8000216a:	ec26                	sd	s1,24(sp)
    8000216c:	e84a                	sd	s2,16(sp)
    8000216e:	e44e                	sd	s3,8(sp)
    80002170:	e052                	sd	s4,0(sp)
    80002172:	1800                	addi	s0,sp,48
    80002174:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002176:	823ff0ef          	jal	80001998 <myproc>
    8000217a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000217c:	00008797          	auipc	a5,0x8
    80002180:	2947b783          	ld	a5,660(a5) # 8000a410 <initproc>
    80002184:	0d050493          	addi	s1,a0,208
    80002188:	15050913          	addi	s2,a0,336
    8000218c:	00a79b63          	bne	a5,a0,800021a2 <kexit+0x3e>
    panic("init exiting");
    80002190:	00005517          	auipc	a0,0x5
    80002194:	06050513          	addi	a0,a0,96 # 800071f0 <etext+0x1f0>
    80002198:	e8cfe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000219c:	04a1                	addi	s1,s1,8
    8000219e:	01248963          	beq	s1,s2,800021b0 <kexit+0x4c>
    if(p->ofile[fd]){
    800021a2:	6088                	ld	a0,0(s1)
    800021a4:	dd65                	beqz	a0,8000219c <kexit+0x38>
      fileclose(f);
    800021a6:	102020ef          	jal	800042a8 <fileclose>
      p->ofile[fd] = 0;
    800021aa:	0004b023          	sd	zero,0(s1)
    800021ae:	b7fd                	j	8000219c <kexit+0x38>
  begin_op();
    800021b0:	4d5010ef          	jal	80003e84 <begin_op>
  iput(p->cwd);
    800021b4:	1509b503          	ld	a0,336(s3)
    800021b8:	442010ef          	jal	800035fa <iput>
  end_op();
    800021bc:	539010ef          	jal	80003ef4 <end_op>
  p->cwd = 0;
    800021c0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021c4:	00010517          	auipc	a0,0x10
    800021c8:	36c50513          	addi	a0,a0,876 # 80012530 <wait_lock>
    800021cc:	a5dfe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800021d0:	854e                	mv	a0,s3
    800021d2:	f3dff0ef          	jal	8000210e <reparent>
  wakeup(p->parent);
    800021d6:	0389b503          	ld	a0,56(s3)
    800021da:	ecbff0ef          	jal	800020a4 <wakeup>
  acquire(&p->lock);
    800021de:	854e                	mv	a0,s3
    800021e0:	a49fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800021e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021e8:	4795                	li	a5,5
    800021ea:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021ee:	00010517          	auipc	a0,0x10
    800021f2:	34250513          	addi	a0,a0,834 # 80012530 <wait_lock>
    800021f6:	ac7fe0ef          	jal	80000cbc <release>
  sched();
    800021fa:	d77ff0ef          	jal	80001f70 <sched>
  panic("zombie exit");
    800021fe:	00005517          	auipc	a0,0x5
    80002202:	00250513          	addi	a0,a0,2 # 80007200 <etext+0x200>
    80002206:	e1efe0ef          	jal	80000824 <panic>

000000008000220a <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	1800                	addi	s0,sp,48
    80002218:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000221a:	00010497          	auipc	s1,0x10
    8000221e:	72e48493          	addi	s1,s1,1838 # 80012948 <proc>
    80002222:	00016997          	auipc	s3,0x16
    80002226:	12698993          	addi	s3,s3,294 # 80018348 <tickslock>
    acquire(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	9fdfe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002230:	589c                	lw	a5,48(s1)
    80002232:	01278b63          	beq	a5,s2,80002248 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002236:	8526                	mv	a0,s1
    80002238:	a85fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000223c:	16848493          	addi	s1,s1,360
    80002240:	ff3495e3          	bne	s1,s3,8000222a <kkill+0x20>
  }
  return -1;
    80002244:	557d                	li	a0,-1
    80002246:	a819                	j	8000225c <kkill+0x52>
      p->killed = 1;
    80002248:	4785                	li	a5,1
    8000224a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000224c:	4c98                	lw	a4,24(s1)
    8000224e:	4789                	li	a5,2
    80002250:	00f70d63          	beq	a4,a5,8000226a <kkill+0x60>
      release(&p->lock);
    80002254:	8526                	mv	a0,s1
    80002256:	a67fe0ef          	jal	80000cbc <release>
      return 0;
    8000225a:	4501                	li	a0,0
}
    8000225c:	70a2                	ld	ra,40(sp)
    8000225e:	7402                	ld	s0,32(sp)
    80002260:	64e2                	ld	s1,24(sp)
    80002262:	6942                	ld	s2,16(sp)
    80002264:	69a2                	ld	s3,8(sp)
    80002266:	6145                	addi	sp,sp,48
    80002268:	8082                	ret
        p->state = RUNNABLE;
    8000226a:	478d                	li	a5,3
    8000226c:	cc9c                	sw	a5,24(s1)
    8000226e:	b7dd                	j	80002254 <kkill+0x4a>

0000000080002270 <setkilled>:

void
setkilled(struct proc *p)
{
    80002270:	1101                	addi	sp,sp,-32
    80002272:	ec06                	sd	ra,24(sp)
    80002274:	e822                	sd	s0,16(sp)
    80002276:	e426                	sd	s1,8(sp)
    80002278:	1000                	addi	s0,sp,32
    8000227a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000227c:	9adfe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002280:	4785                	li	a5,1
    80002282:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	a37fe0ef          	jal	80000cbc <release>
}
    8000228a:	60e2                	ld	ra,24(sp)
    8000228c:	6442                	ld	s0,16(sp)
    8000228e:	64a2                	ld	s1,8(sp)
    80002290:	6105                	addi	sp,sp,32
    80002292:	8082                	ret

0000000080002294 <killed>:

int
killed(struct proc *p)
{
    80002294:	1101                	addi	sp,sp,-32
    80002296:	ec06                	sd	ra,24(sp)
    80002298:	e822                	sd	s0,16(sp)
    8000229a:	e426                	sd	s1,8(sp)
    8000229c:	e04a                	sd	s2,0(sp)
    8000229e:	1000                	addi	s0,sp,32
    800022a0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800022a2:	987fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    800022a6:	549c                	lw	a5,40(s1)
    800022a8:	893e                	mv	s2,a5
  release(&p->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	a11fe0ef          	jal	80000cbc <release>
  return k;
}
    800022b0:	854a                	mv	a0,s2
    800022b2:	60e2                	ld	ra,24(sp)
    800022b4:	6442                	ld	s0,16(sp)
    800022b6:	64a2                	ld	s1,8(sp)
    800022b8:	6902                	ld	s2,0(sp)
    800022ba:	6105                	addi	sp,sp,32
    800022bc:	8082                	ret

00000000800022be <kwait>:
{
    800022be:	715d                	addi	sp,sp,-80
    800022c0:	e486                	sd	ra,72(sp)
    800022c2:	e0a2                	sd	s0,64(sp)
    800022c4:	fc26                	sd	s1,56(sp)
    800022c6:	f84a                	sd	s2,48(sp)
    800022c8:	f44e                	sd	s3,40(sp)
    800022ca:	f052                	sd	s4,32(sp)
    800022cc:	ec56                	sd	s5,24(sp)
    800022ce:	e85a                	sd	s6,16(sp)
    800022d0:	e45e                	sd	s7,8(sp)
    800022d2:	0880                	addi	s0,sp,80
    800022d4:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022d6:	ec2ff0ef          	jal	80001998 <myproc>
    800022da:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022dc:	00010517          	auipc	a0,0x10
    800022e0:	25450513          	addi	a0,a0,596 # 80012530 <wait_lock>
    800022e4:	945fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800022e8:	4a15                	li	s4,5
        havekids = 1;
    800022ea:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022ec:	00016997          	auipc	s3,0x16
    800022f0:	05c98993          	addi	s3,s3,92 # 80018348 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022f4:	00010b17          	auipc	s6,0x10
    800022f8:	23cb0b13          	addi	s6,s6,572 # 80012530 <wait_lock>
    800022fc:	a869                	j	80002396 <kwait+0xd8>
          pid = pp->pid;
    800022fe:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002302:	000b8c63          	beqz	s7,8000231a <kwait+0x5c>
    80002306:	4691                	li	a3,4
    80002308:	02c48613          	addi	a2,s1,44
    8000230c:	85de                	mv	a1,s7
    8000230e:	05093503          	ld	a0,80(s2)
    80002312:	b42ff0ef          	jal	80001654 <copyout>
    80002316:	02054a63          	bltz	a0,8000234a <kwait+0x8c>
          freeproc(pp);
    8000231a:	8526                	mv	a0,s1
    8000231c:	851ff0ef          	jal	80001b6c <freeproc>
          release(&pp->lock);
    80002320:	8526                	mv	a0,s1
    80002322:	99bfe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    80002326:	00010517          	auipc	a0,0x10
    8000232a:	20a50513          	addi	a0,a0,522 # 80012530 <wait_lock>
    8000232e:	98ffe0ef          	jal	80000cbc <release>
}
    80002332:	854e                	mv	a0,s3
    80002334:	60a6                	ld	ra,72(sp)
    80002336:	6406                	ld	s0,64(sp)
    80002338:	74e2                	ld	s1,56(sp)
    8000233a:	7942                	ld	s2,48(sp)
    8000233c:	79a2                	ld	s3,40(sp)
    8000233e:	7a02                	ld	s4,32(sp)
    80002340:	6ae2                	ld	s5,24(sp)
    80002342:	6b42                	ld	s6,16(sp)
    80002344:	6ba2                	ld	s7,8(sp)
    80002346:	6161                	addi	sp,sp,80
    80002348:	8082                	ret
            release(&pp->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	971fe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002350:	00010517          	auipc	a0,0x10
    80002354:	1e050513          	addi	a0,a0,480 # 80012530 <wait_lock>
    80002358:	965fe0ef          	jal	80000cbc <release>
            return -1;
    8000235c:	59fd                	li	s3,-1
    8000235e:	bfd1                	j	80002332 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002360:	16848493          	addi	s1,s1,360
    80002364:	03348063          	beq	s1,s3,80002384 <kwait+0xc6>
      if(pp->parent == p){
    80002368:	7c9c                	ld	a5,56(s1)
    8000236a:	ff279be3          	bne	a5,s2,80002360 <kwait+0xa2>
        acquire(&pp->lock);
    8000236e:	8526                	mv	a0,s1
    80002370:	8b9fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002374:	4c9c                	lw	a5,24(s1)
    80002376:	f94784e3          	beq	a5,s4,800022fe <kwait+0x40>
        release(&pp->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	941fe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002380:	8756                	mv	a4,s5
    80002382:	bff9                	j	80002360 <kwait+0xa2>
    if(!havekids || killed(p)){
    80002384:	cf19                	beqz	a4,800023a2 <kwait+0xe4>
    80002386:	854a                	mv	a0,s2
    80002388:	f0dff0ef          	jal	80002294 <killed>
    8000238c:	e919                	bnez	a0,800023a2 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000238e:	85da                	mv	a1,s6
    80002390:	854a                	mv	a0,s2
    80002392:	cc7ff0ef          	jal	80002058 <sleep>
    havekids = 0;
    80002396:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002398:	00010497          	auipc	s1,0x10
    8000239c:	5b048493          	addi	s1,s1,1456 # 80012948 <proc>
    800023a0:	b7e1                	j	80002368 <kwait+0xaa>
      release(&wait_lock);
    800023a2:	00010517          	auipc	a0,0x10
    800023a6:	18e50513          	addi	a0,a0,398 # 80012530 <wait_lock>
    800023aa:	913fe0ef          	jal	80000cbc <release>
      return -1;
    800023ae:	59fd                	li	s3,-1
    800023b0:	b749                	j	80002332 <kwait+0x74>

00000000800023b2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023b2:	7179                	addi	sp,sp,-48
    800023b4:	f406                	sd	ra,40(sp)
    800023b6:	f022                	sd	s0,32(sp)
    800023b8:	ec26                	sd	s1,24(sp)
    800023ba:	e84a                	sd	s2,16(sp)
    800023bc:	e44e                	sd	s3,8(sp)
    800023be:	e052                	sd	s4,0(sp)
    800023c0:	1800                	addi	s0,sp,48
    800023c2:	84aa                	mv	s1,a0
    800023c4:	8a2e                	mv	s4,a1
    800023c6:	89b2                	mv	s3,a2
    800023c8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023ca:	dceff0ef          	jal	80001998 <myproc>
  if(user_dst){
    800023ce:	cc99                	beqz	s1,800023ec <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800023d0:	86ca                	mv	a3,s2
    800023d2:	864e                	mv	a2,s3
    800023d4:	85d2                	mv	a1,s4
    800023d6:	6928                	ld	a0,80(a0)
    800023d8:	a7cff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023dc:	70a2                	ld	ra,40(sp)
    800023de:	7402                	ld	s0,32(sp)
    800023e0:	64e2                	ld	s1,24(sp)
    800023e2:	6942                	ld	s2,16(sp)
    800023e4:	69a2                	ld	s3,8(sp)
    800023e6:	6a02                	ld	s4,0(sp)
    800023e8:	6145                	addi	sp,sp,48
    800023ea:	8082                	ret
    memmove((char *)dst, src, len);
    800023ec:	0009061b          	sext.w	a2,s2
    800023f0:	85ce                	mv	a1,s3
    800023f2:	8552                	mv	a0,s4
    800023f4:	965fe0ef          	jal	80000d58 <memmove>
    return 0;
    800023f8:	8526                	mv	a0,s1
    800023fa:	b7cd                	j	800023dc <either_copyout+0x2a>

00000000800023fc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023fc:	7179                	addi	sp,sp,-48
    800023fe:	f406                	sd	ra,40(sp)
    80002400:	f022                	sd	s0,32(sp)
    80002402:	ec26                	sd	s1,24(sp)
    80002404:	e84a                	sd	s2,16(sp)
    80002406:	e44e                	sd	s3,8(sp)
    80002408:	e052                	sd	s4,0(sp)
    8000240a:	1800                	addi	s0,sp,48
    8000240c:	8a2a                	mv	s4,a0
    8000240e:	84ae                	mv	s1,a1
    80002410:	89b2                	mv	s3,a2
    80002412:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002414:	d84ff0ef          	jal	80001998 <myproc>
  if(user_src){
    80002418:	cc99                	beqz	s1,80002436 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000241a:	86ca                	mv	a3,s2
    8000241c:	864e                	mv	a2,s3
    8000241e:	85d2                	mv	a1,s4
    80002420:	6928                	ld	a0,80(a0)
    80002422:	af0ff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002426:	70a2                	ld	ra,40(sp)
    80002428:	7402                	ld	s0,32(sp)
    8000242a:	64e2                	ld	s1,24(sp)
    8000242c:	6942                	ld	s2,16(sp)
    8000242e:	69a2                	ld	s3,8(sp)
    80002430:	6a02                	ld	s4,0(sp)
    80002432:	6145                	addi	sp,sp,48
    80002434:	8082                	ret
    memmove(dst, (char*)src, len);
    80002436:	0009061b          	sext.w	a2,s2
    8000243a:	85ce                	mv	a1,s3
    8000243c:	8552                	mv	a0,s4
    8000243e:	91bfe0ef          	jal	80000d58 <memmove>
    return 0;
    80002442:	8526                	mv	a0,s1
    80002444:	b7cd                	j	80002426 <either_copyin+0x2a>

0000000080002446 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002446:	715d                	addi	sp,sp,-80
    80002448:	e486                	sd	ra,72(sp)
    8000244a:	e0a2                	sd	s0,64(sp)
    8000244c:	fc26                	sd	s1,56(sp)
    8000244e:	f84a                	sd	s2,48(sp)
    80002450:	f44e                	sd	s3,40(sp)
    80002452:	f052                	sd	s4,32(sp)
    80002454:	ec56                	sd	s5,24(sp)
    80002456:	e85a                	sd	s6,16(sp)
    80002458:	e45e                	sd	s7,8(sp)
    8000245a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000245c:	00005517          	auipc	a0,0x5
    80002460:	c1c50513          	addi	a0,a0,-996 # 80007078 <etext+0x78>
    80002464:	896fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002468:	00010497          	auipc	s1,0x10
    8000246c:	63848493          	addi	s1,s1,1592 # 80012aa0 <proc+0x158>
    80002470:	00016917          	auipc	s2,0x16
    80002474:	03090913          	addi	s2,s2,48 # 800184a0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002478:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000247a:	00005997          	auipc	s3,0x5
    8000247e:	d9698993          	addi	s3,s3,-618 # 80007210 <etext+0x210>
    printf("%d %s %s", p->pid, state, p->name);
    80002482:	00005a97          	auipc	s5,0x5
    80002486:	d96a8a93          	addi	s5,s5,-618 # 80007218 <etext+0x218>
    printf("\n");
    8000248a:	00005a17          	auipc	s4,0x5
    8000248e:	beea0a13          	addi	s4,s4,-1042 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002492:	00005b97          	auipc	s7,0x5
    80002496:	35eb8b93          	addi	s7,s7,862 # 800077f0 <states.1>
    8000249a:	a829                	j	800024b4 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000249c:	ed86a583          	lw	a1,-296(a3)
    800024a0:	8556                	mv	a0,s5
    800024a2:	858fe0ef          	jal	800004fa <printf>
    printf("\n");
    800024a6:	8552                	mv	a0,s4
    800024a8:	852fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800024ac:	16848493          	addi	s1,s1,360
    800024b0:	03248263          	beq	s1,s2,800024d4 <procdump+0x8e>
    if(p->state == UNUSED)
    800024b4:	86a6                	mv	a3,s1
    800024b6:	ec04a783          	lw	a5,-320(s1)
    800024ba:	dbed                	beqz	a5,800024ac <procdump+0x66>
      state = "???";
    800024bc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024be:	fcfb6fe3          	bltu	s6,a5,8000249c <procdump+0x56>
    800024c2:	02079713          	slli	a4,a5,0x20
    800024c6:	01d75793          	srli	a5,a4,0x1d
    800024ca:	97de                	add	a5,a5,s7
    800024cc:	6390                	ld	a2,0(a5)
    800024ce:	f679                	bnez	a2,8000249c <procdump+0x56>
      state = "???";
    800024d0:	864e                	mv	a2,s3
    800024d2:	b7e9                	j	8000249c <procdump+0x56>
  }
}
    800024d4:	60a6                	ld	ra,72(sp)
    800024d6:	6406                	ld	s0,64(sp)
    800024d8:	74e2                	ld	s1,56(sp)
    800024da:	7942                	ld	s2,48(sp)
    800024dc:	79a2                	ld	s3,40(sp)
    800024de:	7a02                	ld	s4,32(sp)
    800024e0:	6ae2                	ld	s5,24(sp)
    800024e2:	6b42                	ld	s6,16(sp)
    800024e4:	6ba2                	ld	s7,8(sp)
    800024e6:	6161                	addi	sp,sp,80
    800024e8:	8082                	ret

00000000800024ea <kps>:


int
kps(char *arguments)
{
    800024ea:	7179                	addi	sp,sp,-48
    800024ec:	f406                	sd	ra,40(sp)
    800024ee:	f022                	sd	s0,32(sp)
    800024f0:	ec26                	sd	s1,24(sp)
    800024f2:	1800                	addi	s0,sp,48
    800024f4:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    800024f6:	4609                	li	a2,2
    800024f8:	00005597          	auipc	a1,0x5
    800024fc:	d3058593          	addi	a1,a1,-720 # 80007228 <etext+0x228>
    80002500:	8cdfe0ef          	jal	80000dcc <strncmp>
    80002504:	e931                	bnez	a0,80002558 <kps+0x6e>
    80002506:	e84a                	sd	s2,16(sp)
    80002508:	e44e                	sd	s3,8(sp)
    8000250a:	00010497          	auipc	s1,0x10
    8000250e:	59648493          	addi	s1,s1,1430 # 80012aa0 <proc+0x158>
    80002512:	00016917          	auipc	s2,0x16
    80002516:	f8e90913          	addi	s2,s2,-114 # 800184a0 <bcache+0x140>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    8000251a:	00005997          	auipc	s3,0x5
    8000251e:	d1698993          	addi	s3,s3,-746 # 80007230 <etext+0x230>
    80002522:	a029                	j	8000252c <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    80002524:	16848493          	addi	s1,s1,360
    80002528:	01248a63          	beq	s1,s2,8000253c <kps+0x52>
      if (p->state != UNUSED){
    8000252c:	ec04a783          	lw	a5,-320(s1)
    80002530:	dbf5                	beqz	a5,80002524 <kps+0x3a>
        printf("%s ", p->name);
    80002532:	85a6                	mv	a1,s1
    80002534:	854e                	mv	a0,s3
    80002536:	fc5fd0ef          	jal	800004fa <printf>
    8000253a:	b7ed                	j	80002524 <kps+0x3a>
      }
    }
    printf("\n");
    8000253c:	00005517          	auipc	a0,0x5
    80002540:	b3c50513          	addi	a0,a0,-1220 # 80007078 <etext+0x78>
    80002544:	fb7fd0ef          	jal	800004fa <printf>
    80002548:	6942                	ld	s2,16(sp)
    8000254a:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l]\n");
  }

  return 0;

    8000254c:	4501                	li	a0,0
    8000254e:	70a2                	ld	ra,40(sp)
    80002550:	7402                	ld	s0,32(sp)
    80002552:	64e2                	ld	s1,24(sp)
    80002554:	6145                	addi	sp,sp,48
    80002556:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    80002558:	4609                	li	a2,2
    8000255a:	00005597          	auipc	a1,0x5
    8000255e:	cde58593          	addi	a1,a1,-802 # 80007238 <etext+0x238>
    80002562:	8526                	mv	a0,s1
    80002564:	869fe0ef          	jal	80000dcc <strncmp>
    80002568:	e92d                	bnez	a0,800025da <kps+0xf0>
    8000256a:	e84a                	sd	s2,16(sp)
    8000256c:	e44e                	sd	s3,8(sp)
    8000256e:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    80002570:	00005517          	auipc	a0,0x5
    80002574:	cd050513          	addi	a0,a0,-816 # 80007240 <etext+0x240>
    80002578:	f83fd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    8000257c:	00005517          	auipc	a0,0x5
    80002580:	cdc50513          	addi	a0,a0,-804 # 80007258 <etext+0x258>
    80002584:	f77fd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002588:	00010497          	auipc	s1,0x10
    8000258c:	51848493          	addi	s1,s1,1304 # 80012aa0 <proc+0x158>
    80002590:	00016917          	auipc	s2,0x16
    80002594:	f1090913          	addi	s2,s2,-240 # 800184a0 <bcache+0x140>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002598:	00005a17          	auipc	s4,0x5
    8000259c:	258a0a13          	addi	s4,s4,600 # 800077f0 <states.1>
    800025a0:	00005997          	auipc	s3,0x5
    800025a4:	ce098993          	addi	s3,s3,-800 # 80007280 <etext+0x280>
    800025a8:	a029                	j	800025b2 <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    800025aa:	16848493          	addi	s1,s1,360
    800025ae:	03248263          	beq	s1,s2,800025d2 <kps+0xe8>
      if (p->state != UNUSED){
    800025b2:	ec04a783          	lw	a5,-320(s1)
    800025b6:	dbf5                	beqz	a5,800025aa <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    800025b8:	02079713          	slli	a4,a5,0x20
    800025bc:	01d75793          	srli	a5,a4,0x1d
    800025c0:	97d2                	add	a5,a5,s4
    800025c2:	86a6                	mv	a3,s1
    800025c4:	7b90                	ld	a2,48(a5)
    800025c6:	ed84a583          	lw	a1,-296(s1)
    800025ca:	854e                	mv	a0,s3
    800025cc:	f2ffd0ef          	jal	800004fa <printf>
    800025d0:	bfe9                	j	800025aa <kps+0xc0>
    800025d2:	6942                	ld	s2,16(sp)
    800025d4:	69a2                	ld	s3,8(sp)
    800025d6:	6a02                	ld	s4,0(sp)
    800025d8:	bf95                	j	8000254c <kps+0x62>
    printf("Usage: ps [-o | -l]\n");
    800025da:	00005517          	auipc	a0,0x5
    800025de:	cb650513          	addi	a0,a0,-842 # 80007290 <etext+0x290>
    800025e2:	f19fd0ef          	jal	800004fa <printf>
    800025e6:	b79d                	j	8000254c <kps+0x62>

00000000800025e8 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025e8:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025ec:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025f0:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025f2:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025f4:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025f8:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025fc:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002600:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002604:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002608:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000260c:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002610:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002614:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002618:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000261c:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002620:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002624:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002626:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002628:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000262c:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002630:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002634:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002638:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000263c:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002640:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002644:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002648:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000264c:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002650:	8082                	ret

0000000080002652 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002652:	1141                	addi	sp,sp,-16
    80002654:	e406                	sd	ra,8(sp)
    80002656:	e022                	sd	s0,0(sp)
    80002658:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000265a:	00005597          	auipc	a1,0x5
    8000265e:	cbe58593          	addi	a1,a1,-834 # 80007318 <etext+0x318>
    80002662:	00016517          	auipc	a0,0x16
    80002666:	ce650513          	addi	a0,a0,-794 # 80018348 <tickslock>
    8000266a:	d34fe0ef          	jal	80000b9e <initlock>
}
    8000266e:	60a2                	ld	ra,8(sp)
    80002670:	6402                	ld	s0,0(sp)
    80002672:	0141                	addi	sp,sp,16
    80002674:	8082                	ret

0000000080002676 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002676:	1141                	addi	sp,sp,-16
    80002678:	e406                	sd	ra,8(sp)
    8000267a:	e022                	sd	s0,0(sp)
    8000267c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000267e:	00003797          	auipc	a5,0x3
    80002682:	03278793          	addi	a5,a5,50 # 800056b0 <kernelvec>
    80002686:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000268a:	60a2                	ld	ra,8(sp)
    8000268c:	6402                	ld	s0,0(sp)
    8000268e:	0141                	addi	sp,sp,16
    80002690:	8082                	ret

0000000080002692 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002692:	1141                	addi	sp,sp,-16
    80002694:	e406                	sd	ra,8(sp)
    80002696:	e022                	sd	s0,0(sp)
    80002698:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000269a:	afeff0ef          	jal	80001998 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000269e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026a8:	04000737          	lui	a4,0x4000
    800026ac:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800026ae:	0732                	slli	a4,a4,0xc
    800026b0:	00004797          	auipc	a5,0x4
    800026b4:	95078793          	addi	a5,a5,-1712 # 80006000 <_trampoline>
    800026b8:	00004697          	auipc	a3,0x4
    800026bc:	94868693          	addi	a3,a3,-1720 # 80006000 <_trampoline>
    800026c0:	8f95                	sub	a5,a5,a3
    800026c2:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026c4:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026c8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026ca:	18002773          	csrr	a4,satp
    800026ce:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026d0:	6d38                	ld	a4,88(a0)
    800026d2:	613c                	ld	a5,64(a0)
    800026d4:	6685                	lui	a3,0x1
    800026d6:	97b6                	add	a5,a5,a3
    800026d8:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026da:	6d3c                	ld	a5,88(a0)
    800026dc:	00000717          	auipc	a4,0x0
    800026e0:	11c70713          	addi	a4,a4,284 # 800027f8 <usertrap>
    800026e4:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026e6:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026e8:	8712                	mv	a4,tp
    800026ea:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ec:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026f0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026f4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026fc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026fe:	6f9c                	ld	a5,24(a5)
    80002700:	14179073          	csrw	sepc,a5
}
    80002704:	60a2                	ld	ra,8(sp)
    80002706:	6402                	ld	s0,0(sp)
    80002708:	0141                	addi	sp,sp,16
    8000270a:	8082                	ret

000000008000270c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000270c:	1141                	addi	sp,sp,-16
    8000270e:	e406                	sd	ra,8(sp)
    80002710:	e022                	sd	s0,0(sp)
    80002712:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002714:	a50ff0ef          	jal	80001964 <cpuid>
    80002718:	c915                	beqz	a0,8000274c <clockintr+0x40>
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  if (myproc() != 0 && myproc()->state == RUNNING) {
    8000271a:	a7eff0ef          	jal	80001998 <myproc>
    8000271e:	c519                	beqz	a0,8000272c <clockintr+0x20>
    80002720:	a78ff0ef          	jal	80001998 <myproc>
    80002724:	4d18                	lw	a4,24(a0)
    80002726:	4791                	li	a5,4
    80002728:	04f70963          	beq	a4,a5,8000277a <clockintr+0x6e>
    update_cpu_temp(1);   // CPU is active
  } else {
    update_cpu_temp(0);   // CPU is idle
    8000272c:	4501                	li	a0,0
    8000272e:	872ff0ef          	jal	800017a0 <update_cpu_temp>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002732:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002736:	000f4737          	lui	a4,0xf4
    8000273a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000273e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002740:	14d79073          	csrw	stimecmp,a5
}
    80002744:	60a2                	ld	ra,8(sp)
    80002746:	6402                	ld	s0,0(sp)
    80002748:	0141                	addi	sp,sp,16
    8000274a:	8082                	ret
    acquire(&tickslock);
    8000274c:	00016517          	auipc	a0,0x16
    80002750:	bfc50513          	addi	a0,a0,-1028 # 80018348 <tickslock>
    80002754:	cd4fe0ef          	jal	80000c28 <acquire>
    ticks++;
    80002758:	00008717          	auipc	a4,0x8
    8000275c:	cc070713          	addi	a4,a4,-832 # 8000a418 <ticks>
    80002760:	431c                	lw	a5,0(a4)
    80002762:	2785                	addiw	a5,a5,1
    80002764:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002766:	853a                	mv	a0,a4
    80002768:	93dff0ef          	jal	800020a4 <wakeup>
    release(&tickslock);
    8000276c:	00016517          	auipc	a0,0x16
    80002770:	bdc50513          	addi	a0,a0,-1060 # 80018348 <tickslock>
    80002774:	d48fe0ef          	jal	80000cbc <release>
    80002778:	b74d                	j	8000271a <clockintr+0xe>
    update_cpu_temp(1);   // CPU is active
    8000277a:	4505                	li	a0,1
    8000277c:	824ff0ef          	jal	800017a0 <update_cpu_temp>
    80002780:	bf4d                	j	80002732 <clockintr+0x26>

0000000080002782 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002782:	1101                	addi	sp,sp,-32
    80002784:	ec06                	sd	ra,24(sp)
    80002786:	e822                	sd	s0,16(sp)
    80002788:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000278a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000278e:	57fd                	li	a5,-1
    80002790:	17fe                	slli	a5,a5,0x3f
    80002792:	07a5                	addi	a5,a5,9
    80002794:	00f70c63          	beq	a4,a5,800027ac <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002798:	57fd                	li	a5,-1
    8000279a:	17fe                	slli	a5,a5,0x3f
    8000279c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000279e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027a0:	04f70863          	beq	a4,a5,800027f0 <devintr+0x6e>
  }
}
    800027a4:	60e2                	ld	ra,24(sp)
    800027a6:	6442                	ld	s0,16(sp)
    800027a8:	6105                	addi	sp,sp,32
    800027aa:	8082                	ret
    800027ac:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027ae:	7af020ef          	jal	8000575c <plic_claim>
    800027b2:	872a                	mv	a4,a0
    800027b4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027b6:	47a9                	li	a5,10
    800027b8:	00f50963          	beq	a0,a5,800027ca <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800027bc:	4785                	li	a5,1
    800027be:	00f50963          	beq	a0,a5,800027d0 <devintr+0x4e>
    return 1;
    800027c2:	4505                	li	a0,1
    } else if(irq){
    800027c4:	eb09                	bnez	a4,800027d6 <devintr+0x54>
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	bff1                	j	800027a4 <devintr+0x22>
      uartintr();
    800027ca:	a2afe0ef          	jal	800009f4 <uartintr>
    if(irq)
    800027ce:	a819                	j	800027e4 <devintr+0x62>
      virtio_disk_intr();
    800027d0:	422030ef          	jal	80005bf2 <virtio_disk_intr>
    if(irq)
    800027d4:	a801                	j	800027e4 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800027d6:	85ba                	mv	a1,a4
    800027d8:	00005517          	auipc	a0,0x5
    800027dc:	b4850513          	addi	a0,a0,-1208 # 80007320 <etext+0x320>
    800027e0:	d1bfd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800027e4:	8526                	mv	a0,s1
    800027e6:	797020ef          	jal	8000577c <plic_complete>
    return 1;
    800027ea:	4505                	li	a0,1
    800027ec:	64a2                	ld	s1,8(sp)
    800027ee:	bf5d                	j	800027a4 <devintr+0x22>
    clockintr();
    800027f0:	f1dff0ef          	jal	8000270c <clockintr>
    return 2;
    800027f4:	4509                	li	a0,2
    800027f6:	b77d                	j	800027a4 <devintr+0x22>

00000000800027f8 <usertrap>:
{
    800027f8:	1101                	addi	sp,sp,-32
    800027fa:	ec06                	sd	ra,24(sp)
    800027fc:	e822                	sd	s0,16(sp)
    800027fe:	e426                	sd	s1,8(sp)
    80002800:	e04a                	sd	s2,0(sp)
    80002802:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002804:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002808:	1007f793          	andi	a5,a5,256
    8000280c:	eba5                	bnez	a5,8000287c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000280e:	00003797          	auipc	a5,0x3
    80002812:	ea278793          	addi	a5,a5,-350 # 800056b0 <kernelvec>
    80002816:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000281a:	97eff0ef          	jal	80001998 <myproc>
    8000281e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002820:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002822:	14102773          	csrr	a4,sepc
    80002826:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002828:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000282c:	47a1                	li	a5,8
    8000282e:	04f70d63          	beq	a4,a5,80002888 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002832:	f51ff0ef          	jal	80002782 <devintr>
    80002836:	892a                	mv	s2,a0
    80002838:	e945                	bnez	a0,800028e8 <usertrap+0xf0>
    8000283a:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000283e:	47bd                	li	a5,15
    80002840:	08f70863          	beq	a4,a5,800028d0 <usertrap+0xd8>
    80002844:	14202773          	csrr	a4,scause
    80002848:	47b5                	li	a5,13
    8000284a:	08f70363          	beq	a4,a5,800028d0 <usertrap+0xd8>
    8000284e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002852:	5890                	lw	a2,48(s1)
    80002854:	00005517          	auipc	a0,0x5
    80002858:	b0c50513          	addi	a0,a0,-1268 # 80007360 <etext+0x360>
    8000285c:	c9ffd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002860:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002864:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002868:	00005517          	auipc	a0,0x5
    8000286c:	b2850513          	addi	a0,a0,-1240 # 80007390 <etext+0x390>
    80002870:	c8bfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002874:	8526                	mv	a0,s1
    80002876:	9fbff0ef          	jal	80002270 <setkilled>
    8000287a:	a035                	j	800028a6 <usertrap+0xae>
    panic("usertrap: not from user mode");
    8000287c:	00005517          	auipc	a0,0x5
    80002880:	ac450513          	addi	a0,a0,-1340 # 80007340 <etext+0x340>
    80002884:	fa1fd0ef          	jal	80000824 <panic>
    if(killed(p))
    80002888:	a0dff0ef          	jal	80002294 <killed>
    8000288c:	ed15                	bnez	a0,800028c8 <usertrap+0xd0>
    p->trapframe->epc += 4;
    8000288e:	6cb8                	ld	a4,88(s1)
    80002890:	6f1c                	ld	a5,24(a4)
    80002892:	0791                	addi	a5,a5,4
    80002894:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002896:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000289a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000289e:	10079073          	csrw	sstatus,a5
    syscall();
    800028a2:	240000ef          	jal	80002ae2 <syscall>
  if(killed(p))
    800028a6:	8526                	mv	a0,s1
    800028a8:	9edff0ef          	jal	80002294 <killed>
    800028ac:	e139                	bnez	a0,800028f2 <usertrap+0xfa>
  prepare_return();
    800028ae:	de5ff0ef          	jal	80002692 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800028b2:	68a8                	ld	a0,80(s1)
    800028b4:	8131                	srli	a0,a0,0xc
    800028b6:	57fd                	li	a5,-1
    800028b8:	17fe                	slli	a5,a5,0x3f
    800028ba:	8d5d                	or	a0,a0,a5
}
    800028bc:	60e2                	ld	ra,24(sp)
    800028be:	6442                	ld	s0,16(sp)
    800028c0:	64a2                	ld	s1,8(sp)
    800028c2:	6902                	ld	s2,0(sp)
    800028c4:	6105                	addi	sp,sp,32
    800028c6:	8082                	ret
      kexit(-1);
    800028c8:	557d                	li	a0,-1
    800028ca:	89bff0ef          	jal	80002164 <kexit>
    800028ce:	b7c1                	j	8000288e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028d0:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d4:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800028d8:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800028da:	00163613          	seqz	a2,a2
    800028de:	68a8                	ld	a0,80(s1)
    800028e0:	cf1fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800028e4:	f169                	bnez	a0,800028a6 <usertrap+0xae>
    800028e6:	b7a5                	j	8000284e <usertrap+0x56>
  if(killed(p))
    800028e8:	8526                	mv	a0,s1
    800028ea:	9abff0ef          	jal	80002294 <killed>
    800028ee:	c511                	beqz	a0,800028fa <usertrap+0x102>
    800028f0:	a011                	j	800028f4 <usertrap+0xfc>
    800028f2:	4901                	li	s2,0
    kexit(-1);
    800028f4:	557d                	li	a0,-1
    800028f6:	86fff0ef          	jal	80002164 <kexit>
  if(which_dev == 2)
    800028fa:	4789                	li	a5,2
    800028fc:	faf919e3          	bne	s2,a5,800028ae <usertrap+0xb6>
    yield();
    80002900:	f2cff0ef          	jal	8000202c <yield>
    80002904:	b76d                	j	800028ae <usertrap+0xb6>

0000000080002906 <kerneltrap>:
{
    80002906:	7179                	addi	sp,sp,-48
    80002908:	f406                	sd	ra,40(sp)
    8000290a:	f022                	sd	s0,32(sp)
    8000290c:	ec26                	sd	s1,24(sp)
    8000290e:	e84a                	sd	s2,16(sp)
    80002910:	e44e                	sd	s3,8(sp)
    80002912:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002914:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002918:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291c:	142027f3          	csrr	a5,scause
    80002920:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002922:	1004f793          	andi	a5,s1,256
    80002926:	c795                	beqz	a5,80002952 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002928:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000292c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000292e:	eb85                	bnez	a5,8000295e <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002930:	e53ff0ef          	jal	80002782 <devintr>
    80002934:	c91d                	beqz	a0,8000296a <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002936:	4789                	li	a5,2
    80002938:	04f50a63          	beq	a0,a5,8000298c <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000293c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002940:	10049073          	csrw	sstatus,s1
}
    80002944:	70a2                	ld	ra,40(sp)
    80002946:	7402                	ld	s0,32(sp)
    80002948:	64e2                	ld	s1,24(sp)
    8000294a:	6942                	ld	s2,16(sp)
    8000294c:	69a2                	ld	s3,8(sp)
    8000294e:	6145                	addi	sp,sp,48
    80002950:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002952:	00005517          	auipc	a0,0x5
    80002956:	a6650513          	addi	a0,a0,-1434 # 800073b8 <etext+0x3b8>
    8000295a:	ecbfd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    8000295e:	00005517          	auipc	a0,0x5
    80002962:	a8250513          	addi	a0,a0,-1406 # 800073e0 <etext+0x3e0>
    80002966:	ebffd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000296e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002972:	85ce                	mv	a1,s3
    80002974:	00005517          	auipc	a0,0x5
    80002978:	a8c50513          	addi	a0,a0,-1396 # 80007400 <etext+0x400>
    8000297c:	b7ffd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002980:	00005517          	auipc	a0,0x5
    80002984:	aa850513          	addi	a0,a0,-1368 # 80007428 <etext+0x428>
    80002988:	e9dfd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000298c:	80cff0ef          	jal	80001998 <myproc>
    80002990:	d555                	beqz	a0,8000293c <kerneltrap+0x36>
    yield();
    80002992:	e9aff0ef          	jal	8000202c <yield>
    80002996:	b75d                	j	8000293c <kerneltrap+0x36>

0000000080002998 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	e426                	sd	s1,8(sp)
    800029a0:	1000                	addi	s0,sp,32
    800029a2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029a4:	ff5fe0ef          	jal	80001998 <myproc>
  switch (n) {
    800029a8:	4795                	li	a5,5
    800029aa:	0497e163          	bltu	a5,s1,800029ec <argraw+0x54>
    800029ae:	048a                	slli	s1,s1,0x2
    800029b0:	00005717          	auipc	a4,0x5
    800029b4:	ea070713          	addi	a4,a4,-352 # 80007850 <states.0+0x30>
    800029b8:	94ba                	add	s1,s1,a4
    800029ba:	409c                	lw	a5,0(s1)
    800029bc:	97ba                	add	a5,a5,a4
    800029be:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029c0:	6d3c                	ld	a5,88(a0)
    800029c2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029c4:	60e2                	ld	ra,24(sp)
    800029c6:	6442                	ld	s0,16(sp)
    800029c8:	64a2                	ld	s1,8(sp)
    800029ca:	6105                	addi	sp,sp,32
    800029cc:	8082                	ret
    return p->trapframe->a1;
    800029ce:	6d3c                	ld	a5,88(a0)
    800029d0:	7fa8                	ld	a0,120(a5)
    800029d2:	bfcd                	j	800029c4 <argraw+0x2c>
    return p->trapframe->a2;
    800029d4:	6d3c                	ld	a5,88(a0)
    800029d6:	63c8                	ld	a0,128(a5)
    800029d8:	b7f5                	j	800029c4 <argraw+0x2c>
    return p->trapframe->a3;
    800029da:	6d3c                	ld	a5,88(a0)
    800029dc:	67c8                	ld	a0,136(a5)
    800029de:	b7dd                	j	800029c4 <argraw+0x2c>
    return p->trapframe->a4;
    800029e0:	6d3c                	ld	a5,88(a0)
    800029e2:	6bc8                	ld	a0,144(a5)
    800029e4:	b7c5                	j	800029c4 <argraw+0x2c>
    return p->trapframe->a5;
    800029e6:	6d3c                	ld	a5,88(a0)
    800029e8:	6fc8                	ld	a0,152(a5)
    800029ea:	bfe9                	j	800029c4 <argraw+0x2c>
  panic("argraw");
    800029ec:	00005517          	auipc	a0,0x5
    800029f0:	a4c50513          	addi	a0,a0,-1460 # 80007438 <etext+0x438>
    800029f4:	e31fd0ef          	jal	80000824 <panic>

00000000800029f8 <fetchaddr>:
{
    800029f8:	1101                	addi	sp,sp,-32
    800029fa:	ec06                	sd	ra,24(sp)
    800029fc:	e822                	sd	s0,16(sp)
    800029fe:	e426                	sd	s1,8(sp)
    80002a00:	e04a                	sd	s2,0(sp)
    80002a02:	1000                	addi	s0,sp,32
    80002a04:	84aa                	mv	s1,a0
    80002a06:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a08:	f91fe0ef          	jal	80001998 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a0c:	653c                	ld	a5,72(a0)
    80002a0e:	02f4f663          	bgeu	s1,a5,80002a3a <fetchaddr+0x42>
    80002a12:	00848713          	addi	a4,s1,8
    80002a16:	02e7e463          	bltu	a5,a4,80002a3e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a1a:	46a1                	li	a3,8
    80002a1c:	8626                	mv	a2,s1
    80002a1e:	85ca                	mv	a1,s2
    80002a20:	6928                	ld	a0,80(a0)
    80002a22:	cf1fe0ef          	jal	80001712 <copyin>
    80002a26:	00a03533          	snez	a0,a0
    80002a2a:	40a0053b          	negw	a0,a0
}
    80002a2e:	60e2                	ld	ra,24(sp)
    80002a30:	6442                	ld	s0,16(sp)
    80002a32:	64a2                	ld	s1,8(sp)
    80002a34:	6902                	ld	s2,0(sp)
    80002a36:	6105                	addi	sp,sp,32
    80002a38:	8082                	ret
    return -1;
    80002a3a:	557d                	li	a0,-1
    80002a3c:	bfcd                	j	80002a2e <fetchaddr+0x36>
    80002a3e:	557d                	li	a0,-1
    80002a40:	b7fd                	j	80002a2e <fetchaddr+0x36>

0000000080002a42 <fetchstr>:
{
    80002a42:	7179                	addi	sp,sp,-48
    80002a44:	f406                	sd	ra,40(sp)
    80002a46:	f022                	sd	s0,32(sp)
    80002a48:	ec26                	sd	s1,24(sp)
    80002a4a:	e84a                	sd	s2,16(sp)
    80002a4c:	e44e                	sd	s3,8(sp)
    80002a4e:	1800                	addi	s0,sp,48
    80002a50:	89aa                	mv	s3,a0
    80002a52:	84ae                	mv	s1,a1
    80002a54:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002a56:	f43fe0ef          	jal	80001998 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a5a:	86ca                	mv	a3,s2
    80002a5c:	864e                	mv	a2,s3
    80002a5e:	85a6                	mv	a1,s1
    80002a60:	6928                	ld	a0,80(a0)
    80002a62:	a97fe0ef          	jal	800014f8 <copyinstr>
    80002a66:	00054c63          	bltz	a0,80002a7e <fetchstr+0x3c>
  return strlen(buf);
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	c16fe0ef          	jal	80000e82 <strlen>
}
    80002a70:	70a2                	ld	ra,40(sp)
    80002a72:	7402                	ld	s0,32(sp)
    80002a74:	64e2                	ld	s1,24(sp)
    80002a76:	6942                	ld	s2,16(sp)
    80002a78:	69a2                	ld	s3,8(sp)
    80002a7a:	6145                	addi	sp,sp,48
    80002a7c:	8082                	ret
    return -1;
    80002a7e:	557d                	li	a0,-1
    80002a80:	bfc5                	j	80002a70 <fetchstr+0x2e>

0000000080002a82 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a82:	1101                	addi	sp,sp,-32
    80002a84:	ec06                	sd	ra,24(sp)
    80002a86:	e822                	sd	s0,16(sp)
    80002a88:	e426                	sd	s1,8(sp)
    80002a8a:	1000                	addi	s0,sp,32
    80002a8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a8e:	f0bff0ef          	jal	80002998 <argraw>
    80002a92:	c088                	sw	a0,0(s1)
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret

0000000080002a9e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a9e:	1101                	addi	sp,sp,-32
    80002aa0:	ec06                	sd	ra,24(sp)
    80002aa2:	e822                	sd	s0,16(sp)
    80002aa4:	e426                	sd	s1,8(sp)
    80002aa6:	1000                	addi	s0,sp,32
    80002aa8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aaa:	eefff0ef          	jal	80002998 <argraw>
    80002aae:	e088                	sd	a0,0(s1)
}
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6105                	addi	sp,sp,32
    80002ab8:	8082                	ret

0000000080002aba <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002aba:	1101                	addi	sp,sp,-32
    80002abc:	ec06                	sd	ra,24(sp)
    80002abe:	e822                	sd	s0,16(sp)
    80002ac0:	e426                	sd	s1,8(sp)
    80002ac2:	e04a                	sd	s2,0(sp)
    80002ac4:	1000                	addi	s0,sp,32
    80002ac6:	892e                	mv	s2,a1
    80002ac8:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002aca:	ecfff0ef          	jal	80002998 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002ace:	8626                	mv	a2,s1
    80002ad0:	85ca                	mv	a1,s2
    80002ad2:	f71ff0ef          	jal	80002a42 <fetchstr>
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6902                	ld	s2,0(sp)
    80002ade:	6105                	addi	sp,sp,32
    80002ae0:	8082                	ret

0000000080002ae2 <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	e426                	sd	s1,8(sp)
    80002aea:	e04a                	sd	s2,0(sp)
    80002aec:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002aee:	eabfe0ef          	jal	80001998 <myproc>
    80002af2:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002af4:	05853903          	ld	s2,88(a0)
    80002af8:	0a893783          	ld	a5,168(s2)
    80002afc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b00:	37fd                	addiw	a5,a5,-1
    80002b02:	4755                	li	a4,21
    80002b04:	00f76f63          	bltu	a4,a5,80002b22 <syscall+0x40>
    80002b08:	00369713          	slli	a4,a3,0x3
    80002b0c:	00005797          	auipc	a5,0x5
    80002b10:	d5c78793          	addi	a5,a5,-676 # 80007868 <syscalls>
    80002b14:	97ba                	add	a5,a5,a4
    80002b16:	639c                	ld	a5,0(a5)
    80002b18:	c789                	beqz	a5,80002b22 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b1a:	9782                	jalr	a5
    80002b1c:	06a93823          	sd	a0,112(s2)
    80002b20:	a829                	j	80002b3a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b22:	15848613          	addi	a2,s1,344
    80002b26:	588c                	lw	a1,48(s1)
    80002b28:	00005517          	auipc	a0,0x5
    80002b2c:	91850513          	addi	a0,a0,-1768 # 80007440 <etext+0x440>
    80002b30:	9cbfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b34:	6cbc                	ld	a5,88(s1)
    80002b36:	577d                	li	a4,-1
    80002b38:	fbb8                	sd	a4,112(a5)
  }
}
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6902                	ld	s2,0(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret

0000000080002b46 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002b46:	1101                	addi	sp,sp,-32
    80002b48:	ec06                	sd	ra,24(sp)
    80002b4a:	e822                	sd	s0,16(sp)
    80002b4c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b4e:	fec40593          	addi	a1,s0,-20
    80002b52:	4501                	li	a0,0
    80002b54:	f2fff0ef          	jal	80002a82 <argint>
  kexit(n);
    80002b58:	fec42503          	lw	a0,-20(s0)
    80002b5c:	e08ff0ef          	jal	80002164 <kexit>
  return 0;  // not reached
}
    80002b60:	4501                	li	a0,0
    80002b62:	60e2                	ld	ra,24(sp)
    80002b64:	6442                	ld	s0,16(sp)
    80002b66:	6105                	addi	sp,sp,32
    80002b68:	8082                	ret

0000000080002b6a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b6a:	1141                	addi	sp,sp,-16
    80002b6c:	e406                	sd	ra,8(sp)
    80002b6e:	e022                	sd	s0,0(sp)
    80002b70:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b72:	e27fe0ef          	jal	80001998 <myproc>
}
    80002b76:	5908                	lw	a0,48(a0)
    80002b78:	60a2                	ld	ra,8(sp)
    80002b7a:	6402                	ld	s0,0(sp)
    80002b7c:	0141                	addi	sp,sp,16
    80002b7e:	8082                	ret

0000000080002b80 <sys_fork>:

uint64
sys_fork(void)
{
    80002b80:	1141                	addi	sp,sp,-16
    80002b82:	e406                	sd	ra,8(sp)
    80002b84:	e022                	sd	s0,0(sp)
    80002b86:	0800                	addi	s0,sp,16
  return kfork();
    80002b88:	97cff0ef          	jal	80001d04 <kfork>
}
    80002b8c:	60a2                	ld	ra,8(sp)
    80002b8e:	6402                	ld	s0,0(sp)
    80002b90:	0141                	addi	sp,sp,16
    80002b92:	8082                	ret

0000000080002b94 <sys_wait>:

uint64
sys_wait(void)
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b9c:	fe840593          	addi	a1,s0,-24
    80002ba0:	4501                	li	a0,0
    80002ba2:	efdff0ef          	jal	80002a9e <argaddr>
  return kwait(p);
    80002ba6:	fe843503          	ld	a0,-24(s0)
    80002baa:	f14ff0ef          	jal	800022be <kwait>
}
    80002bae:	60e2                	ld	ra,24(sp)
    80002bb0:	6442                	ld	s0,16(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret

0000000080002bb6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bb6:	7179                	addi	sp,sp,-48
    80002bb8:	f406                	sd	ra,40(sp)
    80002bba:	f022                	sd	s0,32(sp)
    80002bbc:	ec26                	sd	s1,24(sp)
    80002bbe:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002bc0:	fd840593          	addi	a1,s0,-40
    80002bc4:	4501                	li	a0,0
    80002bc6:	ebdff0ef          	jal	80002a82 <argint>
  argint(1, &t);
    80002bca:	fdc40593          	addi	a1,s0,-36
    80002bce:	4505                	li	a0,1
    80002bd0:	eb3ff0ef          	jal	80002a82 <argint>
  addr = myproc()->sz;
    80002bd4:	dc5fe0ef          	jal	80001998 <myproc>
    80002bd8:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002bda:	fdc42703          	lw	a4,-36(s0)
    80002bde:	4785                	li	a5,1
    80002be0:	02f70763          	beq	a4,a5,80002c0e <sys_sbrk+0x58>
    80002be4:	fd842783          	lw	a5,-40(s0)
    80002be8:	0207c363          	bltz	a5,80002c0e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bec:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002bee:	02000737          	lui	a4,0x2000
    80002bf2:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bf4:	0736                	slli	a4,a4,0xd
    80002bf6:	02f76a63          	bltu	a4,a5,80002c2a <sys_sbrk+0x74>
    80002bfa:	0297e863          	bltu	a5,s1,80002c2a <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002bfe:	d9bfe0ef          	jal	80001998 <myproc>
    80002c02:	fd842703          	lw	a4,-40(s0)
    80002c06:	653c                	ld	a5,72(a0)
    80002c08:	97ba                	add	a5,a5,a4
    80002c0a:	e53c                	sd	a5,72(a0)
    80002c0c:	a039                	j	80002c1a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002c0e:	fd842503          	lw	a0,-40(s0)
    80002c12:	890ff0ef          	jal	80001ca2 <growproc>
    80002c16:	00054863          	bltz	a0,80002c26 <sys_sbrk+0x70>
  }
  return addr;
}
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6145                	addi	sp,sp,48
    80002c24:	8082                	ret
      return -1;
    80002c26:	54fd                	li	s1,-1
    80002c28:	bfcd                	j	80002c1a <sys_sbrk+0x64>
      return -1;
    80002c2a:	54fd                	li	s1,-1
    80002c2c:	b7fd                	j	80002c1a <sys_sbrk+0x64>

0000000080002c2e <sys_pause>:

uint64
sys_pause(void)
{
    80002c2e:	7139                	addi	sp,sp,-64
    80002c30:	fc06                	sd	ra,56(sp)
    80002c32:	f822                	sd	s0,48(sp)
    80002c34:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c36:	fcc40593          	addi	a1,s0,-52
    80002c3a:	4501                	li	a0,0
    80002c3c:	e47ff0ef          	jal	80002a82 <argint>
  if(n < 0)
    80002c40:	fcc42783          	lw	a5,-52(s0)
    80002c44:	0607c863          	bltz	a5,80002cb4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c48:	00015517          	auipc	a0,0x15
    80002c4c:	70050513          	addi	a0,a0,1792 # 80018348 <tickslock>
    80002c50:	fd9fd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002c54:	fcc42783          	lw	a5,-52(s0)
    80002c58:	c3b9                	beqz	a5,80002c9e <sys_pause+0x70>
    80002c5a:	f426                	sd	s1,40(sp)
    80002c5c:	f04a                	sd	s2,32(sp)
    80002c5e:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002c60:	00007997          	auipc	s3,0x7
    80002c64:	7b89a983          	lw	s3,1976(s3) # 8000a418 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c68:	00015917          	auipc	s2,0x15
    80002c6c:	6e090913          	addi	s2,s2,1760 # 80018348 <tickslock>
    80002c70:	00007497          	auipc	s1,0x7
    80002c74:	7a848493          	addi	s1,s1,1960 # 8000a418 <ticks>
    if(killed(myproc())){
    80002c78:	d21fe0ef          	jal	80001998 <myproc>
    80002c7c:	e18ff0ef          	jal	80002294 <killed>
    80002c80:	ed0d                	bnez	a0,80002cba <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c82:	85ca                	mv	a1,s2
    80002c84:	8526                	mv	a0,s1
    80002c86:	bd2ff0ef          	jal	80002058 <sleep>
  while(ticks - ticks0 < n){
    80002c8a:	409c                	lw	a5,0(s1)
    80002c8c:	413787bb          	subw	a5,a5,s3
    80002c90:	fcc42703          	lw	a4,-52(s0)
    80002c94:	fee7e2e3          	bltu	a5,a4,80002c78 <sys_pause+0x4a>
    80002c98:	74a2                	ld	s1,40(sp)
    80002c9a:	7902                	ld	s2,32(sp)
    80002c9c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c9e:	00015517          	auipc	a0,0x15
    80002ca2:	6aa50513          	addi	a0,a0,1706 # 80018348 <tickslock>
    80002ca6:	816fe0ef          	jal	80000cbc <release>
  return 0;
    80002caa:	4501                	li	a0,0
}
    80002cac:	70e2                	ld	ra,56(sp)
    80002cae:	7442                	ld	s0,48(sp)
    80002cb0:	6121                	addi	sp,sp,64
    80002cb2:	8082                	ret
    n = 0;
    80002cb4:	fc042623          	sw	zero,-52(s0)
    80002cb8:	bf41                	j	80002c48 <sys_pause+0x1a>
      release(&tickslock);
    80002cba:	00015517          	auipc	a0,0x15
    80002cbe:	68e50513          	addi	a0,a0,1678 # 80018348 <tickslock>
    80002cc2:	ffbfd0ef          	jal	80000cbc <release>
      return -1;
    80002cc6:	557d                	li	a0,-1
    80002cc8:	74a2                	ld	s1,40(sp)
    80002cca:	7902                	ld	s2,32(sp)
    80002ccc:	69e2                	ld	s3,24(sp)
    80002cce:	bff9                	j	80002cac <sys_pause+0x7e>

0000000080002cd0 <sys_kill>:

uint64
sys_kill(void)
{
    80002cd0:	1101                	addi	sp,sp,-32
    80002cd2:	ec06                	sd	ra,24(sp)
    80002cd4:	e822                	sd	s0,16(sp)
    80002cd6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002cd8:	fec40593          	addi	a1,s0,-20
    80002cdc:	4501                	li	a0,0
    80002cde:	da5ff0ef          	jal	80002a82 <argint>
  return kkill(pid);
    80002ce2:	fec42503          	lw	a0,-20(s0)
    80002ce6:	d24ff0ef          	jal	8000220a <kkill>
}
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	6105                	addi	sp,sp,32
    80002cf0:	8082                	ret

0000000080002cf2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cf2:	1101                	addi	sp,sp,-32
    80002cf4:	ec06                	sd	ra,24(sp)
    80002cf6:	e822                	sd	s0,16(sp)
    80002cf8:	e426                	sd	s1,8(sp)
    80002cfa:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cfc:	00015517          	auipc	a0,0x15
    80002d00:	64c50513          	addi	a0,a0,1612 # 80018348 <tickslock>
    80002d04:	f25fd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002d08:	00007797          	auipc	a5,0x7
    80002d0c:	7107a783          	lw	a5,1808(a5) # 8000a418 <ticks>
    80002d10:	84be                	mv	s1,a5
  release(&tickslock);
    80002d12:	00015517          	auipc	a0,0x15
    80002d16:	63650513          	addi	a0,a0,1590 # 80018348 <tickslock>
    80002d1a:	fa3fd0ef          	jal	80000cbc <release>
  return xticks;
}
    80002d1e:	02049513          	slli	a0,s1,0x20
    80002d22:	9101                	srli	a0,a0,0x20
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret

0000000080002d2e <sys_kps>:

uint64
sys_kps(void)
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80002d36:	4611                	li	a2,4
    80002d38:	fe840593          	addi	a1,s0,-24
    80002d3c:	4501                	li	a0,0
    80002d3e:	d7dff0ef          	jal	80002aba <argstr>
    80002d42:	87aa                	mv	a5,a0
    return -1;
    80002d44:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80002d46:	0007c663          	bltz	a5,80002d52 <sys_kps+0x24>

  return kps(buffer);
    80002d4a:	fe840513          	addi	a0,s0,-24
    80002d4e:	f9cff0ef          	jal	800024ea <kps>
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret

0000000080002d5a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d5a:	7179                	addi	sp,sp,-48
    80002d5c:	f406                	sd	ra,40(sp)
    80002d5e:	f022                	sd	s0,32(sp)
    80002d60:	ec26                	sd	s1,24(sp)
    80002d62:	e84a                	sd	s2,16(sp)
    80002d64:	e44e                	sd	s3,8(sp)
    80002d66:	e052                	sd	s4,0(sp)
    80002d68:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d6a:	00004597          	auipc	a1,0x4
    80002d6e:	6f658593          	addi	a1,a1,1782 # 80007460 <etext+0x460>
    80002d72:	00015517          	auipc	a0,0x15
    80002d76:	5ee50513          	addi	a0,a0,1518 # 80018360 <bcache>
    80002d7a:	e25fd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d7e:	0001d797          	auipc	a5,0x1d
    80002d82:	5e278793          	addi	a5,a5,1506 # 80020360 <bcache+0x8000>
    80002d86:	0001e717          	auipc	a4,0x1e
    80002d8a:	84270713          	addi	a4,a4,-1982 # 800205c8 <bcache+0x8268>
    80002d8e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d92:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d96:	00015497          	auipc	s1,0x15
    80002d9a:	5e248493          	addi	s1,s1,1506 # 80018378 <bcache+0x18>
    b->next = bcache.head.next;
    80002d9e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002da0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002da2:	00004a17          	auipc	s4,0x4
    80002da6:	6c6a0a13          	addi	s4,s4,1734 # 80007468 <etext+0x468>
    b->next = bcache.head.next;
    80002daa:	2b893783          	ld	a5,696(s2)
    80002dae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002db0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002db4:	85d2                	mv	a1,s4
    80002db6:	01048513          	addi	a0,s1,16
    80002dba:	328010ef          	jal	800040e2 <initsleeplock>
    bcache.head.next->prev = b;
    80002dbe:	2b893783          	ld	a5,696(s2)
    80002dc2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dc4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dc8:	45848493          	addi	s1,s1,1112
    80002dcc:	fd349fe3          	bne	s1,s3,80002daa <binit+0x50>
  }
}
    80002dd0:	70a2                	ld	ra,40(sp)
    80002dd2:	7402                	ld	s0,32(sp)
    80002dd4:	64e2                	ld	s1,24(sp)
    80002dd6:	6942                	ld	s2,16(sp)
    80002dd8:	69a2                	ld	s3,8(sp)
    80002dda:	6a02                	ld	s4,0(sp)
    80002ddc:	6145                	addi	sp,sp,48
    80002dde:	8082                	ret

0000000080002de0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002de0:	7179                	addi	sp,sp,-48
    80002de2:	f406                	sd	ra,40(sp)
    80002de4:	f022                	sd	s0,32(sp)
    80002de6:	ec26                	sd	s1,24(sp)
    80002de8:	e84a                	sd	s2,16(sp)
    80002dea:	e44e                	sd	s3,8(sp)
    80002dec:	1800                	addi	s0,sp,48
    80002dee:	892a                	mv	s2,a0
    80002df0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002df2:	00015517          	auipc	a0,0x15
    80002df6:	56e50513          	addi	a0,a0,1390 # 80018360 <bcache>
    80002dfa:	e2ffd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002dfe:	0001e497          	auipc	s1,0x1e
    80002e02:	81a4b483          	ld	s1,-2022(s1) # 80020618 <bcache+0x82b8>
    80002e06:	0001d797          	auipc	a5,0x1d
    80002e0a:	7c278793          	addi	a5,a5,1986 # 800205c8 <bcache+0x8268>
    80002e0e:	02f48b63          	beq	s1,a5,80002e44 <bread+0x64>
    80002e12:	873e                	mv	a4,a5
    80002e14:	a021                	j	80002e1c <bread+0x3c>
    80002e16:	68a4                	ld	s1,80(s1)
    80002e18:	02e48663          	beq	s1,a4,80002e44 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002e1c:	449c                	lw	a5,8(s1)
    80002e1e:	ff279ce3          	bne	a5,s2,80002e16 <bread+0x36>
    80002e22:	44dc                	lw	a5,12(s1)
    80002e24:	ff3799e3          	bne	a5,s3,80002e16 <bread+0x36>
      b->refcnt++;
    80002e28:	40bc                	lw	a5,64(s1)
    80002e2a:	2785                	addiw	a5,a5,1
    80002e2c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e2e:	00015517          	auipc	a0,0x15
    80002e32:	53250513          	addi	a0,a0,1330 # 80018360 <bcache>
    80002e36:	e87fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002e3a:	01048513          	addi	a0,s1,16
    80002e3e:	2da010ef          	jal	80004118 <acquiresleep>
      return b;
    80002e42:	a889                	j	80002e94 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e44:	0001d497          	auipc	s1,0x1d
    80002e48:	7cc4b483          	ld	s1,1996(s1) # 80020610 <bcache+0x82b0>
    80002e4c:	0001d797          	auipc	a5,0x1d
    80002e50:	77c78793          	addi	a5,a5,1916 # 800205c8 <bcache+0x8268>
    80002e54:	00f48863          	beq	s1,a5,80002e64 <bread+0x84>
    80002e58:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e5a:	40bc                	lw	a5,64(s1)
    80002e5c:	cb91                	beqz	a5,80002e70 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e5e:	64a4                	ld	s1,72(s1)
    80002e60:	fee49de3          	bne	s1,a4,80002e5a <bread+0x7a>
  panic("bget: no buffers");
    80002e64:	00004517          	auipc	a0,0x4
    80002e68:	60c50513          	addi	a0,a0,1548 # 80007470 <etext+0x470>
    80002e6c:	9b9fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002e70:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e74:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e78:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e7c:	4785                	li	a5,1
    80002e7e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e80:	00015517          	auipc	a0,0x15
    80002e84:	4e050513          	addi	a0,a0,1248 # 80018360 <bcache>
    80002e88:	e35fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002e8c:	01048513          	addi	a0,s1,16
    80002e90:	288010ef          	jal	80004118 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e94:	409c                	lw	a5,0(s1)
    80002e96:	cb89                	beqz	a5,80002ea8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e98:	8526                	mv	a0,s1
    80002e9a:	70a2                	ld	ra,40(sp)
    80002e9c:	7402                	ld	s0,32(sp)
    80002e9e:	64e2                	ld	s1,24(sp)
    80002ea0:	6942                	ld	s2,16(sp)
    80002ea2:	69a2                	ld	s3,8(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ea8:	4581                	li	a1,0
    80002eaa:	8526                	mv	a0,s1
    80002eac:	335020ef          	jal	800059e0 <virtio_disk_rw>
    b->valid = 1;
    80002eb0:	4785                	li	a5,1
    80002eb2:	c09c                	sw	a5,0(s1)
  return b;
    80002eb4:	b7d5                	j	80002e98 <bread+0xb8>

0000000080002eb6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002eb6:	1101                	addi	sp,sp,-32
    80002eb8:	ec06                	sd	ra,24(sp)
    80002eba:	e822                	sd	s0,16(sp)
    80002ebc:	e426                	sd	s1,8(sp)
    80002ebe:	1000                	addi	s0,sp,32
    80002ec0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ec2:	0541                	addi	a0,a0,16
    80002ec4:	2d2010ef          	jal	80004196 <holdingsleep>
    80002ec8:	c911                	beqz	a0,80002edc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002eca:	4585                	li	a1,1
    80002ecc:	8526                	mv	a0,s1
    80002ece:	313020ef          	jal	800059e0 <virtio_disk_rw>
}
    80002ed2:	60e2                	ld	ra,24(sp)
    80002ed4:	6442                	ld	s0,16(sp)
    80002ed6:	64a2                	ld	s1,8(sp)
    80002ed8:	6105                	addi	sp,sp,32
    80002eda:	8082                	ret
    panic("bwrite");
    80002edc:	00004517          	auipc	a0,0x4
    80002ee0:	5ac50513          	addi	a0,a0,1452 # 80007488 <etext+0x488>
    80002ee4:	941fd0ef          	jal	80000824 <panic>

0000000080002ee8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ee8:	1101                	addi	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	e04a                	sd	s2,0(sp)
    80002ef2:	1000                	addi	s0,sp,32
    80002ef4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ef6:	01050913          	addi	s2,a0,16
    80002efa:	854a                	mv	a0,s2
    80002efc:	29a010ef          	jal	80004196 <holdingsleep>
    80002f00:	c125                	beqz	a0,80002f60 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002f02:	854a                	mv	a0,s2
    80002f04:	25a010ef          	jal	8000415e <releasesleep>

  acquire(&bcache.lock);
    80002f08:	00015517          	auipc	a0,0x15
    80002f0c:	45850513          	addi	a0,a0,1112 # 80018360 <bcache>
    80002f10:	d19fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f14:	40bc                	lw	a5,64(s1)
    80002f16:	37fd                	addiw	a5,a5,-1
    80002f18:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f1a:	e79d                	bnez	a5,80002f48 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f1c:	68b8                	ld	a4,80(s1)
    80002f1e:	64bc                	ld	a5,72(s1)
    80002f20:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f22:	68b8                	ld	a4,80(s1)
    80002f24:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f26:	0001d797          	auipc	a5,0x1d
    80002f2a:	43a78793          	addi	a5,a5,1082 # 80020360 <bcache+0x8000>
    80002f2e:	2b87b703          	ld	a4,696(a5)
    80002f32:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f34:	0001d717          	auipc	a4,0x1d
    80002f38:	69470713          	addi	a4,a4,1684 # 800205c8 <bcache+0x8268>
    80002f3c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f3e:	2b87b703          	ld	a4,696(a5)
    80002f42:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f44:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f48:	00015517          	auipc	a0,0x15
    80002f4c:	41850513          	addi	a0,a0,1048 # 80018360 <bcache>
    80002f50:	d6dfd0ef          	jal	80000cbc <release>
}
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	64a2                	ld	s1,8(sp)
    80002f5a:	6902                	ld	s2,0(sp)
    80002f5c:	6105                	addi	sp,sp,32
    80002f5e:	8082                	ret
    panic("brelse");
    80002f60:	00004517          	auipc	a0,0x4
    80002f64:	53050513          	addi	a0,a0,1328 # 80007490 <etext+0x490>
    80002f68:	8bdfd0ef          	jal	80000824 <panic>

0000000080002f6c <bpin>:

void
bpin(struct buf *b) {
    80002f6c:	1101                	addi	sp,sp,-32
    80002f6e:	ec06                	sd	ra,24(sp)
    80002f70:	e822                	sd	s0,16(sp)
    80002f72:	e426                	sd	s1,8(sp)
    80002f74:	1000                	addi	s0,sp,32
    80002f76:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f78:	00015517          	auipc	a0,0x15
    80002f7c:	3e850513          	addi	a0,a0,1000 # 80018360 <bcache>
    80002f80:	ca9fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002f84:	40bc                	lw	a5,64(s1)
    80002f86:	2785                	addiw	a5,a5,1
    80002f88:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f8a:	00015517          	auipc	a0,0x15
    80002f8e:	3d650513          	addi	a0,a0,982 # 80018360 <bcache>
    80002f92:	d2bfd0ef          	jal	80000cbc <release>
}
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	64a2                	ld	s1,8(sp)
    80002f9c:	6105                	addi	sp,sp,32
    80002f9e:	8082                	ret

0000000080002fa0 <bunpin>:

void
bunpin(struct buf *b) {
    80002fa0:	1101                	addi	sp,sp,-32
    80002fa2:	ec06                	sd	ra,24(sp)
    80002fa4:	e822                	sd	s0,16(sp)
    80002fa6:	e426                	sd	s1,8(sp)
    80002fa8:	1000                	addi	s0,sp,32
    80002faa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fac:	00015517          	auipc	a0,0x15
    80002fb0:	3b450513          	addi	a0,a0,948 # 80018360 <bcache>
    80002fb4:	c75fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002fb8:	40bc                	lw	a5,64(s1)
    80002fba:	37fd                	addiw	a5,a5,-1
    80002fbc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fbe:	00015517          	auipc	a0,0x15
    80002fc2:	3a250513          	addi	a0,a0,930 # 80018360 <bcache>
    80002fc6:	cf7fd0ef          	jal	80000cbc <release>
}
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	64a2                	ld	s1,8(sp)
    80002fd0:	6105                	addi	sp,sp,32
    80002fd2:	8082                	ret

0000000080002fd4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002fd4:	1101                	addi	sp,sp,-32
    80002fd6:	ec06                	sd	ra,24(sp)
    80002fd8:	e822                	sd	s0,16(sp)
    80002fda:	e426                	sd	s1,8(sp)
    80002fdc:	e04a                	sd	s2,0(sp)
    80002fde:	1000                	addi	s0,sp,32
    80002fe0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002fe2:	00d5d79b          	srliw	a5,a1,0xd
    80002fe6:	0001e597          	auipc	a1,0x1e
    80002fea:	a565a583          	lw	a1,-1450(a1) # 80020a3c <sb+0x1c>
    80002fee:	9dbd                	addw	a1,a1,a5
    80002ff0:	df1ff0ef          	jal	80002de0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ff4:	0074f713          	andi	a4,s1,7
    80002ff8:	4785                	li	a5,1
    80002ffa:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002ffe:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003000:	90d9                	srli	s1,s1,0x36
    80003002:	00950733          	add	a4,a0,s1
    80003006:	05874703          	lbu	a4,88(a4)
    8000300a:	00e7f6b3          	and	a3,a5,a4
    8000300e:	c29d                	beqz	a3,80003034 <bfree+0x60>
    80003010:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003012:	94aa                	add	s1,s1,a0
    80003014:	fff7c793          	not	a5,a5
    80003018:	8f7d                	and	a4,a4,a5
    8000301a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000301e:	000010ef          	jal	8000401e <log_write>
  brelse(bp);
    80003022:	854a                	mv	a0,s2
    80003024:	ec5ff0ef          	jal	80002ee8 <brelse>
}
    80003028:	60e2                	ld	ra,24(sp)
    8000302a:	6442                	ld	s0,16(sp)
    8000302c:	64a2                	ld	s1,8(sp)
    8000302e:	6902                	ld	s2,0(sp)
    80003030:	6105                	addi	sp,sp,32
    80003032:	8082                	ret
    panic("freeing free block");
    80003034:	00004517          	auipc	a0,0x4
    80003038:	46450513          	addi	a0,a0,1124 # 80007498 <etext+0x498>
    8000303c:	fe8fd0ef          	jal	80000824 <panic>

0000000080003040 <balloc>:
{
    80003040:	715d                	addi	sp,sp,-80
    80003042:	e486                	sd	ra,72(sp)
    80003044:	e0a2                	sd	s0,64(sp)
    80003046:	fc26                	sd	s1,56(sp)
    80003048:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    8000304a:	0001e797          	auipc	a5,0x1e
    8000304e:	9da7a783          	lw	a5,-1574(a5) # 80020a24 <sb+0x4>
    80003052:	0e078263          	beqz	a5,80003136 <balloc+0xf6>
    80003056:	f84a                	sd	s2,48(sp)
    80003058:	f44e                	sd	s3,40(sp)
    8000305a:	f052                	sd	s4,32(sp)
    8000305c:	ec56                	sd	s5,24(sp)
    8000305e:	e85a                	sd	s6,16(sp)
    80003060:	e45e                	sd	s7,8(sp)
    80003062:	e062                	sd	s8,0(sp)
    80003064:	8baa                	mv	s7,a0
    80003066:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003068:	0001eb17          	auipc	s6,0x1e
    8000306c:	9b8b0b13          	addi	s6,s6,-1608 # 80020a20 <sb>
      m = 1 << (bi % 8);
    80003070:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003072:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003074:	6c09                	lui	s8,0x2
    80003076:	a09d                	j	800030dc <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003078:	97ca                	add	a5,a5,s2
    8000307a:	8e55                	or	a2,a2,a3
    8000307c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003080:	854a                	mv	a0,s2
    80003082:	79d000ef          	jal	8000401e <log_write>
        brelse(bp);
    80003086:	854a                	mv	a0,s2
    80003088:	e61ff0ef          	jal	80002ee8 <brelse>
  bp = bread(dev, bno);
    8000308c:	85a6                	mv	a1,s1
    8000308e:	855e                	mv	a0,s7
    80003090:	d51ff0ef          	jal	80002de0 <bread>
    80003094:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003096:	40000613          	li	a2,1024
    8000309a:	4581                	li	a1,0
    8000309c:	05850513          	addi	a0,a0,88
    800030a0:	c59fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    800030a4:	854a                	mv	a0,s2
    800030a6:	779000ef          	jal	8000401e <log_write>
  brelse(bp);
    800030aa:	854a                	mv	a0,s2
    800030ac:	e3dff0ef          	jal	80002ee8 <brelse>
}
    800030b0:	7942                	ld	s2,48(sp)
    800030b2:	79a2                	ld	s3,40(sp)
    800030b4:	7a02                	ld	s4,32(sp)
    800030b6:	6ae2                	ld	s5,24(sp)
    800030b8:	6b42                	ld	s6,16(sp)
    800030ba:	6ba2                	ld	s7,8(sp)
    800030bc:	6c02                	ld	s8,0(sp)
}
    800030be:	8526                	mv	a0,s1
    800030c0:	60a6                	ld	ra,72(sp)
    800030c2:	6406                	ld	s0,64(sp)
    800030c4:	74e2                	ld	s1,56(sp)
    800030c6:	6161                	addi	sp,sp,80
    800030c8:	8082                	ret
    brelse(bp);
    800030ca:	854a                	mv	a0,s2
    800030cc:	e1dff0ef          	jal	80002ee8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030d0:	015c0abb          	addw	s5,s8,s5
    800030d4:	004b2783          	lw	a5,4(s6)
    800030d8:	04faf863          	bgeu	s5,a5,80003128 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800030dc:	40dad59b          	sraiw	a1,s5,0xd
    800030e0:	01cb2783          	lw	a5,28(s6)
    800030e4:	9dbd                	addw	a1,a1,a5
    800030e6:	855e                	mv	a0,s7
    800030e8:	cf9ff0ef          	jal	80002de0 <bread>
    800030ec:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ee:	004b2503          	lw	a0,4(s6)
    800030f2:	84d6                	mv	s1,s5
    800030f4:	4701                	li	a4,0
    800030f6:	fca4fae3          	bgeu	s1,a0,800030ca <balloc+0x8a>
      m = 1 << (bi % 8);
    800030fa:	00777693          	andi	a3,a4,7
    800030fe:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003102:	41f7579b          	sraiw	a5,a4,0x1f
    80003106:	01d7d79b          	srliw	a5,a5,0x1d
    8000310a:	9fb9                	addw	a5,a5,a4
    8000310c:	4037d79b          	sraiw	a5,a5,0x3
    80003110:	00f90633          	add	a2,s2,a5
    80003114:	05864603          	lbu	a2,88(a2)
    80003118:	00c6f5b3          	and	a1,a3,a2
    8000311c:	ddb1                	beqz	a1,80003078 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000311e:	2705                	addiw	a4,a4,1
    80003120:	2485                	addiw	s1,s1,1
    80003122:	fd471ae3          	bne	a4,s4,800030f6 <balloc+0xb6>
    80003126:	b755                	j	800030ca <balloc+0x8a>
    80003128:	7942                	ld	s2,48(sp)
    8000312a:	79a2                	ld	s3,40(sp)
    8000312c:	7a02                	ld	s4,32(sp)
    8000312e:	6ae2                	ld	s5,24(sp)
    80003130:	6b42                	ld	s6,16(sp)
    80003132:	6ba2                	ld	s7,8(sp)
    80003134:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003136:	00004517          	auipc	a0,0x4
    8000313a:	37a50513          	addi	a0,a0,890 # 800074b0 <etext+0x4b0>
    8000313e:	bbcfd0ef          	jal	800004fa <printf>
  return 0;
    80003142:	4481                	li	s1,0
    80003144:	bfad                	j	800030be <balloc+0x7e>

0000000080003146 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003146:	7179                	addi	sp,sp,-48
    80003148:	f406                	sd	ra,40(sp)
    8000314a:	f022                	sd	s0,32(sp)
    8000314c:	ec26                	sd	s1,24(sp)
    8000314e:	e84a                	sd	s2,16(sp)
    80003150:	e44e                	sd	s3,8(sp)
    80003152:	1800                	addi	s0,sp,48
    80003154:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003156:	47ad                	li	a5,11
    80003158:	02b7e363          	bltu	a5,a1,8000317e <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000315c:	02059793          	slli	a5,a1,0x20
    80003160:	01e7d593          	srli	a1,a5,0x1e
    80003164:	00b509b3          	add	s3,a0,a1
    80003168:	0509a483          	lw	s1,80(s3)
    8000316c:	e0b5                	bnez	s1,800031d0 <bmap+0x8a>
      addr = balloc(ip->dev);
    8000316e:	4108                	lw	a0,0(a0)
    80003170:	ed1ff0ef          	jal	80003040 <balloc>
    80003174:	84aa                	mv	s1,a0
      if(addr == 0)
    80003176:	cd29                	beqz	a0,800031d0 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003178:	04a9a823          	sw	a0,80(s3)
    8000317c:	a891                	j	800031d0 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000317e:	ff45879b          	addiw	a5,a1,-12
    80003182:	873e                	mv	a4,a5
    80003184:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003186:	0ff00793          	li	a5,255
    8000318a:	06e7e763          	bltu	a5,a4,800031f8 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000318e:	08052483          	lw	s1,128(a0)
    80003192:	e891                	bnez	s1,800031a6 <bmap+0x60>
      addr = balloc(ip->dev);
    80003194:	4108                	lw	a0,0(a0)
    80003196:	eabff0ef          	jal	80003040 <balloc>
    8000319a:	84aa                	mv	s1,a0
      if(addr == 0)
    8000319c:	c915                	beqz	a0,800031d0 <bmap+0x8a>
    8000319e:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800031a0:	08a92023          	sw	a0,128(s2)
    800031a4:	a011                	j	800031a8 <bmap+0x62>
    800031a6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800031a8:	85a6                	mv	a1,s1
    800031aa:	00092503          	lw	a0,0(s2)
    800031ae:	c33ff0ef          	jal	80002de0 <bread>
    800031b2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800031b4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800031b8:	02099713          	slli	a4,s3,0x20
    800031bc:	01e75593          	srli	a1,a4,0x1e
    800031c0:	97ae                	add	a5,a5,a1
    800031c2:	89be                	mv	s3,a5
    800031c4:	4384                	lw	s1,0(a5)
    800031c6:	cc89                	beqz	s1,800031e0 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800031c8:	8552                	mv	a0,s4
    800031ca:	d1fff0ef          	jal	80002ee8 <brelse>
    return addr;
    800031ce:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800031d0:	8526                	mv	a0,s1
    800031d2:	70a2                	ld	ra,40(sp)
    800031d4:	7402                	ld	s0,32(sp)
    800031d6:	64e2                	ld	s1,24(sp)
    800031d8:	6942                	ld	s2,16(sp)
    800031da:	69a2                	ld	s3,8(sp)
    800031dc:	6145                	addi	sp,sp,48
    800031de:	8082                	ret
      addr = balloc(ip->dev);
    800031e0:	00092503          	lw	a0,0(s2)
    800031e4:	e5dff0ef          	jal	80003040 <balloc>
    800031e8:	84aa                	mv	s1,a0
      if(addr){
    800031ea:	dd79                	beqz	a0,800031c8 <bmap+0x82>
        a[bn] = addr;
    800031ec:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800031f0:	8552                	mv	a0,s4
    800031f2:	62d000ef          	jal	8000401e <log_write>
    800031f6:	bfc9                	j	800031c8 <bmap+0x82>
    800031f8:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031fa:	00004517          	auipc	a0,0x4
    800031fe:	2ce50513          	addi	a0,a0,718 # 800074c8 <etext+0x4c8>
    80003202:	e22fd0ef          	jal	80000824 <panic>

0000000080003206 <iget>:
{
    80003206:	7179                	addi	sp,sp,-48
    80003208:	f406                	sd	ra,40(sp)
    8000320a:	f022                	sd	s0,32(sp)
    8000320c:	ec26                	sd	s1,24(sp)
    8000320e:	e84a                	sd	s2,16(sp)
    80003210:	e44e                	sd	s3,8(sp)
    80003212:	e052                	sd	s4,0(sp)
    80003214:	1800                	addi	s0,sp,48
    80003216:	892a                	mv	s2,a0
    80003218:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000321a:	0001e517          	auipc	a0,0x1e
    8000321e:	82650513          	addi	a0,a0,-2010 # 80020a40 <itable>
    80003222:	a07fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    80003226:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003228:	0001e497          	auipc	s1,0x1e
    8000322c:	83048493          	addi	s1,s1,-2000 # 80020a58 <itable+0x18>
    80003230:	0001f697          	auipc	a3,0x1f
    80003234:	2b868693          	addi	a3,a3,696 # 800224e8 <log>
    80003238:	a809                	j	8000324a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000323a:	e781                	bnez	a5,80003242 <iget+0x3c>
    8000323c:	00099363          	bnez	s3,80003242 <iget+0x3c>
      empty = ip;
    80003240:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003242:	08848493          	addi	s1,s1,136
    80003246:	02d48563          	beq	s1,a3,80003270 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000324a:	449c                	lw	a5,8(s1)
    8000324c:	fef057e3          	blez	a5,8000323a <iget+0x34>
    80003250:	4098                	lw	a4,0(s1)
    80003252:	ff2718e3          	bne	a4,s2,80003242 <iget+0x3c>
    80003256:	40d8                	lw	a4,4(s1)
    80003258:	ff4715e3          	bne	a4,s4,80003242 <iget+0x3c>
      ip->ref++;
    8000325c:	2785                	addiw	a5,a5,1
    8000325e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003260:	0001d517          	auipc	a0,0x1d
    80003264:	7e050513          	addi	a0,a0,2016 # 80020a40 <itable>
    80003268:	a55fd0ef          	jal	80000cbc <release>
      return ip;
    8000326c:	89a6                	mv	s3,s1
    8000326e:	a015                	j	80003292 <iget+0x8c>
  if(empty == 0)
    80003270:	02098a63          	beqz	s3,800032a4 <iget+0x9e>
  ip->dev = dev;
    80003274:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003278:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000327c:	4785                	li	a5,1
    8000327e:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003282:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003286:	0001d517          	auipc	a0,0x1d
    8000328a:	7ba50513          	addi	a0,a0,1978 # 80020a40 <itable>
    8000328e:	a2ffd0ef          	jal	80000cbc <release>
}
    80003292:	854e                	mv	a0,s3
    80003294:	70a2                	ld	ra,40(sp)
    80003296:	7402                	ld	s0,32(sp)
    80003298:	64e2                	ld	s1,24(sp)
    8000329a:	6942                	ld	s2,16(sp)
    8000329c:	69a2                	ld	s3,8(sp)
    8000329e:	6a02                	ld	s4,0(sp)
    800032a0:	6145                	addi	sp,sp,48
    800032a2:	8082                	ret
    panic("iget: no inodes");
    800032a4:	00004517          	auipc	a0,0x4
    800032a8:	23c50513          	addi	a0,a0,572 # 800074e0 <etext+0x4e0>
    800032ac:	d78fd0ef          	jal	80000824 <panic>

00000000800032b0 <iinit>:
{
    800032b0:	7179                	addi	sp,sp,-48
    800032b2:	f406                	sd	ra,40(sp)
    800032b4:	f022                	sd	s0,32(sp)
    800032b6:	ec26                	sd	s1,24(sp)
    800032b8:	e84a                	sd	s2,16(sp)
    800032ba:	e44e                	sd	s3,8(sp)
    800032bc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032be:	00004597          	auipc	a1,0x4
    800032c2:	23258593          	addi	a1,a1,562 # 800074f0 <etext+0x4f0>
    800032c6:	0001d517          	auipc	a0,0x1d
    800032ca:	77a50513          	addi	a0,a0,1914 # 80020a40 <itable>
    800032ce:	8d1fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    800032d2:	0001d497          	auipc	s1,0x1d
    800032d6:	79648493          	addi	s1,s1,1942 # 80020a68 <itable+0x28>
    800032da:	0001f997          	auipc	s3,0x1f
    800032de:	21e98993          	addi	s3,s3,542 # 800224f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032e2:	00004917          	auipc	s2,0x4
    800032e6:	21690913          	addi	s2,s2,534 # 800074f8 <etext+0x4f8>
    800032ea:	85ca                	mv	a1,s2
    800032ec:	8526                	mv	a0,s1
    800032ee:	5f5000ef          	jal	800040e2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032f2:	08848493          	addi	s1,s1,136
    800032f6:	ff349ae3          	bne	s1,s3,800032ea <iinit+0x3a>
}
    800032fa:	70a2                	ld	ra,40(sp)
    800032fc:	7402                	ld	s0,32(sp)
    800032fe:	64e2                	ld	s1,24(sp)
    80003300:	6942                	ld	s2,16(sp)
    80003302:	69a2                	ld	s3,8(sp)
    80003304:	6145                	addi	sp,sp,48
    80003306:	8082                	ret

0000000080003308 <ialloc>:
{
    80003308:	7139                	addi	sp,sp,-64
    8000330a:	fc06                	sd	ra,56(sp)
    8000330c:	f822                	sd	s0,48(sp)
    8000330e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003310:	0001d717          	auipc	a4,0x1d
    80003314:	71c72703          	lw	a4,1820(a4) # 80020a2c <sb+0xc>
    80003318:	4785                	li	a5,1
    8000331a:	06e7f063          	bgeu	a5,a4,8000337a <ialloc+0x72>
    8000331e:	f426                	sd	s1,40(sp)
    80003320:	f04a                	sd	s2,32(sp)
    80003322:	ec4e                	sd	s3,24(sp)
    80003324:	e852                	sd	s4,16(sp)
    80003326:	e456                	sd	s5,8(sp)
    80003328:	e05a                	sd	s6,0(sp)
    8000332a:	8aaa                	mv	s5,a0
    8000332c:	8b2e                	mv	s6,a1
    8000332e:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003330:	0001da17          	auipc	s4,0x1d
    80003334:	6f0a0a13          	addi	s4,s4,1776 # 80020a20 <sb>
    80003338:	00495593          	srli	a1,s2,0x4
    8000333c:	018a2783          	lw	a5,24(s4)
    80003340:	9dbd                	addw	a1,a1,a5
    80003342:	8556                	mv	a0,s5
    80003344:	a9dff0ef          	jal	80002de0 <bread>
    80003348:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000334a:	05850993          	addi	s3,a0,88
    8000334e:	00f97793          	andi	a5,s2,15
    80003352:	079a                	slli	a5,a5,0x6
    80003354:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003356:	00099783          	lh	a5,0(s3)
    8000335a:	cb9d                	beqz	a5,80003390 <ialloc+0x88>
    brelse(bp);
    8000335c:	b8dff0ef          	jal	80002ee8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003360:	0905                	addi	s2,s2,1
    80003362:	00ca2703          	lw	a4,12(s4)
    80003366:	0009079b          	sext.w	a5,s2
    8000336a:	fce7e7e3          	bltu	a5,a4,80003338 <ialloc+0x30>
    8000336e:	74a2                	ld	s1,40(sp)
    80003370:	7902                	ld	s2,32(sp)
    80003372:	69e2                	ld	s3,24(sp)
    80003374:	6a42                	ld	s4,16(sp)
    80003376:	6aa2                	ld	s5,8(sp)
    80003378:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000337a:	00004517          	auipc	a0,0x4
    8000337e:	18650513          	addi	a0,a0,390 # 80007500 <etext+0x500>
    80003382:	978fd0ef          	jal	800004fa <printf>
  return 0;
    80003386:	4501                	li	a0,0
}
    80003388:	70e2                	ld	ra,56(sp)
    8000338a:	7442                	ld	s0,48(sp)
    8000338c:	6121                	addi	sp,sp,64
    8000338e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003390:	04000613          	li	a2,64
    80003394:	4581                	li	a1,0
    80003396:	854e                	mv	a0,s3
    80003398:	961fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    8000339c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033a0:	8526                	mv	a0,s1
    800033a2:	47d000ef          	jal	8000401e <log_write>
      brelse(bp);
    800033a6:	8526                	mv	a0,s1
    800033a8:	b41ff0ef          	jal	80002ee8 <brelse>
      return iget(dev, inum);
    800033ac:	0009059b          	sext.w	a1,s2
    800033b0:	8556                	mv	a0,s5
    800033b2:	e55ff0ef          	jal	80003206 <iget>
    800033b6:	74a2                	ld	s1,40(sp)
    800033b8:	7902                	ld	s2,32(sp)
    800033ba:	69e2                	ld	s3,24(sp)
    800033bc:	6a42                	ld	s4,16(sp)
    800033be:	6aa2                	ld	s5,8(sp)
    800033c0:	6b02                	ld	s6,0(sp)
    800033c2:	b7d9                	j	80003388 <ialloc+0x80>

00000000800033c4 <iupdate>:
{
    800033c4:	1101                	addi	sp,sp,-32
    800033c6:	ec06                	sd	ra,24(sp)
    800033c8:	e822                	sd	s0,16(sp)
    800033ca:	e426                	sd	s1,8(sp)
    800033cc:	e04a                	sd	s2,0(sp)
    800033ce:	1000                	addi	s0,sp,32
    800033d0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033d2:	415c                	lw	a5,4(a0)
    800033d4:	0047d79b          	srliw	a5,a5,0x4
    800033d8:	0001d597          	auipc	a1,0x1d
    800033dc:	6605a583          	lw	a1,1632(a1) # 80020a38 <sb+0x18>
    800033e0:	9dbd                	addw	a1,a1,a5
    800033e2:	4108                	lw	a0,0(a0)
    800033e4:	9fdff0ef          	jal	80002de0 <bread>
    800033e8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033ea:	05850793          	addi	a5,a0,88
    800033ee:	40d8                	lw	a4,4(s1)
    800033f0:	8b3d                	andi	a4,a4,15
    800033f2:	071a                	slli	a4,a4,0x6
    800033f4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800033f6:	04449703          	lh	a4,68(s1)
    800033fa:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800033fe:	04649703          	lh	a4,70(s1)
    80003402:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003406:	04849703          	lh	a4,72(s1)
    8000340a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000340e:	04a49703          	lh	a4,74(s1)
    80003412:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003416:	44f8                	lw	a4,76(s1)
    80003418:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000341a:	03400613          	li	a2,52
    8000341e:	05048593          	addi	a1,s1,80
    80003422:	00c78513          	addi	a0,a5,12
    80003426:	933fd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    8000342a:	854a                	mv	a0,s2
    8000342c:	3f3000ef          	jal	8000401e <log_write>
  brelse(bp);
    80003430:	854a                	mv	a0,s2
    80003432:	ab7ff0ef          	jal	80002ee8 <brelse>
}
    80003436:	60e2                	ld	ra,24(sp)
    80003438:	6442                	ld	s0,16(sp)
    8000343a:	64a2                	ld	s1,8(sp)
    8000343c:	6902                	ld	s2,0(sp)
    8000343e:	6105                	addi	sp,sp,32
    80003440:	8082                	ret

0000000080003442 <idup>:
{
    80003442:	1101                	addi	sp,sp,-32
    80003444:	ec06                	sd	ra,24(sp)
    80003446:	e822                	sd	s0,16(sp)
    80003448:	e426                	sd	s1,8(sp)
    8000344a:	1000                	addi	s0,sp,32
    8000344c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000344e:	0001d517          	auipc	a0,0x1d
    80003452:	5f250513          	addi	a0,a0,1522 # 80020a40 <itable>
    80003456:	fd2fd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    8000345a:	449c                	lw	a5,8(s1)
    8000345c:	2785                	addiw	a5,a5,1
    8000345e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003460:	0001d517          	auipc	a0,0x1d
    80003464:	5e050513          	addi	a0,a0,1504 # 80020a40 <itable>
    80003468:	855fd0ef          	jal	80000cbc <release>
}
    8000346c:	8526                	mv	a0,s1
    8000346e:	60e2                	ld	ra,24(sp)
    80003470:	6442                	ld	s0,16(sp)
    80003472:	64a2                	ld	s1,8(sp)
    80003474:	6105                	addi	sp,sp,32
    80003476:	8082                	ret

0000000080003478 <ilock>:
{
    80003478:	1101                	addi	sp,sp,-32
    8000347a:	ec06                	sd	ra,24(sp)
    8000347c:	e822                	sd	s0,16(sp)
    8000347e:	e426                	sd	s1,8(sp)
    80003480:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003482:	cd19                	beqz	a0,800034a0 <ilock+0x28>
    80003484:	84aa                	mv	s1,a0
    80003486:	451c                	lw	a5,8(a0)
    80003488:	00f05c63          	blez	a5,800034a0 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000348c:	0541                	addi	a0,a0,16
    8000348e:	48b000ef          	jal	80004118 <acquiresleep>
  if(ip->valid == 0){
    80003492:	40bc                	lw	a5,64(s1)
    80003494:	cf89                	beqz	a5,800034ae <ilock+0x36>
}
    80003496:	60e2                	ld	ra,24(sp)
    80003498:	6442                	ld	s0,16(sp)
    8000349a:	64a2                	ld	s1,8(sp)
    8000349c:	6105                	addi	sp,sp,32
    8000349e:	8082                	ret
    800034a0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034a2:	00004517          	auipc	a0,0x4
    800034a6:	07650513          	addi	a0,a0,118 # 80007518 <etext+0x518>
    800034aa:	b7afd0ef          	jal	80000824 <panic>
    800034ae:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034b0:	40dc                	lw	a5,4(s1)
    800034b2:	0047d79b          	srliw	a5,a5,0x4
    800034b6:	0001d597          	auipc	a1,0x1d
    800034ba:	5825a583          	lw	a1,1410(a1) # 80020a38 <sb+0x18>
    800034be:	9dbd                	addw	a1,a1,a5
    800034c0:	4088                	lw	a0,0(s1)
    800034c2:	91fff0ef          	jal	80002de0 <bread>
    800034c6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034c8:	05850593          	addi	a1,a0,88
    800034cc:	40dc                	lw	a5,4(s1)
    800034ce:	8bbd                	andi	a5,a5,15
    800034d0:	079a                	slli	a5,a5,0x6
    800034d2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034d4:	00059783          	lh	a5,0(a1)
    800034d8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034dc:	00259783          	lh	a5,2(a1)
    800034e0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034e4:	00459783          	lh	a5,4(a1)
    800034e8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034ec:	00659783          	lh	a5,6(a1)
    800034f0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800034f4:	459c                	lw	a5,8(a1)
    800034f6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800034f8:	03400613          	li	a2,52
    800034fc:	05b1                	addi	a1,a1,12
    800034fe:	05048513          	addi	a0,s1,80
    80003502:	857fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003506:	854a                	mv	a0,s2
    80003508:	9e1ff0ef          	jal	80002ee8 <brelse>
    ip->valid = 1;
    8000350c:	4785                	li	a5,1
    8000350e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003510:	04449783          	lh	a5,68(s1)
    80003514:	c399                	beqz	a5,8000351a <ilock+0xa2>
    80003516:	6902                	ld	s2,0(sp)
    80003518:	bfbd                	j	80003496 <ilock+0x1e>
      panic("ilock: no type");
    8000351a:	00004517          	auipc	a0,0x4
    8000351e:	00650513          	addi	a0,a0,6 # 80007520 <etext+0x520>
    80003522:	b02fd0ef          	jal	80000824 <panic>

0000000080003526 <iunlock>:
{
    80003526:	1101                	addi	sp,sp,-32
    80003528:	ec06                	sd	ra,24(sp)
    8000352a:	e822                	sd	s0,16(sp)
    8000352c:	e426                	sd	s1,8(sp)
    8000352e:	e04a                	sd	s2,0(sp)
    80003530:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003532:	c505                	beqz	a0,8000355a <iunlock+0x34>
    80003534:	84aa                	mv	s1,a0
    80003536:	01050913          	addi	s2,a0,16
    8000353a:	854a                	mv	a0,s2
    8000353c:	45b000ef          	jal	80004196 <holdingsleep>
    80003540:	cd09                	beqz	a0,8000355a <iunlock+0x34>
    80003542:	449c                	lw	a5,8(s1)
    80003544:	00f05b63          	blez	a5,8000355a <iunlock+0x34>
  releasesleep(&ip->lock);
    80003548:	854a                	mv	a0,s2
    8000354a:	415000ef          	jal	8000415e <releasesleep>
}
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6902                	ld	s2,0(sp)
    80003556:	6105                	addi	sp,sp,32
    80003558:	8082                	ret
    panic("iunlock");
    8000355a:	00004517          	auipc	a0,0x4
    8000355e:	fd650513          	addi	a0,a0,-42 # 80007530 <etext+0x530>
    80003562:	ac2fd0ef          	jal	80000824 <panic>

0000000080003566 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003566:	7179                	addi	sp,sp,-48
    80003568:	f406                	sd	ra,40(sp)
    8000356a:	f022                	sd	s0,32(sp)
    8000356c:	ec26                	sd	s1,24(sp)
    8000356e:	e84a                	sd	s2,16(sp)
    80003570:	e44e                	sd	s3,8(sp)
    80003572:	1800                	addi	s0,sp,48
    80003574:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003576:	05050493          	addi	s1,a0,80
    8000357a:	08050913          	addi	s2,a0,128
    8000357e:	a021                	j	80003586 <itrunc+0x20>
    80003580:	0491                	addi	s1,s1,4
    80003582:	01248b63          	beq	s1,s2,80003598 <itrunc+0x32>
    if(ip->addrs[i]){
    80003586:	408c                	lw	a1,0(s1)
    80003588:	dde5                	beqz	a1,80003580 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000358a:	0009a503          	lw	a0,0(s3)
    8000358e:	a47ff0ef          	jal	80002fd4 <bfree>
      ip->addrs[i] = 0;
    80003592:	0004a023          	sw	zero,0(s1)
    80003596:	b7ed                	j	80003580 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003598:	0809a583          	lw	a1,128(s3)
    8000359c:	ed89                	bnez	a1,800035b6 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000359e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035a2:	854e                	mv	a0,s3
    800035a4:	e21ff0ef          	jal	800033c4 <iupdate>
}
    800035a8:	70a2                	ld	ra,40(sp)
    800035aa:	7402                	ld	s0,32(sp)
    800035ac:	64e2                	ld	s1,24(sp)
    800035ae:	6942                	ld	s2,16(sp)
    800035b0:	69a2                	ld	s3,8(sp)
    800035b2:	6145                	addi	sp,sp,48
    800035b4:	8082                	ret
    800035b6:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035b8:	0009a503          	lw	a0,0(s3)
    800035bc:	825ff0ef          	jal	80002de0 <bread>
    800035c0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800035c2:	05850493          	addi	s1,a0,88
    800035c6:	45850913          	addi	s2,a0,1112
    800035ca:	a021                	j	800035d2 <itrunc+0x6c>
    800035cc:	0491                	addi	s1,s1,4
    800035ce:	01248963          	beq	s1,s2,800035e0 <itrunc+0x7a>
      if(a[j])
    800035d2:	408c                	lw	a1,0(s1)
    800035d4:	dde5                	beqz	a1,800035cc <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800035d6:	0009a503          	lw	a0,0(s3)
    800035da:	9fbff0ef          	jal	80002fd4 <bfree>
    800035de:	b7fd                	j	800035cc <itrunc+0x66>
    brelse(bp);
    800035e0:	8552                	mv	a0,s4
    800035e2:	907ff0ef          	jal	80002ee8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035e6:	0809a583          	lw	a1,128(s3)
    800035ea:	0009a503          	lw	a0,0(s3)
    800035ee:	9e7ff0ef          	jal	80002fd4 <bfree>
    ip->addrs[NDIRECT] = 0;
    800035f2:	0809a023          	sw	zero,128(s3)
    800035f6:	6a02                	ld	s4,0(sp)
    800035f8:	b75d                	j	8000359e <itrunc+0x38>

00000000800035fa <iput>:
{
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	1000                	addi	s0,sp,32
    80003604:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003606:	0001d517          	auipc	a0,0x1d
    8000360a:	43a50513          	addi	a0,a0,1082 # 80020a40 <itable>
    8000360e:	e1afd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003612:	4498                	lw	a4,8(s1)
    80003614:	4785                	li	a5,1
    80003616:	02f70063          	beq	a4,a5,80003636 <iput+0x3c>
  ip->ref--;
    8000361a:	449c                	lw	a5,8(s1)
    8000361c:	37fd                	addiw	a5,a5,-1
    8000361e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003620:	0001d517          	auipc	a0,0x1d
    80003624:	42050513          	addi	a0,a0,1056 # 80020a40 <itable>
    80003628:	e94fd0ef          	jal	80000cbc <release>
}
    8000362c:	60e2                	ld	ra,24(sp)
    8000362e:	6442                	ld	s0,16(sp)
    80003630:	64a2                	ld	s1,8(sp)
    80003632:	6105                	addi	sp,sp,32
    80003634:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003636:	40bc                	lw	a5,64(s1)
    80003638:	d3ed                	beqz	a5,8000361a <iput+0x20>
    8000363a:	04a49783          	lh	a5,74(s1)
    8000363e:	fff1                	bnez	a5,8000361a <iput+0x20>
    80003640:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003642:	01048793          	addi	a5,s1,16
    80003646:	893e                	mv	s2,a5
    80003648:	853e                	mv	a0,a5
    8000364a:	2cf000ef          	jal	80004118 <acquiresleep>
    release(&itable.lock);
    8000364e:	0001d517          	auipc	a0,0x1d
    80003652:	3f250513          	addi	a0,a0,1010 # 80020a40 <itable>
    80003656:	e66fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    8000365a:	8526                	mv	a0,s1
    8000365c:	f0bff0ef          	jal	80003566 <itrunc>
    ip->type = 0;
    80003660:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003664:	8526                	mv	a0,s1
    80003666:	d5fff0ef          	jal	800033c4 <iupdate>
    ip->valid = 0;
    8000366a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000366e:	854a                	mv	a0,s2
    80003670:	2ef000ef          	jal	8000415e <releasesleep>
    acquire(&itable.lock);
    80003674:	0001d517          	auipc	a0,0x1d
    80003678:	3cc50513          	addi	a0,a0,972 # 80020a40 <itable>
    8000367c:	dacfd0ef          	jal	80000c28 <acquire>
    80003680:	6902                	ld	s2,0(sp)
    80003682:	bf61                	j	8000361a <iput+0x20>

0000000080003684 <iunlockput>:
{
    80003684:	1101                	addi	sp,sp,-32
    80003686:	ec06                	sd	ra,24(sp)
    80003688:	e822                	sd	s0,16(sp)
    8000368a:	e426                	sd	s1,8(sp)
    8000368c:	1000                	addi	s0,sp,32
    8000368e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003690:	e97ff0ef          	jal	80003526 <iunlock>
  iput(ip);
    80003694:	8526                	mv	a0,s1
    80003696:	f65ff0ef          	jal	800035fa <iput>
}
    8000369a:	60e2                	ld	ra,24(sp)
    8000369c:	6442                	ld	s0,16(sp)
    8000369e:	64a2                	ld	s1,8(sp)
    800036a0:	6105                	addi	sp,sp,32
    800036a2:	8082                	ret

00000000800036a4 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036a4:	0001d717          	auipc	a4,0x1d
    800036a8:	38872703          	lw	a4,904(a4) # 80020a2c <sb+0xc>
    800036ac:	4785                	li	a5,1
    800036ae:	0ae7fe63          	bgeu	a5,a4,8000376a <ireclaim+0xc6>
{
    800036b2:	7139                	addi	sp,sp,-64
    800036b4:	fc06                	sd	ra,56(sp)
    800036b6:	f822                	sd	s0,48(sp)
    800036b8:	f426                	sd	s1,40(sp)
    800036ba:	f04a                	sd	s2,32(sp)
    800036bc:	ec4e                	sd	s3,24(sp)
    800036be:	e852                	sd	s4,16(sp)
    800036c0:	e456                	sd	s5,8(sp)
    800036c2:	e05a                	sd	s6,0(sp)
    800036c4:	0080                	addi	s0,sp,64
    800036c6:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800036c8:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800036ca:	0001da17          	auipc	s4,0x1d
    800036ce:	356a0a13          	addi	s4,s4,854 # 80020a20 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800036d2:	00004b17          	auipc	s6,0x4
    800036d6:	e66b0b13          	addi	s6,s6,-410 # 80007538 <etext+0x538>
    800036da:	a099                	j	80003720 <ireclaim+0x7c>
    800036dc:	85ce                	mv	a1,s3
    800036de:	855a                	mv	a0,s6
    800036e0:	e1bfc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    800036e4:	85ce                	mv	a1,s3
    800036e6:	8556                	mv	a0,s5
    800036e8:	b1fff0ef          	jal	80003206 <iget>
    800036ec:	89aa                	mv	s3,a0
    brelse(bp);
    800036ee:	854a                	mv	a0,s2
    800036f0:	ff8ff0ef          	jal	80002ee8 <brelse>
    if (ip) {
    800036f4:	00098f63          	beqz	s3,80003712 <ireclaim+0x6e>
      begin_op();
    800036f8:	78c000ef          	jal	80003e84 <begin_op>
      ilock(ip);
    800036fc:	854e                	mv	a0,s3
    800036fe:	d7bff0ef          	jal	80003478 <ilock>
      iunlock(ip);
    80003702:	854e                	mv	a0,s3
    80003704:	e23ff0ef          	jal	80003526 <iunlock>
      iput(ip);
    80003708:	854e                	mv	a0,s3
    8000370a:	ef1ff0ef          	jal	800035fa <iput>
      end_op();
    8000370e:	7e6000ef          	jal	80003ef4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003712:	0485                	addi	s1,s1,1
    80003714:	00ca2703          	lw	a4,12(s4)
    80003718:	0004879b          	sext.w	a5,s1
    8000371c:	02e7fd63          	bgeu	a5,a4,80003756 <ireclaim+0xb2>
    80003720:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003724:	0044d593          	srli	a1,s1,0x4
    80003728:	018a2783          	lw	a5,24(s4)
    8000372c:	9dbd                	addw	a1,a1,a5
    8000372e:	8556                	mv	a0,s5
    80003730:	eb0ff0ef          	jal	80002de0 <bread>
    80003734:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003736:	05850793          	addi	a5,a0,88
    8000373a:	00f9f713          	andi	a4,s3,15
    8000373e:	071a                	slli	a4,a4,0x6
    80003740:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003742:	00079703          	lh	a4,0(a5)
    80003746:	c701                	beqz	a4,8000374e <ireclaim+0xaa>
    80003748:	00679783          	lh	a5,6(a5)
    8000374c:	dbc1                	beqz	a5,800036dc <ireclaim+0x38>
    brelse(bp);
    8000374e:	854a                	mv	a0,s2
    80003750:	f98ff0ef          	jal	80002ee8 <brelse>
    if (ip) {
    80003754:	bf7d                	j	80003712 <ireclaim+0x6e>
}
    80003756:	70e2                	ld	ra,56(sp)
    80003758:	7442                	ld	s0,48(sp)
    8000375a:	74a2                	ld	s1,40(sp)
    8000375c:	7902                	ld	s2,32(sp)
    8000375e:	69e2                	ld	s3,24(sp)
    80003760:	6a42                	ld	s4,16(sp)
    80003762:	6aa2                	ld	s5,8(sp)
    80003764:	6b02                	ld	s6,0(sp)
    80003766:	6121                	addi	sp,sp,64
    80003768:	8082                	ret
    8000376a:	8082                	ret

000000008000376c <fsinit>:
fsinit(int dev) {
    8000376c:	1101                	addi	sp,sp,-32
    8000376e:	ec06                	sd	ra,24(sp)
    80003770:	e822                	sd	s0,16(sp)
    80003772:	e426                	sd	s1,8(sp)
    80003774:	e04a                	sd	s2,0(sp)
    80003776:	1000                	addi	s0,sp,32
    80003778:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000377a:	4585                	li	a1,1
    8000377c:	e64ff0ef          	jal	80002de0 <bread>
    80003780:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003782:	02000613          	li	a2,32
    80003786:	05850593          	addi	a1,a0,88
    8000378a:	0001d517          	auipc	a0,0x1d
    8000378e:	29650513          	addi	a0,a0,662 # 80020a20 <sb>
    80003792:	dc6fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003796:	8526                	mv	a0,s1
    80003798:	f50ff0ef          	jal	80002ee8 <brelse>
  if(sb.magic != FSMAGIC)
    8000379c:	0001d717          	auipc	a4,0x1d
    800037a0:	28472703          	lw	a4,644(a4) # 80020a20 <sb>
    800037a4:	102037b7          	lui	a5,0x10203
    800037a8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ac:	02f71263          	bne	a4,a5,800037d0 <fsinit+0x64>
  initlog(dev, &sb);
    800037b0:	0001d597          	auipc	a1,0x1d
    800037b4:	27058593          	addi	a1,a1,624 # 80020a20 <sb>
    800037b8:	854a                	mv	a0,s2
    800037ba:	648000ef          	jal	80003e02 <initlog>
  ireclaim(dev);
    800037be:	854a                	mv	a0,s2
    800037c0:	ee5ff0ef          	jal	800036a4 <ireclaim>
}
    800037c4:	60e2                	ld	ra,24(sp)
    800037c6:	6442                	ld	s0,16(sp)
    800037c8:	64a2                	ld	s1,8(sp)
    800037ca:	6902                	ld	s2,0(sp)
    800037cc:	6105                	addi	sp,sp,32
    800037ce:	8082                	ret
    panic("invalid file system");
    800037d0:	00004517          	auipc	a0,0x4
    800037d4:	d8850513          	addi	a0,a0,-632 # 80007558 <etext+0x558>
    800037d8:	84cfd0ef          	jal	80000824 <panic>

00000000800037dc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800037dc:	1141                	addi	sp,sp,-16
    800037de:	e406                	sd	ra,8(sp)
    800037e0:	e022                	sd	s0,0(sp)
    800037e2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800037e4:	411c                	lw	a5,0(a0)
    800037e6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800037e8:	415c                	lw	a5,4(a0)
    800037ea:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800037ec:	04451783          	lh	a5,68(a0)
    800037f0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800037f4:	04a51783          	lh	a5,74(a0)
    800037f8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800037fc:	04c56783          	lwu	a5,76(a0)
    80003800:	e99c                	sd	a5,16(a1)
}
    80003802:	60a2                	ld	ra,8(sp)
    80003804:	6402                	ld	s0,0(sp)
    80003806:	0141                	addi	sp,sp,16
    80003808:	8082                	ret

000000008000380a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000380a:	457c                	lw	a5,76(a0)
    8000380c:	0ed7e663          	bltu	a5,a3,800038f8 <readi+0xee>
{
    80003810:	7159                	addi	sp,sp,-112
    80003812:	f486                	sd	ra,104(sp)
    80003814:	f0a2                	sd	s0,96(sp)
    80003816:	eca6                	sd	s1,88(sp)
    80003818:	e0d2                	sd	s4,64(sp)
    8000381a:	fc56                	sd	s5,56(sp)
    8000381c:	f85a                	sd	s6,48(sp)
    8000381e:	f45e                	sd	s7,40(sp)
    80003820:	1880                	addi	s0,sp,112
    80003822:	8b2a                	mv	s6,a0
    80003824:	8bae                	mv	s7,a1
    80003826:	8a32                	mv	s4,a2
    80003828:	84b6                	mv	s1,a3
    8000382a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000382c:	9f35                	addw	a4,a4,a3
    return 0;
    8000382e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003830:	0ad76b63          	bltu	a4,a3,800038e6 <readi+0xdc>
    80003834:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003836:	00e7f463          	bgeu	a5,a4,8000383e <readi+0x34>
    n = ip->size - off;
    8000383a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000383e:	080a8b63          	beqz	s5,800038d4 <readi+0xca>
    80003842:	e8ca                	sd	s2,80(sp)
    80003844:	f062                	sd	s8,32(sp)
    80003846:	ec66                	sd	s9,24(sp)
    80003848:	e86a                	sd	s10,16(sp)
    8000384a:	e46e                	sd	s11,8(sp)
    8000384c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000384e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003852:	5c7d                	li	s8,-1
    80003854:	a80d                	j	80003886 <readi+0x7c>
    80003856:	020d1d93          	slli	s11,s10,0x20
    8000385a:	020ddd93          	srli	s11,s11,0x20
    8000385e:	05890613          	addi	a2,s2,88
    80003862:	86ee                	mv	a3,s11
    80003864:	963e                	add	a2,a2,a5
    80003866:	85d2                	mv	a1,s4
    80003868:	855e                	mv	a0,s7
    8000386a:	b49fe0ef          	jal	800023b2 <either_copyout>
    8000386e:	05850363          	beq	a0,s8,800038b4 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003872:	854a                	mv	a0,s2
    80003874:	e74ff0ef          	jal	80002ee8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003878:	013d09bb          	addw	s3,s10,s3
    8000387c:	009d04bb          	addw	s1,s10,s1
    80003880:	9a6e                	add	s4,s4,s11
    80003882:	0559f363          	bgeu	s3,s5,800038c8 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003886:	00a4d59b          	srliw	a1,s1,0xa
    8000388a:	855a                	mv	a0,s6
    8000388c:	8bbff0ef          	jal	80003146 <bmap>
    80003890:	85aa                	mv	a1,a0
    if(addr == 0)
    80003892:	c139                	beqz	a0,800038d8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003894:	000b2503          	lw	a0,0(s6)
    80003898:	d48ff0ef          	jal	80002de0 <bread>
    8000389c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000389e:	3ff4f793          	andi	a5,s1,1023
    800038a2:	40fc873b          	subw	a4,s9,a5
    800038a6:	413a86bb          	subw	a3,s5,s3
    800038aa:	8d3a                	mv	s10,a4
    800038ac:	fae6f5e3          	bgeu	a3,a4,80003856 <readi+0x4c>
    800038b0:	8d36                	mv	s10,a3
    800038b2:	b755                	j	80003856 <readi+0x4c>
      brelse(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	e32ff0ef          	jal	80002ee8 <brelse>
      tot = -1;
    800038ba:	59fd                	li	s3,-1
      break;
    800038bc:	6946                	ld	s2,80(sp)
    800038be:	7c02                	ld	s8,32(sp)
    800038c0:	6ce2                	ld	s9,24(sp)
    800038c2:	6d42                	ld	s10,16(sp)
    800038c4:	6da2                	ld	s11,8(sp)
    800038c6:	a831                	j	800038e2 <readi+0xd8>
    800038c8:	6946                	ld	s2,80(sp)
    800038ca:	7c02                	ld	s8,32(sp)
    800038cc:	6ce2                	ld	s9,24(sp)
    800038ce:	6d42                	ld	s10,16(sp)
    800038d0:	6da2                	ld	s11,8(sp)
    800038d2:	a801                	j	800038e2 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038d4:	89d6                	mv	s3,s5
    800038d6:	a031                	j	800038e2 <readi+0xd8>
    800038d8:	6946                	ld	s2,80(sp)
    800038da:	7c02                	ld	s8,32(sp)
    800038dc:	6ce2                	ld	s9,24(sp)
    800038de:	6d42                	ld	s10,16(sp)
    800038e0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800038e2:	854e                	mv	a0,s3
    800038e4:	69a6                	ld	s3,72(sp)
}
    800038e6:	70a6                	ld	ra,104(sp)
    800038e8:	7406                	ld	s0,96(sp)
    800038ea:	64e6                	ld	s1,88(sp)
    800038ec:	6a06                	ld	s4,64(sp)
    800038ee:	7ae2                	ld	s5,56(sp)
    800038f0:	7b42                	ld	s6,48(sp)
    800038f2:	7ba2                	ld	s7,40(sp)
    800038f4:	6165                	addi	sp,sp,112
    800038f6:	8082                	ret
    return 0;
    800038f8:	4501                	li	a0,0
}
    800038fa:	8082                	ret

00000000800038fc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038fc:	457c                	lw	a5,76(a0)
    800038fe:	0ed7eb63          	bltu	a5,a3,800039f4 <writei+0xf8>
{
    80003902:	7159                	addi	sp,sp,-112
    80003904:	f486                	sd	ra,104(sp)
    80003906:	f0a2                	sd	s0,96(sp)
    80003908:	e8ca                	sd	s2,80(sp)
    8000390a:	e0d2                	sd	s4,64(sp)
    8000390c:	fc56                	sd	s5,56(sp)
    8000390e:	f85a                	sd	s6,48(sp)
    80003910:	f45e                	sd	s7,40(sp)
    80003912:	1880                	addi	s0,sp,112
    80003914:	8aaa                	mv	s5,a0
    80003916:	8bae                	mv	s7,a1
    80003918:	8a32                	mv	s4,a2
    8000391a:	8936                	mv	s2,a3
    8000391c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000391e:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003922:	00043737          	lui	a4,0x43
    80003926:	0cf76963          	bltu	a4,a5,800039f8 <writei+0xfc>
    8000392a:	0cd7e763          	bltu	a5,a3,800039f8 <writei+0xfc>
    8000392e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003930:	0a0b0a63          	beqz	s6,800039e4 <writei+0xe8>
    80003934:	eca6                	sd	s1,88(sp)
    80003936:	f062                	sd	s8,32(sp)
    80003938:	ec66                	sd	s9,24(sp)
    8000393a:	e86a                	sd	s10,16(sp)
    8000393c:	e46e                	sd	s11,8(sp)
    8000393e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003940:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003944:	5c7d                	li	s8,-1
    80003946:	a825                	j	8000397e <writei+0x82>
    80003948:	020d1d93          	slli	s11,s10,0x20
    8000394c:	020ddd93          	srli	s11,s11,0x20
    80003950:	05848513          	addi	a0,s1,88
    80003954:	86ee                	mv	a3,s11
    80003956:	8652                	mv	a2,s4
    80003958:	85de                	mv	a1,s7
    8000395a:	953e                	add	a0,a0,a5
    8000395c:	aa1fe0ef          	jal	800023fc <either_copyin>
    80003960:	05850663          	beq	a0,s8,800039ac <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003964:	8526                	mv	a0,s1
    80003966:	6b8000ef          	jal	8000401e <log_write>
    brelse(bp);
    8000396a:	8526                	mv	a0,s1
    8000396c:	d7cff0ef          	jal	80002ee8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003970:	013d09bb          	addw	s3,s10,s3
    80003974:	012d093b          	addw	s2,s10,s2
    80003978:	9a6e                	add	s4,s4,s11
    8000397a:	0369fc63          	bgeu	s3,s6,800039b2 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    8000397e:	00a9559b          	srliw	a1,s2,0xa
    80003982:	8556                	mv	a0,s5
    80003984:	fc2ff0ef          	jal	80003146 <bmap>
    80003988:	85aa                	mv	a1,a0
    if(addr == 0)
    8000398a:	c505                	beqz	a0,800039b2 <writei+0xb6>
    bp = bread(ip->dev, addr);
    8000398c:	000aa503          	lw	a0,0(s5)
    80003990:	c50ff0ef          	jal	80002de0 <bread>
    80003994:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003996:	3ff97793          	andi	a5,s2,1023
    8000399a:	40fc873b          	subw	a4,s9,a5
    8000399e:	413b06bb          	subw	a3,s6,s3
    800039a2:	8d3a                	mv	s10,a4
    800039a4:	fae6f2e3          	bgeu	a3,a4,80003948 <writei+0x4c>
    800039a8:	8d36                	mv	s10,a3
    800039aa:	bf79                	j	80003948 <writei+0x4c>
      brelse(bp);
    800039ac:	8526                	mv	a0,s1
    800039ae:	d3aff0ef          	jal	80002ee8 <brelse>
  }

  if(off > ip->size)
    800039b2:	04caa783          	lw	a5,76(s5)
    800039b6:	0327f963          	bgeu	a5,s2,800039e8 <writei+0xec>
    ip->size = off;
    800039ba:	052aa623          	sw	s2,76(s5)
    800039be:	64e6                	ld	s1,88(sp)
    800039c0:	7c02                	ld	s8,32(sp)
    800039c2:	6ce2                	ld	s9,24(sp)
    800039c4:	6d42                	ld	s10,16(sp)
    800039c6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800039c8:	8556                	mv	a0,s5
    800039ca:	9fbff0ef          	jal	800033c4 <iupdate>

  return tot;
    800039ce:	854e                	mv	a0,s3
    800039d0:	69a6                	ld	s3,72(sp)
}
    800039d2:	70a6                	ld	ra,104(sp)
    800039d4:	7406                	ld	s0,96(sp)
    800039d6:	6946                	ld	s2,80(sp)
    800039d8:	6a06                	ld	s4,64(sp)
    800039da:	7ae2                	ld	s5,56(sp)
    800039dc:	7b42                	ld	s6,48(sp)
    800039de:	7ba2                	ld	s7,40(sp)
    800039e0:	6165                	addi	sp,sp,112
    800039e2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039e4:	89da                	mv	s3,s6
    800039e6:	b7cd                	j	800039c8 <writei+0xcc>
    800039e8:	64e6                	ld	s1,88(sp)
    800039ea:	7c02                	ld	s8,32(sp)
    800039ec:	6ce2                	ld	s9,24(sp)
    800039ee:	6d42                	ld	s10,16(sp)
    800039f0:	6da2                	ld	s11,8(sp)
    800039f2:	bfd9                	j	800039c8 <writei+0xcc>
    return -1;
    800039f4:	557d                	li	a0,-1
}
    800039f6:	8082                	ret
    return -1;
    800039f8:	557d                	li	a0,-1
    800039fa:	bfe1                	j	800039d2 <writei+0xd6>

00000000800039fc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800039fc:	1141                	addi	sp,sp,-16
    800039fe:	e406                	sd	ra,8(sp)
    80003a00:	e022                	sd	s0,0(sp)
    80003a02:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a04:	4639                	li	a2,14
    80003a06:	bc6fd0ef          	jal	80000dcc <strncmp>
}
    80003a0a:	60a2                	ld	ra,8(sp)
    80003a0c:	6402                	ld	s0,0(sp)
    80003a0e:	0141                	addi	sp,sp,16
    80003a10:	8082                	ret

0000000080003a12 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a12:	711d                	addi	sp,sp,-96
    80003a14:	ec86                	sd	ra,88(sp)
    80003a16:	e8a2                	sd	s0,80(sp)
    80003a18:	e4a6                	sd	s1,72(sp)
    80003a1a:	e0ca                	sd	s2,64(sp)
    80003a1c:	fc4e                	sd	s3,56(sp)
    80003a1e:	f852                	sd	s4,48(sp)
    80003a20:	f456                	sd	s5,40(sp)
    80003a22:	f05a                	sd	s6,32(sp)
    80003a24:	ec5e                	sd	s7,24(sp)
    80003a26:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a28:	04451703          	lh	a4,68(a0)
    80003a2c:	4785                	li	a5,1
    80003a2e:	00f71f63          	bne	a4,a5,80003a4c <dirlookup+0x3a>
    80003a32:	892a                	mv	s2,a0
    80003a34:	8aae                	mv	s5,a1
    80003a36:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a38:	457c                	lw	a5,76(a0)
    80003a3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a3c:	fa040a13          	addi	s4,s0,-96
    80003a40:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003a42:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003a46:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a48:	e39d                	bnez	a5,80003a6e <dirlookup+0x5c>
    80003a4a:	a8b9                	j	80003aa8 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003a4c:	00004517          	auipc	a0,0x4
    80003a50:	b2450513          	addi	a0,a0,-1244 # 80007570 <etext+0x570>
    80003a54:	dd1fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80003a58:	00004517          	auipc	a0,0x4
    80003a5c:	b3050513          	addi	a0,a0,-1232 # 80007588 <etext+0x588>
    80003a60:	dc5fc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a64:	24c1                	addiw	s1,s1,16
    80003a66:	04c92783          	lw	a5,76(s2)
    80003a6a:	02f4fe63          	bgeu	s1,a5,80003aa6 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a6e:	874e                	mv	a4,s3
    80003a70:	86a6                	mv	a3,s1
    80003a72:	8652                	mv	a2,s4
    80003a74:	4581                	li	a1,0
    80003a76:	854a                	mv	a0,s2
    80003a78:	d93ff0ef          	jal	8000380a <readi>
    80003a7c:	fd351ee3          	bne	a0,s3,80003a58 <dirlookup+0x46>
    if(de.inum == 0)
    80003a80:	fa045783          	lhu	a5,-96(s0)
    80003a84:	d3e5                	beqz	a5,80003a64 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003a86:	85da                	mv	a1,s6
    80003a88:	8556                	mv	a0,s5
    80003a8a:	f73ff0ef          	jal	800039fc <namecmp>
    80003a8e:	f979                	bnez	a0,80003a64 <dirlookup+0x52>
      if(poff)
    80003a90:	000b8463          	beqz	s7,80003a98 <dirlookup+0x86>
        *poff = off;
    80003a94:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a98:	fa045583          	lhu	a1,-96(s0)
    80003a9c:	00092503          	lw	a0,0(s2)
    80003aa0:	f66ff0ef          	jal	80003206 <iget>
    80003aa4:	a011                	j	80003aa8 <dirlookup+0x96>
  return 0;
    80003aa6:	4501                	li	a0,0
}
    80003aa8:	60e6                	ld	ra,88(sp)
    80003aaa:	6446                	ld	s0,80(sp)
    80003aac:	64a6                	ld	s1,72(sp)
    80003aae:	6906                	ld	s2,64(sp)
    80003ab0:	79e2                	ld	s3,56(sp)
    80003ab2:	7a42                	ld	s4,48(sp)
    80003ab4:	7aa2                	ld	s5,40(sp)
    80003ab6:	7b02                	ld	s6,32(sp)
    80003ab8:	6be2                	ld	s7,24(sp)
    80003aba:	6125                	addi	sp,sp,96
    80003abc:	8082                	ret

0000000080003abe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003abe:	711d                	addi	sp,sp,-96
    80003ac0:	ec86                	sd	ra,88(sp)
    80003ac2:	e8a2                	sd	s0,80(sp)
    80003ac4:	e4a6                	sd	s1,72(sp)
    80003ac6:	e0ca                	sd	s2,64(sp)
    80003ac8:	fc4e                	sd	s3,56(sp)
    80003aca:	f852                	sd	s4,48(sp)
    80003acc:	f456                	sd	s5,40(sp)
    80003ace:	f05a                	sd	s6,32(sp)
    80003ad0:	ec5e                	sd	s7,24(sp)
    80003ad2:	e862                	sd	s8,16(sp)
    80003ad4:	e466                	sd	s9,8(sp)
    80003ad6:	e06a                	sd	s10,0(sp)
    80003ad8:	1080                	addi	s0,sp,96
    80003ada:	84aa                	mv	s1,a0
    80003adc:	8b2e                	mv	s6,a1
    80003ade:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ae0:	00054703          	lbu	a4,0(a0)
    80003ae4:	02f00793          	li	a5,47
    80003ae8:	00f70f63          	beq	a4,a5,80003b06 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003aec:	eadfd0ef          	jal	80001998 <myproc>
    80003af0:	15053503          	ld	a0,336(a0)
    80003af4:	94fff0ef          	jal	80003442 <idup>
    80003af8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003afa:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003afe:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003b00:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b02:	4b85                	li	s7,1
    80003b04:	a879                	j	80003ba2 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b06:	4585                	li	a1,1
    80003b08:	852e                	mv	a0,a1
    80003b0a:	efcff0ef          	jal	80003206 <iget>
    80003b0e:	8a2a                	mv	s4,a0
    80003b10:	b7ed                	j	80003afa <namex+0x3c>
      iunlockput(ip);
    80003b12:	8552                	mv	a0,s4
    80003b14:	b71ff0ef          	jal	80003684 <iunlockput>
      return 0;
    80003b18:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b1a:	8552                	mv	a0,s4
    80003b1c:	60e6                	ld	ra,88(sp)
    80003b1e:	6446                	ld	s0,80(sp)
    80003b20:	64a6                	ld	s1,72(sp)
    80003b22:	6906                	ld	s2,64(sp)
    80003b24:	79e2                	ld	s3,56(sp)
    80003b26:	7a42                	ld	s4,48(sp)
    80003b28:	7aa2                	ld	s5,40(sp)
    80003b2a:	7b02                	ld	s6,32(sp)
    80003b2c:	6be2                	ld	s7,24(sp)
    80003b2e:	6c42                	ld	s8,16(sp)
    80003b30:	6ca2                	ld	s9,8(sp)
    80003b32:	6d02                	ld	s10,0(sp)
    80003b34:	6125                	addi	sp,sp,96
    80003b36:	8082                	ret
      iunlock(ip);
    80003b38:	8552                	mv	a0,s4
    80003b3a:	9edff0ef          	jal	80003526 <iunlock>
      return ip;
    80003b3e:	bff1                	j	80003b1a <namex+0x5c>
      iunlockput(ip);
    80003b40:	8552                	mv	a0,s4
    80003b42:	b43ff0ef          	jal	80003684 <iunlockput>
      return 0;
    80003b46:	8a4a                	mv	s4,s2
    80003b48:	bfc9                	j	80003b1a <namex+0x5c>
  len = path - s;
    80003b4a:	40990633          	sub	a2,s2,s1
    80003b4e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003b52:	09ac5463          	bge	s8,s10,80003bda <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003b56:	8666                	mv	a2,s9
    80003b58:	85a6                	mv	a1,s1
    80003b5a:	8556                	mv	a0,s5
    80003b5c:	9fcfd0ef          	jal	80000d58 <memmove>
    80003b60:	84ca                	mv	s1,s2
  while(*path == '/')
    80003b62:	0004c783          	lbu	a5,0(s1)
    80003b66:	01379763          	bne	a5,s3,80003b74 <namex+0xb6>
    path++;
    80003b6a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b6c:	0004c783          	lbu	a5,0(s1)
    80003b70:	ff378de3          	beq	a5,s3,80003b6a <namex+0xac>
    ilock(ip);
    80003b74:	8552                	mv	a0,s4
    80003b76:	903ff0ef          	jal	80003478 <ilock>
    if(ip->type != T_DIR){
    80003b7a:	044a1783          	lh	a5,68(s4)
    80003b7e:	f9779ae3          	bne	a5,s7,80003b12 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003b82:	000b0563          	beqz	s6,80003b8c <namex+0xce>
    80003b86:	0004c783          	lbu	a5,0(s1)
    80003b8a:	d7dd                	beqz	a5,80003b38 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b8c:	4601                	li	a2,0
    80003b8e:	85d6                	mv	a1,s5
    80003b90:	8552                	mv	a0,s4
    80003b92:	e81ff0ef          	jal	80003a12 <dirlookup>
    80003b96:	892a                	mv	s2,a0
    80003b98:	d545                	beqz	a0,80003b40 <namex+0x82>
    iunlockput(ip);
    80003b9a:	8552                	mv	a0,s4
    80003b9c:	ae9ff0ef          	jal	80003684 <iunlockput>
    ip = next;
    80003ba0:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003ba2:	0004c783          	lbu	a5,0(s1)
    80003ba6:	01379763          	bne	a5,s3,80003bb4 <namex+0xf6>
    path++;
    80003baa:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bac:	0004c783          	lbu	a5,0(s1)
    80003bb0:	ff378de3          	beq	a5,s3,80003baa <namex+0xec>
  if(*path == 0)
    80003bb4:	cf8d                	beqz	a5,80003bee <namex+0x130>
  while(*path != '/' && *path != 0)
    80003bb6:	0004c783          	lbu	a5,0(s1)
    80003bba:	fd178713          	addi	a4,a5,-47
    80003bbe:	cb19                	beqz	a4,80003bd4 <namex+0x116>
    80003bc0:	cb91                	beqz	a5,80003bd4 <namex+0x116>
    80003bc2:	8926                	mv	s2,s1
    path++;
    80003bc4:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003bc6:	00094783          	lbu	a5,0(s2)
    80003bca:	fd178713          	addi	a4,a5,-47
    80003bce:	df35                	beqz	a4,80003b4a <namex+0x8c>
    80003bd0:	fbf5                	bnez	a5,80003bc4 <namex+0x106>
    80003bd2:	bfa5                	j	80003b4a <namex+0x8c>
    80003bd4:	8926                	mv	s2,s1
  len = path - s;
    80003bd6:	4d01                	li	s10,0
    80003bd8:	4601                	li	a2,0
    memmove(name, s, len);
    80003bda:	2601                	sext.w	a2,a2
    80003bdc:	85a6                	mv	a1,s1
    80003bde:	8556                	mv	a0,s5
    80003be0:	978fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003be4:	9d56                	add	s10,s10,s5
    80003be6:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb8d8>
    80003bea:	84ca                	mv	s1,s2
    80003bec:	bf9d                	j	80003b62 <namex+0xa4>
  if(nameiparent){
    80003bee:	f20b06e3          	beqz	s6,80003b1a <namex+0x5c>
    iput(ip);
    80003bf2:	8552                	mv	a0,s4
    80003bf4:	a07ff0ef          	jal	800035fa <iput>
    return 0;
    80003bf8:	4a01                	li	s4,0
    80003bfa:	b705                	j	80003b1a <namex+0x5c>

0000000080003bfc <dirlink>:
{
    80003bfc:	715d                	addi	sp,sp,-80
    80003bfe:	e486                	sd	ra,72(sp)
    80003c00:	e0a2                	sd	s0,64(sp)
    80003c02:	f84a                	sd	s2,48(sp)
    80003c04:	ec56                	sd	s5,24(sp)
    80003c06:	e85a                	sd	s6,16(sp)
    80003c08:	0880                	addi	s0,sp,80
    80003c0a:	892a                	mv	s2,a0
    80003c0c:	8aae                	mv	s5,a1
    80003c0e:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c10:	4601                	li	a2,0
    80003c12:	e01ff0ef          	jal	80003a12 <dirlookup>
    80003c16:	ed1d                	bnez	a0,80003c54 <dirlink+0x58>
    80003c18:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c1a:	04c92483          	lw	s1,76(s2)
    80003c1e:	c4b9                	beqz	s1,80003c6c <dirlink+0x70>
    80003c20:	f44e                	sd	s3,40(sp)
    80003c22:	f052                	sd	s4,32(sp)
    80003c24:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c26:	fb040a13          	addi	s4,s0,-80
    80003c2a:	49c1                	li	s3,16
    80003c2c:	874e                	mv	a4,s3
    80003c2e:	86a6                	mv	a3,s1
    80003c30:	8652                	mv	a2,s4
    80003c32:	4581                	li	a1,0
    80003c34:	854a                	mv	a0,s2
    80003c36:	bd5ff0ef          	jal	8000380a <readi>
    80003c3a:	03351163          	bne	a0,s3,80003c5c <dirlink+0x60>
    if(de.inum == 0)
    80003c3e:	fb045783          	lhu	a5,-80(s0)
    80003c42:	c39d                	beqz	a5,80003c68 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c44:	24c1                	addiw	s1,s1,16
    80003c46:	04c92783          	lw	a5,76(s2)
    80003c4a:	fef4e1e3          	bltu	s1,a5,80003c2c <dirlink+0x30>
    80003c4e:	79a2                	ld	s3,40(sp)
    80003c50:	7a02                	ld	s4,32(sp)
    80003c52:	a829                	j	80003c6c <dirlink+0x70>
    iput(ip);
    80003c54:	9a7ff0ef          	jal	800035fa <iput>
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	a83d                	j	80003c98 <dirlink+0x9c>
      panic("dirlink read");
    80003c5c:	00004517          	auipc	a0,0x4
    80003c60:	93c50513          	addi	a0,a0,-1732 # 80007598 <etext+0x598>
    80003c64:	bc1fc0ef          	jal	80000824 <panic>
    80003c68:	79a2                	ld	s3,40(sp)
    80003c6a:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003c6c:	4639                	li	a2,14
    80003c6e:	85d6                	mv	a1,s5
    80003c70:	fb240513          	addi	a0,s0,-78
    80003c74:	992fd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003c78:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c7c:	4741                	li	a4,16
    80003c7e:	86a6                	mv	a3,s1
    80003c80:	fb040613          	addi	a2,s0,-80
    80003c84:	4581                	li	a1,0
    80003c86:	854a                	mv	a0,s2
    80003c88:	c75ff0ef          	jal	800038fc <writei>
    80003c8c:	1541                	addi	a0,a0,-16
    80003c8e:	00a03533          	snez	a0,a0
    80003c92:	40a0053b          	negw	a0,a0
    80003c96:	74e2                	ld	s1,56(sp)
}
    80003c98:	60a6                	ld	ra,72(sp)
    80003c9a:	6406                	ld	s0,64(sp)
    80003c9c:	7942                	ld	s2,48(sp)
    80003c9e:	6ae2                	ld	s5,24(sp)
    80003ca0:	6b42                	ld	s6,16(sp)
    80003ca2:	6161                	addi	sp,sp,80
    80003ca4:	8082                	ret

0000000080003ca6 <namei>:

struct inode*
namei(char *path)
{
    80003ca6:	1101                	addi	sp,sp,-32
    80003ca8:	ec06                	sd	ra,24(sp)
    80003caa:	e822                	sd	s0,16(sp)
    80003cac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003cae:	fe040613          	addi	a2,s0,-32
    80003cb2:	4581                	li	a1,0
    80003cb4:	e0bff0ef          	jal	80003abe <namex>
}
    80003cb8:	60e2                	ld	ra,24(sp)
    80003cba:	6442                	ld	s0,16(sp)
    80003cbc:	6105                	addi	sp,sp,32
    80003cbe:	8082                	ret

0000000080003cc0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003cc0:	1141                	addi	sp,sp,-16
    80003cc2:	e406                	sd	ra,8(sp)
    80003cc4:	e022                	sd	s0,0(sp)
    80003cc6:	0800                	addi	s0,sp,16
    80003cc8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003cca:	4585                	li	a1,1
    80003ccc:	df3ff0ef          	jal	80003abe <namex>
}
    80003cd0:	60a2                	ld	ra,8(sp)
    80003cd2:	6402                	ld	s0,0(sp)
    80003cd4:	0141                	addi	sp,sp,16
    80003cd6:	8082                	ret

0000000080003cd8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003cd8:	1101                	addi	sp,sp,-32
    80003cda:	ec06                	sd	ra,24(sp)
    80003cdc:	e822                	sd	s0,16(sp)
    80003cde:	e426                	sd	s1,8(sp)
    80003ce0:	e04a                	sd	s2,0(sp)
    80003ce2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ce4:	0001f917          	auipc	s2,0x1f
    80003ce8:	80490913          	addi	s2,s2,-2044 # 800224e8 <log>
    80003cec:	01892583          	lw	a1,24(s2)
    80003cf0:	02492503          	lw	a0,36(s2)
    80003cf4:	8ecff0ef          	jal	80002de0 <bread>
    80003cf8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003cfa:	02892603          	lw	a2,40(s2)
    80003cfe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d00:	00c05f63          	blez	a2,80003d1e <write_head+0x46>
    80003d04:	0001f717          	auipc	a4,0x1f
    80003d08:	81070713          	addi	a4,a4,-2032 # 80022514 <log+0x2c>
    80003d0c:	87aa                	mv	a5,a0
    80003d0e:	060a                	slli	a2,a2,0x2
    80003d10:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d12:	4314                	lw	a3,0(a4)
    80003d14:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d16:	0711                	addi	a4,a4,4
    80003d18:	0791                	addi	a5,a5,4
    80003d1a:	fec79ce3          	bne	a5,a2,80003d12 <write_head+0x3a>
  }
  bwrite(buf);
    80003d1e:	8526                	mv	a0,s1
    80003d20:	996ff0ef          	jal	80002eb6 <bwrite>
  brelse(buf);
    80003d24:	8526                	mv	a0,s1
    80003d26:	9c2ff0ef          	jal	80002ee8 <brelse>
}
    80003d2a:	60e2                	ld	ra,24(sp)
    80003d2c:	6442                	ld	s0,16(sp)
    80003d2e:	64a2                	ld	s1,8(sp)
    80003d30:	6902                	ld	s2,0(sp)
    80003d32:	6105                	addi	sp,sp,32
    80003d34:	8082                	ret

0000000080003d36 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d36:	0001e797          	auipc	a5,0x1e
    80003d3a:	7da7a783          	lw	a5,2010(a5) # 80022510 <log+0x28>
    80003d3e:	0cf05163          	blez	a5,80003e00 <install_trans+0xca>
{
    80003d42:	715d                	addi	sp,sp,-80
    80003d44:	e486                	sd	ra,72(sp)
    80003d46:	e0a2                	sd	s0,64(sp)
    80003d48:	fc26                	sd	s1,56(sp)
    80003d4a:	f84a                	sd	s2,48(sp)
    80003d4c:	f44e                	sd	s3,40(sp)
    80003d4e:	f052                	sd	s4,32(sp)
    80003d50:	ec56                	sd	s5,24(sp)
    80003d52:	e85a                	sd	s6,16(sp)
    80003d54:	e45e                	sd	s7,8(sp)
    80003d56:	e062                	sd	s8,0(sp)
    80003d58:	0880                	addi	s0,sp,80
    80003d5a:	8b2a                	mv	s6,a0
    80003d5c:	0001ea97          	auipc	s5,0x1e
    80003d60:	7b8a8a93          	addi	s5,s5,1976 # 80022514 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d64:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d66:	00004c17          	auipc	s8,0x4
    80003d6a:	842c0c13          	addi	s8,s8,-1982 # 800075a8 <etext+0x5a8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d6e:	0001ea17          	auipc	s4,0x1e
    80003d72:	77aa0a13          	addi	s4,s4,1914 # 800224e8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d76:	40000b93          	li	s7,1024
    80003d7a:	a025                	j	80003da2 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003d7c:	000aa603          	lw	a2,0(s5)
    80003d80:	85ce                	mv	a1,s3
    80003d82:	8562                	mv	a0,s8
    80003d84:	f76fc0ef          	jal	800004fa <printf>
    80003d88:	a839                	j	80003da6 <install_trans+0x70>
    brelse(lbuf);
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	95cff0ef          	jal	80002ee8 <brelse>
    brelse(dbuf);
    80003d90:	8526                	mv	a0,s1
    80003d92:	956ff0ef          	jal	80002ee8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d96:	2985                	addiw	s3,s3,1
    80003d98:	0a91                	addi	s5,s5,4
    80003d9a:	028a2783          	lw	a5,40(s4)
    80003d9e:	04f9d563          	bge	s3,a5,80003de8 <install_trans+0xb2>
    if(recovering) {
    80003da2:	fc0b1de3          	bnez	s6,80003d7c <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003da6:	018a2583          	lw	a1,24(s4)
    80003daa:	013585bb          	addw	a1,a1,s3
    80003dae:	2585                	addiw	a1,a1,1
    80003db0:	024a2503          	lw	a0,36(s4)
    80003db4:	82cff0ef          	jal	80002de0 <bread>
    80003db8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003dba:	000aa583          	lw	a1,0(s5)
    80003dbe:	024a2503          	lw	a0,36(s4)
    80003dc2:	81eff0ef          	jal	80002de0 <bread>
    80003dc6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003dc8:	865e                	mv	a2,s7
    80003dca:	05890593          	addi	a1,s2,88
    80003dce:	05850513          	addi	a0,a0,88
    80003dd2:	f87fc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003dd6:	8526                	mv	a0,s1
    80003dd8:	8deff0ef          	jal	80002eb6 <bwrite>
    if(recovering == 0)
    80003ddc:	fa0b17e3          	bnez	s6,80003d8a <install_trans+0x54>
      bunpin(dbuf);
    80003de0:	8526                	mv	a0,s1
    80003de2:	9beff0ef          	jal	80002fa0 <bunpin>
    80003de6:	b755                	j	80003d8a <install_trans+0x54>
}
    80003de8:	60a6                	ld	ra,72(sp)
    80003dea:	6406                	ld	s0,64(sp)
    80003dec:	74e2                	ld	s1,56(sp)
    80003dee:	7942                	ld	s2,48(sp)
    80003df0:	79a2                	ld	s3,40(sp)
    80003df2:	7a02                	ld	s4,32(sp)
    80003df4:	6ae2                	ld	s5,24(sp)
    80003df6:	6b42                	ld	s6,16(sp)
    80003df8:	6ba2                	ld	s7,8(sp)
    80003dfa:	6c02                	ld	s8,0(sp)
    80003dfc:	6161                	addi	sp,sp,80
    80003dfe:	8082                	ret
    80003e00:	8082                	ret

0000000080003e02 <initlog>:
{
    80003e02:	7179                	addi	sp,sp,-48
    80003e04:	f406                	sd	ra,40(sp)
    80003e06:	f022                	sd	s0,32(sp)
    80003e08:	ec26                	sd	s1,24(sp)
    80003e0a:	e84a                	sd	s2,16(sp)
    80003e0c:	e44e                	sd	s3,8(sp)
    80003e0e:	1800                	addi	s0,sp,48
    80003e10:	84aa                	mv	s1,a0
    80003e12:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e14:	0001e917          	auipc	s2,0x1e
    80003e18:	6d490913          	addi	s2,s2,1748 # 800224e8 <log>
    80003e1c:	00003597          	auipc	a1,0x3
    80003e20:	7ac58593          	addi	a1,a1,1964 # 800075c8 <etext+0x5c8>
    80003e24:	854a                	mv	a0,s2
    80003e26:	d79fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003e2a:	0149a583          	lw	a1,20(s3)
    80003e2e:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e32:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003e36:	8526                	mv	a0,s1
    80003e38:	fa9fe0ef          	jal	80002de0 <bread>
  log.lh.n = lh->n;
    80003e3c:	4d30                	lw	a2,88(a0)
    80003e3e:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003e42:	00c05f63          	blez	a2,80003e60 <initlog+0x5e>
    80003e46:	87aa                	mv	a5,a0
    80003e48:	0001e717          	auipc	a4,0x1e
    80003e4c:	6cc70713          	addi	a4,a4,1740 # 80022514 <log+0x2c>
    80003e50:	060a                	slli	a2,a2,0x2
    80003e52:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003e54:	4ff4                	lw	a3,92(a5)
    80003e56:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e58:	0791                	addi	a5,a5,4
    80003e5a:	0711                	addi	a4,a4,4
    80003e5c:	fec79ce3          	bne	a5,a2,80003e54 <initlog+0x52>
  brelse(buf);
    80003e60:	888ff0ef          	jal	80002ee8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003e64:	4505                	li	a0,1
    80003e66:	ed1ff0ef          	jal	80003d36 <install_trans>
  log.lh.n = 0;
    80003e6a:	0001e797          	auipc	a5,0x1e
    80003e6e:	6a07a323          	sw	zero,1702(a5) # 80022510 <log+0x28>
  write_head(); // clear the log
    80003e72:	e67ff0ef          	jal	80003cd8 <write_head>
}
    80003e76:	70a2                	ld	ra,40(sp)
    80003e78:	7402                	ld	s0,32(sp)
    80003e7a:	64e2                	ld	s1,24(sp)
    80003e7c:	6942                	ld	s2,16(sp)
    80003e7e:	69a2                	ld	s3,8(sp)
    80003e80:	6145                	addi	sp,sp,48
    80003e82:	8082                	ret

0000000080003e84 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003e84:	1101                	addi	sp,sp,-32
    80003e86:	ec06                	sd	ra,24(sp)
    80003e88:	e822                	sd	s0,16(sp)
    80003e8a:	e426                	sd	s1,8(sp)
    80003e8c:	e04a                	sd	s2,0(sp)
    80003e8e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e90:	0001e517          	auipc	a0,0x1e
    80003e94:	65850513          	addi	a0,a0,1624 # 800224e8 <log>
    80003e98:	d91fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003e9c:	0001e497          	auipc	s1,0x1e
    80003ea0:	64c48493          	addi	s1,s1,1612 # 800224e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ea4:	4979                	li	s2,30
    80003ea6:	a029                	j	80003eb0 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ea8:	85a6                	mv	a1,s1
    80003eaa:	8526                	mv	a0,s1
    80003eac:	9acfe0ef          	jal	80002058 <sleep>
    if(log.committing){
    80003eb0:	509c                	lw	a5,32(s1)
    80003eb2:	fbfd                	bnez	a5,80003ea8 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003eb4:	4cd8                	lw	a4,28(s1)
    80003eb6:	2705                	addiw	a4,a4,1
    80003eb8:	0027179b          	slliw	a5,a4,0x2
    80003ebc:	9fb9                	addw	a5,a5,a4
    80003ebe:	0017979b          	slliw	a5,a5,0x1
    80003ec2:	5494                	lw	a3,40(s1)
    80003ec4:	9fb5                	addw	a5,a5,a3
    80003ec6:	00f95763          	bge	s2,a5,80003ed4 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003eca:	85a6                	mv	a1,s1
    80003ecc:	8526                	mv	a0,s1
    80003ece:	98afe0ef          	jal	80002058 <sleep>
    80003ed2:	bff9                	j	80003eb0 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003ed4:	0001e797          	auipc	a5,0x1e
    80003ed8:	62e7a823          	sw	a4,1584(a5) # 80022504 <log+0x1c>
      release(&log.lock);
    80003edc:	0001e517          	auipc	a0,0x1e
    80003ee0:	60c50513          	addi	a0,a0,1548 # 800224e8 <log>
    80003ee4:	dd9fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003ee8:	60e2                	ld	ra,24(sp)
    80003eea:	6442                	ld	s0,16(sp)
    80003eec:	64a2                	ld	s1,8(sp)
    80003eee:	6902                	ld	s2,0(sp)
    80003ef0:	6105                	addi	sp,sp,32
    80003ef2:	8082                	ret

0000000080003ef4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003ef4:	7139                	addi	sp,sp,-64
    80003ef6:	fc06                	sd	ra,56(sp)
    80003ef8:	f822                	sd	s0,48(sp)
    80003efa:	f426                	sd	s1,40(sp)
    80003efc:	f04a                	sd	s2,32(sp)
    80003efe:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f00:	0001e497          	auipc	s1,0x1e
    80003f04:	5e848493          	addi	s1,s1,1512 # 800224e8 <log>
    80003f08:	8526                	mv	a0,s1
    80003f0a:	d1ffc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003f0e:	4cdc                	lw	a5,28(s1)
    80003f10:	37fd                	addiw	a5,a5,-1
    80003f12:	893e                	mv	s2,a5
    80003f14:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f16:	509c                	lw	a5,32(s1)
    80003f18:	e7b1                	bnez	a5,80003f64 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f1a:	04091e63          	bnez	s2,80003f76 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003f1e:	0001e497          	auipc	s1,0x1e
    80003f22:	5ca48493          	addi	s1,s1,1482 # 800224e8 <log>
    80003f26:	4785                	li	a5,1
    80003f28:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f2a:	8526                	mv	a0,s1
    80003f2c:	d91fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f30:	549c                	lw	a5,40(s1)
    80003f32:	06f04463          	bgtz	a5,80003f9a <end_op+0xa6>
    acquire(&log.lock);
    80003f36:	0001e517          	auipc	a0,0x1e
    80003f3a:	5b250513          	addi	a0,a0,1458 # 800224e8 <log>
    80003f3e:	cebfc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003f42:	0001e797          	auipc	a5,0x1e
    80003f46:	5c07a323          	sw	zero,1478(a5) # 80022508 <log+0x20>
    wakeup(&log);
    80003f4a:	0001e517          	auipc	a0,0x1e
    80003f4e:	59e50513          	addi	a0,a0,1438 # 800224e8 <log>
    80003f52:	952fe0ef          	jal	800020a4 <wakeup>
    release(&log.lock);
    80003f56:	0001e517          	auipc	a0,0x1e
    80003f5a:	59250513          	addi	a0,a0,1426 # 800224e8 <log>
    80003f5e:	d5ffc0ef          	jal	80000cbc <release>
}
    80003f62:	a035                	j	80003f8e <end_op+0x9a>
    80003f64:	ec4e                	sd	s3,24(sp)
    80003f66:	e852                	sd	s4,16(sp)
    80003f68:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003f6a:	00003517          	auipc	a0,0x3
    80003f6e:	66650513          	addi	a0,a0,1638 # 800075d0 <etext+0x5d0>
    80003f72:	8b3fc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003f76:	0001e517          	auipc	a0,0x1e
    80003f7a:	57250513          	addi	a0,a0,1394 # 800224e8 <log>
    80003f7e:	926fe0ef          	jal	800020a4 <wakeup>
  release(&log.lock);
    80003f82:	0001e517          	auipc	a0,0x1e
    80003f86:	56650513          	addi	a0,a0,1382 # 800224e8 <log>
    80003f8a:	d33fc0ef          	jal	80000cbc <release>
}
    80003f8e:	70e2                	ld	ra,56(sp)
    80003f90:	7442                	ld	s0,48(sp)
    80003f92:	74a2                	ld	s1,40(sp)
    80003f94:	7902                	ld	s2,32(sp)
    80003f96:	6121                	addi	sp,sp,64
    80003f98:	8082                	ret
    80003f9a:	ec4e                	sd	s3,24(sp)
    80003f9c:	e852                	sd	s4,16(sp)
    80003f9e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fa0:	0001ea97          	auipc	s5,0x1e
    80003fa4:	574a8a93          	addi	s5,s5,1396 # 80022514 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003fa8:	0001ea17          	auipc	s4,0x1e
    80003fac:	540a0a13          	addi	s4,s4,1344 # 800224e8 <log>
    80003fb0:	018a2583          	lw	a1,24(s4)
    80003fb4:	012585bb          	addw	a1,a1,s2
    80003fb8:	2585                	addiw	a1,a1,1
    80003fba:	024a2503          	lw	a0,36(s4)
    80003fbe:	e23fe0ef          	jal	80002de0 <bread>
    80003fc2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003fc4:	000aa583          	lw	a1,0(s5)
    80003fc8:	024a2503          	lw	a0,36(s4)
    80003fcc:	e15fe0ef          	jal	80002de0 <bread>
    80003fd0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003fd2:	40000613          	li	a2,1024
    80003fd6:	05850593          	addi	a1,a0,88
    80003fda:	05848513          	addi	a0,s1,88
    80003fde:	d7bfc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	ed3fe0ef          	jal	80002eb6 <bwrite>
    brelse(from);
    80003fe8:	854e                	mv	a0,s3
    80003fea:	efffe0ef          	jal	80002ee8 <brelse>
    brelse(to);
    80003fee:	8526                	mv	a0,s1
    80003ff0:	ef9fe0ef          	jal	80002ee8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff4:	2905                	addiw	s2,s2,1
    80003ff6:	0a91                	addi	s5,s5,4
    80003ff8:	028a2783          	lw	a5,40(s4)
    80003ffc:	faf94ae3          	blt	s2,a5,80003fb0 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004000:	cd9ff0ef          	jal	80003cd8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004004:	4501                	li	a0,0
    80004006:	d31ff0ef          	jal	80003d36 <install_trans>
    log.lh.n = 0;
    8000400a:	0001e797          	auipc	a5,0x1e
    8000400e:	5007a323          	sw	zero,1286(a5) # 80022510 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004012:	cc7ff0ef          	jal	80003cd8 <write_head>
    80004016:	69e2                	ld	s3,24(sp)
    80004018:	6a42                	ld	s4,16(sp)
    8000401a:	6aa2                	ld	s5,8(sp)
    8000401c:	bf29                	j	80003f36 <end_op+0x42>

000000008000401e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000401e:	1101                	addi	sp,sp,-32
    80004020:	ec06                	sd	ra,24(sp)
    80004022:	e822                	sd	s0,16(sp)
    80004024:	e426                	sd	s1,8(sp)
    80004026:	1000                	addi	s0,sp,32
    80004028:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000402a:	0001e517          	auipc	a0,0x1e
    8000402e:	4be50513          	addi	a0,a0,1214 # 800224e8 <log>
    80004032:	bf7fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004036:	0001e617          	auipc	a2,0x1e
    8000403a:	4da62603          	lw	a2,1242(a2) # 80022510 <log+0x28>
    8000403e:	47f5                	li	a5,29
    80004040:	04c7cd63          	blt	a5,a2,8000409a <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004044:	0001e797          	auipc	a5,0x1e
    80004048:	4c07a783          	lw	a5,1216(a5) # 80022504 <log+0x1c>
    8000404c:	04f05d63          	blez	a5,800040a6 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004050:	4781                	li	a5,0
    80004052:	06c05063          	blez	a2,800040b2 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004056:	44cc                	lw	a1,12(s1)
    80004058:	0001e717          	auipc	a4,0x1e
    8000405c:	4bc70713          	addi	a4,a4,1212 # 80022514 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004060:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004062:	4314                	lw	a3,0(a4)
    80004064:	04b68763          	beq	a3,a1,800040b2 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004068:	2785                	addiw	a5,a5,1
    8000406a:	0711                	addi	a4,a4,4
    8000406c:	fef61be3          	bne	a2,a5,80004062 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004070:	060a                	slli	a2,a2,0x2
    80004072:	02060613          	addi	a2,a2,32
    80004076:	0001e797          	auipc	a5,0x1e
    8000407a:	47278793          	addi	a5,a5,1138 # 800224e8 <log>
    8000407e:	97b2                	add	a5,a5,a2
    80004080:	44d8                	lw	a4,12(s1)
    80004082:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004084:	8526                	mv	a0,s1
    80004086:	ee7fe0ef          	jal	80002f6c <bpin>
    log.lh.n++;
    8000408a:	0001e717          	auipc	a4,0x1e
    8000408e:	45e70713          	addi	a4,a4,1118 # 800224e8 <log>
    80004092:	571c                	lw	a5,40(a4)
    80004094:	2785                	addiw	a5,a5,1
    80004096:	d71c                	sw	a5,40(a4)
    80004098:	a815                	j	800040cc <log_write+0xae>
    panic("too big a transaction");
    8000409a:	00003517          	auipc	a0,0x3
    8000409e:	54650513          	addi	a0,a0,1350 # 800075e0 <etext+0x5e0>
    800040a2:	f82fc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    800040a6:	00003517          	auipc	a0,0x3
    800040aa:	55250513          	addi	a0,a0,1362 # 800075f8 <etext+0x5f8>
    800040ae:	f76fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    800040b2:	00279693          	slli	a3,a5,0x2
    800040b6:	02068693          	addi	a3,a3,32
    800040ba:	0001e717          	auipc	a4,0x1e
    800040be:	42e70713          	addi	a4,a4,1070 # 800224e8 <log>
    800040c2:	9736                	add	a4,a4,a3
    800040c4:	44d4                	lw	a3,12(s1)
    800040c6:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800040c8:	faf60ee3          	beq	a2,a5,80004084 <log_write+0x66>
  }
  release(&log.lock);
    800040cc:	0001e517          	auipc	a0,0x1e
    800040d0:	41c50513          	addi	a0,a0,1052 # 800224e8 <log>
    800040d4:	be9fc0ef          	jal	80000cbc <release>
}
    800040d8:	60e2                	ld	ra,24(sp)
    800040da:	6442                	ld	s0,16(sp)
    800040dc:	64a2                	ld	s1,8(sp)
    800040de:	6105                	addi	sp,sp,32
    800040e0:	8082                	ret

00000000800040e2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040e2:	1101                	addi	sp,sp,-32
    800040e4:	ec06                	sd	ra,24(sp)
    800040e6:	e822                	sd	s0,16(sp)
    800040e8:	e426                	sd	s1,8(sp)
    800040ea:	e04a                	sd	s2,0(sp)
    800040ec:	1000                	addi	s0,sp,32
    800040ee:	84aa                	mv	s1,a0
    800040f0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040f2:	00003597          	auipc	a1,0x3
    800040f6:	52658593          	addi	a1,a1,1318 # 80007618 <etext+0x618>
    800040fa:	0521                	addi	a0,a0,8
    800040fc:	aa3fc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004100:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004104:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004108:	0204a423          	sw	zero,40(s1)
}
    8000410c:	60e2                	ld	ra,24(sp)
    8000410e:	6442                	ld	s0,16(sp)
    80004110:	64a2                	ld	s1,8(sp)
    80004112:	6902                	ld	s2,0(sp)
    80004114:	6105                	addi	sp,sp,32
    80004116:	8082                	ret

0000000080004118 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004118:	1101                	addi	sp,sp,-32
    8000411a:	ec06                	sd	ra,24(sp)
    8000411c:	e822                	sd	s0,16(sp)
    8000411e:	e426                	sd	s1,8(sp)
    80004120:	e04a                	sd	s2,0(sp)
    80004122:	1000                	addi	s0,sp,32
    80004124:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004126:	00850913          	addi	s2,a0,8
    8000412a:	854a                	mv	a0,s2
    8000412c:	afdfc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    80004130:	409c                	lw	a5,0(s1)
    80004132:	c799                	beqz	a5,80004140 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004134:	85ca                	mv	a1,s2
    80004136:	8526                	mv	a0,s1
    80004138:	f21fd0ef          	jal	80002058 <sleep>
  while (lk->locked) {
    8000413c:	409c                	lw	a5,0(s1)
    8000413e:	fbfd                	bnez	a5,80004134 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004140:	4785                	li	a5,1
    80004142:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004144:	855fd0ef          	jal	80001998 <myproc>
    80004148:	591c                	lw	a5,48(a0)
    8000414a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000414c:	854a                	mv	a0,s2
    8000414e:	b6ffc0ef          	jal	80000cbc <release>
}
    80004152:	60e2                	ld	ra,24(sp)
    80004154:	6442                	ld	s0,16(sp)
    80004156:	64a2                	ld	s1,8(sp)
    80004158:	6902                	ld	s2,0(sp)
    8000415a:	6105                	addi	sp,sp,32
    8000415c:	8082                	ret

000000008000415e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000415e:	1101                	addi	sp,sp,-32
    80004160:	ec06                	sd	ra,24(sp)
    80004162:	e822                	sd	s0,16(sp)
    80004164:	e426                	sd	s1,8(sp)
    80004166:	e04a                	sd	s2,0(sp)
    80004168:	1000                	addi	s0,sp,32
    8000416a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000416c:	00850913          	addi	s2,a0,8
    80004170:	854a                	mv	a0,s2
    80004172:	ab7fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    80004176:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000417a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000417e:	8526                	mv	a0,s1
    80004180:	f25fd0ef          	jal	800020a4 <wakeup>
  release(&lk->lk);
    80004184:	854a                	mv	a0,s2
    80004186:	b37fc0ef          	jal	80000cbc <release>
}
    8000418a:	60e2                	ld	ra,24(sp)
    8000418c:	6442                	ld	s0,16(sp)
    8000418e:	64a2                	ld	s1,8(sp)
    80004190:	6902                	ld	s2,0(sp)
    80004192:	6105                	addi	sp,sp,32
    80004194:	8082                	ret

0000000080004196 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004196:	7179                	addi	sp,sp,-48
    80004198:	f406                	sd	ra,40(sp)
    8000419a:	f022                	sd	s0,32(sp)
    8000419c:	ec26                	sd	s1,24(sp)
    8000419e:	e84a                	sd	s2,16(sp)
    800041a0:	1800                	addi	s0,sp,48
    800041a2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800041a4:	00850913          	addi	s2,a0,8
    800041a8:	854a                	mv	a0,s2
    800041aa:	a7ffc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041ae:	409c                	lw	a5,0(s1)
    800041b0:	ef81                	bnez	a5,800041c8 <holdingsleep+0x32>
    800041b2:	4481                	li	s1,0
  release(&lk->lk);
    800041b4:	854a                	mv	a0,s2
    800041b6:	b07fc0ef          	jal	80000cbc <release>
  return r;
}
    800041ba:	8526                	mv	a0,s1
    800041bc:	70a2                	ld	ra,40(sp)
    800041be:	7402                	ld	s0,32(sp)
    800041c0:	64e2                	ld	s1,24(sp)
    800041c2:	6942                	ld	s2,16(sp)
    800041c4:	6145                	addi	sp,sp,48
    800041c6:	8082                	ret
    800041c8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041ca:	0284a983          	lw	s3,40(s1)
    800041ce:	fcafd0ef          	jal	80001998 <myproc>
    800041d2:	5904                	lw	s1,48(a0)
    800041d4:	413484b3          	sub	s1,s1,s3
    800041d8:	0014b493          	seqz	s1,s1
    800041dc:	69a2                	ld	s3,8(sp)
    800041de:	bfd9                	j	800041b4 <holdingsleep+0x1e>

00000000800041e0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041e0:	1141                	addi	sp,sp,-16
    800041e2:	e406                	sd	ra,8(sp)
    800041e4:	e022                	sd	s0,0(sp)
    800041e6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041e8:	00003597          	auipc	a1,0x3
    800041ec:	44058593          	addi	a1,a1,1088 # 80007628 <etext+0x628>
    800041f0:	0001e517          	auipc	a0,0x1e
    800041f4:	44050513          	addi	a0,a0,1088 # 80022630 <ftable>
    800041f8:	9a7fc0ef          	jal	80000b9e <initlock>
}
    800041fc:	60a2                	ld	ra,8(sp)
    800041fe:	6402                	ld	s0,0(sp)
    80004200:	0141                	addi	sp,sp,16
    80004202:	8082                	ret

0000000080004204 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004204:	1101                	addi	sp,sp,-32
    80004206:	ec06                	sd	ra,24(sp)
    80004208:	e822                	sd	s0,16(sp)
    8000420a:	e426                	sd	s1,8(sp)
    8000420c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000420e:	0001e517          	auipc	a0,0x1e
    80004212:	42250513          	addi	a0,a0,1058 # 80022630 <ftable>
    80004216:	a13fc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000421a:	0001e497          	auipc	s1,0x1e
    8000421e:	42e48493          	addi	s1,s1,1070 # 80022648 <ftable+0x18>
    80004222:	0001f717          	auipc	a4,0x1f
    80004226:	3c670713          	addi	a4,a4,966 # 800235e8 <disk>
    if(f->ref == 0){
    8000422a:	40dc                	lw	a5,4(s1)
    8000422c:	cf89                	beqz	a5,80004246 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000422e:	02848493          	addi	s1,s1,40
    80004232:	fee49ce3          	bne	s1,a4,8000422a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004236:	0001e517          	auipc	a0,0x1e
    8000423a:	3fa50513          	addi	a0,a0,1018 # 80022630 <ftable>
    8000423e:	a7ffc0ef          	jal	80000cbc <release>
  return 0;
    80004242:	4481                	li	s1,0
    80004244:	a809                	j	80004256 <filealloc+0x52>
      f->ref = 1;
    80004246:	4785                	li	a5,1
    80004248:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000424a:	0001e517          	auipc	a0,0x1e
    8000424e:	3e650513          	addi	a0,a0,998 # 80022630 <ftable>
    80004252:	a6bfc0ef          	jal	80000cbc <release>
}
    80004256:	8526                	mv	a0,s1
    80004258:	60e2                	ld	ra,24(sp)
    8000425a:	6442                	ld	s0,16(sp)
    8000425c:	64a2                	ld	s1,8(sp)
    8000425e:	6105                	addi	sp,sp,32
    80004260:	8082                	ret

0000000080004262 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004262:	1101                	addi	sp,sp,-32
    80004264:	ec06                	sd	ra,24(sp)
    80004266:	e822                	sd	s0,16(sp)
    80004268:	e426                	sd	s1,8(sp)
    8000426a:	1000                	addi	s0,sp,32
    8000426c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000426e:	0001e517          	auipc	a0,0x1e
    80004272:	3c250513          	addi	a0,a0,962 # 80022630 <ftable>
    80004276:	9b3fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    8000427a:	40dc                	lw	a5,4(s1)
    8000427c:	02f05063          	blez	a5,8000429c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004280:	2785                	addiw	a5,a5,1
    80004282:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004284:	0001e517          	auipc	a0,0x1e
    80004288:	3ac50513          	addi	a0,a0,940 # 80022630 <ftable>
    8000428c:	a31fc0ef          	jal	80000cbc <release>
  return f;
}
    80004290:	8526                	mv	a0,s1
    80004292:	60e2                	ld	ra,24(sp)
    80004294:	6442                	ld	s0,16(sp)
    80004296:	64a2                	ld	s1,8(sp)
    80004298:	6105                	addi	sp,sp,32
    8000429a:	8082                	ret
    panic("filedup");
    8000429c:	00003517          	auipc	a0,0x3
    800042a0:	39450513          	addi	a0,a0,916 # 80007630 <etext+0x630>
    800042a4:	d80fc0ef          	jal	80000824 <panic>

00000000800042a8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042a8:	7139                	addi	sp,sp,-64
    800042aa:	fc06                	sd	ra,56(sp)
    800042ac:	f822                	sd	s0,48(sp)
    800042ae:	f426                	sd	s1,40(sp)
    800042b0:	0080                	addi	s0,sp,64
    800042b2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042b4:	0001e517          	auipc	a0,0x1e
    800042b8:	37c50513          	addi	a0,a0,892 # 80022630 <ftable>
    800042bc:	96dfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800042c0:	40dc                	lw	a5,4(s1)
    800042c2:	04f05a63          	blez	a5,80004316 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800042c6:	37fd                	addiw	a5,a5,-1
    800042c8:	c0dc                	sw	a5,4(s1)
    800042ca:	06f04063          	bgtz	a5,8000432a <fileclose+0x82>
    800042ce:	f04a                	sd	s2,32(sp)
    800042d0:	ec4e                	sd	s3,24(sp)
    800042d2:	e852                	sd	s4,16(sp)
    800042d4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042d6:	0004a903          	lw	s2,0(s1)
    800042da:	0094c783          	lbu	a5,9(s1)
    800042de:	89be                	mv	s3,a5
    800042e0:	689c                	ld	a5,16(s1)
    800042e2:	8a3e                	mv	s4,a5
    800042e4:	6c9c                	ld	a5,24(s1)
    800042e6:	8abe                	mv	s5,a5
  f->ref = 0;
    800042e8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042ec:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042f0:	0001e517          	auipc	a0,0x1e
    800042f4:	34050513          	addi	a0,a0,832 # 80022630 <ftable>
    800042f8:	9c5fc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    800042fc:	4785                	li	a5,1
    800042fe:	04f90163          	beq	s2,a5,80004340 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004302:	ffe9079b          	addiw	a5,s2,-2
    80004306:	4705                	li	a4,1
    80004308:	04f77563          	bgeu	a4,a5,80004352 <fileclose+0xaa>
    8000430c:	7902                	ld	s2,32(sp)
    8000430e:	69e2                	ld	s3,24(sp)
    80004310:	6a42                	ld	s4,16(sp)
    80004312:	6aa2                	ld	s5,8(sp)
    80004314:	a00d                	j	80004336 <fileclose+0x8e>
    80004316:	f04a                	sd	s2,32(sp)
    80004318:	ec4e                	sd	s3,24(sp)
    8000431a:	e852                	sd	s4,16(sp)
    8000431c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000431e:	00003517          	auipc	a0,0x3
    80004322:	31a50513          	addi	a0,a0,794 # 80007638 <etext+0x638>
    80004326:	cfefc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    8000432a:	0001e517          	auipc	a0,0x1e
    8000432e:	30650513          	addi	a0,a0,774 # 80022630 <ftable>
    80004332:	98bfc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004336:	70e2                	ld	ra,56(sp)
    80004338:	7442                	ld	s0,48(sp)
    8000433a:	74a2                	ld	s1,40(sp)
    8000433c:	6121                	addi	sp,sp,64
    8000433e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004340:	85ce                	mv	a1,s3
    80004342:	8552                	mv	a0,s4
    80004344:	380000ef          	jal	800046c4 <pipeclose>
    80004348:	7902                	ld	s2,32(sp)
    8000434a:	69e2                	ld	s3,24(sp)
    8000434c:	6a42                	ld	s4,16(sp)
    8000434e:	6aa2                	ld	s5,8(sp)
    80004350:	b7dd                	j	80004336 <fileclose+0x8e>
    begin_op();
    80004352:	b33ff0ef          	jal	80003e84 <begin_op>
    iput(ff.ip);
    80004356:	8556                	mv	a0,s5
    80004358:	aa2ff0ef          	jal	800035fa <iput>
    end_op();
    8000435c:	b99ff0ef          	jal	80003ef4 <end_op>
    80004360:	7902                	ld	s2,32(sp)
    80004362:	69e2                	ld	s3,24(sp)
    80004364:	6a42                	ld	s4,16(sp)
    80004366:	6aa2                	ld	s5,8(sp)
    80004368:	b7f9                	j	80004336 <fileclose+0x8e>

000000008000436a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000436a:	715d                	addi	sp,sp,-80
    8000436c:	e486                	sd	ra,72(sp)
    8000436e:	e0a2                	sd	s0,64(sp)
    80004370:	fc26                	sd	s1,56(sp)
    80004372:	f052                	sd	s4,32(sp)
    80004374:	0880                	addi	s0,sp,80
    80004376:	84aa                	mv	s1,a0
    80004378:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000437a:	e1efd0ef          	jal	80001998 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000437e:	409c                	lw	a5,0(s1)
    80004380:	37f9                	addiw	a5,a5,-2
    80004382:	4705                	li	a4,1
    80004384:	04f76263          	bltu	a4,a5,800043c8 <filestat+0x5e>
    80004388:	f84a                	sd	s2,48(sp)
    8000438a:	f44e                	sd	s3,40(sp)
    8000438c:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000438e:	6c88                	ld	a0,24(s1)
    80004390:	8e8ff0ef          	jal	80003478 <ilock>
    stati(f->ip, &st);
    80004394:	fb840913          	addi	s2,s0,-72
    80004398:	85ca                	mv	a1,s2
    8000439a:	6c88                	ld	a0,24(s1)
    8000439c:	c40ff0ef          	jal	800037dc <stati>
    iunlock(f->ip);
    800043a0:	6c88                	ld	a0,24(s1)
    800043a2:	984ff0ef          	jal	80003526 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800043a6:	46e1                	li	a3,24
    800043a8:	864a                	mv	a2,s2
    800043aa:	85d2                	mv	a1,s4
    800043ac:	0509b503          	ld	a0,80(s3)
    800043b0:	aa4fd0ef          	jal	80001654 <copyout>
    800043b4:	41f5551b          	sraiw	a0,a0,0x1f
    800043b8:	7942                	ld	s2,48(sp)
    800043ba:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043bc:	60a6                	ld	ra,72(sp)
    800043be:	6406                	ld	s0,64(sp)
    800043c0:	74e2                	ld	s1,56(sp)
    800043c2:	7a02                	ld	s4,32(sp)
    800043c4:	6161                	addi	sp,sp,80
    800043c6:	8082                	ret
  return -1;
    800043c8:	557d                	li	a0,-1
    800043ca:	bfcd                	j	800043bc <filestat+0x52>

00000000800043cc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043cc:	7179                	addi	sp,sp,-48
    800043ce:	f406                	sd	ra,40(sp)
    800043d0:	f022                	sd	s0,32(sp)
    800043d2:	e84a                	sd	s2,16(sp)
    800043d4:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800043d6:	00854783          	lbu	a5,8(a0)
    800043da:	cfd1                	beqz	a5,80004476 <fileread+0xaa>
    800043dc:	ec26                	sd	s1,24(sp)
    800043de:	e44e                	sd	s3,8(sp)
    800043e0:	84aa                	mv	s1,a0
    800043e2:	892e                	mv	s2,a1
    800043e4:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800043e6:	411c                	lw	a5,0(a0)
    800043e8:	4705                	li	a4,1
    800043ea:	04e78363          	beq	a5,a4,80004430 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800043ee:	470d                	li	a4,3
    800043f0:	04e78763          	beq	a5,a4,8000443e <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800043f4:	4709                	li	a4,2
    800043f6:	06e79a63          	bne	a5,a4,8000446a <fileread+0x9e>
    ilock(f->ip);
    800043fa:	6d08                	ld	a0,24(a0)
    800043fc:	87cff0ef          	jal	80003478 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004400:	874e                	mv	a4,s3
    80004402:	5094                	lw	a3,32(s1)
    80004404:	864a                	mv	a2,s2
    80004406:	4585                	li	a1,1
    80004408:	6c88                	ld	a0,24(s1)
    8000440a:	c00ff0ef          	jal	8000380a <readi>
    8000440e:	892a                	mv	s2,a0
    80004410:	00a05563          	blez	a0,8000441a <fileread+0x4e>
      f->off += r;
    80004414:	509c                	lw	a5,32(s1)
    80004416:	9fa9                	addw	a5,a5,a0
    80004418:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000441a:	6c88                	ld	a0,24(s1)
    8000441c:	90aff0ef          	jal	80003526 <iunlock>
    80004420:	64e2                	ld	s1,24(sp)
    80004422:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004424:	854a                	mv	a0,s2
    80004426:	70a2                	ld	ra,40(sp)
    80004428:	7402                	ld	s0,32(sp)
    8000442a:	6942                	ld	s2,16(sp)
    8000442c:	6145                	addi	sp,sp,48
    8000442e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004430:	6908                	ld	a0,16(a0)
    80004432:	3f8000ef          	jal	8000482a <piperead>
    80004436:	892a                	mv	s2,a0
    80004438:	64e2                	ld	s1,24(sp)
    8000443a:	69a2                	ld	s3,8(sp)
    8000443c:	b7e5                	j	80004424 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000443e:	02451783          	lh	a5,36(a0)
    80004442:	03079693          	slli	a3,a5,0x30
    80004446:	92c1                	srli	a3,a3,0x30
    80004448:	4725                	li	a4,9
    8000444a:	02d76963          	bltu	a4,a3,8000447c <fileread+0xb0>
    8000444e:	0792                	slli	a5,a5,0x4
    80004450:	0001e717          	auipc	a4,0x1e
    80004454:	14070713          	addi	a4,a4,320 # 80022590 <devsw>
    80004458:	97ba                	add	a5,a5,a4
    8000445a:	639c                	ld	a5,0(a5)
    8000445c:	c78d                	beqz	a5,80004486 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    8000445e:	4505                	li	a0,1
    80004460:	9782                	jalr	a5
    80004462:	892a                	mv	s2,a0
    80004464:	64e2                	ld	s1,24(sp)
    80004466:	69a2                	ld	s3,8(sp)
    80004468:	bf75                	j	80004424 <fileread+0x58>
    panic("fileread");
    8000446a:	00003517          	auipc	a0,0x3
    8000446e:	1de50513          	addi	a0,a0,478 # 80007648 <etext+0x648>
    80004472:	bb2fc0ef          	jal	80000824 <panic>
    return -1;
    80004476:	57fd                	li	a5,-1
    80004478:	893e                	mv	s2,a5
    8000447a:	b76d                	j	80004424 <fileread+0x58>
      return -1;
    8000447c:	57fd                	li	a5,-1
    8000447e:	893e                	mv	s2,a5
    80004480:	64e2                	ld	s1,24(sp)
    80004482:	69a2                	ld	s3,8(sp)
    80004484:	b745                	j	80004424 <fileread+0x58>
    80004486:	57fd                	li	a5,-1
    80004488:	893e                	mv	s2,a5
    8000448a:	64e2                	ld	s1,24(sp)
    8000448c:	69a2                	ld	s3,8(sp)
    8000448e:	bf59                	j	80004424 <fileread+0x58>

0000000080004490 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004490:	00954783          	lbu	a5,9(a0)
    80004494:	10078f63          	beqz	a5,800045b2 <filewrite+0x122>
{
    80004498:	711d                	addi	sp,sp,-96
    8000449a:	ec86                	sd	ra,88(sp)
    8000449c:	e8a2                	sd	s0,80(sp)
    8000449e:	e0ca                	sd	s2,64(sp)
    800044a0:	f456                	sd	s5,40(sp)
    800044a2:	f05a                	sd	s6,32(sp)
    800044a4:	1080                	addi	s0,sp,96
    800044a6:	892a                	mv	s2,a0
    800044a8:	8b2e                	mv	s6,a1
    800044aa:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800044ac:	411c                	lw	a5,0(a0)
    800044ae:	4705                	li	a4,1
    800044b0:	02e78a63          	beq	a5,a4,800044e4 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800044b4:	470d                	li	a4,3
    800044b6:	02e78b63          	beq	a5,a4,800044ec <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800044ba:	4709                	li	a4,2
    800044bc:	0ce79f63          	bne	a5,a4,8000459a <filewrite+0x10a>
    800044c0:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800044c2:	0ac05a63          	blez	a2,80004576 <filewrite+0xe6>
    800044c6:	e4a6                	sd	s1,72(sp)
    800044c8:	fc4e                	sd	s3,56(sp)
    800044ca:	ec5e                	sd	s7,24(sp)
    800044cc:	e862                	sd	s8,16(sp)
    800044ce:	e466                	sd	s9,8(sp)
    int i = 0;
    800044d0:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800044d2:	6b85                	lui	s7,0x1
    800044d4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044d8:	6785                	lui	a5,0x1
    800044da:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800044de:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044e0:	4c05                	li	s8,1
    800044e2:	a8ad                	j	8000455c <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800044e4:	6908                	ld	a0,16(a0)
    800044e6:	252000ef          	jal	80004738 <pipewrite>
    800044ea:	a04d                	j	8000458c <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800044ec:	02451783          	lh	a5,36(a0)
    800044f0:	03079693          	slli	a3,a5,0x30
    800044f4:	92c1                	srli	a3,a3,0x30
    800044f6:	4725                	li	a4,9
    800044f8:	0ad76f63          	bltu	a4,a3,800045b6 <filewrite+0x126>
    800044fc:	0792                	slli	a5,a5,0x4
    800044fe:	0001e717          	auipc	a4,0x1e
    80004502:	09270713          	addi	a4,a4,146 # 80022590 <devsw>
    80004506:	97ba                	add	a5,a5,a4
    80004508:	679c                	ld	a5,8(a5)
    8000450a:	cbc5                	beqz	a5,800045ba <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    8000450c:	4505                	li	a0,1
    8000450e:	9782                	jalr	a5
    80004510:	a8b5                	j	8000458c <filewrite+0xfc>
      if(n1 > max)
    80004512:	2981                	sext.w	s3,s3
      begin_op();
    80004514:	971ff0ef          	jal	80003e84 <begin_op>
      ilock(f->ip);
    80004518:	01893503          	ld	a0,24(s2)
    8000451c:	f5dfe0ef          	jal	80003478 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004520:	874e                	mv	a4,s3
    80004522:	02092683          	lw	a3,32(s2)
    80004526:	016a0633          	add	a2,s4,s6
    8000452a:	85e2                	mv	a1,s8
    8000452c:	01893503          	ld	a0,24(s2)
    80004530:	bccff0ef          	jal	800038fc <writei>
    80004534:	84aa                	mv	s1,a0
    80004536:	00a05763          	blez	a0,80004544 <filewrite+0xb4>
        f->off += r;
    8000453a:	02092783          	lw	a5,32(s2)
    8000453e:	9fa9                	addw	a5,a5,a0
    80004540:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004544:	01893503          	ld	a0,24(s2)
    80004548:	fdffe0ef          	jal	80003526 <iunlock>
      end_op();
    8000454c:	9a9ff0ef          	jal	80003ef4 <end_op>

      if(r != n1){
    80004550:	02999563          	bne	s3,s1,8000457a <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004554:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004558:	015a5963          	bge	s4,s5,8000456a <filewrite+0xda>
      int n1 = n - i;
    8000455c:	414a87bb          	subw	a5,s5,s4
    80004560:	89be                	mv	s3,a5
      if(n1 > max)
    80004562:	fafbd8e3          	bge	s7,a5,80004512 <filewrite+0x82>
    80004566:	89e6                	mv	s3,s9
    80004568:	b76d                	j	80004512 <filewrite+0x82>
    8000456a:	64a6                	ld	s1,72(sp)
    8000456c:	79e2                	ld	s3,56(sp)
    8000456e:	6be2                	ld	s7,24(sp)
    80004570:	6c42                	ld	s8,16(sp)
    80004572:	6ca2                	ld	s9,8(sp)
    80004574:	a801                	j	80004584 <filewrite+0xf4>
    int i = 0;
    80004576:	4a01                	li	s4,0
    80004578:	a031                	j	80004584 <filewrite+0xf4>
    8000457a:	64a6                	ld	s1,72(sp)
    8000457c:	79e2                	ld	s3,56(sp)
    8000457e:	6be2                	ld	s7,24(sp)
    80004580:	6c42                	ld	s8,16(sp)
    80004582:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004584:	034a9d63          	bne	s5,s4,800045be <filewrite+0x12e>
    80004588:	8556                	mv	a0,s5
    8000458a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000458c:	60e6                	ld	ra,88(sp)
    8000458e:	6446                	ld	s0,80(sp)
    80004590:	6906                	ld	s2,64(sp)
    80004592:	7aa2                	ld	s5,40(sp)
    80004594:	7b02                	ld	s6,32(sp)
    80004596:	6125                	addi	sp,sp,96
    80004598:	8082                	ret
    8000459a:	e4a6                	sd	s1,72(sp)
    8000459c:	fc4e                	sd	s3,56(sp)
    8000459e:	f852                	sd	s4,48(sp)
    800045a0:	ec5e                	sd	s7,24(sp)
    800045a2:	e862                	sd	s8,16(sp)
    800045a4:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800045a6:	00003517          	auipc	a0,0x3
    800045aa:	0b250513          	addi	a0,a0,178 # 80007658 <etext+0x658>
    800045ae:	a76fc0ef          	jal	80000824 <panic>
    return -1;
    800045b2:	557d                	li	a0,-1
}
    800045b4:	8082                	ret
      return -1;
    800045b6:	557d                	li	a0,-1
    800045b8:	bfd1                	j	8000458c <filewrite+0xfc>
    800045ba:	557d                	li	a0,-1
    800045bc:	bfc1                	j	8000458c <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800045be:	557d                	li	a0,-1
    800045c0:	7a42                	ld	s4,48(sp)
    800045c2:	b7e9                	j	8000458c <filewrite+0xfc>

00000000800045c4 <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045c4:	1101                	addi	sp,sp,-32
    800045c6:	ec06                	sd	ra,24(sp)
    800045c8:	e822                	sd	s0,16(sp)
    800045ca:	e426                	sd	s1,8(sp)
    800045cc:	e04a                	sd	s2,0(sp)
    800045ce:	1000                	addi	s0,sp,32
    800045d0:	84aa                	mv	s1,a0
    800045d2:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045d4:	0005b023          	sd	zero,0(a1)
    800045d8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045dc:	c29ff0ef          	jal	80004204 <filealloc>
    800045e0:	e088                	sd	a0,0(s1)
    800045e2:	cd35                	beqz	a0,8000465e <pipealloc+0x9a>
    800045e4:	c21ff0ef          	jal	80004204 <filealloc>
    800045e8:	00a93023          	sd	a0,0(s2)
    800045ec:	c52d                	beqz	a0,80004656 <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800045ee:	d56fc0ef          	jal	80000b44 <kalloc>
    800045f2:	cd39                	beqz	a0,80004650 <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    800045f4:	4785                	li	a5,1
    800045f6:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    800045fa:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    800045fe:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    80004602:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    80004606:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    8000460a:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    8000460e:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004612:	6098                	ld	a4,0(s1)
    80004614:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    80004616:	6098                	ld	a4,0(s1)
    80004618:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    8000461c:	6098                	ld	a4,0(s1)
    8000461e:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004622:	6098                	ld	a4,0(s1)
    80004624:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    80004626:	00093703          	ld	a4,0(s2)
    8000462a:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    8000462c:	00093703          	ld	a4,0(s2)
    80004630:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    80004634:	00093703          	ld	a4,0(s2)
    80004638:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    8000463c:	00093783          	ld	a5,0(s2)
    80004640:	eb88                	sd	a0,16(a5)
  return 0;
    80004642:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret
  if(*f0)
    80004650:	6088                	ld	a0,0(s1)
    80004652:	e501                	bnez	a0,8000465a <pipealloc+0x96>
    80004654:	a029                	j	8000465e <pipealloc+0x9a>
    80004656:	6088                	ld	a0,0(s1)
    80004658:	cd01                	beqz	a0,80004670 <pipealloc+0xac>
    fileclose(*f0);
    8000465a:	c4fff0ef          	jal	800042a8 <fileclose>
  if(*f1)
    8000465e:	00093783          	ld	a5,0(s2)
  return -1;
    80004662:	557d                	li	a0,-1
  if(*f1)
    80004664:	d3e5                	beqz	a5,80004644 <pipealloc+0x80>
    fileclose(*f1);
    80004666:	853e                	mv	a0,a5
    80004668:	c41ff0ef          	jal	800042a8 <fileclose>
  return -1;
    8000466c:	557d                	li	a0,-1
    8000466e:	bfd9                	j	80004644 <pipealloc+0x80>
    80004670:	557d                	li	a0,-1
    80004672:	bfc9                	j	80004644 <pipealloc+0x80>

0000000080004674 <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    80004674:	1141                	addi	sp,sp,-16
    80004676:	e406                	sd	ra,8(sp)
    80004678:	e022                	sd	s0,0(sp)
    8000467a:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    8000467c:	4785                	li	a5,1
    8000467e:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    80004680:	058a                	slli	a1,a1,0x2
    80004682:	21058593          	addi	a1,a1,528
    80004686:	95aa                	add	a1,a1,a0
    80004688:	4705                	li	a4,1
    8000468a:	c198                	sw	a4,0(a1)
  pi->turn = other;
    8000468c:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    80004690:	078a                	slli	a5,a5,0x2
    80004692:	21078793          	addi	a5,a5,528
    80004696:	953e                	add	a0,a0,a5
    80004698:	4118                	lw	a4,0(a0)
    8000469a:	4785                	li	a5,1
    8000469c:	00f70063          	beq	a4,a5,8000469c <peterson_enter+0x28>
}
    800046a0:	60a2                	ld	ra,8(sp)
    800046a2:	6402                	ld	s0,0(sp)
    800046a4:	0141                	addi	sp,sp,16
    800046a6:	8082                	ret

00000000800046a8 <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    800046a8:	1141                	addi	sp,sp,-16
    800046aa:	e406                	sd	ra,8(sp)
    800046ac:	e022                	sd	s0,0(sp)
    800046ae:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    800046b0:	058a                	slli	a1,a1,0x2
    800046b2:	21058593          	addi	a1,a1,528
    800046b6:	952e                	add	a0,a0,a1
    800046b8:	00052023          	sw	zero,0(a0)
}
    800046bc:	60a2                	ld	ra,8(sp)
    800046be:	6402                	ld	s0,0(sp)
    800046c0:	0141                	addi	sp,sp,16
    800046c2:	8082                	ret

00000000800046c4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046c4:	7179                	addi	sp,sp,-48
    800046c6:	f406                	sd	ra,40(sp)
    800046c8:	f022                	sd	s0,32(sp)
    800046ca:	ec26                	sd	s1,24(sp)
    800046cc:	e84a                	sd	s2,16(sp)
    800046ce:	e44e                	sd	s3,8(sp)
    800046d0:	1800                	addi	s0,sp,48
    800046d2:	84aa                	mv	s1,a0
    800046d4:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    800046d6:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    800046da:	85ca                	mv	a1,s2
    800046dc:	f99ff0ef          	jal	80004674 <peterson_enter>
  if(writable){
    800046e0:	02098b63          	beqz	s3,80004716 <pipeclose+0x52>
    pi->writeopen = 0;
    800046e4:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    800046e8:	20048513          	addi	a0,s1,512
    800046ec:	9b9fd0ef          	jal	800020a4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800046f0:	2084a783          	lw	a5,520(s1)
    800046f4:	e781                	bnez	a5,800046fc <pipeclose+0x38>
    800046f6:	20c4a783          	lw	a5,524(s1)
    800046fa:	c78d                	beqz	a5,80004724 <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    800046fc:	090a                	slli	s2,s2,0x2
    800046fe:	21090913          	addi	s2,s2,528
    80004702:	94ca                	add	s1,s1,s2
    80004704:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    80004708:	70a2                	ld	ra,40(sp)
    8000470a:	7402                	ld	s0,32(sp)
    8000470c:	64e2                	ld	s1,24(sp)
    8000470e:	6942                	ld	s2,16(sp)
    80004710:	69a2                	ld	s3,8(sp)
    80004712:	6145                	addi	sp,sp,48
    80004714:	8082                	ret
    pi->readopen = 0;
    80004716:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    8000471a:	20448513          	addi	a0,s1,516
    8000471e:	987fd0ef          	jal	800020a4 <wakeup>
    80004722:	b7f9                	j	800046f0 <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    80004724:	090a                	slli	s2,s2,0x2
    80004726:	21090913          	addi	s2,s2,528
    8000472a:	9926                	add	s2,s2,s1
    8000472c:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    80004730:	8526                	mv	a0,s1
    80004732:	b2afc0ef          	jal	80000a5c <kfree>
    80004736:	bfc9                	j	80004708 <pipeclose+0x44>

0000000080004738 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004738:	7159                	addi	sp,sp,-112
    8000473a:	f486                	sd	ra,104(sp)
    8000473c:	f0a2                	sd	s0,96(sp)
    8000473e:	eca6                	sd	s1,88(sp)
    80004740:	e8ca                	sd	s2,80(sp)
    80004742:	e4ce                	sd	s3,72(sp)
    80004744:	e0d2                	sd	s4,64(sp)
    80004746:	fc56                	sd	s5,56(sp)
    80004748:	1880                	addi	s0,sp,112
    8000474a:	84aa                	mv	s1,a0
    8000474c:	8aae                	mv	s5,a1
    8000474e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004750:	a48fd0ef          	jal	80001998 <myproc>
    80004754:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    80004756:	4581                	li	a1,0
    80004758:	8526                	mv	a0,s1
    8000475a:	f1bff0ef          	jal	80004674 <peterson_enter>
  while(i < n){
    8000475e:	0b405e63          	blez	s4,8000481a <pipewrite+0xe2>
    80004762:	f85a                	sd	s6,48(sp)
    80004764:	f45e                	sd	s7,40(sp)
    80004766:	f062                	sd	s8,32(sp)
    80004768:	ec66                	sd	s9,24(sp)
    8000476a:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000476c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000476e:	f9f40c13          	addi	s8,s0,-97
    80004772:	4b85                	li	s7,1
    80004774:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004776:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    8000477a:	20448c93          	addi	s9,s1,516
    8000477e:	a825                	j	800047b6 <pipewrite+0x7e>
      return -1;
    80004780:	597d                	li	s2,-1
}
    80004782:	7b42                	ld	s6,48(sp)
    80004784:	7ba2                	ld	s7,40(sp)
    80004786:	7c02                	ld	s8,32(sp)
    80004788:	6ce2                	ld	s9,24(sp)
    8000478a:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    8000478c:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004790:	854a                	mv	a0,s2
    80004792:	70a6                	ld	ra,104(sp)
    80004794:	7406                	ld	s0,96(sp)
    80004796:	64e6                	ld	s1,88(sp)
    80004798:	6946                	ld	s2,80(sp)
    8000479a:	69a6                	ld	s3,72(sp)
    8000479c:	6a06                	ld	s4,64(sp)
    8000479e:	7ae2                	ld	s5,56(sp)
    800047a0:	6165                	addi	sp,sp,112
    800047a2:	8082                	ret
      wakeup(&pi->nread);
    800047a4:	856a                	mv	a0,s10
    800047a6:	8fffd0ef          	jal	800020a4 <wakeup>
      sleep(&pi->nwrite, 0);
    800047aa:	4581                	li	a1,0
    800047ac:	8566                	mv	a0,s9
    800047ae:	8abfd0ef          	jal	80002058 <sleep>
  while(i < n){
    800047b2:	05495a63          	bge	s2,s4,80004806 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800047b6:	2084a783          	lw	a5,520(s1)
    800047ba:	d3f9                	beqz	a5,80004780 <pipewrite+0x48>
    800047bc:	854e                	mv	a0,s3
    800047be:	ad7fd0ef          	jal	80002294 <killed>
    800047c2:	fd5d                	bnez	a0,80004780 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047c4:	2004a783          	lw	a5,512(s1)
    800047c8:	2044a703          	lw	a4,516(s1)
    800047cc:	2007879b          	addiw	a5,a5,512
    800047d0:	fcf70ae3          	beq	a4,a5,800047a4 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047d4:	86de                	mv	a3,s7
    800047d6:	01590633          	add	a2,s2,s5
    800047da:	85e2                	mv	a1,s8
    800047dc:	0509b503          	ld	a0,80(s3)
    800047e0:	f33fc0ef          	jal	80001712 <copyin>
    800047e4:	03650d63          	beq	a0,s6,8000481e <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047e8:	2044a783          	lw	a5,516(s1)
    800047ec:	0017871b          	addiw	a4,a5,1
    800047f0:	20e4a223          	sw	a4,516(s1)
    800047f4:	1ff7f793          	andi	a5,a5,511
    800047f8:	97a6                	add	a5,a5,s1
    800047fa:	f9f44703          	lbu	a4,-97(s0)
    800047fe:	00e78023          	sb	a4,0(a5)
      i++;
    80004802:	2905                	addiw	s2,s2,1
    80004804:	b77d                	j	800047b2 <pipewrite+0x7a>
    80004806:	7b42                	ld	s6,48(sp)
    80004808:	7ba2                	ld	s7,40(sp)
    8000480a:	7c02                	ld	s8,32(sp)
    8000480c:	6ce2                	ld	s9,24(sp)
    8000480e:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004810:	20048513          	addi	a0,s1,512
    80004814:	891fd0ef          	jal	800020a4 <wakeup>
}
    80004818:	bf95                	j	8000478c <pipewrite+0x54>
  int i = 0;
    8000481a:	4901                	li	s2,0
    8000481c:	bfd5                	j	80004810 <pipewrite+0xd8>
    8000481e:	7b42                	ld	s6,48(sp)
    80004820:	7ba2                	ld	s7,40(sp)
    80004822:	7c02                	ld	s8,32(sp)
    80004824:	6ce2                	ld	s9,24(sp)
    80004826:	6d42                	ld	s10,16(sp)
    80004828:	b7e5                	j	80004810 <pipewrite+0xd8>

000000008000482a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000482a:	711d                	addi	sp,sp,-96
    8000482c:	ec86                	sd	ra,88(sp)
    8000482e:	e8a2                	sd	s0,80(sp)
    80004830:	e4a6                	sd	s1,72(sp)
    80004832:	e0ca                	sd	s2,64(sp)
    80004834:	fc4e                	sd	s3,56(sp)
    80004836:	f852                	sd	s4,48(sp)
    80004838:	f456                	sd	s5,40(sp)
    8000483a:	1080                	addi	s0,sp,96
    8000483c:	84aa                	mv	s1,a0
    8000483e:	892e                	mv	s2,a1
    80004840:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004842:	956fd0ef          	jal	80001998 <myproc>
    80004846:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    80004848:	4585                	li	a1,1
    8000484a:	8526                	mv	a0,s1
    8000484c:	e29ff0ef          	jal	80004674 <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004850:	2004a703          	lw	a4,512(s1)
    80004854:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80004858:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000485c:	02f71763          	bne	a4,a5,8000488a <piperead+0x60>
    80004860:	20c4a783          	lw	a5,524(s1)
    80004864:	c79d                	beqz	a5,80004892 <piperead+0x68>
    if(killed(pr)){
    80004866:	8552                	mv	a0,s4
    80004868:	a2dfd0ef          	jal	80002294 <killed>
    8000486c:	e15d                	bnez	a0,80004912 <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    8000486e:	4581                	li	a1,0
    80004870:	854e                	mv	a0,s3
    80004872:	fe6fd0ef          	jal	80002058 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004876:	2004a703          	lw	a4,512(s1)
    8000487a:	2044a783          	lw	a5,516(s1)
    8000487e:	fef701e3          	beq	a4,a5,80004860 <piperead+0x36>
    80004882:	f05a                	sd	s6,32(sp)
    80004884:	ec5e                	sd	s7,24(sp)
    80004886:	e862                	sd	s8,16(sp)
    80004888:	a801                	j	80004898 <piperead+0x6e>
    8000488a:	f05a                	sd	s6,32(sp)
    8000488c:	ec5e                	sd	s7,24(sp)
    8000488e:	e862                	sd	s8,16(sp)
    80004890:	a021                	j	80004898 <piperead+0x6e>
    80004892:	f05a                	sd	s6,32(sp)
    80004894:	ec5e                	sd	s7,24(sp)
    80004896:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004898:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000489a:	faf40c13          	addi	s8,s0,-81
    8000489e:	4b85                	li	s7,1
    800048a0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048a2:	05505163          	blez	s5,800048e4 <piperead+0xba>
    if(pi->nread == pi->nwrite)
    800048a6:	2004a783          	lw	a5,512(s1)
    800048aa:	2044a703          	lw	a4,516(s1)
    800048ae:	02f70b63          	beq	a4,a5,800048e4 <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    800048b2:	1ff7f793          	andi	a5,a5,511
    800048b6:	97a6                	add	a5,a5,s1
    800048b8:	0007c783          	lbu	a5,0(a5)
    800048bc:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048c0:	86de                	mv	a3,s7
    800048c2:	8662                	mv	a2,s8
    800048c4:	85ca                	mv	a1,s2
    800048c6:	050a3503          	ld	a0,80(s4)
    800048ca:	d8bfc0ef          	jal	80001654 <copyout>
    800048ce:	03650e63          	beq	a0,s6,8000490a <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048d2:	2004a783          	lw	a5,512(s1)
    800048d6:	2785                	addiw	a5,a5,1
    800048d8:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048dc:	2985                	addiw	s3,s3,1
    800048de:	0905                	addi	s2,s2,1
    800048e0:	fd3a93e3          	bne	s5,s3,800048a6 <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800048e4:	20448513          	addi	a0,s1,516
    800048e8:	fbcfd0ef          	jal	800020a4 <wakeup>
}
    800048ec:	7b02                	ld	s6,32(sp)
    800048ee:	6be2                	ld	s7,24(sp)
    800048f0:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    800048f2:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    800048f6:	854e                	mv	a0,s3
    800048f8:	60e6                	ld	ra,88(sp)
    800048fa:	6446                	ld	s0,80(sp)
    800048fc:	64a6                	ld	s1,72(sp)
    800048fe:	6906                	ld	s2,64(sp)
    80004900:	79e2                	ld	s3,56(sp)
    80004902:	7a42                	ld	s4,48(sp)
    80004904:	7aa2                	ld	s5,40(sp)
    80004906:	6125                	addi	sp,sp,96
    80004908:	8082                	ret
      if(i == 0)
    8000490a:	fc099de3          	bnez	s3,800048e4 <piperead+0xba>
        i = -1;
    8000490e:	89aa                	mv	s3,a0
    80004910:	bfd1                	j	800048e4 <piperead+0xba>
      return -1;
    80004912:	59fd                	li	s3,-1
    80004914:	bff9                	j	800048f2 <piperead+0xc8>

0000000080004916 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004916:	1141                	addi	sp,sp,-16
    80004918:	e406                	sd	ra,8(sp)
    8000491a:	e022                	sd	s0,0(sp)
    8000491c:	0800                	addi	s0,sp,16
    8000491e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004920:	0035151b          	slliw	a0,a0,0x3
    80004924:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004926:	8b89                	andi	a5,a5,2
    80004928:	c399                	beqz	a5,8000492e <flags2perm+0x18>
      perm |= PTE_W;
    8000492a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000492e:	60a2                	ld	ra,8(sp)
    80004930:	6402                	ld	s0,0(sp)
    80004932:	0141                	addi	sp,sp,16
    80004934:	8082                	ret

0000000080004936 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004936:	de010113          	addi	sp,sp,-544
    8000493a:	20113c23          	sd	ra,536(sp)
    8000493e:	20813823          	sd	s0,528(sp)
    80004942:	20913423          	sd	s1,520(sp)
    80004946:	21213023          	sd	s2,512(sp)
    8000494a:	1400                	addi	s0,sp,544
    8000494c:	892a                	mv	s2,a0
    8000494e:	dea43823          	sd	a0,-528(s0)
    80004952:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004956:	842fd0ef          	jal	80001998 <myproc>
    8000495a:	84aa                	mv	s1,a0

  begin_op();
    8000495c:	d28ff0ef          	jal	80003e84 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004960:	854a                	mv	a0,s2
    80004962:	b44ff0ef          	jal	80003ca6 <namei>
    80004966:	cd21                	beqz	a0,800049be <kexec+0x88>
    80004968:	fbd2                	sd	s4,496(sp)
    8000496a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000496c:	b0dfe0ef          	jal	80003478 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004970:	04000713          	li	a4,64
    80004974:	4681                	li	a3,0
    80004976:	e5040613          	addi	a2,s0,-432
    8000497a:	4581                	li	a1,0
    8000497c:	8552                	mv	a0,s4
    8000497e:	e8dfe0ef          	jal	8000380a <readi>
    80004982:	04000793          	li	a5,64
    80004986:	00f51a63          	bne	a0,a5,8000499a <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000498a:	e5042703          	lw	a4,-432(s0)
    8000498e:	464c47b7          	lui	a5,0x464c4
    80004992:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004996:	02f70863          	beq	a4,a5,800049c6 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000499a:	8552                	mv	a0,s4
    8000499c:	ce9fe0ef          	jal	80003684 <iunlockput>
    end_op();
    800049a0:	d54ff0ef          	jal	80003ef4 <end_op>
  }
  return -1;
    800049a4:	557d                	li	a0,-1
    800049a6:	7a5e                	ld	s4,496(sp)
}
    800049a8:	21813083          	ld	ra,536(sp)
    800049ac:	21013403          	ld	s0,528(sp)
    800049b0:	20813483          	ld	s1,520(sp)
    800049b4:	20013903          	ld	s2,512(sp)
    800049b8:	22010113          	addi	sp,sp,544
    800049bc:	8082                	ret
    end_op();
    800049be:	d36ff0ef          	jal	80003ef4 <end_op>
    return -1;
    800049c2:	557d                	li	a0,-1
    800049c4:	b7d5                	j	800049a8 <kexec+0x72>
    800049c6:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049c8:	8526                	mv	a0,s1
    800049ca:	8d8fd0ef          	jal	80001aa2 <proc_pagetable>
    800049ce:	8b2a                	mv	s6,a0
    800049d0:	26050f63          	beqz	a0,80004c4e <kexec+0x318>
    800049d4:	ffce                	sd	s3,504(sp)
    800049d6:	f7d6                	sd	s5,488(sp)
    800049d8:	efde                	sd	s7,472(sp)
    800049da:	ebe2                	sd	s8,464(sp)
    800049dc:	e7e6                	sd	s9,456(sp)
    800049de:	e3ea                	sd	s10,448(sp)
    800049e0:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049e2:	e8845783          	lhu	a5,-376(s0)
    800049e6:	0e078963          	beqz	a5,80004ad8 <kexec+0x1a2>
    800049ea:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049ee:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049f0:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049f2:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800049f6:	6c85                	lui	s9,0x1
    800049f8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800049fc:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a00:	6a85                	lui	s5,0x1
    80004a02:	a085                	j	80004a62 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a04:	00003517          	auipc	a0,0x3
    80004a08:	c6450513          	addi	a0,a0,-924 # 80007668 <etext+0x668>
    80004a0c:	e19fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004a10:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a12:	874a                	mv	a4,s2
    80004a14:	009b86bb          	addw	a3,s7,s1
    80004a18:	4581                	li	a1,0
    80004a1a:	8552                	mv	a0,s4
    80004a1c:	deffe0ef          	jal	8000380a <readi>
    80004a20:	22a91b63          	bne	s2,a0,80004c56 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004a24:	009a84bb          	addw	s1,s5,s1
    80004a28:	0334f263          	bgeu	s1,s3,80004a4c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a2c:	02049593          	slli	a1,s1,0x20
    80004a30:	9181                	srli	a1,a1,0x20
    80004a32:	95e2                	add	a1,a1,s8
    80004a34:	855a                	mv	a0,s6
    80004a36:	df0fc0ef          	jal	80001026 <walkaddr>
    80004a3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004a3c:	d561                	beqz	a0,80004a04 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004a3e:	409987bb          	subw	a5,s3,s1
    80004a42:	893e                	mv	s2,a5
    80004a44:	fcfcf6e3          	bgeu	s9,a5,80004a10 <kexec+0xda>
    80004a48:	8956                	mv	s2,s5
    80004a4a:	b7d9                	j	80004a10 <kexec+0xda>
    sz = sz1;
    80004a4c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a50:	2d05                	addiw	s10,s10,1
    80004a52:	e0843783          	ld	a5,-504(s0)
    80004a56:	0387869b          	addiw	a3,a5,56
    80004a5a:	e8845783          	lhu	a5,-376(s0)
    80004a5e:	06fd5e63          	bge	s10,a5,80004ada <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a62:	e0d43423          	sd	a3,-504(s0)
    80004a66:	876e                	mv	a4,s11
    80004a68:	e1840613          	addi	a2,s0,-488
    80004a6c:	4581                	li	a1,0
    80004a6e:	8552                	mv	a0,s4
    80004a70:	d9bfe0ef          	jal	8000380a <readi>
    80004a74:	1db51f63          	bne	a0,s11,80004c52 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004a78:	e1842783          	lw	a5,-488(s0)
    80004a7c:	4705                	li	a4,1
    80004a7e:	fce799e3          	bne	a5,a4,80004a50 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004a82:	e4043483          	ld	s1,-448(s0)
    80004a86:	e3843783          	ld	a5,-456(s0)
    80004a8a:	1ef4e463          	bltu	s1,a5,80004c72 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a8e:	e2843783          	ld	a5,-472(s0)
    80004a92:	94be                	add	s1,s1,a5
    80004a94:	1ef4e263          	bltu	s1,a5,80004c78 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004a98:	de843703          	ld	a4,-536(s0)
    80004a9c:	8ff9                	and	a5,a5,a4
    80004a9e:	1e079063          	bnez	a5,80004c7e <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004aa2:	e1c42503          	lw	a0,-484(s0)
    80004aa6:	e71ff0ef          	jal	80004916 <flags2perm>
    80004aaa:	86aa                	mv	a3,a0
    80004aac:	8626                	mv	a2,s1
    80004aae:	85ca                	mv	a1,s2
    80004ab0:	855a                	mv	a0,s6
    80004ab2:	84bfc0ef          	jal	800012fc <uvmalloc>
    80004ab6:	dea43c23          	sd	a0,-520(s0)
    80004aba:	1c050563          	beqz	a0,80004c84 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004abe:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ac2:	00098863          	beqz	s3,80004ad2 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ac6:	e2843c03          	ld	s8,-472(s0)
    80004aca:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ace:	4481                	li	s1,0
    80004ad0:	bfb1                	j	80004a2c <kexec+0xf6>
    sz = sz1;
    80004ad2:	df843903          	ld	s2,-520(s0)
    80004ad6:	bfad                	j	80004a50 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ad8:	4901                	li	s2,0
  iunlockput(ip);
    80004ada:	8552                	mv	a0,s4
    80004adc:	ba9fe0ef          	jal	80003684 <iunlockput>
  end_op();
    80004ae0:	c14ff0ef          	jal	80003ef4 <end_op>
  p = myproc();
    80004ae4:	eb5fc0ef          	jal	80001998 <myproc>
    80004ae8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004aea:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004aee:	6985                	lui	s3,0x1
    80004af0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004af2:	99ca                	add	s3,s3,s2
    80004af4:	77fd                	lui	a5,0xfffff
    80004af6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004afa:	4691                	li	a3,4
    80004afc:	6609                	lui	a2,0x2
    80004afe:	964e                	add	a2,a2,s3
    80004b00:	85ce                	mv	a1,s3
    80004b02:	855a                	mv	a0,s6
    80004b04:	ff8fc0ef          	jal	800012fc <uvmalloc>
    80004b08:	8a2a                	mv	s4,a0
    80004b0a:	e105                	bnez	a0,80004b2a <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004b0c:	85ce                	mv	a1,s3
    80004b0e:	855a                	mv	a0,s6
    80004b10:	816fd0ef          	jal	80001b26 <proc_freepagetable>
  return -1;
    80004b14:	557d                	li	a0,-1
    80004b16:	79fe                	ld	s3,504(sp)
    80004b18:	7a5e                	ld	s4,496(sp)
    80004b1a:	7abe                	ld	s5,488(sp)
    80004b1c:	7b1e                	ld	s6,480(sp)
    80004b1e:	6bfe                	ld	s7,472(sp)
    80004b20:	6c5e                	ld	s8,464(sp)
    80004b22:	6cbe                	ld	s9,456(sp)
    80004b24:	6d1e                	ld	s10,448(sp)
    80004b26:	7dfa                	ld	s11,440(sp)
    80004b28:	b541                	j	800049a8 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b2a:	75f9                	lui	a1,0xffffe
    80004b2c:	95aa                	add	a1,a1,a0
    80004b2e:	855a                	mv	a0,s6
    80004b30:	99ffc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b34:	800a0b93          	addi	s7,s4,-2048
    80004b38:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004b3c:	e0043783          	ld	a5,-512(s0)
    80004b40:	6388                	ld	a0,0(a5)
  sp = sz;
    80004b42:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004b44:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b46:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004b4a:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004b4e:	cd21                	beqz	a0,80004ba6 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004b50:	b32fc0ef          	jal	80000e82 <strlen>
    80004b54:	0015079b          	addiw	a5,a0,1
    80004b58:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b5c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b60:	13796563          	bltu	s2,s7,80004c8a <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b64:	e0043d83          	ld	s11,-512(s0)
    80004b68:	000db983          	ld	s3,0(s11)
    80004b6c:	854e                	mv	a0,s3
    80004b6e:	b14fc0ef          	jal	80000e82 <strlen>
    80004b72:	0015069b          	addiw	a3,a0,1
    80004b76:	864e                	mv	a2,s3
    80004b78:	85ca                	mv	a1,s2
    80004b7a:	855a                	mv	a0,s6
    80004b7c:	ad9fc0ef          	jal	80001654 <copyout>
    80004b80:	10054763          	bltz	a0,80004c8e <kexec+0x358>
    ustack[argc] = sp;
    80004b84:	00349793          	slli	a5,s1,0x3
    80004b88:	97e6                	add	a5,a5,s9
    80004b8a:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb8d8>
  for(argc = 0; argv[argc]; argc++) {
    80004b8e:	0485                	addi	s1,s1,1
    80004b90:	008d8793          	addi	a5,s11,8
    80004b94:	e0f43023          	sd	a5,-512(s0)
    80004b98:	008db503          	ld	a0,8(s11)
    80004b9c:	c509                	beqz	a0,80004ba6 <kexec+0x270>
    if(argc >= MAXARG)
    80004b9e:	fb8499e3          	bne	s1,s8,80004b50 <kexec+0x21a>
  sz = sz1;
    80004ba2:	89d2                	mv	s3,s4
    80004ba4:	b7a5                	j	80004b0c <kexec+0x1d6>
  ustack[argc] = 0;
    80004ba6:	00349793          	slli	a5,s1,0x3
    80004baa:	f9078793          	addi	a5,a5,-112
    80004bae:	97a2                	add	a5,a5,s0
    80004bb0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004bb4:	00349693          	slli	a3,s1,0x3
    80004bb8:	06a1                	addi	a3,a3,8
    80004bba:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004bbe:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004bc2:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004bc4:	f57964e3          	bltu	s2,s7,80004b0c <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004bc8:	e9040613          	addi	a2,s0,-368
    80004bcc:	85ca                	mv	a1,s2
    80004bce:	855a                	mv	a0,s6
    80004bd0:	a85fc0ef          	jal	80001654 <copyout>
    80004bd4:	f2054ce3          	bltz	a0,80004b0c <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004bd8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004bdc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004be0:	df043783          	ld	a5,-528(s0)
    80004be4:	0007c703          	lbu	a4,0(a5)
    80004be8:	cf11                	beqz	a4,80004c04 <kexec+0x2ce>
    80004bea:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004bec:	02f00693          	li	a3,47
    80004bf0:	a029                	j	80004bfa <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004bf2:	0785                	addi	a5,a5,1
    80004bf4:	fff7c703          	lbu	a4,-1(a5)
    80004bf8:	c711                	beqz	a4,80004c04 <kexec+0x2ce>
    if(*s == '/')
    80004bfa:	fed71ce3          	bne	a4,a3,80004bf2 <kexec+0x2bc>
      last = s+1;
    80004bfe:	def43823          	sd	a5,-528(s0)
    80004c02:	bfc5                	j	80004bf2 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c04:	4641                	li	a2,16
    80004c06:	df043583          	ld	a1,-528(s0)
    80004c0a:	158a8513          	addi	a0,s5,344
    80004c0e:	a3efc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c12:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c16:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c1a:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004c1e:	058ab783          	ld	a5,88(s5)
    80004c22:	e6843703          	ld	a4,-408(s0)
    80004c26:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c28:	058ab783          	ld	a5,88(s5)
    80004c2c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c30:	85ea                	mv	a1,s10
    80004c32:	ef5fc0ef          	jal	80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c36:	0004851b          	sext.w	a0,s1
    80004c3a:	79fe                	ld	s3,504(sp)
    80004c3c:	7a5e                	ld	s4,496(sp)
    80004c3e:	7abe                	ld	s5,488(sp)
    80004c40:	7b1e                	ld	s6,480(sp)
    80004c42:	6bfe                	ld	s7,472(sp)
    80004c44:	6c5e                	ld	s8,464(sp)
    80004c46:	6cbe                	ld	s9,456(sp)
    80004c48:	6d1e                	ld	s10,448(sp)
    80004c4a:	7dfa                	ld	s11,440(sp)
    80004c4c:	bbb1                	j	800049a8 <kexec+0x72>
    80004c4e:	7b1e                	ld	s6,480(sp)
    80004c50:	b3a9                	j	8000499a <kexec+0x64>
    80004c52:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c56:	df843583          	ld	a1,-520(s0)
    80004c5a:	855a                	mv	a0,s6
    80004c5c:	ecbfc0ef          	jal	80001b26 <proc_freepagetable>
  if(ip){
    80004c60:	79fe                	ld	s3,504(sp)
    80004c62:	7abe                	ld	s5,488(sp)
    80004c64:	7b1e                	ld	s6,480(sp)
    80004c66:	6bfe                	ld	s7,472(sp)
    80004c68:	6c5e                	ld	s8,464(sp)
    80004c6a:	6cbe                	ld	s9,456(sp)
    80004c6c:	6d1e                	ld	s10,448(sp)
    80004c6e:	7dfa                	ld	s11,440(sp)
    80004c70:	b32d                	j	8000499a <kexec+0x64>
    80004c72:	df243c23          	sd	s2,-520(s0)
    80004c76:	b7c5                	j	80004c56 <kexec+0x320>
    80004c78:	df243c23          	sd	s2,-520(s0)
    80004c7c:	bfe9                	j	80004c56 <kexec+0x320>
    80004c7e:	df243c23          	sd	s2,-520(s0)
    80004c82:	bfd1                	j	80004c56 <kexec+0x320>
    80004c84:	df243c23          	sd	s2,-520(s0)
    80004c88:	b7f9                	j	80004c56 <kexec+0x320>
  sz = sz1;
    80004c8a:	89d2                	mv	s3,s4
    80004c8c:	b541                	j	80004b0c <kexec+0x1d6>
    80004c8e:	89d2                	mv	s3,s4
    80004c90:	bdb5                	j	80004b0c <kexec+0x1d6>

0000000080004c92 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c92:	7179                	addi	sp,sp,-48
    80004c94:	f406                	sd	ra,40(sp)
    80004c96:	f022                	sd	s0,32(sp)
    80004c98:	ec26                	sd	s1,24(sp)
    80004c9a:	e84a                	sd	s2,16(sp)
    80004c9c:	1800                	addi	s0,sp,48
    80004c9e:	892e                	mv	s2,a1
    80004ca0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ca2:	fdc40593          	addi	a1,s0,-36
    80004ca6:	dddfd0ef          	jal	80002a82 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004caa:	fdc42703          	lw	a4,-36(s0)
    80004cae:	47bd                	li	a5,15
    80004cb0:	02e7ea63          	bltu	a5,a4,80004ce4 <argfd+0x52>
    80004cb4:	ce5fc0ef          	jal	80001998 <myproc>
    80004cb8:	fdc42703          	lw	a4,-36(s0)
    80004cbc:	00371793          	slli	a5,a4,0x3
    80004cc0:	0d078793          	addi	a5,a5,208
    80004cc4:	953e                	add	a0,a0,a5
    80004cc6:	611c                	ld	a5,0(a0)
    80004cc8:	c385                	beqz	a5,80004ce8 <argfd+0x56>
    return -1;
  if(pfd)
    80004cca:	00090463          	beqz	s2,80004cd2 <argfd+0x40>
    *pfd = fd;
    80004cce:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004cd2:	4501                	li	a0,0
  if(pf)
    80004cd4:	c091                	beqz	s1,80004cd8 <argfd+0x46>
    *pf = f;
    80004cd6:	e09c                	sd	a5,0(s1)
}
    80004cd8:	70a2                	ld	ra,40(sp)
    80004cda:	7402                	ld	s0,32(sp)
    80004cdc:	64e2                	ld	s1,24(sp)
    80004cde:	6942                	ld	s2,16(sp)
    80004ce0:	6145                	addi	sp,sp,48
    80004ce2:	8082                	ret
    return -1;
    80004ce4:	557d                	li	a0,-1
    80004ce6:	bfcd                	j	80004cd8 <argfd+0x46>
    80004ce8:	557d                	li	a0,-1
    80004cea:	b7fd                	j	80004cd8 <argfd+0x46>

0000000080004cec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cec:	1101                	addi	sp,sp,-32
    80004cee:	ec06                	sd	ra,24(sp)
    80004cf0:	e822                	sd	s0,16(sp)
    80004cf2:	e426                	sd	s1,8(sp)
    80004cf4:	1000                	addi	s0,sp,32
    80004cf6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004cf8:	ca1fc0ef          	jal	80001998 <myproc>
    80004cfc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004cfe:	0d050793          	addi	a5,a0,208
    80004d02:	4501                	li	a0,0
    80004d04:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d06:	6398                	ld	a4,0(a5)
    80004d08:	cb19                	beqz	a4,80004d1e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d0a:	2505                	addiw	a0,a0,1
    80004d0c:	07a1                	addi	a5,a5,8
    80004d0e:	fed51ce3          	bne	a0,a3,80004d06 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d12:	557d                	li	a0,-1
}
    80004d14:	60e2                	ld	ra,24(sp)
    80004d16:	6442                	ld	s0,16(sp)
    80004d18:	64a2                	ld	s1,8(sp)
    80004d1a:	6105                	addi	sp,sp,32
    80004d1c:	8082                	ret
      p->ofile[fd] = f;
    80004d1e:	00351793          	slli	a5,a0,0x3
    80004d22:	0d078793          	addi	a5,a5,208
    80004d26:	963e                	add	a2,a2,a5
    80004d28:	e204                	sd	s1,0(a2)
      return fd;
    80004d2a:	b7ed                	j	80004d14 <fdalloc+0x28>

0000000080004d2c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d2c:	715d                	addi	sp,sp,-80
    80004d2e:	e486                	sd	ra,72(sp)
    80004d30:	e0a2                	sd	s0,64(sp)
    80004d32:	fc26                	sd	s1,56(sp)
    80004d34:	f84a                	sd	s2,48(sp)
    80004d36:	f44e                	sd	s3,40(sp)
    80004d38:	f052                	sd	s4,32(sp)
    80004d3a:	ec56                	sd	s5,24(sp)
    80004d3c:	e85a                	sd	s6,16(sp)
    80004d3e:	0880                	addi	s0,sp,80
    80004d40:	892e                	mv	s2,a1
    80004d42:	8a2e                	mv	s4,a1
    80004d44:	8ab2                	mv	s5,a2
    80004d46:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d48:	fb040593          	addi	a1,s0,-80
    80004d4c:	f75fe0ef          	jal	80003cc0 <nameiparent>
    80004d50:	84aa                	mv	s1,a0
    80004d52:	10050763          	beqz	a0,80004e60 <create+0x134>
    return 0;

  ilock(dp);
    80004d56:	f22fe0ef          	jal	80003478 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d5a:	4601                	li	a2,0
    80004d5c:	fb040593          	addi	a1,s0,-80
    80004d60:	8526                	mv	a0,s1
    80004d62:	cb1fe0ef          	jal	80003a12 <dirlookup>
    80004d66:	89aa                	mv	s3,a0
    80004d68:	c131                	beqz	a0,80004dac <create+0x80>
    iunlockput(dp);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	919fe0ef          	jal	80003684 <iunlockput>
    ilock(ip);
    80004d70:	854e                	mv	a0,s3
    80004d72:	f06fe0ef          	jal	80003478 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d76:	4789                	li	a5,2
    80004d78:	02f91563          	bne	s2,a5,80004da2 <create+0x76>
    80004d7c:	0449d783          	lhu	a5,68(s3)
    80004d80:	37f9                	addiw	a5,a5,-2
    80004d82:	17c2                	slli	a5,a5,0x30
    80004d84:	93c1                	srli	a5,a5,0x30
    80004d86:	4705                	li	a4,1
    80004d88:	00f76d63          	bltu	a4,a5,80004da2 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d8c:	854e                	mv	a0,s3
    80004d8e:	60a6                	ld	ra,72(sp)
    80004d90:	6406                	ld	s0,64(sp)
    80004d92:	74e2                	ld	s1,56(sp)
    80004d94:	7942                	ld	s2,48(sp)
    80004d96:	79a2                	ld	s3,40(sp)
    80004d98:	7a02                	ld	s4,32(sp)
    80004d9a:	6ae2                	ld	s5,24(sp)
    80004d9c:	6b42                	ld	s6,16(sp)
    80004d9e:	6161                	addi	sp,sp,80
    80004da0:	8082                	ret
    iunlockput(ip);
    80004da2:	854e                	mv	a0,s3
    80004da4:	8e1fe0ef          	jal	80003684 <iunlockput>
    return 0;
    80004da8:	4981                	li	s3,0
    80004daa:	b7cd                	j	80004d8c <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004dac:	85ca                	mv	a1,s2
    80004dae:	4088                	lw	a0,0(s1)
    80004db0:	d58fe0ef          	jal	80003308 <ialloc>
    80004db4:	892a                	mv	s2,a0
    80004db6:	cd15                	beqz	a0,80004df2 <create+0xc6>
  ilock(ip);
    80004db8:	ec0fe0ef          	jal	80003478 <ilock>
  ip->major = major;
    80004dbc:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004dc0:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004dc4:	4785                	li	a5,1
    80004dc6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004dca:	854a                	mv	a0,s2
    80004dcc:	df8fe0ef          	jal	800033c4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dd0:	4705                	li	a4,1
    80004dd2:	02ea0463          	beq	s4,a4,80004dfa <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004dd6:	00492603          	lw	a2,4(s2)
    80004dda:	fb040593          	addi	a1,s0,-80
    80004dde:	8526                	mv	a0,s1
    80004de0:	e1dfe0ef          	jal	80003bfc <dirlink>
    80004de4:	06054263          	bltz	a0,80004e48 <create+0x11c>
  iunlockput(dp);
    80004de8:	8526                	mv	a0,s1
    80004dea:	89bfe0ef          	jal	80003684 <iunlockput>
  return ip;
    80004dee:	89ca                	mv	s3,s2
    80004df0:	bf71                	j	80004d8c <create+0x60>
    iunlockput(dp);
    80004df2:	8526                	mv	a0,s1
    80004df4:	891fe0ef          	jal	80003684 <iunlockput>
    return 0;
    80004df8:	bf51                	j	80004d8c <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004dfa:	00492603          	lw	a2,4(s2)
    80004dfe:	00003597          	auipc	a1,0x3
    80004e02:	88a58593          	addi	a1,a1,-1910 # 80007688 <etext+0x688>
    80004e06:	854a                	mv	a0,s2
    80004e08:	df5fe0ef          	jal	80003bfc <dirlink>
    80004e0c:	02054e63          	bltz	a0,80004e48 <create+0x11c>
    80004e10:	40d0                	lw	a2,4(s1)
    80004e12:	00003597          	auipc	a1,0x3
    80004e16:	87e58593          	addi	a1,a1,-1922 # 80007690 <etext+0x690>
    80004e1a:	854a                	mv	a0,s2
    80004e1c:	de1fe0ef          	jal	80003bfc <dirlink>
    80004e20:	02054463          	bltz	a0,80004e48 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e24:	00492603          	lw	a2,4(s2)
    80004e28:	fb040593          	addi	a1,s0,-80
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	dcffe0ef          	jal	80003bfc <dirlink>
    80004e32:	00054b63          	bltz	a0,80004e48 <create+0x11c>
    dp->nlink++;  // for ".."
    80004e36:	04a4d783          	lhu	a5,74(s1)
    80004e3a:	2785                	addiw	a5,a5,1
    80004e3c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e40:	8526                	mv	a0,s1
    80004e42:	d82fe0ef          	jal	800033c4 <iupdate>
    80004e46:	b74d                	j	80004de8 <create+0xbc>
  ip->nlink = 0;
    80004e48:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004e4c:	854a                	mv	a0,s2
    80004e4e:	d76fe0ef          	jal	800033c4 <iupdate>
  iunlockput(ip);
    80004e52:	854a                	mv	a0,s2
    80004e54:	831fe0ef          	jal	80003684 <iunlockput>
  iunlockput(dp);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	82bfe0ef          	jal	80003684 <iunlockput>
  return 0;
    80004e5e:	b73d                	j	80004d8c <create+0x60>
    return 0;
    80004e60:	89aa                	mv	s3,a0
    80004e62:	b72d                	j	80004d8c <create+0x60>

0000000080004e64 <sys_dup>:
{
    80004e64:	7179                	addi	sp,sp,-48
    80004e66:	f406                	sd	ra,40(sp)
    80004e68:	f022                	sd	s0,32(sp)
    80004e6a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e6c:	fd840613          	addi	a2,s0,-40
    80004e70:	4581                	li	a1,0
    80004e72:	4501                	li	a0,0
    80004e74:	e1fff0ef          	jal	80004c92 <argfd>
    return -1;
    80004e78:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004e7a:	02054363          	bltz	a0,80004ea0 <sys_dup+0x3c>
    80004e7e:	ec26                	sd	s1,24(sp)
    80004e80:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004e82:	fd843483          	ld	s1,-40(s0)
    80004e86:	8526                	mv	a0,s1
    80004e88:	e65ff0ef          	jal	80004cec <fdalloc>
    80004e8c:	892a                	mv	s2,a0
    return -1;
    80004e8e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e90:	00054d63          	bltz	a0,80004eaa <sys_dup+0x46>
  filedup(f);
    80004e94:	8526                	mv	a0,s1
    80004e96:	bccff0ef          	jal	80004262 <filedup>
  return fd;
    80004e9a:	87ca                	mv	a5,s2
    80004e9c:	64e2                	ld	s1,24(sp)
    80004e9e:	6942                	ld	s2,16(sp)
}
    80004ea0:	853e                	mv	a0,a5
    80004ea2:	70a2                	ld	ra,40(sp)
    80004ea4:	7402                	ld	s0,32(sp)
    80004ea6:	6145                	addi	sp,sp,48
    80004ea8:	8082                	ret
    80004eaa:	64e2                	ld	s1,24(sp)
    80004eac:	6942                	ld	s2,16(sp)
    80004eae:	bfcd                	j	80004ea0 <sys_dup+0x3c>

0000000080004eb0 <sys_read>:
{
    80004eb0:	7179                	addi	sp,sp,-48
    80004eb2:	f406                	sd	ra,40(sp)
    80004eb4:	f022                	sd	s0,32(sp)
    80004eb6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004eb8:	fd840593          	addi	a1,s0,-40
    80004ebc:	4505                	li	a0,1
    80004ebe:	be1fd0ef          	jal	80002a9e <argaddr>
  argint(2, &n);
    80004ec2:	fe440593          	addi	a1,s0,-28
    80004ec6:	4509                	li	a0,2
    80004ec8:	bbbfd0ef          	jal	80002a82 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ecc:	fe840613          	addi	a2,s0,-24
    80004ed0:	4581                	li	a1,0
    80004ed2:	4501                	li	a0,0
    80004ed4:	dbfff0ef          	jal	80004c92 <argfd>
    80004ed8:	87aa                	mv	a5,a0
    return -1;
    80004eda:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004edc:	0007ca63          	bltz	a5,80004ef0 <sys_read+0x40>
  return fileread(f, p, n);
    80004ee0:	fe442603          	lw	a2,-28(s0)
    80004ee4:	fd843583          	ld	a1,-40(s0)
    80004ee8:	fe843503          	ld	a0,-24(s0)
    80004eec:	ce0ff0ef          	jal	800043cc <fileread>
}
    80004ef0:	70a2                	ld	ra,40(sp)
    80004ef2:	7402                	ld	s0,32(sp)
    80004ef4:	6145                	addi	sp,sp,48
    80004ef6:	8082                	ret

0000000080004ef8 <sys_write>:
{
    80004ef8:	7179                	addi	sp,sp,-48
    80004efa:	f406                	sd	ra,40(sp)
    80004efc:	f022                	sd	s0,32(sp)
    80004efe:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f00:	fd840593          	addi	a1,s0,-40
    80004f04:	4505                	li	a0,1
    80004f06:	b99fd0ef          	jal	80002a9e <argaddr>
  argint(2, &n);
    80004f0a:	fe440593          	addi	a1,s0,-28
    80004f0e:	4509                	li	a0,2
    80004f10:	b73fd0ef          	jal	80002a82 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f14:	fe840613          	addi	a2,s0,-24
    80004f18:	4581                	li	a1,0
    80004f1a:	4501                	li	a0,0
    80004f1c:	d77ff0ef          	jal	80004c92 <argfd>
    80004f20:	87aa                	mv	a5,a0
    return -1;
    80004f22:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f24:	0007ca63          	bltz	a5,80004f38 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f28:	fe442603          	lw	a2,-28(s0)
    80004f2c:	fd843583          	ld	a1,-40(s0)
    80004f30:	fe843503          	ld	a0,-24(s0)
    80004f34:	d5cff0ef          	jal	80004490 <filewrite>
}
    80004f38:	70a2                	ld	ra,40(sp)
    80004f3a:	7402                	ld	s0,32(sp)
    80004f3c:	6145                	addi	sp,sp,48
    80004f3e:	8082                	ret

0000000080004f40 <sys_close>:
{
    80004f40:	1101                	addi	sp,sp,-32
    80004f42:	ec06                	sd	ra,24(sp)
    80004f44:	e822                	sd	s0,16(sp)
    80004f46:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f48:	fe040613          	addi	a2,s0,-32
    80004f4c:	fec40593          	addi	a1,s0,-20
    80004f50:	4501                	li	a0,0
    80004f52:	d41ff0ef          	jal	80004c92 <argfd>
    return -1;
    80004f56:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f58:	02054163          	bltz	a0,80004f7a <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f5c:	a3dfc0ef          	jal	80001998 <myproc>
    80004f60:	fec42783          	lw	a5,-20(s0)
    80004f64:	078e                	slli	a5,a5,0x3
    80004f66:	0d078793          	addi	a5,a5,208
    80004f6a:	953e                	add	a0,a0,a5
    80004f6c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f70:	fe043503          	ld	a0,-32(s0)
    80004f74:	b34ff0ef          	jal	800042a8 <fileclose>
  return 0;
    80004f78:	4781                	li	a5,0
}
    80004f7a:	853e                	mv	a0,a5
    80004f7c:	60e2                	ld	ra,24(sp)
    80004f7e:	6442                	ld	s0,16(sp)
    80004f80:	6105                	addi	sp,sp,32
    80004f82:	8082                	ret

0000000080004f84 <sys_fstat>:
{
    80004f84:	1101                	addi	sp,sp,-32
    80004f86:	ec06                	sd	ra,24(sp)
    80004f88:	e822                	sd	s0,16(sp)
    80004f8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f8c:	fe040593          	addi	a1,s0,-32
    80004f90:	4505                	li	a0,1
    80004f92:	b0dfd0ef          	jal	80002a9e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f96:	fe840613          	addi	a2,s0,-24
    80004f9a:	4581                	li	a1,0
    80004f9c:	4501                	li	a0,0
    80004f9e:	cf5ff0ef          	jal	80004c92 <argfd>
    80004fa2:	87aa                	mv	a5,a0
    return -1;
    80004fa4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fa6:	0007c863          	bltz	a5,80004fb6 <sys_fstat+0x32>
  return filestat(f, st);
    80004faa:	fe043583          	ld	a1,-32(s0)
    80004fae:	fe843503          	ld	a0,-24(s0)
    80004fb2:	bb8ff0ef          	jal	8000436a <filestat>
}
    80004fb6:	60e2                	ld	ra,24(sp)
    80004fb8:	6442                	ld	s0,16(sp)
    80004fba:	6105                	addi	sp,sp,32
    80004fbc:	8082                	ret

0000000080004fbe <sys_link>:
{
    80004fbe:	7169                	addi	sp,sp,-304
    80004fc0:	f606                	sd	ra,296(sp)
    80004fc2:	f222                	sd	s0,288(sp)
    80004fc4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fc6:	08000613          	li	a2,128
    80004fca:	ed040593          	addi	a1,s0,-304
    80004fce:	4501                	li	a0,0
    80004fd0:	aebfd0ef          	jal	80002aba <argstr>
    return -1;
    80004fd4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fd6:	0c054e63          	bltz	a0,800050b2 <sys_link+0xf4>
    80004fda:	08000613          	li	a2,128
    80004fde:	f5040593          	addi	a1,s0,-176
    80004fe2:	4505                	li	a0,1
    80004fe4:	ad7fd0ef          	jal	80002aba <argstr>
    return -1;
    80004fe8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004fea:	0c054463          	bltz	a0,800050b2 <sys_link+0xf4>
    80004fee:	ee26                	sd	s1,280(sp)
  begin_op();
    80004ff0:	e95fe0ef          	jal	80003e84 <begin_op>
  if((ip = namei(old)) == 0){
    80004ff4:	ed040513          	addi	a0,s0,-304
    80004ff8:	caffe0ef          	jal	80003ca6 <namei>
    80004ffc:	84aa                	mv	s1,a0
    80004ffe:	c53d                	beqz	a0,8000506c <sys_link+0xae>
  ilock(ip);
    80005000:	c78fe0ef          	jal	80003478 <ilock>
  if(ip->type == T_DIR){
    80005004:	04449703          	lh	a4,68(s1)
    80005008:	4785                	li	a5,1
    8000500a:	06f70663          	beq	a4,a5,80005076 <sys_link+0xb8>
    8000500e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005010:	04a4d783          	lhu	a5,74(s1)
    80005014:	2785                	addiw	a5,a5,1
    80005016:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000501a:	8526                	mv	a0,s1
    8000501c:	ba8fe0ef          	jal	800033c4 <iupdate>
  iunlock(ip);
    80005020:	8526                	mv	a0,s1
    80005022:	d04fe0ef          	jal	80003526 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005026:	fd040593          	addi	a1,s0,-48
    8000502a:	f5040513          	addi	a0,s0,-176
    8000502e:	c93fe0ef          	jal	80003cc0 <nameiparent>
    80005032:	892a                	mv	s2,a0
    80005034:	cd21                	beqz	a0,8000508c <sys_link+0xce>
  ilock(dp);
    80005036:	c42fe0ef          	jal	80003478 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000503a:	854a                	mv	a0,s2
    8000503c:	00092703          	lw	a4,0(s2)
    80005040:	409c                	lw	a5,0(s1)
    80005042:	04f71263          	bne	a4,a5,80005086 <sys_link+0xc8>
    80005046:	40d0                	lw	a2,4(s1)
    80005048:	fd040593          	addi	a1,s0,-48
    8000504c:	bb1fe0ef          	jal	80003bfc <dirlink>
    80005050:	02054b63          	bltz	a0,80005086 <sys_link+0xc8>
  iunlockput(dp);
    80005054:	854a                	mv	a0,s2
    80005056:	e2efe0ef          	jal	80003684 <iunlockput>
  iput(ip);
    8000505a:	8526                	mv	a0,s1
    8000505c:	d9efe0ef          	jal	800035fa <iput>
  end_op();
    80005060:	e95fe0ef          	jal	80003ef4 <end_op>
  return 0;
    80005064:	4781                	li	a5,0
    80005066:	64f2                	ld	s1,280(sp)
    80005068:	6952                	ld	s2,272(sp)
    8000506a:	a0a1                	j	800050b2 <sys_link+0xf4>
    end_op();
    8000506c:	e89fe0ef          	jal	80003ef4 <end_op>
    return -1;
    80005070:	57fd                	li	a5,-1
    80005072:	64f2                	ld	s1,280(sp)
    80005074:	a83d                	j	800050b2 <sys_link+0xf4>
    iunlockput(ip);
    80005076:	8526                	mv	a0,s1
    80005078:	e0cfe0ef          	jal	80003684 <iunlockput>
    end_op();
    8000507c:	e79fe0ef          	jal	80003ef4 <end_op>
    return -1;
    80005080:	57fd                	li	a5,-1
    80005082:	64f2                	ld	s1,280(sp)
    80005084:	a03d                	j	800050b2 <sys_link+0xf4>
    iunlockput(dp);
    80005086:	854a                	mv	a0,s2
    80005088:	dfcfe0ef          	jal	80003684 <iunlockput>
  ilock(ip);
    8000508c:	8526                	mv	a0,s1
    8000508e:	beafe0ef          	jal	80003478 <ilock>
  ip->nlink--;
    80005092:	04a4d783          	lhu	a5,74(s1)
    80005096:	37fd                	addiw	a5,a5,-1
    80005098:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000509c:	8526                	mv	a0,s1
    8000509e:	b26fe0ef          	jal	800033c4 <iupdate>
  iunlockput(ip);
    800050a2:	8526                	mv	a0,s1
    800050a4:	de0fe0ef          	jal	80003684 <iunlockput>
  end_op();
    800050a8:	e4dfe0ef          	jal	80003ef4 <end_op>
  return -1;
    800050ac:	57fd                	li	a5,-1
    800050ae:	64f2                	ld	s1,280(sp)
    800050b0:	6952                	ld	s2,272(sp)
}
    800050b2:	853e                	mv	a0,a5
    800050b4:	70b2                	ld	ra,296(sp)
    800050b6:	7412                	ld	s0,288(sp)
    800050b8:	6155                	addi	sp,sp,304
    800050ba:	8082                	ret

00000000800050bc <sys_unlink>:
{
    800050bc:	7151                	addi	sp,sp,-240
    800050be:	f586                	sd	ra,232(sp)
    800050c0:	f1a2                	sd	s0,224(sp)
    800050c2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050c4:	08000613          	li	a2,128
    800050c8:	f3040593          	addi	a1,s0,-208
    800050cc:	4501                	li	a0,0
    800050ce:	9edfd0ef          	jal	80002aba <argstr>
    800050d2:	14054d63          	bltz	a0,8000522c <sys_unlink+0x170>
    800050d6:	eda6                	sd	s1,216(sp)
  begin_op();
    800050d8:	dadfe0ef          	jal	80003e84 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800050dc:	fb040593          	addi	a1,s0,-80
    800050e0:	f3040513          	addi	a0,s0,-208
    800050e4:	bddfe0ef          	jal	80003cc0 <nameiparent>
    800050e8:	84aa                	mv	s1,a0
    800050ea:	c955                	beqz	a0,8000519e <sys_unlink+0xe2>
  ilock(dp);
    800050ec:	b8cfe0ef          	jal	80003478 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800050f0:	00002597          	auipc	a1,0x2
    800050f4:	59858593          	addi	a1,a1,1432 # 80007688 <etext+0x688>
    800050f8:	fb040513          	addi	a0,s0,-80
    800050fc:	901fe0ef          	jal	800039fc <namecmp>
    80005100:	10050b63          	beqz	a0,80005216 <sys_unlink+0x15a>
    80005104:	00002597          	auipc	a1,0x2
    80005108:	58c58593          	addi	a1,a1,1420 # 80007690 <etext+0x690>
    8000510c:	fb040513          	addi	a0,s0,-80
    80005110:	8edfe0ef          	jal	800039fc <namecmp>
    80005114:	10050163          	beqz	a0,80005216 <sys_unlink+0x15a>
    80005118:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000511a:	f2c40613          	addi	a2,s0,-212
    8000511e:	fb040593          	addi	a1,s0,-80
    80005122:	8526                	mv	a0,s1
    80005124:	8effe0ef          	jal	80003a12 <dirlookup>
    80005128:	892a                	mv	s2,a0
    8000512a:	0e050563          	beqz	a0,80005214 <sys_unlink+0x158>
    8000512e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005130:	b48fe0ef          	jal	80003478 <ilock>
  if(ip->nlink < 1)
    80005134:	04a91783          	lh	a5,74(s2)
    80005138:	06f05863          	blez	a5,800051a8 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000513c:	04491703          	lh	a4,68(s2)
    80005140:	4785                	li	a5,1
    80005142:	06f70963          	beq	a4,a5,800051b4 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005146:	fc040993          	addi	s3,s0,-64
    8000514a:	4641                	li	a2,16
    8000514c:	4581                	li	a1,0
    8000514e:	854e                	mv	a0,s3
    80005150:	ba9fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005154:	4741                	li	a4,16
    80005156:	f2c42683          	lw	a3,-212(s0)
    8000515a:	864e                	mv	a2,s3
    8000515c:	4581                	li	a1,0
    8000515e:	8526                	mv	a0,s1
    80005160:	f9cfe0ef          	jal	800038fc <writei>
    80005164:	47c1                	li	a5,16
    80005166:	08f51863          	bne	a0,a5,800051f6 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    8000516a:	04491703          	lh	a4,68(s2)
    8000516e:	4785                	li	a5,1
    80005170:	08f70963          	beq	a4,a5,80005202 <sys_unlink+0x146>
  iunlockput(dp);
    80005174:	8526                	mv	a0,s1
    80005176:	d0efe0ef          	jal	80003684 <iunlockput>
  ip->nlink--;
    8000517a:	04a95783          	lhu	a5,74(s2)
    8000517e:	37fd                	addiw	a5,a5,-1
    80005180:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005184:	854a                	mv	a0,s2
    80005186:	a3efe0ef          	jal	800033c4 <iupdate>
  iunlockput(ip);
    8000518a:	854a                	mv	a0,s2
    8000518c:	cf8fe0ef          	jal	80003684 <iunlockput>
  end_op();
    80005190:	d65fe0ef          	jal	80003ef4 <end_op>
  return 0;
    80005194:	4501                	li	a0,0
    80005196:	64ee                	ld	s1,216(sp)
    80005198:	694e                	ld	s2,208(sp)
    8000519a:	69ae                	ld	s3,200(sp)
    8000519c:	a061                	j	80005224 <sys_unlink+0x168>
    end_op();
    8000519e:	d57fe0ef          	jal	80003ef4 <end_op>
    return -1;
    800051a2:	557d                	li	a0,-1
    800051a4:	64ee                	ld	s1,216(sp)
    800051a6:	a8bd                	j	80005224 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051a8:	00002517          	auipc	a0,0x2
    800051ac:	4f050513          	addi	a0,a0,1264 # 80007698 <etext+0x698>
    800051b0:	e74fb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051b4:	04c92703          	lw	a4,76(s2)
    800051b8:	02000793          	li	a5,32
    800051bc:	f8e7f5e3          	bgeu	a5,a4,80005146 <sys_unlink+0x8a>
    800051c0:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051c2:	4741                	li	a4,16
    800051c4:	86ce                	mv	a3,s3
    800051c6:	f1840613          	addi	a2,s0,-232
    800051ca:	4581                	li	a1,0
    800051cc:	854a                	mv	a0,s2
    800051ce:	e3cfe0ef          	jal	8000380a <readi>
    800051d2:	47c1                	li	a5,16
    800051d4:	00f51b63          	bne	a0,a5,800051ea <sys_unlink+0x12e>
    if(de.inum != 0)
    800051d8:	f1845783          	lhu	a5,-232(s0)
    800051dc:	ebb1                	bnez	a5,80005230 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051de:	29c1                	addiw	s3,s3,16
    800051e0:	04c92783          	lw	a5,76(s2)
    800051e4:	fcf9efe3          	bltu	s3,a5,800051c2 <sys_unlink+0x106>
    800051e8:	bfb9                	j	80005146 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800051ea:	00002517          	auipc	a0,0x2
    800051ee:	4c650513          	addi	a0,a0,1222 # 800076b0 <etext+0x6b0>
    800051f2:	e32fb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800051f6:	00002517          	auipc	a0,0x2
    800051fa:	4d250513          	addi	a0,a0,1234 # 800076c8 <etext+0x6c8>
    800051fe:	e26fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005202:	04a4d783          	lhu	a5,74(s1)
    80005206:	37fd                	addiw	a5,a5,-1
    80005208:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000520c:	8526                	mv	a0,s1
    8000520e:	9b6fe0ef          	jal	800033c4 <iupdate>
    80005212:	b78d                	j	80005174 <sys_unlink+0xb8>
    80005214:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005216:	8526                	mv	a0,s1
    80005218:	c6cfe0ef          	jal	80003684 <iunlockput>
  end_op();
    8000521c:	cd9fe0ef          	jal	80003ef4 <end_op>
  return -1;
    80005220:	557d                	li	a0,-1
    80005222:	64ee                	ld	s1,216(sp)
}
    80005224:	70ae                	ld	ra,232(sp)
    80005226:	740e                	ld	s0,224(sp)
    80005228:	616d                	addi	sp,sp,240
    8000522a:	8082                	ret
    return -1;
    8000522c:	557d                	li	a0,-1
    8000522e:	bfdd                	j	80005224 <sys_unlink+0x168>
    iunlockput(ip);
    80005230:	854a                	mv	a0,s2
    80005232:	c52fe0ef          	jal	80003684 <iunlockput>
    goto bad;
    80005236:	694e                	ld	s2,208(sp)
    80005238:	69ae                	ld	s3,200(sp)
    8000523a:	bff1                	j	80005216 <sys_unlink+0x15a>

000000008000523c <sys_open>:

uint64
sys_open(void)
{
    8000523c:	7131                	addi	sp,sp,-192
    8000523e:	fd06                	sd	ra,184(sp)
    80005240:	f922                	sd	s0,176(sp)
    80005242:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005244:	f4c40593          	addi	a1,s0,-180
    80005248:	4505                	li	a0,1
    8000524a:	839fd0ef          	jal	80002a82 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000524e:	08000613          	li	a2,128
    80005252:	f5040593          	addi	a1,s0,-176
    80005256:	4501                	li	a0,0
    80005258:	863fd0ef          	jal	80002aba <argstr>
    8000525c:	87aa                	mv	a5,a0
    return -1;
    8000525e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005260:	0a07c363          	bltz	a5,80005306 <sys_open+0xca>
    80005264:	f526                	sd	s1,168(sp)

  begin_op();
    80005266:	c1ffe0ef          	jal	80003e84 <begin_op>

  if(omode & O_CREATE){
    8000526a:	f4c42783          	lw	a5,-180(s0)
    8000526e:	2007f793          	andi	a5,a5,512
    80005272:	c3dd                	beqz	a5,80005318 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005274:	4681                	li	a3,0
    80005276:	4601                	li	a2,0
    80005278:	4589                	li	a1,2
    8000527a:	f5040513          	addi	a0,s0,-176
    8000527e:	aafff0ef          	jal	80004d2c <create>
    80005282:	84aa                	mv	s1,a0
    if(ip == 0){
    80005284:	c549                	beqz	a0,8000530e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005286:	04449703          	lh	a4,68(s1)
    8000528a:	478d                	li	a5,3
    8000528c:	00f71763          	bne	a4,a5,8000529a <sys_open+0x5e>
    80005290:	0464d703          	lhu	a4,70(s1)
    80005294:	47a5                	li	a5,9
    80005296:	0ae7ee63          	bltu	a5,a4,80005352 <sys_open+0x116>
    8000529a:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000529c:	f69fe0ef          	jal	80004204 <filealloc>
    800052a0:	892a                	mv	s2,a0
    800052a2:	c561                	beqz	a0,8000536a <sys_open+0x12e>
    800052a4:	ed4e                	sd	s3,152(sp)
    800052a6:	a47ff0ef          	jal	80004cec <fdalloc>
    800052aa:	89aa                	mv	s3,a0
    800052ac:	0a054b63          	bltz	a0,80005362 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800052b0:	04449703          	lh	a4,68(s1)
    800052b4:	478d                	li	a5,3
    800052b6:	0cf70363          	beq	a4,a5,8000537c <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052ba:	4789                	li	a5,2
    800052bc:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052c0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052c4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052c8:	f4c42783          	lw	a5,-180(s0)
    800052cc:	0017f713          	andi	a4,a5,1
    800052d0:	00174713          	xori	a4,a4,1
    800052d4:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800052d8:	0037f713          	andi	a4,a5,3
    800052dc:	00e03733          	snez	a4,a4
    800052e0:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800052e4:	4007f793          	andi	a5,a5,1024
    800052e8:	c791                	beqz	a5,800052f4 <sys_open+0xb8>
    800052ea:	04449703          	lh	a4,68(s1)
    800052ee:	4789                	li	a5,2
    800052f0:	08f70d63          	beq	a4,a5,8000538a <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800052f4:	8526                	mv	a0,s1
    800052f6:	a30fe0ef          	jal	80003526 <iunlock>
  end_op();
    800052fa:	bfbfe0ef          	jal	80003ef4 <end_op>

  return fd;
    800052fe:	854e                	mv	a0,s3
    80005300:	74aa                	ld	s1,168(sp)
    80005302:	790a                	ld	s2,160(sp)
    80005304:	69ea                	ld	s3,152(sp)
}
    80005306:	70ea                	ld	ra,184(sp)
    80005308:	744a                	ld	s0,176(sp)
    8000530a:	6129                	addi	sp,sp,192
    8000530c:	8082                	ret
      end_op();
    8000530e:	be7fe0ef          	jal	80003ef4 <end_op>
      return -1;
    80005312:	557d                	li	a0,-1
    80005314:	74aa                	ld	s1,168(sp)
    80005316:	bfc5                	j	80005306 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005318:	f5040513          	addi	a0,s0,-176
    8000531c:	98bfe0ef          	jal	80003ca6 <namei>
    80005320:	84aa                	mv	s1,a0
    80005322:	c11d                	beqz	a0,80005348 <sys_open+0x10c>
    ilock(ip);
    80005324:	954fe0ef          	jal	80003478 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005328:	04449703          	lh	a4,68(s1)
    8000532c:	4785                	li	a5,1
    8000532e:	f4f71ce3          	bne	a4,a5,80005286 <sys_open+0x4a>
    80005332:	f4c42783          	lw	a5,-180(s0)
    80005336:	d3b5                	beqz	a5,8000529a <sys_open+0x5e>
      iunlockput(ip);
    80005338:	8526                	mv	a0,s1
    8000533a:	b4afe0ef          	jal	80003684 <iunlockput>
      end_op();
    8000533e:	bb7fe0ef          	jal	80003ef4 <end_op>
      return -1;
    80005342:	557d                	li	a0,-1
    80005344:	74aa                	ld	s1,168(sp)
    80005346:	b7c1                	j	80005306 <sys_open+0xca>
      end_op();
    80005348:	badfe0ef          	jal	80003ef4 <end_op>
      return -1;
    8000534c:	557d                	li	a0,-1
    8000534e:	74aa                	ld	s1,168(sp)
    80005350:	bf5d                	j	80005306 <sys_open+0xca>
    iunlockput(ip);
    80005352:	8526                	mv	a0,s1
    80005354:	b30fe0ef          	jal	80003684 <iunlockput>
    end_op();
    80005358:	b9dfe0ef          	jal	80003ef4 <end_op>
    return -1;
    8000535c:	557d                	li	a0,-1
    8000535e:	74aa                	ld	s1,168(sp)
    80005360:	b75d                	j	80005306 <sys_open+0xca>
      fileclose(f);
    80005362:	854a                	mv	a0,s2
    80005364:	f45fe0ef          	jal	800042a8 <fileclose>
    80005368:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000536a:	8526                	mv	a0,s1
    8000536c:	b18fe0ef          	jal	80003684 <iunlockput>
    end_op();
    80005370:	b85fe0ef          	jal	80003ef4 <end_op>
    return -1;
    80005374:	557d                	li	a0,-1
    80005376:	74aa                	ld	s1,168(sp)
    80005378:	790a                	ld	s2,160(sp)
    8000537a:	b771                	j	80005306 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000537c:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005380:	04649783          	lh	a5,70(s1)
    80005384:	02f91223          	sh	a5,36(s2)
    80005388:	bf35                	j	800052c4 <sys_open+0x88>
    itrunc(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	9dafe0ef          	jal	80003566 <itrunc>
    80005390:	b795                	j	800052f4 <sys_open+0xb8>

0000000080005392 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005392:	7175                	addi	sp,sp,-144
    80005394:	e506                	sd	ra,136(sp)
    80005396:	e122                	sd	s0,128(sp)
    80005398:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000539a:	aebfe0ef          	jal	80003e84 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000539e:	08000613          	li	a2,128
    800053a2:	f7040593          	addi	a1,s0,-144
    800053a6:	4501                	li	a0,0
    800053a8:	f12fd0ef          	jal	80002aba <argstr>
    800053ac:	02054363          	bltz	a0,800053d2 <sys_mkdir+0x40>
    800053b0:	4681                	li	a3,0
    800053b2:	4601                	li	a2,0
    800053b4:	4585                	li	a1,1
    800053b6:	f7040513          	addi	a0,s0,-144
    800053ba:	973ff0ef          	jal	80004d2c <create>
    800053be:	c911                	beqz	a0,800053d2 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053c0:	ac4fe0ef          	jal	80003684 <iunlockput>
  end_op();
    800053c4:	b31fe0ef          	jal	80003ef4 <end_op>
  return 0;
    800053c8:	4501                	li	a0,0
}
    800053ca:	60aa                	ld	ra,136(sp)
    800053cc:	640a                	ld	s0,128(sp)
    800053ce:	6149                	addi	sp,sp,144
    800053d0:	8082                	ret
    end_op();
    800053d2:	b23fe0ef          	jal	80003ef4 <end_op>
    return -1;
    800053d6:	557d                	li	a0,-1
    800053d8:	bfcd                	j	800053ca <sys_mkdir+0x38>

00000000800053da <sys_mknod>:

uint64
sys_mknod(void)
{
    800053da:	7135                	addi	sp,sp,-160
    800053dc:	ed06                	sd	ra,152(sp)
    800053de:	e922                	sd	s0,144(sp)
    800053e0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800053e2:	aa3fe0ef          	jal	80003e84 <begin_op>
  argint(1, &major);
    800053e6:	f6c40593          	addi	a1,s0,-148
    800053ea:	4505                	li	a0,1
    800053ec:	e96fd0ef          	jal	80002a82 <argint>
  argint(2, &minor);
    800053f0:	f6840593          	addi	a1,s0,-152
    800053f4:	4509                	li	a0,2
    800053f6:	e8cfd0ef          	jal	80002a82 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800053fa:	08000613          	li	a2,128
    800053fe:	f7040593          	addi	a1,s0,-144
    80005402:	4501                	li	a0,0
    80005404:	eb6fd0ef          	jal	80002aba <argstr>
    80005408:	02054563          	bltz	a0,80005432 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000540c:	f6841683          	lh	a3,-152(s0)
    80005410:	f6c41603          	lh	a2,-148(s0)
    80005414:	458d                	li	a1,3
    80005416:	f7040513          	addi	a0,s0,-144
    8000541a:	913ff0ef          	jal	80004d2c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000541e:	c911                	beqz	a0,80005432 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005420:	a64fe0ef          	jal	80003684 <iunlockput>
  end_op();
    80005424:	ad1fe0ef          	jal	80003ef4 <end_op>
  return 0;
    80005428:	4501                	li	a0,0
}
    8000542a:	60ea                	ld	ra,152(sp)
    8000542c:	644a                	ld	s0,144(sp)
    8000542e:	610d                	addi	sp,sp,160
    80005430:	8082                	ret
    end_op();
    80005432:	ac3fe0ef          	jal	80003ef4 <end_op>
    return -1;
    80005436:	557d                	li	a0,-1
    80005438:	bfcd                	j	8000542a <sys_mknod+0x50>

000000008000543a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000543a:	7135                	addi	sp,sp,-160
    8000543c:	ed06                	sd	ra,152(sp)
    8000543e:	e922                	sd	s0,144(sp)
    80005440:	e14a                	sd	s2,128(sp)
    80005442:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005444:	d54fc0ef          	jal	80001998 <myproc>
    80005448:	892a                	mv	s2,a0
  
  begin_op();
    8000544a:	a3bfe0ef          	jal	80003e84 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000544e:	08000613          	li	a2,128
    80005452:	f6040593          	addi	a1,s0,-160
    80005456:	4501                	li	a0,0
    80005458:	e62fd0ef          	jal	80002aba <argstr>
    8000545c:	04054363          	bltz	a0,800054a2 <sys_chdir+0x68>
    80005460:	e526                	sd	s1,136(sp)
    80005462:	f6040513          	addi	a0,s0,-160
    80005466:	841fe0ef          	jal	80003ca6 <namei>
    8000546a:	84aa                	mv	s1,a0
    8000546c:	c915                	beqz	a0,800054a0 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000546e:	80afe0ef          	jal	80003478 <ilock>
  if(ip->type != T_DIR){
    80005472:	04449703          	lh	a4,68(s1)
    80005476:	4785                	li	a5,1
    80005478:	02f71963          	bne	a4,a5,800054aa <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000547c:	8526                	mv	a0,s1
    8000547e:	8a8fe0ef          	jal	80003526 <iunlock>
  iput(p->cwd);
    80005482:	15093503          	ld	a0,336(s2)
    80005486:	974fe0ef          	jal	800035fa <iput>
  end_op();
    8000548a:	a6bfe0ef          	jal	80003ef4 <end_op>
  p->cwd = ip;
    8000548e:	14993823          	sd	s1,336(s2)
  return 0;
    80005492:	4501                	li	a0,0
    80005494:	64aa                	ld	s1,136(sp)
}
    80005496:	60ea                	ld	ra,152(sp)
    80005498:	644a                	ld	s0,144(sp)
    8000549a:	690a                	ld	s2,128(sp)
    8000549c:	610d                	addi	sp,sp,160
    8000549e:	8082                	ret
    800054a0:	64aa                	ld	s1,136(sp)
    end_op();
    800054a2:	a53fe0ef          	jal	80003ef4 <end_op>
    return -1;
    800054a6:	557d                	li	a0,-1
    800054a8:	b7fd                	j	80005496 <sys_chdir+0x5c>
    iunlockput(ip);
    800054aa:	8526                	mv	a0,s1
    800054ac:	9d8fe0ef          	jal	80003684 <iunlockput>
    end_op();
    800054b0:	a45fe0ef          	jal	80003ef4 <end_op>
    return -1;
    800054b4:	557d                	li	a0,-1
    800054b6:	64aa                	ld	s1,136(sp)
    800054b8:	bff9                	j	80005496 <sys_chdir+0x5c>

00000000800054ba <sys_exec>:

uint64
sys_exec(void)
{
    800054ba:	7105                	addi	sp,sp,-480
    800054bc:	ef86                	sd	ra,472(sp)
    800054be:	eba2                	sd	s0,464(sp)
    800054c0:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054c2:	e2840593          	addi	a1,s0,-472
    800054c6:	4505                	li	a0,1
    800054c8:	dd6fd0ef          	jal	80002a9e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054cc:	08000613          	li	a2,128
    800054d0:	f3040593          	addi	a1,s0,-208
    800054d4:	4501                	li	a0,0
    800054d6:	de4fd0ef          	jal	80002aba <argstr>
    800054da:	87aa                	mv	a5,a0
    return -1;
    800054dc:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800054de:	0e07c063          	bltz	a5,800055be <sys_exec+0x104>
    800054e2:	e7a6                	sd	s1,456(sp)
    800054e4:	e3ca                	sd	s2,448(sp)
    800054e6:	ff4e                	sd	s3,440(sp)
    800054e8:	fb52                	sd	s4,432(sp)
    800054ea:	f756                	sd	s5,424(sp)
    800054ec:	f35a                	sd	s6,416(sp)
    800054ee:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800054f0:	e3040a13          	addi	s4,s0,-464
    800054f4:	10000613          	li	a2,256
    800054f8:	4581                	li	a1,0
    800054fa:	8552                	mv	a0,s4
    800054fc:	ffcfb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005500:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005502:	89d2                	mv	s3,s4
    80005504:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005506:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000550a:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000550c:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005510:	00391513          	slli	a0,s2,0x3
    80005514:	85d6                	mv	a1,s5
    80005516:	e2843783          	ld	a5,-472(s0)
    8000551a:	953e                	add	a0,a0,a5
    8000551c:	cdcfd0ef          	jal	800029f8 <fetchaddr>
    80005520:	02054663          	bltz	a0,8000554c <sys_exec+0x92>
    if(uarg == 0){
    80005524:	e2043783          	ld	a5,-480(s0)
    80005528:	c7a1                	beqz	a5,80005570 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000552a:	e1afb0ef          	jal	80000b44 <kalloc>
    8000552e:	85aa                	mv	a1,a0
    80005530:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005534:	cd01                	beqz	a0,8000554c <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005536:	865a                	mv	a2,s6
    80005538:	e2043503          	ld	a0,-480(s0)
    8000553c:	d06fd0ef          	jal	80002a42 <fetchstr>
    80005540:	00054663          	bltz	a0,8000554c <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005544:	0905                	addi	s2,s2,1
    80005546:	09a1                	addi	s3,s3,8
    80005548:	fd7914e3          	bne	s2,s7,80005510 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000554c:	100a0a13          	addi	s4,s4,256
    80005550:	6088                	ld	a0,0(s1)
    80005552:	cd31                	beqz	a0,800055ae <sys_exec+0xf4>
    kfree(argv[i]);
    80005554:	d08fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005558:	04a1                	addi	s1,s1,8
    8000555a:	ff449be3          	bne	s1,s4,80005550 <sys_exec+0x96>
  return -1;
    8000555e:	557d                	li	a0,-1
    80005560:	64be                	ld	s1,456(sp)
    80005562:	691e                	ld	s2,448(sp)
    80005564:	79fa                	ld	s3,440(sp)
    80005566:	7a5a                	ld	s4,432(sp)
    80005568:	7aba                	ld	s5,424(sp)
    8000556a:	7b1a                	ld	s6,416(sp)
    8000556c:	6bfa                	ld	s7,408(sp)
    8000556e:	a881                	j	800055be <sys_exec+0x104>
      argv[i] = 0;
    80005570:	0009079b          	sext.w	a5,s2
    80005574:	e3040593          	addi	a1,s0,-464
    80005578:	078e                	slli	a5,a5,0x3
    8000557a:	97ae                	add	a5,a5,a1
    8000557c:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005580:	f3040513          	addi	a0,s0,-208
    80005584:	bb2ff0ef          	jal	80004936 <kexec>
    80005588:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000558a:	100a0a13          	addi	s4,s4,256
    8000558e:	6088                	ld	a0,0(s1)
    80005590:	c511                	beqz	a0,8000559c <sys_exec+0xe2>
    kfree(argv[i]);
    80005592:	ccafb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005596:	04a1                	addi	s1,s1,8
    80005598:	ff449be3          	bne	s1,s4,8000558e <sys_exec+0xd4>
  return ret;
    8000559c:	854a                	mv	a0,s2
    8000559e:	64be                	ld	s1,456(sp)
    800055a0:	691e                	ld	s2,448(sp)
    800055a2:	79fa                	ld	s3,440(sp)
    800055a4:	7a5a                	ld	s4,432(sp)
    800055a6:	7aba                	ld	s5,424(sp)
    800055a8:	7b1a                	ld	s6,416(sp)
    800055aa:	6bfa                	ld	s7,408(sp)
    800055ac:	a809                	j	800055be <sys_exec+0x104>
  return -1;
    800055ae:	557d                	li	a0,-1
    800055b0:	64be                	ld	s1,456(sp)
    800055b2:	691e                	ld	s2,448(sp)
    800055b4:	79fa                	ld	s3,440(sp)
    800055b6:	7a5a                	ld	s4,432(sp)
    800055b8:	7aba                	ld	s5,424(sp)
    800055ba:	7b1a                	ld	s6,416(sp)
    800055bc:	6bfa                	ld	s7,408(sp)
}
    800055be:	60fe                	ld	ra,472(sp)
    800055c0:	645e                	ld	s0,464(sp)
    800055c2:	613d                	addi	sp,sp,480
    800055c4:	8082                	ret

00000000800055c6 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055c6:	7139                	addi	sp,sp,-64
    800055c8:	fc06                	sd	ra,56(sp)
    800055ca:	f822                	sd	s0,48(sp)
    800055cc:	f426                	sd	s1,40(sp)
    800055ce:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055d0:	bc8fc0ef          	jal	80001998 <myproc>
    800055d4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800055d6:	fd840593          	addi	a1,s0,-40
    800055da:	4501                	li	a0,0
    800055dc:	cc2fd0ef          	jal	80002a9e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800055e0:	fc840593          	addi	a1,s0,-56
    800055e4:	fd040513          	addi	a0,s0,-48
    800055e8:	fddfe0ef          	jal	800045c4 <pipealloc>
    return -1;
    800055ec:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800055ee:	0a054763          	bltz	a0,8000569c <sys_pipe+0xd6>
  fd0 = -1;
    800055f2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800055f6:	fd043503          	ld	a0,-48(s0)
    800055fa:	ef2ff0ef          	jal	80004cec <fdalloc>
    800055fe:	fca42223          	sw	a0,-60(s0)
    80005602:	08054463          	bltz	a0,8000568a <sys_pipe+0xc4>
    80005606:	fc843503          	ld	a0,-56(s0)
    8000560a:	ee2ff0ef          	jal	80004cec <fdalloc>
    8000560e:	fca42023          	sw	a0,-64(s0)
    80005612:	06054263          	bltz	a0,80005676 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005616:	4691                	li	a3,4
    80005618:	fc440613          	addi	a2,s0,-60
    8000561c:	fd843583          	ld	a1,-40(s0)
    80005620:	68a8                	ld	a0,80(s1)
    80005622:	832fc0ef          	jal	80001654 <copyout>
    80005626:	00054e63          	bltz	a0,80005642 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000562a:	4691                	li	a3,4
    8000562c:	fc040613          	addi	a2,s0,-64
    80005630:	fd843583          	ld	a1,-40(s0)
    80005634:	95b6                	add	a1,a1,a3
    80005636:	68a8                	ld	a0,80(s1)
    80005638:	81cfc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000563c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000563e:	04055f63          	bgez	a0,8000569c <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005642:	fc442783          	lw	a5,-60(s0)
    80005646:	078e                	slli	a5,a5,0x3
    80005648:	0d078793          	addi	a5,a5,208
    8000564c:	97a6                	add	a5,a5,s1
    8000564e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005652:	fc042783          	lw	a5,-64(s0)
    80005656:	078e                	slli	a5,a5,0x3
    80005658:	0d078793          	addi	a5,a5,208
    8000565c:	97a6                	add	a5,a5,s1
    8000565e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005662:	fd043503          	ld	a0,-48(s0)
    80005666:	c43fe0ef          	jal	800042a8 <fileclose>
    fileclose(wf);
    8000566a:	fc843503          	ld	a0,-56(s0)
    8000566e:	c3bfe0ef          	jal	800042a8 <fileclose>
    return -1;
    80005672:	57fd                	li	a5,-1
    80005674:	a025                	j	8000569c <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005676:	fc442783          	lw	a5,-60(s0)
    8000567a:	0007c863          	bltz	a5,8000568a <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000567e:	078e                	slli	a5,a5,0x3
    80005680:	0d078793          	addi	a5,a5,208
    80005684:	97a6                	add	a5,a5,s1
    80005686:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000568a:	fd043503          	ld	a0,-48(s0)
    8000568e:	c1bfe0ef          	jal	800042a8 <fileclose>
    fileclose(wf);
    80005692:	fc843503          	ld	a0,-56(s0)
    80005696:	c13fe0ef          	jal	800042a8 <fileclose>
    return -1;
    8000569a:	57fd                	li	a5,-1
}
    8000569c:	853e                	mv	a0,a5
    8000569e:	70e2                	ld	ra,56(sp)
    800056a0:	7442                	ld	s0,48(sp)
    800056a2:	74a2                	ld	s1,40(sp)
    800056a4:	6121                	addi	sp,sp,64
    800056a6:	8082                	ret
	...

00000000800056b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800056b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800056b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800056b4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800056b6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800056b8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800056ba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800056bc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800056be:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800056c0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800056c2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800056c4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800056c6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800056c8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800056ca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800056cc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800056ce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800056d0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800056d2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800056d4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800056d6:	a30fd0ef          	jal	80002906 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800056da:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800056dc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800056de:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800056e0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800056e2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800056e4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800056e6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800056e8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800056ea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800056ec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800056ee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800056f0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800056f2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800056f4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800056f6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800056f8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800056fa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800056fc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800056fe:	10200073          	sret
    80005702:	00000013          	nop
    80005706:	00000013          	nop
    8000570a:	00000013          	nop

000000008000570e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000570e:	1141                	addi	sp,sp,-16
    80005710:	e406                	sd	ra,8(sp)
    80005712:	e022                	sd	s0,0(sp)
    80005714:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005716:	0c000737          	lui	a4,0xc000
    8000571a:	4785                	li	a5,1
    8000571c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000571e:	c35c                	sw	a5,4(a4)
}
    80005720:	60a2                	ld	ra,8(sp)
    80005722:	6402                	ld	s0,0(sp)
    80005724:	0141                	addi	sp,sp,16
    80005726:	8082                	ret

0000000080005728 <plicinithart>:

void
plicinithart(void)
{
    80005728:	1141                	addi	sp,sp,-16
    8000572a:	e406                	sd	ra,8(sp)
    8000572c:	e022                	sd	s0,0(sp)
    8000572e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005730:	a34fc0ef          	jal	80001964 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005734:	0085171b          	slliw	a4,a0,0x8
    80005738:	0c0027b7          	lui	a5,0xc002
    8000573c:	97ba                	add	a5,a5,a4
    8000573e:	40200713          	li	a4,1026
    80005742:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005746:	00d5151b          	slliw	a0,a0,0xd
    8000574a:	0c2017b7          	lui	a5,0xc201
    8000574e:	97aa                	add	a5,a5,a0
    80005750:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005754:	60a2                	ld	ra,8(sp)
    80005756:	6402                	ld	s0,0(sp)
    80005758:	0141                	addi	sp,sp,16
    8000575a:	8082                	ret

000000008000575c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000575c:	1141                	addi	sp,sp,-16
    8000575e:	e406                	sd	ra,8(sp)
    80005760:	e022                	sd	s0,0(sp)
    80005762:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005764:	a00fc0ef          	jal	80001964 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005768:	00d5151b          	slliw	a0,a0,0xd
    8000576c:	0c2017b7          	lui	a5,0xc201
    80005770:	97aa                	add	a5,a5,a0
  return irq;
}
    80005772:	43c8                	lw	a0,4(a5)
    80005774:	60a2                	ld	ra,8(sp)
    80005776:	6402                	ld	s0,0(sp)
    80005778:	0141                	addi	sp,sp,16
    8000577a:	8082                	ret

000000008000577c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000577c:	1101                	addi	sp,sp,-32
    8000577e:	ec06                	sd	ra,24(sp)
    80005780:	e822                	sd	s0,16(sp)
    80005782:	e426                	sd	s1,8(sp)
    80005784:	1000                	addi	s0,sp,32
    80005786:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005788:	9dcfc0ef          	jal	80001964 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000578c:	00d5179b          	slliw	a5,a0,0xd
    80005790:	0c201737          	lui	a4,0xc201
    80005794:	97ba                	add	a5,a5,a4
    80005796:	c3c4                	sw	s1,4(a5)
}
    80005798:	60e2                	ld	ra,24(sp)
    8000579a:	6442                	ld	s0,16(sp)
    8000579c:	64a2                	ld	s1,8(sp)
    8000579e:	6105                	addi	sp,sp,32
    800057a0:	8082                	ret

00000000800057a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800057a2:	1141                	addi	sp,sp,-16
    800057a4:	e406                	sd	ra,8(sp)
    800057a6:	e022                	sd	s0,0(sp)
    800057a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800057aa:	479d                	li	a5,7
    800057ac:	04a7ca63          	blt	a5,a0,80005800 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800057b0:	0001e797          	auipc	a5,0x1e
    800057b4:	e3878793          	addi	a5,a5,-456 # 800235e8 <disk>
    800057b8:	97aa                	add	a5,a5,a0
    800057ba:	0187c783          	lbu	a5,24(a5)
    800057be:	e7b9                	bnez	a5,8000580c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800057c0:	00451693          	slli	a3,a0,0x4
    800057c4:	0001e797          	auipc	a5,0x1e
    800057c8:	e2478793          	addi	a5,a5,-476 # 800235e8 <disk>
    800057cc:	6398                	ld	a4,0(a5)
    800057ce:	9736                	add	a4,a4,a3
    800057d0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800057d4:	6398                	ld	a4,0(a5)
    800057d6:	9736                	add	a4,a4,a3
    800057d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800057dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800057e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800057e4:	97aa                	add	a5,a5,a0
    800057e6:	4705                	li	a4,1
    800057e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800057ec:	0001e517          	auipc	a0,0x1e
    800057f0:	e1450513          	addi	a0,a0,-492 # 80023600 <disk+0x18>
    800057f4:	8b1fc0ef          	jal	800020a4 <wakeup>
}
    800057f8:	60a2                	ld	ra,8(sp)
    800057fa:	6402                	ld	s0,0(sp)
    800057fc:	0141                	addi	sp,sp,16
    800057fe:	8082                	ret
    panic("free_desc 1");
    80005800:	00002517          	auipc	a0,0x2
    80005804:	ed850513          	addi	a0,a0,-296 # 800076d8 <etext+0x6d8>
    80005808:	81cfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000580c:	00002517          	auipc	a0,0x2
    80005810:	edc50513          	addi	a0,a0,-292 # 800076e8 <etext+0x6e8>
    80005814:	810fb0ef          	jal	80000824 <panic>

0000000080005818 <virtio_disk_init>:
{
    80005818:	1101                	addi	sp,sp,-32
    8000581a:	ec06                	sd	ra,24(sp)
    8000581c:	e822                	sd	s0,16(sp)
    8000581e:	e426                	sd	s1,8(sp)
    80005820:	e04a                	sd	s2,0(sp)
    80005822:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005824:	00002597          	auipc	a1,0x2
    80005828:	ed458593          	addi	a1,a1,-300 # 800076f8 <etext+0x6f8>
    8000582c:	0001e517          	auipc	a0,0x1e
    80005830:	ee450513          	addi	a0,a0,-284 # 80023710 <disk+0x128>
    80005834:	b6afb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005838:	100017b7          	lui	a5,0x10001
    8000583c:	4398                	lw	a4,0(a5)
    8000583e:	2701                	sext.w	a4,a4
    80005840:	747277b7          	lui	a5,0x74727
    80005844:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005848:	14f71863          	bne	a4,a5,80005998 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000584c:	100017b7          	lui	a5,0x10001
    80005850:	43dc                	lw	a5,4(a5)
    80005852:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005854:	4709                	li	a4,2
    80005856:	14e79163          	bne	a5,a4,80005998 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000585a:	100017b7          	lui	a5,0x10001
    8000585e:	479c                	lw	a5,8(a5)
    80005860:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005862:	12e79b63          	bne	a5,a4,80005998 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005866:	100017b7          	lui	a5,0x10001
    8000586a:	47d8                	lw	a4,12(a5)
    8000586c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000586e:	554d47b7          	lui	a5,0x554d4
    80005872:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005876:	12f71163          	bne	a4,a5,80005998 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000587a:	100017b7          	lui	a5,0x10001
    8000587e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005882:	4705                	li	a4,1
    80005884:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005886:	470d                	li	a4,3
    80005888:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000588a:	10001737          	lui	a4,0x10001
    8000588e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005890:	c7ffe6b7          	lui	a3,0xc7ffe
    80005894:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb037>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005898:	8f75                	and	a4,a4,a3
    8000589a:	100016b7          	lui	a3,0x10001
    8000589e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058a0:	472d                	li	a4,11
    800058a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058a4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800058a8:	439c                	lw	a5,0(a5)
    800058aa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800058ae:	8ba1                	andi	a5,a5,8
    800058b0:	0e078a63          	beqz	a5,800059a4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800058b4:	100017b7          	lui	a5,0x10001
    800058b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800058bc:	43fc                	lw	a5,68(a5)
    800058be:	2781                	sext.w	a5,a5
    800058c0:	0e079863          	bnez	a5,800059b0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800058c4:	100017b7          	lui	a5,0x10001
    800058c8:	5bdc                	lw	a5,52(a5)
    800058ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800058cc:	0e078863          	beqz	a5,800059bc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800058d0:	471d                	li	a4,7
    800058d2:	0ef77b63          	bgeu	a4,a5,800059c8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800058d6:	a6efb0ef          	jal	80000b44 <kalloc>
    800058da:	0001e497          	auipc	s1,0x1e
    800058de:	d0e48493          	addi	s1,s1,-754 # 800235e8 <disk>
    800058e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800058e4:	a60fb0ef          	jal	80000b44 <kalloc>
    800058e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800058ea:	a5afb0ef          	jal	80000b44 <kalloc>
    800058ee:	87aa                	mv	a5,a0
    800058f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800058f2:	6088                	ld	a0,0(s1)
    800058f4:	0e050063          	beqz	a0,800059d4 <virtio_disk_init+0x1bc>
    800058f8:	0001e717          	auipc	a4,0x1e
    800058fc:	cf873703          	ld	a4,-776(a4) # 800235f0 <disk+0x8>
    80005900:	cb71                	beqz	a4,800059d4 <virtio_disk_init+0x1bc>
    80005902:	cbe9                	beqz	a5,800059d4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005904:	6605                	lui	a2,0x1
    80005906:	4581                	li	a1,0
    80005908:	bf0fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000590c:	0001e497          	auipc	s1,0x1e
    80005910:	cdc48493          	addi	s1,s1,-804 # 800235e8 <disk>
    80005914:	6605                	lui	a2,0x1
    80005916:	4581                	li	a1,0
    80005918:	6488                	ld	a0,8(s1)
    8000591a:	bdefb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000591e:	6605                	lui	a2,0x1
    80005920:	4581                	li	a1,0
    80005922:	6888                	ld	a0,16(s1)
    80005924:	bd4fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005928:	100017b7          	lui	a5,0x10001
    8000592c:	4721                	li	a4,8
    8000592e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005930:	4098                	lw	a4,0(s1)
    80005932:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005936:	40d8                	lw	a4,4(s1)
    80005938:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000593c:	649c                	ld	a5,8(s1)
    8000593e:	0007869b          	sext.w	a3,a5
    80005942:	10001737          	lui	a4,0x10001
    80005946:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000594a:	9781                	srai	a5,a5,0x20
    8000594c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005950:	689c                	ld	a5,16(s1)
    80005952:	0007869b          	sext.w	a3,a5
    80005956:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000595a:	9781                	srai	a5,a5,0x20
    8000595c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005960:	4785                	li	a5,1
    80005962:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005964:	00f48c23          	sb	a5,24(s1)
    80005968:	00f48ca3          	sb	a5,25(s1)
    8000596c:	00f48d23          	sb	a5,26(s1)
    80005970:	00f48da3          	sb	a5,27(s1)
    80005974:	00f48e23          	sb	a5,28(s1)
    80005978:	00f48ea3          	sb	a5,29(s1)
    8000597c:	00f48f23          	sb	a5,30(s1)
    80005980:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005984:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005988:	07272823          	sw	s2,112(a4)
}
    8000598c:	60e2                	ld	ra,24(sp)
    8000598e:	6442                	ld	s0,16(sp)
    80005990:	64a2                	ld	s1,8(sp)
    80005992:	6902                	ld	s2,0(sp)
    80005994:	6105                	addi	sp,sp,32
    80005996:	8082                	ret
    panic("could not find virtio disk");
    80005998:	00002517          	auipc	a0,0x2
    8000599c:	d7050513          	addi	a0,a0,-656 # 80007708 <etext+0x708>
    800059a0:	e85fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    800059a4:	00002517          	auipc	a0,0x2
    800059a8:	d8450513          	addi	a0,a0,-636 # 80007728 <etext+0x728>
    800059ac:	e79fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    800059b0:	00002517          	auipc	a0,0x2
    800059b4:	d9850513          	addi	a0,a0,-616 # 80007748 <etext+0x748>
    800059b8:	e6dfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    800059bc:	00002517          	auipc	a0,0x2
    800059c0:	dac50513          	addi	a0,a0,-596 # 80007768 <etext+0x768>
    800059c4:	e61fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    800059c8:	00002517          	auipc	a0,0x2
    800059cc:	dc050513          	addi	a0,a0,-576 # 80007788 <etext+0x788>
    800059d0:	e55fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    800059d4:	00002517          	auipc	a0,0x2
    800059d8:	dd450513          	addi	a0,a0,-556 # 800077a8 <etext+0x7a8>
    800059dc:	e49fa0ef          	jal	80000824 <panic>

00000000800059e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800059e0:	711d                	addi	sp,sp,-96
    800059e2:	ec86                	sd	ra,88(sp)
    800059e4:	e8a2                	sd	s0,80(sp)
    800059e6:	e4a6                	sd	s1,72(sp)
    800059e8:	e0ca                	sd	s2,64(sp)
    800059ea:	fc4e                	sd	s3,56(sp)
    800059ec:	f852                	sd	s4,48(sp)
    800059ee:	f456                	sd	s5,40(sp)
    800059f0:	f05a                	sd	s6,32(sp)
    800059f2:	ec5e                	sd	s7,24(sp)
    800059f4:	e862                	sd	s8,16(sp)
    800059f6:	1080                	addi	s0,sp,96
    800059f8:	89aa                	mv	s3,a0
    800059fa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800059fc:	00c52b83          	lw	s7,12(a0)
    80005a00:	001b9b9b          	slliw	s7,s7,0x1
    80005a04:	1b82                	slli	s7,s7,0x20
    80005a06:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a0a:	0001e517          	auipc	a0,0x1e
    80005a0e:	d0650513          	addi	a0,a0,-762 # 80023710 <disk+0x128>
    80005a12:	a16fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005a16:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a18:	0001ea97          	auipc	s5,0x1e
    80005a1c:	bd0a8a93          	addi	s5,s5,-1072 # 800235e8 <disk>
  for(int i = 0; i < 3; i++){
    80005a20:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a22:	5c7d                	li	s8,-1
    80005a24:	a095                	j	80005a88 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005a26:	00fa8733          	add	a4,s5,a5
    80005a2a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a2e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a30:	0207c563          	bltz	a5,80005a5a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005a34:	2905                	addiw	s2,s2,1
    80005a36:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a38:	05490c63          	beq	s2,s4,80005a90 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005a3c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a3e:	0001e717          	auipc	a4,0x1e
    80005a42:	baa70713          	addi	a4,a4,-1110 # 800235e8 <disk>
    80005a46:	4781                	li	a5,0
    if(disk.free[i]){
    80005a48:	01874683          	lbu	a3,24(a4)
    80005a4c:	fee9                	bnez	a3,80005a26 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005a4e:	2785                	addiw	a5,a5,1
    80005a50:	0705                	addi	a4,a4,1
    80005a52:	fe979be3          	bne	a5,s1,80005a48 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005a56:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005a5a:	01205d63          	blez	s2,80005a74 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a5e:	fa042503          	lw	a0,-96(s0)
    80005a62:	d41ff0ef          	jal	800057a2 <free_desc>
      for(int j = 0; j < i; j++)
    80005a66:	4785                	li	a5,1
    80005a68:	0127d663          	bge	a5,s2,80005a74 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005a6c:	fa442503          	lw	a0,-92(s0)
    80005a70:	d33ff0ef          	jal	800057a2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005a74:	0001e597          	auipc	a1,0x1e
    80005a78:	c9c58593          	addi	a1,a1,-868 # 80023710 <disk+0x128>
    80005a7c:	0001e517          	auipc	a0,0x1e
    80005a80:	b8450513          	addi	a0,a0,-1148 # 80023600 <disk+0x18>
    80005a84:	dd4fc0ef          	jal	80002058 <sleep>
  for(int i = 0; i < 3; i++){
    80005a88:	fa040613          	addi	a2,s0,-96
    80005a8c:	4901                	li	s2,0
    80005a8e:	b77d                	j	80005a3c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a90:	fa042503          	lw	a0,-96(s0)
    80005a94:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a98:	0001e797          	auipc	a5,0x1e
    80005a9c:	b5078793          	addi	a5,a5,-1200 # 800235e8 <disk>
    80005aa0:	00451713          	slli	a4,a0,0x4
    80005aa4:	0a070713          	addi	a4,a4,160
    80005aa8:	973e                	add	a4,a4,a5
    80005aaa:	01603633          	snez	a2,s6
    80005aae:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005ab0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ab4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ab8:	6398                	ld	a4,0(a5)
    80005aba:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005abc:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005ac0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ac2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ac4:	6390                	ld	a2,0(a5)
    80005ac6:	00d60833          	add	a6,a2,a3
    80005aca:	4741                	li	a4,16
    80005acc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ad0:	4585                	li	a1,1
    80005ad2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005ad6:	fa442703          	lw	a4,-92(s0)
    80005ada:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ade:	0712                	slli	a4,a4,0x4
    80005ae0:	963a                	add	a2,a2,a4
    80005ae2:	05898813          	addi	a6,s3,88
    80005ae6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005aea:	0007b883          	ld	a7,0(a5)
    80005aee:	9746                	add	a4,a4,a7
    80005af0:	40000613          	li	a2,1024
    80005af4:	c710                	sw	a2,8(a4)
  if(write)
    80005af6:	001b3613          	seqz	a2,s6
    80005afa:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005afe:	8e4d                	or	a2,a2,a1
    80005b00:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b04:	fa842603          	lw	a2,-88(s0)
    80005b08:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b0c:	00451813          	slli	a6,a0,0x4
    80005b10:	02080813          	addi	a6,a6,32
    80005b14:	983e                	add	a6,a6,a5
    80005b16:	577d                	li	a4,-1
    80005b18:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b1c:	0612                	slli	a2,a2,0x4
    80005b1e:	98b2                	add	a7,a7,a2
    80005b20:	03068713          	addi	a4,a3,48
    80005b24:	973e                	add	a4,a4,a5
    80005b26:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b2a:	6398                	ld	a4,0(a5)
    80005b2c:	9732                	add	a4,a4,a2
    80005b2e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b30:	4689                	li	a3,2
    80005b32:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b36:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b3a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b3e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005b42:	6794                	ld	a3,8(a5)
    80005b44:	0026d703          	lhu	a4,2(a3)
    80005b48:	8b1d                	andi	a4,a4,7
    80005b4a:	0706                	slli	a4,a4,0x1
    80005b4c:	96ba                	add	a3,a3,a4
    80005b4e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005b52:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005b56:	6798                	ld	a4,8(a5)
    80005b58:	00275783          	lhu	a5,2(a4)
    80005b5c:	2785                	addiw	a5,a5,1
    80005b5e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005b62:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005b66:	100017b7          	lui	a5,0x10001
    80005b6a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005b6e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005b72:	0001e917          	auipc	s2,0x1e
    80005b76:	b9e90913          	addi	s2,s2,-1122 # 80023710 <disk+0x128>
  while(b->disk == 1) {
    80005b7a:	84ae                	mv	s1,a1
    80005b7c:	00b79a63          	bne	a5,a1,80005b90 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005b80:	85ca                	mv	a1,s2
    80005b82:	854e                	mv	a0,s3
    80005b84:	cd4fc0ef          	jal	80002058 <sleep>
  while(b->disk == 1) {
    80005b88:	0049a783          	lw	a5,4(s3)
    80005b8c:	fe978ae3          	beq	a5,s1,80005b80 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b90:	fa042903          	lw	s2,-96(s0)
    80005b94:	00491713          	slli	a4,s2,0x4
    80005b98:	02070713          	addi	a4,a4,32
    80005b9c:	0001e797          	auipc	a5,0x1e
    80005ba0:	a4c78793          	addi	a5,a5,-1460 # 800235e8 <disk>
    80005ba4:	97ba                	add	a5,a5,a4
    80005ba6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005baa:	0001e997          	auipc	s3,0x1e
    80005bae:	a3e98993          	addi	s3,s3,-1474 # 800235e8 <disk>
    80005bb2:	00491713          	slli	a4,s2,0x4
    80005bb6:	0009b783          	ld	a5,0(s3)
    80005bba:	97ba                	add	a5,a5,a4
    80005bbc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005bc0:	854a                	mv	a0,s2
    80005bc2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005bc6:	bddff0ef          	jal	800057a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005bca:	8885                	andi	s1,s1,1
    80005bcc:	f0fd                	bnez	s1,80005bb2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005bce:	0001e517          	auipc	a0,0x1e
    80005bd2:	b4250513          	addi	a0,a0,-1214 # 80023710 <disk+0x128>
    80005bd6:	8e6fb0ef          	jal	80000cbc <release>
}
    80005bda:	60e6                	ld	ra,88(sp)
    80005bdc:	6446                	ld	s0,80(sp)
    80005bde:	64a6                	ld	s1,72(sp)
    80005be0:	6906                	ld	s2,64(sp)
    80005be2:	79e2                	ld	s3,56(sp)
    80005be4:	7a42                	ld	s4,48(sp)
    80005be6:	7aa2                	ld	s5,40(sp)
    80005be8:	7b02                	ld	s6,32(sp)
    80005bea:	6be2                	ld	s7,24(sp)
    80005bec:	6c42                	ld	s8,16(sp)
    80005bee:	6125                	addi	sp,sp,96
    80005bf0:	8082                	ret

0000000080005bf2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005bf2:	1101                	addi	sp,sp,-32
    80005bf4:	ec06                	sd	ra,24(sp)
    80005bf6:	e822                	sd	s0,16(sp)
    80005bf8:	e426                	sd	s1,8(sp)
    80005bfa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005bfc:	0001e497          	auipc	s1,0x1e
    80005c00:	9ec48493          	addi	s1,s1,-1556 # 800235e8 <disk>
    80005c04:	0001e517          	auipc	a0,0x1e
    80005c08:	b0c50513          	addi	a0,a0,-1268 # 80023710 <disk+0x128>
    80005c0c:	81cfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c10:	100017b7          	lui	a5,0x10001
    80005c14:	53bc                	lw	a5,96(a5)
    80005c16:	8b8d                	andi	a5,a5,3
    80005c18:	10001737          	lui	a4,0x10001
    80005c1c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005c1e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c22:	689c                	ld	a5,16(s1)
    80005c24:	0204d703          	lhu	a4,32(s1)
    80005c28:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c2c:	04f70863          	beq	a4,a5,80005c7c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005c30:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c34:	6898                	ld	a4,16(s1)
    80005c36:	0204d783          	lhu	a5,32(s1)
    80005c3a:	8b9d                	andi	a5,a5,7
    80005c3c:	078e                	slli	a5,a5,0x3
    80005c3e:	97ba                	add	a5,a5,a4
    80005c40:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005c42:	00479713          	slli	a4,a5,0x4
    80005c46:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005c4a:	9726                	add	a4,a4,s1
    80005c4c:	01074703          	lbu	a4,16(a4)
    80005c50:	e329                	bnez	a4,80005c92 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005c52:	0792                	slli	a5,a5,0x4
    80005c54:	02078793          	addi	a5,a5,32
    80005c58:	97a6                	add	a5,a5,s1
    80005c5a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005c5c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005c60:	c44fc0ef          	jal	800020a4 <wakeup>

    disk.used_idx += 1;
    80005c64:	0204d783          	lhu	a5,32(s1)
    80005c68:	2785                	addiw	a5,a5,1
    80005c6a:	17c2                	slli	a5,a5,0x30
    80005c6c:	93c1                	srli	a5,a5,0x30
    80005c6e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005c72:	6898                	ld	a4,16(s1)
    80005c74:	00275703          	lhu	a4,2(a4)
    80005c78:	faf71ce3          	bne	a4,a5,80005c30 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005c7c:	0001e517          	auipc	a0,0x1e
    80005c80:	a9450513          	addi	a0,a0,-1388 # 80023710 <disk+0x128>
    80005c84:	838fb0ef          	jal	80000cbc <release>
}
    80005c88:	60e2                	ld	ra,24(sp)
    80005c8a:	6442                	ld	s0,16(sp)
    80005c8c:	64a2                	ld	s1,8(sp)
    80005c8e:	6105                	addi	sp,sp,32
    80005c90:	8082                	ret
      panic("virtio_disk_intr status");
    80005c92:	00002517          	auipc	a0,0x2
    80005c96:	b2e50513          	addi	a0,a0,-1234 # 800077c0 <etext+0x7c0>
    80005c9a:	b8bfa0ef          	jal	80000824 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
