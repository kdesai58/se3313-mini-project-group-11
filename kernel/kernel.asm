
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	96010113          	addi	sp,sp,-1696 # 80007960 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddb97>
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
    8000011a:	278020ef          	jal	80002392 <either_copyin>
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
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	7ce50513          	addi	a0,a0,1998 # 8000f960 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	7c248493          	addi	s1,s1,1986 # 8000f960 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00010917          	auipc	s2,0x10
    800001aa:	85290913          	addi	s2,s2,-1966 # 8000f9f8 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	770010ef          	jal	8000192e <myproc>
    800001c2:	068020ef          	jal	8000222a <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	623010ef          	jal	80001fee <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	78270713          	addi	a4,a4,1922 # 8000f960 <cons>
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
    80000210:	138020ef          	jal	80002348 <either_copyout>
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
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	73850513          	addi	a0,a0,1848 # 8000f960 <cons>
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
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	7af72523          	sw	a5,1962(a4) # 8000f9f8 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	6fc50513          	addi	a0,a0,1788 # 8000f960 <cons>
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
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	6a850513          	addi	a0,a0,1704 # 8000f960 <cons>
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
    800002da:	102020ef          	jal	800023dc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	68250513          	addi	a0,a0,1666 # 8000f960 <cons>
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
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	66470713          	addi	a4,a4,1636 # 8000f960 <cons>
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
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	63e70713          	addi	a4,a4,1598 # 8000f960 <cons>
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
    8000034c:	0000f717          	auipc	a4,0xf
    80000350:	6ac72703          	lw	a4,1708(a4) # 8000f9f8 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	5fe70713          	addi	a4,a4,1534 # 8000f960 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	0000f497          	auipc	s1,0xf
    80000376:	5ee48493          	addi	s1,s1,1518 # 8000f960 <cons>
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
    800003b4:	0000f717          	auipc	a4,0xf
    800003b8:	5ac70713          	addi	a4,a4,1452 # 8000f960 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	0000f717          	auipc	a4,0xf
    800003ce:	62f72b23          	sw	a5,1590(a4) # 8000fa00 <cons+0xa0>
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
    800003e8:	0000f797          	auipc	a5,0xf
    800003ec:	57878793          	addi	a5,a5,1400 # 8000f960 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	0000f797          	auipc	a5,0xf
    8000040e:	5ec7a923          	sw	a2,1522(a5) # 8000f9fc <cons+0x9c>
        wakeup(&cons.r);
    80000412:	0000f517          	auipc	a0,0xf
    80000416:	5e650513          	addi	a0,a0,1510 # 8000f9f8 <cons+0x98>
    8000041a:	421010ef          	jal	8000203a <wakeup>
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
    80000430:	0000f517          	auipc	a0,0xf
    80000434:	53050513          	addi	a0,a0,1328 # 8000f960 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	0001f797          	auipc	a5,0x1f
    80000444:	69078793          	addi	a5,a5,1680 # 8001fad0 <devsw>
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
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	41c7a783          	lw	a5,1052(a5) # 80007934 <panicking>
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
    8000055e:	0000f517          	auipc	a0,0xf
    80000562:	4aa50513          	addi	a0,a0,1194 # 8000fa08 <pr>
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
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	1da7a783          	lw	a5,474(a5) # 80007934 <panicking>
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
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	28450513          	addi	a0,a0,644 # 8000fa08 <pr>
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
    80000834:	00007797          	auipc	a5,0x7
    80000838:	1097a023          	sw	s1,256(a5) # 80007934 <panicking>
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
    80000856:	00007797          	auipc	a5,0x7
    8000085a:	0c97ad23          	sw	s1,218(a5) # 80007930 <panicked>
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
    80000870:	0000f517          	auipc	a0,0xf
    80000874:	19850513          	addi	a0,a0,408 # 8000fa08 <pr>
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
    800008c6:	0000f517          	auipc	a0,0xf
    800008ca:	15a50513          	addi	a0,a0,346 # 8000fa20 <tx_lock>
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
    800008ea:	0000f517          	auipc	a0,0xf
    800008ee:	13650513          	addi	a0,a0,310 # 8000fa20 <tx_lock>
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
    80000908:	00007497          	auipc	s1,0x7
    8000090c:	03448493          	addi	s1,s1,52 # 8000793c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	0000f997          	auipc	s3,0xf
    80000914:	11098993          	addi	s3,s3,272 # 8000fa20 <tx_lock>
    80000918:	00007917          	auipc	s2,0x7
    8000091c:	02090913          	addi	s2,s2,32 # 80007938 <tx_chan>
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
    8000092c:	6c2010ef          	jal	80001fee <sleep>
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
    80000956:	0000f517          	auipc	a0,0xf
    8000095a:	0ca50513          	addi	a0,a0,202 # 8000fa20 <tx_lock>
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
    8000097a:	00007797          	auipc	a5,0x7
    8000097e:	fba7a783          	lw	a5,-70(a5) # 80007934 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	00007797          	auipc	a5,0x7
    80000988:	fac7a783          	lw	a5,-84(a5) # 80007930 <panicked>
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
    800009aa:	00007797          	auipc	a5,0x7
    800009ae:	f8a7a783          	lw	a5,-118(a5) # 80007934 <panicking>
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
    80000a06:	0000f517          	auipc	a0,0xf
    80000a0a:	01a50513          	addi	a0,a0,26 # 8000fa20 <tx_lock>
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
    80000a20:	0000f517          	auipc	a0,0xf
    80000a24:	00050513          	mv	a0,a0
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
    80000a3c:	00007797          	auipc	a5,0x7
    80000a40:	f007a023          	sw	zero,-256(a5) # 8000793c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	ef450513          	addi	a0,a0,-268 # 80007938 <tx_chan>
    80000a4c:	5ee010ef          	jal	8000203a <wakeup>
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
    80000a68:	00020797          	auipc	a5,0x20
    80000a6c:	20078793          	addi	a5,a5,512 # 80020c68 <end>
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
    80000a92:	0000f917          	auipc	s2,0xf
    80000a96:	fa690913          	addi	s2,s2,-90 # 8000fa38 <kmem>
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
    80000b20:	0000f517          	auipc	a0,0xf
    80000b24:	f1850513          	addi	a0,a0,-232 # 8000fa38 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00020517          	auipc	a0,0x20
    80000b34:	13850513          	addi	a0,a0,312 # 80020c68 <end>
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
    80000b4e:	0000f517          	auipc	a0,0xf
    80000b52:	eea50513          	addi	a0,a0,-278 # 8000fa38 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	0000f497          	auipc	s1,0xf
    80000b5e:	ef64b483          	ld	s1,-266(s1) # 8000fa50 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	0000f717          	auipc	a4,0xf
    80000b6a:	eef73523          	sd	a5,-278(a4) # 8000fa50 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	0000f517          	auipc	a0,0xf
    80000b72:	eca50513          	addi	a0,a0,-310 # 8000fa38 <kmem>
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
    80000b90:	0000f517          	auipc	a0,0xf
    80000b94:	ea850513          	addi	a0,a0,-344 # 8000fa38 <kmem>
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
    80000bce:	541000ef          	jal	8000190e <mycpu>
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
    80000bfe:	511000ef          	jal	8000190e <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	509000ef          	jal	8000190e <mycpu>
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
    80000c1a:	4f5000ef          	jal	8000190e <mycpu>
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
    80000c50:	4bf000ef          	jal	8000190e <mycpu>
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
    80000c74:	49b000ef          	jal	8000190e <mycpu>
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
    80000eb6:	245000ef          	jal	800018fa <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	00007717          	auipc	a4,0x7
    80000ebe:	a8670713          	addi	a4,a4,-1402 # 80007940 <started>
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
    80000ece:	22d000ef          	jal	800018fa <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	728010ef          	jal	8000260c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	7b0040ef          	jal	80005698 <plicinithart>
  }

  scheduler();        
    80000eec:	6bd000ef          	jal	80001da8 <scheduler>
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
    80000f28:	11d000ef          	jal	80001844 <procinit>
    trapinit();      // trap vectors
    80000f2c:	6bc010ef          	jal	800025e8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	6dc010ef          	jal	8000260c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	74a040ef          	jal	8000567e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	760040ef          	jal	80005698 <plicinithart>
    binit();         // buffer cache
    80000f3c:	595010ef          	jal	80002cd0 <binit>
    iinit();         // inode table
    80000f40:	2e6020ef          	jal	80003226 <iinit>
    fileinit();      // file table
    80000f44:	212030ef          	jal	80004156 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	041040ef          	jal	80005788 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	4b1000ef          	jal	80001bfc <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	9ef72523          	sw	a5,-1558(a4) # 80007940 <started>
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
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	9dc7b783          	ld	a5,-1572(a5) # 80007948 <kernel_pagetable>
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
    800011dc:	5c4000ef          	jal	800017a0 <proc_mapstacks>
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
    800011f8:	00006797          	auipc	a5,0x6
    800011fc:	74a7b823          	sd	a0,1872(a5) # 80007948 <kernel_pagetable>
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
    800015e0:	34e000ef          	jal	8000192e <myproc>
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

00000000800017a0 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017a0:	715d                	addi	sp,sp,-80
    800017a2:	e486                	sd	ra,72(sp)
    800017a4:	e0a2                	sd	s0,64(sp)
    800017a6:	fc26                	sd	s1,56(sp)
    800017a8:	f84a                	sd	s2,48(sp)
    800017aa:	f44e                	sd	s3,40(sp)
    800017ac:	f052                	sd	s4,32(sp)
    800017ae:	ec56                	sd	s5,24(sp)
    800017b0:	e85a                	sd	s6,16(sp)
    800017b2:	e45e                	sd	s7,8(sp)
    800017b4:	e062                	sd	s8,0(sp)
    800017b6:	0880                	addi	s0,sp,80
    800017b8:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ba:	0000e497          	auipc	s1,0xe
    800017be:	6ce48493          	addi	s1,s1,1742 # 8000fe88 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017c2:	8c26                	mv	s8,s1
    800017c4:	000a57b7          	lui	a5,0xa5
    800017c8:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017cc:	07b2                	slli	a5,a5,0xc
    800017ce:	fa578793          	addi	a5,a5,-91
    800017d2:	4fa50937          	lui	s2,0x4fa50
    800017d6:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017da:	1902                	slli	s2,s2,0x20
    800017dc:	993e                	add	s2,s2,a5
    800017de:	040009b7          	lui	s3,0x4000
    800017e2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017e4:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e6:	4b99                	li	s7,6
    800017e8:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ea:	00014a97          	auipc	s5,0x14
    800017ee:	09ea8a93          	addi	s5,s5,158 # 80015888 <tickslock>
    char *pa = kalloc();
    800017f2:	b52ff0ef          	jal	80000b44 <kalloc>
    800017f6:	862a                	mv	a2,a0
    if(pa == 0)
    800017f8:	c121                	beqz	a0,80001838 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    800017fa:	418485b3          	sub	a1,s1,s8
    800017fe:	858d                	srai	a1,a1,0x3
    80001800:	032585b3          	mul	a1,a1,s2
    80001804:	05b6                	slli	a1,a1,0xd
    80001806:	6789                	lui	a5,0x2
    80001808:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000180a:	875e                	mv	a4,s7
    8000180c:	86da                	mv	a3,s6
    8000180e:	40b985b3          	sub	a1,s3,a1
    80001812:	8552                	mv	a0,s4
    80001814:	903ff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001818:	16848493          	addi	s1,s1,360
    8000181c:	fd549be3          	bne	s1,s5,800017f2 <proc_mapstacks+0x52>
  }
}
    80001820:	60a6                	ld	ra,72(sp)
    80001822:	6406                	ld	s0,64(sp)
    80001824:	74e2                	ld	s1,56(sp)
    80001826:	7942                	ld	s2,48(sp)
    80001828:	79a2                	ld	s3,40(sp)
    8000182a:	7a02                	ld	s4,32(sp)
    8000182c:	6ae2                	ld	s5,24(sp)
    8000182e:	6b42                	ld	s6,16(sp)
    80001830:	6ba2                	ld	s7,8(sp)
    80001832:	6c02                	ld	s8,0(sp)
    80001834:	6161                	addi	sp,sp,80
    80001836:	8082                	ret
      panic("kalloc");
    80001838:	00006517          	auipc	a0,0x6
    8000183c:	92050513          	addi	a0,a0,-1760 # 80007158 <etext+0x158>
    80001840:	fe5fe0ef          	jal	80000824 <panic>

0000000080001844 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001844:	7139                	addi	sp,sp,-64
    80001846:	fc06                	sd	ra,56(sp)
    80001848:	f822                	sd	s0,48(sp)
    8000184a:	f426                	sd	s1,40(sp)
    8000184c:	f04a                	sd	s2,32(sp)
    8000184e:	ec4e                	sd	s3,24(sp)
    80001850:	e852                	sd	s4,16(sp)
    80001852:	e456                	sd	s5,8(sp)
    80001854:	e05a                	sd	s6,0(sp)
    80001856:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001858:	00006597          	auipc	a1,0x6
    8000185c:	90858593          	addi	a1,a1,-1784 # 80007160 <etext+0x160>
    80001860:	0000e517          	auipc	a0,0xe
    80001864:	1f850513          	addi	a0,a0,504 # 8000fa58 <pid_lock>
    80001868:	b36ff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000186c:	00006597          	auipc	a1,0x6
    80001870:	8fc58593          	addi	a1,a1,-1796 # 80007168 <etext+0x168>
    80001874:	0000e517          	auipc	a0,0xe
    80001878:	1fc50513          	addi	a0,a0,508 # 8000fa70 <wait_lock>
    8000187c:	b22ff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	0000e497          	auipc	s1,0xe
    80001884:	60848493          	addi	s1,s1,1544 # 8000fe88 <proc>
      initlock(&p->lock, "proc");
    80001888:	00006b17          	auipc	s6,0x6
    8000188c:	8f0b0b13          	addi	s6,s6,-1808 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001890:	8aa6                	mv	s5,s1
    80001892:	000a57b7          	lui	a5,0xa5
    80001896:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    8000189a:	07b2                	slli	a5,a5,0xc
    8000189c:	fa578793          	addi	a5,a5,-91
    800018a0:	4fa50937          	lui	s2,0x4fa50
    800018a4:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018a8:	1902                	slli	s2,s2,0x20
    800018aa:	993e                	add	s2,s2,a5
    800018ac:	040009b7          	lui	s3,0x4000
    800018b0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b4:	00014a17          	auipc	s4,0x14
    800018b8:	fd4a0a13          	addi	s4,s4,-44 # 80015888 <tickslock>
      initlock(&p->lock, "proc");
    800018bc:	85da                	mv	a1,s6
    800018be:	8526                	mv	a0,s1
    800018c0:	adeff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    800018c4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018c8:	415487b3          	sub	a5,s1,s5
    800018cc:	878d                	srai	a5,a5,0x3
    800018ce:	032787b3          	mul	a5,a5,s2
    800018d2:	07b6                	slli	a5,a5,0xd
    800018d4:	6709                	lui	a4,0x2
    800018d6:	9fb9                	addw	a5,a5,a4
    800018d8:	40f987b3          	sub	a5,s3,a5
    800018dc:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	16848493          	addi	s1,s1,360
    800018e2:	fd449de3          	bne	s1,s4,800018bc <procinit+0x78>
  }
}
    800018e6:	70e2                	ld	ra,56(sp)
    800018e8:	7442                	ld	s0,48(sp)
    800018ea:	74a2                	ld	s1,40(sp)
    800018ec:	7902                	ld	s2,32(sp)
    800018ee:	69e2                	ld	s3,24(sp)
    800018f0:	6a42                	ld	s4,16(sp)
    800018f2:	6aa2                	ld	s5,8(sp)
    800018f4:	6b02                	ld	s6,0(sp)
    800018f6:	6121                	addi	sp,sp,64
    800018f8:	8082                	ret

00000000800018fa <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018fa:	1141                	addi	sp,sp,-16
    800018fc:	e406                	sd	ra,8(sp)
    800018fe:	e022                	sd	s0,0(sp)
    80001900:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001902:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001904:	2501                	sext.w	a0,a0
    80001906:	60a2                	ld	ra,8(sp)
    80001908:	6402                	ld	s0,0(sp)
    8000190a:	0141                	addi	sp,sp,16
    8000190c:	8082                	ret

000000008000190e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000190e:	1141                	addi	sp,sp,-16
    80001910:	e406                	sd	ra,8(sp)
    80001912:	e022                	sd	s0,0(sp)
    80001914:	0800                	addi	s0,sp,16
    80001916:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001918:	2781                	sext.w	a5,a5
    8000191a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000191c:	0000e517          	auipc	a0,0xe
    80001920:	16c50513          	addi	a0,a0,364 # 8000fa88 <cpus>
    80001924:	953e                	add	a0,a0,a5
    80001926:	60a2                	ld	ra,8(sp)
    80001928:	6402                	ld	s0,0(sp)
    8000192a:	0141                	addi	sp,sp,16
    8000192c:	8082                	ret

000000008000192e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000192e:	1101                	addi	sp,sp,-32
    80001930:	ec06                	sd	ra,24(sp)
    80001932:	e822                	sd	s0,16(sp)
    80001934:	e426                	sd	s1,8(sp)
    80001936:	1000                	addi	s0,sp,32
  push_off();
    80001938:	aacff0ef          	jal	80000be4 <push_off>
    8000193c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000193e:	2781                	sext.w	a5,a5
    80001940:	079e                	slli	a5,a5,0x7
    80001942:	0000e717          	auipc	a4,0xe
    80001946:	11670713          	addi	a4,a4,278 # 8000fa58 <pid_lock>
    8000194a:	97ba                	add	a5,a5,a4
    8000194c:	7b9c                	ld	a5,48(a5)
    8000194e:	84be                	mv	s1,a5
  pop_off();
    80001950:	b1cff0ef          	jal	80000c6c <pop_off>
  return p;
}
    80001954:	8526                	mv	a0,s1
    80001956:	60e2                	ld	ra,24(sp)
    80001958:	6442                	ld	s0,16(sp)
    8000195a:	64a2                	ld	s1,8(sp)
    8000195c:	6105                	addi	sp,sp,32
    8000195e:	8082                	ret

0000000080001960 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001960:	7179                	addi	sp,sp,-48
    80001962:	f406                	sd	ra,40(sp)
    80001964:	f022                	sd	s0,32(sp)
    80001966:	ec26                	sd	s1,24(sp)
    80001968:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    8000196a:	fc5ff0ef          	jal	8000192e <myproc>
    8000196e:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001970:	b4cff0ef          	jal	80000cbc <release>

  if (first) {
    80001974:	00006797          	auipc	a5,0x6
    80001978:	fac7a783          	lw	a5,-84(a5) # 80007920 <first.2>
    8000197c:	cf95                	beqz	a5,800019b8 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000197e:	4505                	li	a0,1
    80001980:	563010ef          	jal	800036e2 <fsinit>

    first = 0;
    80001984:	00006797          	auipc	a5,0x6
    80001988:	f807ae23          	sw	zero,-100(a5) # 80007920 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000198c:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001990:	00005797          	auipc	a5,0x5
    80001994:	7f078793          	addi	a5,a5,2032 # 80007180 <etext+0x180>
    80001998:	fcf43823          	sd	a5,-48(s0)
    8000199c:	fc043c23          	sd	zero,-40(s0)
    800019a0:	fd040593          	addi	a1,s0,-48
    800019a4:	853e                	mv	a0,a5
    800019a6:	707020ef          	jal	800048ac <kexec>
    800019aa:	6cbc                	ld	a5,88(s1)
    800019ac:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019ae:	6cbc                	ld	a5,88(s1)
    800019b0:	7bb8                	ld	a4,112(a5)
    800019b2:	57fd                	li	a5,-1
    800019b4:	02f70d63          	beq	a4,a5,800019ee <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019b8:	471000ef          	jal	80002628 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019bc:	68a8                	ld	a0,80(s1)
    800019be:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019c0:	04000737          	lui	a4,0x4000
    800019c4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019c6:	0732                	slli	a4,a4,0xc
    800019c8:	00004797          	auipc	a5,0x4
    800019cc:	6d478793          	addi	a5,a5,1748 # 8000609c <userret>
    800019d0:	00004697          	auipc	a3,0x4
    800019d4:	63068693          	addi	a3,a3,1584 # 80006000 <_trampoline>
    800019d8:	8f95                	sub	a5,a5,a3
    800019da:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019dc:	577d                	li	a4,-1
    800019de:	177e                	slli	a4,a4,0x3f
    800019e0:	8d59                	or	a0,a0,a4
    800019e2:	9782                	jalr	a5
}
    800019e4:	70a2                	ld	ra,40(sp)
    800019e6:	7402                	ld	s0,32(sp)
    800019e8:	64e2                	ld	s1,24(sp)
    800019ea:	6145                	addi	sp,sp,48
    800019ec:	8082                	ret
      panic("exec");
    800019ee:	00005517          	auipc	a0,0x5
    800019f2:	79a50513          	addi	a0,a0,1946 # 80007188 <etext+0x188>
    800019f6:	e2ffe0ef          	jal	80000824 <panic>

00000000800019fa <allocpid>:
{
    800019fa:	1101                	addi	sp,sp,-32
    800019fc:	ec06                	sd	ra,24(sp)
    800019fe:	e822                	sd	s0,16(sp)
    80001a00:	e426                	sd	s1,8(sp)
    80001a02:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a04:	0000e517          	auipc	a0,0xe
    80001a08:	05450513          	addi	a0,a0,84 # 8000fa58 <pid_lock>
    80001a0c:	a1cff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001a10:	00006797          	auipc	a5,0x6
    80001a14:	f1478793          	addi	a5,a5,-236 # 80007924 <nextpid>
    80001a18:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a1a:	0014871b          	addiw	a4,s1,1
    80001a1e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a20:	0000e517          	auipc	a0,0xe
    80001a24:	03850513          	addi	a0,a0,56 # 8000fa58 <pid_lock>
    80001a28:	a94ff0ef          	jal	80000cbc <release>
}
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	60e2                	ld	ra,24(sp)
    80001a30:	6442                	ld	s0,16(sp)
    80001a32:	64a2                	ld	s1,8(sp)
    80001a34:	6105                	addi	sp,sp,32
    80001a36:	8082                	ret

0000000080001a38 <proc_pagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a46:	fc2ff0ef          	jal	80001208 <uvmcreate>
    80001a4a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a4c:	cd05                	beqz	a0,80001a84 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a4e:	4729                	li	a4,10
    80001a50:	00004697          	auipc	a3,0x4
    80001a54:	5b068693          	addi	a3,a3,1456 # 80006000 <_trampoline>
    80001a58:	6605                	lui	a2,0x1
    80001a5a:	040005b7          	lui	a1,0x4000
    80001a5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a60:	05b2                	slli	a1,a1,0xc
    80001a62:	dfeff0ef          	jal	80001060 <mappages>
    80001a66:	02054663          	bltz	a0,80001a92 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a6a:	4719                	li	a4,6
    80001a6c:	05893683          	ld	a3,88(s2)
    80001a70:	6605                	lui	a2,0x1
    80001a72:	020005b7          	lui	a1,0x2000
    80001a76:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a78:	05b6                	slli	a1,a1,0xd
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	de4ff0ef          	jal	80001060 <mappages>
    80001a80:	00054f63          	bltz	a0,80001a9e <proc_pagetable+0x66>
}
    80001a84:	8526                	mv	a0,s1
    80001a86:	60e2                	ld	ra,24(sp)
    80001a88:	6442                	ld	s0,16(sp)
    80001a8a:	64a2                	ld	s1,8(sp)
    80001a8c:	6902                	ld	s2,0(sp)
    80001a8e:	6105                	addi	sp,sp,32
    80001a90:	8082                	ret
    uvmfree(pagetable, 0);
    80001a92:	4581                	li	a1,0
    80001a94:	8526                	mv	a0,s1
    80001a96:	96dff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001a9a:	4481                	li	s1,0
    80001a9c:	b7e5                	j	80001a84 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a9e:	4681                	li	a3,0
    80001aa0:	4605                	li	a2,1
    80001aa2:	040005b7          	lui	a1,0x4000
    80001aa6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aa8:	05b2                	slli	a1,a1,0xc
    80001aaa:	8526                	mv	a0,s1
    80001aac:	f82ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001ab0:	4581                	li	a1,0
    80001ab2:	8526                	mv	a0,s1
    80001ab4:	94fff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001ab8:	4481                	li	s1,0
    80001aba:	b7e9                	j	80001a84 <proc_pagetable+0x4c>

0000000080001abc <proc_freepagetable>:
{
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	e04a                	sd	s2,0(sp)
    80001ac6:	1000                	addi	s0,sp,32
    80001ac8:	84aa                	mv	s1,a0
    80001aca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001acc:	4681                	li	a3,0
    80001ace:	4605                	li	a2,1
    80001ad0:	040005b7          	lui	a1,0x4000
    80001ad4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad6:	05b2                	slli	a1,a1,0xc
    80001ad8:	f56ff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001adc:	4681                	li	a3,0
    80001ade:	4605                	li	a2,1
    80001ae0:	020005b7          	lui	a1,0x2000
    80001ae4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ae6:	05b6                	slli	a1,a1,0xd
    80001ae8:	8526                	mv	a0,s1
    80001aea:	f44ff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001aee:	85ca                	mv	a1,s2
    80001af0:	8526                	mv	a0,s1
    80001af2:	911ff0ef          	jal	80001402 <uvmfree>
}
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret

0000000080001b02 <freeproc>:
{
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	1000                	addi	s0,sp,32
    80001b0c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b0e:	6d28                	ld	a0,88(a0)
    80001b10:	c119                	beqz	a0,80001b16 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b12:	f4bfe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001b16:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b1a:	68a8                	ld	a0,80(s1)
    80001b1c:	c501                	beqz	a0,80001b24 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b1e:	64ac                	ld	a1,72(s1)
    80001b20:	f9dff0ef          	jal	80001abc <proc_freepagetable>
  p->pagetable = 0;
    80001b24:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b28:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b2c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b30:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b34:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b38:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b3c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b40:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b44:	0004ac23          	sw	zero,24(s1)
}
    80001b48:	60e2                	ld	ra,24(sp)
    80001b4a:	6442                	ld	s0,16(sp)
    80001b4c:	64a2                	ld	s1,8(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret

0000000080001b52 <allocproc>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b5e:	0000e497          	auipc	s1,0xe
    80001b62:	32a48493          	addi	s1,s1,810 # 8000fe88 <proc>
    80001b66:	00014917          	auipc	s2,0x14
    80001b6a:	d2290913          	addi	s2,s2,-734 # 80015888 <tickslock>
    acquire(&p->lock);
    80001b6e:	8526                	mv	a0,s1
    80001b70:	8b8ff0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001b74:	4c9c                	lw	a5,24(s1)
    80001b76:	cb91                	beqz	a5,80001b8a <allocproc+0x38>
      release(&p->lock);
    80001b78:	8526                	mv	a0,s1
    80001b7a:	942ff0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b7e:	16848493          	addi	s1,s1,360
    80001b82:	ff2496e3          	bne	s1,s2,80001b6e <allocproc+0x1c>
  return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	a099                	j	80001bce <allocproc+0x7c>
  p->pid = allocpid();
    80001b8a:	e71ff0ef          	jal	800019fa <allocpid>
    80001b8e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b90:	4785                	li	a5,1
    80001b92:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001b94:	0204aa23          	sw	zero,52(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b98:	fadfe0ef          	jal	80000b44 <kalloc>
    80001b9c:	892a                	mv	s2,a0
    80001b9e:	eca8                	sd	a0,88(s1)
    80001ba0:	cd15                	beqz	a0,80001bdc <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	e95ff0ef          	jal	80001a38 <proc_pagetable>
    80001ba8:	892a                	mv	s2,a0
    80001baa:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001bac:	c121                	beqz	a0,80001bec <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001bae:	07000613          	li	a2,112
    80001bb2:	4581                	li	a1,0
    80001bb4:	06048513          	addi	a0,s1,96
    80001bb8:	940ff0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001bbc:	00000797          	auipc	a5,0x0
    80001bc0:	da478793          	addi	a5,a5,-604 # 80001960 <forkret>
    80001bc4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bc6:	60bc                	ld	a5,64(s1)
    80001bc8:	6705                	lui	a4,0x1
    80001bca:	97ba                	add	a5,a5,a4
    80001bcc:	f4bc                	sd	a5,104(s1)
}
    80001bce:	8526                	mv	a0,s1
    80001bd0:	60e2                	ld	ra,24(sp)
    80001bd2:	6442                	ld	s0,16(sp)
    80001bd4:	64a2                	ld	s1,8(sp)
    80001bd6:	6902                	ld	s2,0(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret
    freeproc(p);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	f25ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	8d8ff0ef          	jal	80000cbc <release>
    return 0;
    80001be8:	84ca                	mv	s1,s2
    80001bea:	b7d5                	j	80001bce <allocproc+0x7c>
    freeproc(p);
    80001bec:	8526                	mv	a0,s1
    80001bee:	f15ff0ef          	jal	80001b02 <freeproc>
    release(&p->lock);
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	8c8ff0ef          	jal	80000cbc <release>
    return 0;
    80001bf8:	84ca                	mv	s1,s2
    80001bfa:	bfd1                	j	80001bce <allocproc+0x7c>

0000000080001bfc <userinit>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c06:	f4dff0ef          	jal	80001b52 <allocproc>
    80001c0a:	84aa                	mv	s1,a0
  initproc = p;
    80001c0c:	00006797          	auipc	a5,0x6
    80001c10:	d4a7b223          	sd	a0,-700(a5) # 80007950 <initproc>
  p->cwd = namei("/");
    80001c14:	00005517          	auipc	a0,0x5
    80001c18:	57c50513          	addi	a0,a0,1404 # 80007190 <etext+0x190>
    80001c1c:	000020ef          	jal	80003c1c <namei>
    80001c20:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c24:	478d                	li	a5,3
    80001c26:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c28:	8526                	mv	a0,s1
    80001c2a:	892ff0ef          	jal	80000cbc <release>
}
    80001c2e:	60e2                	ld	ra,24(sp)
    80001c30:	6442                	ld	s0,16(sp)
    80001c32:	64a2                	ld	s1,8(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret

0000000080001c38 <growproc>:
{
    80001c38:	1101                	addi	sp,sp,-32
    80001c3a:	ec06                	sd	ra,24(sp)
    80001c3c:	e822                	sd	s0,16(sp)
    80001c3e:	e426                	sd	s1,8(sp)
    80001c40:	e04a                	sd	s2,0(sp)
    80001c42:	1000                	addi	s0,sp,32
    80001c44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c46:	ce9ff0ef          	jal	8000192e <myproc>
    80001c4a:	892a                	mv	s2,a0
  sz = p->sz;
    80001c4c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c4e:	02905963          	blez	s1,80001c80 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001c52:	00b48633          	add	a2,s1,a1
    80001c56:	020007b7          	lui	a5,0x2000
    80001c5a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c5c:	07b6                	slli	a5,a5,0xd
    80001c5e:	02c7ea63          	bltu	a5,a2,80001c92 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c62:	4691                	li	a3,4
    80001c64:	6928                	ld	a0,80(a0)
    80001c66:	e96ff0ef          	jal	800012fc <uvmalloc>
    80001c6a:	85aa                	mv	a1,a0
    80001c6c:	c50d                	beqz	a0,80001c96 <growproc+0x5e>
  p->sz = sz;
    80001c6e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c72:	4501                	li	a0,0
}
    80001c74:	60e2                	ld	ra,24(sp)
    80001c76:	6442                	ld	s0,16(sp)
    80001c78:	64a2                	ld	s1,8(sp)
    80001c7a:	6902                	ld	s2,0(sp)
    80001c7c:	6105                	addi	sp,sp,32
    80001c7e:	8082                	ret
  } else if(n < 0){
    80001c80:	fe04d7e3          	bgez	s1,80001c6e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c84:	00b48633          	add	a2,s1,a1
    80001c88:	6928                	ld	a0,80(a0)
    80001c8a:	e2eff0ef          	jal	800012b8 <uvmdealloc>
    80001c8e:	85aa                	mv	a1,a0
    80001c90:	bff9                	j	80001c6e <growproc+0x36>
      return -1;
    80001c92:	557d                	li	a0,-1
    80001c94:	b7c5                	j	80001c74 <growproc+0x3c>
      return -1;
    80001c96:	557d                	li	a0,-1
    80001c98:	bff1                	j	80001c74 <growproc+0x3c>

0000000080001c9a <kfork>:
{
    80001c9a:	7139                	addi	sp,sp,-64
    80001c9c:	fc06                	sd	ra,56(sp)
    80001c9e:	f822                	sd	s0,48(sp)
    80001ca0:	f426                	sd	s1,40(sp)
    80001ca2:	e456                	sd	s5,8(sp)
    80001ca4:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ca6:	c89ff0ef          	jal	8000192e <myproc>
    80001caa:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001cac:	ea7ff0ef          	jal	80001b52 <allocproc>
    80001cb0:	0e050a63          	beqz	a0,80001da4 <kfork+0x10a>
    80001cb4:	e852                	sd	s4,16(sp)
    80001cb6:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001cb8:	048ab603          	ld	a2,72(s5)
    80001cbc:	692c                	ld	a1,80(a0)
    80001cbe:	050ab503          	ld	a0,80(s5)
    80001cc2:	f72ff0ef          	jal	80001434 <uvmcopy>
    80001cc6:	04054863          	bltz	a0,80001d16 <kfork+0x7c>
    80001cca:	f04a                	sd	s2,32(sp)
    80001ccc:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001cce:	048ab783          	ld	a5,72(s5)
    80001cd2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cd6:	058ab683          	ld	a3,88(s5)
    80001cda:	87b6                	mv	a5,a3
    80001cdc:	058a3703          	ld	a4,88(s4)
    80001ce0:	12068693          	addi	a3,a3,288
    80001ce4:	6388                	ld	a0,0(a5)
    80001ce6:	678c                	ld	a1,8(a5)
    80001ce8:	6b90                	ld	a2,16(a5)
    80001cea:	e308                	sd	a0,0(a4)
    80001cec:	e70c                	sd	a1,8(a4)
    80001cee:	eb10                	sd	a2,16(a4)
    80001cf0:	6f90                	ld	a2,24(a5)
    80001cf2:	ef10                	sd	a2,24(a4)
    80001cf4:	02078793          	addi	a5,a5,32
    80001cf8:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001cfc:	fed794e3          	bne	a5,a3,80001ce4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d00:	058a3783          	ld	a5,88(s4)
    80001d04:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d08:	0d0a8493          	addi	s1,s5,208
    80001d0c:	0d0a0913          	addi	s2,s4,208
    80001d10:	150a8993          	addi	s3,s5,336
    80001d14:	a831                	j	80001d30 <kfork+0x96>
    freeproc(np);
    80001d16:	8552                	mv	a0,s4
    80001d18:	debff0ef          	jal	80001b02 <freeproc>
    release(&np->lock);
    80001d1c:	8552                	mv	a0,s4
    80001d1e:	f9ffe0ef          	jal	80000cbc <release>
    return -1;
    80001d22:	54fd                	li	s1,-1
    80001d24:	6a42                	ld	s4,16(sp)
    80001d26:	a885                	j	80001d96 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001d28:	04a1                	addi	s1,s1,8
    80001d2a:	0921                	addi	s2,s2,8
    80001d2c:	01348963          	beq	s1,s3,80001d3e <kfork+0xa4>
    if(p->ofile[i])
    80001d30:	6088                	ld	a0,0(s1)
    80001d32:	d97d                	beqz	a0,80001d28 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d34:	4a4020ef          	jal	800041d8 <filedup>
    80001d38:	00a93023          	sd	a0,0(s2)
    80001d3c:	b7f5                	j	80001d28 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d3e:	150ab503          	ld	a0,336(s5)
    80001d42:	676010ef          	jal	800033b8 <idup>
    80001d46:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d4a:	4641                	li	a2,16
    80001d4c:	158a8593          	addi	a1,s5,344
    80001d50:	158a0513          	addi	a0,s4,344
    80001d54:	8f8ff0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001d58:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d5c:	8552                	mv	a0,s4
    80001d5e:	f5ffe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001d62:	0000e517          	auipc	a0,0xe
    80001d66:	d0e50513          	addi	a0,a0,-754 # 8000fa70 <wait_lock>
    80001d6a:	ebffe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001d6e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d72:	0000e517          	auipc	a0,0xe
    80001d76:	cfe50513          	addi	a0,a0,-770 # 8000fa70 <wait_lock>
    80001d7a:	f43fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001d7e:	8552                	mv	a0,s4
    80001d80:	ea9fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001d84:	478d                	li	a5,3
    80001d86:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d8a:	8552                	mv	a0,s4
    80001d8c:	f31fe0ef          	jal	80000cbc <release>
  return pid;
    80001d90:	7902                	ld	s2,32(sp)
    80001d92:	69e2                	ld	s3,24(sp)
    80001d94:	6a42                	ld	s4,16(sp)
}
    80001d96:	8526                	mv	a0,s1
    80001d98:	70e2                	ld	ra,56(sp)
    80001d9a:	7442                	ld	s0,48(sp)
    80001d9c:	74a2                	ld	s1,40(sp)
    80001d9e:	6aa2                	ld	s5,8(sp)
    80001da0:	6121                	addi	sp,sp,64
    80001da2:	8082                	ret
    return -1;
    80001da4:	54fd                	li	s1,-1
    80001da6:	bfc5                	j	80001d96 <kfork+0xfc>

0000000080001da8 <scheduler>:
{
    80001da8:	715d                	addi	sp,sp,-80
    80001daa:	e486                	sd	ra,72(sp)
    80001dac:	e0a2                	sd	s0,64(sp)
    80001dae:	fc26                	sd	s1,56(sp)
    80001db0:	f84a                	sd	s2,48(sp)
    80001db2:	f44e                	sd	s3,40(sp)
    80001db4:	f052                	sd	s4,32(sp)
    80001db6:	ec56                	sd	s5,24(sp)
    80001db8:	e85a                	sd	s6,16(sp)
    80001dba:	e45e                	sd	s7,8(sp)
    80001dbc:	e062                	sd	s8,0(sp)
    80001dbe:	0880                	addi	s0,sp,80
    80001dc0:	8792                	mv	a5,tp
  int id = r_tp();
    80001dc2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dc4:	00779693          	slli	a3,a5,0x7
    80001dc8:	0000e717          	auipc	a4,0xe
    80001dcc:	c9070713          	addi	a4,a4,-880 # 8000fa58 <pid_lock>
    80001dd0:	9736                	add	a4,a4,a3
    80001dd2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &chosen->context);
    80001dd6:	0000e717          	auipc	a4,0xe
    80001dda:	cba70713          	addi	a4,a4,-838 # 8000fa90 <cpus+0x8>
    80001dde:	9736                	add	a4,a4,a3
    80001de0:	8c3a                	mv	s8,a4
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001de2:	498d                	li	s3,3
    80001de4:	4aa5                	li	s5,9
    for(p=proc; p<&proc[NPROC]; p++){
    80001de6:	00014917          	auipc	s2,0x14
    80001dea:	aa290913          	addi	s2,s2,-1374 # 80015888 <tickslock>
        c->proc = chosen;
    80001dee:	0000eb17          	auipc	s6,0xe
    80001df2:	c6ab0b13          	addi	s6,s6,-918 # 8000fa58 <pid_lock>
    80001df6:	9b36                	add	s6,s6,a3
    80001df8:	a84d                	j	80001eaa <scheduler+0x102>
          chosen = p;
    80001dfa:	8a26                	mv	s4,s1
      release(&p->lock);
    80001dfc:	8526                	mv	a0,s1
    80001dfe:	ebffe0ef          	jal	80000cbc <release>
    for(p=proc; p<&proc[NPROC]; p++){
    80001e02:	16848493          	addi	s1,s1,360
    80001e06:	03248a63          	beq	s1,s2,80001e3a <scheduler+0x92>
      acquire(&p->lock);
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	e1dfe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001e10:	4c9c                	lw	a5,24(s1)
    80001e12:	ff3795e3          	bne	a5,s3,80001dfc <scheduler+0x54>
    80001e16:	7c88                	ld	a0,56(s1)
    80001e18:	d175                	beqz	a0,80001dfc <scheduler+0x54>
    80001e1a:	8656                	mv	a2,s5
    80001e1c:	85de                	mv	a1,s7
    80001e1e:	15850513          	addi	a0,a0,344
    80001e22:	fabfe0ef          	jal	80000dcc <strncmp>
    80001e26:	f979                	bnez	a0,80001dfc <scheduler+0x54>
        if(chosen == 0 || p->pid < chosen->pid){
    80001e28:	fc0a09e3          	beqz	s4,80001dfa <scheduler+0x52>
    80001e2c:	5898                	lw	a4,48(s1)
    80001e2e:	030a2783          	lw	a5,48(s4)
    80001e32:	fcf755e3          	bge	a4,a5,80001dfc <scheduler+0x54>
          chosen = p;
    80001e36:	8a26                	mv	s4,s1
    80001e38:	b7d1                	j	80001dfc <scheduler+0x54>
      found = 1;
    80001e3a:	4b85                	li	s7,1
    if(chosen != 0)
    80001e3c:	000a0763          	beqz	s4,80001e4a <scheduler+0xa2>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e40:	0000e497          	auipc	s1,0xe
    80001e44:	04848493          	addi	s1,s1,72 # 8000fe88 <proc>
    80001e48:	a089                	j	80001e8a <scheduler+0xe2>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e4a:	0000e497          	auipc	s1,0xe
    80001e4e:	03e48493          	addi	s1,s1,62 # 8000fe88 <proc>
        acquire(&p->lock);
    80001e52:	8526                	mv	a0,s1
    80001e54:	dd5fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE) {
    80001e58:	4c9c                	lw	a5,24(s1)
    80001e5a:	01378b63          	beq	a5,s3,80001e70 <scheduler+0xc8>
        release(&p->lock);
    80001e5e:	8526                	mv	a0,s1
    80001e60:	e5dfe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001e64:	16848493          	addi	s1,s1,360
    80001e68:	ff2495e3          	bne	s1,s2,80001e52 <scheduler+0xaa>
    80001e6c:	4b81                	li	s7,0
    80001e6e:	bfc9                	j	80001e40 <scheduler+0x98>
          release(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	e4bfe0ef          	jal	80000cbc <release>
          chosen = p;
    80001e76:	8a26                	mv	s4,s1
          found = 1;
    80001e78:	4b85                	li	s7,1
          break;
    80001e7a:	b7d9                	j	80001e40 <scheduler+0x98>
      release(&p->lock);
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	e3ffe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e82:	16848493          	addi	s1,s1,360
    80001e86:	01248e63          	beq	s1,s2,80001ea2 <scheduler+0xfa>
      acquire(&p->lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	d9dfe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen) {
    80001e90:	4c9c                	lw	a5,24(s1)
    80001e92:	17f5                	addi	a5,a5,-3
    80001e94:	f7e5                	bnez	a5,80001e7c <scheduler+0xd4>
    80001e96:	fe9a03e3          	beq	s4,s1,80001e7c <scheduler+0xd4>
        p->waiting_tick++;
    80001e9a:	58dc                	lw	a5,52(s1)
    80001e9c:	2785                	addiw	a5,a5,1
    80001e9e:	d8dc                	sw	a5,52(s1)
    80001ea0:	bff1                	j	80001e7c <scheduler+0xd4>
    if(found == 0) {
    80001ea2:	020b9963          	bnez	s7,80001ed4 <scheduler+0x12c>
      asm volatile("wfi");
    80001ea6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eaa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eb2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eb6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001eba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ebc:	10079073          	csrw	sstatus,a5
    chosen = 0;
    80001ec0:	4a01                	li	s4,0
    for(p=proc; p<&proc[NPROC]; p++){
    80001ec2:	0000e497          	auipc	s1,0xe
    80001ec6:	fc648493          	addi	s1,s1,-58 # 8000fe88 <proc>
      if(p->state == RUNNABLE && p->parent != 0 && strncmp(p->parent->name, "schedtest", 9) == 0){
    80001eca:	00005b97          	auipc	s7,0x5
    80001ece:	2ceb8b93          	addi	s7,s7,718 # 80007198 <etext+0x198>
    80001ed2:	bf25                	j	80001e0a <scheduler+0x62>
      acquire(&chosen->lock);
    80001ed4:	84d2                	mv	s1,s4
    80001ed6:	8552                	mv	a0,s4
    80001ed8:	d51fe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    80001edc:	018a2783          	lw	a5,24(s4)
    80001ee0:	01378663          	beq	a5,s3,80001eec <scheduler+0x144>
      release(&chosen->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	dd7fe0ef          	jal	80000cbc <release>
    80001eea:	b7c1                	j	80001eaa <scheduler+0x102>
        chosen->state = RUNNING;
    80001eec:	4791                	li	a5,4
    80001eee:	00fa2c23          	sw	a5,24(s4)
        c->proc = chosen;
    80001ef2:	034b3823          	sd	s4,48(s6)
        swtch(&c->context, &chosen->context);
    80001ef6:	060a0593          	addi	a1,s4,96
    80001efa:	8562                	mv	a0,s8
    80001efc:	682000ef          	jal	8000257e <swtch>
        c->proc = 0;
    80001f00:	020b3823          	sd	zero,48(s6)
    80001f04:	b7c5                	j	80001ee4 <scheduler+0x13c>

0000000080001f06 <sched>:
{
    80001f06:	7179                	addi	sp,sp,-48
    80001f08:	f406                	sd	ra,40(sp)
    80001f0a:	f022                	sd	s0,32(sp)
    80001f0c:	ec26                	sd	s1,24(sp)
    80001f0e:	e84a                	sd	s2,16(sp)
    80001f10:	e44e                	sd	s3,8(sp)
    80001f12:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f14:	a1bff0ef          	jal	8000192e <myproc>
    80001f18:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f1a:	c9ffe0ef          	jal	80000bb8 <holding>
    80001f1e:	c935                	beqz	a0,80001f92 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f20:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f22:	2781                	sext.w	a5,a5
    80001f24:	079e                	slli	a5,a5,0x7
    80001f26:	0000e717          	auipc	a4,0xe
    80001f2a:	b3270713          	addi	a4,a4,-1230 # 8000fa58 <pid_lock>
    80001f2e:	97ba                	add	a5,a5,a4
    80001f30:	0a87a703          	lw	a4,168(a5)
    80001f34:	4785                	li	a5,1
    80001f36:	06f71463          	bne	a4,a5,80001f9e <sched+0x98>
  if(p->state == RUNNING)
    80001f3a:	4c98                	lw	a4,24(s1)
    80001f3c:	4791                	li	a5,4
    80001f3e:	06f70663          	beq	a4,a5,80001faa <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f42:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f46:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f48:	e7bd                	bnez	a5,80001fb6 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f4a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f4c:	0000e917          	auipc	s2,0xe
    80001f50:	b0c90913          	addi	s2,s2,-1268 # 8000fa58 <pid_lock>
    80001f54:	2781                	sext.w	a5,a5
    80001f56:	079e                	slli	a5,a5,0x7
    80001f58:	97ca                	add	a5,a5,s2
    80001f5a:	0ac7a983          	lw	s3,172(a5)
    80001f5e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f60:	2781                	sext.w	a5,a5
    80001f62:	079e                	slli	a5,a5,0x7
    80001f64:	07a1                	addi	a5,a5,8
    80001f66:	0000e597          	auipc	a1,0xe
    80001f6a:	b2258593          	addi	a1,a1,-1246 # 8000fa88 <cpus>
    80001f6e:	95be                	add	a1,a1,a5
    80001f70:	06048513          	addi	a0,s1,96
    80001f74:	60a000ef          	jal	8000257e <swtch>
    80001f78:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f7a:	2781                	sext.w	a5,a5
    80001f7c:	079e                	slli	a5,a5,0x7
    80001f7e:	993e                	add	s2,s2,a5
    80001f80:	0b392623          	sw	s3,172(s2)
}
    80001f84:	70a2                	ld	ra,40(sp)
    80001f86:	7402                	ld	s0,32(sp)
    80001f88:	64e2                	ld	s1,24(sp)
    80001f8a:	6942                	ld	s2,16(sp)
    80001f8c:	69a2                	ld	s3,8(sp)
    80001f8e:	6145                	addi	sp,sp,48
    80001f90:	8082                	ret
    panic("sched p->lock");
    80001f92:	00005517          	auipc	a0,0x5
    80001f96:	21650513          	addi	a0,a0,534 # 800071a8 <etext+0x1a8>
    80001f9a:	88bfe0ef          	jal	80000824 <panic>
    panic("sched locks");
    80001f9e:	00005517          	auipc	a0,0x5
    80001fa2:	21a50513          	addi	a0,a0,538 # 800071b8 <etext+0x1b8>
    80001fa6:	87ffe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    80001faa:	00005517          	auipc	a0,0x5
    80001fae:	21e50513          	addi	a0,a0,542 # 800071c8 <etext+0x1c8>
    80001fb2:	873fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    80001fb6:	00005517          	auipc	a0,0x5
    80001fba:	22250513          	addi	a0,a0,546 # 800071d8 <etext+0x1d8>
    80001fbe:	867fe0ef          	jal	80000824 <panic>

0000000080001fc2 <yield>:
{
    80001fc2:	1101                	addi	sp,sp,-32
    80001fc4:	ec06                	sd	ra,24(sp)
    80001fc6:	e822                	sd	s0,16(sp)
    80001fc8:	e426                	sd	s1,8(sp)
    80001fca:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001fcc:	963ff0ef          	jal	8000192e <myproc>
    80001fd0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fd2:	c57fe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80001fd6:	478d                	li	a5,3
    80001fd8:	cc9c                	sw	a5,24(s1)
  sched();
    80001fda:	f2dff0ef          	jal	80001f06 <sched>
  release(&p->lock);
    80001fde:	8526                	mv	a0,s1
    80001fe0:	cddfe0ef          	jal	80000cbc <release>
}
    80001fe4:	60e2                	ld	ra,24(sp)
    80001fe6:	6442                	ld	s0,16(sp)
    80001fe8:	64a2                	ld	s1,8(sp)
    80001fea:	6105                	addi	sp,sp,32
    80001fec:	8082                	ret

0000000080001fee <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001fee:	7179                	addi	sp,sp,-48
    80001ff0:	f406                	sd	ra,40(sp)
    80001ff2:	f022                	sd	s0,32(sp)
    80001ff4:	ec26                	sd	s1,24(sp)
    80001ff6:	e84a                	sd	s2,16(sp)
    80001ff8:	e44e                	sd	s3,8(sp)
    80001ffa:	1800                	addi	s0,sp,48
    80001ffc:	89aa                	mv	s3,a0
    80001ffe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002000:	92fff0ef          	jal	8000192e <myproc>
    80002004:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002006:	c23fe0ef          	jal	80000c28 <acquire>
  release(lk);
    8000200a:	854a                	mv	a0,s2
    8000200c:	cb1fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    80002010:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002014:	4789                	li	a5,2
    80002016:	cc9c                	sw	a5,24(s1)

  sched();
    80002018:	eefff0ef          	jal	80001f06 <sched>

  // Tidy up.
  p->chan = 0;
    8000201c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002020:	8526                	mv	a0,s1
    80002022:	c9bfe0ef          	jal	80000cbc <release>
  acquire(lk);
    80002026:	854a                	mv	a0,s2
    80002028:	c01fe0ef          	jal	80000c28 <acquire>
}
    8000202c:	70a2                	ld	ra,40(sp)
    8000202e:	7402                	ld	s0,32(sp)
    80002030:	64e2                	ld	s1,24(sp)
    80002032:	6942                	ld	s2,16(sp)
    80002034:	69a2                	ld	s3,8(sp)
    80002036:	6145                	addi	sp,sp,48
    80002038:	8082                	ret

000000008000203a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000203a:	7139                	addi	sp,sp,-64
    8000203c:	fc06                	sd	ra,56(sp)
    8000203e:	f822                	sd	s0,48(sp)
    80002040:	f426                	sd	s1,40(sp)
    80002042:	f04a                	sd	s2,32(sp)
    80002044:	ec4e                	sd	s3,24(sp)
    80002046:	e852                	sd	s4,16(sp)
    80002048:	e456                	sd	s5,8(sp)
    8000204a:	0080                	addi	s0,sp,64
    8000204c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000204e:	0000e497          	auipc	s1,0xe
    80002052:	e3a48493          	addi	s1,s1,-454 # 8000fe88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002056:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002058:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000205a:	00014917          	auipc	s2,0x14
    8000205e:	82e90913          	addi	s2,s2,-2002 # 80015888 <tickslock>
    80002062:	a801                	j	80002072 <wakeup+0x38>
      }
      release(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	c57fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000206a:	16848493          	addi	s1,s1,360
    8000206e:	03248263          	beq	s1,s2,80002092 <wakeup+0x58>
    if(p != myproc()){
    80002072:	8bdff0ef          	jal	8000192e <myproc>
    80002076:	fe950ae3          	beq	a0,s1,8000206a <wakeup+0x30>
      acquire(&p->lock);
    8000207a:	8526                	mv	a0,s1
    8000207c:	badfe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002080:	4c9c                	lw	a5,24(s1)
    80002082:	ff3791e3          	bne	a5,s3,80002064 <wakeup+0x2a>
    80002086:	709c                	ld	a5,32(s1)
    80002088:	fd479ee3          	bne	a5,s4,80002064 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000208c:	0154ac23          	sw	s5,24(s1)
    80002090:	bfd1                	j	80002064 <wakeup+0x2a>
    }
  }
}
    80002092:	70e2                	ld	ra,56(sp)
    80002094:	7442                	ld	s0,48(sp)
    80002096:	74a2                	ld	s1,40(sp)
    80002098:	7902                	ld	s2,32(sp)
    8000209a:	69e2                	ld	s3,24(sp)
    8000209c:	6a42                	ld	s4,16(sp)
    8000209e:	6aa2                	ld	s5,8(sp)
    800020a0:	6121                	addi	sp,sp,64
    800020a2:	8082                	ret

00000000800020a4 <reparent>:
{
    800020a4:	7179                	addi	sp,sp,-48
    800020a6:	f406                	sd	ra,40(sp)
    800020a8:	f022                	sd	s0,32(sp)
    800020aa:	ec26                	sd	s1,24(sp)
    800020ac:	e84a                	sd	s2,16(sp)
    800020ae:	e44e                	sd	s3,8(sp)
    800020b0:	e052                	sd	s4,0(sp)
    800020b2:	1800                	addi	s0,sp,48
    800020b4:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020b6:	0000e497          	auipc	s1,0xe
    800020ba:	dd248493          	addi	s1,s1,-558 # 8000fe88 <proc>
      pp->parent = initproc;
    800020be:	00006a17          	auipc	s4,0x6
    800020c2:	892a0a13          	addi	s4,s4,-1902 # 80007950 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800020c6:	00013997          	auipc	s3,0x13
    800020ca:	7c298993          	addi	s3,s3,1986 # 80015888 <tickslock>
    800020ce:	a029                	j	800020d8 <reparent+0x34>
    800020d0:	16848493          	addi	s1,s1,360
    800020d4:	01348b63          	beq	s1,s3,800020ea <reparent+0x46>
    if(pp->parent == p){
    800020d8:	7c9c                	ld	a5,56(s1)
    800020da:	ff279be3          	bne	a5,s2,800020d0 <reparent+0x2c>
      pp->parent = initproc;
    800020de:	000a3503          	ld	a0,0(s4)
    800020e2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020e4:	f57ff0ef          	jal	8000203a <wakeup>
    800020e8:	b7e5                	j	800020d0 <reparent+0x2c>
}
    800020ea:	70a2                	ld	ra,40(sp)
    800020ec:	7402                	ld	s0,32(sp)
    800020ee:	64e2                	ld	s1,24(sp)
    800020f0:	6942                	ld	s2,16(sp)
    800020f2:	69a2                	ld	s3,8(sp)
    800020f4:	6a02                	ld	s4,0(sp)
    800020f6:	6145                	addi	sp,sp,48
    800020f8:	8082                	ret

00000000800020fa <kexit>:
{
    800020fa:	7179                	addi	sp,sp,-48
    800020fc:	f406                	sd	ra,40(sp)
    800020fe:	f022                	sd	s0,32(sp)
    80002100:	ec26                	sd	s1,24(sp)
    80002102:	e84a                	sd	s2,16(sp)
    80002104:	e44e                	sd	s3,8(sp)
    80002106:	e052                	sd	s4,0(sp)
    80002108:	1800                	addi	s0,sp,48
    8000210a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000210c:	823ff0ef          	jal	8000192e <myproc>
    80002110:	89aa                	mv	s3,a0
  if(p == initproc)
    80002112:	00006797          	auipc	a5,0x6
    80002116:	83e7b783          	ld	a5,-1986(a5) # 80007950 <initproc>
    8000211a:	0d050493          	addi	s1,a0,208
    8000211e:	15050913          	addi	s2,a0,336
    80002122:	00a79b63          	bne	a5,a0,80002138 <kexit+0x3e>
    panic("init exiting");
    80002126:	00005517          	auipc	a0,0x5
    8000212a:	0ca50513          	addi	a0,a0,202 # 800071f0 <etext+0x1f0>
    8000212e:	ef6fe0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002132:	04a1                	addi	s1,s1,8
    80002134:	01248963          	beq	s1,s2,80002146 <kexit+0x4c>
    if(p->ofile[fd]){
    80002138:	6088                	ld	a0,0(s1)
    8000213a:	dd65                	beqz	a0,80002132 <kexit+0x38>
      fileclose(f);
    8000213c:	0e2020ef          	jal	8000421e <fileclose>
      p->ofile[fd] = 0;
    80002140:	0004b023          	sd	zero,0(s1)
    80002144:	b7fd                	j	80002132 <kexit+0x38>
  begin_op();
    80002146:	4b5010ef          	jal	80003dfa <begin_op>
  iput(p->cwd);
    8000214a:	1509b503          	ld	a0,336(s3)
    8000214e:	422010ef          	jal	80003570 <iput>
  end_op();
    80002152:	519010ef          	jal	80003e6a <end_op>
  p->cwd = 0;
    80002156:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000215a:	0000e517          	auipc	a0,0xe
    8000215e:	91650513          	addi	a0,a0,-1770 # 8000fa70 <wait_lock>
    80002162:	ac7fe0ef          	jal	80000c28 <acquire>
  reparent(p);
    80002166:	854e                	mv	a0,s3
    80002168:	f3dff0ef          	jal	800020a4 <reparent>
  wakeup(p->parent);
    8000216c:	0389b503          	ld	a0,56(s3)
    80002170:	ecbff0ef          	jal	8000203a <wakeup>
  acquire(&p->lock);
    80002174:	854e                	mv	a0,s3
    80002176:	ab3fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    8000217a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000217e:	4795                	li	a5,5
    80002180:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002184:	0000e517          	auipc	a0,0xe
    80002188:	8ec50513          	addi	a0,a0,-1812 # 8000fa70 <wait_lock>
    8000218c:	b31fe0ef          	jal	80000cbc <release>
  sched();
    80002190:	d77ff0ef          	jal	80001f06 <sched>
  panic("zombie exit");
    80002194:	00005517          	auipc	a0,0x5
    80002198:	06c50513          	addi	a0,a0,108 # 80007200 <etext+0x200>
    8000219c:	e88fe0ef          	jal	80000824 <panic>

00000000800021a0 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800021a0:	7179                	addi	sp,sp,-48
    800021a2:	f406                	sd	ra,40(sp)
    800021a4:	f022                	sd	s0,32(sp)
    800021a6:	ec26                	sd	s1,24(sp)
    800021a8:	e84a                	sd	s2,16(sp)
    800021aa:	e44e                	sd	s3,8(sp)
    800021ac:	1800                	addi	s0,sp,48
    800021ae:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800021b0:	0000e497          	auipc	s1,0xe
    800021b4:	cd848493          	addi	s1,s1,-808 # 8000fe88 <proc>
    800021b8:	00013997          	auipc	s3,0x13
    800021bc:	6d098993          	addi	s3,s3,1744 # 80015888 <tickslock>
    acquire(&p->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	a67fe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    800021c6:	589c                	lw	a5,48(s1)
    800021c8:	01278b63          	beq	a5,s2,800021de <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	aeffe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800021d2:	16848493          	addi	s1,s1,360
    800021d6:	ff3495e3          	bne	s1,s3,800021c0 <kkill+0x20>
  }
  return -1;
    800021da:	557d                	li	a0,-1
    800021dc:	a819                	j	800021f2 <kkill+0x52>
      p->killed = 1;
    800021de:	4785                	li	a5,1
    800021e0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021e2:	4c98                	lw	a4,24(s1)
    800021e4:	4789                	li	a5,2
    800021e6:	00f70d63          	beq	a4,a5,80002200 <kkill+0x60>
      release(&p->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	ad1fe0ef          	jal	80000cbc <release>
      return 0;
    800021f0:	4501                	li	a0,0
}
    800021f2:	70a2                	ld	ra,40(sp)
    800021f4:	7402                	ld	s0,32(sp)
    800021f6:	64e2                	ld	s1,24(sp)
    800021f8:	6942                	ld	s2,16(sp)
    800021fa:	69a2                	ld	s3,8(sp)
    800021fc:	6145                	addi	sp,sp,48
    800021fe:	8082                	ret
        p->state = RUNNABLE;
    80002200:	478d                	li	a5,3
    80002202:	cc9c                	sw	a5,24(s1)
    80002204:	b7dd                	j	800021ea <kkill+0x4a>

0000000080002206 <setkilled>:

void
setkilled(struct proc *p)
{
    80002206:	1101                	addi	sp,sp,-32
    80002208:	ec06                	sd	ra,24(sp)
    8000220a:	e822                	sd	s0,16(sp)
    8000220c:	e426                	sd	s1,8(sp)
    8000220e:	1000                	addi	s0,sp,32
    80002210:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002212:	a17fe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002216:	4785                	li	a5,1
    80002218:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	aa1fe0ef          	jal	80000cbc <release>
}
    80002220:	60e2                	ld	ra,24(sp)
    80002222:	6442                	ld	s0,16(sp)
    80002224:	64a2                	ld	s1,8(sp)
    80002226:	6105                	addi	sp,sp,32
    80002228:	8082                	ret

000000008000222a <killed>:

int
killed(struct proc *p)
{
    8000222a:	1101                	addi	sp,sp,-32
    8000222c:	ec06                	sd	ra,24(sp)
    8000222e:	e822                	sd	s0,16(sp)
    80002230:	e426                	sd	s1,8(sp)
    80002232:	e04a                	sd	s2,0(sp)
    80002234:	1000                	addi	s0,sp,32
    80002236:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002238:	9f1fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    8000223c:	549c                	lw	a5,40(s1)
    8000223e:	893e                	mv	s2,a5
  release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	a7bfe0ef          	jal	80000cbc <release>
  return k;
}
    80002246:	854a                	mv	a0,s2
    80002248:	60e2                	ld	ra,24(sp)
    8000224a:	6442                	ld	s0,16(sp)
    8000224c:	64a2                	ld	s1,8(sp)
    8000224e:	6902                	ld	s2,0(sp)
    80002250:	6105                	addi	sp,sp,32
    80002252:	8082                	ret

0000000080002254 <kwait>:
{
    80002254:	715d                	addi	sp,sp,-80
    80002256:	e486                	sd	ra,72(sp)
    80002258:	e0a2                	sd	s0,64(sp)
    8000225a:	fc26                	sd	s1,56(sp)
    8000225c:	f84a                	sd	s2,48(sp)
    8000225e:	f44e                	sd	s3,40(sp)
    80002260:	f052                	sd	s4,32(sp)
    80002262:	ec56                	sd	s5,24(sp)
    80002264:	e85a                	sd	s6,16(sp)
    80002266:	e45e                	sd	s7,8(sp)
    80002268:	0880                	addi	s0,sp,80
    8000226a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000226c:	ec2ff0ef          	jal	8000192e <myproc>
    80002270:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002272:	0000d517          	auipc	a0,0xd
    80002276:	7fe50513          	addi	a0,a0,2046 # 8000fa70 <wait_lock>
    8000227a:	9affe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000227e:	4a15                	li	s4,5
        havekids = 1;
    80002280:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002282:	00013997          	auipc	s3,0x13
    80002286:	60698993          	addi	s3,s3,1542 # 80015888 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000228a:	0000db17          	auipc	s6,0xd
    8000228e:	7e6b0b13          	addi	s6,s6,2022 # 8000fa70 <wait_lock>
    80002292:	a869                	j	8000232c <kwait+0xd8>
          pid = pp->pid;
    80002294:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002298:	000b8c63          	beqz	s7,800022b0 <kwait+0x5c>
    8000229c:	4691                	li	a3,4
    8000229e:	02c48613          	addi	a2,s1,44
    800022a2:	85de                	mv	a1,s7
    800022a4:	05093503          	ld	a0,80(s2)
    800022a8:	bacff0ef          	jal	80001654 <copyout>
    800022ac:	02054a63          	bltz	a0,800022e0 <kwait+0x8c>
          freeproc(pp);
    800022b0:	8526                	mv	a0,s1
    800022b2:	851ff0ef          	jal	80001b02 <freeproc>
          release(&pp->lock);
    800022b6:	8526                	mv	a0,s1
    800022b8:	a05fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    800022bc:	0000d517          	auipc	a0,0xd
    800022c0:	7b450513          	addi	a0,a0,1972 # 8000fa70 <wait_lock>
    800022c4:	9f9fe0ef          	jal	80000cbc <release>
}
    800022c8:	854e                	mv	a0,s3
    800022ca:	60a6                	ld	ra,72(sp)
    800022cc:	6406                	ld	s0,64(sp)
    800022ce:	74e2                	ld	s1,56(sp)
    800022d0:	7942                	ld	s2,48(sp)
    800022d2:	79a2                	ld	s3,40(sp)
    800022d4:	7a02                	ld	s4,32(sp)
    800022d6:	6ae2                	ld	s5,24(sp)
    800022d8:	6b42                	ld	s6,16(sp)
    800022da:	6ba2                	ld	s7,8(sp)
    800022dc:	6161                	addi	sp,sp,80
    800022de:	8082                	ret
            release(&pp->lock);
    800022e0:	8526                	mv	a0,s1
    800022e2:	9dbfe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    800022e6:	0000d517          	auipc	a0,0xd
    800022ea:	78a50513          	addi	a0,a0,1930 # 8000fa70 <wait_lock>
    800022ee:	9cffe0ef          	jal	80000cbc <release>
            return -1;
    800022f2:	59fd                	li	s3,-1
    800022f4:	bfd1                	j	800022c8 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022f6:	16848493          	addi	s1,s1,360
    800022fa:	03348063          	beq	s1,s3,8000231a <kwait+0xc6>
      if(pp->parent == p){
    800022fe:	7c9c                	ld	a5,56(s1)
    80002300:	ff279be3          	bne	a5,s2,800022f6 <kwait+0xa2>
        acquire(&pp->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	923fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    8000230a:	4c9c                	lw	a5,24(s1)
    8000230c:	f94784e3          	beq	a5,s4,80002294 <kwait+0x40>
        release(&pp->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	9abfe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002316:	8756                	mv	a4,s5
    80002318:	bff9                	j	800022f6 <kwait+0xa2>
    if(!havekids || killed(p)){
    8000231a:	cf19                	beqz	a4,80002338 <kwait+0xe4>
    8000231c:	854a                	mv	a0,s2
    8000231e:	f0dff0ef          	jal	8000222a <killed>
    80002322:	e919                	bnez	a0,80002338 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002324:	85da                	mv	a1,s6
    80002326:	854a                	mv	a0,s2
    80002328:	cc7ff0ef          	jal	80001fee <sleep>
    havekids = 0;
    8000232c:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000232e:	0000e497          	auipc	s1,0xe
    80002332:	b5a48493          	addi	s1,s1,-1190 # 8000fe88 <proc>
    80002336:	b7e1                	j	800022fe <kwait+0xaa>
      release(&wait_lock);
    80002338:	0000d517          	auipc	a0,0xd
    8000233c:	73850513          	addi	a0,a0,1848 # 8000fa70 <wait_lock>
    80002340:	97dfe0ef          	jal	80000cbc <release>
      return -1;
    80002344:	59fd                	li	s3,-1
    80002346:	b749                	j	800022c8 <kwait+0x74>

0000000080002348 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002348:	7179                	addi	sp,sp,-48
    8000234a:	f406                	sd	ra,40(sp)
    8000234c:	f022                	sd	s0,32(sp)
    8000234e:	ec26                	sd	s1,24(sp)
    80002350:	e84a                	sd	s2,16(sp)
    80002352:	e44e                	sd	s3,8(sp)
    80002354:	e052                	sd	s4,0(sp)
    80002356:	1800                	addi	s0,sp,48
    80002358:	84aa                	mv	s1,a0
    8000235a:	8a2e                	mv	s4,a1
    8000235c:	89b2                	mv	s3,a2
    8000235e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002360:	dceff0ef          	jal	8000192e <myproc>
  if(user_dst){
    80002364:	cc99                	beqz	s1,80002382 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002366:	86ca                	mv	a3,s2
    80002368:	864e                	mv	a2,s3
    8000236a:	85d2                	mv	a1,s4
    8000236c:	6928                	ld	a0,80(a0)
    8000236e:	ae6ff0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002372:	70a2                	ld	ra,40(sp)
    80002374:	7402                	ld	s0,32(sp)
    80002376:	64e2                	ld	s1,24(sp)
    80002378:	6942                	ld	s2,16(sp)
    8000237a:	69a2                	ld	s3,8(sp)
    8000237c:	6a02                	ld	s4,0(sp)
    8000237e:	6145                	addi	sp,sp,48
    80002380:	8082                	ret
    memmove((char *)dst, src, len);
    80002382:	0009061b          	sext.w	a2,s2
    80002386:	85ce                	mv	a1,s3
    80002388:	8552                	mv	a0,s4
    8000238a:	9cffe0ef          	jal	80000d58 <memmove>
    return 0;
    8000238e:	8526                	mv	a0,s1
    80002390:	b7cd                	j	80002372 <either_copyout+0x2a>

0000000080002392 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002392:	7179                	addi	sp,sp,-48
    80002394:	f406                	sd	ra,40(sp)
    80002396:	f022                	sd	s0,32(sp)
    80002398:	ec26                	sd	s1,24(sp)
    8000239a:	e84a                	sd	s2,16(sp)
    8000239c:	e44e                	sd	s3,8(sp)
    8000239e:	e052                	sd	s4,0(sp)
    800023a0:	1800                	addi	s0,sp,48
    800023a2:	8a2a                	mv	s4,a0
    800023a4:	84ae                	mv	s1,a1
    800023a6:	89b2                	mv	s3,a2
    800023a8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023aa:	d84ff0ef          	jal	8000192e <myproc>
  if(user_src){
    800023ae:	cc99                	beqz	s1,800023cc <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800023b0:	86ca                	mv	a3,s2
    800023b2:	864e                	mv	a2,s3
    800023b4:	85d2                	mv	a1,s4
    800023b6:	6928                	ld	a0,80(a0)
    800023b8:	b5aff0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800023bc:	70a2                	ld	ra,40(sp)
    800023be:	7402                	ld	s0,32(sp)
    800023c0:	64e2                	ld	s1,24(sp)
    800023c2:	6942                	ld	s2,16(sp)
    800023c4:	69a2                	ld	s3,8(sp)
    800023c6:	6a02                	ld	s4,0(sp)
    800023c8:	6145                	addi	sp,sp,48
    800023ca:	8082                	ret
    memmove(dst, (char*)src, len);
    800023cc:	0009061b          	sext.w	a2,s2
    800023d0:	85ce                	mv	a1,s3
    800023d2:	8552                	mv	a0,s4
    800023d4:	985fe0ef          	jal	80000d58 <memmove>
    return 0;
    800023d8:	8526                	mv	a0,s1
    800023da:	b7cd                	j	800023bc <either_copyin+0x2a>

00000000800023dc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023dc:	715d                	addi	sp,sp,-80
    800023de:	e486                	sd	ra,72(sp)
    800023e0:	e0a2                	sd	s0,64(sp)
    800023e2:	fc26                	sd	s1,56(sp)
    800023e4:	f84a                	sd	s2,48(sp)
    800023e6:	f44e                	sd	s3,40(sp)
    800023e8:	f052                	sd	s4,32(sp)
    800023ea:	ec56                	sd	s5,24(sp)
    800023ec:	e85a                	sd	s6,16(sp)
    800023ee:	e45e                	sd	s7,8(sp)
    800023f0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800023f2:	00005517          	auipc	a0,0x5
    800023f6:	c8650513          	addi	a0,a0,-890 # 80007078 <etext+0x78>
    800023fa:	900fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023fe:	0000e497          	auipc	s1,0xe
    80002402:	be248493          	addi	s1,s1,-1054 # 8000ffe0 <proc+0x158>
    80002406:	00013917          	auipc	s2,0x13
    8000240a:	5da90913          	addi	s2,s2,1498 # 800159e0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000240e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002410:	00005997          	auipc	s3,0x5
    80002414:	e0098993          	addi	s3,s3,-512 # 80007210 <etext+0x210>
    printf("%d %s %s", p->pid, state, p->name);
    80002418:	00005a97          	auipc	s5,0x5
    8000241c:	e00a8a93          	addi	s5,s5,-512 # 80007218 <etext+0x218>
    printf("\n");
    80002420:	00005a17          	auipc	s4,0x5
    80002424:	c58a0a13          	addi	s4,s4,-936 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002428:	00005b97          	auipc	s7,0x5
    8000242c:	3c8b8b93          	addi	s7,s7,968 # 800077f0 <states.1>
    80002430:	a829                	j	8000244a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002432:	ed86a583          	lw	a1,-296(a3)
    80002436:	8556                	mv	a0,s5
    80002438:	8c2fe0ef          	jal	800004fa <printf>
    printf("\n");
    8000243c:	8552                	mv	a0,s4
    8000243e:	8bcfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002442:	16848493          	addi	s1,s1,360
    80002446:	03248263          	beq	s1,s2,8000246a <procdump+0x8e>
    if(p->state == UNUSED)
    8000244a:	86a6                	mv	a3,s1
    8000244c:	ec04a783          	lw	a5,-320(s1)
    80002450:	dbed                	beqz	a5,80002442 <procdump+0x66>
      state = "???";
    80002452:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002454:	fcfb6fe3          	bltu	s6,a5,80002432 <procdump+0x56>
    80002458:	02079713          	slli	a4,a5,0x20
    8000245c:	01d75793          	srli	a5,a4,0x1d
    80002460:	97de                	add	a5,a5,s7
    80002462:	6390                	ld	a2,0(a5)
    80002464:	f679                	bnez	a2,80002432 <procdump+0x56>
      state = "???";
    80002466:	864e                	mv	a2,s3
    80002468:	b7e9                	j	80002432 <procdump+0x56>
  }
}
    8000246a:	60a6                	ld	ra,72(sp)
    8000246c:	6406                	ld	s0,64(sp)
    8000246e:	74e2                	ld	s1,56(sp)
    80002470:	7942                	ld	s2,48(sp)
    80002472:	79a2                	ld	s3,40(sp)
    80002474:	7a02                	ld	s4,32(sp)
    80002476:	6ae2                	ld	s5,24(sp)
    80002478:	6b42                	ld	s6,16(sp)
    8000247a:	6ba2                	ld	s7,8(sp)
    8000247c:	6161                	addi	sp,sp,80
    8000247e:	8082                	ret

0000000080002480 <kps>:


int
kps(char *arguments)
{
    80002480:	7179                	addi	sp,sp,-48
    80002482:	f406                	sd	ra,40(sp)
    80002484:	f022                	sd	s0,32(sp)
    80002486:	ec26                	sd	s1,24(sp)
    80002488:	1800                	addi	s0,sp,48
    8000248a:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    8000248c:	4609                	li	a2,2
    8000248e:	00005597          	auipc	a1,0x5
    80002492:	d9a58593          	addi	a1,a1,-614 # 80007228 <etext+0x228>
    80002496:	937fe0ef          	jal	80000dcc <strncmp>
    8000249a:	e931                	bnez	a0,800024ee <kps+0x6e>
    8000249c:	e84a                	sd	s2,16(sp)
    8000249e:	e44e                	sd	s3,8(sp)
    800024a0:	0000e497          	auipc	s1,0xe
    800024a4:	b4048493          	addi	s1,s1,-1216 # 8000ffe0 <proc+0x158>
    800024a8:	00013917          	auipc	s2,0x13
    800024ac:	53890913          	addi	s2,s2,1336 # 800159e0 <bcache+0x140>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    800024b0:	00005997          	auipc	s3,0x5
    800024b4:	d8098993          	addi	s3,s3,-640 # 80007230 <etext+0x230>
    800024b8:	a029                	j	800024c2 <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    800024ba:	16848493          	addi	s1,s1,360
    800024be:	01248a63          	beq	s1,s2,800024d2 <kps+0x52>
      if (p->state != UNUSED){
    800024c2:	ec04a783          	lw	a5,-320(s1)
    800024c6:	dbf5                	beqz	a5,800024ba <kps+0x3a>
        printf("%s ", p->name);
    800024c8:	85a6                	mv	a1,s1
    800024ca:	854e                	mv	a0,s3
    800024cc:	82efe0ef          	jal	800004fa <printf>
    800024d0:	b7ed                	j	800024ba <kps+0x3a>
      }
    }
    printf("\n");
    800024d2:	00005517          	auipc	a0,0x5
    800024d6:	ba650513          	addi	a0,a0,-1114 # 80007078 <etext+0x78>
    800024da:	820fe0ef          	jal	800004fa <printf>
    800024de:	6942                	ld	s2,16(sp)
    800024e0:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l]\n");
  }

  return 0;

    800024e2:	4501                	li	a0,0
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6145                	addi	sp,sp,48
    800024ec:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    800024ee:	4609                	li	a2,2
    800024f0:	00005597          	auipc	a1,0x5
    800024f4:	d4858593          	addi	a1,a1,-696 # 80007238 <etext+0x238>
    800024f8:	8526                	mv	a0,s1
    800024fa:	8d3fe0ef          	jal	80000dcc <strncmp>
    800024fe:	e92d                	bnez	a0,80002570 <kps+0xf0>
    80002500:	e84a                	sd	s2,16(sp)
    80002502:	e44e                	sd	s3,8(sp)
    80002504:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    80002506:	00005517          	auipc	a0,0x5
    8000250a:	d3a50513          	addi	a0,a0,-710 # 80007240 <etext+0x240>
    8000250e:	fedfd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    80002512:	00005517          	auipc	a0,0x5
    80002516:	d4650513          	addi	a0,a0,-698 # 80007258 <etext+0x258>
    8000251a:	fe1fd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    8000251e:	0000e497          	auipc	s1,0xe
    80002522:	ac248493          	addi	s1,s1,-1342 # 8000ffe0 <proc+0x158>
    80002526:	00013917          	auipc	s2,0x13
    8000252a:	4ba90913          	addi	s2,s2,1210 # 800159e0 <bcache+0x140>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    8000252e:	00005a17          	auipc	s4,0x5
    80002532:	2c2a0a13          	addi	s4,s4,706 # 800077f0 <states.1>
    80002536:	00005997          	auipc	s3,0x5
    8000253a:	d4a98993          	addi	s3,s3,-694 # 80007280 <etext+0x280>
    8000253e:	a029                	j	80002548 <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    80002540:	16848493          	addi	s1,s1,360
    80002544:	03248263          	beq	s1,s2,80002568 <kps+0xe8>
      if (p->state != UNUSED){
    80002548:	ec04a783          	lw	a5,-320(s1)
    8000254c:	dbf5                	beqz	a5,80002540 <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    8000254e:	02079713          	slli	a4,a5,0x20
    80002552:	01d75793          	srli	a5,a4,0x1d
    80002556:	97d2                	add	a5,a5,s4
    80002558:	86a6                	mv	a3,s1
    8000255a:	7b90                	ld	a2,48(a5)
    8000255c:	ed84a583          	lw	a1,-296(s1)
    80002560:	854e                	mv	a0,s3
    80002562:	f99fd0ef          	jal	800004fa <printf>
    80002566:	bfe9                	j	80002540 <kps+0xc0>
    80002568:	6942                	ld	s2,16(sp)
    8000256a:	69a2                	ld	s3,8(sp)
    8000256c:	6a02                	ld	s4,0(sp)
    8000256e:	bf95                	j	800024e2 <kps+0x62>
    printf("Usage: ps [-o | -l]\n");
    80002570:	00005517          	auipc	a0,0x5
    80002574:	d2050513          	addi	a0,a0,-736 # 80007290 <etext+0x290>
    80002578:	f83fd0ef          	jal	800004fa <printf>
    8000257c:	b79d                	j	800024e2 <kps+0x62>

000000008000257e <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000257e:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002582:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002586:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002588:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000258a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000258e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002592:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002596:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000259a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000259e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025a2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025a6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025aa:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025ae:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800025b2:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800025b6:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800025ba:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800025bc:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800025be:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800025c2:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800025c6:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800025ca:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800025ce:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800025d2:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800025d6:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800025da:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800025de:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800025e2:	0685bd83          	ld	s11,104(a1)
        
        ret
    800025e6:	8082                	ret

00000000800025e8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025e8:	1141                	addi	sp,sp,-16
    800025ea:	e406                	sd	ra,8(sp)
    800025ec:	e022                	sd	s0,0(sp)
    800025ee:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800025f0:	00005597          	auipc	a1,0x5
    800025f4:	d2858593          	addi	a1,a1,-728 # 80007318 <etext+0x318>
    800025f8:	00013517          	auipc	a0,0x13
    800025fc:	29050513          	addi	a0,a0,656 # 80015888 <tickslock>
    80002600:	d9efe0ef          	jal	80000b9e <initlock>
}
    80002604:	60a2                	ld	ra,8(sp)
    80002606:	6402                	ld	s0,0(sp)
    80002608:	0141                	addi	sp,sp,16
    8000260a:	8082                	ret

000000008000260c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000260c:	1141                	addi	sp,sp,-16
    8000260e:	e406                	sd	ra,8(sp)
    80002610:	e022                	sd	s0,0(sp)
    80002612:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002614:	00003797          	auipc	a5,0x3
    80002618:	00c78793          	addi	a5,a5,12 # 80005620 <kernelvec>
    8000261c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002620:	60a2                	ld	ra,8(sp)
    80002622:	6402                	ld	s0,0(sp)
    80002624:	0141                	addi	sp,sp,16
    80002626:	8082                	ret

0000000080002628 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002628:	1141                	addi	sp,sp,-16
    8000262a:	e406                	sd	ra,8(sp)
    8000262c:	e022                	sd	s0,0(sp)
    8000262e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002630:	afeff0ef          	jal	8000192e <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002634:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002638:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000263a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000263e:	04000737          	lui	a4,0x4000
    80002642:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002644:	0732                	slli	a4,a4,0xc
    80002646:	00004797          	auipc	a5,0x4
    8000264a:	9ba78793          	addi	a5,a5,-1606 # 80006000 <_trampoline>
    8000264e:	00004697          	auipc	a3,0x4
    80002652:	9b268693          	addi	a3,a3,-1614 # 80006000 <_trampoline>
    80002656:	8f95                	sub	a5,a5,a3
    80002658:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000265a:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000265e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002660:	18002773          	csrr	a4,satp
    80002664:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002666:	6d38                	ld	a4,88(a0)
    80002668:	613c                	ld	a5,64(a0)
    8000266a:	6685                	lui	a3,0x1
    8000266c:	97b6                	add	a5,a5,a3
    8000266e:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002670:	6d3c                	ld	a5,88(a0)
    80002672:	00000717          	auipc	a4,0x0
    80002676:	0fc70713          	addi	a4,a4,252 # 8000276e <usertrap>
    8000267a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000267c:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000267e:	8712                	mv	a4,tp
    80002680:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002682:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002686:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000268a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002692:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002694:	6f9c                	ld	a5,24(a5)
    80002696:	14179073          	csrw	sepc,a5
}
    8000269a:	60a2                	ld	ra,8(sp)
    8000269c:	6402                	ld	s0,0(sp)
    8000269e:	0141                	addi	sp,sp,16
    800026a0:	8082                	ret

00000000800026a2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026a2:	1141                	addi	sp,sp,-16
    800026a4:	e406                	sd	ra,8(sp)
    800026a6:	e022                	sd	s0,0(sp)
    800026a8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800026aa:	a50ff0ef          	jal	800018fa <cpuid>
    800026ae:	cd11                	beqz	a0,800026ca <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800026b0:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800026b4:	000f4737          	lui	a4,0xf4
    800026b8:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800026bc:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800026be:	14d79073          	csrw	stimecmp,a5
}
    800026c2:	60a2                	ld	ra,8(sp)
    800026c4:	6402                	ld	s0,0(sp)
    800026c6:	0141                	addi	sp,sp,16
    800026c8:	8082                	ret
    acquire(&tickslock);
    800026ca:	00013517          	auipc	a0,0x13
    800026ce:	1be50513          	addi	a0,a0,446 # 80015888 <tickslock>
    800026d2:	d56fe0ef          	jal	80000c28 <acquire>
    ticks++;
    800026d6:	00005717          	auipc	a4,0x5
    800026da:	28270713          	addi	a4,a4,642 # 80007958 <ticks>
    800026de:	431c                	lw	a5,0(a4)
    800026e0:	2785                	addiw	a5,a5,1
    800026e2:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800026e4:	853a                	mv	a0,a4
    800026e6:	955ff0ef          	jal	8000203a <wakeup>
    release(&tickslock);
    800026ea:	00013517          	auipc	a0,0x13
    800026ee:	19e50513          	addi	a0,a0,414 # 80015888 <tickslock>
    800026f2:	dcafe0ef          	jal	80000cbc <release>
    800026f6:	bf6d                	j	800026b0 <clockintr+0xe>

00000000800026f8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800026f8:	1101                	addi	sp,sp,-32
    800026fa:	ec06                	sd	ra,24(sp)
    800026fc:	e822                	sd	s0,16(sp)
    800026fe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002700:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002704:	57fd                	li	a5,-1
    80002706:	17fe                	slli	a5,a5,0x3f
    80002708:	07a5                	addi	a5,a5,9
    8000270a:	00f70c63          	beq	a4,a5,80002722 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000270e:	57fd                	li	a5,-1
    80002710:	17fe                	slli	a5,a5,0x3f
    80002712:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002714:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002716:	04f70863          	beq	a4,a5,80002766 <devintr+0x6e>
  }
}
    8000271a:	60e2                	ld	ra,24(sp)
    8000271c:	6442                	ld	s0,16(sp)
    8000271e:	6105                	addi	sp,sp,32
    80002720:	8082                	ret
    80002722:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002724:	7a9020ef          	jal	800056cc <plic_claim>
    80002728:	872a                	mv	a4,a0
    8000272a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000272c:	47a9                	li	a5,10
    8000272e:	00f50963          	beq	a0,a5,80002740 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002732:	4785                	li	a5,1
    80002734:	00f50963          	beq	a0,a5,80002746 <devintr+0x4e>
    return 1;
    80002738:	4505                	li	a0,1
    } else if(irq){
    8000273a:	eb09                	bnez	a4,8000274c <devintr+0x54>
    8000273c:	64a2                	ld	s1,8(sp)
    8000273e:	bff1                	j	8000271a <devintr+0x22>
      uartintr();
    80002740:	ab4fe0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002744:	a819                	j	8000275a <devintr+0x62>
      virtio_disk_intr();
    80002746:	41c030ef          	jal	80005b62 <virtio_disk_intr>
    if(irq)
    8000274a:	a801                	j	8000275a <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000274c:	85ba                	mv	a1,a4
    8000274e:	00005517          	auipc	a0,0x5
    80002752:	bd250513          	addi	a0,a0,-1070 # 80007320 <etext+0x320>
    80002756:	da5fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000275a:	8526                	mv	a0,s1
    8000275c:	791020ef          	jal	800056ec <plic_complete>
    return 1;
    80002760:	4505                	li	a0,1
    80002762:	64a2                	ld	s1,8(sp)
    80002764:	bf5d                	j	8000271a <devintr+0x22>
    clockintr();
    80002766:	f3dff0ef          	jal	800026a2 <clockintr>
    return 2;
    8000276a:	4509                	li	a0,2
    8000276c:	b77d                	j	8000271a <devintr+0x22>

000000008000276e <usertrap>:
{
    8000276e:	1101                	addi	sp,sp,-32
    80002770:	ec06                	sd	ra,24(sp)
    80002772:	e822                	sd	s0,16(sp)
    80002774:	e426                	sd	s1,8(sp)
    80002776:	e04a                	sd	s2,0(sp)
    80002778:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000277a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000277e:	1007f793          	andi	a5,a5,256
    80002782:	eba5                	bnez	a5,800027f2 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002784:	00003797          	auipc	a5,0x3
    80002788:	e9c78793          	addi	a5,a5,-356 # 80005620 <kernelvec>
    8000278c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002790:	99eff0ef          	jal	8000192e <myproc>
    80002794:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002796:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002798:	14102773          	csrr	a4,sepc
    8000279c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000279e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027a2:	47a1                	li	a5,8
    800027a4:	04f70d63          	beq	a4,a5,800027fe <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800027a8:	f51ff0ef          	jal	800026f8 <devintr>
    800027ac:	892a                	mv	s2,a0
    800027ae:	e945                	bnez	a0,8000285e <usertrap+0xf0>
    800027b0:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800027b4:	47bd                	li	a5,15
    800027b6:	08f70863          	beq	a4,a5,80002846 <usertrap+0xd8>
    800027ba:	14202773          	csrr	a4,scause
    800027be:	47b5                	li	a5,13
    800027c0:	08f70363          	beq	a4,a5,80002846 <usertrap+0xd8>
    800027c4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800027c8:	5890                	lw	a2,48(s1)
    800027ca:	00005517          	auipc	a0,0x5
    800027ce:	b9650513          	addi	a0,a0,-1130 # 80007360 <etext+0x360>
    800027d2:	d29fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027d6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027da:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800027de:	00005517          	auipc	a0,0x5
    800027e2:	bb250513          	addi	a0,a0,-1102 # 80007390 <etext+0x390>
    800027e6:	d15fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800027ea:	8526                	mv	a0,s1
    800027ec:	a1bff0ef          	jal	80002206 <setkilled>
    800027f0:	a035                	j	8000281c <usertrap+0xae>
    panic("usertrap: not from user mode");
    800027f2:	00005517          	auipc	a0,0x5
    800027f6:	b4e50513          	addi	a0,a0,-1202 # 80007340 <etext+0x340>
    800027fa:	82afe0ef          	jal	80000824 <panic>
    if(killed(p))
    800027fe:	a2dff0ef          	jal	8000222a <killed>
    80002802:	ed15                	bnez	a0,8000283e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002804:	6cb8                	ld	a4,88(s1)
    80002806:	6f1c                	ld	a5,24(a4)
    80002808:	0791                	addi	a5,a5,4
    8000280a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000280c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002810:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002814:	10079073          	csrw	sstatus,a5
    syscall();
    80002818:	240000ef          	jal	80002a58 <syscall>
  if(killed(p))
    8000281c:	8526                	mv	a0,s1
    8000281e:	a0dff0ef          	jal	8000222a <killed>
    80002822:	e139                	bnez	a0,80002868 <usertrap+0xfa>
  prepare_return();
    80002824:	e05ff0ef          	jal	80002628 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002828:	68a8                	ld	a0,80(s1)
    8000282a:	8131                	srli	a0,a0,0xc
    8000282c:	57fd                	li	a5,-1
    8000282e:	17fe                	slli	a5,a5,0x3f
    80002830:	8d5d                	or	a0,a0,a5
}
    80002832:	60e2                	ld	ra,24(sp)
    80002834:	6442                	ld	s0,16(sp)
    80002836:	64a2                	ld	s1,8(sp)
    80002838:	6902                	ld	s2,0(sp)
    8000283a:	6105                	addi	sp,sp,32
    8000283c:	8082                	ret
      kexit(-1);
    8000283e:	557d                	li	a0,-1
    80002840:	8bbff0ef          	jal	800020fa <kexit>
    80002844:	b7c1                	j	80002804 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002846:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000284a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000284e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002850:	00163613          	seqz	a2,a2
    80002854:	68a8                	ld	a0,80(s1)
    80002856:	d7bfe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000285a:	f169                	bnez	a0,8000281c <usertrap+0xae>
    8000285c:	b7a5                	j	800027c4 <usertrap+0x56>
  if(killed(p))
    8000285e:	8526                	mv	a0,s1
    80002860:	9cbff0ef          	jal	8000222a <killed>
    80002864:	c511                	beqz	a0,80002870 <usertrap+0x102>
    80002866:	a011                	j	8000286a <usertrap+0xfc>
    80002868:	4901                	li	s2,0
    kexit(-1);
    8000286a:	557d                	li	a0,-1
    8000286c:	88fff0ef          	jal	800020fa <kexit>
  if(which_dev == 2)
    80002870:	4789                	li	a5,2
    80002872:	faf919e3          	bne	s2,a5,80002824 <usertrap+0xb6>
    yield();
    80002876:	f4cff0ef          	jal	80001fc2 <yield>
    8000287a:	b76d                	j	80002824 <usertrap+0xb6>

000000008000287c <kerneltrap>:
{
    8000287c:	7179                	addi	sp,sp,-48
    8000287e:	f406                	sd	ra,40(sp)
    80002880:	f022                	sd	s0,32(sp)
    80002882:	ec26                	sd	s1,24(sp)
    80002884:	e84a                	sd	s2,16(sp)
    80002886:	e44e                	sd	s3,8(sp)
    80002888:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000288a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000288e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002892:	142027f3          	csrr	a5,scause
    80002896:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002898:	1004f793          	andi	a5,s1,256
    8000289c:	c795                	beqz	a5,800028c8 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000289e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028a2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028a4:	eb85                	bnez	a5,800028d4 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800028a6:	e53ff0ef          	jal	800026f8 <devintr>
    800028aa:	c91d                	beqz	a0,800028e0 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800028ac:	4789                	li	a5,2
    800028ae:	04f50a63          	beq	a0,a5,80002902 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028b2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028b6:	10049073          	csrw	sstatus,s1
}
    800028ba:	70a2                	ld	ra,40(sp)
    800028bc:	7402                	ld	s0,32(sp)
    800028be:	64e2                	ld	s1,24(sp)
    800028c0:	6942                	ld	s2,16(sp)
    800028c2:	69a2                	ld	s3,8(sp)
    800028c4:	6145                	addi	sp,sp,48
    800028c6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028c8:	00005517          	auipc	a0,0x5
    800028cc:	af050513          	addi	a0,a0,-1296 # 800073b8 <etext+0x3b8>
    800028d0:	f55fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    800028d4:	00005517          	auipc	a0,0x5
    800028d8:	b0c50513          	addi	a0,a0,-1268 # 800073e0 <etext+0x3e0>
    800028dc:	f49fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028e4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800028e8:	85ce                	mv	a1,s3
    800028ea:	00005517          	auipc	a0,0x5
    800028ee:	b1650513          	addi	a0,a0,-1258 # 80007400 <etext+0x400>
    800028f2:	c09fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800028f6:	00005517          	auipc	a0,0x5
    800028fa:	b3250513          	addi	a0,a0,-1230 # 80007428 <etext+0x428>
    800028fe:	f27fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002902:	82cff0ef          	jal	8000192e <myproc>
    80002906:	d555                	beqz	a0,800028b2 <kerneltrap+0x36>
    yield();
    80002908:	ebaff0ef          	jal	80001fc2 <yield>
    8000290c:	b75d                	j	800028b2 <kerneltrap+0x36>

000000008000290e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000290e:	1101                	addi	sp,sp,-32
    80002910:	ec06                	sd	ra,24(sp)
    80002912:	e822                	sd	s0,16(sp)
    80002914:	e426                	sd	s1,8(sp)
    80002916:	1000                	addi	s0,sp,32
    80002918:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000291a:	814ff0ef          	jal	8000192e <myproc>
  switch (n) {
    8000291e:	4795                	li	a5,5
    80002920:	0497e163          	bltu	a5,s1,80002962 <argraw+0x54>
    80002924:	048a                	slli	s1,s1,0x2
    80002926:	00005717          	auipc	a4,0x5
    8000292a:	f2a70713          	addi	a4,a4,-214 # 80007850 <states.0+0x30>
    8000292e:	94ba                	add	s1,s1,a4
    80002930:	409c                	lw	a5,0(s1)
    80002932:	97ba                	add	a5,a5,a4
    80002934:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002936:	6d3c                	ld	a5,88(a0)
    80002938:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000293a:	60e2                	ld	ra,24(sp)
    8000293c:	6442                	ld	s0,16(sp)
    8000293e:	64a2                	ld	s1,8(sp)
    80002940:	6105                	addi	sp,sp,32
    80002942:	8082                	ret
    return p->trapframe->a1;
    80002944:	6d3c                	ld	a5,88(a0)
    80002946:	7fa8                	ld	a0,120(a5)
    80002948:	bfcd                	j	8000293a <argraw+0x2c>
    return p->trapframe->a2;
    8000294a:	6d3c                	ld	a5,88(a0)
    8000294c:	63c8                	ld	a0,128(a5)
    8000294e:	b7f5                	j	8000293a <argraw+0x2c>
    return p->trapframe->a3;
    80002950:	6d3c                	ld	a5,88(a0)
    80002952:	67c8                	ld	a0,136(a5)
    80002954:	b7dd                	j	8000293a <argraw+0x2c>
    return p->trapframe->a4;
    80002956:	6d3c                	ld	a5,88(a0)
    80002958:	6bc8                	ld	a0,144(a5)
    8000295a:	b7c5                	j	8000293a <argraw+0x2c>
    return p->trapframe->a5;
    8000295c:	6d3c                	ld	a5,88(a0)
    8000295e:	6fc8                	ld	a0,152(a5)
    80002960:	bfe9                	j	8000293a <argraw+0x2c>
  panic("argraw");
    80002962:	00005517          	auipc	a0,0x5
    80002966:	ad650513          	addi	a0,a0,-1322 # 80007438 <etext+0x438>
    8000296a:	ebbfd0ef          	jal	80000824 <panic>

000000008000296e <fetchaddr>:
{
    8000296e:	1101                	addi	sp,sp,-32
    80002970:	ec06                	sd	ra,24(sp)
    80002972:	e822                	sd	s0,16(sp)
    80002974:	e426                	sd	s1,8(sp)
    80002976:	e04a                	sd	s2,0(sp)
    80002978:	1000                	addi	s0,sp,32
    8000297a:	84aa                	mv	s1,a0
    8000297c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000297e:	fb1fe0ef          	jal	8000192e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002982:	653c                	ld	a5,72(a0)
    80002984:	02f4f663          	bgeu	s1,a5,800029b0 <fetchaddr+0x42>
    80002988:	00848713          	addi	a4,s1,8
    8000298c:	02e7e463          	bltu	a5,a4,800029b4 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002990:	46a1                	li	a3,8
    80002992:	8626                	mv	a2,s1
    80002994:	85ca                	mv	a1,s2
    80002996:	6928                	ld	a0,80(a0)
    80002998:	d7bfe0ef          	jal	80001712 <copyin>
    8000299c:	00a03533          	snez	a0,a0
    800029a0:	40a0053b          	negw	a0,a0
}
    800029a4:	60e2                	ld	ra,24(sp)
    800029a6:	6442                	ld	s0,16(sp)
    800029a8:	64a2                	ld	s1,8(sp)
    800029aa:	6902                	ld	s2,0(sp)
    800029ac:	6105                	addi	sp,sp,32
    800029ae:	8082                	ret
    return -1;
    800029b0:	557d                	li	a0,-1
    800029b2:	bfcd                	j	800029a4 <fetchaddr+0x36>
    800029b4:	557d                	li	a0,-1
    800029b6:	b7fd                	j	800029a4 <fetchaddr+0x36>

00000000800029b8 <fetchstr>:
{
    800029b8:	7179                	addi	sp,sp,-48
    800029ba:	f406                	sd	ra,40(sp)
    800029bc:	f022                	sd	s0,32(sp)
    800029be:	ec26                	sd	s1,24(sp)
    800029c0:	e84a                	sd	s2,16(sp)
    800029c2:	e44e                	sd	s3,8(sp)
    800029c4:	1800                	addi	s0,sp,48
    800029c6:	89aa                	mv	s3,a0
    800029c8:	84ae                	mv	s1,a1
    800029ca:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800029cc:	f63fe0ef          	jal	8000192e <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800029d0:	86ca                	mv	a3,s2
    800029d2:	864e                	mv	a2,s3
    800029d4:	85a6                	mv	a1,s1
    800029d6:	6928                	ld	a0,80(a0)
    800029d8:	b21fe0ef          	jal	800014f8 <copyinstr>
    800029dc:	00054c63          	bltz	a0,800029f4 <fetchstr+0x3c>
  return strlen(buf);
    800029e0:	8526                	mv	a0,s1
    800029e2:	ca0fe0ef          	jal	80000e82 <strlen>
}
    800029e6:	70a2                	ld	ra,40(sp)
    800029e8:	7402                	ld	s0,32(sp)
    800029ea:	64e2                	ld	s1,24(sp)
    800029ec:	6942                	ld	s2,16(sp)
    800029ee:	69a2                	ld	s3,8(sp)
    800029f0:	6145                	addi	sp,sp,48
    800029f2:	8082                	ret
    return -1;
    800029f4:	557d                	li	a0,-1
    800029f6:	bfc5                	j	800029e6 <fetchstr+0x2e>

00000000800029f8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800029f8:	1101                	addi	sp,sp,-32
    800029fa:	ec06                	sd	ra,24(sp)
    800029fc:	e822                	sd	s0,16(sp)
    800029fe:	e426                	sd	s1,8(sp)
    80002a00:	1000                	addi	s0,sp,32
    80002a02:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a04:	f0bff0ef          	jal	8000290e <argraw>
    80002a08:	c088                	sw	a0,0(s1)
}
    80002a0a:	60e2                	ld	ra,24(sp)
    80002a0c:	6442                	ld	s0,16(sp)
    80002a0e:	64a2                	ld	s1,8(sp)
    80002a10:	6105                	addi	sp,sp,32
    80002a12:	8082                	ret

0000000080002a14 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a14:	1101                	addi	sp,sp,-32
    80002a16:	ec06                	sd	ra,24(sp)
    80002a18:	e822                	sd	s0,16(sp)
    80002a1a:	e426                	sd	s1,8(sp)
    80002a1c:	1000                	addi	s0,sp,32
    80002a1e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a20:	eefff0ef          	jal	8000290e <argraw>
    80002a24:	e088                	sd	a0,0(s1)
}
    80002a26:	60e2                	ld	ra,24(sp)
    80002a28:	6442                	ld	s0,16(sp)
    80002a2a:	64a2                	ld	s1,8(sp)
    80002a2c:	6105                	addi	sp,sp,32
    80002a2e:	8082                	ret

0000000080002a30 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a30:	1101                	addi	sp,sp,-32
    80002a32:	ec06                	sd	ra,24(sp)
    80002a34:	e822                	sd	s0,16(sp)
    80002a36:	e426                	sd	s1,8(sp)
    80002a38:	e04a                	sd	s2,0(sp)
    80002a3a:	1000                	addi	s0,sp,32
    80002a3c:	892e                	mv	s2,a1
    80002a3e:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a40:	ecfff0ef          	jal	8000290e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a44:	8626                	mv	a2,s1
    80002a46:	85ca                	mv	a1,s2
    80002a48:	f71ff0ef          	jal	800029b8 <fetchstr>
}
    80002a4c:	60e2                	ld	ra,24(sp)
    80002a4e:	6442                	ld	s0,16(sp)
    80002a50:	64a2                	ld	s1,8(sp)
    80002a52:	6902                	ld	s2,0(sp)
    80002a54:	6105                	addi	sp,sp,32
    80002a56:	8082                	ret

0000000080002a58 <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    80002a58:	1101                	addi	sp,sp,-32
    80002a5a:	ec06                	sd	ra,24(sp)
    80002a5c:	e822                	sd	s0,16(sp)
    80002a5e:	e426                	sd	s1,8(sp)
    80002a60:	e04a                	sd	s2,0(sp)
    80002a62:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002a64:	ecbfe0ef          	jal	8000192e <myproc>
    80002a68:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002a6a:	05853903          	ld	s2,88(a0)
    80002a6e:	0a893783          	ld	a5,168(s2)
    80002a72:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002a76:	37fd                	addiw	a5,a5,-1
    80002a78:	4755                	li	a4,21
    80002a7a:	00f76f63          	bltu	a4,a5,80002a98 <syscall+0x40>
    80002a7e:	00369713          	slli	a4,a3,0x3
    80002a82:	00005797          	auipc	a5,0x5
    80002a86:	de678793          	addi	a5,a5,-538 # 80007868 <syscalls>
    80002a8a:	97ba                	add	a5,a5,a4
    80002a8c:	639c                	ld	a5,0(a5)
    80002a8e:	c789                	beqz	a5,80002a98 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002a90:	9782                	jalr	a5
    80002a92:	06a93823          	sd	a0,112(s2)
    80002a96:	a829                	j	80002ab0 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002a98:	15848613          	addi	a2,s1,344
    80002a9c:	588c                	lw	a1,48(s1)
    80002a9e:	00005517          	auipc	a0,0x5
    80002aa2:	9a250513          	addi	a0,a0,-1630 # 80007440 <etext+0x440>
    80002aa6:	a55fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002aaa:	6cbc                	ld	a5,88(s1)
    80002aac:	577d                	li	a4,-1
    80002aae:	fbb8                	sd	a4,112(a5)
  }
}
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6902                	ld	s2,0(sp)
    80002ab8:	6105                	addi	sp,sp,32
    80002aba:	8082                	ret

0000000080002abc <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002abc:	1101                	addi	sp,sp,-32
    80002abe:	ec06                	sd	ra,24(sp)
    80002ac0:	e822                	sd	s0,16(sp)
    80002ac2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ac4:	fec40593          	addi	a1,s0,-20
    80002ac8:	4501                	li	a0,0
    80002aca:	f2fff0ef          	jal	800029f8 <argint>
  kexit(n);
    80002ace:	fec42503          	lw	a0,-20(s0)
    80002ad2:	e28ff0ef          	jal	800020fa <kexit>
  return 0;  // not reached
}
    80002ad6:	4501                	li	a0,0
    80002ad8:	60e2                	ld	ra,24(sp)
    80002ada:	6442                	ld	s0,16(sp)
    80002adc:	6105                	addi	sp,sp,32
    80002ade:	8082                	ret

0000000080002ae0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ae0:	1141                	addi	sp,sp,-16
    80002ae2:	e406                	sd	ra,8(sp)
    80002ae4:	e022                	sd	s0,0(sp)
    80002ae6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002ae8:	e47fe0ef          	jal	8000192e <myproc>
}
    80002aec:	5908                	lw	a0,48(a0)
    80002aee:	60a2                	ld	ra,8(sp)
    80002af0:	6402                	ld	s0,0(sp)
    80002af2:	0141                	addi	sp,sp,16
    80002af4:	8082                	ret

0000000080002af6 <sys_fork>:

uint64
sys_fork(void)
{
    80002af6:	1141                	addi	sp,sp,-16
    80002af8:	e406                	sd	ra,8(sp)
    80002afa:	e022                	sd	s0,0(sp)
    80002afc:	0800                	addi	s0,sp,16
  return kfork();
    80002afe:	99cff0ef          	jal	80001c9a <kfork>
}
    80002b02:	60a2                	ld	ra,8(sp)
    80002b04:	6402                	ld	s0,0(sp)
    80002b06:	0141                	addi	sp,sp,16
    80002b08:	8082                	ret

0000000080002b0a <sys_wait>:

uint64
sys_wait(void)
{
    80002b0a:	1101                	addi	sp,sp,-32
    80002b0c:	ec06                	sd	ra,24(sp)
    80002b0e:	e822                	sd	s0,16(sp)
    80002b10:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b12:	fe840593          	addi	a1,s0,-24
    80002b16:	4501                	li	a0,0
    80002b18:	efdff0ef          	jal	80002a14 <argaddr>
  return kwait(p);
    80002b1c:	fe843503          	ld	a0,-24(s0)
    80002b20:	f34ff0ef          	jal	80002254 <kwait>
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret

0000000080002b2c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b2c:	7179                	addi	sp,sp,-48
    80002b2e:	f406                	sd	ra,40(sp)
    80002b30:	f022                	sd	s0,32(sp)
    80002b32:	ec26                	sd	s1,24(sp)
    80002b34:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b36:	fd840593          	addi	a1,s0,-40
    80002b3a:	4501                	li	a0,0
    80002b3c:	ebdff0ef          	jal	800029f8 <argint>
  argint(1, &t);
    80002b40:	fdc40593          	addi	a1,s0,-36
    80002b44:	4505                	li	a0,1
    80002b46:	eb3ff0ef          	jal	800029f8 <argint>
  addr = myproc()->sz;
    80002b4a:	de5fe0ef          	jal	8000192e <myproc>
    80002b4e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002b50:	fdc42703          	lw	a4,-36(s0)
    80002b54:	4785                	li	a5,1
    80002b56:	02f70763          	beq	a4,a5,80002b84 <sys_sbrk+0x58>
    80002b5a:	fd842783          	lw	a5,-40(s0)
    80002b5e:	0207c363          	bltz	a5,80002b84 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002b62:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002b64:	02000737          	lui	a4,0x2000
    80002b68:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002b6a:	0736                	slli	a4,a4,0xd
    80002b6c:	02f76a63          	bltu	a4,a5,80002ba0 <sys_sbrk+0x74>
    80002b70:	0297e863          	bltu	a5,s1,80002ba0 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002b74:	dbbfe0ef          	jal	8000192e <myproc>
    80002b78:	fd842703          	lw	a4,-40(s0)
    80002b7c:	653c                	ld	a5,72(a0)
    80002b7e:	97ba                	add	a5,a5,a4
    80002b80:	e53c                	sd	a5,72(a0)
    80002b82:	a039                	j	80002b90 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002b84:	fd842503          	lw	a0,-40(s0)
    80002b88:	8b0ff0ef          	jal	80001c38 <growproc>
    80002b8c:	00054863          	bltz	a0,80002b9c <sys_sbrk+0x70>
  }
  return addr;
}
    80002b90:	8526                	mv	a0,s1
    80002b92:	70a2                	ld	ra,40(sp)
    80002b94:	7402                	ld	s0,32(sp)
    80002b96:	64e2                	ld	s1,24(sp)
    80002b98:	6145                	addi	sp,sp,48
    80002b9a:	8082                	ret
      return -1;
    80002b9c:	54fd                	li	s1,-1
    80002b9e:	bfcd                	j	80002b90 <sys_sbrk+0x64>
      return -1;
    80002ba0:	54fd                	li	s1,-1
    80002ba2:	b7fd                	j	80002b90 <sys_sbrk+0x64>

0000000080002ba4 <sys_pause>:

uint64
sys_pause(void)
{
    80002ba4:	7139                	addi	sp,sp,-64
    80002ba6:	fc06                	sd	ra,56(sp)
    80002ba8:	f822                	sd	s0,48(sp)
    80002baa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bac:	fcc40593          	addi	a1,s0,-52
    80002bb0:	4501                	li	a0,0
    80002bb2:	e47ff0ef          	jal	800029f8 <argint>
  if(n < 0)
    80002bb6:	fcc42783          	lw	a5,-52(s0)
    80002bba:	0607c863          	bltz	a5,80002c2a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002bbe:	00013517          	auipc	a0,0x13
    80002bc2:	cca50513          	addi	a0,a0,-822 # 80015888 <tickslock>
    80002bc6:	862fe0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002bca:	fcc42783          	lw	a5,-52(s0)
    80002bce:	c3b9                	beqz	a5,80002c14 <sys_pause+0x70>
    80002bd0:	f426                	sd	s1,40(sp)
    80002bd2:	f04a                	sd	s2,32(sp)
    80002bd4:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002bd6:	00005997          	auipc	s3,0x5
    80002bda:	d829a983          	lw	s3,-638(s3) # 80007958 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002bde:	00013917          	auipc	s2,0x13
    80002be2:	caa90913          	addi	s2,s2,-854 # 80015888 <tickslock>
    80002be6:	00005497          	auipc	s1,0x5
    80002bea:	d7248493          	addi	s1,s1,-654 # 80007958 <ticks>
    if(killed(myproc())){
    80002bee:	d41fe0ef          	jal	8000192e <myproc>
    80002bf2:	e38ff0ef          	jal	8000222a <killed>
    80002bf6:	ed0d                	bnez	a0,80002c30 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002bf8:	85ca                	mv	a1,s2
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	bf2ff0ef          	jal	80001fee <sleep>
  while(ticks - ticks0 < n){
    80002c00:	409c                	lw	a5,0(s1)
    80002c02:	413787bb          	subw	a5,a5,s3
    80002c06:	fcc42703          	lw	a4,-52(s0)
    80002c0a:	fee7e2e3          	bltu	a5,a4,80002bee <sys_pause+0x4a>
    80002c0e:	74a2                	ld	s1,40(sp)
    80002c10:	7902                	ld	s2,32(sp)
    80002c12:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c14:	00013517          	auipc	a0,0x13
    80002c18:	c7450513          	addi	a0,a0,-908 # 80015888 <tickslock>
    80002c1c:	8a0fe0ef          	jal	80000cbc <release>
  return 0;
    80002c20:	4501                	li	a0,0
}
    80002c22:	70e2                	ld	ra,56(sp)
    80002c24:	7442                	ld	s0,48(sp)
    80002c26:	6121                	addi	sp,sp,64
    80002c28:	8082                	ret
    n = 0;
    80002c2a:	fc042623          	sw	zero,-52(s0)
    80002c2e:	bf41                	j	80002bbe <sys_pause+0x1a>
      release(&tickslock);
    80002c30:	00013517          	auipc	a0,0x13
    80002c34:	c5850513          	addi	a0,a0,-936 # 80015888 <tickslock>
    80002c38:	884fe0ef          	jal	80000cbc <release>
      return -1;
    80002c3c:	557d                	li	a0,-1
    80002c3e:	74a2                	ld	s1,40(sp)
    80002c40:	7902                	ld	s2,32(sp)
    80002c42:	69e2                	ld	s3,24(sp)
    80002c44:	bff9                	j	80002c22 <sys_pause+0x7e>

0000000080002c46 <sys_kill>:

uint64
sys_kill(void)
{
    80002c46:	1101                	addi	sp,sp,-32
    80002c48:	ec06                	sd	ra,24(sp)
    80002c4a:	e822                	sd	s0,16(sp)
    80002c4c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c4e:	fec40593          	addi	a1,s0,-20
    80002c52:	4501                	li	a0,0
    80002c54:	da5ff0ef          	jal	800029f8 <argint>
  return kkill(pid);
    80002c58:	fec42503          	lw	a0,-20(s0)
    80002c5c:	d44ff0ef          	jal	800021a0 <kkill>
}
    80002c60:	60e2                	ld	ra,24(sp)
    80002c62:	6442                	ld	s0,16(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c72:	00013517          	auipc	a0,0x13
    80002c76:	c1650513          	addi	a0,a0,-1002 # 80015888 <tickslock>
    80002c7a:	faffd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    80002c7e:	00005797          	auipc	a5,0x5
    80002c82:	cda7a783          	lw	a5,-806(a5) # 80007958 <ticks>
    80002c86:	84be                	mv	s1,a5
  release(&tickslock);
    80002c88:	00013517          	auipc	a0,0x13
    80002c8c:	c0050513          	addi	a0,a0,-1024 # 80015888 <tickslock>
    80002c90:	82cfe0ef          	jal	80000cbc <release>
  return xticks;
}
    80002c94:	02049513          	slli	a0,s1,0x20
    80002c98:	9101                	srli	a0,a0,0x20
    80002c9a:	60e2                	ld	ra,24(sp)
    80002c9c:	6442                	ld	s0,16(sp)
    80002c9e:	64a2                	ld	s1,8(sp)
    80002ca0:	6105                	addi	sp,sp,32
    80002ca2:	8082                	ret

0000000080002ca4 <sys_kps>:

uint64
sys_kps(void)
{
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80002cac:	4611                	li	a2,4
    80002cae:	fe840593          	addi	a1,s0,-24
    80002cb2:	4501                	li	a0,0
    80002cb4:	d7dff0ef          	jal	80002a30 <argstr>
    80002cb8:	87aa                	mv	a5,a0
    return -1;
    80002cba:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    80002cbc:	0007c663          	bltz	a5,80002cc8 <sys_kps+0x24>

  return kps(buffer);
    80002cc0:	fe840513          	addi	a0,s0,-24
    80002cc4:	fbcff0ef          	jal	80002480 <kps>
    80002cc8:	60e2                	ld	ra,24(sp)
    80002cca:	6442                	ld	s0,16(sp)
    80002ccc:	6105                	addi	sp,sp,32
    80002cce:	8082                	ret

0000000080002cd0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cd0:	7179                	addi	sp,sp,-48
    80002cd2:	f406                	sd	ra,40(sp)
    80002cd4:	f022                	sd	s0,32(sp)
    80002cd6:	ec26                	sd	s1,24(sp)
    80002cd8:	e84a                	sd	s2,16(sp)
    80002cda:	e44e                	sd	s3,8(sp)
    80002cdc:	e052                	sd	s4,0(sp)
    80002cde:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ce0:	00004597          	auipc	a1,0x4
    80002ce4:	78058593          	addi	a1,a1,1920 # 80007460 <etext+0x460>
    80002ce8:	00013517          	auipc	a0,0x13
    80002cec:	bb850513          	addi	a0,a0,-1096 # 800158a0 <bcache>
    80002cf0:	eaffd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cf4:	0001b797          	auipc	a5,0x1b
    80002cf8:	bac78793          	addi	a5,a5,-1108 # 8001d8a0 <bcache+0x8000>
    80002cfc:	0001b717          	auipc	a4,0x1b
    80002d00:	e0c70713          	addi	a4,a4,-500 # 8001db08 <bcache+0x8268>
    80002d04:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d08:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d0c:	00013497          	auipc	s1,0x13
    80002d10:	bac48493          	addi	s1,s1,-1108 # 800158b8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d14:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d16:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d18:	00004a17          	auipc	s4,0x4
    80002d1c:	750a0a13          	addi	s4,s4,1872 # 80007468 <etext+0x468>
    b->next = bcache.head.next;
    80002d20:	2b893783          	ld	a5,696(s2)
    80002d24:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d26:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d2a:	85d2                	mv	a1,s4
    80002d2c:	01048513          	addi	a0,s1,16
    80002d30:	328010ef          	jal	80004058 <initsleeplock>
    bcache.head.next->prev = b;
    80002d34:	2b893783          	ld	a5,696(s2)
    80002d38:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d3a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d3e:	45848493          	addi	s1,s1,1112
    80002d42:	fd349fe3          	bne	s1,s3,80002d20 <binit+0x50>
  }
}
    80002d46:	70a2                	ld	ra,40(sp)
    80002d48:	7402                	ld	s0,32(sp)
    80002d4a:	64e2                	ld	s1,24(sp)
    80002d4c:	6942                	ld	s2,16(sp)
    80002d4e:	69a2                	ld	s3,8(sp)
    80002d50:	6a02                	ld	s4,0(sp)
    80002d52:	6145                	addi	sp,sp,48
    80002d54:	8082                	ret

0000000080002d56 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d56:	7179                	addi	sp,sp,-48
    80002d58:	f406                	sd	ra,40(sp)
    80002d5a:	f022                	sd	s0,32(sp)
    80002d5c:	ec26                	sd	s1,24(sp)
    80002d5e:	e84a                	sd	s2,16(sp)
    80002d60:	e44e                	sd	s3,8(sp)
    80002d62:	1800                	addi	s0,sp,48
    80002d64:	892a                	mv	s2,a0
    80002d66:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d68:	00013517          	auipc	a0,0x13
    80002d6c:	b3850513          	addi	a0,a0,-1224 # 800158a0 <bcache>
    80002d70:	eb9fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d74:	0001b497          	auipc	s1,0x1b
    80002d78:	de44b483          	ld	s1,-540(s1) # 8001db58 <bcache+0x82b8>
    80002d7c:	0001b797          	auipc	a5,0x1b
    80002d80:	d8c78793          	addi	a5,a5,-628 # 8001db08 <bcache+0x8268>
    80002d84:	02f48b63          	beq	s1,a5,80002dba <bread+0x64>
    80002d88:	873e                	mv	a4,a5
    80002d8a:	a021                	j	80002d92 <bread+0x3c>
    80002d8c:	68a4                	ld	s1,80(s1)
    80002d8e:	02e48663          	beq	s1,a4,80002dba <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d92:	449c                	lw	a5,8(s1)
    80002d94:	ff279ce3          	bne	a5,s2,80002d8c <bread+0x36>
    80002d98:	44dc                	lw	a5,12(s1)
    80002d9a:	ff3799e3          	bne	a5,s3,80002d8c <bread+0x36>
      b->refcnt++;
    80002d9e:	40bc                	lw	a5,64(s1)
    80002da0:	2785                	addiw	a5,a5,1
    80002da2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002da4:	00013517          	auipc	a0,0x13
    80002da8:	afc50513          	addi	a0,a0,-1284 # 800158a0 <bcache>
    80002dac:	f11fd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002db0:	01048513          	addi	a0,s1,16
    80002db4:	2da010ef          	jal	8000408e <acquiresleep>
      return b;
    80002db8:	a889                	j	80002e0a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dba:	0001b497          	auipc	s1,0x1b
    80002dbe:	d964b483          	ld	s1,-618(s1) # 8001db50 <bcache+0x82b0>
    80002dc2:	0001b797          	auipc	a5,0x1b
    80002dc6:	d4678793          	addi	a5,a5,-698 # 8001db08 <bcache+0x8268>
    80002dca:	00f48863          	beq	s1,a5,80002dda <bread+0x84>
    80002dce:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dd0:	40bc                	lw	a5,64(s1)
    80002dd2:	cb91                	beqz	a5,80002de6 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dd4:	64a4                	ld	s1,72(s1)
    80002dd6:	fee49de3          	bne	s1,a4,80002dd0 <bread+0x7a>
  panic("bget: no buffers");
    80002dda:	00004517          	auipc	a0,0x4
    80002dde:	69650513          	addi	a0,a0,1686 # 80007470 <etext+0x470>
    80002de2:	a43fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80002de6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002dea:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dee:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002df2:	4785                	li	a5,1
    80002df4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df6:	00013517          	auipc	a0,0x13
    80002dfa:	aaa50513          	addi	a0,a0,-1366 # 800158a0 <bcache>
    80002dfe:	ebffd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80002e02:	01048513          	addi	a0,s1,16
    80002e06:	288010ef          	jal	8000408e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e0a:	409c                	lw	a5,0(s1)
    80002e0c:	cb89                	beqz	a5,80002e1e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e0e:	8526                	mv	a0,s1
    80002e10:	70a2                	ld	ra,40(sp)
    80002e12:	7402                	ld	s0,32(sp)
    80002e14:	64e2                	ld	s1,24(sp)
    80002e16:	6942                	ld	s2,16(sp)
    80002e18:	69a2                	ld	s3,8(sp)
    80002e1a:	6145                	addi	sp,sp,48
    80002e1c:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e1e:	4581                	li	a1,0
    80002e20:	8526                	mv	a0,s1
    80002e22:	32f020ef          	jal	80005950 <virtio_disk_rw>
    b->valid = 1;
    80002e26:	4785                	li	a5,1
    80002e28:	c09c                	sw	a5,0(s1)
  return b;
    80002e2a:	b7d5                	j	80002e0e <bread+0xb8>

0000000080002e2c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	e426                	sd	s1,8(sp)
    80002e34:	1000                	addi	s0,sp,32
    80002e36:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e38:	0541                	addi	a0,a0,16
    80002e3a:	2d2010ef          	jal	8000410c <holdingsleep>
    80002e3e:	c911                	beqz	a0,80002e52 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e40:	4585                	li	a1,1
    80002e42:	8526                	mv	a0,s1
    80002e44:	30d020ef          	jal	80005950 <virtio_disk_rw>
}
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret
    panic("bwrite");
    80002e52:	00004517          	auipc	a0,0x4
    80002e56:	63650513          	addi	a0,a0,1590 # 80007488 <etext+0x488>
    80002e5a:	9cbfd0ef          	jal	80000824 <panic>

0000000080002e5e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e5e:	1101                	addi	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	e04a                	sd	s2,0(sp)
    80002e68:	1000                	addi	s0,sp,32
    80002e6a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e6c:	01050913          	addi	s2,a0,16
    80002e70:	854a                	mv	a0,s2
    80002e72:	29a010ef          	jal	8000410c <holdingsleep>
    80002e76:	c125                	beqz	a0,80002ed6 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e78:	854a                	mv	a0,s2
    80002e7a:	25a010ef          	jal	800040d4 <releasesleep>

  acquire(&bcache.lock);
    80002e7e:	00013517          	auipc	a0,0x13
    80002e82:	a2250513          	addi	a0,a0,-1502 # 800158a0 <bcache>
    80002e86:	da3fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002e8a:	40bc                	lw	a5,64(s1)
    80002e8c:	37fd                	addiw	a5,a5,-1
    80002e8e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e90:	e79d                	bnez	a5,80002ebe <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e92:	68b8                	ld	a4,80(s1)
    80002e94:	64bc                	ld	a5,72(s1)
    80002e96:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e98:	68b8                	ld	a4,80(s1)
    80002e9a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e9c:	0001b797          	auipc	a5,0x1b
    80002ea0:	a0478793          	addi	a5,a5,-1532 # 8001d8a0 <bcache+0x8000>
    80002ea4:	2b87b703          	ld	a4,696(a5)
    80002ea8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002eaa:	0001b717          	auipc	a4,0x1b
    80002eae:	c5e70713          	addi	a4,a4,-930 # 8001db08 <bcache+0x8268>
    80002eb2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002eb4:	2b87b703          	ld	a4,696(a5)
    80002eb8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002eba:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ebe:	00013517          	auipc	a0,0x13
    80002ec2:	9e250513          	addi	a0,a0,-1566 # 800158a0 <bcache>
    80002ec6:	df7fd0ef          	jal	80000cbc <release>
}
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	64a2                	ld	s1,8(sp)
    80002ed0:	6902                	ld	s2,0(sp)
    80002ed2:	6105                	addi	sp,sp,32
    80002ed4:	8082                	ret
    panic("brelse");
    80002ed6:	00004517          	auipc	a0,0x4
    80002eda:	5ba50513          	addi	a0,a0,1466 # 80007490 <etext+0x490>
    80002ede:	947fd0ef          	jal	80000824 <panic>

0000000080002ee2 <bpin>:

void
bpin(struct buf *b) {
    80002ee2:	1101                	addi	sp,sp,-32
    80002ee4:	ec06                	sd	ra,24(sp)
    80002ee6:	e822                	sd	s0,16(sp)
    80002ee8:	e426                	sd	s1,8(sp)
    80002eea:	1000                	addi	s0,sp,32
    80002eec:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eee:	00013517          	auipc	a0,0x13
    80002ef2:	9b250513          	addi	a0,a0,-1614 # 800158a0 <bcache>
    80002ef6:	d33fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    80002efa:	40bc                	lw	a5,64(s1)
    80002efc:	2785                	addiw	a5,a5,1
    80002efe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f00:	00013517          	auipc	a0,0x13
    80002f04:	9a050513          	addi	a0,a0,-1632 # 800158a0 <bcache>
    80002f08:	db5fd0ef          	jal	80000cbc <release>
}
    80002f0c:	60e2                	ld	ra,24(sp)
    80002f0e:	6442                	ld	s0,16(sp)
    80002f10:	64a2                	ld	s1,8(sp)
    80002f12:	6105                	addi	sp,sp,32
    80002f14:	8082                	ret

0000000080002f16 <bunpin>:

void
bunpin(struct buf *b) {
    80002f16:	1101                	addi	sp,sp,-32
    80002f18:	ec06                	sd	ra,24(sp)
    80002f1a:	e822                	sd	s0,16(sp)
    80002f1c:	e426                	sd	s1,8(sp)
    80002f1e:	1000                	addi	s0,sp,32
    80002f20:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f22:	00013517          	auipc	a0,0x13
    80002f26:	97e50513          	addi	a0,a0,-1666 # 800158a0 <bcache>
    80002f2a:	cfffd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80002f2e:	40bc                	lw	a5,64(s1)
    80002f30:	37fd                	addiw	a5,a5,-1
    80002f32:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f34:	00013517          	auipc	a0,0x13
    80002f38:	96c50513          	addi	a0,a0,-1684 # 800158a0 <bcache>
    80002f3c:	d81fd0ef          	jal	80000cbc <release>
}
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	64a2                	ld	s1,8(sp)
    80002f46:	6105                	addi	sp,sp,32
    80002f48:	8082                	ret

0000000080002f4a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	e04a                	sd	s2,0(sp)
    80002f54:	1000                	addi	s0,sp,32
    80002f56:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f58:	00d5d79b          	srliw	a5,a1,0xd
    80002f5c:	0001b597          	auipc	a1,0x1b
    80002f60:	0205a583          	lw	a1,32(a1) # 8001df7c <sb+0x1c>
    80002f64:	9dbd                	addw	a1,a1,a5
    80002f66:	df1ff0ef          	jal	80002d56 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f6a:	0074f713          	andi	a4,s1,7
    80002f6e:	4785                	li	a5,1
    80002f70:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f74:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002f76:	90d9                	srli	s1,s1,0x36
    80002f78:	00950733          	add	a4,a0,s1
    80002f7c:	05874703          	lbu	a4,88(a4)
    80002f80:	00e7f6b3          	and	a3,a5,a4
    80002f84:	c29d                	beqz	a3,80002faa <bfree+0x60>
    80002f86:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f88:	94aa                	add	s1,s1,a0
    80002f8a:	fff7c793          	not	a5,a5
    80002f8e:	8f7d                	and	a4,a4,a5
    80002f90:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f94:	000010ef          	jal	80003f94 <log_write>
  brelse(bp);
    80002f98:	854a                	mv	a0,s2
    80002f9a:	ec5ff0ef          	jal	80002e5e <brelse>
}
    80002f9e:	60e2                	ld	ra,24(sp)
    80002fa0:	6442                	ld	s0,16(sp)
    80002fa2:	64a2                	ld	s1,8(sp)
    80002fa4:	6902                	ld	s2,0(sp)
    80002fa6:	6105                	addi	sp,sp,32
    80002fa8:	8082                	ret
    panic("freeing free block");
    80002faa:	00004517          	auipc	a0,0x4
    80002fae:	4ee50513          	addi	a0,a0,1262 # 80007498 <etext+0x498>
    80002fb2:	873fd0ef          	jal	80000824 <panic>

0000000080002fb6 <balloc>:
{
    80002fb6:	715d                	addi	sp,sp,-80
    80002fb8:	e486                	sd	ra,72(sp)
    80002fba:	e0a2                	sd	s0,64(sp)
    80002fbc:	fc26                	sd	s1,56(sp)
    80002fbe:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002fc0:	0001b797          	auipc	a5,0x1b
    80002fc4:	fa47a783          	lw	a5,-92(a5) # 8001df64 <sb+0x4>
    80002fc8:	0e078263          	beqz	a5,800030ac <balloc+0xf6>
    80002fcc:	f84a                	sd	s2,48(sp)
    80002fce:	f44e                	sd	s3,40(sp)
    80002fd0:	f052                	sd	s4,32(sp)
    80002fd2:	ec56                	sd	s5,24(sp)
    80002fd4:	e85a                	sd	s6,16(sp)
    80002fd6:	e45e                	sd	s7,8(sp)
    80002fd8:	e062                	sd	s8,0(sp)
    80002fda:	8baa                	mv	s7,a0
    80002fdc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fde:	0001bb17          	auipc	s6,0x1b
    80002fe2:	f82b0b13          	addi	s6,s6,-126 # 8001df60 <sb>
      m = 1 << (bi % 8);
    80002fe6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fe8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002fea:	6c09                	lui	s8,0x2
    80002fec:	a09d                	j	80003052 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002fee:	97ca                	add	a5,a5,s2
    80002ff0:	8e55                	or	a2,a2,a3
    80002ff2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ff6:	854a                	mv	a0,s2
    80002ff8:	79d000ef          	jal	80003f94 <log_write>
        brelse(bp);
    80002ffc:	854a                	mv	a0,s2
    80002ffe:	e61ff0ef          	jal	80002e5e <brelse>
  bp = bread(dev, bno);
    80003002:	85a6                	mv	a1,s1
    80003004:	855e                	mv	a0,s7
    80003006:	d51ff0ef          	jal	80002d56 <bread>
    8000300a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000300c:	40000613          	li	a2,1024
    80003010:	4581                	li	a1,0
    80003012:	05850513          	addi	a0,a0,88
    80003016:	ce3fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    8000301a:	854a                	mv	a0,s2
    8000301c:	779000ef          	jal	80003f94 <log_write>
  brelse(bp);
    80003020:	854a                	mv	a0,s2
    80003022:	e3dff0ef          	jal	80002e5e <brelse>
}
    80003026:	7942                	ld	s2,48(sp)
    80003028:	79a2                	ld	s3,40(sp)
    8000302a:	7a02                	ld	s4,32(sp)
    8000302c:	6ae2                	ld	s5,24(sp)
    8000302e:	6b42                	ld	s6,16(sp)
    80003030:	6ba2                	ld	s7,8(sp)
    80003032:	6c02                	ld	s8,0(sp)
}
    80003034:	8526                	mv	a0,s1
    80003036:	60a6                	ld	ra,72(sp)
    80003038:	6406                	ld	s0,64(sp)
    8000303a:	74e2                	ld	s1,56(sp)
    8000303c:	6161                	addi	sp,sp,80
    8000303e:	8082                	ret
    brelse(bp);
    80003040:	854a                	mv	a0,s2
    80003042:	e1dff0ef          	jal	80002e5e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003046:	015c0abb          	addw	s5,s8,s5
    8000304a:	004b2783          	lw	a5,4(s6)
    8000304e:	04faf863          	bgeu	s5,a5,8000309e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003052:	40dad59b          	sraiw	a1,s5,0xd
    80003056:	01cb2783          	lw	a5,28(s6)
    8000305a:	9dbd                	addw	a1,a1,a5
    8000305c:	855e                	mv	a0,s7
    8000305e:	cf9ff0ef          	jal	80002d56 <bread>
    80003062:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003064:	004b2503          	lw	a0,4(s6)
    80003068:	84d6                	mv	s1,s5
    8000306a:	4701                	li	a4,0
    8000306c:	fca4fae3          	bgeu	s1,a0,80003040 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003070:	00777693          	andi	a3,a4,7
    80003074:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003078:	41f7579b          	sraiw	a5,a4,0x1f
    8000307c:	01d7d79b          	srliw	a5,a5,0x1d
    80003080:	9fb9                	addw	a5,a5,a4
    80003082:	4037d79b          	sraiw	a5,a5,0x3
    80003086:	00f90633          	add	a2,s2,a5
    8000308a:	05864603          	lbu	a2,88(a2)
    8000308e:	00c6f5b3          	and	a1,a3,a2
    80003092:	ddb1                	beqz	a1,80002fee <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003094:	2705                	addiw	a4,a4,1
    80003096:	2485                	addiw	s1,s1,1
    80003098:	fd471ae3          	bne	a4,s4,8000306c <balloc+0xb6>
    8000309c:	b755                	j	80003040 <balloc+0x8a>
    8000309e:	7942                	ld	s2,48(sp)
    800030a0:	79a2                	ld	s3,40(sp)
    800030a2:	7a02                	ld	s4,32(sp)
    800030a4:	6ae2                	ld	s5,24(sp)
    800030a6:	6b42                	ld	s6,16(sp)
    800030a8:	6ba2                	ld	s7,8(sp)
    800030aa:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800030ac:	00004517          	auipc	a0,0x4
    800030b0:	40450513          	addi	a0,a0,1028 # 800074b0 <etext+0x4b0>
    800030b4:	c46fd0ef          	jal	800004fa <printf>
  return 0;
    800030b8:	4481                	li	s1,0
    800030ba:	bfad                	j	80003034 <balloc+0x7e>

00000000800030bc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030bc:	7179                	addi	sp,sp,-48
    800030be:	f406                	sd	ra,40(sp)
    800030c0:	f022                	sd	s0,32(sp)
    800030c2:	ec26                	sd	s1,24(sp)
    800030c4:	e84a                	sd	s2,16(sp)
    800030c6:	e44e                	sd	s3,8(sp)
    800030c8:	1800                	addi	s0,sp,48
    800030ca:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030cc:	47ad                	li	a5,11
    800030ce:	02b7e363          	bltu	a5,a1,800030f4 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800030d2:	02059793          	slli	a5,a1,0x20
    800030d6:	01e7d593          	srli	a1,a5,0x1e
    800030da:	00b509b3          	add	s3,a0,a1
    800030de:	0509a483          	lw	s1,80(s3)
    800030e2:	e0b5                	bnez	s1,80003146 <bmap+0x8a>
      addr = balloc(ip->dev);
    800030e4:	4108                	lw	a0,0(a0)
    800030e6:	ed1ff0ef          	jal	80002fb6 <balloc>
    800030ea:	84aa                	mv	s1,a0
      if(addr == 0)
    800030ec:	cd29                	beqz	a0,80003146 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800030ee:	04a9a823          	sw	a0,80(s3)
    800030f2:	a891                	j	80003146 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800030f4:	ff45879b          	addiw	a5,a1,-12
    800030f8:	873e                	mv	a4,a5
    800030fa:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800030fc:	0ff00793          	li	a5,255
    80003100:	06e7e763          	bltu	a5,a4,8000316e <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003104:	08052483          	lw	s1,128(a0)
    80003108:	e891                	bnez	s1,8000311c <bmap+0x60>
      addr = balloc(ip->dev);
    8000310a:	4108                	lw	a0,0(a0)
    8000310c:	eabff0ef          	jal	80002fb6 <balloc>
    80003110:	84aa                	mv	s1,a0
      if(addr == 0)
    80003112:	c915                	beqz	a0,80003146 <bmap+0x8a>
    80003114:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003116:	08a92023          	sw	a0,128(s2)
    8000311a:	a011                	j	8000311e <bmap+0x62>
    8000311c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000311e:	85a6                	mv	a1,s1
    80003120:	00092503          	lw	a0,0(s2)
    80003124:	c33ff0ef          	jal	80002d56 <bread>
    80003128:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000312a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000312e:	02099713          	slli	a4,s3,0x20
    80003132:	01e75593          	srli	a1,a4,0x1e
    80003136:	97ae                	add	a5,a5,a1
    80003138:	89be                	mv	s3,a5
    8000313a:	4384                	lw	s1,0(a5)
    8000313c:	cc89                	beqz	s1,80003156 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000313e:	8552                	mv	a0,s4
    80003140:	d1fff0ef          	jal	80002e5e <brelse>
    return addr;
    80003144:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003146:	8526                	mv	a0,s1
    80003148:	70a2                	ld	ra,40(sp)
    8000314a:	7402                	ld	s0,32(sp)
    8000314c:	64e2                	ld	s1,24(sp)
    8000314e:	6942                	ld	s2,16(sp)
    80003150:	69a2                	ld	s3,8(sp)
    80003152:	6145                	addi	sp,sp,48
    80003154:	8082                	ret
      addr = balloc(ip->dev);
    80003156:	00092503          	lw	a0,0(s2)
    8000315a:	e5dff0ef          	jal	80002fb6 <balloc>
    8000315e:	84aa                	mv	s1,a0
      if(addr){
    80003160:	dd79                	beqz	a0,8000313e <bmap+0x82>
        a[bn] = addr;
    80003162:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003166:	8552                	mv	a0,s4
    80003168:	62d000ef          	jal	80003f94 <log_write>
    8000316c:	bfc9                	j	8000313e <bmap+0x82>
    8000316e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003170:	00004517          	auipc	a0,0x4
    80003174:	35850513          	addi	a0,a0,856 # 800074c8 <etext+0x4c8>
    80003178:	eacfd0ef          	jal	80000824 <panic>

000000008000317c <iget>:
{
    8000317c:	7179                	addi	sp,sp,-48
    8000317e:	f406                	sd	ra,40(sp)
    80003180:	f022                	sd	s0,32(sp)
    80003182:	ec26                	sd	s1,24(sp)
    80003184:	e84a                	sd	s2,16(sp)
    80003186:	e44e                	sd	s3,8(sp)
    80003188:	e052                	sd	s4,0(sp)
    8000318a:	1800                	addi	s0,sp,48
    8000318c:	892a                	mv	s2,a0
    8000318e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003190:	0001b517          	auipc	a0,0x1b
    80003194:	df050513          	addi	a0,a0,-528 # 8001df80 <itable>
    80003198:	a91fd0ef          	jal	80000c28 <acquire>
  empty = 0;
    8000319c:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000319e:	0001b497          	auipc	s1,0x1b
    800031a2:	dfa48493          	addi	s1,s1,-518 # 8001df98 <itable+0x18>
    800031a6:	0001d697          	auipc	a3,0x1d
    800031aa:	88268693          	addi	a3,a3,-1918 # 8001fa28 <log>
    800031ae:	a809                	j	800031c0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031b0:	e781                	bnez	a5,800031b8 <iget+0x3c>
    800031b2:	00099363          	bnez	s3,800031b8 <iget+0x3c>
      empty = ip;
    800031b6:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031b8:	08848493          	addi	s1,s1,136
    800031bc:	02d48563          	beq	s1,a3,800031e6 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031c0:	449c                	lw	a5,8(s1)
    800031c2:	fef057e3          	blez	a5,800031b0 <iget+0x34>
    800031c6:	4098                	lw	a4,0(s1)
    800031c8:	ff2718e3          	bne	a4,s2,800031b8 <iget+0x3c>
    800031cc:	40d8                	lw	a4,4(s1)
    800031ce:	ff4715e3          	bne	a4,s4,800031b8 <iget+0x3c>
      ip->ref++;
    800031d2:	2785                	addiw	a5,a5,1
    800031d4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800031d6:	0001b517          	auipc	a0,0x1b
    800031da:	daa50513          	addi	a0,a0,-598 # 8001df80 <itable>
    800031de:	adffd0ef          	jal	80000cbc <release>
      return ip;
    800031e2:	89a6                	mv	s3,s1
    800031e4:	a015                	j	80003208 <iget+0x8c>
  if(empty == 0)
    800031e6:	02098a63          	beqz	s3,8000321a <iget+0x9e>
  ip->dev = dev;
    800031ea:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800031ee:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800031f2:	4785                	li	a5,1
    800031f4:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800031f8:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800031fc:	0001b517          	auipc	a0,0x1b
    80003200:	d8450513          	addi	a0,a0,-636 # 8001df80 <itable>
    80003204:	ab9fd0ef          	jal	80000cbc <release>
}
    80003208:	854e                	mv	a0,s3
    8000320a:	70a2                	ld	ra,40(sp)
    8000320c:	7402                	ld	s0,32(sp)
    8000320e:	64e2                	ld	s1,24(sp)
    80003210:	6942                	ld	s2,16(sp)
    80003212:	69a2                	ld	s3,8(sp)
    80003214:	6a02                	ld	s4,0(sp)
    80003216:	6145                	addi	sp,sp,48
    80003218:	8082                	ret
    panic("iget: no inodes");
    8000321a:	00004517          	auipc	a0,0x4
    8000321e:	2c650513          	addi	a0,a0,710 # 800074e0 <etext+0x4e0>
    80003222:	e02fd0ef          	jal	80000824 <panic>

0000000080003226 <iinit>:
{
    80003226:	7179                	addi	sp,sp,-48
    80003228:	f406                	sd	ra,40(sp)
    8000322a:	f022                	sd	s0,32(sp)
    8000322c:	ec26                	sd	s1,24(sp)
    8000322e:	e84a                	sd	s2,16(sp)
    80003230:	e44e                	sd	s3,8(sp)
    80003232:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003234:	00004597          	auipc	a1,0x4
    80003238:	2bc58593          	addi	a1,a1,700 # 800074f0 <etext+0x4f0>
    8000323c:	0001b517          	auipc	a0,0x1b
    80003240:	d4450513          	addi	a0,a0,-700 # 8001df80 <itable>
    80003244:	95bfd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003248:	0001b497          	auipc	s1,0x1b
    8000324c:	d6048493          	addi	s1,s1,-672 # 8001dfa8 <itable+0x28>
    80003250:	0001c997          	auipc	s3,0x1c
    80003254:	7e898993          	addi	s3,s3,2024 # 8001fa38 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003258:	00004917          	auipc	s2,0x4
    8000325c:	2a090913          	addi	s2,s2,672 # 800074f8 <etext+0x4f8>
    80003260:	85ca                	mv	a1,s2
    80003262:	8526                	mv	a0,s1
    80003264:	5f5000ef          	jal	80004058 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003268:	08848493          	addi	s1,s1,136
    8000326c:	ff349ae3          	bne	s1,s3,80003260 <iinit+0x3a>
}
    80003270:	70a2                	ld	ra,40(sp)
    80003272:	7402                	ld	s0,32(sp)
    80003274:	64e2                	ld	s1,24(sp)
    80003276:	6942                	ld	s2,16(sp)
    80003278:	69a2                	ld	s3,8(sp)
    8000327a:	6145                	addi	sp,sp,48
    8000327c:	8082                	ret

000000008000327e <ialloc>:
{
    8000327e:	7139                	addi	sp,sp,-64
    80003280:	fc06                	sd	ra,56(sp)
    80003282:	f822                	sd	s0,48(sp)
    80003284:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003286:	0001b717          	auipc	a4,0x1b
    8000328a:	ce672703          	lw	a4,-794(a4) # 8001df6c <sb+0xc>
    8000328e:	4785                	li	a5,1
    80003290:	06e7f063          	bgeu	a5,a4,800032f0 <ialloc+0x72>
    80003294:	f426                	sd	s1,40(sp)
    80003296:	f04a                	sd	s2,32(sp)
    80003298:	ec4e                	sd	s3,24(sp)
    8000329a:	e852                	sd	s4,16(sp)
    8000329c:	e456                	sd	s5,8(sp)
    8000329e:	e05a                	sd	s6,0(sp)
    800032a0:	8aaa                	mv	s5,a0
    800032a2:	8b2e                	mv	s6,a1
    800032a4:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800032a6:	0001ba17          	auipc	s4,0x1b
    800032aa:	cbaa0a13          	addi	s4,s4,-838 # 8001df60 <sb>
    800032ae:	00495593          	srli	a1,s2,0x4
    800032b2:	018a2783          	lw	a5,24(s4)
    800032b6:	9dbd                	addw	a1,a1,a5
    800032b8:	8556                	mv	a0,s5
    800032ba:	a9dff0ef          	jal	80002d56 <bread>
    800032be:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800032c0:	05850993          	addi	s3,a0,88
    800032c4:	00f97793          	andi	a5,s2,15
    800032c8:	079a                	slli	a5,a5,0x6
    800032ca:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032cc:	00099783          	lh	a5,0(s3)
    800032d0:	cb9d                	beqz	a5,80003306 <ialloc+0x88>
    brelse(bp);
    800032d2:	b8dff0ef          	jal	80002e5e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032d6:	0905                	addi	s2,s2,1
    800032d8:	00ca2703          	lw	a4,12(s4)
    800032dc:	0009079b          	sext.w	a5,s2
    800032e0:	fce7e7e3          	bltu	a5,a4,800032ae <ialloc+0x30>
    800032e4:	74a2                	ld	s1,40(sp)
    800032e6:	7902                	ld	s2,32(sp)
    800032e8:	69e2                	ld	s3,24(sp)
    800032ea:	6a42                	ld	s4,16(sp)
    800032ec:	6aa2                	ld	s5,8(sp)
    800032ee:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800032f0:	00004517          	auipc	a0,0x4
    800032f4:	21050513          	addi	a0,a0,528 # 80007500 <etext+0x500>
    800032f8:	a02fd0ef          	jal	800004fa <printf>
  return 0;
    800032fc:	4501                	li	a0,0
}
    800032fe:	70e2                	ld	ra,56(sp)
    80003300:	7442                	ld	s0,48(sp)
    80003302:	6121                	addi	sp,sp,64
    80003304:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003306:	04000613          	li	a2,64
    8000330a:	4581                	li	a1,0
    8000330c:	854e                	mv	a0,s3
    8000330e:	9ebfd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003312:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003316:	8526                	mv	a0,s1
    80003318:	47d000ef          	jal	80003f94 <log_write>
      brelse(bp);
    8000331c:	8526                	mv	a0,s1
    8000331e:	b41ff0ef          	jal	80002e5e <brelse>
      return iget(dev, inum);
    80003322:	0009059b          	sext.w	a1,s2
    80003326:	8556                	mv	a0,s5
    80003328:	e55ff0ef          	jal	8000317c <iget>
    8000332c:	74a2                	ld	s1,40(sp)
    8000332e:	7902                	ld	s2,32(sp)
    80003330:	69e2                	ld	s3,24(sp)
    80003332:	6a42                	ld	s4,16(sp)
    80003334:	6aa2                	ld	s5,8(sp)
    80003336:	6b02                	ld	s6,0(sp)
    80003338:	b7d9                	j	800032fe <ialloc+0x80>

000000008000333a <iupdate>:
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	e04a                	sd	s2,0(sp)
    80003344:	1000                	addi	s0,sp,32
    80003346:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003348:	415c                	lw	a5,4(a0)
    8000334a:	0047d79b          	srliw	a5,a5,0x4
    8000334e:	0001b597          	auipc	a1,0x1b
    80003352:	c2a5a583          	lw	a1,-982(a1) # 8001df78 <sb+0x18>
    80003356:	9dbd                	addw	a1,a1,a5
    80003358:	4108                	lw	a0,0(a0)
    8000335a:	9fdff0ef          	jal	80002d56 <bread>
    8000335e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003360:	05850793          	addi	a5,a0,88
    80003364:	40d8                	lw	a4,4(s1)
    80003366:	8b3d                	andi	a4,a4,15
    80003368:	071a                	slli	a4,a4,0x6
    8000336a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000336c:	04449703          	lh	a4,68(s1)
    80003370:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003374:	04649703          	lh	a4,70(s1)
    80003378:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000337c:	04849703          	lh	a4,72(s1)
    80003380:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003384:	04a49703          	lh	a4,74(s1)
    80003388:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000338c:	44f8                	lw	a4,76(s1)
    8000338e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003390:	03400613          	li	a2,52
    80003394:	05048593          	addi	a1,s1,80
    80003398:	00c78513          	addi	a0,a5,12
    8000339c:	9bdfd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    800033a0:	854a                	mv	a0,s2
    800033a2:	3f3000ef          	jal	80003f94 <log_write>
  brelse(bp);
    800033a6:	854a                	mv	a0,s2
    800033a8:	ab7ff0ef          	jal	80002e5e <brelse>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret

00000000800033b8 <idup>:
{
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	e426                	sd	s1,8(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033c4:	0001b517          	auipc	a0,0x1b
    800033c8:	bbc50513          	addi	a0,a0,-1092 # 8001df80 <itable>
    800033cc:	85dfd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    800033d0:	449c                	lw	a5,8(s1)
    800033d2:	2785                	addiw	a5,a5,1
    800033d4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033d6:	0001b517          	auipc	a0,0x1b
    800033da:	baa50513          	addi	a0,a0,-1110 # 8001df80 <itable>
    800033de:	8dffd0ef          	jal	80000cbc <release>
}
    800033e2:	8526                	mv	a0,s1
    800033e4:	60e2                	ld	ra,24(sp)
    800033e6:	6442                	ld	s0,16(sp)
    800033e8:	64a2                	ld	s1,8(sp)
    800033ea:	6105                	addi	sp,sp,32
    800033ec:	8082                	ret

00000000800033ee <ilock>:
{
    800033ee:	1101                	addi	sp,sp,-32
    800033f0:	ec06                	sd	ra,24(sp)
    800033f2:	e822                	sd	s0,16(sp)
    800033f4:	e426                	sd	s1,8(sp)
    800033f6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033f8:	cd19                	beqz	a0,80003416 <ilock+0x28>
    800033fa:	84aa                	mv	s1,a0
    800033fc:	451c                	lw	a5,8(a0)
    800033fe:	00f05c63          	blez	a5,80003416 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003402:	0541                	addi	a0,a0,16
    80003404:	48b000ef          	jal	8000408e <acquiresleep>
  if(ip->valid == 0){
    80003408:	40bc                	lw	a5,64(s1)
    8000340a:	cf89                	beqz	a5,80003424 <ilock+0x36>
}
    8000340c:	60e2                	ld	ra,24(sp)
    8000340e:	6442                	ld	s0,16(sp)
    80003410:	64a2                	ld	s1,8(sp)
    80003412:	6105                	addi	sp,sp,32
    80003414:	8082                	ret
    80003416:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003418:	00004517          	auipc	a0,0x4
    8000341c:	10050513          	addi	a0,a0,256 # 80007518 <etext+0x518>
    80003420:	c04fd0ef          	jal	80000824 <panic>
    80003424:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003426:	40dc                	lw	a5,4(s1)
    80003428:	0047d79b          	srliw	a5,a5,0x4
    8000342c:	0001b597          	auipc	a1,0x1b
    80003430:	b4c5a583          	lw	a1,-1204(a1) # 8001df78 <sb+0x18>
    80003434:	9dbd                	addw	a1,a1,a5
    80003436:	4088                	lw	a0,0(s1)
    80003438:	91fff0ef          	jal	80002d56 <bread>
    8000343c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000343e:	05850593          	addi	a1,a0,88
    80003442:	40dc                	lw	a5,4(s1)
    80003444:	8bbd                	andi	a5,a5,15
    80003446:	079a                	slli	a5,a5,0x6
    80003448:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000344a:	00059783          	lh	a5,0(a1)
    8000344e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003452:	00259783          	lh	a5,2(a1)
    80003456:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000345a:	00459783          	lh	a5,4(a1)
    8000345e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003462:	00659783          	lh	a5,6(a1)
    80003466:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000346a:	459c                	lw	a5,8(a1)
    8000346c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000346e:	03400613          	li	a2,52
    80003472:	05b1                	addi	a1,a1,12
    80003474:	05048513          	addi	a0,s1,80
    80003478:	8e1fd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    8000347c:	854a                	mv	a0,s2
    8000347e:	9e1ff0ef          	jal	80002e5e <brelse>
    ip->valid = 1;
    80003482:	4785                	li	a5,1
    80003484:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003486:	04449783          	lh	a5,68(s1)
    8000348a:	c399                	beqz	a5,80003490 <ilock+0xa2>
    8000348c:	6902                	ld	s2,0(sp)
    8000348e:	bfbd                	j	8000340c <ilock+0x1e>
      panic("ilock: no type");
    80003490:	00004517          	auipc	a0,0x4
    80003494:	09050513          	addi	a0,a0,144 # 80007520 <etext+0x520>
    80003498:	b8cfd0ef          	jal	80000824 <panic>

000000008000349c <iunlock>:
{
    8000349c:	1101                	addi	sp,sp,-32
    8000349e:	ec06                	sd	ra,24(sp)
    800034a0:	e822                	sd	s0,16(sp)
    800034a2:	e426                	sd	s1,8(sp)
    800034a4:	e04a                	sd	s2,0(sp)
    800034a6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034a8:	c505                	beqz	a0,800034d0 <iunlock+0x34>
    800034aa:	84aa                	mv	s1,a0
    800034ac:	01050913          	addi	s2,a0,16
    800034b0:	854a                	mv	a0,s2
    800034b2:	45b000ef          	jal	8000410c <holdingsleep>
    800034b6:	cd09                	beqz	a0,800034d0 <iunlock+0x34>
    800034b8:	449c                	lw	a5,8(s1)
    800034ba:	00f05b63          	blez	a5,800034d0 <iunlock+0x34>
  releasesleep(&ip->lock);
    800034be:	854a                	mv	a0,s2
    800034c0:	415000ef          	jal	800040d4 <releasesleep>
}
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6902                	ld	s2,0(sp)
    800034cc:	6105                	addi	sp,sp,32
    800034ce:	8082                	ret
    panic("iunlock");
    800034d0:	00004517          	auipc	a0,0x4
    800034d4:	06050513          	addi	a0,a0,96 # 80007530 <etext+0x530>
    800034d8:	b4cfd0ef          	jal	80000824 <panic>

00000000800034dc <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800034dc:	7179                	addi	sp,sp,-48
    800034de:	f406                	sd	ra,40(sp)
    800034e0:	f022                	sd	s0,32(sp)
    800034e2:	ec26                	sd	s1,24(sp)
    800034e4:	e84a                	sd	s2,16(sp)
    800034e6:	e44e                	sd	s3,8(sp)
    800034e8:	1800                	addi	s0,sp,48
    800034ea:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800034ec:	05050493          	addi	s1,a0,80
    800034f0:	08050913          	addi	s2,a0,128
    800034f4:	a021                	j	800034fc <itrunc+0x20>
    800034f6:	0491                	addi	s1,s1,4
    800034f8:	01248b63          	beq	s1,s2,8000350e <itrunc+0x32>
    if(ip->addrs[i]){
    800034fc:	408c                	lw	a1,0(s1)
    800034fe:	dde5                	beqz	a1,800034f6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003500:	0009a503          	lw	a0,0(s3)
    80003504:	a47ff0ef          	jal	80002f4a <bfree>
      ip->addrs[i] = 0;
    80003508:	0004a023          	sw	zero,0(s1)
    8000350c:	b7ed                	j	800034f6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000350e:	0809a583          	lw	a1,128(s3)
    80003512:	ed89                	bnez	a1,8000352c <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003514:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003518:	854e                	mv	a0,s3
    8000351a:	e21ff0ef          	jal	8000333a <iupdate>
}
    8000351e:	70a2                	ld	ra,40(sp)
    80003520:	7402                	ld	s0,32(sp)
    80003522:	64e2                	ld	s1,24(sp)
    80003524:	6942                	ld	s2,16(sp)
    80003526:	69a2                	ld	s3,8(sp)
    80003528:	6145                	addi	sp,sp,48
    8000352a:	8082                	ret
    8000352c:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000352e:	0009a503          	lw	a0,0(s3)
    80003532:	825ff0ef          	jal	80002d56 <bread>
    80003536:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003538:	05850493          	addi	s1,a0,88
    8000353c:	45850913          	addi	s2,a0,1112
    80003540:	a021                	j	80003548 <itrunc+0x6c>
    80003542:	0491                	addi	s1,s1,4
    80003544:	01248963          	beq	s1,s2,80003556 <itrunc+0x7a>
      if(a[j])
    80003548:	408c                	lw	a1,0(s1)
    8000354a:	dde5                	beqz	a1,80003542 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000354c:	0009a503          	lw	a0,0(s3)
    80003550:	9fbff0ef          	jal	80002f4a <bfree>
    80003554:	b7fd                	j	80003542 <itrunc+0x66>
    brelse(bp);
    80003556:	8552                	mv	a0,s4
    80003558:	907ff0ef          	jal	80002e5e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000355c:	0809a583          	lw	a1,128(s3)
    80003560:	0009a503          	lw	a0,0(s3)
    80003564:	9e7ff0ef          	jal	80002f4a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003568:	0809a023          	sw	zero,128(s3)
    8000356c:	6a02                	ld	s4,0(sp)
    8000356e:	b75d                	j	80003514 <itrunc+0x38>

0000000080003570 <iput>:
{
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	1000                	addi	s0,sp,32
    8000357a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000357c:	0001b517          	auipc	a0,0x1b
    80003580:	a0450513          	addi	a0,a0,-1532 # 8001df80 <itable>
    80003584:	ea4fd0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003588:	4498                	lw	a4,8(s1)
    8000358a:	4785                	li	a5,1
    8000358c:	02f70063          	beq	a4,a5,800035ac <iput+0x3c>
  ip->ref--;
    80003590:	449c                	lw	a5,8(s1)
    80003592:	37fd                	addiw	a5,a5,-1
    80003594:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003596:	0001b517          	auipc	a0,0x1b
    8000359a:	9ea50513          	addi	a0,a0,-1558 # 8001df80 <itable>
    8000359e:	f1efd0ef          	jal	80000cbc <release>
}
    800035a2:	60e2                	ld	ra,24(sp)
    800035a4:	6442                	ld	s0,16(sp)
    800035a6:	64a2                	ld	s1,8(sp)
    800035a8:	6105                	addi	sp,sp,32
    800035aa:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035ac:	40bc                	lw	a5,64(s1)
    800035ae:	d3ed                	beqz	a5,80003590 <iput+0x20>
    800035b0:	04a49783          	lh	a5,74(s1)
    800035b4:	fff1                	bnez	a5,80003590 <iput+0x20>
    800035b6:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800035b8:	01048793          	addi	a5,s1,16
    800035bc:	893e                	mv	s2,a5
    800035be:	853e                	mv	a0,a5
    800035c0:	2cf000ef          	jal	8000408e <acquiresleep>
    release(&itable.lock);
    800035c4:	0001b517          	auipc	a0,0x1b
    800035c8:	9bc50513          	addi	a0,a0,-1604 # 8001df80 <itable>
    800035cc:	ef0fd0ef          	jal	80000cbc <release>
    itrunc(ip);
    800035d0:	8526                	mv	a0,s1
    800035d2:	f0bff0ef          	jal	800034dc <itrunc>
    ip->type = 0;
    800035d6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035da:	8526                	mv	a0,s1
    800035dc:	d5fff0ef          	jal	8000333a <iupdate>
    ip->valid = 0;
    800035e0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035e4:	854a                	mv	a0,s2
    800035e6:	2ef000ef          	jal	800040d4 <releasesleep>
    acquire(&itable.lock);
    800035ea:	0001b517          	auipc	a0,0x1b
    800035ee:	99650513          	addi	a0,a0,-1642 # 8001df80 <itable>
    800035f2:	e36fd0ef          	jal	80000c28 <acquire>
    800035f6:	6902                	ld	s2,0(sp)
    800035f8:	bf61                	j	80003590 <iput+0x20>

00000000800035fa <iunlockput>:
{
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	1000                	addi	s0,sp,32
    80003604:	84aa                	mv	s1,a0
  iunlock(ip);
    80003606:	e97ff0ef          	jal	8000349c <iunlock>
  iput(ip);
    8000360a:	8526                	mv	a0,s1
    8000360c:	f65ff0ef          	jal	80003570 <iput>
}
    80003610:	60e2                	ld	ra,24(sp)
    80003612:	6442                	ld	s0,16(sp)
    80003614:	64a2                	ld	s1,8(sp)
    80003616:	6105                	addi	sp,sp,32
    80003618:	8082                	ret

000000008000361a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000361a:	0001b717          	auipc	a4,0x1b
    8000361e:	95272703          	lw	a4,-1710(a4) # 8001df6c <sb+0xc>
    80003622:	4785                	li	a5,1
    80003624:	0ae7fe63          	bgeu	a5,a4,800036e0 <ireclaim+0xc6>
{
    80003628:	7139                	addi	sp,sp,-64
    8000362a:	fc06                	sd	ra,56(sp)
    8000362c:	f822                	sd	s0,48(sp)
    8000362e:	f426                	sd	s1,40(sp)
    80003630:	f04a                	sd	s2,32(sp)
    80003632:	ec4e                	sd	s3,24(sp)
    80003634:	e852                	sd	s4,16(sp)
    80003636:	e456                	sd	s5,8(sp)
    80003638:	e05a                	sd	s6,0(sp)
    8000363a:	0080                	addi	s0,sp,64
    8000363c:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000363e:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003640:	0001ba17          	auipc	s4,0x1b
    80003644:	920a0a13          	addi	s4,s4,-1760 # 8001df60 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003648:	00004b17          	auipc	s6,0x4
    8000364c:	ef0b0b13          	addi	s6,s6,-272 # 80007538 <etext+0x538>
    80003650:	a099                	j	80003696 <ireclaim+0x7c>
    80003652:	85ce                	mv	a1,s3
    80003654:	855a                	mv	a0,s6
    80003656:	ea5fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    8000365a:	85ce                	mv	a1,s3
    8000365c:	8556                	mv	a0,s5
    8000365e:	b1fff0ef          	jal	8000317c <iget>
    80003662:	89aa                	mv	s3,a0
    brelse(bp);
    80003664:	854a                	mv	a0,s2
    80003666:	ff8ff0ef          	jal	80002e5e <brelse>
    if (ip) {
    8000366a:	00098f63          	beqz	s3,80003688 <ireclaim+0x6e>
      begin_op();
    8000366e:	78c000ef          	jal	80003dfa <begin_op>
      ilock(ip);
    80003672:	854e                	mv	a0,s3
    80003674:	d7bff0ef          	jal	800033ee <ilock>
      iunlock(ip);
    80003678:	854e                	mv	a0,s3
    8000367a:	e23ff0ef          	jal	8000349c <iunlock>
      iput(ip);
    8000367e:	854e                	mv	a0,s3
    80003680:	ef1ff0ef          	jal	80003570 <iput>
      end_op();
    80003684:	7e6000ef          	jal	80003e6a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003688:	0485                	addi	s1,s1,1
    8000368a:	00ca2703          	lw	a4,12(s4)
    8000368e:	0004879b          	sext.w	a5,s1
    80003692:	02e7fd63          	bgeu	a5,a4,800036cc <ireclaim+0xb2>
    80003696:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000369a:	0044d593          	srli	a1,s1,0x4
    8000369e:	018a2783          	lw	a5,24(s4)
    800036a2:	9dbd                	addw	a1,a1,a5
    800036a4:	8556                	mv	a0,s5
    800036a6:	eb0ff0ef          	jal	80002d56 <bread>
    800036aa:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800036ac:	05850793          	addi	a5,a0,88
    800036b0:	00f9f713          	andi	a4,s3,15
    800036b4:	071a                	slli	a4,a4,0x6
    800036b6:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800036b8:	00079703          	lh	a4,0(a5)
    800036bc:	c701                	beqz	a4,800036c4 <ireclaim+0xaa>
    800036be:	00679783          	lh	a5,6(a5)
    800036c2:	dbc1                	beqz	a5,80003652 <ireclaim+0x38>
    brelse(bp);
    800036c4:	854a                	mv	a0,s2
    800036c6:	f98ff0ef          	jal	80002e5e <brelse>
    if (ip) {
    800036ca:	bf7d                	j	80003688 <ireclaim+0x6e>
}
    800036cc:	70e2                	ld	ra,56(sp)
    800036ce:	7442                	ld	s0,48(sp)
    800036d0:	74a2                	ld	s1,40(sp)
    800036d2:	7902                	ld	s2,32(sp)
    800036d4:	69e2                	ld	s3,24(sp)
    800036d6:	6a42                	ld	s4,16(sp)
    800036d8:	6aa2                	ld	s5,8(sp)
    800036da:	6b02                	ld	s6,0(sp)
    800036dc:	6121                	addi	sp,sp,64
    800036de:	8082                	ret
    800036e0:	8082                	ret

00000000800036e2 <fsinit>:
fsinit(int dev) {
    800036e2:	1101                	addi	sp,sp,-32
    800036e4:	ec06                	sd	ra,24(sp)
    800036e6:	e822                	sd	s0,16(sp)
    800036e8:	e426                	sd	s1,8(sp)
    800036ea:	e04a                	sd	s2,0(sp)
    800036ec:	1000                	addi	s0,sp,32
    800036ee:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036f0:	4585                	li	a1,1
    800036f2:	e64ff0ef          	jal	80002d56 <bread>
    800036f6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036f8:	02000613          	li	a2,32
    800036fc:	05850593          	addi	a1,a0,88
    80003700:	0001b517          	auipc	a0,0x1b
    80003704:	86050513          	addi	a0,a0,-1952 # 8001df60 <sb>
    80003708:	e50fd0ef          	jal	80000d58 <memmove>
  brelse(bp);
    8000370c:	8526                	mv	a0,s1
    8000370e:	f50ff0ef          	jal	80002e5e <brelse>
  if(sb.magic != FSMAGIC)
    80003712:	0001b717          	auipc	a4,0x1b
    80003716:	84e72703          	lw	a4,-1970(a4) # 8001df60 <sb>
    8000371a:	102037b7          	lui	a5,0x10203
    8000371e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003722:	02f71263          	bne	a4,a5,80003746 <fsinit+0x64>
  initlog(dev, &sb);
    80003726:	0001b597          	auipc	a1,0x1b
    8000372a:	83a58593          	addi	a1,a1,-1990 # 8001df60 <sb>
    8000372e:	854a                	mv	a0,s2
    80003730:	648000ef          	jal	80003d78 <initlog>
  ireclaim(dev);
    80003734:	854a                	mv	a0,s2
    80003736:	ee5ff0ef          	jal	8000361a <ireclaim>
}
    8000373a:	60e2                	ld	ra,24(sp)
    8000373c:	6442                	ld	s0,16(sp)
    8000373e:	64a2                	ld	s1,8(sp)
    80003740:	6902                	ld	s2,0(sp)
    80003742:	6105                	addi	sp,sp,32
    80003744:	8082                	ret
    panic("invalid file system");
    80003746:	00004517          	auipc	a0,0x4
    8000374a:	e1250513          	addi	a0,a0,-494 # 80007558 <etext+0x558>
    8000374e:	8d6fd0ef          	jal	80000824 <panic>

0000000080003752 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003752:	1141                	addi	sp,sp,-16
    80003754:	e406                	sd	ra,8(sp)
    80003756:	e022                	sd	s0,0(sp)
    80003758:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000375a:	411c                	lw	a5,0(a0)
    8000375c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000375e:	415c                	lw	a5,4(a0)
    80003760:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003762:	04451783          	lh	a5,68(a0)
    80003766:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000376a:	04a51783          	lh	a5,74(a0)
    8000376e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003772:	04c56783          	lwu	a5,76(a0)
    80003776:	e99c                	sd	a5,16(a1)
}
    80003778:	60a2                	ld	ra,8(sp)
    8000377a:	6402                	ld	s0,0(sp)
    8000377c:	0141                	addi	sp,sp,16
    8000377e:	8082                	ret

0000000080003780 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003780:	457c                	lw	a5,76(a0)
    80003782:	0ed7e663          	bltu	a5,a3,8000386e <readi+0xee>
{
    80003786:	7159                	addi	sp,sp,-112
    80003788:	f486                	sd	ra,104(sp)
    8000378a:	f0a2                	sd	s0,96(sp)
    8000378c:	eca6                	sd	s1,88(sp)
    8000378e:	e0d2                	sd	s4,64(sp)
    80003790:	fc56                	sd	s5,56(sp)
    80003792:	f85a                	sd	s6,48(sp)
    80003794:	f45e                	sd	s7,40(sp)
    80003796:	1880                	addi	s0,sp,112
    80003798:	8b2a                	mv	s6,a0
    8000379a:	8bae                	mv	s7,a1
    8000379c:	8a32                	mv	s4,a2
    8000379e:	84b6                	mv	s1,a3
    800037a0:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800037a2:	9f35                	addw	a4,a4,a3
    return 0;
    800037a4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800037a6:	0ad76b63          	bltu	a4,a3,8000385c <readi+0xdc>
    800037aa:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800037ac:	00e7f463          	bgeu	a5,a4,800037b4 <readi+0x34>
    n = ip->size - off;
    800037b0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b4:	080a8b63          	beqz	s5,8000384a <readi+0xca>
    800037b8:	e8ca                	sd	s2,80(sp)
    800037ba:	f062                	sd	s8,32(sp)
    800037bc:	ec66                	sd	s9,24(sp)
    800037be:	e86a                	sd	s10,16(sp)
    800037c0:	e46e                	sd	s11,8(sp)
    800037c2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800037c4:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037c8:	5c7d                	li	s8,-1
    800037ca:	a80d                	j	800037fc <readi+0x7c>
    800037cc:	020d1d93          	slli	s11,s10,0x20
    800037d0:	020ddd93          	srli	s11,s11,0x20
    800037d4:	05890613          	addi	a2,s2,88
    800037d8:	86ee                	mv	a3,s11
    800037da:	963e                	add	a2,a2,a5
    800037dc:	85d2                	mv	a1,s4
    800037de:	855e                	mv	a0,s7
    800037e0:	b69fe0ef          	jal	80002348 <either_copyout>
    800037e4:	05850363          	beq	a0,s8,8000382a <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037e8:	854a                	mv	a0,s2
    800037ea:	e74ff0ef          	jal	80002e5e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037ee:	013d09bb          	addw	s3,s10,s3
    800037f2:	009d04bb          	addw	s1,s10,s1
    800037f6:	9a6e                	add	s4,s4,s11
    800037f8:	0559f363          	bgeu	s3,s5,8000383e <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800037fc:	00a4d59b          	srliw	a1,s1,0xa
    80003800:	855a                	mv	a0,s6
    80003802:	8bbff0ef          	jal	800030bc <bmap>
    80003806:	85aa                	mv	a1,a0
    if(addr == 0)
    80003808:	c139                	beqz	a0,8000384e <readi+0xce>
    bp = bread(ip->dev, addr);
    8000380a:	000b2503          	lw	a0,0(s6)
    8000380e:	d48ff0ef          	jal	80002d56 <bread>
    80003812:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003814:	3ff4f793          	andi	a5,s1,1023
    80003818:	40fc873b          	subw	a4,s9,a5
    8000381c:	413a86bb          	subw	a3,s5,s3
    80003820:	8d3a                	mv	s10,a4
    80003822:	fae6f5e3          	bgeu	a3,a4,800037cc <readi+0x4c>
    80003826:	8d36                	mv	s10,a3
    80003828:	b755                	j	800037cc <readi+0x4c>
      brelse(bp);
    8000382a:	854a                	mv	a0,s2
    8000382c:	e32ff0ef          	jal	80002e5e <brelse>
      tot = -1;
    80003830:	59fd                	li	s3,-1
      break;
    80003832:	6946                	ld	s2,80(sp)
    80003834:	7c02                	ld	s8,32(sp)
    80003836:	6ce2                	ld	s9,24(sp)
    80003838:	6d42                	ld	s10,16(sp)
    8000383a:	6da2                	ld	s11,8(sp)
    8000383c:	a831                	j	80003858 <readi+0xd8>
    8000383e:	6946                	ld	s2,80(sp)
    80003840:	7c02                	ld	s8,32(sp)
    80003842:	6ce2                	ld	s9,24(sp)
    80003844:	6d42                	ld	s10,16(sp)
    80003846:	6da2                	ld	s11,8(sp)
    80003848:	a801                	j	80003858 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000384a:	89d6                	mv	s3,s5
    8000384c:	a031                	j	80003858 <readi+0xd8>
    8000384e:	6946                	ld	s2,80(sp)
    80003850:	7c02                	ld	s8,32(sp)
    80003852:	6ce2                	ld	s9,24(sp)
    80003854:	6d42                	ld	s10,16(sp)
    80003856:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003858:	854e                	mv	a0,s3
    8000385a:	69a6                	ld	s3,72(sp)
}
    8000385c:	70a6                	ld	ra,104(sp)
    8000385e:	7406                	ld	s0,96(sp)
    80003860:	64e6                	ld	s1,88(sp)
    80003862:	6a06                	ld	s4,64(sp)
    80003864:	7ae2                	ld	s5,56(sp)
    80003866:	7b42                	ld	s6,48(sp)
    80003868:	7ba2                	ld	s7,40(sp)
    8000386a:	6165                	addi	sp,sp,112
    8000386c:	8082                	ret
    return 0;
    8000386e:	4501                	li	a0,0
}
    80003870:	8082                	ret

0000000080003872 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003872:	457c                	lw	a5,76(a0)
    80003874:	0ed7eb63          	bltu	a5,a3,8000396a <writei+0xf8>
{
    80003878:	7159                	addi	sp,sp,-112
    8000387a:	f486                	sd	ra,104(sp)
    8000387c:	f0a2                	sd	s0,96(sp)
    8000387e:	e8ca                	sd	s2,80(sp)
    80003880:	e0d2                	sd	s4,64(sp)
    80003882:	fc56                	sd	s5,56(sp)
    80003884:	f85a                	sd	s6,48(sp)
    80003886:	f45e                	sd	s7,40(sp)
    80003888:	1880                	addi	s0,sp,112
    8000388a:	8aaa                	mv	s5,a0
    8000388c:	8bae                	mv	s7,a1
    8000388e:	8a32                	mv	s4,a2
    80003890:	8936                	mv	s2,a3
    80003892:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003894:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003898:	00043737          	lui	a4,0x43
    8000389c:	0cf76963          	bltu	a4,a5,8000396e <writei+0xfc>
    800038a0:	0cd7e763          	bltu	a5,a3,8000396e <writei+0xfc>
    800038a4:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038a6:	0a0b0a63          	beqz	s6,8000395a <writei+0xe8>
    800038aa:	eca6                	sd	s1,88(sp)
    800038ac:	f062                	sd	s8,32(sp)
    800038ae:	ec66                	sd	s9,24(sp)
    800038b0:	e86a                	sd	s10,16(sp)
    800038b2:	e46e                	sd	s11,8(sp)
    800038b4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038b6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800038ba:	5c7d                	li	s8,-1
    800038bc:	a825                	j	800038f4 <writei+0x82>
    800038be:	020d1d93          	slli	s11,s10,0x20
    800038c2:	020ddd93          	srli	s11,s11,0x20
    800038c6:	05848513          	addi	a0,s1,88
    800038ca:	86ee                	mv	a3,s11
    800038cc:	8652                	mv	a2,s4
    800038ce:	85de                	mv	a1,s7
    800038d0:	953e                	add	a0,a0,a5
    800038d2:	ac1fe0ef          	jal	80002392 <either_copyin>
    800038d6:	05850663          	beq	a0,s8,80003922 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800038da:	8526                	mv	a0,s1
    800038dc:	6b8000ef          	jal	80003f94 <log_write>
    brelse(bp);
    800038e0:	8526                	mv	a0,s1
    800038e2:	d7cff0ef          	jal	80002e5e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038e6:	013d09bb          	addw	s3,s10,s3
    800038ea:	012d093b          	addw	s2,s10,s2
    800038ee:	9a6e                	add	s4,s4,s11
    800038f0:	0369fc63          	bgeu	s3,s6,80003928 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800038f4:	00a9559b          	srliw	a1,s2,0xa
    800038f8:	8556                	mv	a0,s5
    800038fa:	fc2ff0ef          	jal	800030bc <bmap>
    800038fe:	85aa                	mv	a1,a0
    if(addr == 0)
    80003900:	c505                	beqz	a0,80003928 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003902:	000aa503          	lw	a0,0(s5)
    80003906:	c50ff0ef          	jal	80002d56 <bread>
    8000390a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000390c:	3ff97793          	andi	a5,s2,1023
    80003910:	40fc873b          	subw	a4,s9,a5
    80003914:	413b06bb          	subw	a3,s6,s3
    80003918:	8d3a                	mv	s10,a4
    8000391a:	fae6f2e3          	bgeu	a3,a4,800038be <writei+0x4c>
    8000391e:	8d36                	mv	s10,a3
    80003920:	bf79                	j	800038be <writei+0x4c>
      brelse(bp);
    80003922:	8526                	mv	a0,s1
    80003924:	d3aff0ef          	jal	80002e5e <brelse>
  }

  if(off > ip->size)
    80003928:	04caa783          	lw	a5,76(s5)
    8000392c:	0327f963          	bgeu	a5,s2,8000395e <writei+0xec>
    ip->size = off;
    80003930:	052aa623          	sw	s2,76(s5)
    80003934:	64e6                	ld	s1,88(sp)
    80003936:	7c02                	ld	s8,32(sp)
    80003938:	6ce2                	ld	s9,24(sp)
    8000393a:	6d42                	ld	s10,16(sp)
    8000393c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000393e:	8556                	mv	a0,s5
    80003940:	9fbff0ef          	jal	8000333a <iupdate>

  return tot;
    80003944:	854e                	mv	a0,s3
    80003946:	69a6                	ld	s3,72(sp)
}
    80003948:	70a6                	ld	ra,104(sp)
    8000394a:	7406                	ld	s0,96(sp)
    8000394c:	6946                	ld	s2,80(sp)
    8000394e:	6a06                	ld	s4,64(sp)
    80003950:	7ae2                	ld	s5,56(sp)
    80003952:	7b42                	ld	s6,48(sp)
    80003954:	7ba2                	ld	s7,40(sp)
    80003956:	6165                	addi	sp,sp,112
    80003958:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000395a:	89da                	mv	s3,s6
    8000395c:	b7cd                	j	8000393e <writei+0xcc>
    8000395e:	64e6                	ld	s1,88(sp)
    80003960:	7c02                	ld	s8,32(sp)
    80003962:	6ce2                	ld	s9,24(sp)
    80003964:	6d42                	ld	s10,16(sp)
    80003966:	6da2                	ld	s11,8(sp)
    80003968:	bfd9                	j	8000393e <writei+0xcc>
    return -1;
    8000396a:	557d                	li	a0,-1
}
    8000396c:	8082                	ret
    return -1;
    8000396e:	557d                	li	a0,-1
    80003970:	bfe1                	j	80003948 <writei+0xd6>

0000000080003972 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003972:	1141                	addi	sp,sp,-16
    80003974:	e406                	sd	ra,8(sp)
    80003976:	e022                	sd	s0,0(sp)
    80003978:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000397a:	4639                	li	a2,14
    8000397c:	c50fd0ef          	jal	80000dcc <strncmp>
}
    80003980:	60a2                	ld	ra,8(sp)
    80003982:	6402                	ld	s0,0(sp)
    80003984:	0141                	addi	sp,sp,16
    80003986:	8082                	ret

0000000080003988 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003988:	711d                	addi	sp,sp,-96
    8000398a:	ec86                	sd	ra,88(sp)
    8000398c:	e8a2                	sd	s0,80(sp)
    8000398e:	e4a6                	sd	s1,72(sp)
    80003990:	e0ca                	sd	s2,64(sp)
    80003992:	fc4e                	sd	s3,56(sp)
    80003994:	f852                	sd	s4,48(sp)
    80003996:	f456                	sd	s5,40(sp)
    80003998:	f05a                	sd	s6,32(sp)
    8000399a:	ec5e                	sd	s7,24(sp)
    8000399c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000399e:	04451703          	lh	a4,68(a0)
    800039a2:	4785                	li	a5,1
    800039a4:	00f71f63          	bne	a4,a5,800039c2 <dirlookup+0x3a>
    800039a8:	892a                	mv	s2,a0
    800039aa:	8aae                	mv	s5,a1
    800039ac:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800039ae:	457c                	lw	a5,76(a0)
    800039b0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039b2:	fa040a13          	addi	s4,s0,-96
    800039b6:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800039b8:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039bc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039be:	e39d                	bnez	a5,800039e4 <dirlookup+0x5c>
    800039c0:	a8b9                	j	80003a1e <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039c2:	00004517          	auipc	a0,0x4
    800039c6:	bae50513          	addi	a0,a0,-1106 # 80007570 <etext+0x570>
    800039ca:	e5bfc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    800039ce:	00004517          	auipc	a0,0x4
    800039d2:	bba50513          	addi	a0,a0,-1094 # 80007588 <etext+0x588>
    800039d6:	e4ffc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039da:	24c1                	addiw	s1,s1,16
    800039dc:	04c92783          	lw	a5,76(s2)
    800039e0:	02f4fe63          	bgeu	s1,a5,80003a1c <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039e4:	874e                	mv	a4,s3
    800039e6:	86a6                	mv	a3,s1
    800039e8:	8652                	mv	a2,s4
    800039ea:	4581                	li	a1,0
    800039ec:	854a                	mv	a0,s2
    800039ee:	d93ff0ef          	jal	80003780 <readi>
    800039f2:	fd351ee3          	bne	a0,s3,800039ce <dirlookup+0x46>
    if(de.inum == 0)
    800039f6:	fa045783          	lhu	a5,-96(s0)
    800039fa:	d3e5                	beqz	a5,800039da <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800039fc:	85da                	mv	a1,s6
    800039fe:	8556                	mv	a0,s5
    80003a00:	f73ff0ef          	jal	80003972 <namecmp>
    80003a04:	f979                	bnez	a0,800039da <dirlookup+0x52>
      if(poff)
    80003a06:	000b8463          	beqz	s7,80003a0e <dirlookup+0x86>
        *poff = off;
    80003a0a:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003a0e:	fa045583          	lhu	a1,-96(s0)
    80003a12:	00092503          	lw	a0,0(s2)
    80003a16:	f66ff0ef          	jal	8000317c <iget>
    80003a1a:	a011                	j	80003a1e <dirlookup+0x96>
  return 0;
    80003a1c:	4501                	li	a0,0
}
    80003a1e:	60e6                	ld	ra,88(sp)
    80003a20:	6446                	ld	s0,80(sp)
    80003a22:	64a6                	ld	s1,72(sp)
    80003a24:	6906                	ld	s2,64(sp)
    80003a26:	79e2                	ld	s3,56(sp)
    80003a28:	7a42                	ld	s4,48(sp)
    80003a2a:	7aa2                	ld	s5,40(sp)
    80003a2c:	7b02                	ld	s6,32(sp)
    80003a2e:	6be2                	ld	s7,24(sp)
    80003a30:	6125                	addi	sp,sp,96
    80003a32:	8082                	ret

0000000080003a34 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003a34:	711d                	addi	sp,sp,-96
    80003a36:	ec86                	sd	ra,88(sp)
    80003a38:	e8a2                	sd	s0,80(sp)
    80003a3a:	e4a6                	sd	s1,72(sp)
    80003a3c:	e0ca                	sd	s2,64(sp)
    80003a3e:	fc4e                	sd	s3,56(sp)
    80003a40:	f852                	sd	s4,48(sp)
    80003a42:	f456                	sd	s5,40(sp)
    80003a44:	f05a                	sd	s6,32(sp)
    80003a46:	ec5e                	sd	s7,24(sp)
    80003a48:	e862                	sd	s8,16(sp)
    80003a4a:	e466                	sd	s9,8(sp)
    80003a4c:	e06a                	sd	s10,0(sp)
    80003a4e:	1080                	addi	s0,sp,96
    80003a50:	84aa                	mv	s1,a0
    80003a52:	8b2e                	mv	s6,a1
    80003a54:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a56:	00054703          	lbu	a4,0(a0)
    80003a5a:	02f00793          	li	a5,47
    80003a5e:	00f70f63          	beq	a4,a5,80003a7c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a62:	ecdfd0ef          	jal	8000192e <myproc>
    80003a66:	15053503          	ld	a0,336(a0)
    80003a6a:	94fff0ef          	jal	800033b8 <idup>
    80003a6e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003a70:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003a74:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a76:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a78:	4b85                	li	s7,1
    80003a7a:	a879                	j	80003b18 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a7c:	4585                	li	a1,1
    80003a7e:	852e                	mv	a0,a1
    80003a80:	efcff0ef          	jal	8000317c <iget>
    80003a84:	8a2a                	mv	s4,a0
    80003a86:	b7ed                	j	80003a70 <namex+0x3c>
      iunlockput(ip);
    80003a88:	8552                	mv	a0,s4
    80003a8a:	b71ff0ef          	jal	800035fa <iunlockput>
      return 0;
    80003a8e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a90:	8552                	mv	a0,s4
    80003a92:	60e6                	ld	ra,88(sp)
    80003a94:	6446                	ld	s0,80(sp)
    80003a96:	64a6                	ld	s1,72(sp)
    80003a98:	6906                	ld	s2,64(sp)
    80003a9a:	79e2                	ld	s3,56(sp)
    80003a9c:	7a42                	ld	s4,48(sp)
    80003a9e:	7aa2                	ld	s5,40(sp)
    80003aa0:	7b02                	ld	s6,32(sp)
    80003aa2:	6be2                	ld	s7,24(sp)
    80003aa4:	6c42                	ld	s8,16(sp)
    80003aa6:	6ca2                	ld	s9,8(sp)
    80003aa8:	6d02                	ld	s10,0(sp)
    80003aaa:	6125                	addi	sp,sp,96
    80003aac:	8082                	ret
      iunlock(ip);
    80003aae:	8552                	mv	a0,s4
    80003ab0:	9edff0ef          	jal	8000349c <iunlock>
      return ip;
    80003ab4:	bff1                	j	80003a90 <namex+0x5c>
      iunlockput(ip);
    80003ab6:	8552                	mv	a0,s4
    80003ab8:	b43ff0ef          	jal	800035fa <iunlockput>
      return 0;
    80003abc:	8a4a                	mv	s4,s2
    80003abe:	bfc9                	j	80003a90 <namex+0x5c>
  len = path - s;
    80003ac0:	40990633          	sub	a2,s2,s1
    80003ac4:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ac8:	09ac5463          	bge	s8,s10,80003b50 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003acc:	8666                	mv	a2,s9
    80003ace:	85a6                	mv	a1,s1
    80003ad0:	8556                	mv	a0,s5
    80003ad2:	a86fd0ef          	jal	80000d58 <memmove>
    80003ad6:	84ca                	mv	s1,s2
  while(*path == '/')
    80003ad8:	0004c783          	lbu	a5,0(s1)
    80003adc:	01379763          	bne	a5,s3,80003aea <namex+0xb6>
    path++;
    80003ae0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ae2:	0004c783          	lbu	a5,0(s1)
    80003ae6:	ff378de3          	beq	a5,s3,80003ae0 <namex+0xac>
    ilock(ip);
    80003aea:	8552                	mv	a0,s4
    80003aec:	903ff0ef          	jal	800033ee <ilock>
    if(ip->type != T_DIR){
    80003af0:	044a1783          	lh	a5,68(s4)
    80003af4:	f9779ae3          	bne	a5,s7,80003a88 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003af8:	000b0563          	beqz	s6,80003b02 <namex+0xce>
    80003afc:	0004c783          	lbu	a5,0(s1)
    80003b00:	d7dd                	beqz	a5,80003aae <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003b02:	4601                	li	a2,0
    80003b04:	85d6                	mv	a1,s5
    80003b06:	8552                	mv	a0,s4
    80003b08:	e81ff0ef          	jal	80003988 <dirlookup>
    80003b0c:	892a                	mv	s2,a0
    80003b0e:	d545                	beqz	a0,80003ab6 <namex+0x82>
    iunlockput(ip);
    80003b10:	8552                	mv	a0,s4
    80003b12:	ae9ff0ef          	jal	800035fa <iunlockput>
    ip = next;
    80003b16:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003b18:	0004c783          	lbu	a5,0(s1)
    80003b1c:	01379763          	bne	a5,s3,80003b2a <namex+0xf6>
    path++;
    80003b20:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003b22:	0004c783          	lbu	a5,0(s1)
    80003b26:	ff378de3          	beq	a5,s3,80003b20 <namex+0xec>
  if(*path == 0)
    80003b2a:	cf8d                	beqz	a5,80003b64 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003b2c:	0004c783          	lbu	a5,0(s1)
    80003b30:	fd178713          	addi	a4,a5,-47
    80003b34:	cb19                	beqz	a4,80003b4a <namex+0x116>
    80003b36:	cb91                	beqz	a5,80003b4a <namex+0x116>
    80003b38:	8926                	mv	s2,s1
    path++;
    80003b3a:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003b3c:	00094783          	lbu	a5,0(s2)
    80003b40:	fd178713          	addi	a4,a5,-47
    80003b44:	df35                	beqz	a4,80003ac0 <namex+0x8c>
    80003b46:	fbf5                	bnez	a5,80003b3a <namex+0x106>
    80003b48:	bfa5                	j	80003ac0 <namex+0x8c>
    80003b4a:	8926                	mv	s2,s1
  len = path - s;
    80003b4c:	4d01                	li	s10,0
    80003b4e:	4601                	li	a2,0
    memmove(name, s, len);
    80003b50:	2601                	sext.w	a2,a2
    80003b52:	85a6                	mv	a1,s1
    80003b54:	8556                	mv	a0,s5
    80003b56:	a02fd0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    80003b5a:	9d56                	add	s10,s10,s5
    80003b5c:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde398>
    80003b60:	84ca                	mv	s1,s2
    80003b62:	bf9d                	j	80003ad8 <namex+0xa4>
  if(nameiparent){
    80003b64:	f20b06e3          	beqz	s6,80003a90 <namex+0x5c>
    iput(ip);
    80003b68:	8552                	mv	a0,s4
    80003b6a:	a07ff0ef          	jal	80003570 <iput>
    return 0;
    80003b6e:	4a01                	li	s4,0
    80003b70:	b705                	j	80003a90 <namex+0x5c>

0000000080003b72 <dirlink>:
{
    80003b72:	715d                	addi	sp,sp,-80
    80003b74:	e486                	sd	ra,72(sp)
    80003b76:	e0a2                	sd	s0,64(sp)
    80003b78:	f84a                	sd	s2,48(sp)
    80003b7a:	ec56                	sd	s5,24(sp)
    80003b7c:	e85a                	sd	s6,16(sp)
    80003b7e:	0880                	addi	s0,sp,80
    80003b80:	892a                	mv	s2,a0
    80003b82:	8aae                	mv	s5,a1
    80003b84:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b86:	4601                	li	a2,0
    80003b88:	e01ff0ef          	jal	80003988 <dirlookup>
    80003b8c:	ed1d                	bnez	a0,80003bca <dirlink+0x58>
    80003b8e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b90:	04c92483          	lw	s1,76(s2)
    80003b94:	c4b9                	beqz	s1,80003be2 <dirlink+0x70>
    80003b96:	f44e                	sd	s3,40(sp)
    80003b98:	f052                	sd	s4,32(sp)
    80003b9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b9c:	fb040a13          	addi	s4,s0,-80
    80003ba0:	49c1                	li	s3,16
    80003ba2:	874e                	mv	a4,s3
    80003ba4:	86a6                	mv	a3,s1
    80003ba6:	8652                	mv	a2,s4
    80003ba8:	4581                	li	a1,0
    80003baa:	854a                	mv	a0,s2
    80003bac:	bd5ff0ef          	jal	80003780 <readi>
    80003bb0:	03351163          	bne	a0,s3,80003bd2 <dirlink+0x60>
    if(de.inum == 0)
    80003bb4:	fb045783          	lhu	a5,-80(s0)
    80003bb8:	c39d                	beqz	a5,80003bde <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bba:	24c1                	addiw	s1,s1,16
    80003bbc:	04c92783          	lw	a5,76(s2)
    80003bc0:	fef4e1e3          	bltu	s1,a5,80003ba2 <dirlink+0x30>
    80003bc4:	79a2                	ld	s3,40(sp)
    80003bc6:	7a02                	ld	s4,32(sp)
    80003bc8:	a829                	j	80003be2 <dirlink+0x70>
    iput(ip);
    80003bca:	9a7ff0ef          	jal	80003570 <iput>
    return -1;
    80003bce:	557d                	li	a0,-1
    80003bd0:	a83d                	j	80003c0e <dirlink+0x9c>
      panic("dirlink read");
    80003bd2:	00004517          	auipc	a0,0x4
    80003bd6:	9c650513          	addi	a0,a0,-1594 # 80007598 <etext+0x598>
    80003bda:	c4bfc0ef          	jal	80000824 <panic>
    80003bde:	79a2                	ld	s3,40(sp)
    80003be0:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003be2:	4639                	li	a2,14
    80003be4:	85d6                	mv	a1,s5
    80003be6:	fb240513          	addi	a0,s0,-78
    80003bea:	a1cfd0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80003bee:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bf2:	4741                	li	a4,16
    80003bf4:	86a6                	mv	a3,s1
    80003bf6:	fb040613          	addi	a2,s0,-80
    80003bfa:	4581                	li	a1,0
    80003bfc:	854a                	mv	a0,s2
    80003bfe:	c75ff0ef          	jal	80003872 <writei>
    80003c02:	1541                	addi	a0,a0,-16
    80003c04:	00a03533          	snez	a0,a0
    80003c08:	40a0053b          	negw	a0,a0
    80003c0c:	74e2                	ld	s1,56(sp)
}
    80003c0e:	60a6                	ld	ra,72(sp)
    80003c10:	6406                	ld	s0,64(sp)
    80003c12:	7942                	ld	s2,48(sp)
    80003c14:	6ae2                	ld	s5,24(sp)
    80003c16:	6b42                	ld	s6,16(sp)
    80003c18:	6161                	addi	sp,sp,80
    80003c1a:	8082                	ret

0000000080003c1c <namei>:

struct inode*
namei(char *path)
{
    80003c1c:	1101                	addi	sp,sp,-32
    80003c1e:	ec06                	sd	ra,24(sp)
    80003c20:	e822                	sd	s0,16(sp)
    80003c22:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c24:	fe040613          	addi	a2,s0,-32
    80003c28:	4581                	li	a1,0
    80003c2a:	e0bff0ef          	jal	80003a34 <namex>
}
    80003c2e:	60e2                	ld	ra,24(sp)
    80003c30:	6442                	ld	s0,16(sp)
    80003c32:	6105                	addi	sp,sp,32
    80003c34:	8082                	ret

0000000080003c36 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c36:	1141                	addi	sp,sp,-16
    80003c38:	e406                	sd	ra,8(sp)
    80003c3a:	e022                	sd	s0,0(sp)
    80003c3c:	0800                	addi	s0,sp,16
    80003c3e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c40:	4585                	li	a1,1
    80003c42:	df3ff0ef          	jal	80003a34 <namex>
}
    80003c46:	60a2                	ld	ra,8(sp)
    80003c48:	6402                	ld	s0,0(sp)
    80003c4a:	0141                	addi	sp,sp,16
    80003c4c:	8082                	ret

0000000080003c4e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c4e:	1101                	addi	sp,sp,-32
    80003c50:	ec06                	sd	ra,24(sp)
    80003c52:	e822                	sd	s0,16(sp)
    80003c54:	e426                	sd	s1,8(sp)
    80003c56:	e04a                	sd	s2,0(sp)
    80003c58:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c5a:	0001c917          	auipc	s2,0x1c
    80003c5e:	dce90913          	addi	s2,s2,-562 # 8001fa28 <log>
    80003c62:	01892583          	lw	a1,24(s2)
    80003c66:	02492503          	lw	a0,36(s2)
    80003c6a:	8ecff0ef          	jal	80002d56 <bread>
    80003c6e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003c70:	02892603          	lw	a2,40(s2)
    80003c74:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c76:	00c05f63          	blez	a2,80003c94 <write_head+0x46>
    80003c7a:	0001c717          	auipc	a4,0x1c
    80003c7e:	dda70713          	addi	a4,a4,-550 # 8001fa54 <log+0x2c>
    80003c82:	87aa                	mv	a5,a0
    80003c84:	060a                	slli	a2,a2,0x2
    80003c86:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c88:	4314                	lw	a3,0(a4)
    80003c8a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c8c:	0711                	addi	a4,a4,4
    80003c8e:	0791                	addi	a5,a5,4
    80003c90:	fec79ce3          	bne	a5,a2,80003c88 <write_head+0x3a>
  }
  bwrite(buf);
    80003c94:	8526                	mv	a0,s1
    80003c96:	996ff0ef          	jal	80002e2c <bwrite>
  brelse(buf);
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	9c2ff0ef          	jal	80002e5e <brelse>
}
    80003ca0:	60e2                	ld	ra,24(sp)
    80003ca2:	6442                	ld	s0,16(sp)
    80003ca4:	64a2                	ld	s1,8(sp)
    80003ca6:	6902                	ld	s2,0(sp)
    80003ca8:	6105                	addi	sp,sp,32
    80003caa:	8082                	ret

0000000080003cac <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cac:	0001c797          	auipc	a5,0x1c
    80003cb0:	da47a783          	lw	a5,-604(a5) # 8001fa50 <log+0x28>
    80003cb4:	0cf05163          	blez	a5,80003d76 <install_trans+0xca>
{
    80003cb8:	715d                	addi	sp,sp,-80
    80003cba:	e486                	sd	ra,72(sp)
    80003cbc:	e0a2                	sd	s0,64(sp)
    80003cbe:	fc26                	sd	s1,56(sp)
    80003cc0:	f84a                	sd	s2,48(sp)
    80003cc2:	f44e                	sd	s3,40(sp)
    80003cc4:	f052                	sd	s4,32(sp)
    80003cc6:	ec56                	sd	s5,24(sp)
    80003cc8:	e85a                	sd	s6,16(sp)
    80003cca:	e45e                	sd	s7,8(sp)
    80003ccc:	e062                	sd	s8,0(sp)
    80003cce:	0880                	addi	s0,sp,80
    80003cd0:	8b2a                	mv	s6,a0
    80003cd2:	0001ca97          	auipc	s5,0x1c
    80003cd6:	d82a8a93          	addi	s5,s5,-638 # 8001fa54 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cda:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cdc:	00004c17          	auipc	s8,0x4
    80003ce0:	8ccc0c13          	addi	s8,s8,-1844 # 800075a8 <etext+0x5a8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ce4:	0001ca17          	auipc	s4,0x1c
    80003ce8:	d44a0a13          	addi	s4,s4,-700 # 8001fa28 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003cec:	40000b93          	li	s7,1024
    80003cf0:	a025                	j	80003d18 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cf2:	000aa603          	lw	a2,0(s5)
    80003cf6:	85ce                	mv	a1,s3
    80003cf8:	8562                	mv	a0,s8
    80003cfa:	801fc0ef          	jal	800004fa <printf>
    80003cfe:	a839                	j	80003d1c <install_trans+0x70>
    brelse(lbuf);
    80003d00:	854a                	mv	a0,s2
    80003d02:	95cff0ef          	jal	80002e5e <brelse>
    brelse(dbuf);
    80003d06:	8526                	mv	a0,s1
    80003d08:	956ff0ef          	jal	80002e5e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d0c:	2985                	addiw	s3,s3,1
    80003d0e:	0a91                	addi	s5,s5,4
    80003d10:	028a2783          	lw	a5,40(s4)
    80003d14:	04f9d563          	bge	s3,a5,80003d5e <install_trans+0xb2>
    if(recovering) {
    80003d18:	fc0b1de3          	bnez	s6,80003cf2 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003d1c:	018a2583          	lw	a1,24(s4)
    80003d20:	013585bb          	addw	a1,a1,s3
    80003d24:	2585                	addiw	a1,a1,1
    80003d26:	024a2503          	lw	a0,36(s4)
    80003d2a:	82cff0ef          	jal	80002d56 <bread>
    80003d2e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003d30:	000aa583          	lw	a1,0(s5)
    80003d34:	024a2503          	lw	a0,36(s4)
    80003d38:	81eff0ef          	jal	80002d56 <bread>
    80003d3c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d3e:	865e                	mv	a2,s7
    80003d40:	05890593          	addi	a1,s2,88
    80003d44:	05850513          	addi	a0,a0,88
    80003d48:	810fd0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	8deff0ef          	jal	80002e2c <bwrite>
    if(recovering == 0)
    80003d52:	fa0b17e3          	bnez	s6,80003d00 <install_trans+0x54>
      bunpin(dbuf);
    80003d56:	8526                	mv	a0,s1
    80003d58:	9beff0ef          	jal	80002f16 <bunpin>
    80003d5c:	b755                	j	80003d00 <install_trans+0x54>
}
    80003d5e:	60a6                	ld	ra,72(sp)
    80003d60:	6406                	ld	s0,64(sp)
    80003d62:	74e2                	ld	s1,56(sp)
    80003d64:	7942                	ld	s2,48(sp)
    80003d66:	79a2                	ld	s3,40(sp)
    80003d68:	7a02                	ld	s4,32(sp)
    80003d6a:	6ae2                	ld	s5,24(sp)
    80003d6c:	6b42                	ld	s6,16(sp)
    80003d6e:	6ba2                	ld	s7,8(sp)
    80003d70:	6c02                	ld	s8,0(sp)
    80003d72:	6161                	addi	sp,sp,80
    80003d74:	8082                	ret
    80003d76:	8082                	ret

0000000080003d78 <initlog>:
{
    80003d78:	7179                	addi	sp,sp,-48
    80003d7a:	f406                	sd	ra,40(sp)
    80003d7c:	f022                	sd	s0,32(sp)
    80003d7e:	ec26                	sd	s1,24(sp)
    80003d80:	e84a                	sd	s2,16(sp)
    80003d82:	e44e                	sd	s3,8(sp)
    80003d84:	1800                	addi	s0,sp,48
    80003d86:	84aa                	mv	s1,a0
    80003d88:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d8a:	0001c917          	auipc	s2,0x1c
    80003d8e:	c9e90913          	addi	s2,s2,-866 # 8001fa28 <log>
    80003d92:	00004597          	auipc	a1,0x4
    80003d96:	83658593          	addi	a1,a1,-1994 # 800075c8 <etext+0x5c8>
    80003d9a:	854a                	mv	a0,s2
    80003d9c:	e03fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    80003da0:	0149a583          	lw	a1,20(s3)
    80003da4:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003da8:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003dac:	8526                	mv	a0,s1
    80003dae:	fa9fe0ef          	jal	80002d56 <bread>
  log.lh.n = lh->n;
    80003db2:	4d30                	lw	a2,88(a0)
    80003db4:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003db8:	00c05f63          	blez	a2,80003dd6 <initlog+0x5e>
    80003dbc:	87aa                	mv	a5,a0
    80003dbe:	0001c717          	auipc	a4,0x1c
    80003dc2:	c9670713          	addi	a4,a4,-874 # 8001fa54 <log+0x2c>
    80003dc6:	060a                	slli	a2,a2,0x2
    80003dc8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003dca:	4ff4                	lw	a3,92(a5)
    80003dcc:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dce:	0791                	addi	a5,a5,4
    80003dd0:	0711                	addi	a4,a4,4
    80003dd2:	fec79ce3          	bne	a5,a2,80003dca <initlog+0x52>
  brelse(buf);
    80003dd6:	888ff0ef          	jal	80002e5e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003dda:	4505                	li	a0,1
    80003ddc:	ed1ff0ef          	jal	80003cac <install_trans>
  log.lh.n = 0;
    80003de0:	0001c797          	auipc	a5,0x1c
    80003de4:	c607a823          	sw	zero,-912(a5) # 8001fa50 <log+0x28>
  write_head(); // clear the log
    80003de8:	e67ff0ef          	jal	80003c4e <write_head>
}
    80003dec:	70a2                	ld	ra,40(sp)
    80003dee:	7402                	ld	s0,32(sp)
    80003df0:	64e2                	ld	s1,24(sp)
    80003df2:	6942                	ld	s2,16(sp)
    80003df4:	69a2                	ld	s3,8(sp)
    80003df6:	6145                	addi	sp,sp,48
    80003df8:	8082                	ret

0000000080003dfa <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003dfa:	1101                	addi	sp,sp,-32
    80003dfc:	ec06                	sd	ra,24(sp)
    80003dfe:	e822                	sd	s0,16(sp)
    80003e00:	e426                	sd	s1,8(sp)
    80003e02:	e04a                	sd	s2,0(sp)
    80003e04:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003e06:	0001c517          	auipc	a0,0x1c
    80003e0a:	c2250513          	addi	a0,a0,-990 # 8001fa28 <log>
    80003e0e:	e1bfc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80003e12:	0001c497          	auipc	s1,0x1c
    80003e16:	c1648493          	addi	s1,s1,-1002 # 8001fa28 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e1a:	4979                	li	s2,30
    80003e1c:	a029                	j	80003e26 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003e1e:	85a6                	mv	a1,s1
    80003e20:	8526                	mv	a0,s1
    80003e22:	9ccfe0ef          	jal	80001fee <sleep>
    if(log.committing){
    80003e26:	509c                	lw	a5,32(s1)
    80003e28:	fbfd                	bnez	a5,80003e1e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003e2a:	4cd8                	lw	a4,28(s1)
    80003e2c:	2705                	addiw	a4,a4,1
    80003e2e:	0027179b          	slliw	a5,a4,0x2
    80003e32:	9fb9                	addw	a5,a5,a4
    80003e34:	0017979b          	slliw	a5,a5,0x1
    80003e38:	5494                	lw	a3,40(s1)
    80003e3a:	9fb5                	addw	a5,a5,a3
    80003e3c:	00f95763          	bge	s2,a5,80003e4a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003e40:	85a6                	mv	a1,s1
    80003e42:	8526                	mv	a0,s1
    80003e44:	9aafe0ef          	jal	80001fee <sleep>
    80003e48:	bff9                	j	80003e26 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003e4a:	0001c797          	auipc	a5,0x1c
    80003e4e:	bee7ad23          	sw	a4,-1030(a5) # 8001fa44 <log+0x1c>
      release(&log.lock);
    80003e52:	0001c517          	auipc	a0,0x1c
    80003e56:	bd650513          	addi	a0,a0,-1066 # 8001fa28 <log>
    80003e5a:	e63fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    80003e5e:	60e2                	ld	ra,24(sp)
    80003e60:	6442                	ld	s0,16(sp)
    80003e62:	64a2                	ld	s1,8(sp)
    80003e64:	6902                	ld	s2,0(sp)
    80003e66:	6105                	addi	sp,sp,32
    80003e68:	8082                	ret

0000000080003e6a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e6a:	7139                	addi	sp,sp,-64
    80003e6c:	fc06                	sd	ra,56(sp)
    80003e6e:	f822                	sd	s0,48(sp)
    80003e70:	f426                	sd	s1,40(sp)
    80003e72:	f04a                	sd	s2,32(sp)
    80003e74:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e76:	0001c497          	auipc	s1,0x1c
    80003e7a:	bb248493          	addi	s1,s1,-1102 # 8001fa28 <log>
    80003e7e:	8526                	mv	a0,s1
    80003e80:	da9fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    80003e84:	4cdc                	lw	a5,28(s1)
    80003e86:	37fd                	addiw	a5,a5,-1
    80003e88:	893e                	mv	s2,a5
    80003e8a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003e8c:	509c                	lw	a5,32(s1)
    80003e8e:	e7b1                	bnez	a5,80003eda <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003e90:	04091e63          	bnez	s2,80003eec <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003e94:	0001c497          	auipc	s1,0x1c
    80003e98:	b9448493          	addi	s1,s1,-1132 # 8001fa28 <log>
    80003e9c:	4785                	li	a5,1
    80003e9e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ea0:	8526                	mv	a0,s1
    80003ea2:	e1bfc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ea6:	549c                	lw	a5,40(s1)
    80003ea8:	06f04463          	bgtz	a5,80003f10 <end_op+0xa6>
    acquire(&log.lock);
    80003eac:	0001c517          	auipc	a0,0x1c
    80003eb0:	b7c50513          	addi	a0,a0,-1156 # 8001fa28 <log>
    80003eb4:	d75fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    80003eb8:	0001c797          	auipc	a5,0x1c
    80003ebc:	b807a823          	sw	zero,-1136(a5) # 8001fa48 <log+0x20>
    wakeup(&log);
    80003ec0:	0001c517          	auipc	a0,0x1c
    80003ec4:	b6850513          	addi	a0,a0,-1176 # 8001fa28 <log>
    80003ec8:	972fe0ef          	jal	8000203a <wakeup>
    release(&log.lock);
    80003ecc:	0001c517          	auipc	a0,0x1c
    80003ed0:	b5c50513          	addi	a0,a0,-1188 # 8001fa28 <log>
    80003ed4:	de9fc0ef          	jal	80000cbc <release>
}
    80003ed8:	a035                	j	80003f04 <end_op+0x9a>
    80003eda:	ec4e                	sd	s3,24(sp)
    80003edc:	e852                	sd	s4,16(sp)
    80003ede:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ee0:	00003517          	auipc	a0,0x3
    80003ee4:	6f050513          	addi	a0,a0,1776 # 800075d0 <etext+0x5d0>
    80003ee8:	93dfc0ef          	jal	80000824 <panic>
    wakeup(&log);
    80003eec:	0001c517          	auipc	a0,0x1c
    80003ef0:	b3c50513          	addi	a0,a0,-1220 # 8001fa28 <log>
    80003ef4:	946fe0ef          	jal	8000203a <wakeup>
  release(&log.lock);
    80003ef8:	0001c517          	auipc	a0,0x1c
    80003efc:	b3050513          	addi	a0,a0,-1232 # 8001fa28 <log>
    80003f00:	dbdfc0ef          	jal	80000cbc <release>
}
    80003f04:	70e2                	ld	ra,56(sp)
    80003f06:	7442                	ld	s0,48(sp)
    80003f08:	74a2                	ld	s1,40(sp)
    80003f0a:	7902                	ld	s2,32(sp)
    80003f0c:	6121                	addi	sp,sp,64
    80003f0e:	8082                	ret
    80003f10:	ec4e                	sd	s3,24(sp)
    80003f12:	e852                	sd	s4,16(sp)
    80003f14:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f16:	0001ca97          	auipc	s5,0x1c
    80003f1a:	b3ea8a93          	addi	s5,s5,-1218 # 8001fa54 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003f1e:	0001ca17          	auipc	s4,0x1c
    80003f22:	b0aa0a13          	addi	s4,s4,-1270 # 8001fa28 <log>
    80003f26:	018a2583          	lw	a1,24(s4)
    80003f2a:	012585bb          	addw	a1,a1,s2
    80003f2e:	2585                	addiw	a1,a1,1
    80003f30:	024a2503          	lw	a0,36(s4)
    80003f34:	e23fe0ef          	jal	80002d56 <bread>
    80003f38:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f3a:	000aa583          	lw	a1,0(s5)
    80003f3e:	024a2503          	lw	a0,36(s4)
    80003f42:	e15fe0ef          	jal	80002d56 <bread>
    80003f46:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f48:	40000613          	li	a2,1024
    80003f4c:	05850593          	addi	a1,a0,88
    80003f50:	05848513          	addi	a0,s1,88
    80003f54:	e05fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    80003f58:	8526                	mv	a0,s1
    80003f5a:	ed3fe0ef          	jal	80002e2c <bwrite>
    brelse(from);
    80003f5e:	854e                	mv	a0,s3
    80003f60:	efffe0ef          	jal	80002e5e <brelse>
    brelse(to);
    80003f64:	8526                	mv	a0,s1
    80003f66:	ef9fe0ef          	jal	80002e5e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f6a:	2905                	addiw	s2,s2,1
    80003f6c:	0a91                	addi	s5,s5,4
    80003f6e:	028a2783          	lw	a5,40(s4)
    80003f72:	faf94ae3          	blt	s2,a5,80003f26 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003f76:	cd9ff0ef          	jal	80003c4e <write_head>
    install_trans(0); // Now install writes to home locations
    80003f7a:	4501                	li	a0,0
    80003f7c:	d31ff0ef          	jal	80003cac <install_trans>
    log.lh.n = 0;
    80003f80:	0001c797          	auipc	a5,0x1c
    80003f84:	ac07a823          	sw	zero,-1328(a5) # 8001fa50 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003f88:	cc7ff0ef          	jal	80003c4e <write_head>
    80003f8c:	69e2                	ld	s3,24(sp)
    80003f8e:	6a42                	ld	s4,16(sp)
    80003f90:	6aa2                	ld	s5,8(sp)
    80003f92:	bf29                	j	80003eac <end_op+0x42>

0000000080003f94 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f94:	1101                	addi	sp,sp,-32
    80003f96:	ec06                	sd	ra,24(sp)
    80003f98:	e822                	sd	s0,16(sp)
    80003f9a:	e426                	sd	s1,8(sp)
    80003f9c:	1000                	addi	s0,sp,32
    80003f9e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003fa0:	0001c517          	auipc	a0,0x1c
    80003fa4:	a8850513          	addi	a0,a0,-1400 # 8001fa28 <log>
    80003fa8:	c81fc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fac:	0001c617          	auipc	a2,0x1c
    80003fb0:	aa462603          	lw	a2,-1372(a2) # 8001fa50 <log+0x28>
    80003fb4:	47f5                	li	a5,29
    80003fb6:	04c7cd63          	blt	a5,a2,80004010 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fba:	0001c797          	auipc	a5,0x1c
    80003fbe:	a8a7a783          	lw	a5,-1398(a5) # 8001fa44 <log+0x1c>
    80003fc2:	04f05d63          	blez	a5,8000401c <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fc6:	4781                	li	a5,0
    80003fc8:	06c05063          	blez	a2,80004028 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fcc:	44cc                	lw	a1,12(s1)
    80003fce:	0001c717          	auipc	a4,0x1c
    80003fd2:	a8670713          	addi	a4,a4,-1402 # 8001fa54 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003fd6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003fd8:	4314                	lw	a3,0(a4)
    80003fda:	04b68763          	beq	a3,a1,80004028 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003fde:	2785                	addiw	a5,a5,1
    80003fe0:	0711                	addi	a4,a4,4
    80003fe2:	fef61be3          	bne	a2,a5,80003fd8 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003fe6:	060a                	slli	a2,a2,0x2
    80003fe8:	02060613          	addi	a2,a2,32
    80003fec:	0001c797          	auipc	a5,0x1c
    80003ff0:	a3c78793          	addi	a5,a5,-1476 # 8001fa28 <log>
    80003ff4:	97b2                	add	a5,a5,a2
    80003ff6:	44d8                	lw	a4,12(s1)
    80003ff8:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	ee7fe0ef          	jal	80002ee2 <bpin>
    log.lh.n++;
    80004000:	0001c717          	auipc	a4,0x1c
    80004004:	a2870713          	addi	a4,a4,-1496 # 8001fa28 <log>
    80004008:	571c                	lw	a5,40(a4)
    8000400a:	2785                	addiw	a5,a5,1
    8000400c:	d71c                	sw	a5,40(a4)
    8000400e:	a815                	j	80004042 <log_write+0xae>
    panic("too big a transaction");
    80004010:	00003517          	auipc	a0,0x3
    80004014:	5d050513          	addi	a0,a0,1488 # 800075e0 <etext+0x5e0>
    80004018:	80dfc0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    8000401c:	00003517          	auipc	a0,0x3
    80004020:	5dc50513          	addi	a0,a0,1500 # 800075f8 <etext+0x5f8>
    80004024:	801fc0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    80004028:	00279693          	slli	a3,a5,0x2
    8000402c:	02068693          	addi	a3,a3,32
    80004030:	0001c717          	auipc	a4,0x1c
    80004034:	9f870713          	addi	a4,a4,-1544 # 8001fa28 <log>
    80004038:	9736                	add	a4,a4,a3
    8000403a:	44d4                	lw	a3,12(s1)
    8000403c:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000403e:	faf60ee3          	beq	a2,a5,80003ffa <log_write+0x66>
  }
  release(&log.lock);
    80004042:	0001c517          	auipc	a0,0x1c
    80004046:	9e650513          	addi	a0,a0,-1562 # 8001fa28 <log>
    8000404a:	c73fc0ef          	jal	80000cbc <release>
}
    8000404e:	60e2                	ld	ra,24(sp)
    80004050:	6442                	ld	s0,16(sp)
    80004052:	64a2                	ld	s1,8(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004058:	1101                	addi	sp,sp,-32
    8000405a:	ec06                	sd	ra,24(sp)
    8000405c:	e822                	sd	s0,16(sp)
    8000405e:	e426                	sd	s1,8(sp)
    80004060:	e04a                	sd	s2,0(sp)
    80004062:	1000                	addi	s0,sp,32
    80004064:	84aa                	mv	s1,a0
    80004066:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004068:	00003597          	auipc	a1,0x3
    8000406c:	5b058593          	addi	a1,a1,1456 # 80007618 <etext+0x618>
    80004070:	0521                	addi	a0,a0,8
    80004072:	b2dfc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    80004076:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000407a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000407e:	0204a423          	sw	zero,40(s1)
}
    80004082:	60e2                	ld	ra,24(sp)
    80004084:	6442                	ld	s0,16(sp)
    80004086:	64a2                	ld	s1,8(sp)
    80004088:	6902                	ld	s2,0(sp)
    8000408a:	6105                	addi	sp,sp,32
    8000408c:	8082                	ret

000000008000408e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000408e:	1101                	addi	sp,sp,-32
    80004090:	ec06                	sd	ra,24(sp)
    80004092:	e822                	sd	s0,16(sp)
    80004094:	e426                	sd	s1,8(sp)
    80004096:	e04a                	sd	s2,0(sp)
    80004098:	1000                	addi	s0,sp,32
    8000409a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000409c:	00850913          	addi	s2,a0,8
    800040a0:	854a                	mv	a0,s2
    800040a2:	b87fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800040a6:	409c                	lw	a5,0(s1)
    800040a8:	c799                	beqz	a5,800040b6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800040aa:	85ca                	mv	a1,s2
    800040ac:	8526                	mv	a0,s1
    800040ae:	f41fd0ef          	jal	80001fee <sleep>
  while (lk->locked) {
    800040b2:	409c                	lw	a5,0(s1)
    800040b4:	fbfd                	bnez	a5,800040aa <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800040b6:	4785                	li	a5,1
    800040b8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800040ba:	875fd0ef          	jal	8000192e <myproc>
    800040be:	591c                	lw	a5,48(a0)
    800040c0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800040c2:	854a                	mv	a0,s2
    800040c4:	bf9fc0ef          	jal	80000cbc <release>
}
    800040c8:	60e2                	ld	ra,24(sp)
    800040ca:	6442                	ld	s0,16(sp)
    800040cc:	64a2                	ld	s1,8(sp)
    800040ce:	6902                	ld	s2,0(sp)
    800040d0:	6105                	addi	sp,sp,32
    800040d2:	8082                	ret

00000000800040d4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800040d4:	1101                	addi	sp,sp,-32
    800040d6:	ec06                	sd	ra,24(sp)
    800040d8:	e822                	sd	s0,16(sp)
    800040da:	e426                	sd	s1,8(sp)
    800040dc:	e04a                	sd	s2,0(sp)
    800040de:	1000                	addi	s0,sp,32
    800040e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800040e2:	00850913          	addi	s2,a0,8
    800040e6:	854a                	mv	a0,s2
    800040e8:	b41fc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    800040ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800040f4:	8526                	mv	a0,s1
    800040f6:	f45fd0ef          	jal	8000203a <wakeup>
  release(&lk->lk);
    800040fa:	854a                	mv	a0,s2
    800040fc:	bc1fc0ef          	jal	80000cbc <release>
}
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	64a2                	ld	s1,8(sp)
    80004106:	6902                	ld	s2,0(sp)
    80004108:	6105                	addi	sp,sp,32
    8000410a:	8082                	ret

000000008000410c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000410c:	7179                	addi	sp,sp,-48
    8000410e:	f406                	sd	ra,40(sp)
    80004110:	f022                	sd	s0,32(sp)
    80004112:	ec26                	sd	s1,24(sp)
    80004114:	e84a                	sd	s2,16(sp)
    80004116:	1800                	addi	s0,sp,48
    80004118:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000411a:	00850913          	addi	s2,a0,8
    8000411e:	854a                	mv	a0,s2
    80004120:	b09fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004124:	409c                	lw	a5,0(s1)
    80004126:	ef81                	bnez	a5,8000413e <holdingsleep+0x32>
    80004128:	4481                	li	s1,0
  release(&lk->lk);
    8000412a:	854a                	mv	a0,s2
    8000412c:	b91fc0ef          	jal	80000cbc <release>
  return r;
}
    80004130:	8526                	mv	a0,s1
    80004132:	70a2                	ld	ra,40(sp)
    80004134:	7402                	ld	s0,32(sp)
    80004136:	64e2                	ld	s1,24(sp)
    80004138:	6942                	ld	s2,16(sp)
    8000413a:	6145                	addi	sp,sp,48
    8000413c:	8082                	ret
    8000413e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004140:	0284a983          	lw	s3,40(s1)
    80004144:	feafd0ef          	jal	8000192e <myproc>
    80004148:	5904                	lw	s1,48(a0)
    8000414a:	413484b3          	sub	s1,s1,s3
    8000414e:	0014b493          	seqz	s1,s1
    80004152:	69a2                	ld	s3,8(sp)
    80004154:	bfd9                	j	8000412a <holdingsleep+0x1e>

0000000080004156 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004156:	1141                	addi	sp,sp,-16
    80004158:	e406                	sd	ra,8(sp)
    8000415a:	e022                	sd	s0,0(sp)
    8000415c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000415e:	00003597          	auipc	a1,0x3
    80004162:	4ca58593          	addi	a1,a1,1226 # 80007628 <etext+0x628>
    80004166:	0001c517          	auipc	a0,0x1c
    8000416a:	a0a50513          	addi	a0,a0,-1526 # 8001fb70 <ftable>
    8000416e:	a31fc0ef          	jal	80000b9e <initlock>
}
    80004172:	60a2                	ld	ra,8(sp)
    80004174:	6402                	ld	s0,0(sp)
    80004176:	0141                	addi	sp,sp,16
    80004178:	8082                	ret

000000008000417a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000417a:	1101                	addi	sp,sp,-32
    8000417c:	ec06                	sd	ra,24(sp)
    8000417e:	e822                	sd	s0,16(sp)
    80004180:	e426                	sd	s1,8(sp)
    80004182:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004184:	0001c517          	auipc	a0,0x1c
    80004188:	9ec50513          	addi	a0,a0,-1556 # 8001fb70 <ftable>
    8000418c:	a9dfc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004190:	0001c497          	auipc	s1,0x1c
    80004194:	9f848493          	addi	s1,s1,-1544 # 8001fb88 <ftable+0x18>
    80004198:	0001d717          	auipc	a4,0x1d
    8000419c:	99070713          	addi	a4,a4,-1648 # 80020b28 <disk>
    if(f->ref == 0){
    800041a0:	40dc                	lw	a5,4(s1)
    800041a2:	cf89                	beqz	a5,800041bc <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800041a4:	02848493          	addi	s1,s1,40
    800041a8:	fee49ce3          	bne	s1,a4,800041a0 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800041ac:	0001c517          	auipc	a0,0x1c
    800041b0:	9c450513          	addi	a0,a0,-1596 # 8001fb70 <ftable>
    800041b4:	b09fc0ef          	jal	80000cbc <release>
  return 0;
    800041b8:	4481                	li	s1,0
    800041ba:	a809                	j	800041cc <filealloc+0x52>
      f->ref = 1;
    800041bc:	4785                	li	a5,1
    800041be:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800041c0:	0001c517          	auipc	a0,0x1c
    800041c4:	9b050513          	addi	a0,a0,-1616 # 8001fb70 <ftable>
    800041c8:	af5fc0ef          	jal	80000cbc <release>
}
    800041cc:	8526                	mv	a0,s1
    800041ce:	60e2                	ld	ra,24(sp)
    800041d0:	6442                	ld	s0,16(sp)
    800041d2:	64a2                	ld	s1,8(sp)
    800041d4:	6105                	addi	sp,sp,32
    800041d6:	8082                	ret

00000000800041d8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800041d8:	1101                	addi	sp,sp,-32
    800041da:	ec06                	sd	ra,24(sp)
    800041dc:	e822                	sd	s0,16(sp)
    800041de:	e426                	sd	s1,8(sp)
    800041e0:	1000                	addi	s0,sp,32
    800041e2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800041e4:	0001c517          	auipc	a0,0x1c
    800041e8:	98c50513          	addi	a0,a0,-1652 # 8001fb70 <ftable>
    800041ec:	a3dfc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    800041f0:	40dc                	lw	a5,4(s1)
    800041f2:	02f05063          	blez	a5,80004212 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800041f6:	2785                	addiw	a5,a5,1
    800041f8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800041fa:	0001c517          	auipc	a0,0x1c
    800041fe:	97650513          	addi	a0,a0,-1674 # 8001fb70 <ftable>
    80004202:	abbfc0ef          	jal	80000cbc <release>
  return f;
}
    80004206:	8526                	mv	a0,s1
    80004208:	60e2                	ld	ra,24(sp)
    8000420a:	6442                	ld	s0,16(sp)
    8000420c:	64a2                	ld	s1,8(sp)
    8000420e:	6105                	addi	sp,sp,32
    80004210:	8082                	ret
    panic("filedup");
    80004212:	00003517          	auipc	a0,0x3
    80004216:	41e50513          	addi	a0,a0,1054 # 80007630 <etext+0x630>
    8000421a:	e0afc0ef          	jal	80000824 <panic>

000000008000421e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000421e:	7139                	addi	sp,sp,-64
    80004220:	fc06                	sd	ra,56(sp)
    80004222:	f822                	sd	s0,48(sp)
    80004224:	f426                	sd	s1,40(sp)
    80004226:	0080                	addi	s0,sp,64
    80004228:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000422a:	0001c517          	auipc	a0,0x1c
    8000422e:	94650513          	addi	a0,a0,-1722 # 8001fb70 <ftable>
    80004232:	9f7fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004236:	40dc                	lw	a5,4(s1)
    80004238:	04f05a63          	blez	a5,8000428c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000423c:	37fd                	addiw	a5,a5,-1
    8000423e:	c0dc                	sw	a5,4(s1)
    80004240:	06f04063          	bgtz	a5,800042a0 <fileclose+0x82>
    80004244:	f04a                	sd	s2,32(sp)
    80004246:	ec4e                	sd	s3,24(sp)
    80004248:	e852                	sd	s4,16(sp)
    8000424a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000424c:	0004a903          	lw	s2,0(s1)
    80004250:	0094c783          	lbu	a5,9(s1)
    80004254:	89be                	mv	s3,a5
    80004256:	689c                	ld	a5,16(s1)
    80004258:	8a3e                	mv	s4,a5
    8000425a:	6c9c                	ld	a5,24(s1)
    8000425c:	8abe                	mv	s5,a5
  f->ref = 0;
    8000425e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004262:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004266:	0001c517          	auipc	a0,0x1c
    8000426a:	90a50513          	addi	a0,a0,-1782 # 8001fb70 <ftable>
    8000426e:	a4ffc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004272:	4785                	li	a5,1
    80004274:	04f90163          	beq	s2,a5,800042b6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004278:	ffe9079b          	addiw	a5,s2,-2
    8000427c:	4705                	li	a4,1
    8000427e:	04f77563          	bgeu	a4,a5,800042c8 <fileclose+0xaa>
    80004282:	7902                	ld	s2,32(sp)
    80004284:	69e2                	ld	s3,24(sp)
    80004286:	6a42                	ld	s4,16(sp)
    80004288:	6aa2                	ld	s5,8(sp)
    8000428a:	a00d                	j	800042ac <fileclose+0x8e>
    8000428c:	f04a                	sd	s2,32(sp)
    8000428e:	ec4e                	sd	s3,24(sp)
    80004290:	e852                	sd	s4,16(sp)
    80004292:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004294:	00003517          	auipc	a0,0x3
    80004298:	3a450513          	addi	a0,a0,932 # 80007638 <etext+0x638>
    8000429c:	d88fc0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    800042a0:	0001c517          	auipc	a0,0x1c
    800042a4:	8d050513          	addi	a0,a0,-1840 # 8001fb70 <ftable>
    800042a8:	a15fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800042ac:	70e2                	ld	ra,56(sp)
    800042ae:	7442                	ld	s0,48(sp)
    800042b0:	74a2                	ld	s1,40(sp)
    800042b2:	6121                	addi	sp,sp,64
    800042b4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800042b6:	85ce                	mv	a1,s3
    800042b8:	8552                	mv	a0,s4
    800042ba:	380000ef          	jal	8000463a <pipeclose>
    800042be:	7902                	ld	s2,32(sp)
    800042c0:	69e2                	ld	s3,24(sp)
    800042c2:	6a42                	ld	s4,16(sp)
    800042c4:	6aa2                	ld	s5,8(sp)
    800042c6:	b7dd                	j	800042ac <fileclose+0x8e>
    begin_op();
    800042c8:	b33ff0ef          	jal	80003dfa <begin_op>
    iput(ff.ip);
    800042cc:	8556                	mv	a0,s5
    800042ce:	aa2ff0ef          	jal	80003570 <iput>
    end_op();
    800042d2:	b99ff0ef          	jal	80003e6a <end_op>
    800042d6:	7902                	ld	s2,32(sp)
    800042d8:	69e2                	ld	s3,24(sp)
    800042da:	6a42                	ld	s4,16(sp)
    800042dc:	6aa2                	ld	s5,8(sp)
    800042de:	b7f9                	j	800042ac <fileclose+0x8e>

00000000800042e0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800042e0:	715d                	addi	sp,sp,-80
    800042e2:	e486                	sd	ra,72(sp)
    800042e4:	e0a2                	sd	s0,64(sp)
    800042e6:	fc26                	sd	s1,56(sp)
    800042e8:	f052                	sd	s4,32(sp)
    800042ea:	0880                	addi	s0,sp,80
    800042ec:	84aa                	mv	s1,a0
    800042ee:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800042f0:	e3efd0ef          	jal	8000192e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800042f4:	409c                	lw	a5,0(s1)
    800042f6:	37f9                	addiw	a5,a5,-2
    800042f8:	4705                	li	a4,1
    800042fa:	04f76263          	bltu	a4,a5,8000433e <filestat+0x5e>
    800042fe:	f84a                	sd	s2,48(sp)
    80004300:	f44e                	sd	s3,40(sp)
    80004302:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004304:	6c88                	ld	a0,24(s1)
    80004306:	8e8ff0ef          	jal	800033ee <ilock>
    stati(f->ip, &st);
    8000430a:	fb840913          	addi	s2,s0,-72
    8000430e:	85ca                	mv	a1,s2
    80004310:	6c88                	ld	a0,24(s1)
    80004312:	c40ff0ef          	jal	80003752 <stati>
    iunlock(f->ip);
    80004316:	6c88                	ld	a0,24(s1)
    80004318:	984ff0ef          	jal	8000349c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000431c:	46e1                	li	a3,24
    8000431e:	864a                	mv	a2,s2
    80004320:	85d2                	mv	a1,s4
    80004322:	0509b503          	ld	a0,80(s3)
    80004326:	b2efd0ef          	jal	80001654 <copyout>
    8000432a:	41f5551b          	sraiw	a0,a0,0x1f
    8000432e:	7942                	ld	s2,48(sp)
    80004330:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004332:	60a6                	ld	ra,72(sp)
    80004334:	6406                	ld	s0,64(sp)
    80004336:	74e2                	ld	s1,56(sp)
    80004338:	7a02                	ld	s4,32(sp)
    8000433a:	6161                	addi	sp,sp,80
    8000433c:	8082                	ret
  return -1;
    8000433e:	557d                	li	a0,-1
    80004340:	bfcd                	j	80004332 <filestat+0x52>

0000000080004342 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004342:	7179                	addi	sp,sp,-48
    80004344:	f406                	sd	ra,40(sp)
    80004346:	f022                	sd	s0,32(sp)
    80004348:	e84a                	sd	s2,16(sp)
    8000434a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000434c:	00854783          	lbu	a5,8(a0)
    80004350:	cfd1                	beqz	a5,800043ec <fileread+0xaa>
    80004352:	ec26                	sd	s1,24(sp)
    80004354:	e44e                	sd	s3,8(sp)
    80004356:	84aa                	mv	s1,a0
    80004358:	892e                	mv	s2,a1
    8000435a:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    8000435c:	411c                	lw	a5,0(a0)
    8000435e:	4705                	li	a4,1
    80004360:	04e78363          	beq	a5,a4,800043a6 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004364:	470d                	li	a4,3
    80004366:	04e78763          	beq	a5,a4,800043b4 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000436a:	4709                	li	a4,2
    8000436c:	06e79a63          	bne	a5,a4,800043e0 <fileread+0x9e>
    ilock(f->ip);
    80004370:	6d08                	ld	a0,24(a0)
    80004372:	87cff0ef          	jal	800033ee <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004376:	874e                	mv	a4,s3
    80004378:	5094                	lw	a3,32(s1)
    8000437a:	864a                	mv	a2,s2
    8000437c:	4585                	li	a1,1
    8000437e:	6c88                	ld	a0,24(s1)
    80004380:	c00ff0ef          	jal	80003780 <readi>
    80004384:	892a                	mv	s2,a0
    80004386:	00a05563          	blez	a0,80004390 <fileread+0x4e>
      f->off += r;
    8000438a:	509c                	lw	a5,32(s1)
    8000438c:	9fa9                	addw	a5,a5,a0
    8000438e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004390:	6c88                	ld	a0,24(s1)
    80004392:	90aff0ef          	jal	8000349c <iunlock>
    80004396:	64e2                	ld	s1,24(sp)
    80004398:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000439a:	854a                	mv	a0,s2
    8000439c:	70a2                	ld	ra,40(sp)
    8000439e:	7402                	ld	s0,32(sp)
    800043a0:	6942                	ld	s2,16(sp)
    800043a2:	6145                	addi	sp,sp,48
    800043a4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800043a6:	6908                	ld	a0,16(a0)
    800043a8:	3f8000ef          	jal	800047a0 <piperead>
    800043ac:	892a                	mv	s2,a0
    800043ae:	64e2                	ld	s1,24(sp)
    800043b0:	69a2                	ld	s3,8(sp)
    800043b2:	b7e5                	j	8000439a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800043b4:	02451783          	lh	a5,36(a0)
    800043b8:	03079693          	slli	a3,a5,0x30
    800043bc:	92c1                	srli	a3,a3,0x30
    800043be:	4725                	li	a4,9
    800043c0:	02d76963          	bltu	a4,a3,800043f2 <fileread+0xb0>
    800043c4:	0792                	slli	a5,a5,0x4
    800043c6:	0001b717          	auipc	a4,0x1b
    800043ca:	70a70713          	addi	a4,a4,1802 # 8001fad0 <devsw>
    800043ce:	97ba                	add	a5,a5,a4
    800043d0:	639c                	ld	a5,0(a5)
    800043d2:	c78d                	beqz	a5,800043fc <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800043d4:	4505                	li	a0,1
    800043d6:	9782                	jalr	a5
    800043d8:	892a                	mv	s2,a0
    800043da:	64e2                	ld	s1,24(sp)
    800043dc:	69a2                	ld	s3,8(sp)
    800043de:	bf75                	j	8000439a <fileread+0x58>
    panic("fileread");
    800043e0:	00003517          	auipc	a0,0x3
    800043e4:	26850513          	addi	a0,a0,616 # 80007648 <etext+0x648>
    800043e8:	c3cfc0ef          	jal	80000824 <panic>
    return -1;
    800043ec:	57fd                	li	a5,-1
    800043ee:	893e                	mv	s2,a5
    800043f0:	b76d                	j	8000439a <fileread+0x58>
      return -1;
    800043f2:	57fd                	li	a5,-1
    800043f4:	893e                	mv	s2,a5
    800043f6:	64e2                	ld	s1,24(sp)
    800043f8:	69a2                	ld	s3,8(sp)
    800043fa:	b745                	j	8000439a <fileread+0x58>
    800043fc:	57fd                	li	a5,-1
    800043fe:	893e                	mv	s2,a5
    80004400:	64e2                	ld	s1,24(sp)
    80004402:	69a2                	ld	s3,8(sp)
    80004404:	bf59                	j	8000439a <fileread+0x58>

0000000080004406 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004406:	00954783          	lbu	a5,9(a0)
    8000440a:	10078f63          	beqz	a5,80004528 <filewrite+0x122>
{
    8000440e:	711d                	addi	sp,sp,-96
    80004410:	ec86                	sd	ra,88(sp)
    80004412:	e8a2                	sd	s0,80(sp)
    80004414:	e0ca                	sd	s2,64(sp)
    80004416:	f456                	sd	s5,40(sp)
    80004418:	f05a                	sd	s6,32(sp)
    8000441a:	1080                	addi	s0,sp,96
    8000441c:	892a                	mv	s2,a0
    8000441e:	8b2e                	mv	s6,a1
    80004420:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004422:	411c                	lw	a5,0(a0)
    80004424:	4705                	li	a4,1
    80004426:	02e78a63          	beq	a5,a4,8000445a <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000442a:	470d                	li	a4,3
    8000442c:	02e78b63          	beq	a5,a4,80004462 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004430:	4709                	li	a4,2
    80004432:	0ce79f63          	bne	a5,a4,80004510 <filewrite+0x10a>
    80004436:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004438:	0ac05a63          	blez	a2,800044ec <filewrite+0xe6>
    8000443c:	e4a6                	sd	s1,72(sp)
    8000443e:	fc4e                	sd	s3,56(sp)
    80004440:	ec5e                	sd	s7,24(sp)
    80004442:	e862                	sd	s8,16(sp)
    80004444:	e466                	sd	s9,8(sp)
    int i = 0;
    80004446:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004448:	6b85                	lui	s7,0x1
    8000444a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000444e:	6785                	lui	a5,0x1
    80004450:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004454:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004456:	4c05                	li	s8,1
    80004458:	a8ad                	j	800044d2 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    8000445a:	6908                	ld	a0,16(a0)
    8000445c:	252000ef          	jal	800046ae <pipewrite>
    80004460:	a04d                	j	80004502 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004462:	02451783          	lh	a5,36(a0)
    80004466:	03079693          	slli	a3,a5,0x30
    8000446a:	92c1                	srli	a3,a3,0x30
    8000446c:	4725                	li	a4,9
    8000446e:	0ad76f63          	bltu	a4,a3,8000452c <filewrite+0x126>
    80004472:	0792                	slli	a5,a5,0x4
    80004474:	0001b717          	auipc	a4,0x1b
    80004478:	65c70713          	addi	a4,a4,1628 # 8001fad0 <devsw>
    8000447c:	97ba                	add	a5,a5,a4
    8000447e:	679c                	ld	a5,8(a5)
    80004480:	cbc5                	beqz	a5,80004530 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004482:	4505                	li	a0,1
    80004484:	9782                	jalr	a5
    80004486:	a8b5                	j	80004502 <filewrite+0xfc>
      if(n1 > max)
    80004488:	2981                	sext.w	s3,s3
      begin_op();
    8000448a:	971ff0ef          	jal	80003dfa <begin_op>
      ilock(f->ip);
    8000448e:	01893503          	ld	a0,24(s2)
    80004492:	f5dfe0ef          	jal	800033ee <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004496:	874e                	mv	a4,s3
    80004498:	02092683          	lw	a3,32(s2)
    8000449c:	016a0633          	add	a2,s4,s6
    800044a0:	85e2                	mv	a1,s8
    800044a2:	01893503          	ld	a0,24(s2)
    800044a6:	bccff0ef          	jal	80003872 <writei>
    800044aa:	84aa                	mv	s1,a0
    800044ac:	00a05763          	blez	a0,800044ba <filewrite+0xb4>
        f->off += r;
    800044b0:	02092783          	lw	a5,32(s2)
    800044b4:	9fa9                	addw	a5,a5,a0
    800044b6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800044ba:	01893503          	ld	a0,24(s2)
    800044be:	fdffe0ef          	jal	8000349c <iunlock>
      end_op();
    800044c2:	9a9ff0ef          	jal	80003e6a <end_op>

      if(r != n1){
    800044c6:	02999563          	bne	s3,s1,800044f0 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800044ca:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800044ce:	015a5963          	bge	s4,s5,800044e0 <filewrite+0xda>
      int n1 = n - i;
    800044d2:	414a87bb          	subw	a5,s5,s4
    800044d6:	89be                	mv	s3,a5
      if(n1 > max)
    800044d8:	fafbd8e3          	bge	s7,a5,80004488 <filewrite+0x82>
    800044dc:	89e6                	mv	s3,s9
    800044de:	b76d                	j	80004488 <filewrite+0x82>
    800044e0:	64a6                	ld	s1,72(sp)
    800044e2:	79e2                	ld	s3,56(sp)
    800044e4:	6be2                	ld	s7,24(sp)
    800044e6:	6c42                	ld	s8,16(sp)
    800044e8:	6ca2                	ld	s9,8(sp)
    800044ea:	a801                	j	800044fa <filewrite+0xf4>
    int i = 0;
    800044ec:	4a01                	li	s4,0
    800044ee:	a031                	j	800044fa <filewrite+0xf4>
    800044f0:	64a6                	ld	s1,72(sp)
    800044f2:	79e2                	ld	s3,56(sp)
    800044f4:	6be2                	ld	s7,24(sp)
    800044f6:	6c42                	ld	s8,16(sp)
    800044f8:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800044fa:	034a9d63          	bne	s5,s4,80004534 <filewrite+0x12e>
    800044fe:	8556                	mv	a0,s5
    80004500:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004502:	60e6                	ld	ra,88(sp)
    80004504:	6446                	ld	s0,80(sp)
    80004506:	6906                	ld	s2,64(sp)
    80004508:	7aa2                	ld	s5,40(sp)
    8000450a:	7b02                	ld	s6,32(sp)
    8000450c:	6125                	addi	sp,sp,96
    8000450e:	8082                	ret
    80004510:	e4a6                	sd	s1,72(sp)
    80004512:	fc4e                	sd	s3,56(sp)
    80004514:	f852                	sd	s4,48(sp)
    80004516:	ec5e                	sd	s7,24(sp)
    80004518:	e862                	sd	s8,16(sp)
    8000451a:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000451c:	00003517          	auipc	a0,0x3
    80004520:	13c50513          	addi	a0,a0,316 # 80007658 <etext+0x658>
    80004524:	b00fc0ef          	jal	80000824 <panic>
    return -1;
    80004528:	557d                	li	a0,-1
}
    8000452a:	8082                	ret
      return -1;
    8000452c:	557d                	li	a0,-1
    8000452e:	bfd1                	j	80004502 <filewrite+0xfc>
    80004530:	557d                	li	a0,-1
    80004532:	bfc1                	j	80004502 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004534:	557d                	li	a0,-1
    80004536:	7a42                	ld	s4,48(sp)
    80004538:	b7e9                	j	80004502 <filewrite+0xfc>

000000008000453a <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000453a:	1101                	addi	sp,sp,-32
    8000453c:	ec06                	sd	ra,24(sp)
    8000453e:	e822                	sd	s0,16(sp)
    80004540:	e426                	sd	s1,8(sp)
    80004542:	e04a                	sd	s2,0(sp)
    80004544:	1000                	addi	s0,sp,32
    80004546:	84aa                	mv	s1,a0
    80004548:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000454a:	0005b023          	sd	zero,0(a1)
    8000454e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004552:	c29ff0ef          	jal	8000417a <filealloc>
    80004556:	e088                	sd	a0,0(s1)
    80004558:	cd35                	beqz	a0,800045d4 <pipealloc+0x9a>
    8000455a:	c21ff0ef          	jal	8000417a <filealloc>
    8000455e:	00a93023          	sd	a0,0(s2)
    80004562:	c52d                	beqz	a0,800045cc <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004564:	de0fc0ef          	jal	80000b44 <kalloc>
    80004568:	cd39                	beqz	a0,800045c6 <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    8000456a:	4785                	li	a5,1
    8000456c:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    80004570:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    80004574:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    80004578:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    8000457c:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    80004580:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    80004584:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004588:	6098                	ld	a4,0(s1)
    8000458a:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    8000458c:	6098                	ld	a4,0(s1)
    8000458e:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    80004592:	6098                	ld	a4,0(s1)
    80004594:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004598:	6098                	ld	a4,0(s1)
    8000459a:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    8000459c:	00093703          	ld	a4,0(s2)
    800045a0:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    800045a2:	00093703          	ld	a4,0(s2)
    800045a6:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    800045aa:	00093703          	ld	a4,0(s2)
    800045ae:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    800045b2:	00093783          	ld	a5,0(s2)
    800045b6:	eb88                	sd	a0,16(a5)
  return 0;
    800045b8:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    800045ba:	60e2                	ld	ra,24(sp)
    800045bc:	6442                	ld	s0,16(sp)
    800045be:	64a2                	ld	s1,8(sp)
    800045c0:	6902                	ld	s2,0(sp)
    800045c2:	6105                	addi	sp,sp,32
    800045c4:	8082                	ret
  if(*f0)
    800045c6:	6088                	ld	a0,0(s1)
    800045c8:	e501                	bnez	a0,800045d0 <pipealloc+0x96>
    800045ca:	a029                	j	800045d4 <pipealloc+0x9a>
    800045cc:	6088                	ld	a0,0(s1)
    800045ce:	cd01                	beqz	a0,800045e6 <pipealloc+0xac>
    fileclose(*f0);
    800045d0:	c4fff0ef          	jal	8000421e <fileclose>
  if(*f1)
    800045d4:	00093783          	ld	a5,0(s2)
  return -1;
    800045d8:	557d                	li	a0,-1
  if(*f1)
    800045da:	d3e5                	beqz	a5,800045ba <pipealloc+0x80>
    fileclose(*f1);
    800045dc:	853e                	mv	a0,a5
    800045de:	c41ff0ef          	jal	8000421e <fileclose>
  return -1;
    800045e2:	557d                	li	a0,-1
    800045e4:	bfd9                	j	800045ba <pipealloc+0x80>
    800045e6:	557d                	li	a0,-1
    800045e8:	bfc9                	j	800045ba <pipealloc+0x80>

00000000800045ea <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    800045ea:	1141                	addi	sp,sp,-16
    800045ec:	e406                	sd	ra,8(sp)
    800045ee:	e022                	sd	s0,0(sp)
    800045f0:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    800045f2:	4785                	li	a5,1
    800045f4:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    800045f6:	058a                	slli	a1,a1,0x2
    800045f8:	21058593          	addi	a1,a1,528
    800045fc:	95aa                	add	a1,a1,a0
    800045fe:	4705                	li	a4,1
    80004600:	c198                	sw	a4,0(a1)
  pi->turn = other;
    80004602:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    80004606:	078a                	slli	a5,a5,0x2
    80004608:	21078793          	addi	a5,a5,528
    8000460c:	953e                	add	a0,a0,a5
    8000460e:	4118                	lw	a4,0(a0)
    80004610:	4785                	li	a5,1
    80004612:	00f70063          	beq	a4,a5,80004612 <peterson_enter+0x28>
}
    80004616:	60a2                	ld	ra,8(sp)
    80004618:	6402                	ld	s0,0(sp)
    8000461a:	0141                	addi	sp,sp,16
    8000461c:	8082                	ret

000000008000461e <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    8000461e:	1141                	addi	sp,sp,-16
    80004620:	e406                	sd	ra,8(sp)
    80004622:	e022                	sd	s0,0(sp)
    80004624:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    80004626:	058a                	slli	a1,a1,0x2
    80004628:	21058593          	addi	a1,a1,528
    8000462c:	952e                	add	a0,a0,a1
    8000462e:	00052023          	sw	zero,0(a0)
}
    80004632:	60a2                	ld	ra,8(sp)
    80004634:	6402                	ld	s0,0(sp)
    80004636:	0141                	addi	sp,sp,16
    80004638:	8082                	ret

000000008000463a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000463a:	7179                	addi	sp,sp,-48
    8000463c:	f406                	sd	ra,40(sp)
    8000463e:	f022                	sd	s0,32(sp)
    80004640:	ec26                	sd	s1,24(sp)
    80004642:	e84a                	sd	s2,16(sp)
    80004644:	e44e                	sd	s3,8(sp)
    80004646:	1800                	addi	s0,sp,48
    80004648:	84aa                	mv	s1,a0
    8000464a:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    8000464c:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    80004650:	85ca                	mv	a1,s2
    80004652:	f99ff0ef          	jal	800045ea <peterson_enter>
  if(writable){
    80004656:	02098b63          	beqz	s3,8000468c <pipeclose+0x52>
    pi->writeopen = 0;
    8000465a:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    8000465e:	20048513          	addi	a0,s1,512
    80004662:	9d9fd0ef          	jal	8000203a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004666:	2084a783          	lw	a5,520(s1)
    8000466a:	e781                	bnez	a5,80004672 <pipeclose+0x38>
    8000466c:	20c4a783          	lw	a5,524(s1)
    80004670:	c78d                	beqz	a5,8000469a <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    80004672:	090a                	slli	s2,s2,0x2
    80004674:	21090913          	addi	s2,s2,528
    80004678:	94ca                	add	s1,s1,s2
    8000467a:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    8000467e:	70a2                	ld	ra,40(sp)
    80004680:	7402                	ld	s0,32(sp)
    80004682:	64e2                	ld	s1,24(sp)
    80004684:	6942                	ld	s2,16(sp)
    80004686:	69a2                	ld	s3,8(sp)
    80004688:	6145                	addi	sp,sp,48
    8000468a:	8082                	ret
    pi->readopen = 0;
    8000468c:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    80004690:	20448513          	addi	a0,s1,516
    80004694:	9a7fd0ef          	jal	8000203a <wakeup>
    80004698:	b7f9                	j	80004666 <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    8000469a:	090a                	slli	s2,s2,0x2
    8000469c:	21090913          	addi	s2,s2,528
    800046a0:	9926                	add	s2,s2,s1
    800046a2:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    800046a6:	8526                	mv	a0,s1
    800046a8:	bb4fc0ef          	jal	80000a5c <kfree>
    800046ac:	bfc9                	j	8000467e <pipeclose+0x44>

00000000800046ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800046ae:	7159                	addi	sp,sp,-112
    800046b0:	f486                	sd	ra,104(sp)
    800046b2:	f0a2                	sd	s0,96(sp)
    800046b4:	eca6                	sd	s1,88(sp)
    800046b6:	e8ca                	sd	s2,80(sp)
    800046b8:	e4ce                	sd	s3,72(sp)
    800046ba:	e0d2                	sd	s4,64(sp)
    800046bc:	fc56                	sd	s5,56(sp)
    800046be:	1880                	addi	s0,sp,112
    800046c0:	84aa                	mv	s1,a0
    800046c2:	8aae                	mv	s5,a1
    800046c4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800046c6:	a68fd0ef          	jal	8000192e <myproc>
    800046ca:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    800046cc:	4581                	li	a1,0
    800046ce:	8526                	mv	a0,s1
    800046d0:	f1bff0ef          	jal	800045ea <peterson_enter>
  while(i < n){
    800046d4:	0b405e63          	blez	s4,80004790 <pipewrite+0xe2>
    800046d8:	f85a                	sd	s6,48(sp)
    800046da:	f45e                	sd	s7,40(sp)
    800046dc:	f062                	sd	s8,32(sp)
    800046de:	ec66                	sd	s9,24(sp)
    800046e0:	e86a                	sd	s10,16(sp)
  int i = 0;
    800046e2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800046e4:	f9f40c13          	addi	s8,s0,-97
    800046e8:	4b85                	li	s7,1
    800046ea:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800046ec:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    800046f0:	20448c93          	addi	s9,s1,516
    800046f4:	a825                	j	8000472c <pipewrite+0x7e>
      return -1;
    800046f6:	597d                	li	s2,-1
}
    800046f8:	7b42                	ld	s6,48(sp)
    800046fa:	7ba2                	ld	s7,40(sp)
    800046fc:	7c02                	ld	s8,32(sp)
    800046fe:	6ce2                	ld	s9,24(sp)
    80004700:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    80004702:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004706:	854a                	mv	a0,s2
    80004708:	70a6                	ld	ra,104(sp)
    8000470a:	7406                	ld	s0,96(sp)
    8000470c:	64e6                	ld	s1,88(sp)
    8000470e:	6946                	ld	s2,80(sp)
    80004710:	69a6                	ld	s3,72(sp)
    80004712:	6a06                	ld	s4,64(sp)
    80004714:	7ae2                	ld	s5,56(sp)
    80004716:	6165                	addi	sp,sp,112
    80004718:	8082                	ret
      wakeup(&pi->nread);
    8000471a:	856a                	mv	a0,s10
    8000471c:	91ffd0ef          	jal	8000203a <wakeup>
      sleep(&pi->nwrite, 0);
    80004720:	4581                	li	a1,0
    80004722:	8566                	mv	a0,s9
    80004724:	8cbfd0ef          	jal	80001fee <sleep>
  while(i < n){
    80004728:	05495a63          	bge	s2,s4,8000477c <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000472c:	2084a783          	lw	a5,520(s1)
    80004730:	d3f9                	beqz	a5,800046f6 <pipewrite+0x48>
    80004732:	854e                	mv	a0,s3
    80004734:	af7fd0ef          	jal	8000222a <killed>
    80004738:	fd5d                	bnez	a0,800046f6 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000473a:	2004a783          	lw	a5,512(s1)
    8000473e:	2044a703          	lw	a4,516(s1)
    80004742:	2007879b          	addiw	a5,a5,512
    80004746:	fcf70ae3          	beq	a4,a5,8000471a <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000474a:	86de                	mv	a3,s7
    8000474c:	01590633          	add	a2,s2,s5
    80004750:	85e2                	mv	a1,s8
    80004752:	0509b503          	ld	a0,80(s3)
    80004756:	fbdfc0ef          	jal	80001712 <copyin>
    8000475a:	03650d63          	beq	a0,s6,80004794 <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000475e:	2044a783          	lw	a5,516(s1)
    80004762:	0017871b          	addiw	a4,a5,1
    80004766:	20e4a223          	sw	a4,516(s1)
    8000476a:	1ff7f793          	andi	a5,a5,511
    8000476e:	97a6                	add	a5,a5,s1
    80004770:	f9f44703          	lbu	a4,-97(s0)
    80004774:	00e78023          	sb	a4,0(a5)
      i++;
    80004778:	2905                	addiw	s2,s2,1
    8000477a:	b77d                	j	80004728 <pipewrite+0x7a>
    8000477c:	7b42                	ld	s6,48(sp)
    8000477e:	7ba2                	ld	s7,40(sp)
    80004780:	7c02                	ld	s8,32(sp)
    80004782:	6ce2                	ld	s9,24(sp)
    80004784:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004786:	20048513          	addi	a0,s1,512
    8000478a:	8b1fd0ef          	jal	8000203a <wakeup>
}
    8000478e:	bf95                	j	80004702 <pipewrite+0x54>
  int i = 0;
    80004790:	4901                	li	s2,0
    80004792:	bfd5                	j	80004786 <pipewrite+0xd8>
    80004794:	7b42                	ld	s6,48(sp)
    80004796:	7ba2                	ld	s7,40(sp)
    80004798:	7c02                	ld	s8,32(sp)
    8000479a:	6ce2                	ld	s9,24(sp)
    8000479c:	6d42                	ld	s10,16(sp)
    8000479e:	b7e5                	j	80004786 <pipewrite+0xd8>

00000000800047a0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800047a0:	711d                	addi	sp,sp,-96
    800047a2:	ec86                	sd	ra,88(sp)
    800047a4:	e8a2                	sd	s0,80(sp)
    800047a6:	e4a6                	sd	s1,72(sp)
    800047a8:	e0ca                	sd	s2,64(sp)
    800047aa:	fc4e                	sd	s3,56(sp)
    800047ac:	f852                	sd	s4,48(sp)
    800047ae:	f456                	sd	s5,40(sp)
    800047b0:	1080                	addi	s0,sp,96
    800047b2:	84aa                	mv	s1,a0
    800047b4:	892e                	mv	s2,a1
    800047b6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800047b8:	976fd0ef          	jal	8000192e <myproc>
    800047bc:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    800047be:	4585                	li	a1,1
    800047c0:	8526                	mv	a0,s1
    800047c2:	e29ff0ef          	jal	800045ea <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047c6:	2004a703          	lw	a4,512(s1)
    800047ca:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    800047ce:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047d2:	02f71763          	bne	a4,a5,80004800 <piperead+0x60>
    800047d6:	20c4a783          	lw	a5,524(s1)
    800047da:	c79d                	beqz	a5,80004808 <piperead+0x68>
    if(killed(pr)){
    800047dc:	8552                	mv	a0,s4
    800047de:	a4dfd0ef          	jal	8000222a <killed>
    800047e2:	e15d                	bnez	a0,80004888 <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    800047e4:	4581                	li	a1,0
    800047e6:	854e                	mv	a0,s3
    800047e8:	807fd0ef          	jal	80001fee <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800047ec:	2004a703          	lw	a4,512(s1)
    800047f0:	2044a783          	lw	a5,516(s1)
    800047f4:	fef701e3          	beq	a4,a5,800047d6 <piperead+0x36>
    800047f8:	f05a                	sd	s6,32(sp)
    800047fa:	ec5e                	sd	s7,24(sp)
    800047fc:	e862                	sd	s8,16(sp)
    800047fe:	a801                	j	8000480e <piperead+0x6e>
    80004800:	f05a                	sd	s6,32(sp)
    80004802:	ec5e                	sd	s7,24(sp)
    80004804:	e862                	sd	s8,16(sp)
    80004806:	a021                	j	8000480e <piperead+0x6e>
    80004808:	f05a                	sd	s6,32(sp)
    8000480a:	ec5e                	sd	s7,24(sp)
    8000480c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000480e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004810:	faf40c13          	addi	s8,s0,-81
    80004814:	4b85                	li	s7,1
    80004816:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004818:	05505163          	blez	s5,8000485a <piperead+0xba>
    if(pi->nread == pi->nwrite)
    8000481c:	2004a783          	lw	a5,512(s1)
    80004820:	2044a703          	lw	a4,516(s1)
    80004824:	02f70b63          	beq	a4,a5,8000485a <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    80004828:	1ff7f793          	andi	a5,a5,511
    8000482c:	97a6                	add	a5,a5,s1
    8000482e:	0007c783          	lbu	a5,0(a5)
    80004832:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004836:	86de                	mv	a3,s7
    80004838:	8662                	mv	a2,s8
    8000483a:	85ca                	mv	a1,s2
    8000483c:	050a3503          	ld	a0,80(s4)
    80004840:	e15fc0ef          	jal	80001654 <copyout>
    80004844:	03650e63          	beq	a0,s6,80004880 <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004848:	2004a783          	lw	a5,512(s1)
    8000484c:	2785                	addiw	a5,a5,1
    8000484e:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004852:	2985                	addiw	s3,s3,1
    80004854:	0905                	addi	s2,s2,1
    80004856:	fd3a93e3          	bne	s5,s3,8000481c <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000485a:	20448513          	addi	a0,s1,516
    8000485e:	fdcfd0ef          	jal	8000203a <wakeup>
}
    80004862:	7b02                	ld	s6,32(sp)
    80004864:	6be2                	ld	s7,24(sp)
    80004866:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    80004868:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    8000486c:	854e                	mv	a0,s3
    8000486e:	60e6                	ld	ra,88(sp)
    80004870:	6446                	ld	s0,80(sp)
    80004872:	64a6                	ld	s1,72(sp)
    80004874:	6906                	ld	s2,64(sp)
    80004876:	79e2                	ld	s3,56(sp)
    80004878:	7a42                	ld	s4,48(sp)
    8000487a:	7aa2                	ld	s5,40(sp)
    8000487c:	6125                	addi	sp,sp,96
    8000487e:	8082                	ret
      if(i == 0)
    80004880:	fc099de3          	bnez	s3,8000485a <piperead+0xba>
        i = -1;
    80004884:	89aa                	mv	s3,a0
    80004886:	bfd1                	j	8000485a <piperead+0xba>
      return -1;
    80004888:	59fd                	li	s3,-1
    8000488a:	bff9                	j	80004868 <piperead+0xc8>

000000008000488c <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    8000488c:	1141                	addi	sp,sp,-16
    8000488e:	e406                	sd	ra,8(sp)
    80004890:	e022                	sd	s0,0(sp)
    80004892:	0800                	addi	s0,sp,16
    80004894:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004896:	0035151b          	slliw	a0,a0,0x3
    8000489a:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    8000489c:	8b89                	andi	a5,a5,2
    8000489e:	c399                	beqz	a5,800048a4 <flags2perm+0x18>
      perm |= PTE_W;
    800048a0:	00456513          	ori	a0,a0,4
    return perm;
}
    800048a4:	60a2                	ld	ra,8(sp)
    800048a6:	6402                	ld	s0,0(sp)
    800048a8:	0141                	addi	sp,sp,16
    800048aa:	8082                	ret

00000000800048ac <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800048ac:	de010113          	addi	sp,sp,-544
    800048b0:	20113c23          	sd	ra,536(sp)
    800048b4:	20813823          	sd	s0,528(sp)
    800048b8:	20913423          	sd	s1,520(sp)
    800048bc:	21213023          	sd	s2,512(sp)
    800048c0:	1400                	addi	s0,sp,544
    800048c2:	892a                	mv	s2,a0
    800048c4:	dea43823          	sd	a0,-528(s0)
    800048c8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800048cc:	862fd0ef          	jal	8000192e <myproc>
    800048d0:	84aa                	mv	s1,a0

  begin_op();
    800048d2:	d28ff0ef          	jal	80003dfa <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    800048d6:	854a                	mv	a0,s2
    800048d8:	b44ff0ef          	jal	80003c1c <namei>
    800048dc:	cd21                	beqz	a0,80004934 <kexec+0x88>
    800048de:	fbd2                	sd	s4,496(sp)
    800048e0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800048e2:	b0dfe0ef          	jal	800033ee <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800048e6:	04000713          	li	a4,64
    800048ea:	4681                	li	a3,0
    800048ec:	e5040613          	addi	a2,s0,-432
    800048f0:	4581                	li	a1,0
    800048f2:	8552                	mv	a0,s4
    800048f4:	e8dfe0ef          	jal	80003780 <readi>
    800048f8:	04000793          	li	a5,64
    800048fc:	00f51a63          	bne	a0,a5,80004910 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004900:	e5042703          	lw	a4,-432(s0)
    80004904:	464c47b7          	lui	a5,0x464c4
    80004908:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000490c:	02f70863          	beq	a4,a5,8000493c <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004910:	8552                	mv	a0,s4
    80004912:	ce9fe0ef          	jal	800035fa <iunlockput>
    end_op();
    80004916:	d54ff0ef          	jal	80003e6a <end_op>
  }
  return -1;
    8000491a:	557d                	li	a0,-1
    8000491c:	7a5e                	ld	s4,496(sp)
}
    8000491e:	21813083          	ld	ra,536(sp)
    80004922:	21013403          	ld	s0,528(sp)
    80004926:	20813483          	ld	s1,520(sp)
    8000492a:	20013903          	ld	s2,512(sp)
    8000492e:	22010113          	addi	sp,sp,544
    80004932:	8082                	ret
    end_op();
    80004934:	d36ff0ef          	jal	80003e6a <end_op>
    return -1;
    80004938:	557d                	li	a0,-1
    8000493a:	b7d5                	j	8000491e <kexec+0x72>
    8000493c:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000493e:	8526                	mv	a0,s1
    80004940:	8f8fd0ef          	jal	80001a38 <proc_pagetable>
    80004944:	8b2a                	mv	s6,a0
    80004946:	26050f63          	beqz	a0,80004bc4 <kexec+0x318>
    8000494a:	ffce                	sd	s3,504(sp)
    8000494c:	f7d6                	sd	s5,488(sp)
    8000494e:	efde                	sd	s7,472(sp)
    80004950:	ebe2                	sd	s8,464(sp)
    80004952:	e7e6                	sd	s9,456(sp)
    80004954:	e3ea                	sd	s10,448(sp)
    80004956:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004958:	e8845783          	lhu	a5,-376(s0)
    8000495c:	0e078963          	beqz	a5,80004a4e <kexec+0x1a2>
    80004960:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004964:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004966:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004968:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    8000496c:	6c85                	lui	s9,0x1
    8000496e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004972:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004976:	6a85                	lui	s5,0x1
    80004978:	a085                	j	800049d8 <kexec+0x12c>
      panic("loadseg: address should exist");
    8000497a:	00003517          	auipc	a0,0x3
    8000497e:	cee50513          	addi	a0,a0,-786 # 80007668 <etext+0x668>
    80004982:	ea3fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    80004986:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004988:	874a                	mv	a4,s2
    8000498a:	009b86bb          	addw	a3,s7,s1
    8000498e:	4581                	li	a1,0
    80004990:	8552                	mv	a0,s4
    80004992:	deffe0ef          	jal	80003780 <readi>
    80004996:	22a91b63          	bne	s2,a0,80004bcc <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    8000499a:	009a84bb          	addw	s1,s5,s1
    8000499e:	0334f263          	bgeu	s1,s3,800049c2 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800049a2:	02049593          	slli	a1,s1,0x20
    800049a6:	9181                	srli	a1,a1,0x20
    800049a8:	95e2                	add	a1,a1,s8
    800049aa:	855a                	mv	a0,s6
    800049ac:	e7afc0ef          	jal	80001026 <walkaddr>
    800049b0:	862a                	mv	a2,a0
    if(pa == 0)
    800049b2:	d561                	beqz	a0,8000497a <kexec+0xce>
    if(sz - i < PGSIZE)
    800049b4:	409987bb          	subw	a5,s3,s1
    800049b8:	893e                	mv	s2,a5
    800049ba:	fcfcf6e3          	bgeu	s9,a5,80004986 <kexec+0xda>
    800049be:	8956                	mv	s2,s5
    800049c0:	b7d9                	j	80004986 <kexec+0xda>
    sz = sz1;
    800049c2:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800049c6:	2d05                	addiw	s10,s10,1
    800049c8:	e0843783          	ld	a5,-504(s0)
    800049cc:	0387869b          	addiw	a3,a5,56
    800049d0:	e8845783          	lhu	a5,-376(s0)
    800049d4:	06fd5e63          	bge	s10,a5,80004a50 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800049d8:	e0d43423          	sd	a3,-504(s0)
    800049dc:	876e                	mv	a4,s11
    800049de:	e1840613          	addi	a2,s0,-488
    800049e2:	4581                	li	a1,0
    800049e4:	8552                	mv	a0,s4
    800049e6:	d9bfe0ef          	jal	80003780 <readi>
    800049ea:	1db51f63          	bne	a0,s11,80004bc8 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    800049ee:	e1842783          	lw	a5,-488(s0)
    800049f2:	4705                	li	a4,1
    800049f4:	fce799e3          	bne	a5,a4,800049c6 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    800049f8:	e4043483          	ld	s1,-448(s0)
    800049fc:	e3843783          	ld	a5,-456(s0)
    80004a00:	1ef4e463          	bltu	s1,a5,80004be8 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004a04:	e2843783          	ld	a5,-472(s0)
    80004a08:	94be                	add	s1,s1,a5
    80004a0a:	1ef4e263          	bltu	s1,a5,80004bee <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004a0e:	de843703          	ld	a4,-536(s0)
    80004a12:	8ff9                	and	a5,a5,a4
    80004a14:	1e079063          	bnez	a5,80004bf4 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004a18:	e1c42503          	lw	a0,-484(s0)
    80004a1c:	e71ff0ef          	jal	8000488c <flags2perm>
    80004a20:	86aa                	mv	a3,a0
    80004a22:	8626                	mv	a2,s1
    80004a24:	85ca                	mv	a1,s2
    80004a26:	855a                	mv	a0,s6
    80004a28:	8d5fc0ef          	jal	800012fc <uvmalloc>
    80004a2c:	dea43c23          	sd	a0,-520(s0)
    80004a30:	1c050563          	beqz	a0,80004bfa <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a34:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a38:	00098863          	beqz	s3,80004a48 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004a3c:	e2843c03          	ld	s8,-472(s0)
    80004a40:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004a44:	4481                	li	s1,0
    80004a46:	bfb1                	j	800049a2 <kexec+0xf6>
    sz = sz1;
    80004a48:	df843903          	ld	s2,-520(s0)
    80004a4c:	bfad                	j	800049c6 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a4e:	4901                	li	s2,0
  iunlockput(ip);
    80004a50:	8552                	mv	a0,s4
    80004a52:	ba9fe0ef          	jal	800035fa <iunlockput>
  end_op();
    80004a56:	c14ff0ef          	jal	80003e6a <end_op>
  p = myproc();
    80004a5a:	ed5fc0ef          	jal	8000192e <myproc>
    80004a5e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004a60:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004a64:	6985                	lui	s3,0x1
    80004a66:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004a68:	99ca                	add	s3,s3,s2
    80004a6a:	77fd                	lui	a5,0xfffff
    80004a6c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004a70:	4691                	li	a3,4
    80004a72:	6609                	lui	a2,0x2
    80004a74:	964e                	add	a2,a2,s3
    80004a76:	85ce                	mv	a1,s3
    80004a78:	855a                	mv	a0,s6
    80004a7a:	883fc0ef          	jal	800012fc <uvmalloc>
    80004a7e:	8a2a                	mv	s4,a0
    80004a80:	e105                	bnez	a0,80004aa0 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004a82:	85ce                	mv	a1,s3
    80004a84:	855a                	mv	a0,s6
    80004a86:	836fd0ef          	jal	80001abc <proc_freepagetable>
  return -1;
    80004a8a:	557d                	li	a0,-1
    80004a8c:	79fe                	ld	s3,504(sp)
    80004a8e:	7a5e                	ld	s4,496(sp)
    80004a90:	7abe                	ld	s5,488(sp)
    80004a92:	7b1e                	ld	s6,480(sp)
    80004a94:	6bfe                	ld	s7,472(sp)
    80004a96:	6c5e                	ld	s8,464(sp)
    80004a98:	6cbe                	ld	s9,456(sp)
    80004a9a:	6d1e                	ld	s10,448(sp)
    80004a9c:	7dfa                	ld	s11,440(sp)
    80004a9e:	b541                	j	8000491e <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004aa0:	75f9                	lui	a1,0xffffe
    80004aa2:	95aa                	add	a1,a1,a0
    80004aa4:	855a                	mv	a0,s6
    80004aa6:	a29fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004aaa:	800a0b93          	addi	s7,s4,-2048
    80004aae:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004ab2:	e0043783          	ld	a5,-512(s0)
    80004ab6:	6388                	ld	a0,0(a5)
  sp = sz;
    80004ab8:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004aba:	4481                	li	s1,0
    ustack[argc] = sp;
    80004abc:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004ac0:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004ac4:	cd21                	beqz	a0,80004b1c <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004ac6:	bbcfc0ef          	jal	80000e82 <strlen>
    80004aca:	0015079b          	addiw	a5,a0,1
    80004ace:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ad2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ad6:	13796563          	bltu	s2,s7,80004c00 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ada:	e0043d83          	ld	s11,-512(s0)
    80004ade:	000db983          	ld	s3,0(s11)
    80004ae2:	854e                	mv	a0,s3
    80004ae4:	b9efc0ef          	jal	80000e82 <strlen>
    80004ae8:	0015069b          	addiw	a3,a0,1
    80004aec:	864e                	mv	a2,s3
    80004aee:	85ca                	mv	a1,s2
    80004af0:	855a                	mv	a0,s6
    80004af2:	b63fc0ef          	jal	80001654 <copyout>
    80004af6:	10054763          	bltz	a0,80004c04 <kexec+0x358>
    ustack[argc] = sp;
    80004afa:	00349793          	slli	a5,s1,0x3
    80004afe:	97e6                	add	a5,a5,s9
    80004b00:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde398>
  for(argc = 0; argv[argc]; argc++) {
    80004b04:	0485                	addi	s1,s1,1
    80004b06:	008d8793          	addi	a5,s11,8
    80004b0a:	e0f43023          	sd	a5,-512(s0)
    80004b0e:	008db503          	ld	a0,8(s11)
    80004b12:	c509                	beqz	a0,80004b1c <kexec+0x270>
    if(argc >= MAXARG)
    80004b14:	fb8499e3          	bne	s1,s8,80004ac6 <kexec+0x21a>
  sz = sz1;
    80004b18:	89d2                	mv	s3,s4
    80004b1a:	b7a5                	j	80004a82 <kexec+0x1d6>
  ustack[argc] = 0;
    80004b1c:	00349793          	slli	a5,s1,0x3
    80004b20:	f9078793          	addi	a5,a5,-112
    80004b24:	97a2                	add	a5,a5,s0
    80004b26:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004b2a:	00349693          	slli	a3,s1,0x3
    80004b2e:	06a1                	addi	a3,a3,8
    80004b30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004b34:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004b38:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004b3a:	f57964e3          	bltu	s2,s7,80004a82 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004b3e:	e9040613          	addi	a2,s0,-368
    80004b42:	85ca                	mv	a1,s2
    80004b44:	855a                	mv	a0,s6
    80004b46:	b0ffc0ef          	jal	80001654 <copyout>
    80004b4a:	f2054ce3          	bltz	a0,80004a82 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004b4e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004b52:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004b56:	df043783          	ld	a5,-528(s0)
    80004b5a:	0007c703          	lbu	a4,0(a5)
    80004b5e:	cf11                	beqz	a4,80004b7a <kexec+0x2ce>
    80004b60:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004b62:	02f00693          	li	a3,47
    80004b66:	a029                	j	80004b70 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004b68:	0785                	addi	a5,a5,1
    80004b6a:	fff7c703          	lbu	a4,-1(a5)
    80004b6e:	c711                	beqz	a4,80004b7a <kexec+0x2ce>
    if(*s == '/')
    80004b70:	fed71ce3          	bne	a4,a3,80004b68 <kexec+0x2bc>
      last = s+1;
    80004b74:	def43823          	sd	a5,-528(s0)
    80004b78:	bfc5                	j	80004b68 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004b7a:	4641                	li	a2,16
    80004b7c:	df043583          	ld	a1,-528(s0)
    80004b80:	158a8513          	addi	a0,s5,344
    80004b84:	ac8fc0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004b88:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004b8c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004b90:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004b94:	058ab783          	ld	a5,88(s5)
    80004b98:	e6843703          	ld	a4,-408(s0)
    80004b9c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004b9e:	058ab783          	ld	a5,88(s5)
    80004ba2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ba6:	85ea                	mv	a1,s10
    80004ba8:	f15fc0ef          	jal	80001abc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004bac:	0004851b          	sext.w	a0,s1
    80004bb0:	79fe                	ld	s3,504(sp)
    80004bb2:	7a5e                	ld	s4,496(sp)
    80004bb4:	7abe                	ld	s5,488(sp)
    80004bb6:	7b1e                	ld	s6,480(sp)
    80004bb8:	6bfe                	ld	s7,472(sp)
    80004bba:	6c5e                	ld	s8,464(sp)
    80004bbc:	6cbe                	ld	s9,456(sp)
    80004bbe:	6d1e                	ld	s10,448(sp)
    80004bc0:	7dfa                	ld	s11,440(sp)
    80004bc2:	bbb1                	j	8000491e <kexec+0x72>
    80004bc4:	7b1e                	ld	s6,480(sp)
    80004bc6:	b3a9                	j	80004910 <kexec+0x64>
    80004bc8:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004bcc:	df843583          	ld	a1,-520(s0)
    80004bd0:	855a                	mv	a0,s6
    80004bd2:	eebfc0ef          	jal	80001abc <proc_freepagetable>
  if(ip){
    80004bd6:	79fe                	ld	s3,504(sp)
    80004bd8:	7abe                	ld	s5,488(sp)
    80004bda:	7b1e                	ld	s6,480(sp)
    80004bdc:	6bfe                	ld	s7,472(sp)
    80004bde:	6c5e                	ld	s8,464(sp)
    80004be0:	6cbe                	ld	s9,456(sp)
    80004be2:	6d1e                	ld	s10,448(sp)
    80004be4:	7dfa                	ld	s11,440(sp)
    80004be6:	b32d                	j	80004910 <kexec+0x64>
    80004be8:	df243c23          	sd	s2,-520(s0)
    80004bec:	b7c5                	j	80004bcc <kexec+0x320>
    80004bee:	df243c23          	sd	s2,-520(s0)
    80004bf2:	bfe9                	j	80004bcc <kexec+0x320>
    80004bf4:	df243c23          	sd	s2,-520(s0)
    80004bf8:	bfd1                	j	80004bcc <kexec+0x320>
    80004bfa:	df243c23          	sd	s2,-520(s0)
    80004bfe:	b7f9                	j	80004bcc <kexec+0x320>
  sz = sz1;
    80004c00:	89d2                	mv	s3,s4
    80004c02:	b541                	j	80004a82 <kexec+0x1d6>
    80004c04:	89d2                	mv	s3,s4
    80004c06:	bdb5                	j	80004a82 <kexec+0x1d6>

0000000080004c08 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c08:	7179                	addi	sp,sp,-48
    80004c0a:	f406                	sd	ra,40(sp)
    80004c0c:	f022                	sd	s0,32(sp)
    80004c0e:	ec26                	sd	s1,24(sp)
    80004c10:	e84a                	sd	s2,16(sp)
    80004c12:	1800                	addi	s0,sp,48
    80004c14:	892e                	mv	s2,a1
    80004c16:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004c18:	fdc40593          	addi	a1,s0,-36
    80004c1c:	dddfd0ef          	jal	800029f8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004c20:	fdc42703          	lw	a4,-36(s0)
    80004c24:	47bd                	li	a5,15
    80004c26:	02e7ea63          	bltu	a5,a4,80004c5a <argfd+0x52>
    80004c2a:	d05fc0ef          	jal	8000192e <myproc>
    80004c2e:	fdc42703          	lw	a4,-36(s0)
    80004c32:	00371793          	slli	a5,a4,0x3
    80004c36:	0d078793          	addi	a5,a5,208
    80004c3a:	953e                	add	a0,a0,a5
    80004c3c:	611c                	ld	a5,0(a0)
    80004c3e:	c385                	beqz	a5,80004c5e <argfd+0x56>
    return -1;
  if(pfd)
    80004c40:	00090463          	beqz	s2,80004c48 <argfd+0x40>
    *pfd = fd;
    80004c44:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004c48:	4501                	li	a0,0
  if(pf)
    80004c4a:	c091                	beqz	s1,80004c4e <argfd+0x46>
    *pf = f;
    80004c4c:	e09c                	sd	a5,0(s1)
}
    80004c4e:	70a2                	ld	ra,40(sp)
    80004c50:	7402                	ld	s0,32(sp)
    80004c52:	64e2                	ld	s1,24(sp)
    80004c54:	6942                	ld	s2,16(sp)
    80004c56:	6145                	addi	sp,sp,48
    80004c58:	8082                	ret
    return -1;
    80004c5a:	557d                	li	a0,-1
    80004c5c:	bfcd                	j	80004c4e <argfd+0x46>
    80004c5e:	557d                	li	a0,-1
    80004c60:	b7fd                	j	80004c4e <argfd+0x46>

0000000080004c62 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004c62:	1101                	addi	sp,sp,-32
    80004c64:	ec06                	sd	ra,24(sp)
    80004c66:	e822                	sd	s0,16(sp)
    80004c68:	e426                	sd	s1,8(sp)
    80004c6a:	1000                	addi	s0,sp,32
    80004c6c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004c6e:	cc1fc0ef          	jal	8000192e <myproc>
    80004c72:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004c74:	0d050793          	addi	a5,a0,208
    80004c78:	4501                	li	a0,0
    80004c7a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004c7c:	6398                	ld	a4,0(a5)
    80004c7e:	cb19                	beqz	a4,80004c94 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004c80:	2505                	addiw	a0,a0,1
    80004c82:	07a1                	addi	a5,a5,8
    80004c84:	fed51ce3          	bne	a0,a3,80004c7c <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004c88:	557d                	li	a0,-1
}
    80004c8a:	60e2                	ld	ra,24(sp)
    80004c8c:	6442                	ld	s0,16(sp)
    80004c8e:	64a2                	ld	s1,8(sp)
    80004c90:	6105                	addi	sp,sp,32
    80004c92:	8082                	ret
      p->ofile[fd] = f;
    80004c94:	00351793          	slli	a5,a0,0x3
    80004c98:	0d078793          	addi	a5,a5,208
    80004c9c:	963e                	add	a2,a2,a5
    80004c9e:	e204                	sd	s1,0(a2)
      return fd;
    80004ca0:	b7ed                	j	80004c8a <fdalloc+0x28>

0000000080004ca2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ca2:	715d                	addi	sp,sp,-80
    80004ca4:	e486                	sd	ra,72(sp)
    80004ca6:	e0a2                	sd	s0,64(sp)
    80004ca8:	fc26                	sd	s1,56(sp)
    80004caa:	f84a                	sd	s2,48(sp)
    80004cac:	f44e                	sd	s3,40(sp)
    80004cae:	f052                	sd	s4,32(sp)
    80004cb0:	ec56                	sd	s5,24(sp)
    80004cb2:	e85a                	sd	s6,16(sp)
    80004cb4:	0880                	addi	s0,sp,80
    80004cb6:	892e                	mv	s2,a1
    80004cb8:	8a2e                	mv	s4,a1
    80004cba:	8ab2                	mv	s5,a2
    80004cbc:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004cbe:	fb040593          	addi	a1,s0,-80
    80004cc2:	f75fe0ef          	jal	80003c36 <nameiparent>
    80004cc6:	84aa                	mv	s1,a0
    80004cc8:	10050763          	beqz	a0,80004dd6 <create+0x134>
    return 0;

  ilock(dp);
    80004ccc:	f22fe0ef          	jal	800033ee <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004cd0:	4601                	li	a2,0
    80004cd2:	fb040593          	addi	a1,s0,-80
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	cb1fe0ef          	jal	80003988 <dirlookup>
    80004cdc:	89aa                	mv	s3,a0
    80004cde:	c131                	beqz	a0,80004d22 <create+0x80>
    iunlockput(dp);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	919fe0ef          	jal	800035fa <iunlockput>
    ilock(ip);
    80004ce6:	854e                	mv	a0,s3
    80004ce8:	f06fe0ef          	jal	800033ee <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004cec:	4789                	li	a5,2
    80004cee:	02f91563          	bne	s2,a5,80004d18 <create+0x76>
    80004cf2:	0449d783          	lhu	a5,68(s3)
    80004cf6:	37f9                	addiw	a5,a5,-2
    80004cf8:	17c2                	slli	a5,a5,0x30
    80004cfa:	93c1                	srli	a5,a5,0x30
    80004cfc:	4705                	li	a4,1
    80004cfe:	00f76d63          	bltu	a4,a5,80004d18 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004d02:	854e                	mv	a0,s3
    80004d04:	60a6                	ld	ra,72(sp)
    80004d06:	6406                	ld	s0,64(sp)
    80004d08:	74e2                	ld	s1,56(sp)
    80004d0a:	7942                	ld	s2,48(sp)
    80004d0c:	79a2                	ld	s3,40(sp)
    80004d0e:	7a02                	ld	s4,32(sp)
    80004d10:	6ae2                	ld	s5,24(sp)
    80004d12:	6b42                	ld	s6,16(sp)
    80004d14:	6161                	addi	sp,sp,80
    80004d16:	8082                	ret
    iunlockput(ip);
    80004d18:	854e                	mv	a0,s3
    80004d1a:	8e1fe0ef          	jal	800035fa <iunlockput>
    return 0;
    80004d1e:	4981                	li	s3,0
    80004d20:	b7cd                	j	80004d02 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004d22:	85ca                	mv	a1,s2
    80004d24:	4088                	lw	a0,0(s1)
    80004d26:	d58fe0ef          	jal	8000327e <ialloc>
    80004d2a:	892a                	mv	s2,a0
    80004d2c:	cd15                	beqz	a0,80004d68 <create+0xc6>
  ilock(ip);
    80004d2e:	ec0fe0ef          	jal	800033ee <ilock>
  ip->major = major;
    80004d32:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004d36:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004d3a:	4785                	li	a5,1
    80004d3c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d40:	854a                	mv	a0,s2
    80004d42:	df8fe0ef          	jal	8000333a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004d46:	4705                	li	a4,1
    80004d48:	02ea0463          	beq	s4,a4,80004d70 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d4c:	00492603          	lw	a2,4(s2)
    80004d50:	fb040593          	addi	a1,s0,-80
    80004d54:	8526                	mv	a0,s1
    80004d56:	e1dfe0ef          	jal	80003b72 <dirlink>
    80004d5a:	06054263          	bltz	a0,80004dbe <create+0x11c>
  iunlockput(dp);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	89bfe0ef          	jal	800035fa <iunlockput>
  return ip;
    80004d64:	89ca                	mv	s3,s2
    80004d66:	bf71                	j	80004d02 <create+0x60>
    iunlockput(dp);
    80004d68:	8526                	mv	a0,s1
    80004d6a:	891fe0ef          	jal	800035fa <iunlockput>
    return 0;
    80004d6e:	bf51                	j	80004d02 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004d70:	00492603          	lw	a2,4(s2)
    80004d74:	00003597          	auipc	a1,0x3
    80004d78:	91458593          	addi	a1,a1,-1772 # 80007688 <etext+0x688>
    80004d7c:	854a                	mv	a0,s2
    80004d7e:	df5fe0ef          	jal	80003b72 <dirlink>
    80004d82:	02054e63          	bltz	a0,80004dbe <create+0x11c>
    80004d86:	40d0                	lw	a2,4(s1)
    80004d88:	00003597          	auipc	a1,0x3
    80004d8c:	90858593          	addi	a1,a1,-1784 # 80007690 <etext+0x690>
    80004d90:	854a                	mv	a0,s2
    80004d92:	de1fe0ef          	jal	80003b72 <dirlink>
    80004d96:	02054463          	bltz	a0,80004dbe <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004d9a:	00492603          	lw	a2,4(s2)
    80004d9e:	fb040593          	addi	a1,s0,-80
    80004da2:	8526                	mv	a0,s1
    80004da4:	dcffe0ef          	jal	80003b72 <dirlink>
    80004da8:	00054b63          	bltz	a0,80004dbe <create+0x11c>
    dp->nlink++;  // for ".."
    80004dac:	04a4d783          	lhu	a5,74(s1)
    80004db0:	2785                	addiw	a5,a5,1
    80004db2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004db6:	8526                	mv	a0,s1
    80004db8:	d82fe0ef          	jal	8000333a <iupdate>
    80004dbc:	b74d                	j	80004d5e <create+0xbc>
  ip->nlink = 0;
    80004dbe:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004dc2:	854a                	mv	a0,s2
    80004dc4:	d76fe0ef          	jal	8000333a <iupdate>
  iunlockput(ip);
    80004dc8:	854a                	mv	a0,s2
    80004dca:	831fe0ef          	jal	800035fa <iunlockput>
  iunlockput(dp);
    80004dce:	8526                	mv	a0,s1
    80004dd0:	82bfe0ef          	jal	800035fa <iunlockput>
  return 0;
    80004dd4:	b73d                	j	80004d02 <create+0x60>
    return 0;
    80004dd6:	89aa                	mv	s3,a0
    80004dd8:	b72d                	j	80004d02 <create+0x60>

0000000080004dda <sys_dup>:
{
    80004dda:	7179                	addi	sp,sp,-48
    80004ddc:	f406                	sd	ra,40(sp)
    80004dde:	f022                	sd	s0,32(sp)
    80004de0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004de2:	fd840613          	addi	a2,s0,-40
    80004de6:	4581                	li	a1,0
    80004de8:	4501                	li	a0,0
    80004dea:	e1fff0ef          	jal	80004c08 <argfd>
    return -1;
    80004dee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004df0:	02054363          	bltz	a0,80004e16 <sys_dup+0x3c>
    80004df4:	ec26                	sd	s1,24(sp)
    80004df6:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004df8:	fd843483          	ld	s1,-40(s0)
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	e65ff0ef          	jal	80004c62 <fdalloc>
    80004e02:	892a                	mv	s2,a0
    return -1;
    80004e04:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004e06:	00054d63          	bltz	a0,80004e20 <sys_dup+0x46>
  filedup(f);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	bccff0ef          	jal	800041d8 <filedup>
  return fd;
    80004e10:	87ca                	mv	a5,s2
    80004e12:	64e2                	ld	s1,24(sp)
    80004e14:	6942                	ld	s2,16(sp)
}
    80004e16:	853e                	mv	a0,a5
    80004e18:	70a2                	ld	ra,40(sp)
    80004e1a:	7402                	ld	s0,32(sp)
    80004e1c:	6145                	addi	sp,sp,48
    80004e1e:	8082                	ret
    80004e20:	64e2                	ld	s1,24(sp)
    80004e22:	6942                	ld	s2,16(sp)
    80004e24:	bfcd                	j	80004e16 <sys_dup+0x3c>

0000000080004e26 <sys_read>:
{
    80004e26:	7179                	addi	sp,sp,-48
    80004e28:	f406                	sd	ra,40(sp)
    80004e2a:	f022                	sd	s0,32(sp)
    80004e2c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e2e:	fd840593          	addi	a1,s0,-40
    80004e32:	4505                	li	a0,1
    80004e34:	be1fd0ef          	jal	80002a14 <argaddr>
  argint(2, &n);
    80004e38:	fe440593          	addi	a1,s0,-28
    80004e3c:	4509                	li	a0,2
    80004e3e:	bbbfd0ef          	jal	800029f8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e42:	fe840613          	addi	a2,s0,-24
    80004e46:	4581                	li	a1,0
    80004e48:	4501                	li	a0,0
    80004e4a:	dbfff0ef          	jal	80004c08 <argfd>
    80004e4e:	87aa                	mv	a5,a0
    return -1;
    80004e50:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e52:	0007ca63          	bltz	a5,80004e66 <sys_read+0x40>
  return fileread(f, p, n);
    80004e56:	fe442603          	lw	a2,-28(s0)
    80004e5a:	fd843583          	ld	a1,-40(s0)
    80004e5e:	fe843503          	ld	a0,-24(s0)
    80004e62:	ce0ff0ef          	jal	80004342 <fileread>
}
    80004e66:	70a2                	ld	ra,40(sp)
    80004e68:	7402                	ld	s0,32(sp)
    80004e6a:	6145                	addi	sp,sp,48
    80004e6c:	8082                	ret

0000000080004e6e <sys_write>:
{
    80004e6e:	7179                	addi	sp,sp,-48
    80004e70:	f406                	sd	ra,40(sp)
    80004e72:	f022                	sd	s0,32(sp)
    80004e74:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004e76:	fd840593          	addi	a1,s0,-40
    80004e7a:	4505                	li	a0,1
    80004e7c:	b99fd0ef          	jal	80002a14 <argaddr>
  argint(2, &n);
    80004e80:	fe440593          	addi	a1,s0,-28
    80004e84:	4509                	li	a0,2
    80004e86:	b73fd0ef          	jal	800029f8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004e8a:	fe840613          	addi	a2,s0,-24
    80004e8e:	4581                	li	a1,0
    80004e90:	4501                	li	a0,0
    80004e92:	d77ff0ef          	jal	80004c08 <argfd>
    80004e96:	87aa                	mv	a5,a0
    return -1;
    80004e98:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004e9a:	0007ca63          	bltz	a5,80004eae <sys_write+0x40>
  return filewrite(f, p, n);
    80004e9e:	fe442603          	lw	a2,-28(s0)
    80004ea2:	fd843583          	ld	a1,-40(s0)
    80004ea6:	fe843503          	ld	a0,-24(s0)
    80004eaa:	d5cff0ef          	jal	80004406 <filewrite>
}
    80004eae:	70a2                	ld	ra,40(sp)
    80004eb0:	7402                	ld	s0,32(sp)
    80004eb2:	6145                	addi	sp,sp,48
    80004eb4:	8082                	ret

0000000080004eb6 <sys_close>:
{
    80004eb6:	1101                	addi	sp,sp,-32
    80004eb8:	ec06                	sd	ra,24(sp)
    80004eba:	e822                	sd	s0,16(sp)
    80004ebc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ebe:	fe040613          	addi	a2,s0,-32
    80004ec2:	fec40593          	addi	a1,s0,-20
    80004ec6:	4501                	li	a0,0
    80004ec8:	d41ff0ef          	jal	80004c08 <argfd>
    return -1;
    80004ecc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ece:	02054163          	bltz	a0,80004ef0 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004ed2:	a5dfc0ef          	jal	8000192e <myproc>
    80004ed6:	fec42783          	lw	a5,-20(s0)
    80004eda:	078e                	slli	a5,a5,0x3
    80004edc:	0d078793          	addi	a5,a5,208
    80004ee0:	953e                	add	a0,a0,a5
    80004ee2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004ee6:	fe043503          	ld	a0,-32(s0)
    80004eea:	b34ff0ef          	jal	8000421e <fileclose>
  return 0;
    80004eee:	4781                	li	a5,0
}
    80004ef0:	853e                	mv	a0,a5
    80004ef2:	60e2                	ld	ra,24(sp)
    80004ef4:	6442                	ld	s0,16(sp)
    80004ef6:	6105                	addi	sp,sp,32
    80004ef8:	8082                	ret

0000000080004efa <sys_fstat>:
{
    80004efa:	1101                	addi	sp,sp,-32
    80004efc:	ec06                	sd	ra,24(sp)
    80004efe:	e822                	sd	s0,16(sp)
    80004f00:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004f02:	fe040593          	addi	a1,s0,-32
    80004f06:	4505                	li	a0,1
    80004f08:	b0dfd0ef          	jal	80002a14 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004f0c:	fe840613          	addi	a2,s0,-24
    80004f10:	4581                	li	a1,0
    80004f12:	4501                	li	a0,0
    80004f14:	cf5ff0ef          	jal	80004c08 <argfd>
    80004f18:	87aa                	mv	a5,a0
    return -1;
    80004f1a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f1c:	0007c863          	bltz	a5,80004f2c <sys_fstat+0x32>
  return filestat(f, st);
    80004f20:	fe043583          	ld	a1,-32(s0)
    80004f24:	fe843503          	ld	a0,-24(s0)
    80004f28:	bb8ff0ef          	jal	800042e0 <filestat>
}
    80004f2c:	60e2                	ld	ra,24(sp)
    80004f2e:	6442                	ld	s0,16(sp)
    80004f30:	6105                	addi	sp,sp,32
    80004f32:	8082                	ret

0000000080004f34 <sys_link>:
{
    80004f34:	7169                	addi	sp,sp,-304
    80004f36:	f606                	sd	ra,296(sp)
    80004f38:	f222                	sd	s0,288(sp)
    80004f3a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f3c:	08000613          	li	a2,128
    80004f40:	ed040593          	addi	a1,s0,-304
    80004f44:	4501                	li	a0,0
    80004f46:	aebfd0ef          	jal	80002a30 <argstr>
    return -1;
    80004f4a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f4c:	0c054e63          	bltz	a0,80005028 <sys_link+0xf4>
    80004f50:	08000613          	li	a2,128
    80004f54:	f5040593          	addi	a1,s0,-176
    80004f58:	4505                	li	a0,1
    80004f5a:	ad7fd0ef          	jal	80002a30 <argstr>
    return -1;
    80004f5e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004f60:	0c054463          	bltz	a0,80005028 <sys_link+0xf4>
    80004f64:	ee26                	sd	s1,280(sp)
  begin_op();
    80004f66:	e95fe0ef          	jal	80003dfa <begin_op>
  if((ip = namei(old)) == 0){
    80004f6a:	ed040513          	addi	a0,s0,-304
    80004f6e:	caffe0ef          	jal	80003c1c <namei>
    80004f72:	84aa                	mv	s1,a0
    80004f74:	c53d                	beqz	a0,80004fe2 <sys_link+0xae>
  ilock(ip);
    80004f76:	c78fe0ef          	jal	800033ee <ilock>
  if(ip->type == T_DIR){
    80004f7a:	04449703          	lh	a4,68(s1)
    80004f7e:	4785                	li	a5,1
    80004f80:	06f70663          	beq	a4,a5,80004fec <sys_link+0xb8>
    80004f84:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004f86:	04a4d783          	lhu	a5,74(s1)
    80004f8a:	2785                	addiw	a5,a5,1
    80004f8c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f90:	8526                	mv	a0,s1
    80004f92:	ba8fe0ef          	jal	8000333a <iupdate>
  iunlock(ip);
    80004f96:	8526                	mv	a0,s1
    80004f98:	d04fe0ef          	jal	8000349c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004f9c:	fd040593          	addi	a1,s0,-48
    80004fa0:	f5040513          	addi	a0,s0,-176
    80004fa4:	c93fe0ef          	jal	80003c36 <nameiparent>
    80004fa8:	892a                	mv	s2,a0
    80004faa:	cd21                	beqz	a0,80005002 <sys_link+0xce>
  ilock(dp);
    80004fac:	c42fe0ef          	jal	800033ee <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004fb0:	854a                	mv	a0,s2
    80004fb2:	00092703          	lw	a4,0(s2)
    80004fb6:	409c                	lw	a5,0(s1)
    80004fb8:	04f71263          	bne	a4,a5,80004ffc <sys_link+0xc8>
    80004fbc:	40d0                	lw	a2,4(s1)
    80004fbe:	fd040593          	addi	a1,s0,-48
    80004fc2:	bb1fe0ef          	jal	80003b72 <dirlink>
    80004fc6:	02054b63          	bltz	a0,80004ffc <sys_link+0xc8>
  iunlockput(dp);
    80004fca:	854a                	mv	a0,s2
    80004fcc:	e2efe0ef          	jal	800035fa <iunlockput>
  iput(ip);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	d9efe0ef          	jal	80003570 <iput>
  end_op();
    80004fd6:	e95fe0ef          	jal	80003e6a <end_op>
  return 0;
    80004fda:	4781                	li	a5,0
    80004fdc:	64f2                	ld	s1,280(sp)
    80004fde:	6952                	ld	s2,272(sp)
    80004fe0:	a0a1                	j	80005028 <sys_link+0xf4>
    end_op();
    80004fe2:	e89fe0ef          	jal	80003e6a <end_op>
    return -1;
    80004fe6:	57fd                	li	a5,-1
    80004fe8:	64f2                	ld	s1,280(sp)
    80004fea:	a83d                	j	80005028 <sys_link+0xf4>
    iunlockput(ip);
    80004fec:	8526                	mv	a0,s1
    80004fee:	e0cfe0ef          	jal	800035fa <iunlockput>
    end_op();
    80004ff2:	e79fe0ef          	jal	80003e6a <end_op>
    return -1;
    80004ff6:	57fd                	li	a5,-1
    80004ff8:	64f2                	ld	s1,280(sp)
    80004ffa:	a03d                	j	80005028 <sys_link+0xf4>
    iunlockput(dp);
    80004ffc:	854a                	mv	a0,s2
    80004ffe:	dfcfe0ef          	jal	800035fa <iunlockput>
  ilock(ip);
    80005002:	8526                	mv	a0,s1
    80005004:	beafe0ef          	jal	800033ee <ilock>
  ip->nlink--;
    80005008:	04a4d783          	lhu	a5,74(s1)
    8000500c:	37fd                	addiw	a5,a5,-1
    8000500e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005012:	8526                	mv	a0,s1
    80005014:	b26fe0ef          	jal	8000333a <iupdate>
  iunlockput(ip);
    80005018:	8526                	mv	a0,s1
    8000501a:	de0fe0ef          	jal	800035fa <iunlockput>
  end_op();
    8000501e:	e4dfe0ef          	jal	80003e6a <end_op>
  return -1;
    80005022:	57fd                	li	a5,-1
    80005024:	64f2                	ld	s1,280(sp)
    80005026:	6952                	ld	s2,272(sp)
}
    80005028:	853e                	mv	a0,a5
    8000502a:	70b2                	ld	ra,296(sp)
    8000502c:	7412                	ld	s0,288(sp)
    8000502e:	6155                	addi	sp,sp,304
    80005030:	8082                	ret

0000000080005032 <sys_unlink>:
{
    80005032:	7151                	addi	sp,sp,-240
    80005034:	f586                	sd	ra,232(sp)
    80005036:	f1a2                	sd	s0,224(sp)
    80005038:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000503a:	08000613          	li	a2,128
    8000503e:	f3040593          	addi	a1,s0,-208
    80005042:	4501                	li	a0,0
    80005044:	9edfd0ef          	jal	80002a30 <argstr>
    80005048:	14054d63          	bltz	a0,800051a2 <sys_unlink+0x170>
    8000504c:	eda6                	sd	s1,216(sp)
  begin_op();
    8000504e:	dadfe0ef          	jal	80003dfa <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005052:	fb040593          	addi	a1,s0,-80
    80005056:	f3040513          	addi	a0,s0,-208
    8000505a:	bddfe0ef          	jal	80003c36 <nameiparent>
    8000505e:	84aa                	mv	s1,a0
    80005060:	c955                	beqz	a0,80005114 <sys_unlink+0xe2>
  ilock(dp);
    80005062:	b8cfe0ef          	jal	800033ee <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005066:	00002597          	auipc	a1,0x2
    8000506a:	62258593          	addi	a1,a1,1570 # 80007688 <etext+0x688>
    8000506e:	fb040513          	addi	a0,s0,-80
    80005072:	901fe0ef          	jal	80003972 <namecmp>
    80005076:	10050b63          	beqz	a0,8000518c <sys_unlink+0x15a>
    8000507a:	00002597          	auipc	a1,0x2
    8000507e:	61658593          	addi	a1,a1,1558 # 80007690 <etext+0x690>
    80005082:	fb040513          	addi	a0,s0,-80
    80005086:	8edfe0ef          	jal	80003972 <namecmp>
    8000508a:	10050163          	beqz	a0,8000518c <sys_unlink+0x15a>
    8000508e:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005090:	f2c40613          	addi	a2,s0,-212
    80005094:	fb040593          	addi	a1,s0,-80
    80005098:	8526                	mv	a0,s1
    8000509a:	8effe0ef          	jal	80003988 <dirlookup>
    8000509e:	892a                	mv	s2,a0
    800050a0:	0e050563          	beqz	a0,8000518a <sys_unlink+0x158>
    800050a4:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800050a6:	b48fe0ef          	jal	800033ee <ilock>
  if(ip->nlink < 1)
    800050aa:	04a91783          	lh	a5,74(s2)
    800050ae:	06f05863          	blez	a5,8000511e <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800050b2:	04491703          	lh	a4,68(s2)
    800050b6:	4785                	li	a5,1
    800050b8:	06f70963          	beq	a4,a5,8000512a <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800050bc:	fc040993          	addi	s3,s0,-64
    800050c0:	4641                	li	a2,16
    800050c2:	4581                	li	a1,0
    800050c4:	854e                	mv	a0,s3
    800050c6:	c33fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800050ca:	4741                	li	a4,16
    800050cc:	f2c42683          	lw	a3,-212(s0)
    800050d0:	864e                	mv	a2,s3
    800050d2:	4581                	li	a1,0
    800050d4:	8526                	mv	a0,s1
    800050d6:	f9cfe0ef          	jal	80003872 <writei>
    800050da:	47c1                	li	a5,16
    800050dc:	08f51863          	bne	a0,a5,8000516c <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800050e0:	04491703          	lh	a4,68(s2)
    800050e4:	4785                	li	a5,1
    800050e6:	08f70963          	beq	a4,a5,80005178 <sys_unlink+0x146>
  iunlockput(dp);
    800050ea:	8526                	mv	a0,s1
    800050ec:	d0efe0ef          	jal	800035fa <iunlockput>
  ip->nlink--;
    800050f0:	04a95783          	lhu	a5,74(s2)
    800050f4:	37fd                	addiw	a5,a5,-1
    800050f6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800050fa:	854a                	mv	a0,s2
    800050fc:	a3efe0ef          	jal	8000333a <iupdate>
  iunlockput(ip);
    80005100:	854a                	mv	a0,s2
    80005102:	cf8fe0ef          	jal	800035fa <iunlockput>
  end_op();
    80005106:	d65fe0ef          	jal	80003e6a <end_op>
  return 0;
    8000510a:	4501                	li	a0,0
    8000510c:	64ee                	ld	s1,216(sp)
    8000510e:	694e                	ld	s2,208(sp)
    80005110:	69ae                	ld	s3,200(sp)
    80005112:	a061                	j	8000519a <sys_unlink+0x168>
    end_op();
    80005114:	d57fe0ef          	jal	80003e6a <end_op>
    return -1;
    80005118:	557d                	li	a0,-1
    8000511a:	64ee                	ld	s1,216(sp)
    8000511c:	a8bd                	j	8000519a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    8000511e:	00002517          	auipc	a0,0x2
    80005122:	57a50513          	addi	a0,a0,1402 # 80007698 <etext+0x698>
    80005126:	efefb0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000512a:	04c92703          	lw	a4,76(s2)
    8000512e:	02000793          	li	a5,32
    80005132:	f8e7f5e3          	bgeu	a5,a4,800050bc <sys_unlink+0x8a>
    80005136:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005138:	4741                	li	a4,16
    8000513a:	86ce                	mv	a3,s3
    8000513c:	f1840613          	addi	a2,s0,-232
    80005140:	4581                	li	a1,0
    80005142:	854a                	mv	a0,s2
    80005144:	e3cfe0ef          	jal	80003780 <readi>
    80005148:	47c1                	li	a5,16
    8000514a:	00f51b63          	bne	a0,a5,80005160 <sys_unlink+0x12e>
    if(de.inum != 0)
    8000514e:	f1845783          	lhu	a5,-232(s0)
    80005152:	ebb1                	bnez	a5,800051a6 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005154:	29c1                	addiw	s3,s3,16
    80005156:	04c92783          	lw	a5,76(s2)
    8000515a:	fcf9efe3          	bltu	s3,a5,80005138 <sys_unlink+0x106>
    8000515e:	bfb9                	j	800050bc <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005160:	00002517          	auipc	a0,0x2
    80005164:	55050513          	addi	a0,a0,1360 # 800076b0 <etext+0x6b0>
    80005168:	ebcfb0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    8000516c:	00002517          	auipc	a0,0x2
    80005170:	55c50513          	addi	a0,a0,1372 # 800076c8 <etext+0x6c8>
    80005174:	eb0fb0ef          	jal	80000824 <panic>
    dp->nlink--;
    80005178:	04a4d783          	lhu	a5,74(s1)
    8000517c:	37fd                	addiw	a5,a5,-1
    8000517e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	9b6fe0ef          	jal	8000333a <iupdate>
    80005188:	b78d                	j	800050ea <sys_unlink+0xb8>
    8000518a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000518c:	8526                	mv	a0,s1
    8000518e:	c6cfe0ef          	jal	800035fa <iunlockput>
  end_op();
    80005192:	cd9fe0ef          	jal	80003e6a <end_op>
  return -1;
    80005196:	557d                	li	a0,-1
    80005198:	64ee                	ld	s1,216(sp)
}
    8000519a:	70ae                	ld	ra,232(sp)
    8000519c:	740e                	ld	s0,224(sp)
    8000519e:	616d                	addi	sp,sp,240
    800051a0:	8082                	ret
    return -1;
    800051a2:	557d                	li	a0,-1
    800051a4:	bfdd                	j	8000519a <sys_unlink+0x168>
    iunlockput(ip);
    800051a6:	854a                	mv	a0,s2
    800051a8:	c52fe0ef          	jal	800035fa <iunlockput>
    goto bad;
    800051ac:	694e                	ld	s2,208(sp)
    800051ae:	69ae                	ld	s3,200(sp)
    800051b0:	bff1                	j	8000518c <sys_unlink+0x15a>

00000000800051b2 <sys_open>:

uint64
sys_open(void)
{
    800051b2:	7131                	addi	sp,sp,-192
    800051b4:	fd06                	sd	ra,184(sp)
    800051b6:	f922                	sd	s0,176(sp)
    800051b8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800051ba:	f4c40593          	addi	a1,s0,-180
    800051be:	4505                	li	a0,1
    800051c0:	839fd0ef          	jal	800029f8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051c4:	08000613          	li	a2,128
    800051c8:	f5040593          	addi	a1,s0,-176
    800051cc:	4501                	li	a0,0
    800051ce:	863fd0ef          	jal	80002a30 <argstr>
    800051d2:	87aa                	mv	a5,a0
    return -1;
    800051d4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800051d6:	0a07c363          	bltz	a5,8000527c <sys_open+0xca>
    800051da:	f526                	sd	s1,168(sp)

  begin_op();
    800051dc:	c1ffe0ef          	jal	80003dfa <begin_op>

  if(omode & O_CREATE){
    800051e0:	f4c42783          	lw	a5,-180(s0)
    800051e4:	2007f793          	andi	a5,a5,512
    800051e8:	c3dd                	beqz	a5,8000528e <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800051ea:	4681                	li	a3,0
    800051ec:	4601                	li	a2,0
    800051ee:	4589                	li	a1,2
    800051f0:	f5040513          	addi	a0,s0,-176
    800051f4:	aafff0ef          	jal	80004ca2 <create>
    800051f8:	84aa                	mv	s1,a0
    if(ip == 0){
    800051fa:	c549                	beqz	a0,80005284 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800051fc:	04449703          	lh	a4,68(s1)
    80005200:	478d                	li	a5,3
    80005202:	00f71763          	bne	a4,a5,80005210 <sys_open+0x5e>
    80005206:	0464d703          	lhu	a4,70(s1)
    8000520a:	47a5                	li	a5,9
    8000520c:	0ae7ee63          	bltu	a5,a4,800052c8 <sys_open+0x116>
    80005210:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005212:	f69fe0ef          	jal	8000417a <filealloc>
    80005216:	892a                	mv	s2,a0
    80005218:	c561                	beqz	a0,800052e0 <sys_open+0x12e>
    8000521a:	ed4e                	sd	s3,152(sp)
    8000521c:	a47ff0ef          	jal	80004c62 <fdalloc>
    80005220:	89aa                	mv	s3,a0
    80005222:	0a054b63          	bltz	a0,800052d8 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005226:	04449703          	lh	a4,68(s1)
    8000522a:	478d                	li	a5,3
    8000522c:	0cf70363          	beq	a4,a5,800052f2 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005230:	4789                	li	a5,2
    80005232:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005236:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000523a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000523e:	f4c42783          	lw	a5,-180(s0)
    80005242:	0017f713          	andi	a4,a5,1
    80005246:	00174713          	xori	a4,a4,1
    8000524a:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000524e:	0037f713          	andi	a4,a5,3
    80005252:	00e03733          	snez	a4,a4
    80005256:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000525a:	4007f793          	andi	a5,a5,1024
    8000525e:	c791                	beqz	a5,8000526a <sys_open+0xb8>
    80005260:	04449703          	lh	a4,68(s1)
    80005264:	4789                	li	a5,2
    80005266:	08f70d63          	beq	a4,a5,80005300 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000526a:	8526                	mv	a0,s1
    8000526c:	a30fe0ef          	jal	8000349c <iunlock>
  end_op();
    80005270:	bfbfe0ef          	jal	80003e6a <end_op>

  return fd;
    80005274:	854e                	mv	a0,s3
    80005276:	74aa                	ld	s1,168(sp)
    80005278:	790a                	ld	s2,160(sp)
    8000527a:	69ea                	ld	s3,152(sp)
}
    8000527c:	70ea                	ld	ra,184(sp)
    8000527e:	744a                	ld	s0,176(sp)
    80005280:	6129                	addi	sp,sp,192
    80005282:	8082                	ret
      end_op();
    80005284:	be7fe0ef          	jal	80003e6a <end_op>
      return -1;
    80005288:	557d                	li	a0,-1
    8000528a:	74aa                	ld	s1,168(sp)
    8000528c:	bfc5                	j	8000527c <sys_open+0xca>
    if((ip = namei(path)) == 0){
    8000528e:	f5040513          	addi	a0,s0,-176
    80005292:	98bfe0ef          	jal	80003c1c <namei>
    80005296:	84aa                	mv	s1,a0
    80005298:	c11d                	beqz	a0,800052be <sys_open+0x10c>
    ilock(ip);
    8000529a:	954fe0ef          	jal	800033ee <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000529e:	04449703          	lh	a4,68(s1)
    800052a2:	4785                	li	a5,1
    800052a4:	f4f71ce3          	bne	a4,a5,800051fc <sys_open+0x4a>
    800052a8:	f4c42783          	lw	a5,-180(s0)
    800052ac:	d3b5                	beqz	a5,80005210 <sys_open+0x5e>
      iunlockput(ip);
    800052ae:	8526                	mv	a0,s1
    800052b0:	b4afe0ef          	jal	800035fa <iunlockput>
      end_op();
    800052b4:	bb7fe0ef          	jal	80003e6a <end_op>
      return -1;
    800052b8:	557d                	li	a0,-1
    800052ba:	74aa                	ld	s1,168(sp)
    800052bc:	b7c1                	j	8000527c <sys_open+0xca>
      end_op();
    800052be:	badfe0ef          	jal	80003e6a <end_op>
      return -1;
    800052c2:	557d                	li	a0,-1
    800052c4:	74aa                	ld	s1,168(sp)
    800052c6:	bf5d                	j	8000527c <sys_open+0xca>
    iunlockput(ip);
    800052c8:	8526                	mv	a0,s1
    800052ca:	b30fe0ef          	jal	800035fa <iunlockput>
    end_op();
    800052ce:	b9dfe0ef          	jal	80003e6a <end_op>
    return -1;
    800052d2:	557d                	li	a0,-1
    800052d4:	74aa                	ld	s1,168(sp)
    800052d6:	b75d                	j	8000527c <sys_open+0xca>
      fileclose(f);
    800052d8:	854a                	mv	a0,s2
    800052da:	f45fe0ef          	jal	8000421e <fileclose>
    800052de:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800052e0:	8526                	mv	a0,s1
    800052e2:	b18fe0ef          	jal	800035fa <iunlockput>
    end_op();
    800052e6:	b85fe0ef          	jal	80003e6a <end_op>
    return -1;
    800052ea:	557d                	li	a0,-1
    800052ec:	74aa                	ld	s1,168(sp)
    800052ee:	790a                	ld	s2,160(sp)
    800052f0:	b771                	j	8000527c <sys_open+0xca>
    f->type = FD_DEVICE;
    800052f2:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800052f6:	04649783          	lh	a5,70(s1)
    800052fa:	02f91223          	sh	a5,36(s2)
    800052fe:	bf35                	j	8000523a <sys_open+0x88>
    itrunc(ip);
    80005300:	8526                	mv	a0,s1
    80005302:	9dafe0ef          	jal	800034dc <itrunc>
    80005306:	b795                	j	8000526a <sys_open+0xb8>

0000000080005308 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005308:	7175                	addi	sp,sp,-144
    8000530a:	e506                	sd	ra,136(sp)
    8000530c:	e122                	sd	s0,128(sp)
    8000530e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005310:	aebfe0ef          	jal	80003dfa <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005314:	08000613          	li	a2,128
    80005318:	f7040593          	addi	a1,s0,-144
    8000531c:	4501                	li	a0,0
    8000531e:	f12fd0ef          	jal	80002a30 <argstr>
    80005322:	02054363          	bltz	a0,80005348 <sys_mkdir+0x40>
    80005326:	4681                	li	a3,0
    80005328:	4601                	li	a2,0
    8000532a:	4585                	li	a1,1
    8000532c:	f7040513          	addi	a0,s0,-144
    80005330:	973ff0ef          	jal	80004ca2 <create>
    80005334:	c911                	beqz	a0,80005348 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005336:	ac4fe0ef          	jal	800035fa <iunlockput>
  end_op();
    8000533a:	b31fe0ef          	jal	80003e6a <end_op>
  return 0;
    8000533e:	4501                	li	a0,0
}
    80005340:	60aa                	ld	ra,136(sp)
    80005342:	640a                	ld	s0,128(sp)
    80005344:	6149                	addi	sp,sp,144
    80005346:	8082                	ret
    end_op();
    80005348:	b23fe0ef          	jal	80003e6a <end_op>
    return -1;
    8000534c:	557d                	li	a0,-1
    8000534e:	bfcd                	j	80005340 <sys_mkdir+0x38>

0000000080005350 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005350:	7135                	addi	sp,sp,-160
    80005352:	ed06                	sd	ra,152(sp)
    80005354:	e922                	sd	s0,144(sp)
    80005356:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005358:	aa3fe0ef          	jal	80003dfa <begin_op>
  argint(1, &major);
    8000535c:	f6c40593          	addi	a1,s0,-148
    80005360:	4505                	li	a0,1
    80005362:	e96fd0ef          	jal	800029f8 <argint>
  argint(2, &minor);
    80005366:	f6840593          	addi	a1,s0,-152
    8000536a:	4509                	li	a0,2
    8000536c:	e8cfd0ef          	jal	800029f8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005370:	08000613          	li	a2,128
    80005374:	f7040593          	addi	a1,s0,-144
    80005378:	4501                	li	a0,0
    8000537a:	eb6fd0ef          	jal	80002a30 <argstr>
    8000537e:	02054563          	bltz	a0,800053a8 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005382:	f6841683          	lh	a3,-152(s0)
    80005386:	f6c41603          	lh	a2,-148(s0)
    8000538a:	458d                	li	a1,3
    8000538c:	f7040513          	addi	a0,s0,-144
    80005390:	913ff0ef          	jal	80004ca2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005394:	c911                	beqz	a0,800053a8 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005396:	a64fe0ef          	jal	800035fa <iunlockput>
  end_op();
    8000539a:	ad1fe0ef          	jal	80003e6a <end_op>
  return 0;
    8000539e:	4501                	li	a0,0
}
    800053a0:	60ea                	ld	ra,152(sp)
    800053a2:	644a                	ld	s0,144(sp)
    800053a4:	610d                	addi	sp,sp,160
    800053a6:	8082                	ret
    end_op();
    800053a8:	ac3fe0ef          	jal	80003e6a <end_op>
    return -1;
    800053ac:	557d                	li	a0,-1
    800053ae:	bfcd                	j	800053a0 <sys_mknod+0x50>

00000000800053b0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800053b0:	7135                	addi	sp,sp,-160
    800053b2:	ed06                	sd	ra,152(sp)
    800053b4:	e922                	sd	s0,144(sp)
    800053b6:	e14a                	sd	s2,128(sp)
    800053b8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800053ba:	d74fc0ef          	jal	8000192e <myproc>
    800053be:	892a                	mv	s2,a0
  
  begin_op();
    800053c0:	a3bfe0ef          	jal	80003dfa <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800053c4:	08000613          	li	a2,128
    800053c8:	f6040593          	addi	a1,s0,-160
    800053cc:	4501                	li	a0,0
    800053ce:	e62fd0ef          	jal	80002a30 <argstr>
    800053d2:	04054363          	bltz	a0,80005418 <sys_chdir+0x68>
    800053d6:	e526                	sd	s1,136(sp)
    800053d8:	f6040513          	addi	a0,s0,-160
    800053dc:	841fe0ef          	jal	80003c1c <namei>
    800053e0:	84aa                	mv	s1,a0
    800053e2:	c915                	beqz	a0,80005416 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800053e4:	80afe0ef          	jal	800033ee <ilock>
  if(ip->type != T_DIR){
    800053e8:	04449703          	lh	a4,68(s1)
    800053ec:	4785                	li	a5,1
    800053ee:	02f71963          	bne	a4,a5,80005420 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800053f2:	8526                	mv	a0,s1
    800053f4:	8a8fe0ef          	jal	8000349c <iunlock>
  iput(p->cwd);
    800053f8:	15093503          	ld	a0,336(s2)
    800053fc:	974fe0ef          	jal	80003570 <iput>
  end_op();
    80005400:	a6bfe0ef          	jal	80003e6a <end_op>
  p->cwd = ip;
    80005404:	14993823          	sd	s1,336(s2)
  return 0;
    80005408:	4501                	li	a0,0
    8000540a:	64aa                	ld	s1,136(sp)
}
    8000540c:	60ea                	ld	ra,152(sp)
    8000540e:	644a                	ld	s0,144(sp)
    80005410:	690a                	ld	s2,128(sp)
    80005412:	610d                	addi	sp,sp,160
    80005414:	8082                	ret
    80005416:	64aa                	ld	s1,136(sp)
    end_op();
    80005418:	a53fe0ef          	jal	80003e6a <end_op>
    return -1;
    8000541c:	557d                	li	a0,-1
    8000541e:	b7fd                	j	8000540c <sys_chdir+0x5c>
    iunlockput(ip);
    80005420:	8526                	mv	a0,s1
    80005422:	9d8fe0ef          	jal	800035fa <iunlockput>
    end_op();
    80005426:	a45fe0ef          	jal	80003e6a <end_op>
    return -1;
    8000542a:	557d                	li	a0,-1
    8000542c:	64aa                	ld	s1,136(sp)
    8000542e:	bff9                	j	8000540c <sys_chdir+0x5c>

0000000080005430 <sys_exec>:

uint64
sys_exec(void)
{
    80005430:	7105                	addi	sp,sp,-480
    80005432:	ef86                	sd	ra,472(sp)
    80005434:	eba2                	sd	s0,464(sp)
    80005436:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005438:	e2840593          	addi	a1,s0,-472
    8000543c:	4505                	li	a0,1
    8000543e:	dd6fd0ef          	jal	80002a14 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005442:	08000613          	li	a2,128
    80005446:	f3040593          	addi	a1,s0,-208
    8000544a:	4501                	li	a0,0
    8000544c:	de4fd0ef          	jal	80002a30 <argstr>
    80005450:	87aa                	mv	a5,a0
    return -1;
    80005452:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005454:	0e07c063          	bltz	a5,80005534 <sys_exec+0x104>
    80005458:	e7a6                	sd	s1,456(sp)
    8000545a:	e3ca                	sd	s2,448(sp)
    8000545c:	ff4e                	sd	s3,440(sp)
    8000545e:	fb52                	sd	s4,432(sp)
    80005460:	f756                	sd	s5,424(sp)
    80005462:	f35a                	sd	s6,416(sp)
    80005464:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005466:	e3040a13          	addi	s4,s0,-464
    8000546a:	10000613          	li	a2,256
    8000546e:	4581                	li	a1,0
    80005470:	8552                	mv	a0,s4
    80005472:	887fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005476:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005478:	89d2                	mv	s3,s4
    8000547a:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000547c:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005480:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005482:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005486:	00391513          	slli	a0,s2,0x3
    8000548a:	85d6                	mv	a1,s5
    8000548c:	e2843783          	ld	a5,-472(s0)
    80005490:	953e                	add	a0,a0,a5
    80005492:	cdcfd0ef          	jal	8000296e <fetchaddr>
    80005496:	02054663          	bltz	a0,800054c2 <sys_exec+0x92>
    if(uarg == 0){
    8000549a:	e2043783          	ld	a5,-480(s0)
    8000549e:	c7a1                	beqz	a5,800054e6 <sys_exec+0xb6>
    argv[i] = kalloc();
    800054a0:	ea4fb0ef          	jal	80000b44 <kalloc>
    800054a4:	85aa                	mv	a1,a0
    800054a6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800054aa:	cd01                	beqz	a0,800054c2 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800054ac:	865a                	mv	a2,s6
    800054ae:	e2043503          	ld	a0,-480(s0)
    800054b2:	d06fd0ef          	jal	800029b8 <fetchstr>
    800054b6:	00054663          	bltz	a0,800054c2 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800054ba:	0905                	addi	s2,s2,1
    800054bc:	09a1                	addi	s3,s3,8
    800054be:	fd7914e3          	bne	s2,s7,80005486 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054c2:	100a0a13          	addi	s4,s4,256
    800054c6:	6088                	ld	a0,0(s1)
    800054c8:	cd31                	beqz	a0,80005524 <sys_exec+0xf4>
    kfree(argv[i]);
    800054ca:	d92fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800054ce:	04a1                	addi	s1,s1,8
    800054d0:	ff449be3          	bne	s1,s4,800054c6 <sys_exec+0x96>
  return -1;
    800054d4:	557d                	li	a0,-1
    800054d6:	64be                	ld	s1,456(sp)
    800054d8:	691e                	ld	s2,448(sp)
    800054da:	79fa                	ld	s3,440(sp)
    800054dc:	7a5a                	ld	s4,432(sp)
    800054de:	7aba                	ld	s5,424(sp)
    800054e0:	7b1a                	ld	s6,416(sp)
    800054e2:	6bfa                	ld	s7,408(sp)
    800054e4:	a881                	j	80005534 <sys_exec+0x104>
      argv[i] = 0;
    800054e6:	0009079b          	sext.w	a5,s2
    800054ea:	e3040593          	addi	a1,s0,-464
    800054ee:	078e                	slli	a5,a5,0x3
    800054f0:	97ae                	add	a5,a5,a1
    800054f2:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800054f6:	f3040513          	addi	a0,s0,-208
    800054fa:	bb2ff0ef          	jal	800048ac <kexec>
    800054fe:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005500:	100a0a13          	addi	s4,s4,256
    80005504:	6088                	ld	a0,0(s1)
    80005506:	c511                	beqz	a0,80005512 <sys_exec+0xe2>
    kfree(argv[i]);
    80005508:	d54fb0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000550c:	04a1                	addi	s1,s1,8
    8000550e:	ff449be3          	bne	s1,s4,80005504 <sys_exec+0xd4>
  return ret;
    80005512:	854a                	mv	a0,s2
    80005514:	64be                	ld	s1,456(sp)
    80005516:	691e                	ld	s2,448(sp)
    80005518:	79fa                	ld	s3,440(sp)
    8000551a:	7a5a                	ld	s4,432(sp)
    8000551c:	7aba                	ld	s5,424(sp)
    8000551e:	7b1a                	ld	s6,416(sp)
    80005520:	6bfa                	ld	s7,408(sp)
    80005522:	a809                	j	80005534 <sys_exec+0x104>
  return -1;
    80005524:	557d                	li	a0,-1
    80005526:	64be                	ld	s1,456(sp)
    80005528:	691e                	ld	s2,448(sp)
    8000552a:	79fa                	ld	s3,440(sp)
    8000552c:	7a5a                	ld	s4,432(sp)
    8000552e:	7aba                	ld	s5,424(sp)
    80005530:	7b1a                	ld	s6,416(sp)
    80005532:	6bfa                	ld	s7,408(sp)
}
    80005534:	60fe                	ld	ra,472(sp)
    80005536:	645e                	ld	s0,464(sp)
    80005538:	613d                	addi	sp,sp,480
    8000553a:	8082                	ret

000000008000553c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000553c:	7139                	addi	sp,sp,-64
    8000553e:	fc06                	sd	ra,56(sp)
    80005540:	f822                	sd	s0,48(sp)
    80005542:	f426                	sd	s1,40(sp)
    80005544:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005546:	be8fc0ef          	jal	8000192e <myproc>
    8000554a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000554c:	fd840593          	addi	a1,s0,-40
    80005550:	4501                	li	a0,0
    80005552:	cc2fd0ef          	jal	80002a14 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005556:	fc840593          	addi	a1,s0,-56
    8000555a:	fd040513          	addi	a0,s0,-48
    8000555e:	fddfe0ef          	jal	8000453a <pipealloc>
    return -1;
    80005562:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005564:	0a054763          	bltz	a0,80005612 <sys_pipe+0xd6>
  fd0 = -1;
    80005568:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000556c:	fd043503          	ld	a0,-48(s0)
    80005570:	ef2ff0ef          	jal	80004c62 <fdalloc>
    80005574:	fca42223          	sw	a0,-60(s0)
    80005578:	08054463          	bltz	a0,80005600 <sys_pipe+0xc4>
    8000557c:	fc843503          	ld	a0,-56(s0)
    80005580:	ee2ff0ef          	jal	80004c62 <fdalloc>
    80005584:	fca42023          	sw	a0,-64(s0)
    80005588:	06054263          	bltz	a0,800055ec <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000558c:	4691                	li	a3,4
    8000558e:	fc440613          	addi	a2,s0,-60
    80005592:	fd843583          	ld	a1,-40(s0)
    80005596:	68a8                	ld	a0,80(s1)
    80005598:	8bcfc0ef          	jal	80001654 <copyout>
    8000559c:	00054e63          	bltz	a0,800055b8 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800055a0:	4691                	li	a3,4
    800055a2:	fc040613          	addi	a2,s0,-64
    800055a6:	fd843583          	ld	a1,-40(s0)
    800055aa:	95b6                	add	a1,a1,a3
    800055ac:	68a8                	ld	a0,80(s1)
    800055ae:	8a6fc0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800055b2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800055b4:	04055f63          	bgez	a0,80005612 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800055b8:	fc442783          	lw	a5,-60(s0)
    800055bc:	078e                	slli	a5,a5,0x3
    800055be:	0d078793          	addi	a5,a5,208
    800055c2:	97a6                	add	a5,a5,s1
    800055c4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800055c8:	fc042783          	lw	a5,-64(s0)
    800055cc:	078e                	slli	a5,a5,0x3
    800055ce:	0d078793          	addi	a5,a5,208
    800055d2:	97a6                	add	a5,a5,s1
    800055d4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800055d8:	fd043503          	ld	a0,-48(s0)
    800055dc:	c43fe0ef          	jal	8000421e <fileclose>
    fileclose(wf);
    800055e0:	fc843503          	ld	a0,-56(s0)
    800055e4:	c3bfe0ef          	jal	8000421e <fileclose>
    return -1;
    800055e8:	57fd                	li	a5,-1
    800055ea:	a025                	j	80005612 <sys_pipe+0xd6>
    if(fd0 >= 0)
    800055ec:	fc442783          	lw	a5,-60(s0)
    800055f0:	0007c863          	bltz	a5,80005600 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800055f4:	078e                	slli	a5,a5,0x3
    800055f6:	0d078793          	addi	a5,a5,208
    800055fa:	97a6                	add	a5,a5,s1
    800055fc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005600:	fd043503          	ld	a0,-48(s0)
    80005604:	c1bfe0ef          	jal	8000421e <fileclose>
    fileclose(wf);
    80005608:	fc843503          	ld	a0,-56(s0)
    8000560c:	c13fe0ef          	jal	8000421e <fileclose>
    return -1;
    80005610:	57fd                	li	a5,-1
}
    80005612:	853e                	mv	a0,a5
    80005614:	70e2                	ld	ra,56(sp)
    80005616:	7442                	ld	s0,48(sp)
    80005618:	74a2                	ld	s1,40(sp)
    8000561a:	6121                	addi	sp,sp,64
    8000561c:	8082                	ret
	...

0000000080005620 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005620:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005622:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005624:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005626:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005628:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000562a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000562c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000562e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005630:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005632:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005634:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005636:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005638:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000563a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000563c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000563e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005640:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005642:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005644:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005646:	a36fd0ef          	jal	8000287c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000564a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000564c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000564e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005650:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005652:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005654:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005656:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005658:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000565a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000565c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000565e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005660:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005662:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005664:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005666:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005668:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000566a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000566c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000566e:	10200073          	sret
    80005672:	00000013          	nop
    80005676:	00000013          	nop
    8000567a:	00000013          	nop

000000008000567e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000567e:	1141                	addi	sp,sp,-16
    80005680:	e406                	sd	ra,8(sp)
    80005682:	e022                	sd	s0,0(sp)
    80005684:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005686:	0c000737          	lui	a4,0xc000
    8000568a:	4785                	li	a5,1
    8000568c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000568e:	c35c                	sw	a5,4(a4)
}
    80005690:	60a2                	ld	ra,8(sp)
    80005692:	6402                	ld	s0,0(sp)
    80005694:	0141                	addi	sp,sp,16
    80005696:	8082                	ret

0000000080005698 <plicinithart>:

void
plicinithart(void)
{
    80005698:	1141                	addi	sp,sp,-16
    8000569a:	e406                	sd	ra,8(sp)
    8000569c:	e022                	sd	s0,0(sp)
    8000569e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056a0:	a5afc0ef          	jal	800018fa <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800056a4:	0085171b          	slliw	a4,a0,0x8
    800056a8:	0c0027b7          	lui	a5,0xc002
    800056ac:	97ba                	add	a5,a5,a4
    800056ae:	40200713          	li	a4,1026
    800056b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800056b6:	00d5151b          	slliw	a0,a0,0xd
    800056ba:	0c2017b7          	lui	a5,0xc201
    800056be:	97aa                	add	a5,a5,a0
    800056c0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800056c4:	60a2                	ld	ra,8(sp)
    800056c6:	6402                	ld	s0,0(sp)
    800056c8:	0141                	addi	sp,sp,16
    800056ca:	8082                	ret

00000000800056cc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800056cc:	1141                	addi	sp,sp,-16
    800056ce:	e406                	sd	ra,8(sp)
    800056d0:	e022                	sd	s0,0(sp)
    800056d2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800056d4:	a26fc0ef          	jal	800018fa <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800056d8:	00d5151b          	slliw	a0,a0,0xd
    800056dc:	0c2017b7          	lui	a5,0xc201
    800056e0:	97aa                	add	a5,a5,a0
  return irq;
}
    800056e2:	43c8                	lw	a0,4(a5)
    800056e4:	60a2                	ld	ra,8(sp)
    800056e6:	6402                	ld	s0,0(sp)
    800056e8:	0141                	addi	sp,sp,16
    800056ea:	8082                	ret

00000000800056ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800056ec:	1101                	addi	sp,sp,-32
    800056ee:	ec06                	sd	ra,24(sp)
    800056f0:	e822                	sd	s0,16(sp)
    800056f2:	e426                	sd	s1,8(sp)
    800056f4:	1000                	addi	s0,sp,32
    800056f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800056f8:	a02fc0ef          	jal	800018fa <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800056fc:	00d5179b          	slliw	a5,a0,0xd
    80005700:	0c201737          	lui	a4,0xc201
    80005704:	97ba                	add	a5,a5,a4
    80005706:	c3c4                	sw	s1,4(a5)
}
    80005708:	60e2                	ld	ra,24(sp)
    8000570a:	6442                	ld	s0,16(sp)
    8000570c:	64a2                	ld	s1,8(sp)
    8000570e:	6105                	addi	sp,sp,32
    80005710:	8082                	ret

0000000080005712 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005712:	1141                	addi	sp,sp,-16
    80005714:	e406                	sd	ra,8(sp)
    80005716:	e022                	sd	s0,0(sp)
    80005718:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000571a:	479d                	li	a5,7
    8000571c:	04a7ca63          	blt	a5,a0,80005770 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005720:	0001b797          	auipc	a5,0x1b
    80005724:	40878793          	addi	a5,a5,1032 # 80020b28 <disk>
    80005728:	97aa                	add	a5,a5,a0
    8000572a:	0187c783          	lbu	a5,24(a5)
    8000572e:	e7b9                	bnez	a5,8000577c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005730:	00451693          	slli	a3,a0,0x4
    80005734:	0001b797          	auipc	a5,0x1b
    80005738:	3f478793          	addi	a5,a5,1012 # 80020b28 <disk>
    8000573c:	6398                	ld	a4,0(a5)
    8000573e:	9736                	add	a4,a4,a3
    80005740:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005744:	6398                	ld	a4,0(a5)
    80005746:	9736                	add	a4,a4,a3
    80005748:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000574c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005750:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005754:	97aa                	add	a5,a5,a0
    80005756:	4705                	li	a4,1
    80005758:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000575c:	0001b517          	auipc	a0,0x1b
    80005760:	3e450513          	addi	a0,a0,996 # 80020b40 <disk+0x18>
    80005764:	8d7fc0ef          	jal	8000203a <wakeup>
}
    80005768:	60a2                	ld	ra,8(sp)
    8000576a:	6402                	ld	s0,0(sp)
    8000576c:	0141                	addi	sp,sp,16
    8000576e:	8082                	ret
    panic("free_desc 1");
    80005770:	00002517          	auipc	a0,0x2
    80005774:	f6850513          	addi	a0,a0,-152 # 800076d8 <etext+0x6d8>
    80005778:	8acfb0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    8000577c:	00002517          	auipc	a0,0x2
    80005780:	f6c50513          	addi	a0,a0,-148 # 800076e8 <etext+0x6e8>
    80005784:	8a0fb0ef          	jal	80000824 <panic>

0000000080005788 <virtio_disk_init>:
{
    80005788:	1101                	addi	sp,sp,-32
    8000578a:	ec06                	sd	ra,24(sp)
    8000578c:	e822                	sd	s0,16(sp)
    8000578e:	e426                	sd	s1,8(sp)
    80005790:	e04a                	sd	s2,0(sp)
    80005792:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005794:	00002597          	auipc	a1,0x2
    80005798:	f6458593          	addi	a1,a1,-156 # 800076f8 <etext+0x6f8>
    8000579c:	0001b517          	auipc	a0,0x1b
    800057a0:	4b450513          	addi	a0,a0,1204 # 80020c50 <disk+0x128>
    800057a4:	bfafb0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057a8:	100017b7          	lui	a5,0x10001
    800057ac:	4398                	lw	a4,0(a5)
    800057ae:	2701                	sext.w	a4,a4
    800057b0:	747277b7          	lui	a5,0x74727
    800057b4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800057b8:	14f71863          	bne	a4,a5,80005908 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057bc:	100017b7          	lui	a5,0x10001
    800057c0:	43dc                	lw	a5,4(a5)
    800057c2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800057c4:	4709                	li	a4,2
    800057c6:	14e79163          	bne	a5,a4,80005908 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057ca:	100017b7          	lui	a5,0x10001
    800057ce:	479c                	lw	a5,8(a5)
    800057d0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800057d2:	12e79b63          	bne	a5,a4,80005908 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800057d6:	100017b7          	lui	a5,0x10001
    800057da:	47d8                	lw	a4,12(a5)
    800057dc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800057de:	554d47b7          	lui	a5,0x554d4
    800057e2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800057e6:	12f71163          	bne	a4,a5,80005908 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057ea:	100017b7          	lui	a5,0x10001
    800057ee:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f2:	4705                	li	a4,1
    800057f4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800057f6:	470d                	li	a4,3
    800057f8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800057fa:	10001737          	lui	a4,0x10001
    800057fe:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005800:	c7ffe6b7          	lui	a3,0xc7ffe
    80005804:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddaf7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005808:	8f75                	and	a4,a4,a3
    8000580a:	100016b7          	lui	a3,0x10001
    8000580e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005810:	472d                	li	a4,11
    80005812:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005814:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005818:	439c                	lw	a5,0(a5)
    8000581a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000581e:	8ba1                	andi	a5,a5,8
    80005820:	0e078a63          	beqz	a5,80005914 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005824:	100017b7          	lui	a5,0x10001
    80005828:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000582c:	43fc                	lw	a5,68(a5)
    8000582e:	2781                	sext.w	a5,a5
    80005830:	0e079863          	bnez	a5,80005920 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005834:	100017b7          	lui	a5,0x10001
    80005838:	5bdc                	lw	a5,52(a5)
    8000583a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000583c:	0e078863          	beqz	a5,8000592c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005840:	471d                	li	a4,7
    80005842:	0ef77b63          	bgeu	a4,a5,80005938 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005846:	afefb0ef          	jal	80000b44 <kalloc>
    8000584a:	0001b497          	auipc	s1,0x1b
    8000584e:	2de48493          	addi	s1,s1,734 # 80020b28 <disk>
    80005852:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005854:	af0fb0ef          	jal	80000b44 <kalloc>
    80005858:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000585a:	aeafb0ef          	jal	80000b44 <kalloc>
    8000585e:	87aa                	mv	a5,a0
    80005860:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005862:	6088                	ld	a0,0(s1)
    80005864:	0e050063          	beqz	a0,80005944 <virtio_disk_init+0x1bc>
    80005868:	0001b717          	auipc	a4,0x1b
    8000586c:	2c873703          	ld	a4,712(a4) # 80020b30 <disk+0x8>
    80005870:	cb71                	beqz	a4,80005944 <virtio_disk_init+0x1bc>
    80005872:	cbe9                	beqz	a5,80005944 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005874:	6605                	lui	a2,0x1
    80005876:	4581                	li	a1,0
    80005878:	c80fb0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000587c:	0001b497          	auipc	s1,0x1b
    80005880:	2ac48493          	addi	s1,s1,684 # 80020b28 <disk>
    80005884:	6605                	lui	a2,0x1
    80005886:	4581                	li	a1,0
    80005888:	6488                	ld	a0,8(s1)
    8000588a:	c6efb0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000588e:	6605                	lui	a2,0x1
    80005890:	4581                	li	a1,0
    80005892:	6888                	ld	a0,16(s1)
    80005894:	c64fb0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005898:	100017b7          	lui	a5,0x10001
    8000589c:	4721                	li	a4,8
    8000589e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800058a0:	4098                	lw	a4,0(s1)
    800058a2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800058a6:	40d8                	lw	a4,4(s1)
    800058a8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800058ac:	649c                	ld	a5,8(s1)
    800058ae:	0007869b          	sext.w	a3,a5
    800058b2:	10001737          	lui	a4,0x10001
    800058b6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800058ba:	9781                	srai	a5,a5,0x20
    800058bc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800058c0:	689c                	ld	a5,16(s1)
    800058c2:	0007869b          	sext.w	a3,a5
    800058c6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800058ca:	9781                	srai	a5,a5,0x20
    800058cc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800058d0:	4785                	li	a5,1
    800058d2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800058d4:	00f48c23          	sb	a5,24(s1)
    800058d8:	00f48ca3          	sb	a5,25(s1)
    800058dc:	00f48d23          	sb	a5,26(s1)
    800058e0:	00f48da3          	sb	a5,27(s1)
    800058e4:	00f48e23          	sb	a5,28(s1)
    800058e8:	00f48ea3          	sb	a5,29(s1)
    800058ec:	00f48f23          	sb	a5,30(s1)
    800058f0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800058f4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800058f8:	07272823          	sw	s2,112(a4)
}
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	64a2                	ld	s1,8(sp)
    80005902:	6902                	ld	s2,0(sp)
    80005904:	6105                	addi	sp,sp,32
    80005906:	8082                	ret
    panic("could not find virtio disk");
    80005908:	00002517          	auipc	a0,0x2
    8000590c:	e0050513          	addi	a0,a0,-512 # 80007708 <etext+0x708>
    80005910:	f15fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005914:	00002517          	auipc	a0,0x2
    80005918:	e1450513          	addi	a0,a0,-492 # 80007728 <etext+0x728>
    8000591c:	f09fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80005920:	00002517          	auipc	a0,0x2
    80005924:	e2850513          	addi	a0,a0,-472 # 80007748 <etext+0x748>
    80005928:	efdfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000592c:	00002517          	auipc	a0,0x2
    80005930:	e3c50513          	addi	a0,a0,-452 # 80007768 <etext+0x768>
    80005934:	ef1fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	e5050513          	addi	a0,a0,-432 # 80007788 <etext+0x788>
    80005940:	ee5fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80005944:	00002517          	auipc	a0,0x2
    80005948:	e6450513          	addi	a0,a0,-412 # 800077a8 <etext+0x7a8>
    8000594c:	ed9fa0ef          	jal	80000824 <panic>

0000000080005950 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005950:	711d                	addi	sp,sp,-96
    80005952:	ec86                	sd	ra,88(sp)
    80005954:	e8a2                	sd	s0,80(sp)
    80005956:	e4a6                	sd	s1,72(sp)
    80005958:	e0ca                	sd	s2,64(sp)
    8000595a:	fc4e                	sd	s3,56(sp)
    8000595c:	f852                	sd	s4,48(sp)
    8000595e:	f456                	sd	s5,40(sp)
    80005960:	f05a                	sd	s6,32(sp)
    80005962:	ec5e                	sd	s7,24(sp)
    80005964:	e862                	sd	s8,16(sp)
    80005966:	1080                	addi	s0,sp,96
    80005968:	89aa                	mv	s3,a0
    8000596a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000596c:	00c52b83          	lw	s7,12(a0)
    80005970:	001b9b9b          	slliw	s7,s7,0x1
    80005974:	1b82                	slli	s7,s7,0x20
    80005976:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000597a:	0001b517          	auipc	a0,0x1b
    8000597e:	2d650513          	addi	a0,a0,726 # 80020c50 <disk+0x128>
    80005982:	aa6fb0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    80005986:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005988:	0001ba97          	auipc	s5,0x1b
    8000598c:	1a0a8a93          	addi	s5,s5,416 # 80020b28 <disk>
  for(int i = 0; i < 3; i++){
    80005990:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005992:	5c7d                	li	s8,-1
    80005994:	a095                	j	800059f8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005996:	00fa8733          	add	a4,s5,a5
    8000599a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000599e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800059a0:	0207c563          	bltz	a5,800059ca <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800059a4:	2905                	addiw	s2,s2,1
    800059a6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800059a8:	05490c63          	beq	s2,s4,80005a00 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800059ac:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800059ae:	0001b717          	auipc	a4,0x1b
    800059b2:	17a70713          	addi	a4,a4,378 # 80020b28 <disk>
    800059b6:	4781                	li	a5,0
    if(disk.free[i]){
    800059b8:	01874683          	lbu	a3,24(a4)
    800059bc:	fee9                	bnez	a3,80005996 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800059be:	2785                	addiw	a5,a5,1
    800059c0:	0705                	addi	a4,a4,1
    800059c2:	fe979be3          	bne	a5,s1,800059b8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800059c6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800059ca:	01205d63          	blez	s2,800059e4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059ce:	fa042503          	lw	a0,-96(s0)
    800059d2:	d41ff0ef          	jal	80005712 <free_desc>
      for(int j = 0; j < i; j++)
    800059d6:	4785                	li	a5,1
    800059d8:	0127d663          	bge	a5,s2,800059e4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800059dc:	fa442503          	lw	a0,-92(s0)
    800059e0:	d33ff0ef          	jal	80005712 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800059e4:	0001b597          	auipc	a1,0x1b
    800059e8:	26c58593          	addi	a1,a1,620 # 80020c50 <disk+0x128>
    800059ec:	0001b517          	auipc	a0,0x1b
    800059f0:	15450513          	addi	a0,a0,340 # 80020b40 <disk+0x18>
    800059f4:	dfafc0ef          	jal	80001fee <sleep>
  for(int i = 0; i < 3; i++){
    800059f8:	fa040613          	addi	a2,s0,-96
    800059fc:	4901                	li	s2,0
    800059fe:	b77d                	j	800059ac <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a00:	fa042503          	lw	a0,-96(s0)
    80005a04:	00451693          	slli	a3,a0,0x4

  if(write)
    80005a08:	0001b797          	auipc	a5,0x1b
    80005a0c:	12078793          	addi	a5,a5,288 # 80020b28 <disk>
    80005a10:	00451713          	slli	a4,a0,0x4
    80005a14:	0a070713          	addi	a4,a4,160
    80005a18:	973e                	add	a4,a4,a5
    80005a1a:	01603633          	snez	a2,s6
    80005a1e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005a20:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005a24:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a28:	6398                	ld	a4,0(a5)
    80005a2a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005a2c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005a30:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005a32:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005a34:	6390                	ld	a2,0(a5)
    80005a36:	00d60833          	add	a6,a2,a3
    80005a3a:	4741                	li	a4,16
    80005a3c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005a40:	4585                	li	a1,1
    80005a42:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005a46:	fa442703          	lw	a4,-92(s0)
    80005a4a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005a4e:	0712                	slli	a4,a4,0x4
    80005a50:	963a                	add	a2,a2,a4
    80005a52:	05898813          	addi	a6,s3,88
    80005a56:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005a5a:	0007b883          	ld	a7,0(a5)
    80005a5e:	9746                	add	a4,a4,a7
    80005a60:	40000613          	li	a2,1024
    80005a64:	c710                	sw	a2,8(a4)
  if(write)
    80005a66:	001b3613          	seqz	a2,s6
    80005a6a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005a6e:	8e4d                	or	a2,a2,a1
    80005a70:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005a74:	fa842603          	lw	a2,-88(s0)
    80005a78:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005a7c:	00451813          	slli	a6,a0,0x4
    80005a80:	02080813          	addi	a6,a6,32
    80005a84:	983e                	add	a6,a6,a5
    80005a86:	577d                	li	a4,-1
    80005a88:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005a8c:	0612                	slli	a2,a2,0x4
    80005a8e:	98b2                	add	a7,a7,a2
    80005a90:	03068713          	addi	a4,a3,48
    80005a94:	973e                	add	a4,a4,a5
    80005a96:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005a9a:	6398                	ld	a4,0(a5)
    80005a9c:	9732                	add	a4,a4,a2
    80005a9e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005aa0:	4689                	li	a3,2
    80005aa2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005aa6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005aaa:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005aae:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ab2:	6794                	ld	a3,8(a5)
    80005ab4:	0026d703          	lhu	a4,2(a3)
    80005ab8:	8b1d                	andi	a4,a4,7
    80005aba:	0706                	slli	a4,a4,0x1
    80005abc:	96ba                	add	a3,a3,a4
    80005abe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ac2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ac6:	6798                	ld	a4,8(a5)
    80005ac8:	00275783          	lhu	a5,2(a4)
    80005acc:	2785                	addiw	a5,a5,1
    80005ace:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ad2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ad6:	100017b7          	lui	a5,0x10001
    80005ada:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005ade:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005ae2:	0001b917          	auipc	s2,0x1b
    80005ae6:	16e90913          	addi	s2,s2,366 # 80020c50 <disk+0x128>
  while(b->disk == 1) {
    80005aea:	84ae                	mv	s1,a1
    80005aec:	00b79a63          	bne	a5,a1,80005b00 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005af0:	85ca                	mv	a1,s2
    80005af2:	854e                	mv	a0,s3
    80005af4:	cfafc0ef          	jal	80001fee <sleep>
  while(b->disk == 1) {
    80005af8:	0049a783          	lw	a5,4(s3)
    80005afc:	fe978ae3          	beq	a5,s1,80005af0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005b00:	fa042903          	lw	s2,-96(s0)
    80005b04:	00491713          	slli	a4,s2,0x4
    80005b08:	02070713          	addi	a4,a4,32
    80005b0c:	0001b797          	auipc	a5,0x1b
    80005b10:	01c78793          	addi	a5,a5,28 # 80020b28 <disk>
    80005b14:	97ba                	add	a5,a5,a4
    80005b16:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005b1a:	0001b997          	auipc	s3,0x1b
    80005b1e:	00e98993          	addi	s3,s3,14 # 80020b28 <disk>
    80005b22:	00491713          	slli	a4,s2,0x4
    80005b26:	0009b783          	ld	a5,0(s3)
    80005b2a:	97ba                	add	a5,a5,a4
    80005b2c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005b30:	854a                	mv	a0,s2
    80005b32:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005b36:	bddff0ef          	jal	80005712 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005b3a:	8885                	andi	s1,s1,1
    80005b3c:	f0fd                	bnez	s1,80005b22 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005b3e:	0001b517          	auipc	a0,0x1b
    80005b42:	11250513          	addi	a0,a0,274 # 80020c50 <disk+0x128>
    80005b46:	976fb0ef          	jal	80000cbc <release>
}
    80005b4a:	60e6                	ld	ra,88(sp)
    80005b4c:	6446                	ld	s0,80(sp)
    80005b4e:	64a6                	ld	s1,72(sp)
    80005b50:	6906                	ld	s2,64(sp)
    80005b52:	79e2                	ld	s3,56(sp)
    80005b54:	7a42                	ld	s4,48(sp)
    80005b56:	7aa2                	ld	s5,40(sp)
    80005b58:	7b02                	ld	s6,32(sp)
    80005b5a:	6be2                	ld	s7,24(sp)
    80005b5c:	6c42                	ld	s8,16(sp)
    80005b5e:	6125                	addi	sp,sp,96
    80005b60:	8082                	ret

0000000080005b62 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005b62:	1101                	addi	sp,sp,-32
    80005b64:	ec06                	sd	ra,24(sp)
    80005b66:	e822                	sd	s0,16(sp)
    80005b68:	e426                	sd	s1,8(sp)
    80005b6a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005b6c:	0001b497          	auipc	s1,0x1b
    80005b70:	fbc48493          	addi	s1,s1,-68 # 80020b28 <disk>
    80005b74:	0001b517          	auipc	a0,0x1b
    80005b78:	0dc50513          	addi	a0,a0,220 # 80020c50 <disk+0x128>
    80005b7c:	8acfb0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005b80:	100017b7          	lui	a5,0x10001
    80005b84:	53bc                	lw	a5,96(a5)
    80005b86:	8b8d                	andi	a5,a5,3
    80005b88:	10001737          	lui	a4,0x10001
    80005b8c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005b8e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005b92:	689c                	ld	a5,16(s1)
    80005b94:	0204d703          	lhu	a4,32(s1)
    80005b98:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005b9c:	04f70863          	beq	a4,a5,80005bec <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005ba0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ba4:	6898                	ld	a4,16(s1)
    80005ba6:	0204d783          	lhu	a5,32(s1)
    80005baa:	8b9d                	andi	a5,a5,7
    80005bac:	078e                	slli	a5,a5,0x3
    80005bae:	97ba                	add	a5,a5,a4
    80005bb0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005bb2:	00479713          	slli	a4,a5,0x4
    80005bb6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005bba:	9726                	add	a4,a4,s1
    80005bbc:	01074703          	lbu	a4,16(a4)
    80005bc0:	e329                	bnez	a4,80005c02 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005bc2:	0792                	slli	a5,a5,0x4
    80005bc4:	02078793          	addi	a5,a5,32
    80005bc8:	97a6                	add	a5,a5,s1
    80005bca:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005bcc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005bd0:	c6afc0ef          	jal	8000203a <wakeup>

    disk.used_idx += 1;
    80005bd4:	0204d783          	lhu	a5,32(s1)
    80005bd8:	2785                	addiw	a5,a5,1
    80005bda:	17c2                	slli	a5,a5,0x30
    80005bdc:	93c1                	srli	a5,a5,0x30
    80005bde:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005be2:	6898                	ld	a4,16(s1)
    80005be4:	00275703          	lhu	a4,2(a4)
    80005be8:	faf71ce3          	bne	a4,a5,80005ba0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005bec:	0001b517          	auipc	a0,0x1b
    80005bf0:	06450513          	addi	a0,a0,100 # 80020c50 <disk+0x128>
    80005bf4:	8c8fb0ef          	jal	80000cbc <release>
}
    80005bf8:	60e2                	ld	ra,24(sp)
    80005bfa:	6442                	ld	s0,16(sp)
    80005bfc:	64a2                	ld	s1,8(sp)
    80005bfe:	6105                	addi	sp,sp,32
    80005c00:	8082                	ret
      panic("virtio_disk_intr status");
    80005c02:	00002517          	auipc	a0,0x2
    80005c06:	bbe50513          	addi	a0,a0,-1090 # 800077c0 <etext+0x7c0>
    80005c0a:	c1bfa0ef          	jal	80000824 <panic>
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
