
user/_good_pipe:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// 0 for write, 1 for read

int
main(void)
{
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	fca6                	sd	s1,120(sp)
   8:	0900                	addi	s0,sp,144
    int fd[2];      // fd[0] for read, fd[1] for write
    pipe(fd);       // create a pipe
   a:	fd840513          	addi	a0,s0,-40
   e:	33a000ef          	jal	348 <pipe>

    int pid = fork();   // create a child process
  12:	31e000ef          	jal	330 <fork>

    if(pid == 0){       // child process as reader
  16:	e915                	bnez	a0,4a <main+0x4a>
        close(fd[1]);   // close the writer
  18:	fdc42503          	lw	a0,-36(s0)
  1c:	344000ef          	jal	360 <close>

        char buf[100];  
        int n = read(fd[0], buf, sizeof(buf));  // read from the pipe
  20:	f7040493          	addi	s1,s0,-144
  24:	06400613          	li	a2,100
  28:	85a6                	mv	a1,s1
  2a:	fd842503          	lw	a0,-40(s0)
  2e:	322000ef          	jal	350 <read>
  32:	862a                	mv	a2,a0
        write(1, buf, n);   // write to standard output
  34:	85a6                	mv	a1,s1
  36:	4505                	li	a0,1
  38:	320000ef          	jal	358 <write>

        close(fd[0]);       // close the reader
  3c:	fd842503          	lw	a0,-40(s0)
  40:	320000ef          	jal	360 <close>
        write(fd[1], msg, strlen(msg));  // write to the pipe

        close(fd[1]);   // close the writer
        wait(0);    
    }
    exit(0);
  44:	4501                	li	a0,0
  46:	2f2000ef          	jal	338 <exit>
        close(fd[0]);   // close the reader
  4a:	fd842503          	lw	a0,-40(s0)
  4e:	312000ef          	jal	360 <close>
        write(fd[1], msg, strlen(msg));  // write to the pipe
  52:	fdc42483          	lw	s1,-36(s0)
  56:	00001517          	auipc	a0,0x1
  5a:	8da50513          	addi	a0,a0,-1830 # 930 <malloc+0xf2>
  5e:	084000ef          	jal	e2 <strlen>
  62:	862a                	mv	a2,a0
  64:	00001597          	auipc	a1,0x1
  68:	8cc58593          	addi	a1,a1,-1844 # 930 <malloc+0xf2>
  6c:	8526                	mv	a0,s1
  6e:	2ea000ef          	jal	358 <write>
        close(fd[1]);   // close the writer
  72:	fdc42503          	lw	a0,-36(s0)
  76:	2ea000ef          	jal	360 <close>
        wait(0);    
  7a:	4501                	li	a0,0
  7c:	2c4000ef          	jal	340 <wait>
  80:	b7d1                	j	44 <main+0x44>

0000000000000082 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  82:	1141                	addi	sp,sp,-16
  84:	e406                	sd	ra,8(sp)
  86:	e022                	sd	s0,0(sp)
  88:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  8a:	f77ff0ef          	jal	0 <main>
  exit(r);
  8e:	2aa000ef          	jal	338 <exit>

0000000000000092 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  92:	1141                	addi	sp,sp,-16
  94:	e406                	sd	ra,8(sp)
  96:	e022                	sd	s0,0(sp)
  98:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9a:	87aa                	mv	a5,a0
  9c:	0585                	addi	a1,a1,1
  9e:	0785                	addi	a5,a5,1
  a0:	fff5c703          	lbu	a4,-1(a1)
  a4:	fee78fa3          	sb	a4,-1(a5)
  a8:	fb75                	bnez	a4,9c <strcpy+0xa>
    ;
  return os;
}
  aa:	60a2                	ld	ra,8(sp)
  ac:	6402                	ld	s0,0(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret

00000000000000b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e406                	sd	ra,8(sp)
  b6:	e022                	sd	s0,0(sp)
  b8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ba:	00054783          	lbu	a5,0(a0)
  be:	cb91                	beqz	a5,d2 <strcmp+0x20>
  c0:	0005c703          	lbu	a4,0(a1)
  c4:	00f71763          	bne	a4,a5,d2 <strcmp+0x20>
    p++, q++;
  c8:	0505                	addi	a0,a0,1
  ca:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	fbe5                	bnez	a5,c0 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  d2:	0005c503          	lbu	a0,0(a1)
}
  d6:	40a7853b          	subw	a0,a5,a0
  da:	60a2                	ld	ra,8(sp)
  dc:	6402                	ld	s0,0(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strlen>:

uint
strlen(const char *s)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cf91                	beqz	a5,10a <strlen+0x28>
  f0:	00150793          	addi	a5,a0,1
  f4:	86be                	mv	a3,a5
  f6:	0785                	addi	a5,a5,1
  f8:	fff7c703          	lbu	a4,-1(a5)
  fc:	ff65                	bnez	a4,f4 <strlen+0x12>
  fe:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 102:	60a2                	ld	ra,8(sp)
 104:	6402                	ld	s0,0(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret
  for(n = 0; s[n]; n++)
 10a:	4501                	li	a0,0
 10c:	bfdd                	j	102 <strlen+0x20>

000000000000010e <memset>:

void*
memset(void *dst, int c, uint n)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e406                	sd	ra,8(sp)
 112:	e022                	sd	s0,0(sp)
 114:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 116:	ca19                	beqz	a2,12c <memset+0x1e>
 118:	87aa                	mv	a5,a0
 11a:	1602                	slli	a2,a2,0x20
 11c:	9201                	srli	a2,a2,0x20
 11e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 122:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 126:	0785                	addi	a5,a5,1
 128:	fee79de3          	bne	a5,a4,122 <memset+0x14>
  }
  return dst;
}
 12c:	60a2                	ld	ra,8(sp)
 12e:	6402                	ld	s0,0(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strchr>:

char*
strchr(const char *s, char c)
{
 134:	1141                	addi	sp,sp,-16
 136:	e406                	sd	ra,8(sp)
 138:	e022                	sd	s0,0(sp)
 13a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cf81                	beqz	a5,158 <strchr+0x24>
    if(*s == c)
 142:	00f58763          	beq	a1,a5,150 <strchr+0x1c>
  for(; *s; s++)
 146:	0505                	addi	a0,a0,1
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbfd                	bnez	a5,142 <strchr+0xe>
      return (char*)s;
  return 0;
 14e:	4501                	li	a0,0
}
 150:	60a2                	ld	ra,8(sp)
 152:	6402                	ld	s0,0(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret
  return 0;
 158:	4501                	li	a0,0
 15a:	bfdd                	j	150 <strchr+0x1c>

000000000000015c <gets>:

char*
gets(char *buf, int max)
{
 15c:	711d                	addi	sp,sp,-96
 15e:	ec86                	sd	ra,88(sp)
 160:	e8a2                	sd	s0,80(sp)
 162:	e4a6                	sd	s1,72(sp)
 164:	e0ca                	sd	s2,64(sp)
 166:	fc4e                	sd	s3,56(sp)
 168:	f852                	sd	s4,48(sp)
 16a:	f456                	sd	s5,40(sp)
 16c:	f05a                	sd	s6,32(sp)
 16e:	ec5e                	sd	s7,24(sp)
 170:	e862                	sd	s8,16(sp)
 172:	1080                	addi	s0,sp,96
 174:	8baa                	mv	s7,a0
 176:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 178:	892a                	mv	s2,a0
 17a:	4481                	li	s1,0
    cc = read(0, &c, 1);
 17c:	faf40b13          	addi	s6,s0,-81
 180:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 182:	8c26                	mv	s8,s1
 184:	0014899b          	addiw	s3,s1,1
 188:	84ce                	mv	s1,s3
 18a:	0349d463          	bge	s3,s4,1b2 <gets+0x56>
    cc = read(0, &c, 1);
 18e:	8656                	mv	a2,s5
 190:	85da                	mv	a1,s6
 192:	4501                	li	a0,0
 194:	1bc000ef          	jal	350 <read>
    if(cc < 1)
 198:	00a05d63          	blez	a0,1b2 <gets+0x56>
      break;
    buf[i++] = c;
 19c:	faf44783          	lbu	a5,-81(s0)
 1a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a4:	0905                	addi	s2,s2,1
 1a6:	ff678713          	addi	a4,a5,-10
 1aa:	c319                	beqz	a4,1b0 <gets+0x54>
 1ac:	17cd                	addi	a5,a5,-13
 1ae:	fbf1                	bnez	a5,182 <gets+0x26>
    buf[i++] = c;
 1b0:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 1b2:	9c5e                	add	s8,s8,s7
 1b4:	000c0023          	sb	zero,0(s8)
  return buf;
}
 1b8:	855e                	mv	a0,s7
 1ba:	60e6                	ld	ra,88(sp)
 1bc:	6446                	ld	s0,80(sp)
 1be:	64a6                	ld	s1,72(sp)
 1c0:	6906                	ld	s2,64(sp)
 1c2:	79e2                	ld	s3,56(sp)
 1c4:	7a42                	ld	s4,48(sp)
 1c6:	7aa2                	ld	s5,40(sp)
 1c8:	7b02                	ld	s6,32(sp)
 1ca:	6be2                	ld	s7,24(sp)
 1cc:	6c42                	ld	s8,16(sp)
 1ce:	6125                	addi	sp,sp,96
 1d0:	8082                	ret

00000000000001d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d2:	1101                	addi	sp,sp,-32
 1d4:	ec06                	sd	ra,24(sp)
 1d6:	e822                	sd	s0,16(sp)
 1d8:	e04a                	sd	s2,0(sp)
 1da:	1000                	addi	s0,sp,32
 1dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1de:	4581                	li	a1,0
 1e0:	198000ef          	jal	378 <open>
  if(fd < 0)
 1e4:	02054263          	bltz	a0,208 <stat+0x36>
 1e8:	e426                	sd	s1,8(sp)
 1ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ec:	85ca                	mv	a1,s2
 1ee:	1a2000ef          	jal	390 <fstat>
 1f2:	892a                	mv	s2,a0
  close(fd);
 1f4:	8526                	mv	a0,s1
 1f6:	16a000ef          	jal	360 <close>
  return r;
 1fa:	64a2                	ld	s1,8(sp)
}
 1fc:	854a                	mv	a0,s2
 1fe:	60e2                	ld	ra,24(sp)
 200:	6442                	ld	s0,16(sp)
 202:	6902                	ld	s2,0(sp)
 204:	6105                	addi	sp,sp,32
 206:	8082                	ret
    return -1;
 208:	57fd                	li	a5,-1
 20a:	893e                	mv	s2,a5
 20c:	bfc5                	j	1fc <stat+0x2a>

000000000000020e <atoi>:

int
atoi(const char *s)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e406                	sd	ra,8(sp)
 212:	e022                	sd	s0,0(sp)
 214:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 216:	00054683          	lbu	a3,0(a0)
 21a:	fd06879b          	addiw	a5,a3,-48
 21e:	0ff7f793          	zext.b	a5,a5
 222:	4625                	li	a2,9
 224:	02f66963          	bltu	a2,a5,256 <atoi+0x48>
 228:	872a                	mv	a4,a0
  n = 0;
 22a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 22c:	0705                	addi	a4,a4,1
 22e:	0025179b          	slliw	a5,a0,0x2
 232:	9fa9                	addw	a5,a5,a0
 234:	0017979b          	slliw	a5,a5,0x1
 238:	9fb5                	addw	a5,a5,a3
 23a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 23e:	00074683          	lbu	a3,0(a4)
 242:	fd06879b          	addiw	a5,a3,-48
 246:	0ff7f793          	zext.b	a5,a5
 24a:	fef671e3          	bgeu	a2,a5,22c <atoi+0x1e>
  return n;
}
 24e:	60a2                	ld	ra,8(sp)
 250:	6402                	ld	s0,0(sp)
 252:	0141                	addi	sp,sp,16
 254:	8082                	ret
  n = 0;
 256:	4501                	li	a0,0
 258:	bfdd                	j	24e <atoi+0x40>

000000000000025a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 262:	02b57563          	bgeu	a0,a1,28c <memmove+0x32>
    while(n-- > 0)
 266:	00c05f63          	blez	a2,284 <memmove+0x2a>
 26a:	1602                	slli	a2,a2,0x20
 26c:	9201                	srli	a2,a2,0x20
 26e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 272:	872a                	mv	a4,a0
      *dst++ = *src++;
 274:	0585                	addi	a1,a1,1
 276:	0705                	addi	a4,a4,1
 278:	fff5c683          	lbu	a3,-1(a1)
 27c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 280:	fee79ae3          	bne	a5,a4,274 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 284:	60a2                	ld	ra,8(sp)
 286:	6402                	ld	s0,0(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
    while(n-- > 0)
 28c:	fec05ce3          	blez	a2,284 <memmove+0x2a>
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
 296:	fff6079b          	addiw	a5,a2,-1
 29a:	1782                	slli	a5,a5,0x20
 29c:	9381                	srli	a5,a5,0x20
 29e:	fff7c793          	not	a5,a5
 2a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a4:	15fd                	addi	a1,a1,-1
 2a6:	177d                	addi	a4,a4,-1
 2a8:	0005c683          	lbu	a3,0(a1)
 2ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b0:	fef71ae3          	bne	a4,a5,2a4 <memmove+0x4a>
 2b4:	bfc1                	j	284 <memmove+0x2a>

00000000000002b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e406                	sd	ra,8(sp)
 2ba:	e022                	sd	s0,0(sp)
 2bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2be:	c61d                	beqz	a2,2ec <memcmp+0x36>
 2c0:	1602                	slli	a2,a2,0x20
 2c2:	9201                	srli	a2,a2,0x20
 2c4:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 2c8:	00054783          	lbu	a5,0(a0)
 2cc:	0005c703          	lbu	a4,0(a1)
 2d0:	00e79863          	bne	a5,a4,2e0 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 2d4:	0505                	addi	a0,a0,1
    p2++;
 2d6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2d8:	fed518e3          	bne	a0,a3,2c8 <memcmp+0x12>
  }
  return 0;
 2dc:	4501                	li	a0,0
 2de:	a019                	j	2e4 <memcmp+0x2e>
      return *p1 - *p2;
 2e0:	40e7853b          	subw	a0,a5,a4
}
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	bfdd                	j	2e4 <memcmp+0x2e>

00000000000002f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f8:	f63ff0ef          	jal	25a <memmove>
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret

0000000000000304 <sbrk>:

char *
sbrk(int n) {
 304:	1141                	addi	sp,sp,-16
 306:	e406                	sd	ra,8(sp)
 308:	e022                	sd	s0,0(sp)
 30a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 30c:	4585                	li	a1,1
 30e:	0b2000ef          	jal	3c0 <sys_sbrk>
}
 312:	60a2                	ld	ra,8(sp)
 314:	6402                	ld	s0,0(sp)
 316:	0141                	addi	sp,sp,16
 318:	8082                	ret

000000000000031a <sbrklazy>:

char *
sbrklazy(int n) {
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 322:	4589                	li	a1,2
 324:	09c000ef          	jal	3c0 <sys_sbrk>
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret

0000000000000330 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 330:	4885                	li	a7,1
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <exit>:
.global exit
exit:
 li a7, SYS_exit
 338:	4889                	li	a7,2
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <wait>:
.global wait
wait:
 li a7, SYS_wait
 340:	488d                	li	a7,3
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 348:	4891                	li	a7,4
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <read>:
.global read
read:
 li a7, SYS_read
 350:	4895                	li	a7,5
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <write>:
.global write
write:
 li a7, SYS_write
 358:	48c1                	li	a7,16
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <close>:
.global close
close:
 li a7, SYS_close
 360:	48d5                	li	a7,21
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <kill>:
.global kill
kill:
 li a7, SYS_kill
 368:	4899                	li	a7,6
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <exec>:
.global exec
exec:
 li a7, SYS_exec
 370:	489d                	li	a7,7
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <open>:
.global open
open:
 li a7, SYS_open
 378:	48bd                	li	a7,15
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 380:	48c5                	li	a7,17
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 388:	48c9                	li	a7,18
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 390:	48a1                	li	a7,8
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <link>:
.global link
link:
 li a7, SYS_link
 398:	48cd                	li	a7,19
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a0:	48d1                	li	a7,20
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a8:	48a5                	li	a7,9
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b0:	48a9                	li	a7,10
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b8:	48ad                	li	a7,11
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c0:	48b1                	li	a7,12
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3c8:	48b5                	li	a7,13
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d0:	48b9                	li	a7,14
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <kps>:
.global kps
kps:
 li a7, SYS_kps
 3d8:	48d9                	li	a7,22
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e0:	1101                	addi	sp,sp,-32
 3e2:	ec06                	sd	ra,24(sp)
 3e4:	e822                	sd	s0,16(sp)
 3e6:	1000                	addi	s0,sp,32
 3e8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ec:	4605                	li	a2,1
 3ee:	fef40593          	addi	a1,s0,-17
 3f2:	f67ff0ef          	jal	358 <write>
}
 3f6:	60e2                	ld	ra,24(sp)
 3f8:	6442                	ld	s0,16(sp)
 3fa:	6105                	addi	sp,sp,32
 3fc:	8082                	ret

00000000000003fe <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3fe:	715d                	addi	sp,sp,-80
 400:	e486                	sd	ra,72(sp)
 402:	e0a2                	sd	s0,64(sp)
 404:	f84a                	sd	s2,48(sp)
 406:	f44e                	sd	s3,40(sp)
 408:	0880                	addi	s0,sp,80
 40a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 40c:	c6d1                	beqz	a3,498 <printint+0x9a>
 40e:	0805d563          	bgez	a1,498 <printint+0x9a>
    neg = 1;
    x = -xx;
 412:	40b005b3          	neg	a1,a1
    neg = 1;
 416:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 418:	fb840993          	addi	s3,s0,-72
  neg = 0;
 41c:	86ce                	mv	a3,s3
  i = 0;
 41e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 420:	00000817          	auipc	a6,0x0
 424:	55880813          	addi	a6,a6,1368 # 978 <digits>
 428:	88ba                	mv	a7,a4
 42a:	0017051b          	addiw	a0,a4,1
 42e:	872a                	mv	a4,a0
 430:	02c5f7b3          	remu	a5,a1,a2
 434:	97c2                	add	a5,a5,a6
 436:	0007c783          	lbu	a5,0(a5)
 43a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 43e:	87ae                	mv	a5,a1
 440:	02c5d5b3          	divu	a1,a1,a2
 444:	0685                	addi	a3,a3,1
 446:	fec7f1e3          	bgeu	a5,a2,428 <printint+0x2a>
  if(neg)
 44a:	00030c63          	beqz	t1,462 <printint+0x64>
    buf[i++] = '-';
 44e:	fd050793          	addi	a5,a0,-48
 452:	00878533          	add	a0,a5,s0
 456:	02d00793          	li	a5,45
 45a:	fef50423          	sb	a5,-24(a0)
 45e:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 462:	02e05563          	blez	a4,48c <printint+0x8e>
 466:	fc26                	sd	s1,56(sp)
 468:	377d                	addiw	a4,a4,-1
 46a:	00e984b3          	add	s1,s3,a4
 46e:	19fd                	addi	s3,s3,-1
 470:	99ba                	add	s3,s3,a4
 472:	1702                	slli	a4,a4,0x20
 474:	9301                	srli	a4,a4,0x20
 476:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47a:	0004c583          	lbu	a1,0(s1)
 47e:	854a                	mv	a0,s2
 480:	f61ff0ef          	jal	3e0 <putc>
  while(--i >= 0)
 484:	14fd                	addi	s1,s1,-1
 486:	ff349ae3          	bne	s1,s3,47a <printint+0x7c>
 48a:	74e2                	ld	s1,56(sp)
}
 48c:	60a6                	ld	ra,72(sp)
 48e:	6406                	ld	s0,64(sp)
 490:	7942                	ld	s2,48(sp)
 492:	79a2                	ld	s3,40(sp)
 494:	6161                	addi	sp,sp,80
 496:	8082                	ret
  neg = 0;
 498:	4301                	li	t1,0
 49a:	bfbd                	j	418 <printint+0x1a>

000000000000049c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49c:	711d                	addi	sp,sp,-96
 49e:	ec86                	sd	ra,88(sp)
 4a0:	e8a2                	sd	s0,80(sp)
 4a2:	e4a6                	sd	s1,72(sp)
 4a4:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a6:	0005c483          	lbu	s1,0(a1)
 4aa:	22048363          	beqz	s1,6d0 <vprintf+0x234>
 4ae:	e0ca                	sd	s2,64(sp)
 4b0:	fc4e                	sd	s3,56(sp)
 4b2:	f852                	sd	s4,48(sp)
 4b4:	f456                	sd	s5,40(sp)
 4b6:	f05a                	sd	s6,32(sp)
 4b8:	ec5e                	sd	s7,24(sp)
 4ba:	e862                	sd	s8,16(sp)
 4bc:	8b2a                	mv	s6,a0
 4be:	8a2e                	mv	s4,a1
 4c0:	8bb2                	mv	s7,a2
  state = 0;
 4c2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4c4:	4901                	li	s2,0
 4c6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4c8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4cc:	06400c13          	li	s8,100
 4d0:	a00d                	j	4f2 <vprintf+0x56>
        putc(fd, c0);
 4d2:	85a6                	mv	a1,s1
 4d4:	855a                	mv	a0,s6
 4d6:	f0bff0ef          	jal	3e0 <putc>
 4da:	a019                	j	4e0 <vprintf+0x44>
    } else if(state == '%'){
 4dc:	03598363          	beq	s3,s5,502 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 4e0:	0019079b          	addiw	a5,s2,1
 4e4:	893e                	mv	s2,a5
 4e6:	873e                	mv	a4,a5
 4e8:	97d2                	add	a5,a5,s4
 4ea:	0007c483          	lbu	s1,0(a5)
 4ee:	1c048a63          	beqz	s1,6c2 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4f2:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4f6:	fe0993e3          	bnez	s3,4dc <vprintf+0x40>
      if(c0 == '%'){
 4fa:	fd579ce3          	bne	a5,s5,4d2 <vprintf+0x36>
        state = '%';
 4fe:	89be                	mv	s3,a5
 500:	b7c5                	j	4e0 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 502:	00ea06b3          	add	a3,s4,a4
 506:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 50a:	1c060863          	beqz	a2,6da <vprintf+0x23e>
      if(c0 == 'd'){
 50e:	03878763          	beq	a5,s8,53c <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 512:	f9478693          	addi	a3,a5,-108
 516:	0016b693          	seqz	a3,a3
 51a:	f9c60593          	addi	a1,a2,-100
 51e:	e99d                	bnez	a1,554 <vprintf+0xb8>
 520:	ca95                	beqz	a3,554 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 522:	008b8493          	addi	s1,s7,8
 526:	4685                	li	a3,1
 528:	4629                	li	a2,10
 52a:	000bb583          	ld	a1,0(s7)
 52e:	855a                	mv	a0,s6
 530:	ecfff0ef          	jal	3fe <printint>
        i += 1;
 534:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 536:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 538:	4981                	li	s3,0
 53a:	b75d                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 53c:	008b8493          	addi	s1,s7,8
 540:	4685                	li	a3,1
 542:	4629                	li	a2,10
 544:	000ba583          	lw	a1,0(s7)
 548:	855a                	mv	a0,s6
 54a:	eb5ff0ef          	jal	3fe <printint>
 54e:	8ba6                	mv	s7,s1
      state = 0;
 550:	4981                	li	s3,0
 552:	b779                	j	4e0 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 554:	9752                	add	a4,a4,s4
 556:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 55a:	f9460713          	addi	a4,a2,-108
 55e:	00173713          	seqz	a4,a4
 562:	8f75                	and	a4,a4,a3
 564:	f9c58513          	addi	a0,a1,-100
 568:	18051363          	bnez	a0,6ee <vprintf+0x252>
 56c:	18070163          	beqz	a4,6ee <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	008b8493          	addi	s1,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000bb583          	ld	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	e81ff0ef          	jal	3fe <printint>
        i += 2;
 582:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	8ba6                	mv	s7,s1
      state = 0;
 586:	4981                	li	s3,0
        i += 2;
 588:	bfa1                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 58a:	008b8493          	addi	s1,s7,8
 58e:	4681                	li	a3,0
 590:	4629                	li	a2,10
 592:	000be583          	lwu	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e67ff0ef          	jal	3fe <printint>
 59c:	8ba6                	mv	s7,s1
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b781                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a2:	008b8493          	addi	s1,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4629                	li	a2,10
 5aa:	000bb583          	ld	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	e4fff0ef          	jal	3fe <printint>
        i += 1;
 5b4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	8ba6                	mv	s7,s1
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	b71d                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5bc:	008b8493          	addi	s1,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4629                	li	a2,10
 5c4:	000bb583          	ld	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e35ff0ef          	jal	3fe <printint>
        i += 2;
 5ce:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5d0:	8ba6                	mv	s7,s1
      state = 0;
 5d2:	4981                	li	s3,0
        i += 2;
 5d4:	b731                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5d6:	008b8493          	addi	s1,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000be583          	lwu	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e1bff0ef          	jal	3fe <printint>
 5e8:	8ba6                	mv	s7,s1
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bdd5                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ee:	008b8493          	addi	s1,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4641                	li	a2,16
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	e03ff0ef          	jal	3fe <printint>
        i += 1;
 600:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 602:	8ba6                	mv	s7,s1
      state = 0;
 604:	4981                	li	s3,0
 606:	bde9                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	008b8493          	addi	s1,s7,8
 60c:	4681                	li	a3,0
 60e:	4641                	li	a2,16
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	de9ff0ef          	jal	3fe <printint>
        i += 2;
 61a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 61c:	8ba6                	mv	s7,s1
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	b5c1                	j	4e0 <vprintf+0x44>
 622:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 624:	008b8793          	addi	a5,s7,8
 628:	8cbe                	mv	s9,a5
 62a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 62e:	03000593          	li	a1,48
 632:	855a                	mv	a0,s6
 634:	dadff0ef          	jal	3e0 <putc>
  putc(fd, 'x');
 638:	07800593          	li	a1,120
 63c:	855a                	mv	a0,s6
 63e:	da3ff0ef          	jal	3e0 <putc>
 642:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 644:	00000b97          	auipc	s7,0x0
 648:	334b8b93          	addi	s7,s7,820 # 978 <digits>
 64c:	03c9d793          	srli	a5,s3,0x3c
 650:	97de                	add	a5,a5,s7
 652:	0007c583          	lbu	a1,0(a5)
 656:	855a                	mv	a0,s6
 658:	d89ff0ef          	jal	3e0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 65c:	0992                	slli	s3,s3,0x4
 65e:	34fd                	addiw	s1,s1,-1
 660:	f4f5                	bnez	s1,64c <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 662:	8be6                	mv	s7,s9
      state = 0;
 664:	4981                	li	s3,0
 666:	6ca2                	ld	s9,8(sp)
 668:	bda5                	j	4e0 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 66a:	008b8493          	addi	s1,s7,8
 66e:	000bc583          	lbu	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	d6dff0ef          	jal	3e0 <putc>
 678:	8ba6                	mv	s7,s1
      state = 0;
 67a:	4981                	li	s3,0
 67c:	b595                	j	4e0 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 67e:	008b8993          	addi	s3,s7,8
 682:	000bb483          	ld	s1,0(s7)
 686:	cc91                	beqz	s1,6a2 <vprintf+0x206>
        for(; *s; s++)
 688:	0004c583          	lbu	a1,0(s1)
 68c:	c985                	beqz	a1,6bc <vprintf+0x220>
          putc(fd, *s);
 68e:	855a                	mv	a0,s6
 690:	d51ff0ef          	jal	3e0 <putc>
        for(; *s; s++)
 694:	0485                	addi	s1,s1,1
 696:	0004c583          	lbu	a1,0(s1)
 69a:	f9f5                	bnez	a1,68e <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 69c:	8bce                	mv	s7,s3
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b581                	j	4e0 <vprintf+0x44>
          s = "(null)";
 6a2:	00000497          	auipc	s1,0x0
 6a6:	2ce48493          	addi	s1,s1,718 # 970 <malloc+0x132>
        for(; *s; s++)
 6aa:	02800593          	li	a1,40
 6ae:	b7c5                	j	68e <vprintf+0x1f2>
        putc(fd, '%');
 6b0:	85be                	mv	a1,a5
 6b2:	855a                	mv	a0,s6
 6b4:	d2dff0ef          	jal	3e0 <putc>
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b51d                	j	4e0 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6bc:	8bce                	mv	s7,s3
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b505                	j	4e0 <vprintf+0x44>
 6c2:	6906                	ld	s2,64(sp)
 6c4:	79e2                	ld	s3,56(sp)
 6c6:	7a42                	ld	s4,48(sp)
 6c8:	7aa2                	ld	s5,40(sp)
 6ca:	7b02                	ld	s6,32(sp)
 6cc:	6be2                	ld	s7,24(sp)
 6ce:	6c42                	ld	s8,16(sp)
    }
  }
}
 6d0:	60e6                	ld	ra,88(sp)
 6d2:	6446                	ld	s0,80(sp)
 6d4:	64a6                	ld	s1,72(sp)
 6d6:	6125                	addi	sp,sp,96
 6d8:	8082                	ret
      if(c0 == 'd'){
 6da:	06400713          	li	a4,100
 6de:	e4e78fe3          	beq	a5,a4,53c <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 6e2:	f9478693          	addi	a3,a5,-108
 6e6:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 6ea:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ec:	4701                	li	a4,0
      } else if(c0 == 'u'){
 6ee:	07500513          	li	a0,117
 6f2:	e8a78ce3          	beq	a5,a0,58a <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6f6:	f8b60513          	addi	a0,a2,-117
 6fa:	e119                	bnez	a0,700 <vprintf+0x264>
 6fc:	ea0693e3          	bnez	a3,5a2 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 700:	f8b58513          	addi	a0,a1,-117
 704:	e119                	bnez	a0,70a <vprintf+0x26e>
 706:	ea071be3          	bnez	a4,5bc <vprintf+0x120>
      } else if(c0 == 'x'){
 70a:	07800513          	li	a0,120
 70e:	eca784e3          	beq	a5,a0,5d6 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 712:	f8860613          	addi	a2,a2,-120
 716:	e219                	bnez	a2,71c <vprintf+0x280>
 718:	ec069be3          	bnez	a3,5ee <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 71c:	f8858593          	addi	a1,a1,-120
 720:	e199                	bnez	a1,726 <vprintf+0x28a>
 722:	ee0713e3          	bnez	a4,608 <vprintf+0x16c>
      } else if(c0 == 'p'){
 726:	07000713          	li	a4,112
 72a:	eee78ce3          	beq	a5,a4,622 <vprintf+0x186>
      } else if(c0 == 'c'){
 72e:	06300713          	li	a4,99
 732:	f2e78ce3          	beq	a5,a4,66a <vprintf+0x1ce>
      } else if(c0 == 's'){
 736:	07300713          	li	a4,115
 73a:	f4e782e3          	beq	a5,a4,67e <vprintf+0x1e2>
      } else if(c0 == '%'){
 73e:	02500713          	li	a4,37
 742:	f6e787e3          	beq	a5,a4,6b0 <vprintf+0x214>
        putc(fd, '%');
 746:	02500593          	li	a1,37
 74a:	855a                	mv	a0,s6
 74c:	c95ff0ef          	jal	3e0 <putc>
        putc(fd, c0);
 750:	85a6                	mv	a1,s1
 752:	855a                	mv	a0,s6
 754:	c8dff0ef          	jal	3e0 <putc>
      state = 0;
 758:	4981                	li	s3,0
 75a:	b359                	j	4e0 <vprintf+0x44>

000000000000075c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 75c:	715d                	addi	sp,sp,-80
 75e:	ec06                	sd	ra,24(sp)
 760:	e822                	sd	s0,16(sp)
 762:	1000                	addi	s0,sp,32
 764:	e010                	sd	a2,0(s0)
 766:	e414                	sd	a3,8(s0)
 768:	e818                	sd	a4,16(s0)
 76a:	ec1c                	sd	a5,24(s0)
 76c:	03043023          	sd	a6,32(s0)
 770:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 774:	8622                	mv	a2,s0
 776:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77a:	d23ff0ef          	jal	49c <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6161                	addi	sp,sp,80
 784:	8082                	ret

0000000000000786 <printf>:

void
printf(const char *fmt, ...)
{
 786:	711d                	addi	sp,sp,-96
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e40c                	sd	a1,8(s0)
 790:	e810                	sd	a2,16(s0)
 792:	ec14                	sd	a3,24(s0)
 794:	f018                	sd	a4,32(s0)
 796:	f41c                	sd	a5,40(s0)
 798:	03043823          	sd	a6,48(s0)
 79c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	00840613          	addi	a2,s0,8
 7a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a8:	85aa                	mv	a1,a0
 7aa:	4505                	li	a0,1
 7ac:	cf1ff0ef          	jal	49c <vprintf>
}
 7b0:	60e2                	ld	ra,24(sp)
 7b2:	6442                	ld	s0,16(sp)
 7b4:	6125                	addi	sp,sp,96
 7b6:	8082                	ret

00000000000007b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b8:	1141                	addi	sp,sp,-16
 7ba:	e406                	sd	ra,8(sp)
 7bc:	e022                	sd	s0,0(sp)
 7be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c4:	00001797          	auipc	a5,0x1
 7c8:	83c7b783          	ld	a5,-1988(a5) # 1000 <freep>
 7cc:	a039                	j	7da <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e7e463          	bltu	a5,a4,7d8 <free+0x20>
 7d4:	00e6ea63          	bltu	a3,a4,7e8 <free+0x30>
{
 7d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	fed7fae3          	bgeu	a5,a3,7ce <free+0x16>
 7de:	6398                	ld	a4,0(a5)
 7e0:	00e6e463          	bltu	a3,a4,7e8 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e4:	fee7eae3          	bltu	a5,a4,7d8 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e8:	ff852583          	lw	a1,-8(a0)
 7ec:	6390                	ld	a2,0(a5)
 7ee:	02059813          	slli	a6,a1,0x20
 7f2:	01c85713          	srli	a4,a6,0x1c
 7f6:	9736                	add	a4,a4,a3
 7f8:	02e60563          	beq	a2,a4,822 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 800:	4790                	lw	a2,8(a5)
 802:	02061593          	slli	a1,a2,0x20
 806:	01c5d713          	srli	a4,a1,0x1c
 80a:	973e                	add	a4,a4,a5
 80c:	02e68263          	beq	a3,a4,830 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 810:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 812:	00000717          	auipc	a4,0x0
 816:	7ef73723          	sd	a5,2030(a4) # 1000 <freep>
}
 81a:	60a2                	ld	ra,8(sp)
 81c:	6402                	ld	s0,0(sp)
 81e:	0141                	addi	sp,sp,16
 820:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 822:	4618                	lw	a4,8(a2)
 824:	9f2d                	addw	a4,a4,a1
 826:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82a:	6398                	ld	a4,0(a5)
 82c:	6310                	ld	a2,0(a4)
 82e:	b7f9                	j	7fc <free+0x44>
    p->s.size += bp->s.size;
 830:	ff852703          	lw	a4,-8(a0)
 834:	9f31                	addw	a4,a4,a2
 836:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 838:	ff053683          	ld	a3,-16(a0)
 83c:	bfd1                	j	810 <free+0x58>

000000000000083e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 83e:	7139                	addi	sp,sp,-64
 840:	fc06                	sd	ra,56(sp)
 842:	f822                	sd	s0,48(sp)
 844:	f04a                	sd	s2,32(sp)
 846:	ec4e                	sd	s3,24(sp)
 848:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 84a:	02051993          	slli	s3,a0,0x20
 84e:	0209d993          	srli	s3,s3,0x20
 852:	09bd                	addi	s3,s3,15
 854:	0049d993          	srli	s3,s3,0x4
 858:	2985                	addiw	s3,s3,1
 85a:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 85c:	00000517          	auipc	a0,0x0
 860:	7a453503          	ld	a0,1956(a0) # 1000 <freep>
 864:	c905                	beqz	a0,894 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 866:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 868:	4798                	lw	a4,8(a5)
 86a:	09377663          	bgeu	a4,s3,8f6 <malloc+0xb8>
 86e:	f426                	sd	s1,40(sp)
 870:	e852                	sd	s4,16(sp)
 872:	e456                	sd	s5,8(sp)
 874:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 876:	8a4e                	mv	s4,s3
 878:	6705                	lui	a4,0x1
 87a:	00e9f363          	bgeu	s3,a4,880 <malloc+0x42>
 87e:	6a05                	lui	s4,0x1
 880:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 884:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 888:	00000497          	auipc	s1,0x0
 88c:	77848493          	addi	s1,s1,1912 # 1000 <freep>
  if(p == SBRK_ERROR)
 890:	5afd                	li	s5,-1
 892:	a83d                	j	8d0 <malloc+0x92>
 894:	f426                	sd	s1,40(sp)
 896:	e852                	sd	s4,16(sp)
 898:	e456                	sd	s5,8(sp)
 89a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 89c:	00000797          	auipc	a5,0x0
 8a0:	77478793          	addi	a5,a5,1908 # 1010 <base>
 8a4:	00000717          	auipc	a4,0x0
 8a8:	74f73e23          	sd	a5,1884(a4) # 1000 <freep>
 8ac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ae:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b2:	b7d1                	j	876 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 8b4:	6398                	ld	a4,0(a5)
 8b6:	e118                	sd	a4,0(a0)
 8b8:	a899                	j	90e <malloc+0xd0>
  hp->s.size = nu;
 8ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8be:	0541                	addi	a0,a0,16
 8c0:	ef9ff0ef          	jal	7b8 <free>
  return freep;
 8c4:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 8c6:	c125                	beqz	a0,926 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ca:	4798                	lw	a4,8(a5)
 8cc:	03277163          	bgeu	a4,s2,8ee <malloc+0xb0>
    if(p == freep)
 8d0:	6098                	ld	a4,0(s1)
 8d2:	853e                	mv	a0,a5
 8d4:	fef71ae3          	bne	a4,a5,8c8 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 8d8:	8552                	mv	a0,s4
 8da:	a2bff0ef          	jal	304 <sbrk>
  if(p == SBRK_ERROR)
 8de:	fd551ee3          	bne	a0,s5,8ba <malloc+0x7c>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	74a2                	ld	s1,40(sp)
 8e6:	6a42                	ld	s4,16(sp)
 8e8:	6aa2                	ld	s5,8(sp)
 8ea:	6b02                	ld	s6,0(sp)
 8ec:	a03d                	j	91a <malloc+0xdc>
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8f6:	fae90fe3          	beq	s2,a4,8b4 <malloc+0x76>
        p->s.size -= nunits;
 8fa:	4137073b          	subw	a4,a4,s3
 8fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 900:	02071693          	slli	a3,a4,0x20
 904:	01c6d713          	srli	a4,a3,0x1c
 908:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90e:	00000717          	auipc	a4,0x0
 912:	6ea73923          	sd	a0,1778(a4) # 1000 <freep>
      return (void*)(p + 1);
 916:	01078513          	addi	a0,a5,16
  }
}
 91a:	70e2                	ld	ra,56(sp)
 91c:	7442                	ld	s0,48(sp)
 91e:	7902                	ld	s2,32(sp)
 920:	69e2                	ld	s3,24(sp)
 922:	6121                	addi	sp,sp,64
 924:	8082                	ret
 926:	74a2                	ld	s1,40(sp)
 928:	6a42                	ld	s4,16(sp)
 92a:	6aa2                	ld	s5,8(sp)
 92c:	6b02                	ld	s6,0(sp)
 92e:	b7f5                	j	91a <malloc+0xdc>
