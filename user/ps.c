#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
  if(argc < 2) {
    printf("Usage: ps [-o | -l]\n");
    return 0;
  }
  kps(argv[1]);
  exit(0);
}