
user/_bad_pipe:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <pipe_write>:
    uint nwrite;    // number of bytes written
};

void 
pipe_write(struct bad_pipe *pi, char ch)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    // if(pi->nwrite - pi->nread == PIPESIZE) {
    //     // Pipe is full, cannot write
    //     return;
    // }

    pi->data[pi->nwrite % PIPESIZE] = ch;
   8:	515c                	lw	a5,36(a0)
   a:	01f7f713          	andi	a4,a5,31
   e:	972a                	add	a4,a4,a0
  10:	00b70023          	sb	a1,0(a4)
    pi->nwrite++;
  14:	2785                	addiw	a5,a5,1
  16:	d15c                	sw	a5,36(a0)
}
  18:	60a2                	ld	ra,8(sp)
  1a:	6402                	ld	s0,0(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <pipe_read>:

int 
pipe_read(struct bad_pipe *pi)
{
  20:	1141                	addi	sp,sp,-16
  22:	e406                	sd	ra,8(sp)
  24:	e022                	sd	s0,0(sp)
  26:	0800                	addi	s0,sp,16
    if(pi->nread == pi->nwrite) {
  28:	511c                	lw	a5,32(a0)
  2a:	5158                	lw	a4,36(a0)
  2c:	00f70f63          	beq	a4,a5,4a <pipe_read+0x2a>
        // Pipe is empty, cannot read
        return -1;
    }

    char ch = pi->data[pi->nread % PIPESIZE];
  30:	01f7f713          	andi	a4,a5,31
  34:	972a                	add	a4,a4,a0
  36:	00074703          	lbu	a4,0(a4)
    pi->nread++;
  3a:	2785                	addiw	a5,a5,1
  3c:	d11c                	sw	a5,32(a0)
    return ch;
  3e:	0007051b          	sext.w	a0,a4
}
  42:	60a2                	ld	ra,8(sp)
  44:	6402                	ld	s0,0(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret
        return -1;
  4a:	557d                	li	a0,-1
  4c:	bfdd                	j	42 <pipe_read+0x22>

000000000000004e <main>:

int
main(void)
{
  4e:	7159                	addi	sp,sp,-112
  50:	f486                	sd	ra,104(sp)
  52:	f0a2                	sd	s0,96(sp)
  54:	eca6                	sd	s1,88(sp)
  56:	e8ca                	sd	s2,80(sp)
  58:	e4ce                	sd	s3,72(sp)
  5a:	e0d2                	sd	s4,64(sp)
  5c:	fc56                	sd	s5,56(sp)
  5e:	1880                	addi	s0,sp,112
    struct bad_pipe pipe;

    char last3[3] = {0,0,0};
    char ch;

    printf("Type text. Enter 'ok?' to stop and display buffer contents.\n\n");
  60:	00001517          	auipc	a0,0x1
  64:	99050513          	addi	a0,a0,-1648 # 9f0 <malloc+0xfc>
  68:	7d4000ef          	jal	83c <printf>

    pipe.nread = 0;
  6c:	fa042c23          	sw	zero,-72(s0)
    pipe.nwrite = 0;

    while(read(0, &ch, 1) == 1){
  70:	4481                	li	s1,0
    char last3[3] = {0,0,0};
  72:	4901                	li	s2,0
  74:	4a81                	li	s5,0
    while(read(0, &ch, 1) == 1){
  76:	f9740a13          	addi	s4,s0,-105
  7a:	4985                	li	s3,1
  7c:	a819                	j	92 <main+0x44>
    pi->data[pi->nwrite % PIPESIZE] = ch;
  7e:	01f4f793          	andi	a5,s1,31
  82:	fc078793          	addi	a5,a5,-64
  86:	97a2                	add	a5,a5,s0
  88:	fcd78c23          	sb	a3,-40(a5)
    pi->nwrite++;
  8c:	2485                	addiw	s1,s1,1
        // Check for "ok?" pattern before writing
        last3[0] = last3[1];
        last3[1] = last3[2];
  8e:	8aca                	mv	s5,s2
        last3[2] = ch;        
  90:	8936                	mv	s2,a3
    pipe.nwrite = 0;
  92:	fa942e23          	sw	s1,-68(s0)
    while(read(0, &ch, 1) == 1){
  96:	864e                	mv	a2,s3
  98:	85d2                	mv	a1,s4
  9a:	4501                	li	a0,0
  9c:	36a000ef          	jal	406 <read>
  a0:	03351663          	bne	a0,s3,cc <main+0x7e>
        last3[2] = ch;        
  a4:	f9744683          	lbu	a3,-105(s0)

        if(last3[0] == 'o' && last3[1] == 'k' && last3[2] == '?') {
  a8:	f9590793          	addi	a5,s2,-107
  ac:	0017b793          	seqz	a5,a5
  b0:	fc168713          	addi	a4,a3,-63
  b4:	00173713          	seqz	a4,a4
  b8:	8ff9                	and	a5,a5,a4
  ba:	d3f1                	beqz	a5,7e <main+0x30>
  bc:	2a81                	sext.w	s5,s5
  be:	f91a8a93          	addi	s5,s5,-111
  c2:	fa0a9ee3          	bnez	s5,7e <main+0x30>
            // Remove the 'o' and 'k' that were already written
            pipe.nwrite -= 2;
  c6:	34f9                	addiw	s1,s1,-2
  c8:	fa942e23          	sw	s1,-68(s0)
        }else{
            pipe_write(&pipe, ch);
        }
    }

    if(pipe.nwrite - pipe.nread == PIPESIZE) {
  cc:	fbc42703          	lw	a4,-68(s0)
  d0:	02000793          	li	a5,32
  d4:	02f70063          	beq	a4,a5,f4 <main+0xa6>
        printf("\nPipe overflow occurred!\n");
        pipe.nread = pipe.nwrite - PIPESIZE; // Adjust read pointer to avoid overflow
    }

    printf("\nBuffer contents:\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	98050513          	addi	a0,a0,-1664 # a58 <malloc+0x164>
  e0:	75c000ef          	jal	83c <printf>
    int out_ch;
    while((out_ch = pipe_read(&pipe)) != -1) {
  e4:	f9840913          	addi	s2,s0,-104
  e8:	54fd                	li	s1,-1
        printf("%c", out_ch);
  ea:	00001997          	auipc	s3,0x1
  ee:	98698993          	addi	s3,s3,-1658 # a70 <malloc+0x17c>
    while((out_ch = pipe_read(&pipe)) != -1) {
  f2:	a829                	j	10c <main+0xbe>
        printf("\nPipe overflow occurred!\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	94450513          	addi	a0,a0,-1724 # a38 <malloc+0x144>
  fc:	740000ef          	jal	83c <printf>
        pipe.nread = pipe.nwrite - PIPESIZE; // Adjust read pointer to avoid overflow
 100:	fa042c23          	sw	zero,-72(s0)
 104:	bfd1                	j	d8 <main+0x8a>
        printf("%c", out_ch);
 106:	854e                	mv	a0,s3
 108:	734000ef          	jal	83c <printf>
    while((out_ch = pipe_read(&pipe)) != -1) {
 10c:	854a                	mv	a0,s2
 10e:	f13ff0ef          	jal	20 <pipe_read>
 112:	85aa                	mv	a1,a0
 114:	fe9519e3          	bne	a0,s1,106 <main+0xb8>
    }
    printf("\n");
 118:	00001517          	auipc	a0,0x1
 11c:	96050513          	addi	a0,a0,-1696 # a78 <malloc+0x184>
 120:	71c000ef          	jal	83c <printf>
}
 124:	4501                	li	a0,0
 126:	70a6                	ld	ra,104(sp)
 128:	7406                	ld	s0,96(sp)
 12a:	64e6                	ld	s1,88(sp)
 12c:	6946                	ld	s2,80(sp)
 12e:	69a6                	ld	s3,72(sp)
 130:	6a06                	ld	s4,64(sp)
 132:	7ae2                	ld	s5,56(sp)
 134:	6165                	addi	sp,sp,112
 136:	8082                	ret

0000000000000138 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 140:	f0fff0ef          	jal	4e <main>
  exit(r);
 144:	2aa000ef          	jal	3ee <exit>

0000000000000148 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e406                	sd	ra,8(sp)
 14c:	e022                	sd	s0,0(sp)
 14e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 150:	87aa                	mv	a5,a0
 152:	0585                	addi	a1,a1,1
 154:	0785                	addi	a5,a5,1
 156:	fff5c703          	lbu	a4,-1(a1)
 15a:	fee78fa3          	sb	a4,-1(a5)
 15e:	fb75                	bnez	a4,152 <strcpy+0xa>
    ;
  return os;
}
 160:	60a2                	ld	ra,8(sp)
 162:	6402                	ld	s0,0(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e406                	sd	ra,8(sp)
 16c:	e022                	sd	s0,0(sp)
 16e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 170:	00054783          	lbu	a5,0(a0)
 174:	cb91                	beqz	a5,188 <strcmp+0x20>
 176:	0005c703          	lbu	a4,0(a1)
 17a:	00f71763          	bne	a4,a5,188 <strcmp+0x20>
    p++, q++;
 17e:	0505                	addi	a0,a0,1
 180:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	fbe5                	bnez	a5,176 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 188:	0005c503          	lbu	a0,0(a1)
}
 18c:	40a7853b          	subw	a0,a5,a0
 190:	60a2                	ld	ra,8(sp)
 192:	6402                	ld	s0,0(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e406                	sd	ra,8(sp)
 19c:	e022                	sd	s0,0(sp)
 19e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cf91                	beqz	a5,1c0 <strlen+0x28>
 1a6:	00150793          	addi	a5,a0,1
 1aa:	86be                	mv	a3,a5
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff7c703          	lbu	a4,-1(a5)
 1b2:	ff65                	bnez	a4,1aa <strlen+0x12>
 1b4:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  for(n = 0; s[n]; n++)
 1c0:	4501                	li	a0,0
 1c2:	bfdd                	j	1b8 <strlen+0x20>

00000000000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e406                	sd	ra,8(sp)
 1c8:	e022                	sd	s0,0(sp)
 1ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1cc:	ca19                	beqz	a2,1e2 <memset+0x1e>
 1ce:	87aa                	mv	a5,a0
 1d0:	1602                	slli	a2,a2,0x20
 1d2:	9201                	srli	a2,a2,0x20
 1d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1dc:	0785                	addi	a5,a5,1
 1de:	fee79de3          	bne	a5,a4,1d8 <memset+0x14>
  }
  return dst;
}
 1e2:	60a2                	ld	ra,8(sp)
 1e4:	6402                	ld	s0,0(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strchr>:

char*
strchr(const char *s, char c)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e406                	sd	ra,8(sp)
 1ee:	e022                	sd	s0,0(sp)
 1f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf81                	beqz	a5,20e <strchr+0x24>
    if(*s == c)
 1f8:	00f58763          	beq	a1,a5,206 <strchr+0x1c>
  for(; *s; s++)
 1fc:	0505                	addi	a0,a0,1
 1fe:	00054783          	lbu	a5,0(a0)
 202:	fbfd                	bnez	a5,1f8 <strchr+0xe>
      return (char*)s;
  return 0;
 204:	4501                	li	a0,0
}
 206:	60a2                	ld	ra,8(sp)
 208:	6402                	ld	s0,0(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  return 0;
 20e:	4501                	li	a0,0
 210:	bfdd                	j	206 <strchr+0x1c>

0000000000000212 <gets>:

char*
gets(char *buf, int max)
{
 212:	711d                	addi	sp,sp,-96
 214:	ec86                	sd	ra,88(sp)
 216:	e8a2                	sd	s0,80(sp)
 218:	e4a6                	sd	s1,72(sp)
 21a:	e0ca                	sd	s2,64(sp)
 21c:	fc4e                	sd	s3,56(sp)
 21e:	f852                	sd	s4,48(sp)
 220:	f456                	sd	s5,40(sp)
 222:	f05a                	sd	s6,32(sp)
 224:	ec5e                	sd	s7,24(sp)
 226:	e862                	sd	s8,16(sp)
 228:	1080                	addi	s0,sp,96
 22a:	8baa                	mv	s7,a0
 22c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22e:	892a                	mv	s2,a0
 230:	4481                	li	s1,0
    cc = read(0, &c, 1);
 232:	faf40b13          	addi	s6,s0,-81
 236:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 238:	8c26                	mv	s8,s1
 23a:	0014899b          	addiw	s3,s1,1
 23e:	84ce                	mv	s1,s3
 240:	0349d463          	bge	s3,s4,268 <gets+0x56>
    cc = read(0, &c, 1);
 244:	8656                	mv	a2,s5
 246:	85da                	mv	a1,s6
 248:	4501                	li	a0,0
 24a:	1bc000ef          	jal	406 <read>
    if(cc < 1)
 24e:	00a05d63          	blez	a0,268 <gets+0x56>
      break;
    buf[i++] = c;
 252:	faf44783          	lbu	a5,-81(s0)
 256:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 25a:	0905                	addi	s2,s2,1
 25c:	ff678713          	addi	a4,a5,-10
 260:	c319                	beqz	a4,266 <gets+0x54>
 262:	17cd                	addi	a5,a5,-13
 264:	fbf1                	bnez	a5,238 <gets+0x26>
    buf[i++] = c;
 266:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 268:	9c5e                	add	s8,s8,s7
 26a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 26e:	855e                	mv	a0,s7
 270:	60e6                	ld	ra,88(sp)
 272:	6446                	ld	s0,80(sp)
 274:	64a6                	ld	s1,72(sp)
 276:	6906                	ld	s2,64(sp)
 278:	79e2                	ld	s3,56(sp)
 27a:	7a42                	ld	s4,48(sp)
 27c:	7aa2                	ld	s5,40(sp)
 27e:	7b02                	ld	s6,32(sp)
 280:	6be2                	ld	s7,24(sp)
 282:	6c42                	ld	s8,16(sp)
 284:	6125                	addi	sp,sp,96
 286:	8082                	ret

0000000000000288 <stat>:

int
stat(const char *n, struct stat *st)
{
 288:	1101                	addi	sp,sp,-32
 28a:	ec06                	sd	ra,24(sp)
 28c:	e822                	sd	s0,16(sp)
 28e:	e04a                	sd	s2,0(sp)
 290:	1000                	addi	s0,sp,32
 292:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 294:	4581                	li	a1,0
 296:	198000ef          	jal	42e <open>
  if(fd < 0)
 29a:	02054263          	bltz	a0,2be <stat+0x36>
 29e:	e426                	sd	s1,8(sp)
 2a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a2:	85ca                	mv	a1,s2
 2a4:	1a2000ef          	jal	446 <fstat>
 2a8:	892a                	mv	s2,a0
  close(fd);
 2aa:	8526                	mv	a0,s1
 2ac:	16a000ef          	jal	416 <close>
  return r;
 2b0:	64a2                	ld	s1,8(sp)
}
 2b2:	854a                	mv	a0,s2
 2b4:	60e2                	ld	ra,24(sp)
 2b6:	6442                	ld	s0,16(sp)
 2b8:	6902                	ld	s2,0(sp)
 2ba:	6105                	addi	sp,sp,32
 2bc:	8082                	ret
    return -1;
 2be:	57fd                	li	a5,-1
 2c0:	893e                	mv	s2,a5
 2c2:	bfc5                	j	2b2 <stat+0x2a>

00000000000002c4 <atoi>:

int
atoi(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e406                	sd	ra,8(sp)
 2c8:	e022                	sd	s0,0(sp)
 2ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2cc:	00054683          	lbu	a3,0(a0)
 2d0:	fd06879b          	addiw	a5,a3,-48
 2d4:	0ff7f793          	zext.b	a5,a5
 2d8:	4625                	li	a2,9
 2da:	02f66963          	bltu	a2,a5,30c <atoi+0x48>
 2de:	872a                	mv	a4,a0
  n = 0;
 2e0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2e2:	0705                	addi	a4,a4,1
 2e4:	0025179b          	slliw	a5,a0,0x2
 2e8:	9fa9                	addw	a5,a5,a0
 2ea:	0017979b          	slliw	a5,a5,0x1
 2ee:	9fb5                	addw	a5,a5,a3
 2f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f4:	00074683          	lbu	a3,0(a4)
 2f8:	fd06879b          	addiw	a5,a3,-48
 2fc:	0ff7f793          	zext.b	a5,a5
 300:	fef671e3          	bgeu	a2,a5,2e2 <atoi+0x1e>
  return n;
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  n = 0;
 30c:	4501                	li	a0,0
 30e:	bfdd                	j	304 <atoi+0x40>

0000000000000310 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e406                	sd	ra,8(sp)
 314:	e022                	sd	s0,0(sp)
 316:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 318:	02b57563          	bgeu	a0,a1,342 <memmove+0x32>
    while(n-- > 0)
 31c:	00c05f63          	blez	a2,33a <memmove+0x2a>
 320:	1602                	slli	a2,a2,0x20
 322:	9201                	srli	a2,a2,0x20
 324:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 328:	872a                	mv	a4,a0
      *dst++ = *src++;
 32a:	0585                	addi	a1,a1,1
 32c:	0705                	addi	a4,a4,1
 32e:	fff5c683          	lbu	a3,-1(a1)
 332:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 336:	fee79ae3          	bne	a5,a4,32a <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
    while(n-- > 0)
 342:	fec05ce3          	blez	a2,33a <memmove+0x2a>
    dst += n;
 346:	00c50733          	add	a4,a0,a2
    src += n;
 34a:	95b2                	add	a1,a1,a2
 34c:	fff6079b          	addiw	a5,a2,-1
 350:	1782                	slli	a5,a5,0x20
 352:	9381                	srli	a5,a5,0x20
 354:	fff7c793          	not	a5,a5
 358:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35a:	15fd                	addi	a1,a1,-1
 35c:	177d                	addi	a4,a4,-1
 35e:	0005c683          	lbu	a3,0(a1)
 362:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 366:	fef71ae3          	bne	a4,a5,35a <memmove+0x4a>
 36a:	bfc1                	j	33a <memmove+0x2a>

000000000000036c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e406                	sd	ra,8(sp)
 370:	e022                	sd	s0,0(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	c61d                	beqz	a2,3a2 <memcmp+0x36>
 376:	1602                	slli	a2,a2,0x20
 378:	9201                	srli	a2,a2,0x20
 37a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 37e:	00054783          	lbu	a5,0(a0)
 382:	0005c703          	lbu	a4,0(a1)
 386:	00e79863          	bne	a5,a4,396 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 38a:	0505                	addi	a0,a0,1
    p2++;
 38c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38e:	fed518e3          	bne	a0,a3,37e <memcmp+0x12>
  }
  return 0;
 392:	4501                	li	a0,0
 394:	a019                	j	39a <memcmp+0x2e>
      return *p1 - *p2;
 396:	40e7853b          	subw	a0,a5,a4
}
 39a:	60a2                	ld	ra,8(sp)
 39c:	6402                	ld	s0,0(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
  return 0;
 3a2:	4501                	li	a0,0
 3a4:	bfdd                	j	39a <memcmp+0x2e>

00000000000003a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e406                	sd	ra,8(sp)
 3aa:	e022                	sd	s0,0(sp)
 3ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ae:	f63ff0ef          	jal	310 <memmove>
}
 3b2:	60a2                	ld	ra,8(sp)
 3b4:	6402                	ld	s0,0(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret

00000000000003ba <sbrk>:

char *
sbrk(int n) {
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3c2:	4585                	li	a1,1
 3c4:	0b2000ef          	jal	476 <sys_sbrk>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	addi	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <sbrklazy>:

char *
sbrklazy(int n) {
 3d0:	1141                	addi	sp,sp,-16
 3d2:	e406                	sd	ra,8(sp)
 3d4:	e022                	sd	s0,0(sp)
 3d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3d8:	4589                	li	a1,2
 3da:	09c000ef          	jal	476 <sys_sbrk>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e6:	4885                	li	a7,1
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ee:	4889                	li	a7,2
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f6:	488d                	li	a7,3
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fe:	4891                	li	a7,4
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <read>:
.global read
read:
 li a7, SYS_read
 406:	4895                	li	a7,5
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <write>:
.global write
write:
 li a7, SYS_write
 40e:	48c1                	li	a7,16
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <close>:
.global close
close:
 li a7, SYS_close
 416:	48d5                	li	a7,21
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <kill>:
.global kill
kill:
 li a7, SYS_kill
 41e:	4899                	li	a7,6
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exec>:
.global exec
exec:
 li a7, SYS_exec
 426:	489d                	li	a7,7
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <open>:
.global open
open:
 li a7, SYS_open
 42e:	48bd                	li	a7,15
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 436:	48c5                	li	a7,17
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43e:	48c9                	li	a7,18
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 446:	48a1                	li	a7,8
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <link>:
.global link
link:
 li a7, SYS_link
 44e:	48cd                	li	a7,19
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 456:	48d1                	li	a7,20
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45e:	48a5                	li	a7,9
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <dup>:
.global dup
dup:
 li a7, SYS_dup
 466:	48a9                	li	a7,10
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46e:	48ad                	li	a7,11
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 476:	48b1                	li	a7,12
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <pause>:
.global pause
pause:
 li a7, SYS_pause
 47e:	48b5                	li	a7,13
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 486:	48b9                	li	a7,14
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <kps>:
.global kps
kps:
 li a7, SYS_kps
 48e:	48d9                	li	a7,22
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 496:	1101                	addi	sp,sp,-32
 498:	ec06                	sd	ra,24(sp)
 49a:	e822                	sd	s0,16(sp)
 49c:	1000                	addi	s0,sp,32
 49e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a2:	4605                	li	a2,1
 4a4:	fef40593          	addi	a1,s0,-17
 4a8:	f67ff0ef          	jal	40e <write>
}
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6105                	addi	sp,sp,32
 4b2:	8082                	ret

00000000000004b4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4b4:	715d                	addi	sp,sp,-80
 4b6:	e486                	sd	ra,72(sp)
 4b8:	e0a2                	sd	s0,64(sp)
 4ba:	f84a                	sd	s2,48(sp)
 4bc:	f44e                	sd	s3,40(sp)
 4be:	0880                	addi	s0,sp,80
 4c0:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4c2:	c6d1                	beqz	a3,54e <printint+0x9a>
 4c4:	0805d563          	bgez	a1,54e <printint+0x9a>
    neg = 1;
    x = -xx;
 4c8:	40b005b3          	neg	a1,a1
    neg = 1;
 4cc:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4ce:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4d2:	86ce                	mv	a3,s3
  i = 0;
 4d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d6:	00000817          	auipc	a6,0x0
 4da:	5b280813          	addi	a6,a6,1458 # a88 <digits>
 4de:	88ba                	mv	a7,a4
 4e0:	0017051b          	addiw	a0,a4,1
 4e4:	872a                	mv	a4,a0
 4e6:	02c5f7b3          	remu	a5,a1,a2
 4ea:	97c2                	add	a5,a5,a6
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f4:	87ae                	mv	a5,a1
 4f6:	02c5d5b3          	divu	a1,a1,a2
 4fa:	0685                	addi	a3,a3,1
 4fc:	fec7f1e3          	bgeu	a5,a2,4de <printint+0x2a>
  if(neg)
 500:	00030c63          	beqz	t1,518 <printint+0x64>
    buf[i++] = '-';
 504:	fd050793          	addi	a5,a0,-48
 508:	00878533          	add	a0,a5,s0
 50c:	02d00793          	li	a5,45
 510:	fef50423          	sb	a5,-24(a0)
 514:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 518:	02e05563          	blez	a4,542 <printint+0x8e>
 51c:	fc26                	sd	s1,56(sp)
 51e:	377d                	addiw	a4,a4,-1
 520:	00e984b3          	add	s1,s3,a4
 524:	19fd                	addi	s3,s3,-1
 526:	99ba                	add	s3,s3,a4
 528:	1702                	slli	a4,a4,0x20
 52a:	9301                	srli	a4,a4,0x20
 52c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 530:	0004c583          	lbu	a1,0(s1)
 534:	854a                	mv	a0,s2
 536:	f61ff0ef          	jal	496 <putc>
  while(--i >= 0)
 53a:	14fd                	addi	s1,s1,-1
 53c:	ff349ae3          	bne	s1,s3,530 <printint+0x7c>
 540:	74e2                	ld	s1,56(sp)
}
 542:	60a6                	ld	ra,72(sp)
 544:	6406                	ld	s0,64(sp)
 546:	7942                	ld	s2,48(sp)
 548:	79a2                	ld	s3,40(sp)
 54a:	6161                	addi	sp,sp,80
 54c:	8082                	ret
  neg = 0;
 54e:	4301                	li	t1,0
 550:	bfbd                	j	4ce <printint+0x1a>

0000000000000552 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 552:	711d                	addi	sp,sp,-96
 554:	ec86                	sd	ra,88(sp)
 556:	e8a2                	sd	s0,80(sp)
 558:	e4a6                	sd	s1,72(sp)
 55a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55c:	0005c483          	lbu	s1,0(a1)
 560:	22048363          	beqz	s1,786 <vprintf+0x234>
 564:	e0ca                	sd	s2,64(sp)
 566:	fc4e                	sd	s3,56(sp)
 568:	f852                	sd	s4,48(sp)
 56a:	f456                	sd	s5,40(sp)
 56c:	f05a                	sd	s6,32(sp)
 56e:	ec5e                	sd	s7,24(sp)
 570:	e862                	sd	s8,16(sp)
 572:	8b2a                	mv	s6,a0
 574:	8a2e                	mv	s4,a1
 576:	8bb2                	mv	s7,a2
  state = 0;
 578:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 57a:	4901                	li	s2,0
 57c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 57e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 582:	06400c13          	li	s8,100
 586:	a00d                	j	5a8 <vprintf+0x56>
        putc(fd, c0);
 588:	85a6                	mv	a1,s1
 58a:	855a                	mv	a0,s6
 58c:	f0bff0ef          	jal	496 <putc>
 590:	a019                	j	596 <vprintf+0x44>
    } else if(state == '%'){
 592:	03598363          	beq	s3,s5,5b8 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 596:	0019079b          	addiw	a5,s2,1
 59a:	893e                	mv	s2,a5
 59c:	873e                	mv	a4,a5
 59e:	97d2                	add	a5,a5,s4
 5a0:	0007c483          	lbu	s1,0(a5)
 5a4:	1c048a63          	beqz	s1,778 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5a8:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5ac:	fe0993e3          	bnez	s3,592 <vprintf+0x40>
      if(c0 == '%'){
 5b0:	fd579ce3          	bne	a5,s5,588 <vprintf+0x36>
        state = '%';
 5b4:	89be                	mv	s3,a5
 5b6:	b7c5                	j	596 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5b8:	00ea06b3          	add	a3,s4,a4
 5bc:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5c0:	1c060863          	beqz	a2,790 <vprintf+0x23e>
      if(c0 == 'd'){
 5c4:	03878763          	beq	a5,s8,5f2 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c8:	f9478693          	addi	a3,a5,-108
 5cc:	0016b693          	seqz	a3,a3
 5d0:	f9c60593          	addi	a1,a2,-100
 5d4:	e99d                	bnez	a1,60a <vprintf+0xb8>
 5d6:	ca95                	beqz	a3,60a <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d8:	008b8493          	addi	s1,s7,8
 5dc:	4685                	li	a3,1
 5de:	4629                	li	a2,10
 5e0:	000bb583          	ld	a1,0(s7)
 5e4:	855a                	mv	a0,s6
 5e6:	ecfff0ef          	jal	4b4 <printint>
        i += 1;
 5ea:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ec:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b75d                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5f2:	008b8493          	addi	s1,s7,8
 5f6:	4685                	li	a3,1
 5f8:	4629                	li	a2,10
 5fa:	000ba583          	lw	a1,0(s7)
 5fe:	855a                	mv	a0,s6
 600:	eb5ff0ef          	jal	4b4 <printint>
 604:	8ba6                	mv	s7,s1
      state = 0;
 606:	4981                	li	s3,0
 608:	b779                	j	596 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 60a:	9752                	add	a4,a4,s4
 60c:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 610:	f9460713          	addi	a4,a2,-108
 614:	00173713          	seqz	a4,a4
 618:	8f75                	and	a4,a4,a3
 61a:	f9c58513          	addi	a0,a1,-100
 61e:	18051363          	bnez	a0,7a4 <vprintf+0x252>
 622:	18070163          	beqz	a4,7a4 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 626:	008b8493          	addi	s1,s7,8
 62a:	4685                	li	a3,1
 62c:	4629                	li	a2,10
 62e:	000bb583          	ld	a1,0(s7)
 632:	855a                	mv	a0,s6
 634:	e81ff0ef          	jal	4b4 <printint>
        i += 2;
 638:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 63a:	8ba6                	mv	s7,s1
      state = 0;
 63c:	4981                	li	s3,0
        i += 2;
 63e:	bfa1                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 640:	008b8493          	addi	s1,s7,8
 644:	4681                	li	a3,0
 646:	4629                	li	a2,10
 648:	000be583          	lwu	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e67ff0ef          	jal	4b4 <printint>
 652:	8ba6                	mv	s7,s1
      state = 0;
 654:	4981                	li	s3,0
 656:	b781                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b8493          	addi	s1,s7,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000bb583          	ld	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e4fff0ef          	jal	4b4 <printint>
        i += 1;
 66a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	8ba6                	mv	s7,s1
      state = 0;
 66e:	4981                	li	s3,0
 670:	b71d                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	008b8493          	addi	s1,s7,8
 676:	4681                	li	a3,0
 678:	4629                	li	a2,10
 67a:	000bb583          	ld	a1,0(s7)
 67e:	855a                	mv	a0,s6
 680:	e35ff0ef          	jal	4b4 <printint>
        i += 2;
 684:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 686:	8ba6                	mv	s7,s1
      state = 0;
 688:	4981                	li	s3,0
        i += 2;
 68a:	b731                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 68c:	008b8493          	addi	s1,s7,8
 690:	4681                	li	a3,0
 692:	4641                	li	a2,16
 694:	000be583          	lwu	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	e1bff0ef          	jal	4b4 <printint>
 69e:	8ba6                	mv	s7,s1
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bdd5                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a4:	008b8493          	addi	s1,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4641                	li	a2,16
 6ac:	000bb583          	ld	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	e03ff0ef          	jal	4b4 <printint>
        i += 1;
 6b6:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	8ba6                	mv	s7,s1
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	bde9                	j	596 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	008b8493          	addi	s1,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4641                	li	a2,16
 6c6:	000bb583          	ld	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	de9ff0ef          	jal	4b4 <printint>
        i += 2;
 6d0:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	8ba6                	mv	s7,s1
      state = 0;
 6d4:	4981                	li	s3,0
        i += 2;
 6d6:	b5c1                	j	596 <vprintf+0x44>
 6d8:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6da:	008b8793          	addi	a5,s7,8
 6de:	8cbe                	mv	s9,a5
 6e0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e4:	03000593          	li	a1,48
 6e8:	855a                	mv	a0,s6
 6ea:	dadff0ef          	jal	496 <putc>
  putc(fd, 'x');
 6ee:	07800593          	li	a1,120
 6f2:	855a                	mv	a0,s6
 6f4:	da3ff0ef          	jal	496 <putc>
 6f8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fa:	00000b97          	auipc	s7,0x0
 6fe:	38eb8b93          	addi	s7,s7,910 # a88 <digits>
 702:	03c9d793          	srli	a5,s3,0x3c
 706:	97de                	add	a5,a5,s7
 708:	0007c583          	lbu	a1,0(a5)
 70c:	855a                	mv	a0,s6
 70e:	d89ff0ef          	jal	496 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 712:	0992                	slli	s3,s3,0x4
 714:	34fd                	addiw	s1,s1,-1
 716:	f4f5                	bnez	s1,702 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 718:	8be6                	mv	s7,s9
      state = 0;
 71a:	4981                	li	s3,0
 71c:	6ca2                	ld	s9,8(sp)
 71e:	bda5                	j	596 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 720:	008b8493          	addi	s1,s7,8
 724:	000bc583          	lbu	a1,0(s7)
 728:	855a                	mv	a0,s6
 72a:	d6dff0ef          	jal	496 <putc>
 72e:	8ba6                	mv	s7,s1
      state = 0;
 730:	4981                	li	s3,0
 732:	b595                	j	596 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 734:	008b8993          	addi	s3,s7,8
 738:	000bb483          	ld	s1,0(s7)
 73c:	cc91                	beqz	s1,758 <vprintf+0x206>
        for(; *s; s++)
 73e:	0004c583          	lbu	a1,0(s1)
 742:	c985                	beqz	a1,772 <vprintf+0x220>
          putc(fd, *s);
 744:	855a                	mv	a0,s6
 746:	d51ff0ef          	jal	496 <putc>
        for(; *s; s++)
 74a:	0485                	addi	s1,s1,1
 74c:	0004c583          	lbu	a1,0(s1)
 750:	f9f5                	bnez	a1,744 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 752:	8bce                	mv	s7,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	b581                	j	596 <vprintf+0x44>
          s = "(null)";
 758:	00000497          	auipc	s1,0x0
 75c:	32848493          	addi	s1,s1,808 # a80 <malloc+0x18c>
        for(; *s; s++)
 760:	02800593          	li	a1,40
 764:	b7c5                	j	744 <vprintf+0x1f2>
        putc(fd, '%');
 766:	85be                	mv	a1,a5
 768:	855a                	mv	a0,s6
 76a:	d2dff0ef          	jal	496 <putc>
      state = 0;
 76e:	4981                	li	s3,0
 770:	b51d                	j	596 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 772:	8bce                	mv	s7,s3
      state = 0;
 774:	4981                	li	s3,0
 776:	b505                	j	596 <vprintf+0x44>
 778:	6906                	ld	s2,64(sp)
 77a:	79e2                	ld	s3,56(sp)
 77c:	7a42                	ld	s4,48(sp)
 77e:	7aa2                	ld	s5,40(sp)
 780:	7b02                	ld	s6,32(sp)
 782:	6be2                	ld	s7,24(sp)
 784:	6c42                	ld	s8,16(sp)
    }
  }
}
 786:	60e6                	ld	ra,88(sp)
 788:	6446                	ld	s0,80(sp)
 78a:	64a6                	ld	s1,72(sp)
 78c:	6125                	addi	sp,sp,96
 78e:	8082                	ret
      if(c0 == 'd'){
 790:	06400713          	li	a4,100
 794:	e4e78fe3          	beq	a5,a4,5f2 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 798:	f9478693          	addi	a3,a5,-108
 79c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7a0:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a2:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7a4:	07500513          	li	a0,117
 7a8:	e8a78ce3          	beq	a5,a0,640 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7ac:	f8b60513          	addi	a0,a2,-117
 7b0:	e119                	bnez	a0,7b6 <vprintf+0x264>
 7b2:	ea0693e3          	bnez	a3,658 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7b6:	f8b58513          	addi	a0,a1,-117
 7ba:	e119                	bnez	a0,7c0 <vprintf+0x26e>
 7bc:	ea071be3          	bnez	a4,672 <vprintf+0x120>
      } else if(c0 == 'x'){
 7c0:	07800513          	li	a0,120
 7c4:	eca784e3          	beq	a5,a0,68c <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7c8:	f8860613          	addi	a2,a2,-120
 7cc:	e219                	bnez	a2,7d2 <vprintf+0x280>
 7ce:	ec069be3          	bnez	a3,6a4 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7d2:	f8858593          	addi	a1,a1,-120
 7d6:	e199                	bnez	a1,7dc <vprintf+0x28a>
 7d8:	ee0713e3          	bnez	a4,6be <vprintf+0x16c>
      } else if(c0 == 'p'){
 7dc:	07000713          	li	a4,112
 7e0:	eee78ce3          	beq	a5,a4,6d8 <vprintf+0x186>
      } else if(c0 == 'c'){
 7e4:	06300713          	li	a4,99
 7e8:	f2e78ce3          	beq	a5,a4,720 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7ec:	07300713          	li	a4,115
 7f0:	f4e782e3          	beq	a5,a4,734 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7f4:	02500713          	li	a4,37
 7f8:	f6e787e3          	beq	a5,a4,766 <vprintf+0x214>
        putc(fd, '%');
 7fc:	02500593          	li	a1,37
 800:	855a                	mv	a0,s6
 802:	c95ff0ef          	jal	496 <putc>
        putc(fd, c0);
 806:	85a6                	mv	a1,s1
 808:	855a                	mv	a0,s6
 80a:	c8dff0ef          	jal	496 <putc>
      state = 0;
 80e:	4981                	li	s3,0
 810:	b359                	j	596 <vprintf+0x44>

0000000000000812 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 812:	715d                	addi	sp,sp,-80
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e010                	sd	a2,0(s0)
 81c:	e414                	sd	a3,8(s0)
 81e:	e818                	sd	a4,16(s0)
 820:	ec1c                	sd	a5,24(s0)
 822:	03043023          	sd	a6,32(s0)
 826:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	8622                	mv	a2,s0
 82c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 830:	d23ff0ef          	jal	552 <vprintf>
}
 834:	60e2                	ld	ra,24(sp)
 836:	6442                	ld	s0,16(sp)
 838:	6161                	addi	sp,sp,80
 83a:	8082                	ret

000000000000083c <printf>:

void
printf(const char *fmt, ...)
{
 83c:	711d                	addi	sp,sp,-96
 83e:	ec06                	sd	ra,24(sp)
 840:	e822                	sd	s0,16(sp)
 842:	1000                	addi	s0,sp,32
 844:	e40c                	sd	a1,8(s0)
 846:	e810                	sd	a2,16(s0)
 848:	ec14                	sd	a3,24(s0)
 84a:	f018                	sd	a4,32(s0)
 84c:	f41c                	sd	a5,40(s0)
 84e:	03043823          	sd	a6,48(s0)
 852:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 856:	00840613          	addi	a2,s0,8
 85a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 85e:	85aa                	mv	a1,a0
 860:	4505                	li	a0,1
 862:	cf1ff0ef          	jal	552 <vprintf>
}
 866:	60e2                	ld	ra,24(sp)
 868:	6442                	ld	s0,16(sp)
 86a:	6125                	addi	sp,sp,96
 86c:	8082                	ret

000000000000086e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86e:	1141                	addi	sp,sp,-16
 870:	e406                	sd	ra,8(sp)
 872:	e022                	sd	s0,0(sp)
 874:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 876:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	00000797          	auipc	a5,0x0
 87e:	7867b783          	ld	a5,1926(a5) # 1000 <freep>
 882:	a039                	j	890 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 884:	6398                	ld	a4,0(a5)
 886:	00e7e463          	bltu	a5,a4,88e <free+0x20>
 88a:	00e6ea63          	bltu	a3,a4,89e <free+0x30>
{
 88e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 890:	fed7fae3          	bgeu	a5,a3,884 <free+0x16>
 894:	6398                	ld	a4,0(a5)
 896:	00e6e463          	bltu	a3,a4,89e <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89a:	fee7eae3          	bltu	a5,a4,88e <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 89e:	ff852583          	lw	a1,-8(a0)
 8a2:	6390                	ld	a2,0(a5)
 8a4:	02059813          	slli	a6,a1,0x20
 8a8:	01c85713          	srli	a4,a6,0x1c
 8ac:	9736                	add	a4,a4,a3
 8ae:	02e60563          	beq	a2,a4,8d8 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8b2:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8b6:	4790                	lw	a2,8(a5)
 8b8:	02061593          	slli	a1,a2,0x20
 8bc:	01c5d713          	srli	a4,a1,0x1c
 8c0:	973e                	add	a4,a4,a5
 8c2:	02e68263          	beq	a3,a4,8e6 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8c6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c8:	00000717          	auipc	a4,0x0
 8cc:	72f73c23          	sd	a5,1848(a4) # 1000 <freep>
}
 8d0:	60a2                	ld	ra,8(sp)
 8d2:	6402                	ld	s0,0(sp)
 8d4:	0141                	addi	sp,sp,16
 8d6:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8d8:	4618                	lw	a4,8(a2)
 8da:	9f2d                	addw	a4,a4,a1
 8dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e0:	6398                	ld	a4,0(a5)
 8e2:	6310                	ld	a2,0(a4)
 8e4:	b7f9                	j	8b2 <free+0x44>
    p->s.size += bp->s.size;
 8e6:	ff852703          	lw	a4,-8(a0)
 8ea:	9f31                	addw	a4,a4,a2
 8ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ee:	ff053683          	ld	a3,-16(a0)
 8f2:	bfd1                	j	8c6 <free+0x58>

00000000000008f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f4:	7139                	addi	sp,sp,-64
 8f6:	fc06                	sd	ra,56(sp)
 8f8:	f822                	sd	s0,48(sp)
 8fa:	f04a                	sd	s2,32(sp)
 8fc:	ec4e                	sd	s3,24(sp)
 8fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 900:	02051993          	slli	s3,a0,0x20
 904:	0209d993          	srli	s3,s3,0x20
 908:	09bd                	addi	s3,s3,15
 90a:	0049d993          	srli	s3,s3,0x4
 90e:	2985                	addiw	s3,s3,1
 910:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 912:	00000517          	auipc	a0,0x0
 916:	6ee53503          	ld	a0,1774(a0) # 1000 <freep>
 91a:	c905                	beqz	a0,94a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 91e:	4798                	lw	a4,8(a5)
 920:	09377663          	bgeu	a4,s3,9ac <malloc+0xb8>
 924:	f426                	sd	s1,40(sp)
 926:	e852                	sd	s4,16(sp)
 928:	e456                	sd	s5,8(sp)
 92a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 92c:	8a4e                	mv	s4,s3
 92e:	6705                	lui	a4,0x1
 930:	00e9f363          	bgeu	s3,a4,936 <malloc+0x42>
 934:	6a05                	lui	s4,0x1
 936:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 93e:	00000497          	auipc	s1,0x0
 942:	6c248493          	addi	s1,s1,1730 # 1000 <freep>
  if(p == SBRK_ERROR)
 946:	5afd                	li	s5,-1
 948:	a83d                	j	986 <malloc+0x92>
 94a:	f426                	sd	s1,40(sp)
 94c:	e852                	sd	s4,16(sp)
 94e:	e456                	sd	s5,8(sp)
 950:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 952:	00000797          	auipc	a5,0x0
 956:	6be78793          	addi	a5,a5,1726 # 1010 <base>
 95a:	00000717          	auipc	a4,0x0
 95e:	6af73323          	sd	a5,1702(a4) # 1000 <freep>
 962:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 964:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 968:	b7d1                	j	92c <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 96a:	6398                	ld	a4,0(a5)
 96c:	e118                	sd	a4,0(a0)
 96e:	a899                	j	9c4 <malloc+0xd0>
  hp->s.size = nu;
 970:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 974:	0541                	addi	a0,a0,16
 976:	ef9ff0ef          	jal	86e <free>
  return freep;
 97a:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 97c:	c125                	beqz	a0,9dc <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 980:	4798                	lw	a4,8(a5)
 982:	03277163          	bgeu	a4,s2,9a4 <malloc+0xb0>
    if(p == freep)
 986:	6098                	ld	a4,0(s1)
 988:	853e                	mv	a0,a5
 98a:	fef71ae3          	bne	a4,a5,97e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 98e:	8552                	mv	a0,s4
 990:	a2bff0ef          	jal	3ba <sbrk>
  if(p == SBRK_ERROR)
 994:	fd551ee3          	bne	a0,s5,970 <malloc+0x7c>
        return 0;
 998:	4501                	li	a0,0
 99a:	74a2                	ld	s1,40(sp)
 99c:	6a42                	ld	s4,16(sp)
 99e:	6aa2                	ld	s5,8(sp)
 9a0:	6b02                	ld	s6,0(sp)
 9a2:	a03d                	j	9d0 <malloc+0xdc>
 9a4:	74a2                	ld	s1,40(sp)
 9a6:	6a42                	ld	s4,16(sp)
 9a8:	6aa2                	ld	s5,8(sp)
 9aa:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9ac:	fae90fe3          	beq	s2,a4,96a <malloc+0x76>
        p->s.size -= nunits;
 9b0:	4137073b          	subw	a4,a4,s3
 9b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b6:	02071693          	slli	a3,a4,0x20
 9ba:	01c6d713          	srli	a4,a3,0x1c
 9be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9c4:	00000717          	auipc	a4,0x0
 9c8:	62a73e23          	sd	a0,1596(a4) # 1000 <freep>
      return (void*)(p + 1);
 9cc:	01078513          	addi	a0,a5,16
  }
}
 9d0:	70e2                	ld	ra,56(sp)
 9d2:	7442                	ld	s0,48(sp)
 9d4:	7902                	ld	s2,32(sp)
 9d6:	69e2                	ld	s3,24(sp)
 9d8:	6121                	addi	sp,sp,64
 9da:	8082                	ret
 9dc:	74a2                	ld	s1,40(sp)
 9de:	6a42                	ld	s4,16(sp)
 9e0:	6aa2                	ld	s5,8(sp)
 9e2:	6b02                	ld	s6,0(sp)
 9e4:	b7f5                	j	9d0 <malloc+0xdc>
