#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "user/user.h"

#define PIPESIZE 32

struct bad_pipe {
    char data[PIPESIZE];
    uint nread;     // number of bytes read
    uint nwrite;    // number of bytes written
};

void 
pipe_write(struct bad_pipe *pi, char ch)
{
    // if(pi->nwrite - pi->nread == PIPESIZE) {
    //     // Pipe is full, cannot write
    //     return;
    // }

    pi->data[pi->nwrite % PIPESIZE] = ch;
    pi->nwrite++;
}

int 
pipe_read(struct bad_pipe *pi)
{
    if(pi->nread == pi->nwrite) {
        // Pipe is empty, cannot read
        return -1;
    }

    char ch = pi->data[pi->nread % PIPESIZE];
    pi->nread++;
    return ch;
}

int
main(void)
{
    struct bad_pipe pipe;

    char last3[3] = {0,0,0};
    char ch;

    printf("Type text. Enter 'ok?' to stop and display buffer contents.\n\n");

    pipe.nread = 0;
    pipe.nwrite = 0;

    while(read(0, &ch, 1) == 1){
        // Check for "ok?" pattern before writing
        last3[0] = last3[1];
        last3[1] = last3[2];
        last3[2] = ch;        

        if(last3[0] == 'o' && last3[1] == 'k' && last3[2] == '?') {
            // Remove the 'o' and 'k' that were already written
            pipe.nwrite -= 2;
            break;
        }else{
            pipe_write(&pipe, ch);
        }
    }

    if(pipe.nwrite - pipe.nread == PIPESIZE) {
        printf("\nPipe overflow occurred!\n");
        pipe.nread = pipe.nwrite - PIPESIZE; // Adjust read pointer to avoid overflow
    }

    printf("\nBuffer contents:\n");
    int out_ch;
    while((out_ch = pipe_read(&pipe)) != -1) {
        printf("%c", out_ch);
    }
    printf("\n");
}
