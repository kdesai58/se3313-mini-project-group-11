#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


#define NCHILD 5


// Dummy calculation function to simulate CPU burst
void cpu_burst(int iterations) {
    
    int start = uptime();        // ticks since boot
    while (uptime() - start < iterations*10) {
            // busy wait: burn CPU
    }
}


void child_process(int child_id) {
    int burst_input;
    
   
    int j;
    for (j = 0; j < 3; j++) {
        burst_input = (NCHILD - child_id + 1);
        // burst_input = child_id;
        cpu_burst(burst_input);
    }
}

int main(void) {
    int i;
    
    for (i = 0; i < NCHILD; i++) {
        int pid = fork();
        
        if (pid < 0) {
            printf("Fork failed for child %d\n", i);
            exit(1);
        } else if (pid == 0) {
            
            child_process(i + 1);
            exit(0);  
        } else {
            
            printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
        }
    }
    
    
   
    
    for (i = 0; i < NCHILD; i++) {
        wait(0);
    }
    
    
    exit(0);
}
