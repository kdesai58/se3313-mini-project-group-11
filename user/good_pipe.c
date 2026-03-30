#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "user/user.h"

// 0 for write, 1 for read

int
main(void)
{
    int fd[2];      // fd[0] for read, fd[1] for write
    pipe(fd);       // create a pipe

    int pid = fork();   // create a child process

    if(pid == 0){       // child process as reader
        close(fd[1]);   // close the writer

        char buf[100];  
        int n = read(fd[0], buf, sizeof(buf));  // read from the pipe
        write(1, buf, n);   // write to standard output

        close(fd[0]);       // close the reader
    }else{          // parent process as writer
        close(fd[0]);   // close the reader

        char *msg = "I write, erase, rewrite\n"
                    "Erase again, and then\n"
                    "A poppy blooms.\n";

        write(fd[1], msg, strlen(msg));  // write to the pipe

        close(fd[1]);   // close the writer
        wait(0);    
    }
    exit(0);
}
