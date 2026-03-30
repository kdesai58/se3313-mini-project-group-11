
user/_schedtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cpu_burst>:

#define NCHILD 5


// Dummy calculation function to simulate CPU burst
void cpu_burst(int iterations) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
    
    int start = uptime();        // ticks since boot
  10:	40e000ef          	jal	41e <uptime>
  14:	892a                	mv	s2,a0
    while (uptime() - start < iterations*10) {
  16:	0029949b          	slliw	s1,s3,0x2
  1a:	013484bb          	addw	s1,s1,s3
  1e:	0014949b          	slliw	s1,s1,0x1
  22:	3fc000ef          	jal	41e <uptime>
  26:	4125053b          	subw	a0,a0,s2
  2a:	fe954ce3          	blt	a0,s1,22 <cpu_burst+0x22>
            // busy wait: burn CPU
    }
}
  2e:	70a2                	ld	ra,40(sp)
  30:	7402                	ld	s0,32(sp)
  32:	64e2                	ld	s1,24(sp)
  34:	6942                	ld	s2,16(sp)
  36:	69a2                	ld	s3,8(sp)
  38:	6145                	addi	sp,sp,48
  3a:	8082                	ret

000000000000003c <child_process>:


void child_process(int child_id) {
  3c:	1101                	addi	sp,sp,-32
  3e:	ec06                	sd	ra,24(sp)
  40:	e822                	sd	s0,16(sp)
  42:	e426                	sd	s1,8(sp)
  44:	e04a                	sd	s2,0(sp)
  46:	1000                	addi	s0,sp,32
  48:	448d                	li	s1,3
    int burst_input;
    
   
    int j;
    for (j = 0; j < 3; j++) {
        burst_input = (NCHILD - child_id + 1);
  4a:	4919                	li	s2,6
  4c:	40a9093b          	subw	s2,s2,a0
        // burst_input = child_id;
        cpu_burst(burst_input);
  50:	854a                	mv	a0,s2
  52:	fafff0ef          	jal	0 <cpu_burst>
    for (j = 0; j < 3; j++) {
  56:	34fd                	addiw	s1,s1,-1
  58:	fce5                	bnez	s1,50 <child_process+0x14>
    }
}
  5a:	60e2                	ld	ra,24(sp)
  5c:	6442                	ld	s0,16(sp)
  5e:	64a2                	ld	s1,8(sp)
  60:	6902                	ld	s2,0(sp)
  62:	6105                	addi	sp,sp,32
  64:	8082                	ret

0000000000000066 <main>:

int main(void) {
  66:	7179                	addi	sp,sp,-48
  68:	f406                	sd	ra,40(sp)
  6a:	f022                	sd	s0,32(sp)
  6c:	ec26                	sd	s1,24(sp)
  6e:	e84a                	sd	s2,16(sp)
  70:	e44e                	sd	s3,8(sp)
  72:	1800                	addi	s0,sp,48
    int i;
    
    for (i = 0; i < NCHILD; i++) {
  74:	4481                	li	s1,0
            
            child_process(i + 1);
            exit(0);  
        } else {
            
            printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
  76:	00001997          	auipc	s3,0x1
  7a:	92a98993          	addi	s3,s3,-1750 # 9a0 <malloc+0x114>
    for (i = 0; i < NCHILD; i++) {
  7e:	4915                	li	s2,5
        int pid = fork();
  80:	2fe000ef          	jal	37e <fork>
  84:	862a                	mv	a2,a0
        if (pid < 0) {
  86:	02054463          	bltz	a0,ae <main+0x48>
        } else if (pid == 0) {
  8a:	cd05                	beqz	a0,c2 <main+0x5c>
            printf("Parent: Forked child %d with PID %d\n", i + 1, pid);
  8c:	0014859b          	addiw	a1,s1,1
  90:	84ae                	mv	s1,a1
  92:	854e                	mv	a0,s3
  94:	740000ef          	jal	7d4 <printf>
    for (i = 0; i < NCHILD; i++) {
  98:	ff2494e3          	bne	s1,s2,80 <main+0x1a>
  9c:	4495                	li	s1,5
    
    
   
    
    for (i = 0; i < NCHILD; i++) {
        wait(0);
  9e:	4501                	li	a0,0
  a0:	2ee000ef          	jal	38e <wait>
    for (i = 0; i < NCHILD; i++) {
  a4:	34fd                	addiw	s1,s1,-1
  a6:	fce5                	bnez	s1,9e <main+0x38>
    }
    
    
    exit(0);
  a8:	4501                	li	a0,0
  aa:	2dc000ef          	jal	386 <exit>
            printf("Fork failed for child %d\n", i);
  ae:	85a6                	mv	a1,s1
  b0:	00001517          	auipc	a0,0x1
  b4:	8d050513          	addi	a0,a0,-1840 # 980 <malloc+0xf4>
  b8:	71c000ef          	jal	7d4 <printf>
            exit(1);
  bc:	4505                	li	a0,1
  be:	2c8000ef          	jal	386 <exit>
            child_process(i + 1);
  c2:	0014851b          	addiw	a0,s1,1
  c6:	f77ff0ef          	jal	3c <child_process>
            exit(0);  
  ca:	4501                	li	a0,0
  cc:	2ba000ef          	jal	386 <exit>

00000000000000d0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e406                	sd	ra,8(sp)
  d4:	e022                	sd	s0,0(sp)
  d6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  d8:	f8fff0ef          	jal	66 <main>
  exit(r);
  dc:	2aa000ef          	jal	386 <exit>

00000000000000e0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e406                	sd	ra,8(sp)
  e4:	e022                	sd	s0,0(sp)
  e6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e8:	87aa                	mv	a5,a0
  ea:	0585                	addi	a1,a1,1
  ec:	0785                	addi	a5,a5,1
  ee:	fff5c703          	lbu	a4,-1(a1)
  f2:	fee78fa3          	sb	a4,-1(a5)
  f6:	fb75                	bnez	a4,ea <strcpy+0xa>
    ;
  return os;
}
  f8:	60a2                	ld	ra,8(sp)
  fa:	6402                	ld	s0,0(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret

0000000000000100 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cb91                	beqz	a5,120 <strcmp+0x20>
 10e:	0005c703          	lbu	a4,0(a1)
 112:	00f71763          	bne	a4,a5,120 <strcmp+0x20>
    p++, q++;
 116:	0505                	addi	a0,a0,1
 118:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	fbe5                	bnez	a5,10e <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 120:	0005c503          	lbu	a0,0(a1)
}
 124:	40a7853b          	subw	a0,a5,a0
 128:	60a2                	ld	ra,8(sp)
 12a:	6402                	ld	s0,0(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:

uint
strlen(const char *s)
{
 130:	1141                	addi	sp,sp,-16
 132:	e406                	sd	ra,8(sp)
 134:	e022                	sd	s0,0(sp)
 136:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 138:	00054783          	lbu	a5,0(a0)
 13c:	cf91                	beqz	a5,158 <strlen+0x28>
 13e:	00150793          	addi	a5,a0,1
 142:	86be                	mv	a3,a5
 144:	0785                	addi	a5,a5,1
 146:	fff7c703          	lbu	a4,-1(a5)
 14a:	ff65                	bnez	a4,142 <strlen+0x12>
 14c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 150:	60a2                	ld	ra,8(sp)
 152:	6402                	ld	s0,0(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret
  for(n = 0; s[n]; n++)
 158:	4501                	li	a0,0
 15a:	bfdd                	j	150 <strlen+0x20>

000000000000015c <memset>:

void*
memset(void *dst, int c, uint n)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 164:	ca19                	beqz	a2,17a <memset+0x1e>
 166:	87aa                	mv	a5,a0
 168:	1602                	slli	a2,a2,0x20
 16a:	9201                	srli	a2,a2,0x20
 16c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 170:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 174:	0785                	addi	a5,a5,1
 176:	fee79de3          	bne	a5,a4,170 <memset+0x14>
  }
  return dst;
}
 17a:	60a2                	ld	ra,8(sp)
 17c:	6402                	ld	s0,0(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret

0000000000000182 <strchr>:

char*
strchr(const char *s, char c)
{
 182:	1141                	addi	sp,sp,-16
 184:	e406                	sd	ra,8(sp)
 186:	e022                	sd	s0,0(sp)
 188:	0800                	addi	s0,sp,16
  for(; *s; s++)
 18a:	00054783          	lbu	a5,0(a0)
 18e:	cf81                	beqz	a5,1a6 <strchr+0x24>
    if(*s == c)
 190:	00f58763          	beq	a1,a5,19e <strchr+0x1c>
  for(; *s; s++)
 194:	0505                	addi	a0,a0,1
 196:	00054783          	lbu	a5,0(a0)
 19a:	fbfd                	bnez	a5,190 <strchr+0xe>
      return (char*)s;
  return 0;
 19c:	4501                	li	a0,0
}
 19e:	60a2                	ld	ra,8(sp)
 1a0:	6402                	ld	s0,0(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  return 0;
 1a6:	4501                	li	a0,0
 1a8:	bfdd                	j	19e <strchr+0x1c>

00000000000001aa <gets>:

char*
gets(char *buf, int max)
{
 1aa:	711d                	addi	sp,sp,-96
 1ac:	ec86                	sd	ra,88(sp)
 1ae:	e8a2                	sd	s0,80(sp)
 1b0:	e4a6                	sd	s1,72(sp)
 1b2:	e0ca                	sd	s2,64(sp)
 1b4:	fc4e                	sd	s3,56(sp)
 1b6:	f852                	sd	s4,48(sp)
 1b8:	f456                	sd	s5,40(sp)
 1ba:	f05a                	sd	s6,32(sp)
 1bc:	ec5e                	sd	s7,24(sp)
 1be:	e862                	sd	s8,16(sp)
 1c0:	1080                	addi	s0,sp,96
 1c2:	8baa                	mv	s7,a0
 1c4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c6:	892a                	mv	s2,a0
 1c8:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1ca:	faf40b13          	addi	s6,s0,-81
 1ce:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 1d0:	8c26                	mv	s8,s1
 1d2:	0014899b          	addiw	s3,s1,1
 1d6:	84ce                	mv	s1,s3
 1d8:	0349d463          	bge	s3,s4,200 <gets+0x56>
    cc = read(0, &c, 1);
 1dc:	8656                	mv	a2,s5
 1de:	85da                	mv	a1,s6
 1e0:	4501                	li	a0,0
 1e2:	1bc000ef          	jal	39e <read>
    if(cc < 1)
 1e6:	00a05d63          	blez	a0,200 <gets+0x56>
      break;
    buf[i++] = c;
 1ea:	faf44783          	lbu	a5,-81(s0)
 1ee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f2:	0905                	addi	s2,s2,1
 1f4:	ff678713          	addi	a4,a5,-10
 1f8:	c319                	beqz	a4,1fe <gets+0x54>
 1fa:	17cd                	addi	a5,a5,-13
 1fc:	fbf1                	bnez	a5,1d0 <gets+0x26>
    buf[i++] = c;
 1fe:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 200:	9c5e                	add	s8,s8,s7
 202:	000c0023          	sb	zero,0(s8)
  return buf;
}
 206:	855e                	mv	a0,s7
 208:	60e6                	ld	ra,88(sp)
 20a:	6446                	ld	s0,80(sp)
 20c:	64a6                	ld	s1,72(sp)
 20e:	6906                	ld	s2,64(sp)
 210:	79e2                	ld	s3,56(sp)
 212:	7a42                	ld	s4,48(sp)
 214:	7aa2                	ld	s5,40(sp)
 216:	7b02                	ld	s6,32(sp)
 218:	6be2                	ld	s7,24(sp)
 21a:	6c42                	ld	s8,16(sp)
 21c:	6125                	addi	sp,sp,96
 21e:	8082                	ret

0000000000000220 <stat>:

int
stat(const char *n, struct stat *st)
{
 220:	1101                	addi	sp,sp,-32
 222:	ec06                	sd	ra,24(sp)
 224:	e822                	sd	s0,16(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
 22a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22c:	4581                	li	a1,0
 22e:	198000ef          	jal	3c6 <open>
  if(fd < 0)
 232:	02054263          	bltz	a0,256 <stat+0x36>
 236:	e426                	sd	s1,8(sp)
 238:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23a:	85ca                	mv	a1,s2
 23c:	1a2000ef          	jal	3de <fstat>
 240:	892a                	mv	s2,a0
  close(fd);
 242:	8526                	mv	a0,s1
 244:	16a000ef          	jal	3ae <close>
  return r;
 248:	64a2                	ld	s1,8(sp)
}
 24a:	854a                	mv	a0,s2
 24c:	60e2                	ld	ra,24(sp)
 24e:	6442                	ld	s0,16(sp)
 250:	6902                	ld	s2,0(sp)
 252:	6105                	addi	sp,sp,32
 254:	8082                	ret
    return -1;
 256:	57fd                	li	a5,-1
 258:	893e                	mv	s2,a5
 25a:	bfc5                	j	24a <stat+0x2a>

000000000000025c <atoi>:

int
atoi(const char *s)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e406                	sd	ra,8(sp)
 260:	e022                	sd	s0,0(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 264:	00054683          	lbu	a3,0(a0)
 268:	fd06879b          	addiw	a5,a3,-48
 26c:	0ff7f793          	zext.b	a5,a5
 270:	4625                	li	a2,9
 272:	02f66963          	bltu	a2,a5,2a4 <atoi+0x48>
 276:	872a                	mv	a4,a0
  n = 0;
 278:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 27a:	0705                	addi	a4,a4,1
 27c:	0025179b          	slliw	a5,a0,0x2
 280:	9fa9                	addw	a5,a5,a0
 282:	0017979b          	slliw	a5,a5,0x1
 286:	9fb5                	addw	a5,a5,a3
 288:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28c:	00074683          	lbu	a3,0(a4)
 290:	fd06879b          	addiw	a5,a3,-48
 294:	0ff7f793          	zext.b	a5,a5
 298:	fef671e3          	bgeu	a2,a5,27a <atoi+0x1e>
  return n;
}
 29c:	60a2                	ld	ra,8(sp)
 29e:	6402                	ld	s0,0(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  n = 0;
 2a4:	4501                	li	a0,0
 2a6:	bfdd                	j	29c <atoi+0x40>

00000000000002a8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b0:	02b57563          	bgeu	a0,a1,2da <memmove+0x32>
    while(n-- > 0)
 2b4:	00c05f63          	blez	a2,2d2 <memmove+0x2a>
 2b8:	1602                	slli	a2,a2,0x20
 2ba:	9201                	srli	a2,a2,0x20
 2bc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c2:	0585                	addi	a1,a1,1
 2c4:	0705                	addi	a4,a4,1
 2c6:	fff5c683          	lbu	a3,-1(a1)
 2ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d2:	60a2                	ld	ra,8(sp)
 2d4:	6402                	ld	s0,0(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
    while(n-- > 0)
 2da:	fec05ce3          	blez	a2,2d2 <memmove+0x2a>
    dst += n;
 2de:	00c50733          	add	a4,a0,a2
    src += n;
 2e2:	95b2                	add	a1,a1,a2
 2e4:	fff6079b          	addiw	a5,a2,-1
 2e8:	1782                	slli	a5,a5,0x20
 2ea:	9381                	srli	a5,a5,0x20
 2ec:	fff7c793          	not	a5,a5
 2f0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f2:	15fd                	addi	a1,a1,-1
 2f4:	177d                	addi	a4,a4,-1
 2f6:	0005c683          	lbu	a3,0(a1)
 2fa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fe:	fef71ae3          	bne	a4,a5,2f2 <memmove+0x4a>
 302:	bfc1                	j	2d2 <memmove+0x2a>

0000000000000304 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e406                	sd	ra,8(sp)
 308:	e022                	sd	s0,0(sp)
 30a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30c:	c61d                	beqz	a2,33a <memcmp+0x36>
 30e:	1602                	slli	a2,a2,0x20
 310:	9201                	srli	a2,a2,0x20
 312:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 316:	00054783          	lbu	a5,0(a0)
 31a:	0005c703          	lbu	a4,0(a1)
 31e:	00e79863          	bne	a5,a4,32e <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 322:	0505                	addi	a0,a0,1
    p2++;
 324:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 326:	fed518e3          	bne	a0,a3,316 <memcmp+0x12>
  }
  return 0;
 32a:	4501                	li	a0,0
 32c:	a019                	j	332 <memcmp+0x2e>
      return *p1 - *p2;
 32e:	40e7853b          	subw	a0,a5,a4
}
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret
  return 0;
 33a:	4501                	li	a0,0
 33c:	bfdd                	j	332 <memcmp+0x2e>

000000000000033e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 346:	f63ff0ef          	jal	2a8 <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <sbrk>:

char *
sbrk(int n) {
 352:	1141                	addi	sp,sp,-16
 354:	e406                	sd	ra,8(sp)
 356:	e022                	sd	s0,0(sp)
 358:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 35a:	4585                	li	a1,1
 35c:	0b2000ef          	jal	40e <sys_sbrk>
}
 360:	60a2                	ld	ra,8(sp)
 362:	6402                	ld	s0,0(sp)
 364:	0141                	addi	sp,sp,16
 366:	8082                	ret

0000000000000368 <sbrklazy>:

char *
sbrklazy(int n) {
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 370:	4589                	li	a1,2
 372:	09c000ef          	jal	40e <sys_sbrk>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37e:	4885                	li	a7,1
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exit>:
.global exit
exit:
 li a7, SYS_exit
 386:	4889                	li	a7,2
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <wait>:
.global wait
wait:
 li a7, SYS_wait
 38e:	488d                	li	a7,3
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 396:	4891                	li	a7,4
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <read>:
.global read
read:
 li a7, SYS_read
 39e:	4895                	li	a7,5
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <write>:
.global write
write:
 li a7, SYS_write
 3a6:	48c1                	li	a7,16
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <close>:
.global close
close:
 li a7, SYS_close
 3ae:	48d5                	li	a7,21
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b6:	4899                	li	a7,6
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <exec>:
.global exec
exec:
 li a7, SYS_exec
 3be:	489d                	li	a7,7
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <open>:
.global open
open:
 li a7, SYS_open
 3c6:	48bd                	li	a7,15
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ce:	48c5                	li	a7,17
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d6:	48c9                	li	a7,18
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3de:	48a1                	li	a7,8
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <link>:
.global link
link:
 li a7, SYS_link
 3e6:	48cd                	li	a7,19
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ee:	48d1                	li	a7,20
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f6:	48a5                	li	a7,9
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fe:	48a9                	li	a7,10
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 406:	48ad                	li	a7,11
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 40e:	48b1                	li	a7,12
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <pause>:
.global pause
pause:
 li a7, SYS_pause
 416:	48b5                	li	a7,13
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41e:	48b9                	li	a7,14
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <kps>:
.global kps
kps:
 li a7, SYS_kps
 426:	48d9                	li	a7,22
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 42e:	1101                	addi	sp,sp,-32
 430:	ec06                	sd	ra,24(sp)
 432:	e822                	sd	s0,16(sp)
 434:	1000                	addi	s0,sp,32
 436:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 43a:	4605                	li	a2,1
 43c:	fef40593          	addi	a1,s0,-17
 440:	f67ff0ef          	jal	3a6 <write>
}
 444:	60e2                	ld	ra,24(sp)
 446:	6442                	ld	s0,16(sp)
 448:	6105                	addi	sp,sp,32
 44a:	8082                	ret

000000000000044c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 44c:	715d                	addi	sp,sp,-80
 44e:	e486                	sd	ra,72(sp)
 450:	e0a2                	sd	s0,64(sp)
 452:	f84a                	sd	s2,48(sp)
 454:	f44e                	sd	s3,40(sp)
 456:	0880                	addi	s0,sp,80
 458:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 45a:	c6d1                	beqz	a3,4e6 <printint+0x9a>
 45c:	0805d563          	bgez	a1,4e6 <printint+0x9a>
    neg = 1;
    x = -xx;
 460:	40b005b3          	neg	a1,a1
    neg = 1;
 464:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 466:	fb840993          	addi	s3,s0,-72
  neg = 0;
 46a:	86ce                	mv	a3,s3
  i = 0;
 46c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 46e:	00000817          	auipc	a6,0x0
 472:	56280813          	addi	a6,a6,1378 # 9d0 <digits>
 476:	88ba                	mv	a7,a4
 478:	0017051b          	addiw	a0,a4,1
 47c:	872a                	mv	a4,a0
 47e:	02c5f7b3          	remu	a5,a1,a2
 482:	97c2                	add	a5,a5,a6
 484:	0007c783          	lbu	a5,0(a5)
 488:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 48c:	87ae                	mv	a5,a1
 48e:	02c5d5b3          	divu	a1,a1,a2
 492:	0685                	addi	a3,a3,1
 494:	fec7f1e3          	bgeu	a5,a2,476 <printint+0x2a>
  if(neg)
 498:	00030c63          	beqz	t1,4b0 <printint+0x64>
    buf[i++] = '-';
 49c:	fd050793          	addi	a5,a0,-48
 4a0:	00878533          	add	a0,a5,s0
 4a4:	02d00793          	li	a5,45
 4a8:	fef50423          	sb	a5,-24(a0)
 4ac:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 4b0:	02e05563          	blez	a4,4da <printint+0x8e>
 4b4:	fc26                	sd	s1,56(sp)
 4b6:	377d                	addiw	a4,a4,-1
 4b8:	00e984b3          	add	s1,s3,a4
 4bc:	19fd                	addi	s3,s3,-1
 4be:	99ba                	add	s3,s3,a4
 4c0:	1702                	slli	a4,a4,0x20
 4c2:	9301                	srli	a4,a4,0x20
 4c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c8:	0004c583          	lbu	a1,0(s1)
 4cc:	854a                	mv	a0,s2
 4ce:	f61ff0ef          	jal	42e <putc>
  while(--i >= 0)
 4d2:	14fd                	addi	s1,s1,-1
 4d4:	ff349ae3          	bne	s1,s3,4c8 <printint+0x7c>
 4d8:	74e2                	ld	s1,56(sp)
}
 4da:	60a6                	ld	ra,72(sp)
 4dc:	6406                	ld	s0,64(sp)
 4de:	7942                	ld	s2,48(sp)
 4e0:	79a2                	ld	s3,40(sp)
 4e2:	6161                	addi	sp,sp,80
 4e4:	8082                	ret
  neg = 0;
 4e6:	4301                	li	t1,0
 4e8:	bfbd                	j	466 <printint+0x1a>

00000000000004ea <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ea:	711d                	addi	sp,sp,-96
 4ec:	ec86                	sd	ra,88(sp)
 4ee:	e8a2                	sd	s0,80(sp)
 4f0:	e4a6                	sd	s1,72(sp)
 4f2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f4:	0005c483          	lbu	s1,0(a1)
 4f8:	22048363          	beqz	s1,71e <vprintf+0x234>
 4fc:	e0ca                	sd	s2,64(sp)
 4fe:	fc4e                	sd	s3,56(sp)
 500:	f852                	sd	s4,48(sp)
 502:	f456                	sd	s5,40(sp)
 504:	f05a                	sd	s6,32(sp)
 506:	ec5e                	sd	s7,24(sp)
 508:	e862                	sd	s8,16(sp)
 50a:	8b2a                	mv	s6,a0
 50c:	8a2e                	mv	s4,a1
 50e:	8bb2                	mv	s7,a2
  state = 0;
 510:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 512:	4901                	li	s2,0
 514:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 516:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 51a:	06400c13          	li	s8,100
 51e:	a00d                	j	540 <vprintf+0x56>
        putc(fd, c0);
 520:	85a6                	mv	a1,s1
 522:	855a                	mv	a0,s6
 524:	f0bff0ef          	jal	42e <putc>
 528:	a019                	j	52e <vprintf+0x44>
    } else if(state == '%'){
 52a:	03598363          	beq	s3,s5,550 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 52e:	0019079b          	addiw	a5,s2,1
 532:	893e                	mv	s2,a5
 534:	873e                	mv	a4,a5
 536:	97d2                	add	a5,a5,s4
 538:	0007c483          	lbu	s1,0(a5)
 53c:	1c048a63          	beqz	s1,710 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 540:	0004879b          	sext.w	a5,s1
    if(state == 0){
 544:	fe0993e3          	bnez	s3,52a <vprintf+0x40>
      if(c0 == '%'){
 548:	fd579ce3          	bne	a5,s5,520 <vprintf+0x36>
        state = '%';
 54c:	89be                	mv	s3,a5
 54e:	b7c5                	j	52e <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 550:	00ea06b3          	add	a3,s4,a4
 554:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 558:	1c060863          	beqz	a2,728 <vprintf+0x23e>
      if(c0 == 'd'){
 55c:	03878763          	beq	a5,s8,58a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 560:	f9478693          	addi	a3,a5,-108
 564:	0016b693          	seqz	a3,a3
 568:	f9c60593          	addi	a1,a2,-100
 56c:	e99d                	bnez	a1,5a2 <vprintf+0xb8>
 56e:	ca95                	beqz	a3,5a2 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	008b8493          	addi	s1,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000bb583          	ld	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	ecfff0ef          	jal	44c <printint>
        i += 1;
 582:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 586:	4981                	li	s3,0
 588:	b75d                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 58a:	008b8493          	addi	s1,s7,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000ba583          	lw	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	eb5ff0ef          	jal	44c <printint>
 59c:	8ba6                	mv	s7,s1
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	b779                	j	52e <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5a2:	9752                	add	a4,a4,s4
 5a4:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a8:	f9460713          	addi	a4,a2,-108
 5ac:	00173713          	seqz	a4,a4
 5b0:	8f75                	and	a4,a4,a3
 5b2:	f9c58513          	addi	a0,a1,-100
 5b6:	18051363          	bnez	a0,73c <vprintf+0x252>
 5ba:	18070163          	beqz	a4,73c <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5be:	008b8493          	addi	s1,s7,8
 5c2:	4685                	li	a3,1
 5c4:	4629                	li	a2,10
 5c6:	000bb583          	ld	a1,0(s7)
 5ca:	855a                	mv	a0,s6
 5cc:	e81ff0ef          	jal	44c <printint>
        i += 2;
 5d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d2:	8ba6                	mv	s7,s1
      state = 0;
 5d4:	4981                	li	s3,0
        i += 2;
 5d6:	bfa1                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5d8:	008b8493          	addi	s1,s7,8
 5dc:	4681                	li	a3,0
 5de:	4629                	li	a2,10
 5e0:	000be583          	lwu	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	e67ff0ef          	jal	44c <printint>
 5ea:	8ba6                	mv	s7,s1
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b781                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f0:	008b8493          	addi	s1,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000bb583          	ld	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	e4fff0ef          	jal	44c <printint>
        i += 1;
 602:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 604:	8ba6                	mv	s7,s1
      state = 0;
 606:	4981                	li	s3,0
 608:	b71d                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	008b8493          	addi	s1,s7,8
 60e:	4681                	li	a3,0
 610:	4629                	li	a2,10
 612:	000bb583          	ld	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	e35ff0ef          	jal	44c <printint>
        i += 2;
 61c:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 61e:	8ba6                	mv	s7,s1
      state = 0;
 620:	4981                	li	s3,0
        i += 2;
 622:	b731                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 624:	008b8493          	addi	s1,s7,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000be583          	lwu	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e1bff0ef          	jal	44c <printint>
 636:	8ba6                	mv	s7,s1
      state = 0;
 638:	4981                	li	s3,0
 63a:	bdd5                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63c:	008b8493          	addi	s1,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000bb583          	ld	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	e03ff0ef          	jal	44c <printint>
        i += 1;
 64e:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 650:	8ba6                	mv	s7,s1
      state = 0;
 652:	4981                	li	s3,0
 654:	bde9                	j	52e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	008b8493          	addi	s1,s7,8
 65a:	4681                	li	a3,0
 65c:	4641                	li	a2,16
 65e:	000bb583          	ld	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	de9ff0ef          	jal	44c <printint>
        i += 2;
 668:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	8ba6                	mv	s7,s1
      state = 0;
 66c:	4981                	li	s3,0
        i += 2;
 66e:	b5c1                	j	52e <vprintf+0x44>
 670:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 672:	008b8793          	addi	a5,s7,8
 676:	8cbe                	mv	s9,a5
 678:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 67c:	03000593          	li	a1,48
 680:	855a                	mv	a0,s6
 682:	dadff0ef          	jal	42e <putc>
  putc(fd, 'x');
 686:	07800593          	li	a1,120
 68a:	855a                	mv	a0,s6
 68c:	da3ff0ef          	jal	42e <putc>
 690:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 692:	00000b97          	auipc	s7,0x0
 696:	33eb8b93          	addi	s7,s7,830 # 9d0 <digits>
 69a:	03c9d793          	srli	a5,s3,0x3c
 69e:	97de                	add	a5,a5,s7
 6a0:	0007c583          	lbu	a1,0(a5)
 6a4:	855a                	mv	a0,s6
 6a6:	d89ff0ef          	jal	42e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6aa:	0992                	slli	s3,s3,0x4
 6ac:	34fd                	addiw	s1,s1,-1
 6ae:	f4f5                	bnez	s1,69a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6b0:	8be6                	mv	s7,s9
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	6ca2                	ld	s9,8(sp)
 6b6:	bda5                	j	52e <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6b8:	008b8493          	addi	s1,s7,8
 6bc:	000bc583          	lbu	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	d6dff0ef          	jal	42e <putc>
 6c6:	8ba6                	mv	s7,s1
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b595                	j	52e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 6cc:	008b8993          	addi	s3,s7,8
 6d0:	000bb483          	ld	s1,0(s7)
 6d4:	cc91                	beqz	s1,6f0 <vprintf+0x206>
        for(; *s; s++)
 6d6:	0004c583          	lbu	a1,0(s1)
 6da:	c985                	beqz	a1,70a <vprintf+0x220>
          putc(fd, *s);
 6dc:	855a                	mv	a0,s6
 6de:	d51ff0ef          	jal	42e <putc>
        for(; *s; s++)
 6e2:	0485                	addi	s1,s1,1
 6e4:	0004c583          	lbu	a1,0(s1)
 6e8:	f9f5                	bnez	a1,6dc <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 6ea:	8bce                	mv	s7,s3
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b581                	j	52e <vprintf+0x44>
          s = "(null)";
 6f0:	00000497          	auipc	s1,0x0
 6f4:	2d848493          	addi	s1,s1,728 # 9c8 <malloc+0x13c>
        for(; *s; s++)
 6f8:	02800593          	li	a1,40
 6fc:	b7c5                	j	6dc <vprintf+0x1f2>
        putc(fd, '%');
 6fe:	85be                	mv	a1,a5
 700:	855a                	mv	a0,s6
 702:	d2dff0ef          	jal	42e <putc>
      state = 0;
 706:	4981                	li	s3,0
 708:	b51d                	j	52e <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b505                	j	52e <vprintf+0x44>
 710:	6906                	ld	s2,64(sp)
 712:	79e2                	ld	s3,56(sp)
 714:	7a42                	ld	s4,48(sp)
 716:	7aa2                	ld	s5,40(sp)
 718:	7b02                	ld	s6,32(sp)
 71a:	6be2                	ld	s7,24(sp)
 71c:	6c42                	ld	s8,16(sp)
    }
  }
}
 71e:	60e6                	ld	ra,88(sp)
 720:	6446                	ld	s0,80(sp)
 722:	64a6                	ld	s1,72(sp)
 724:	6125                	addi	sp,sp,96
 726:	8082                	ret
      if(c0 == 'd'){
 728:	06400713          	li	a4,100
 72c:	e4e78fe3          	beq	a5,a4,58a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 730:	f9478693          	addi	a3,a5,-108
 734:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 738:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 73a:	4701                	li	a4,0
      } else if(c0 == 'u'){
 73c:	07500513          	li	a0,117
 740:	e8a78ce3          	beq	a5,a0,5d8 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 744:	f8b60513          	addi	a0,a2,-117
 748:	e119                	bnez	a0,74e <vprintf+0x264>
 74a:	ea0693e3          	bnez	a3,5f0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 74e:	f8b58513          	addi	a0,a1,-117
 752:	e119                	bnez	a0,758 <vprintf+0x26e>
 754:	ea071be3          	bnez	a4,60a <vprintf+0x120>
      } else if(c0 == 'x'){
 758:	07800513          	li	a0,120
 75c:	eca784e3          	beq	a5,a0,624 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 760:	f8860613          	addi	a2,a2,-120
 764:	e219                	bnez	a2,76a <vprintf+0x280>
 766:	ec069be3          	bnez	a3,63c <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 76a:	f8858593          	addi	a1,a1,-120
 76e:	e199                	bnez	a1,774 <vprintf+0x28a>
 770:	ee0713e3          	bnez	a4,656 <vprintf+0x16c>
      } else if(c0 == 'p'){
 774:	07000713          	li	a4,112
 778:	eee78ce3          	beq	a5,a4,670 <vprintf+0x186>
      } else if(c0 == 'c'){
 77c:	06300713          	li	a4,99
 780:	f2e78ce3          	beq	a5,a4,6b8 <vprintf+0x1ce>
      } else if(c0 == 's'){
 784:	07300713          	li	a4,115
 788:	f4e782e3          	beq	a5,a4,6cc <vprintf+0x1e2>
      } else if(c0 == '%'){
 78c:	02500713          	li	a4,37
 790:	f6e787e3          	beq	a5,a4,6fe <vprintf+0x214>
        putc(fd, '%');
 794:	02500593          	li	a1,37
 798:	855a                	mv	a0,s6
 79a:	c95ff0ef          	jal	42e <putc>
        putc(fd, c0);
 79e:	85a6                	mv	a1,s1
 7a0:	855a                	mv	a0,s6
 7a2:	c8dff0ef          	jal	42e <putc>
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	b359                	j	52e <vprintf+0x44>

00000000000007aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7aa:	715d                	addi	sp,sp,-80
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	e010                	sd	a2,0(s0)
 7b4:	e414                	sd	a3,8(s0)
 7b6:	e818                	sd	a4,16(s0)
 7b8:	ec1c                	sd	a5,24(s0)
 7ba:	03043023          	sd	a6,32(s0)
 7be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c2:	8622                	mv	a2,s0
 7c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c8:	d23ff0ef          	jal	4ea <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6161                	addi	sp,sp,80
 7d2:	8082                	ret

00000000000007d4 <printf>:

void
printf(const char *fmt, ...)
{
 7d4:	711d                	addi	sp,sp,-96
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e40c                	sd	a1,8(s0)
 7de:	e810                	sd	a2,16(s0)
 7e0:	ec14                	sd	a3,24(s0)
 7e2:	f018                	sd	a4,32(s0)
 7e4:	f41c                	sd	a5,40(s0)
 7e6:	03043823          	sd	a6,48(s0)
 7ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ee:	00840613          	addi	a2,s0,8
 7f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f6:	85aa                	mv	a1,a0
 7f8:	4505                	li	a0,1
 7fa:	cf1ff0ef          	jal	4ea <vprintf>
}
 7fe:	60e2                	ld	ra,24(sp)
 800:	6442                	ld	s0,16(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 806:	1141                	addi	sp,sp,-16
 808:	e406                	sd	ra,8(sp)
 80a:	e022                	sd	s0,0(sp)
 80c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 80e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 812:	00000797          	auipc	a5,0x0
 816:	7ee7b783          	ld	a5,2030(a5) # 1000 <freep>
 81a:	a039                	j	828 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 81c:	6398                	ld	a4,0(a5)
 81e:	00e7e463          	bltu	a5,a4,826 <free+0x20>
 822:	00e6ea63          	bltu	a3,a4,836 <free+0x30>
{
 826:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	fed7fae3          	bgeu	a5,a3,81c <free+0x16>
 82c:	6398                	ld	a4,0(a5)
 82e:	00e6e463          	bltu	a3,a4,836 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	fee7eae3          	bltu	a5,a4,826 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 836:	ff852583          	lw	a1,-8(a0)
 83a:	6390                	ld	a2,0(a5)
 83c:	02059813          	slli	a6,a1,0x20
 840:	01c85713          	srli	a4,a6,0x1c
 844:	9736                	add	a4,a4,a3
 846:	02e60563          	beq	a2,a4,870 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 84e:	4790                	lw	a2,8(a5)
 850:	02061593          	slli	a1,a2,0x20
 854:	01c5d713          	srli	a4,a1,0x1c
 858:	973e                	add	a4,a4,a5
 85a:	02e68263          	beq	a3,a4,87e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 85e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 860:	00000717          	auipc	a4,0x0
 864:	7af73023          	sd	a5,1952(a4) # 1000 <freep>
}
 868:	60a2                	ld	ra,8(sp)
 86a:	6402                	ld	s0,0(sp)
 86c:	0141                	addi	sp,sp,16
 86e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 870:	4618                	lw	a4,8(a2)
 872:	9f2d                	addw	a4,a4,a1
 874:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	6310                	ld	a2,0(a4)
 87c:	b7f9                	j	84a <free+0x44>
    p->s.size += bp->s.size;
 87e:	ff852703          	lw	a4,-8(a0)
 882:	9f31                	addw	a4,a4,a2
 884:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 886:	ff053683          	ld	a3,-16(a0)
 88a:	bfd1                	j	85e <free+0x58>

000000000000088c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88c:	7139                	addi	sp,sp,-64
 88e:	fc06                	sd	ra,56(sp)
 890:	f822                	sd	s0,48(sp)
 892:	f04a                	sd	s2,32(sp)
 894:	ec4e                	sd	s3,24(sp)
 896:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 898:	02051993          	slli	s3,a0,0x20
 89c:	0209d993          	srli	s3,s3,0x20
 8a0:	09bd                	addi	s3,s3,15
 8a2:	0049d993          	srli	s3,s3,0x4
 8a6:	2985                	addiw	s3,s3,1
 8a8:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 8aa:	00000517          	auipc	a0,0x0
 8ae:	75653503          	ld	a0,1878(a0) # 1000 <freep>
 8b2:	c905                	beqz	a0,8e2 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b6:	4798                	lw	a4,8(a5)
 8b8:	09377663          	bgeu	a4,s3,944 <malloc+0xb8>
 8bc:	f426                	sd	s1,40(sp)
 8be:	e852                	sd	s4,16(sp)
 8c0:	e456                	sd	s5,8(sp)
 8c2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c4:	8a4e                	mv	s4,s3
 8c6:	6705                	lui	a4,0x1
 8c8:	00e9f363          	bgeu	s3,a4,8ce <malloc+0x42>
 8cc:	6a05                	lui	s4,0x1
 8ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d6:	00000497          	auipc	s1,0x0
 8da:	72a48493          	addi	s1,s1,1834 # 1000 <freep>
  if(p == SBRK_ERROR)
 8de:	5afd                	li	s5,-1
 8e0:	a83d                	j	91e <malloc+0x92>
 8e2:	f426                	sd	s1,40(sp)
 8e4:	e852                	sd	s4,16(sp)
 8e6:	e456                	sd	s5,8(sp)
 8e8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8ea:	00000797          	auipc	a5,0x0
 8ee:	72678793          	addi	a5,a5,1830 # 1010 <base>
 8f2:	00000717          	auipc	a4,0x0
 8f6:	70f73723          	sd	a5,1806(a4) # 1000 <freep>
 8fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8fc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 900:	b7d1                	j	8c4 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 902:	6398                	ld	a4,0(a5)
 904:	e118                	sd	a4,0(a0)
 906:	a899                	j	95c <malloc+0xd0>
  hp->s.size = nu;
 908:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 90c:	0541                	addi	a0,a0,16
 90e:	ef9ff0ef          	jal	806 <free>
  return freep;
 912:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 914:	c125                	beqz	a0,974 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 916:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 918:	4798                	lw	a4,8(a5)
 91a:	03277163          	bgeu	a4,s2,93c <malloc+0xb0>
    if(p == freep)
 91e:	6098                	ld	a4,0(s1)
 920:	853e                	mv	a0,a5
 922:	fef71ae3          	bne	a4,a5,916 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 926:	8552                	mv	a0,s4
 928:	a2bff0ef          	jal	352 <sbrk>
  if(p == SBRK_ERROR)
 92c:	fd551ee3          	bne	a0,s5,908 <malloc+0x7c>
        return 0;
 930:	4501                	li	a0,0
 932:	74a2                	ld	s1,40(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	a03d                	j	968 <malloc+0xdc>
 93c:	74a2                	ld	s1,40(sp)
 93e:	6a42                	ld	s4,16(sp)
 940:	6aa2                	ld	s5,8(sp)
 942:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 944:	fae90fe3          	beq	s2,a4,902 <malloc+0x76>
        p->s.size -= nunits;
 948:	4137073b          	subw	a4,a4,s3
 94c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94e:	02071693          	slli	a3,a4,0x20
 952:	01c6d713          	srli	a4,a3,0x1c
 956:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 958:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95c:	00000717          	auipc	a4,0x0
 960:	6aa73223          	sd	a0,1700(a4) # 1000 <freep>
      return (void*)(p + 1);
 964:	01078513          	addi	a0,a5,16
  }
}
 968:	70e2                	ld	ra,56(sp)
 96a:	7442                	ld	s0,48(sp)
 96c:	7902                	ld	s2,32(sp)
 96e:	69e2                	ld	s3,24(sp)
 970:	6121                	addi	sp,sp,64
 972:	8082                	ret
 974:	74a2                	ld	s1,40(sp)
 976:	6a42                	ld	s4,16(sp)
 978:	6aa2                	ld	s5,8(sp)
 97a:	6b02                	ld	s6,0(sp)
 97c:	b7f5                	j	968 <malloc+0xdc>
