
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(argc < 2) {
   8:	4785                	li	a5,1
   a:	00a7cd63          	blt	a5,a0,24 <main+0x24>
    printf("Usage: ps [-o | -l]\n");
   e:	00001517          	auipc	a0,0x1
  12:	8d250513          	addi	a0,a0,-1838 # 8e0 <malloc+0xf4>
  16:	71e000ef          	jal	734 <printf>
    return 0;
  }
  kps(argv[1]);
  exit(0);
  1a:	4501                	li	a0,0
  1c:	60a2                	ld	ra,8(sp)
  1e:	6402                	ld	s0,0(sp)
  20:	0141                	addi	sp,sp,16
  22:	8082                	ret
  kps(argv[1]);
  24:	6588                	ld	a0,8(a1)
  26:	360000ef          	jal	386 <kps>
  exit(0);
  2a:	4501                	li	a0,0
  2c:	2ba000ef          	jal	2e6 <exit>

0000000000000030 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  30:	1141                	addi	sp,sp,-16
  32:	e406                	sd	ra,8(sp)
  34:	e022                	sd	s0,0(sp)
  36:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  38:	fc9ff0ef          	jal	0 <main>
  exit(r);
  3c:	2aa000ef          	jal	2e6 <exit>

0000000000000040 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  40:	1141                	addi	sp,sp,-16
  42:	e406                	sd	ra,8(sp)
  44:	e022                	sd	s0,0(sp)
  46:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  48:	87aa                	mv	a5,a0
  4a:	0585                	addi	a1,a1,1
  4c:	0785                	addi	a5,a5,1
  4e:	fff5c703          	lbu	a4,-1(a1)
  52:	fee78fa3          	sb	a4,-1(a5)
  56:	fb75                	bnez	a4,4a <strcpy+0xa>
    ;
  return os;
}
  58:	60a2                	ld	ra,8(sp)
  5a:	6402                	ld	s0,0(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  60:	1141                	addi	sp,sp,-16
  62:	e406                	sd	ra,8(sp)
  64:	e022                	sd	s0,0(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x20>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x20>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strlen>:

uint
strlen(const char *s)
{
  90:	1141                	addi	sp,sp,-16
  92:	e406                	sd	ra,8(sp)
  94:	e022                	sd	s0,0(sp)
  96:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  98:	00054783          	lbu	a5,0(a0)
  9c:	cf91                	beqz	a5,b8 <strlen+0x28>
  9e:	00150793          	addi	a5,a0,1
  a2:	86be                	mv	a3,a5
  a4:	0785                	addi	a5,a5,1
  a6:	fff7c703          	lbu	a4,-1(a5)
  aa:	ff65                	bnez	a4,a2 <strlen+0x12>
  ac:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
  b0:	60a2                	ld	ra,8(sp)
  b2:	6402                	ld	s0,0(sp)
  b4:	0141                	addi	sp,sp,16
  b6:	8082                	ret
  for(n = 0; s[n]; n++)
  b8:	4501                	li	a0,0
  ba:	bfdd                	j	b0 <strlen+0x20>

00000000000000bc <memset>:

void*
memset(void *dst, int c, uint n)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e406                	sd	ra,8(sp)
  c0:	e022                	sd	s0,0(sp)
  c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c4:	ca19                	beqz	a2,da <memset+0x1e>
  c6:	87aa                	mv	a5,a0
  c8:	1602                	slli	a2,a2,0x20
  ca:	9201                	srli	a2,a2,0x20
  cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d4:	0785                	addi	a5,a5,1
  d6:	fee79de3          	bne	a5,a4,d0 <memset+0x14>
  }
  return dst;
}
  da:	60a2                	ld	ra,8(sp)
  dc:	6402                	ld	s0,0(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <strchr>:

char*
strchr(const char *s, char c)
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cf81                	beqz	a5,106 <strchr+0x24>
    if(*s == c)
  f0:	00f58763          	beq	a1,a5,fe <strchr+0x1c>
  for(; *s; s++)
  f4:	0505                	addi	a0,a0,1
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbfd                	bnez	a5,f0 <strchr+0xe>
      return (char*)s;
  return 0;
  fc:	4501                	li	a0,0
}
  fe:	60a2                	ld	ra,8(sp)
 100:	6402                	ld	s0,0(sp)
 102:	0141                	addi	sp,sp,16
 104:	8082                	ret
  return 0;
 106:	4501                	li	a0,0
 108:	bfdd                	j	fe <strchr+0x1c>

000000000000010a <gets>:

char*
gets(char *buf, int max)
{
 10a:	711d                	addi	sp,sp,-96
 10c:	ec86                	sd	ra,88(sp)
 10e:	e8a2                	sd	s0,80(sp)
 110:	e4a6                	sd	s1,72(sp)
 112:	e0ca                	sd	s2,64(sp)
 114:	fc4e                	sd	s3,56(sp)
 116:	f852                	sd	s4,48(sp)
 118:	f456                	sd	s5,40(sp)
 11a:	f05a                	sd	s6,32(sp)
 11c:	ec5e                	sd	s7,24(sp)
 11e:	e862                	sd	s8,16(sp)
 120:	1080                	addi	s0,sp,96
 122:	8baa                	mv	s7,a0
 124:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 126:	892a                	mv	s2,a0
 128:	4481                	li	s1,0
    cc = read(0, &c, 1);
 12a:	faf40b13          	addi	s6,s0,-81
 12e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 130:	8c26                	mv	s8,s1
 132:	0014899b          	addiw	s3,s1,1
 136:	84ce                	mv	s1,s3
 138:	0349d463          	bge	s3,s4,160 <gets+0x56>
    cc = read(0, &c, 1);
 13c:	8656                	mv	a2,s5
 13e:	85da                	mv	a1,s6
 140:	4501                	li	a0,0
 142:	1bc000ef          	jal	2fe <read>
    if(cc < 1)
 146:	00a05d63          	blez	a0,160 <gets+0x56>
      break;
    buf[i++] = c;
 14a:	faf44783          	lbu	a5,-81(s0)
 14e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 152:	0905                	addi	s2,s2,1
 154:	ff678713          	addi	a4,a5,-10
 158:	c319                	beqz	a4,15e <gets+0x54>
 15a:	17cd                	addi	a5,a5,-13
 15c:	fbf1                	bnez	a5,130 <gets+0x26>
    buf[i++] = c;
 15e:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 160:	9c5e                	add	s8,s8,s7
 162:	000c0023          	sb	zero,0(s8)
  return buf;
}
 166:	855e                	mv	a0,s7
 168:	60e6                	ld	ra,88(sp)
 16a:	6446                	ld	s0,80(sp)
 16c:	64a6                	ld	s1,72(sp)
 16e:	6906                	ld	s2,64(sp)
 170:	79e2                	ld	s3,56(sp)
 172:	7a42                	ld	s4,48(sp)
 174:	7aa2                	ld	s5,40(sp)
 176:	7b02                	ld	s6,32(sp)
 178:	6be2                	ld	s7,24(sp)
 17a:	6c42                	ld	s8,16(sp)
 17c:	6125                	addi	sp,sp,96
 17e:	8082                	ret

0000000000000180 <stat>:

int
stat(const char *n, struct stat *st)
{
 180:	1101                	addi	sp,sp,-32
 182:	ec06                	sd	ra,24(sp)
 184:	e822                	sd	s0,16(sp)
 186:	e04a                	sd	s2,0(sp)
 188:	1000                	addi	s0,sp,32
 18a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18c:	4581                	li	a1,0
 18e:	198000ef          	jal	326 <open>
  if(fd < 0)
 192:	02054263          	bltz	a0,1b6 <stat+0x36>
 196:	e426                	sd	s1,8(sp)
 198:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19a:	85ca                	mv	a1,s2
 19c:	1a2000ef          	jal	33e <fstat>
 1a0:	892a                	mv	s2,a0
  close(fd);
 1a2:	8526                	mv	a0,s1
 1a4:	16a000ef          	jal	30e <close>
  return r;
 1a8:	64a2                	ld	s1,8(sp)
}
 1aa:	854a                	mv	a0,s2
 1ac:	60e2                	ld	ra,24(sp)
 1ae:	6442                	ld	s0,16(sp)
 1b0:	6902                	ld	s2,0(sp)
 1b2:	6105                	addi	sp,sp,32
 1b4:	8082                	ret
    return -1;
 1b6:	57fd                	li	a5,-1
 1b8:	893e                	mv	s2,a5
 1ba:	bfc5                	j	1aa <stat+0x2a>

00000000000001bc <atoi>:

int
atoi(const char *s)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c4:	00054683          	lbu	a3,0(a0)
 1c8:	fd06879b          	addiw	a5,a3,-48
 1cc:	0ff7f793          	zext.b	a5,a5
 1d0:	4625                	li	a2,9
 1d2:	02f66963          	bltu	a2,a5,204 <atoi+0x48>
 1d6:	872a                	mv	a4,a0
  n = 0;
 1d8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1da:	0705                	addi	a4,a4,1
 1dc:	0025179b          	slliw	a5,a0,0x2
 1e0:	9fa9                	addw	a5,a5,a0
 1e2:	0017979b          	slliw	a5,a5,0x1
 1e6:	9fb5                	addw	a5,a5,a3
 1e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ec:	00074683          	lbu	a3,0(a4)
 1f0:	fd06879b          	addiw	a5,a3,-48
 1f4:	0ff7f793          	zext.b	a5,a5
 1f8:	fef671e3          	bgeu	a2,a5,1da <atoi+0x1e>
  return n;
}
 1fc:	60a2                	ld	ra,8(sp)
 1fe:	6402                	ld	s0,0(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfdd                	j	1fc <atoi+0x40>

0000000000000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e406                	sd	ra,8(sp)
 20c:	e022                	sd	s0,0(sp)
 20e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 210:	02b57563          	bgeu	a0,a1,23a <memmove+0x32>
    while(n-- > 0)
 214:	00c05f63          	blez	a2,232 <memmove+0x2a>
 218:	1602                	slli	a2,a2,0x20
 21a:	9201                	srli	a2,a2,0x20
 21c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 220:	872a                	mv	a4,a0
      *dst++ = *src++;
 222:	0585                	addi	a1,a1,1
 224:	0705                	addi	a4,a4,1
 226:	fff5c683          	lbu	a3,-1(a1)
 22a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22e:	fee79ae3          	bne	a5,a4,222 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 232:	60a2                	ld	ra,8(sp)
 234:	6402                	ld	s0,0(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
    while(n-- > 0)
 23a:	fec05ce3          	blez	a2,232 <memmove+0x2a>
    dst += n;
 23e:	00c50733          	add	a4,a0,a2
    src += n;
 242:	95b2                	add	a1,a1,a2
 244:	fff6079b          	addiw	a5,a2,-1
 248:	1782                	slli	a5,a5,0x20
 24a:	9381                	srli	a5,a5,0x20
 24c:	fff7c793          	not	a5,a5
 250:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 252:	15fd                	addi	a1,a1,-1
 254:	177d                	addi	a4,a4,-1
 256:	0005c683          	lbu	a3,0(a1)
 25a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25e:	fef71ae3          	bne	a4,a5,252 <memmove+0x4a>
 262:	bfc1                	j	232 <memmove+0x2a>

0000000000000264 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e406                	sd	ra,8(sp)
 268:	e022                	sd	s0,0(sp)
 26a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26c:	c61d                	beqz	a2,29a <memcmp+0x36>
 26e:	1602                	slli	a2,a2,0x20
 270:	9201                	srli	a2,a2,0x20
 272:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 276:	00054783          	lbu	a5,0(a0)
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00e79863          	bne	a5,a4,28e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 282:	0505                	addi	a0,a0,1
    p2++;
 284:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 286:	fed518e3          	bne	a0,a3,276 <memcmp+0x12>
  }
  return 0;
 28a:	4501                	li	a0,0
 28c:	a019                	j	292 <memcmp+0x2e>
      return *p1 - *p2;
 28e:	40e7853b          	subw	a0,a5,a4
}
 292:	60a2                	ld	ra,8(sp)
 294:	6402                	ld	s0,0(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  return 0;
 29a:	4501                	li	a0,0
 29c:	bfdd                	j	292 <memcmp+0x2e>

000000000000029e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a6:	f63ff0ef          	jal	208 <memmove>
}
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <sbrk>:

char *
sbrk(int n) {
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e406                	sd	ra,8(sp)
 2b6:	e022                	sd	s0,0(sp)
 2b8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2ba:	4585                	li	a1,1
 2bc:	0b2000ef          	jal	36e <sys_sbrk>
}
 2c0:	60a2                	ld	ra,8(sp)
 2c2:	6402                	ld	s0,0(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <sbrklazy>:

char *
sbrklazy(int n) {
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d0:	4589                	li	a1,2
 2d2:	09c000ef          	jal	36e <sys_sbrk>
}
 2d6:	60a2                	ld	ra,8(sp)
 2d8:	6402                	ld	s0,0(sp)
 2da:	0141                	addi	sp,sp,16
 2dc:	8082                	ret

00000000000002de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2de:	4885                	li	a7,1
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2e6:	4889                	li	a7,2
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ee:	488d                	li	a7,3
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2f6:	4891                	li	a7,4
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <read>:
.global read
read:
 li a7, SYS_read
 2fe:	4895                	li	a7,5
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <write>:
.global write
write:
 li a7, SYS_write
 306:	48c1                	li	a7,16
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <close>:
.global close
close:
 li a7, SYS_close
 30e:	48d5                	li	a7,21
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <kill>:
.global kill
kill:
 li a7, SYS_kill
 316:	4899                	li	a7,6
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <exec>:
.global exec
exec:
 li a7, SYS_exec
 31e:	489d                	li	a7,7
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <open>:
.global open
open:
 li a7, SYS_open
 326:	48bd                	li	a7,15
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 32e:	48c5                	li	a7,17
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 336:	48c9                	li	a7,18
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 33e:	48a1                	li	a7,8
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <link>:
.global link
link:
 li a7, SYS_link
 346:	48cd                	li	a7,19
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 34e:	48d1                	li	a7,20
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 356:	48a5                	li	a7,9
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <dup>:
.global dup
dup:
 li a7, SYS_dup
 35e:	48a9                	li	a7,10
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 366:	48ad                	li	a7,11
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 36e:	48b1                	li	a7,12
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <pause>:
.global pause
pause:
 li a7, SYS_pause
 376:	48b5                	li	a7,13
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 37e:	48b9                	li	a7,14
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <kps>:
.global kps
kps:
 li a7, SYS_kps
 386:	48d9                	li	a7,22
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 38e:	1101                	addi	sp,sp,-32
 390:	ec06                	sd	ra,24(sp)
 392:	e822                	sd	s0,16(sp)
 394:	1000                	addi	s0,sp,32
 396:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 39a:	4605                	li	a2,1
 39c:	fef40593          	addi	a1,s0,-17
 3a0:	f67ff0ef          	jal	306 <write>
}
 3a4:	60e2                	ld	ra,24(sp)
 3a6:	6442                	ld	s0,16(sp)
 3a8:	6105                	addi	sp,sp,32
 3aa:	8082                	ret

00000000000003ac <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3ac:	715d                	addi	sp,sp,-80
 3ae:	e486                	sd	ra,72(sp)
 3b0:	e0a2                	sd	s0,64(sp)
 3b2:	f84a                	sd	s2,48(sp)
 3b4:	f44e                	sd	s3,40(sp)
 3b6:	0880                	addi	s0,sp,80
 3b8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3ba:	c6d1                	beqz	a3,446 <printint+0x9a>
 3bc:	0805d563          	bgez	a1,446 <printint+0x9a>
    neg = 1;
    x = -xx;
 3c0:	40b005b3          	neg	a1,a1
    neg = 1;
 3c4:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 3c6:	fb840993          	addi	s3,s0,-72
  neg = 0;
 3ca:	86ce                	mv	a3,s3
  i = 0;
 3cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ce:	00000817          	auipc	a6,0x0
 3d2:	53280813          	addi	a6,a6,1330 # 900 <digits>
 3d6:	88ba                	mv	a7,a4
 3d8:	0017051b          	addiw	a0,a4,1
 3dc:	872a                	mv	a4,a0
 3de:	02c5f7b3          	remu	a5,a1,a2
 3e2:	97c2                	add	a5,a5,a6
 3e4:	0007c783          	lbu	a5,0(a5)
 3e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ec:	87ae                	mv	a5,a1
 3ee:	02c5d5b3          	divu	a1,a1,a2
 3f2:	0685                	addi	a3,a3,1
 3f4:	fec7f1e3          	bgeu	a5,a2,3d6 <printint+0x2a>
  if(neg)
 3f8:	00030c63          	beqz	t1,410 <printint+0x64>
    buf[i++] = '-';
 3fc:	fd050793          	addi	a5,a0,-48
 400:	00878533          	add	a0,a5,s0
 404:	02d00793          	li	a5,45
 408:	fef50423          	sb	a5,-24(a0)
 40c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 410:	02e05563          	blez	a4,43a <printint+0x8e>
 414:	fc26                	sd	s1,56(sp)
 416:	377d                	addiw	a4,a4,-1
 418:	00e984b3          	add	s1,s3,a4
 41c:	19fd                	addi	s3,s3,-1
 41e:	99ba                	add	s3,s3,a4
 420:	1702                	slli	a4,a4,0x20
 422:	9301                	srli	a4,a4,0x20
 424:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 428:	0004c583          	lbu	a1,0(s1)
 42c:	854a                	mv	a0,s2
 42e:	f61ff0ef          	jal	38e <putc>
  while(--i >= 0)
 432:	14fd                	addi	s1,s1,-1
 434:	ff349ae3          	bne	s1,s3,428 <printint+0x7c>
 438:	74e2                	ld	s1,56(sp)
}
 43a:	60a6                	ld	ra,72(sp)
 43c:	6406                	ld	s0,64(sp)
 43e:	7942                	ld	s2,48(sp)
 440:	79a2                	ld	s3,40(sp)
 442:	6161                	addi	sp,sp,80
 444:	8082                	ret
  neg = 0;
 446:	4301                	li	t1,0
 448:	bfbd                	j	3c6 <printint+0x1a>

000000000000044a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44a:	711d                	addi	sp,sp,-96
 44c:	ec86                	sd	ra,88(sp)
 44e:	e8a2                	sd	s0,80(sp)
 450:	e4a6                	sd	s1,72(sp)
 452:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 454:	0005c483          	lbu	s1,0(a1)
 458:	22048363          	beqz	s1,67e <vprintf+0x234>
 45c:	e0ca                	sd	s2,64(sp)
 45e:	fc4e                	sd	s3,56(sp)
 460:	f852                	sd	s4,48(sp)
 462:	f456                	sd	s5,40(sp)
 464:	f05a                	sd	s6,32(sp)
 466:	ec5e                	sd	s7,24(sp)
 468:	e862                	sd	s8,16(sp)
 46a:	8b2a                	mv	s6,a0
 46c:	8a2e                	mv	s4,a1
 46e:	8bb2                	mv	s7,a2
  state = 0;
 470:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 472:	4901                	li	s2,0
 474:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 476:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 47a:	06400c13          	li	s8,100
 47e:	a00d                	j	4a0 <vprintf+0x56>
        putc(fd, c0);
 480:	85a6                	mv	a1,s1
 482:	855a                	mv	a0,s6
 484:	f0bff0ef          	jal	38e <putc>
 488:	a019                	j	48e <vprintf+0x44>
    } else if(state == '%'){
 48a:	03598363          	beq	s3,s5,4b0 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 48e:	0019079b          	addiw	a5,s2,1
 492:	893e                	mv	s2,a5
 494:	873e                	mv	a4,a5
 496:	97d2                	add	a5,a5,s4
 498:	0007c483          	lbu	s1,0(a5)
 49c:	1c048a63          	beqz	s1,670 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 4a0:	0004879b          	sext.w	a5,s1
    if(state == 0){
 4a4:	fe0993e3          	bnez	s3,48a <vprintf+0x40>
      if(c0 == '%'){
 4a8:	fd579ce3          	bne	a5,s5,480 <vprintf+0x36>
        state = '%';
 4ac:	89be                	mv	s3,a5
 4ae:	b7c5                	j	48e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 4b0:	00ea06b3          	add	a3,s4,a4
 4b4:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 4b8:	1c060863          	beqz	a2,688 <vprintf+0x23e>
      if(c0 == 'd'){
 4bc:	03878763          	beq	a5,s8,4ea <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4c0:	f9478693          	addi	a3,a5,-108
 4c4:	0016b693          	seqz	a3,a3
 4c8:	f9c60593          	addi	a1,a2,-100
 4cc:	e99d                	bnez	a1,502 <vprintf+0xb8>
 4ce:	ca95                	beqz	a3,502 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 4d0:	008b8493          	addi	s1,s7,8
 4d4:	4685                	li	a3,1
 4d6:	4629                	li	a2,10
 4d8:	000bb583          	ld	a1,0(s7)
 4dc:	855a                	mv	a0,s6
 4de:	ecfff0ef          	jal	3ac <printint>
        i += 1;
 4e2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 4e4:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4e6:	4981                	li	s3,0
 4e8:	b75d                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 4ea:	008b8493          	addi	s1,s7,8
 4ee:	4685                	li	a3,1
 4f0:	4629                	li	a2,10
 4f2:	000ba583          	lw	a1,0(s7)
 4f6:	855a                	mv	a0,s6
 4f8:	eb5ff0ef          	jal	3ac <printint>
 4fc:	8ba6                	mv	s7,s1
      state = 0;
 4fe:	4981                	li	s3,0
 500:	b779                	j	48e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 502:	9752                	add	a4,a4,s4
 504:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 508:	f9460713          	addi	a4,a2,-108
 50c:	00173713          	seqz	a4,a4
 510:	8f75                	and	a4,a4,a3
 512:	f9c58513          	addi	a0,a1,-100
 516:	18051363          	bnez	a0,69c <vprintf+0x252>
 51a:	18070163          	beqz	a4,69c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 51e:	008b8493          	addi	s1,s7,8
 522:	4685                	li	a3,1
 524:	4629                	li	a2,10
 526:	000bb583          	ld	a1,0(s7)
 52a:	855a                	mv	a0,s6
 52c:	e81ff0ef          	jal	3ac <printint>
        i += 2;
 530:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 532:	8ba6                	mv	s7,s1
      state = 0;
 534:	4981                	li	s3,0
        i += 2;
 536:	bfa1                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 538:	008b8493          	addi	s1,s7,8
 53c:	4681                	li	a3,0
 53e:	4629                	li	a2,10
 540:	000be583          	lwu	a1,0(s7)
 544:	855a                	mv	a0,s6
 546:	e67ff0ef          	jal	3ac <printint>
 54a:	8ba6                	mv	s7,s1
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b781                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 550:	008b8493          	addi	s1,s7,8
 554:	4681                	li	a3,0
 556:	4629                	li	a2,10
 558:	000bb583          	ld	a1,0(s7)
 55c:	855a                	mv	a0,s6
 55e:	e4fff0ef          	jal	3ac <printint>
        i += 1;
 562:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 564:	8ba6                	mv	s7,s1
      state = 0;
 566:	4981                	li	s3,0
 568:	b71d                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 56a:	008b8493          	addi	s1,s7,8
 56e:	4681                	li	a3,0
 570:	4629                	li	a2,10
 572:	000bb583          	ld	a1,0(s7)
 576:	855a                	mv	a0,s6
 578:	e35ff0ef          	jal	3ac <printint>
        i += 2;
 57c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	8ba6                	mv	s7,s1
      state = 0;
 580:	4981                	li	s3,0
        i += 2;
 582:	b731                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 584:	008b8493          	addi	s1,s7,8
 588:	4681                	li	a3,0
 58a:	4641                	li	a2,16
 58c:	000be583          	lwu	a1,0(s7)
 590:	855a                	mv	a0,s6
 592:	e1bff0ef          	jal	3ac <printint>
 596:	8ba6                	mv	s7,s1
      state = 0;
 598:	4981                	li	s3,0
 59a:	bdd5                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 59c:	008b8493          	addi	s1,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4641                	li	a2,16
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	e03ff0ef          	jal	3ac <printint>
        i += 1;
 5ae:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b0:	8ba6                	mv	s7,s1
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bde9                	j	48e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b6:	008b8493          	addi	s1,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4641                	li	a2,16
 5be:	000bb583          	ld	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	de9ff0ef          	jal	3ac <printint>
        i += 2;
 5c8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ca:	8ba6                	mv	s7,s1
      state = 0;
 5cc:	4981                	li	s3,0
        i += 2;
 5ce:	b5c1                	j	48e <vprintf+0x44>
 5d0:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 5d2:	008b8793          	addi	a5,s7,8
 5d6:	8cbe                	mv	s9,a5
 5d8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5dc:	03000593          	li	a1,48
 5e0:	855a                	mv	a0,s6
 5e2:	dadff0ef          	jal	38e <putc>
  putc(fd, 'x');
 5e6:	07800593          	li	a1,120
 5ea:	855a                	mv	a0,s6
 5ec:	da3ff0ef          	jal	38e <putc>
 5f0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5f2:	00000b97          	auipc	s7,0x0
 5f6:	30eb8b93          	addi	s7,s7,782 # 900 <digits>
 5fa:	03c9d793          	srli	a5,s3,0x3c
 5fe:	97de                	add	a5,a5,s7
 600:	0007c583          	lbu	a1,0(a5)
 604:	855a                	mv	a0,s6
 606:	d89ff0ef          	jal	38e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 60a:	0992                	slli	s3,s3,0x4
 60c:	34fd                	addiw	s1,s1,-1
 60e:	f4f5                	bnez	s1,5fa <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 610:	8be6                	mv	s7,s9
      state = 0;
 612:	4981                	li	s3,0
 614:	6ca2                	ld	s9,8(sp)
 616:	bda5                	j	48e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 618:	008b8493          	addi	s1,s7,8
 61c:	000bc583          	lbu	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	d6dff0ef          	jal	38e <putc>
 626:	8ba6                	mv	s7,s1
      state = 0;
 628:	4981                	li	s3,0
 62a:	b595                	j	48e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 62c:	008b8993          	addi	s3,s7,8
 630:	000bb483          	ld	s1,0(s7)
 634:	cc91                	beqz	s1,650 <vprintf+0x206>
        for(; *s; s++)
 636:	0004c583          	lbu	a1,0(s1)
 63a:	c985                	beqz	a1,66a <vprintf+0x220>
          putc(fd, *s);
 63c:	855a                	mv	a0,s6
 63e:	d51ff0ef          	jal	38e <putc>
        for(; *s; s++)
 642:	0485                	addi	s1,s1,1
 644:	0004c583          	lbu	a1,0(s1)
 648:	f9f5                	bnez	a1,63c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 64a:	8bce                	mv	s7,s3
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b581                	j	48e <vprintf+0x44>
          s = "(null)";
 650:	00000497          	auipc	s1,0x0
 654:	2a848493          	addi	s1,s1,680 # 8f8 <malloc+0x10c>
        for(; *s; s++)
 658:	02800593          	li	a1,40
 65c:	b7c5                	j	63c <vprintf+0x1f2>
        putc(fd, '%');
 65e:	85be                	mv	a1,a5
 660:	855a                	mv	a0,s6
 662:	d2dff0ef          	jal	38e <putc>
      state = 0;
 666:	4981                	li	s3,0
 668:	b51d                	j	48e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 66a:	8bce                	mv	s7,s3
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b505                	j	48e <vprintf+0x44>
 670:	6906                	ld	s2,64(sp)
 672:	79e2                	ld	s3,56(sp)
 674:	7a42                	ld	s4,48(sp)
 676:	7aa2                	ld	s5,40(sp)
 678:	7b02                	ld	s6,32(sp)
 67a:	6be2                	ld	s7,24(sp)
 67c:	6c42                	ld	s8,16(sp)
    }
  }
}
 67e:	60e6                	ld	ra,88(sp)
 680:	6446                	ld	s0,80(sp)
 682:	64a6                	ld	s1,72(sp)
 684:	6125                	addi	sp,sp,96
 686:	8082                	ret
      if(c0 == 'd'){
 688:	06400713          	li	a4,100
 68c:	e4e78fe3          	beq	a5,a4,4ea <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 690:	f9478693          	addi	a3,a5,-108
 694:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 698:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 69a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 69c:	07500513          	li	a0,117
 6a0:	e8a78ce3          	beq	a5,a0,538 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 6a4:	f8b60513          	addi	a0,a2,-117
 6a8:	e119                	bnez	a0,6ae <vprintf+0x264>
 6aa:	ea0693e3          	bnez	a3,550 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6ae:	f8b58513          	addi	a0,a1,-117
 6b2:	e119                	bnez	a0,6b8 <vprintf+0x26e>
 6b4:	ea071be3          	bnez	a4,56a <vprintf+0x120>
      } else if(c0 == 'x'){
 6b8:	07800513          	li	a0,120
 6bc:	eca784e3          	beq	a5,a0,584 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 6c0:	f8860613          	addi	a2,a2,-120
 6c4:	e219                	bnez	a2,6ca <vprintf+0x280>
 6c6:	ec069be3          	bnez	a3,59c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ca:	f8858593          	addi	a1,a1,-120
 6ce:	e199                	bnez	a1,6d4 <vprintf+0x28a>
 6d0:	ee0713e3          	bnez	a4,5b6 <vprintf+0x16c>
      } else if(c0 == 'p'){
 6d4:	07000713          	li	a4,112
 6d8:	eee78ce3          	beq	a5,a4,5d0 <vprintf+0x186>
      } else if(c0 == 'c'){
 6dc:	06300713          	li	a4,99
 6e0:	f2e78ce3          	beq	a5,a4,618 <vprintf+0x1ce>
      } else if(c0 == 's'){
 6e4:	07300713          	li	a4,115
 6e8:	f4e782e3          	beq	a5,a4,62c <vprintf+0x1e2>
      } else if(c0 == '%'){
 6ec:	02500713          	li	a4,37
 6f0:	f6e787e3          	beq	a5,a4,65e <vprintf+0x214>
        putc(fd, '%');
 6f4:	02500593          	li	a1,37
 6f8:	855a                	mv	a0,s6
 6fa:	c95ff0ef          	jal	38e <putc>
        putc(fd, c0);
 6fe:	85a6                	mv	a1,s1
 700:	855a                	mv	a0,s6
 702:	c8dff0ef          	jal	38e <putc>
      state = 0;
 706:	4981                	li	s3,0
 708:	b359                	j	48e <vprintf+0x44>

000000000000070a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70a:	715d                	addi	sp,sp,-80
 70c:	ec06                	sd	ra,24(sp)
 70e:	e822                	sd	s0,16(sp)
 710:	1000                	addi	s0,sp,32
 712:	e010                	sd	a2,0(s0)
 714:	e414                	sd	a3,8(s0)
 716:	e818                	sd	a4,16(s0)
 718:	ec1c                	sd	a5,24(s0)
 71a:	03043023          	sd	a6,32(s0)
 71e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 722:	8622                	mv	a2,s0
 724:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 728:	d23ff0ef          	jal	44a <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6161                	addi	sp,sp,80
 732:	8082                	ret

0000000000000734 <printf>:

void
printf(const char *fmt, ...)
{
 734:	711d                	addi	sp,sp,-96
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e40c                	sd	a1,8(s0)
 73e:	e810                	sd	a2,16(s0)
 740:	ec14                	sd	a3,24(s0)
 742:	f018                	sd	a4,32(s0)
 744:	f41c                	sd	a5,40(s0)
 746:	03043823          	sd	a6,48(s0)
 74a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	00840613          	addi	a2,s0,8
 752:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 756:	85aa                	mv	a1,a0
 758:	4505                	li	a0,1
 75a:	cf1ff0ef          	jal	44a <vprintf>
}
 75e:	60e2                	ld	ra,24(sp)
 760:	6442                	ld	s0,16(sp)
 762:	6125                	addi	sp,sp,96
 764:	8082                	ret

0000000000000766 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 766:	1141                	addi	sp,sp,-16
 768:	e406                	sd	ra,8(sp)
 76a:	e022                	sd	s0,0(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00001797          	auipc	a5,0x1
 776:	88e7b783          	ld	a5,-1906(a5) # 1000 <freep>
 77a:	a039                	j	788 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77c:	6398                	ld	a4,0(a5)
 77e:	00e7e463          	bltu	a5,a4,786 <free+0x20>
 782:	00e6ea63          	bltu	a3,a4,796 <free+0x30>
{
 786:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	fed7fae3          	bgeu	a5,a3,77c <free+0x16>
 78c:	6398                	ld	a4,0(a5)
 78e:	00e6e463          	bltu	a3,a4,796 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 792:	fee7eae3          	bltu	a5,a4,786 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 796:	ff852583          	lw	a1,-8(a0)
 79a:	6390                	ld	a2,0(a5)
 79c:	02059813          	slli	a6,a1,0x20
 7a0:	01c85713          	srli	a4,a6,0x1c
 7a4:	9736                	add	a4,a4,a3
 7a6:	02e60563          	beq	a2,a4,7d0 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7ae:	4790                	lw	a2,8(a5)
 7b0:	02061593          	slli	a1,a2,0x20
 7b4:	01c5d713          	srli	a4,a1,0x1c
 7b8:	973e                	add	a4,a4,a5
 7ba:	02e68263          	beq	a3,a4,7de <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 7be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c0:	00001717          	auipc	a4,0x1
 7c4:	84f73023          	sd	a5,-1984(a4) # 1000 <freep>
}
 7c8:	60a2                	ld	ra,8(sp)
 7ca:	6402                	ld	s0,0(sp)
 7cc:	0141                	addi	sp,sp,16
 7ce:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 7d0:	4618                	lw	a4,8(a2)
 7d2:	9f2d                	addw	a4,a4,a1
 7d4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	6398                	ld	a4,0(a5)
 7da:	6310                	ld	a2,0(a4)
 7dc:	b7f9                	j	7aa <free+0x44>
    p->s.size += bp->s.size;
 7de:	ff852703          	lw	a4,-8(a0)
 7e2:	9f31                	addw	a4,a4,a2
 7e4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7e6:	ff053683          	ld	a3,-16(a0)
 7ea:	bfd1                	j	7be <free+0x58>

00000000000007ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ec:	7139                	addi	sp,sp,-64
 7ee:	fc06                	sd	ra,56(sp)
 7f0:	f822                	sd	s0,48(sp)
 7f2:	f04a                	sd	s2,32(sp)
 7f4:	ec4e                	sd	s3,24(sp)
 7f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f8:	02051993          	slli	s3,a0,0x20
 7fc:	0209d993          	srli	s3,s3,0x20
 800:	09bd                	addi	s3,s3,15
 802:	0049d993          	srli	s3,s3,0x4
 806:	2985                	addiw	s3,s3,1
 808:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 80a:	00000517          	auipc	a0,0x0
 80e:	7f653503          	ld	a0,2038(a0) # 1000 <freep>
 812:	c905                	beqz	a0,842 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 814:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 816:	4798                	lw	a4,8(a5)
 818:	09377663          	bgeu	a4,s3,8a4 <malloc+0xb8>
 81c:	f426                	sd	s1,40(sp)
 81e:	e852                	sd	s4,16(sp)
 820:	e456                	sd	s5,8(sp)
 822:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 824:	8a4e                	mv	s4,s3
 826:	6705                	lui	a4,0x1
 828:	00e9f363          	bgeu	s3,a4,82e <malloc+0x42>
 82c:	6a05                	lui	s4,0x1
 82e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 832:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 836:	00000497          	auipc	s1,0x0
 83a:	7ca48493          	addi	s1,s1,1994 # 1000 <freep>
  if(p == SBRK_ERROR)
 83e:	5afd                	li	s5,-1
 840:	a83d                	j	87e <malloc+0x92>
 842:	f426                	sd	s1,40(sp)
 844:	e852                	sd	s4,16(sp)
 846:	e456                	sd	s5,8(sp)
 848:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 84a:	00000797          	auipc	a5,0x0
 84e:	7c678793          	addi	a5,a5,1990 # 1010 <base>
 852:	00000717          	auipc	a4,0x0
 856:	7af73723          	sd	a5,1966(a4) # 1000 <freep>
 85a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 860:	b7d1                	j	824 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 862:	6398                	ld	a4,0(a5)
 864:	e118                	sd	a4,0(a0)
 866:	a899                	j	8bc <malloc+0xd0>
  hp->s.size = nu;
 868:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86c:	0541                	addi	a0,a0,16
 86e:	ef9ff0ef          	jal	766 <free>
  return freep;
 872:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 874:	c125                	beqz	a0,8d4 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 876:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 878:	4798                	lw	a4,8(a5)
 87a:	03277163          	bgeu	a4,s2,89c <malloc+0xb0>
    if(p == freep)
 87e:	6098                	ld	a4,0(s1)
 880:	853e                	mv	a0,a5
 882:	fef71ae3          	bne	a4,a5,876 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 886:	8552                	mv	a0,s4
 888:	a2bff0ef          	jal	2b2 <sbrk>
  if(p == SBRK_ERROR)
 88c:	fd551ee3          	bne	a0,s5,868 <malloc+0x7c>
        return 0;
 890:	4501                	li	a0,0
 892:	74a2                	ld	s1,40(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	a03d                	j	8c8 <malloc+0xdc>
 89c:	74a2                	ld	s1,40(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a4:	fae90fe3          	beq	s2,a4,862 <malloc+0x76>
        p->s.size -= nunits;
 8a8:	4137073b          	subw	a4,a4,s3
 8ac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ae:	02071693          	slli	a3,a4,0x20
 8b2:	01c6d713          	srli	a4,a3,0x1c
 8b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74a73223          	sd	a0,1860(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c4:	01078513          	addi	a0,a5,16
  }
}
 8c8:	70e2                	ld	ra,56(sp)
 8ca:	7442                	ld	s0,48(sp)
 8cc:	7902                	ld	s2,32(sp)
 8ce:	69e2                	ld	s3,24(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
 8d4:	74a2                	ld	s1,40(sp)
 8d6:	6a42                	ld	s4,16(sp)
 8d8:	6aa2                	ld	s5,8(sp)
 8da:	6b02                	ld	s6,0(sp)
 8dc:	b7f5                	j	8c8 <malloc+0xdc>
