
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	83813103          	ld	sp,-1992(sp) # 8000b838 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd98d7>
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
    8000011a:	1b5020ef          	jal	80002ace <either_copyin>
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
    80000192:	00013517          	auipc	a0,0x13
    80000196:	70e50513          	addi	a0,a0,1806 # 800138a0 <cons>
    8000019a:	28f000ef          	jal	80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	00013497          	auipc	s1,0x13
    800001a2:	70248493          	addi	s1,s1,1794 # 800138a0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	00013917          	auipc	s2,0x13
    800001aa:	79290913          	addi	s2,s2,1938 # 80013938 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	0f9010ef          	jal	80001ab6 <myproc>
    800001c2:	7a4020ef          	jal	80002966 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	55e020ef          	jal	8000272a <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00013717          	auipc	a4,0x13
    800001e2:	6c270713          	addi	a4,a4,1730 # 800138a0 <cons>
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
    80000210:	075020ef          	jal	80002a84 <either_copyout>
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
    80000228:	00013517          	auipc	a0,0x13
    8000022c:	67850513          	addi	a0,a0,1656 # 800138a0 <cons>
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
    8000024e:	00013717          	auipc	a4,0x13
    80000252:	6ef72523          	sw	a5,1770(a4) # 80013938 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	00013517          	auipc	a0,0x13
    80000268:	63c50513          	addi	a0,a0,1596 # 800138a0 <cons>
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
    800002b8:	00013517          	auipc	a0,0x13
    800002bc:	5e850513          	addi	a0,a0,1512 # 800138a0 <cons>
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
    800002da:	03f020ef          	jal	80002b18 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	00013517          	auipc	a0,0x13
    800002e2:	5c250513          	addi	a0,a0,1474 # 800138a0 <cons>
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
    800002fc:	00013717          	auipc	a4,0x13
    80000300:	5a470713          	addi	a4,a4,1444 # 800138a0 <cons>
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
    80000322:	00013717          	auipc	a4,0x13
    80000326:	57e70713          	addi	a4,a4,1406 # 800138a0 <cons>
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
    8000034c:	00013717          	auipc	a4,0x13
    80000350:	5ec72703          	lw	a4,1516(a4) # 80013938 <cons+0x98>
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	08000713          	li	a4,128
    8000035a:	f8e792e3          	bne	a5,a4,800002de <consoleintr+0x32>
    8000035e:	a075                	j	8000040a <consoleintr+0x15e>
    80000360:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000362:	00013717          	auipc	a4,0x13
    80000366:	53e70713          	addi	a4,a4,1342 # 800138a0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000372:	00013497          	auipc	s1,0x13
    80000376:	52e48493          	addi	s1,s1,1326 # 800138a0 <cons>
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
    800003b4:	00013717          	auipc	a4,0x13
    800003b8:	4ec70713          	addi	a4,a4,1260 # 800138a0 <cons>
    800003bc:	0a072783          	lw	a5,160(a4)
    800003c0:	09c72703          	lw	a4,156(a4)
    800003c4:	f0f70de3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003c8:	37fd                	addiw	a5,a5,-1
    800003ca:	00013717          	auipc	a4,0x13
    800003ce:	56f72b23          	sw	a5,1398(a4) # 80013940 <cons+0xa0>
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
    800003e8:	00013797          	auipc	a5,0x13
    800003ec:	4b878793          	addi	a5,a5,1208 # 800138a0 <cons>
    800003f0:	0a07a703          	lw	a4,160(a5)
    800003f4:	0017069b          	addiw	a3,a4,1
    800003f8:	8636                	mv	a2,a3
    800003fa:	0ad7a023          	sw	a3,160(a5)
    800003fe:	07f77713          	andi	a4,a4,127
    80000402:	97ba                	add	a5,a5,a4
    80000404:	4729                	li	a4,10
    80000406:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040a:	00013797          	auipc	a5,0x13
    8000040e:	52c7a923          	sw	a2,1330(a5) # 8001393c <cons+0x9c>
        wakeup(&cons.r);
    80000412:	00013517          	auipc	a0,0x13
    80000416:	52650513          	addi	a0,a0,1318 # 80013938 <cons+0x98>
    8000041a:	35c020ef          	jal	80002776 <wakeup>
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
    80000428:	00008597          	auipc	a1,0x8
    8000042c:	bd858593          	addi	a1,a1,-1064 # 80008000 <etext>
    80000430:	00013517          	auipc	a0,0x13
    80000434:	47050513          	addi	a0,a0,1136 # 800138a0 <cons>
    80000438:	766000ef          	jal	80000b9e <initlock>

  uartinit();
    8000043c:	448000ef          	jal	80000884 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000440:	00024797          	auipc	a5,0x24
    80000444:	95078793          	addi	a5,a5,-1712 # 80023d90 <devsw>
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
    8000047e:	00008817          	auipc	a6,0x8
    80000482:	71a80813          	addi	a6,a6,1818 # 80008b98 <digits>
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
    80000518:	0000b797          	auipc	a5,0xb
    8000051c:	33c7a783          	lw	a5,828(a5) # 8000b854 <panicking>
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
    8000055e:	00013517          	auipc	a0,0x13
    80000562:	3ea50513          	addi	a0,a0,1002 # 80013948 <pr>
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
    800006d2:	00008c97          	auipc	s9,0x8
    800006d6:	4c6c8c93          	addi	s9,s9,1222 # 80008b98 <digits>
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
    80000732:	00008a17          	auipc	s4,0x8
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80008008 <etext+0x8>
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
    8000075a:	0000b797          	auipc	a5,0xb
    8000075e:	0fa7a783          	lw	a5,250(a5) # 8000b854 <panicking>
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
    80000784:	00013517          	auipc	a0,0x13
    80000788:	1c450513          	addi	a0,a0,452 # 80013948 <pr>
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
    80000834:	0000b797          	auipc	a5,0xb
    80000838:	0297a023          	sw	s1,32(a5) # 8000b854 <panicking>
  printf("panic: ");
    8000083c:	00007517          	auipc	a0,0x7
    80000840:	7dc50513          	addi	a0,a0,2012 # 80008018 <etext+0x18>
    80000844:	cb7ff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000848:	85ca                	mv	a1,s2
    8000084a:	00007517          	auipc	a0,0x7
    8000084e:	7d650513          	addi	a0,a0,2006 # 80008020 <etext+0x20>
    80000852:	ca9ff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000856:	0000b797          	auipc	a5,0xb
    8000085a:	fe97ad23          	sw	s1,-6(a5) # 8000b850 <panicked>
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
    80000868:	00007597          	auipc	a1,0x7
    8000086c:	7c058593          	addi	a1,a1,1984 # 80008028 <etext+0x28>
    80000870:	00013517          	auipc	a0,0x13
    80000874:	0d850513          	addi	a0,a0,216 # 80013948 <pr>
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
    800008be:	00007597          	auipc	a1,0x7
    800008c2:	77258593          	addi	a1,a1,1906 # 80008030 <etext+0x30>
    800008c6:	00013517          	auipc	a0,0x13
    800008ca:	09a50513          	addi	a0,a0,154 # 80013960 <tx_lock>
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
    800008ea:	00013517          	auipc	a0,0x13
    800008ee:	07650513          	addi	a0,a0,118 # 80013960 <tx_lock>
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
    80000908:	0000b497          	auipc	s1,0xb
    8000090c:	f5448493          	addi	s1,s1,-172 # 8000b85c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000910:	00013997          	auipc	s3,0x13
    80000914:	05098993          	addi	s3,s3,80 # 80013960 <tx_lock>
    80000918:	0000b917          	auipc	s2,0xb
    8000091c:	f4090913          	addi	s2,s2,-192 # 8000b858 <tx_chan>
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
    8000092c:	5ff010ef          	jal	8000272a <sleep>
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
    80000956:	00013517          	auipc	a0,0x13
    8000095a:	00a50513          	addi	a0,a0,10 # 80013960 <tx_lock>
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
    8000097a:	0000b797          	auipc	a5,0xb
    8000097e:	eda7a783          	lw	a5,-294(a5) # 8000b854 <panicking>
    80000982:	cf95                	beqz	a5,800009be <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000984:	0000b797          	auipc	a5,0xb
    80000988:	ecc7a783          	lw	a5,-308(a5) # 8000b850 <panicked>
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
    800009aa:	0000b797          	auipc	a5,0xb
    800009ae:	eaa7a783          	lw	a5,-342(a5) # 8000b854 <panicking>
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
    80000a06:	00013517          	auipc	a0,0x13
    80000a0a:	f5a50513          	addi	a0,a0,-166 # 80013960 <tx_lock>
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
    80000a20:	00013517          	auipc	a0,0x13
    80000a24:	f4050513          	addi	a0,a0,-192 # 80013960 <tx_lock>
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
    80000a3c:	0000b797          	auipc	a5,0xb
    80000a40:	e207a023          	sw	zero,-480(a5) # 8000b85c <tx_busy>
    wakeup(&tx_chan);
    80000a44:	0000b517          	auipc	a0,0xb
    80000a48:	e1450513          	addi	a0,a0,-492 # 8000b858 <tx_chan>
    80000a4c:	52b010ef          	jal	80002776 <wakeup>
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
    80000a68:	00024797          	auipc	a5,0x24
    80000a6c:	4c078793          	addi	a5,a5,1216 # 80024f28 <end>
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
    80000a92:	00013917          	auipc	s2,0x13
    80000a96:	ee690913          	addi	s2,s2,-282 # 80013978 <kmem>
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
    80000abc:	00007517          	auipc	a0,0x7
    80000ac0:	57c50513          	addi	a0,a0,1404 # 80008038 <etext+0x38>
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
    80000b18:	00007597          	auipc	a1,0x7
    80000b1c:	52858593          	addi	a1,a1,1320 # 80008040 <etext+0x40>
    80000b20:	00013517          	auipc	a0,0x13
    80000b24:	e5850513          	addi	a0,a0,-424 # 80013978 <kmem>
    80000b28:	076000ef          	jal	80000b9e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00024517          	auipc	a0,0x24
    80000b34:	3f850513          	addi	a0,a0,1016 # 80024f28 <end>
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
    80000b4e:	00013517          	auipc	a0,0x13
    80000b52:	e2a50513          	addi	a0,a0,-470 # 80013978 <kmem>
    80000b56:	0d2000ef          	jal	80000c28 <acquire>
  r = kmem.freelist;
    80000b5a:	00013497          	auipc	s1,0x13
    80000b5e:	e364b483          	ld	s1,-458(s1) # 80013990 <kmem+0x18>
  if(r)
    80000b62:	c49d                	beqz	s1,80000b90 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00013717          	auipc	a4,0x13
    80000b6a:	e2f73523          	sd	a5,-470(a4) # 80013990 <kmem+0x18>
  release(&kmem.lock);
    80000b6e:	00013517          	auipc	a0,0x13
    80000b72:	e0a50513          	addi	a0,a0,-502 # 80013978 <kmem>
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
    80000b90:	00013517          	auipc	a0,0x13
    80000b94:	de850513          	addi	a0,a0,-536 # 80013978 <kmem>
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
    80000bce:	6c9000ef          	jal	80001a96 <mycpu>
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
    80000bfe:	699000ef          	jal	80001a96 <mycpu>
    80000c02:	5d3c                	lw	a5,120(a0)
    80000c04:	cb99                	beqz	a5,80000c1a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c06:	691000ef          	jal	80001a96 <mycpu>
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
    80000c1a:	67d000ef          	jal	80001a96 <mycpu>
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
    80000c50:	647000ef          	jal	80001a96 <mycpu>
    80000c54:	e888                	sd	a0,16(s1)
}
    80000c56:	60e2                	ld	ra,24(sp)
    80000c58:	6442                	ld	s0,16(sp)
    80000c5a:	64a2                	ld	s1,8(sp)
    80000c5c:	6105                	addi	sp,sp,32
    80000c5e:	8082                	ret
    panic("acquire");
    80000c60:	00007517          	auipc	a0,0x7
    80000c64:	3e850513          	addi	a0,a0,1000 # 80008048 <etext+0x48>
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
    80000c74:	623000ef          	jal	80001a96 <mycpu>
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
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3ac50513          	addi	a0,a0,940 # 80008050 <etext+0x50>
    80000cac:	b79ff0ef          	jal	80000824 <panic>
    panic("pop_off");
    80000cb0:	00007517          	auipc	a0,0x7
    80000cb4:	3b850513          	addi	a0,a0,952 # 80008068 <etext+0x68>
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
    80000cec:	00007517          	auipc	a0,0x7
    80000cf0:	38450513          	addi	a0,a0,900 # 80008070 <etext+0x70>
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
    80000eb6:	3cd000ef          	jal	80001a82 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eba:	0000b717          	auipc	a4,0xb
    80000ebe:	9a670713          	addi	a4,a4,-1626 # 8000b860 <started>
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
    80000ece:	3b5000ef          	jal	80001a82 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00007517          	auipc	a0,0x7
    80000ed8:	1c450513          	addi	a0,a0,452 # 80008098 <etext+0x98>
    80000edc:	e1eff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	74b010ef          	jal	80002e2e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	7f1040ef          	jal	80005ed8 <plicinithart>
  }

  scheduler();        
    80000eec:	04e010ef          	jal	80001f3a <scheduler>
    consoleinit();
    80000ef0:	d30ff0ef          	jal	80000420 <consoleinit>
    printfinit();
    80000ef4:	96dff0ef          	jal	80000860 <printfinit>
    printf("\n");
    80000ef8:	00007517          	auipc	a0,0x7
    80000efc:	18050513          	addi	a0,a0,384 # 80008078 <etext+0x78>
    80000f00:	dfaff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	17c50513          	addi	a0,a0,380 # 80008080 <etext+0x80>
    80000f0c:	deeff0ef          	jal	800004fa <printf>
    printf("\n");
    80000f10:	00007517          	auipc	a0,0x7
    80000f14:	16850513          	addi	a0,a0,360 # 80008078 <etext+0x78>
    80000f18:	de2ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000f1c:	bf5ff0ef          	jal	80000b10 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2cc000ef          	jal	800011ec <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	2a5000ef          	jal	800019cc <procinit>
    trapinit();      // trap vectors
    80000f2c:	6df010ef          	jal	80002e0a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	6ff010ef          	jal	80002e2e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	78b040ef          	jal	80005ebe <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	7a1040ef          	jal	80005ed8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	5d6020ef          	jal	80003512 <binit>
    iinit();         // inode table
    80000f40:	329020ef          	jal	80003a68 <iinit>
    fileinit();      // file table
    80000f44:	255030ef          	jal	80004998 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	080050ef          	jal	80005fc8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	643000ef          	jal	80001d8e <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	0000b717          	auipc	a4,0xb
    80000f5a:	90f72523          	sw	a5,-1782(a4) # 8000b860 <started>
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
    80000f6c:	0000b797          	auipc	a5,0xb
    80000f70:	8fc7b783          	ld	a5,-1796(a5) # 8000b868 <kernel_pagetable>
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
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	0be50513          	addi	a0,a0,190 # 800080b0 <etext+0xb0>
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
    800010ca:	00007517          	auipc	a0,0x7
    800010ce:	fee50513          	addi	a0,a0,-18 # 800080b8 <etext+0xb8>
    800010d2:	f52ff0ef          	jal	80000824 <panic>
    panic("mappages: size not aligned");
    800010d6:	00007517          	auipc	a0,0x7
    800010da:	00250513          	addi	a0,a0,2 # 800080d8 <etext+0xd8>
    800010de:	f46ff0ef          	jal	80000824 <panic>
    panic("mappages: size");
    800010e2:	00007517          	auipc	a0,0x7
    800010e6:	01650513          	addi	a0,a0,22 # 800080f8 <etext+0xf8>
    800010ea:	f3aff0ef          	jal	80000824 <panic>
      panic("mappages: remap");
    800010ee:	00007517          	auipc	a0,0x7
    800010f2:	01a50513          	addi	a0,a0,26 # 80008108 <etext+0x108>
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
    80001132:	00007517          	auipc	a0,0x7
    80001136:	fe650513          	addi	a0,a0,-26 # 80008118 <etext+0x118>
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
    8000118a:	80007697          	auipc	a3,0x80007
    8000118e:	e7668693          	addi	a3,a3,-394 # 8000 <_entry-0x7fff8000>
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f7dff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	00007697          	auipc	a3,0x7
    800011a4:	e6068693          	addi	a3,a3,-416 # 80008000 <etext>
    800011a8:	47c5                	li	a5,17
    800011aa:	07ee                	slli	a5,a5,0x1b
    800011ac:	40d786b3          	sub	a3,a5,a3
    800011b0:	00007617          	auipc	a2,0x7
    800011b4:	e5060613          	addi	a2,a2,-432 # 80008000 <etext>
    800011b8:	85b2                	mv	a1,a2
    800011ba:	8526                	mv	a0,s1
    800011bc:	f5bff0ef          	jal	80001116 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c0:	4729                	li	a4,10
    800011c2:	6685                	lui	a3,0x1
    800011c4:	00006617          	auipc	a2,0x6
    800011c8:	e3c60613          	addi	a2,a2,-452 # 80007000 <_trampoline>
    800011cc:	040005b7          	lui	a1,0x4000
    800011d0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011d2:	05b2                	slli	a1,a1,0xc
    800011d4:	8526                	mv	a0,s1
    800011d6:	f41ff0ef          	jal	80001116 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011da:	8526                	mv	a0,s1
    800011dc:	74c000ef          	jal	80001928 <proc_mapstacks>
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
    800011f8:	0000a797          	auipc	a5,0xa
    800011fc:	66a7b823          	sd	a0,1648(a5) # 8000b868 <kernel_pagetable>
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
    80001268:	00007517          	auipc	a0,0x7
    8000126c:	eb850513          	addi	a0,a0,-328 # 80008120 <etext+0x120>
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
    800013be:	00007517          	auipc	a0,0x7
    800013c2:	d7a50513          	addi	a0,a0,-646 # 80008138 <etext+0x138>
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
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	c5c50513          	addi	a0,a0,-932 # 80008148 <etext+0x148>
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
    800015e0:	4d6000ef          	jal	80001ab6 <myproc>
  if (va >= p->sz)
    800015e4:	693c                	ld	a5,80(a0)
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
    80001632:	6ca8                	ld	a0,88(s1)
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

00000000800017a0 <tm_find>:
static int   tm_cooling_cycles = 0;
static int   tm_had_children = 0; // 1 if we saw schedtest children

static struct thermal_metrics*
tm_find(int pid)
{
    800017a0:	1141                	addi	sp,sp,-16
    800017a2:	e406                	sd	ra,8(sp)
    800017a4:	e022                	sd	s0,0(sp)
    800017a6:	0800                	addi	s0,sp,16
  // find existing or allocate a new slot
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017a8:	00012617          	auipc	a2,0x12
    800017ac:	1f060613          	addi	a2,a2,496 # 80013998 <tm>
{
    800017b0:	8732                	mv	a4,a2
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017b2:	4781                	li	a5,0
    800017b4:	45c1                	li	a1,16
    if(tm[i].pid == pid) return &tm[i];
    800017b6:	4314                	lw	a3,0(a4)
    800017b8:	02a68063          	beq	a3,a0,800017d8 <tm_find+0x38>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017bc:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda0d9>
    800017be:	0761                	addi	a4,a4,24
    800017c0:	feb79be3          	bne	a5,a1,800017b6 <tm_find+0x16>
  }
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017c4:	4781                	li	a5,0
    800017c6:	46c1                	li	a3,16
    if(tm[i].pid == 0){
    800017c8:	4218                	lw	a4,0(a2)
    800017ca:	c705                	beqz	a4,800017f2 <tm_find+0x52>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800017cc:	2785                	addiw	a5,a5,1
    800017ce:	0661                	addi	a2,a2,24
    800017d0:	fed79ce3          	bne	a5,a3,800017c8 <tm_find+0x28>
      tm[i].heat_min = MAX_HEAT + 1;
      tm[i].heat_max = -1;
      return &tm[i];
    }
  }
  return 0; // table full
    800017d4:	4501                	li	a0,0
    800017d6:	a811                	j	800017ea <tm_find+0x4a>
    if(tm[i].pid == pid) return &tm[i];
    800017d8:	00179713          	slli	a4,a5,0x1
    800017dc:	97ba                	add	a5,a5,a4
    800017de:	078e                	slli	a5,a5,0x3
    800017e0:	00012517          	auipc	a0,0x12
    800017e4:	1b850513          	addi	a0,a0,440 # 80013998 <tm>
    800017e8:	953e                	add	a0,a0,a5
}
    800017ea:	60a2                	ld	ra,8(sp)
    800017ec:	6402                	ld	s0,0(sp)
    800017ee:	0141                	addi	sp,sp,16
    800017f0:	8082                	ret
      tm[i].pid = pid;
    800017f2:	00012717          	auipc	a4,0x12
    800017f6:	1a670713          	addi	a4,a4,422 # 80013998 <tm>
    800017fa:	00179613          	slli	a2,a5,0x1
    800017fe:	00f606b3          	add	a3,a2,a5
    80001802:	068e                	slli	a3,a3,0x3
    80001804:	96ba                	add	a3,a3,a4
    80001806:	c288                	sw	a0,0(a3)
      tm[i].heat_min = MAX_HEAT + 1;
    80001808:	06500593          	li	a1,101
    8000180c:	ca8c                	sw	a1,16(a3)
      tm[i].heat_max = -1;
    8000180e:	55fd                	li	a1,-1
    80001810:	cacc                	sw	a1,20(a3)
      return &tm[i];
    80001812:	8536                	mv	a0,a3
    80001814:	bfd9                	j	800017ea <tm_find+0x4a>

0000000080001816 <tm_record_skip>:
  if(cpu_temp > tm_temp_max) tm_temp_max = cpu_temp;
}

static void
tm_record_skip(int pid)
{
    80001816:	1141                	addi	sp,sp,-16
    80001818:	e406                	sd	ra,8(sp)
    8000181a:	e022                	sd	s0,0(sp)
    8000181c:	0800                	addi	s0,sp,16
  struct thermal_metrics *m = tm_find(pid);
    8000181e:	f83ff0ef          	jal	800017a0 <tm_find>
  if(!m) return;
    80001822:	c501                	beqz	a0,8000182a <tm_record_skip+0x14>
  m->skip_count++;
    80001824:	451c                	lw	a5,8(a0)
    80001826:	2785                	addiw	a5,a5,1
    80001828:	c51c                	sw	a5,8(a0)
}
    8000182a:	60a2                	ld	ra,8(sp)
    8000182c:	6402                	ld	s0,0(sp)
    8000182e:	0141                	addi	sp,sp,16
    80001830:	8082                	ret

0000000080001832 <printpad>:

// Print integer right-aligned in a field of 'width' characters.
// xv6 printf has no width specifiers, so we do it manually.
static void
printpad(int val, int width)
{
    80001832:	7179                	addi	sp,sp,-48
    80001834:	f406                	sd	ra,40(sp)
    80001836:	f022                	sd	s0,32(sp)
    80001838:	e84a                	sd	s2,16(sp)
    8000183a:	e44e                	sd	s3,8(sp)
    8000183c:	1800                	addi	s0,sp,48
    8000183e:	89aa                	mv	s3,a0
  // Count digits
  int tmp = val;
  int digits = 0;
  if(tmp <= 0) digits = 1;
    80001840:	00152693          	slti	a3,a0,1
  while(tmp > 0){ digits++; tmp /= 10; }
    80001844:	02a05363          	blez	a0,8000186a <printpad+0x38>
    80001848:	87aa                	mv	a5,a0
    8000184a:	66666537          	lui	a0,0x66666
    8000184e:	66750513          	addi	a0,a0,1639 # 66666667 <_entry-0x19999999>
    80001852:	4825                	li	a6,9
    80001854:	2685                	addiw	a3,a3,1 # fffffffffffff001 <end+0xffffffff7ffda0d9>
    80001856:	863e                	mv	a2,a5
    80001858:	02a78733          	mul	a4,a5,a0
    8000185c:	9709                	srai	a4,a4,0x22
    8000185e:	41f7d79b          	sraiw	a5,a5,0x1f
    80001862:	40f707bb          	subw	a5,a4,a5
    80001866:	fec847e3          	blt	a6,a2,80001854 <printpad+0x22>
  // Print leading spaces
  for(int i = 0; i < width - digits; i++)
    8000186a:	40d5893b          	subw	s2,a1,a3
    8000186e:	03205163          	blez	s2,80001890 <printpad+0x5e>
    80001872:	ec26                	sd	s1,24(sp)
    80001874:	e052                	sd	s4,0(sp)
    80001876:	4481                	li	s1,0
    printf(" ");
    80001878:	00007a17          	auipc	s4,0x7
    8000187c:	8e0a0a13          	addi	s4,s4,-1824 # 80008158 <etext+0x158>
    80001880:	8552                	mv	a0,s4
    80001882:	c79fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < width - digits; i++)
    80001886:	2485                	addiw	s1,s1,1
    80001888:	ff249ce3          	bne	s1,s2,80001880 <printpad+0x4e>
    8000188c:	64e2                	ld	s1,24(sp)
    8000188e:	6a02                	ld	s4,0(sp)
  printf("%d", val);
    80001890:	85ce                	mv	a1,s3
    80001892:	00007517          	auipc	a0,0x7
    80001896:	8ce50513          	addi	a0,a0,-1842 # 80008160 <etext+0x160>
    8000189a:	c61fe0ef          	jal	800004fa <printf>
}
    8000189e:	70a2                	ld	ra,40(sp)
    800018a0:	7402                	ld	s0,32(sp)
    800018a2:	6942                	ld	s2,16(sp)
    800018a4:	69a2                	ld	s3,8(sp)
    800018a6:	6145                	addi	sp,sp,48
    800018a8:	8082                	ret

00000000800018aa <update_cpu_temp>:
void update_cpu_temp(int process_heat) {
    800018aa:	1141                	addi	sp,sp,-16
    800018ac:	e406                	sd	ra,8(sp)
    800018ae:	e022                	sd	s0,0(sp)
    800018b0:	0800                	addi	s0,sp,16
  if (process_heat > 0) {
    800018b2:	04a05263          	blez	a0,800018f6 <update_cpu_temp+0x4c>
    int heat_factor = 1 + process_heat / 30;  // 1‒4
    800018b6:	888897b7          	lui	a5,0x88889
    800018ba:	88978793          	addi	a5,a5,-1911 # ffffffff88888889 <end+0xffffffff08863961>
    800018be:	02f507b3          	mul	a5,a0,a5
    800018c2:	9381                	srli	a5,a5,0x20
    800018c4:	9fa9                	addw	a5,a5,a0
    800018c6:	4047d79b          	sraiw	a5,a5,0x4
    800018ca:	41f5551b          	sraiw	a0,a0,0x1f
    800018ce:	9f89                	subw	a5,a5,a0
    800018d0:	2785                	addiw	a5,a5,1
    cpu_temp += heat_factor;
    800018d2:	0000a717          	auipc	a4,0xa
    800018d6:	f5672703          	lw	a4,-170(a4) # 8000b828 <cpu_temp>
    800018da:	9fb9                	addw	a5,a5,a4
  if(cpu_temp > 100)
    800018dc:	06400713          	li	a4,100
    800018e0:	02f75663          	bge	a4,a5,8000190c <update_cpu_temp+0x62>
    cpu_temp = 100;
    800018e4:	87ba                	mv	a5,a4
    800018e6:	0000a717          	auipc	a4,0xa
    800018ea:	f4f72123          	sw	a5,-190(a4) # 8000b828 <cpu_temp>
}
    800018ee:	60a2                	ld	ra,8(sp)
    800018f0:	6402                	ld	s0,0(sp)
    800018f2:	0141                	addi	sp,sp,16
    800018f4:	8082                	ret
    cpu_temp -= (cpu_temp > 50) ? 2 : 1;
    800018f6:	0000a797          	auipc	a5,0xa
    800018fa:	f327a783          	lw	a5,-206(a5) # 8000b828 <cpu_temp>
    800018fe:	03200713          	li	a4,50
    80001902:	00f72733          	slt	a4,a4,a5
    80001906:	0705                	addi	a4,a4,1
    80001908:	9f99                	subw	a5,a5,a4
    8000190a:	bfc9                	j	800018dc <update_cpu_temp+0x32>
  else if(cpu_temp < 20)
    8000190c:	474d                	li	a4,19
    8000190e:	00f75763          	bge	a4,a5,8000191c <update_cpu_temp+0x72>
    cpu_temp += heat_factor;
    80001912:	0000a717          	auipc	a4,0xa
    80001916:	f0f72b23          	sw	a5,-234(a4) # 8000b828 <cpu_temp>
    8000191a:	bfd1                	j	800018ee <update_cpu_temp+0x44>
    cpu_temp = 20;
    8000191c:	47d1                	li	a5,20
    8000191e:	0000a717          	auipc	a4,0xa
    80001922:	f0f72523          	sw	a5,-246(a4) # 8000b828 <cpu_temp>
}
    80001926:	b7e1                	j	800018ee <update_cpu_temp+0x44>

0000000080001928 <proc_mapstacks>:
{
    80001928:	715d                	addi	sp,sp,-80
    8000192a:	e486                	sd	ra,72(sp)
    8000192c:	e0a2                	sd	s0,64(sp)
    8000192e:	fc26                	sd	s1,56(sp)
    80001930:	f84a                	sd	s2,48(sp)
    80001932:	f44e                	sd	s3,40(sp)
    80001934:	f052                	sd	s4,32(sp)
    80001936:	ec56                	sd	s5,24(sp)
    80001938:	e85a                	sd	s6,16(sp)
    8000193a:	e45e                	sd	s7,8(sp)
    8000193c:	e062                	sd	s8,0(sp)
    8000193e:	0880                	addi	s0,sp,80
    80001940:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001942:	00012497          	auipc	s1,0x12
    80001946:	60648493          	addi	s1,s1,1542 # 80013f48 <proc>
    uint64 va = KSTACK((int) (p - proc));
    8000194a:	8c26                	mv	s8,s1
    8000194c:	ff4df937          	lui	s2,0xff4df
    80001950:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a95>
    80001954:	0936                	slli	s2,s2,0xd
    80001956:	6f590913          	addi	s2,s2,1781
    8000195a:	0936                	slli	s2,s2,0xd
    8000195c:	bd390913          	addi	s2,s2,-1069
    80001960:	0932                	slli	s2,s2,0xc
    80001962:	7a790913          	addi	s2,s2,1959
    80001966:	040009b7          	lui	s3,0x4000
    8000196a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000196c:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000196e:	4b99                	li	s7,6
    80001970:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001972:	00018a97          	auipc	s5,0x18
    80001976:	1d6a8a93          	addi	s5,s5,470 # 80019b48 <tickslock>
    char *pa = kalloc();
    8000197a:	9caff0ef          	jal	80000b44 <kalloc>
    8000197e:	862a                	mv	a2,a0
    if(pa == 0)
    80001980:	c121                	beqz	a0,800019c0 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int) (p - proc));
    80001982:	418485b3          	sub	a1,s1,s8
    80001986:	8591                	srai	a1,a1,0x4
    80001988:	032585b3          	mul	a1,a1,s2
    8000198c:	05b6                	slli	a1,a1,0xd
    8000198e:	6789                	lui	a5,0x2
    80001990:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001992:	875e                	mv	a4,s7
    80001994:	86da                	mv	a3,s6
    80001996:	40b985b3          	sub	a1,s3,a1
    8000199a:	8552                	mv	a0,s4
    8000199c:	f7aff0ef          	jal	80001116 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	17048493          	addi	s1,s1,368
    800019a4:	fd549be3          	bne	s1,s5,8000197a <proc_mapstacks+0x52>
}
    800019a8:	60a6                	ld	ra,72(sp)
    800019aa:	6406                	ld	s0,64(sp)
    800019ac:	74e2                	ld	s1,56(sp)
    800019ae:	7942                	ld	s2,48(sp)
    800019b0:	79a2                	ld	s3,40(sp)
    800019b2:	7a02                	ld	s4,32(sp)
    800019b4:	6ae2                	ld	s5,24(sp)
    800019b6:	6b42                	ld	s6,16(sp)
    800019b8:	6ba2                	ld	s7,8(sp)
    800019ba:	6c02                	ld	s8,0(sp)
    800019bc:	6161                	addi	sp,sp,80
    800019be:	8082                	ret
      panic("kalloc");
    800019c0:	00006517          	auipc	a0,0x6
    800019c4:	7a850513          	addi	a0,a0,1960 # 80008168 <etext+0x168>
    800019c8:	e5dfe0ef          	jal	80000824 <panic>

00000000800019cc <procinit>:
{
    800019cc:	7139                	addi	sp,sp,-64
    800019ce:	fc06                	sd	ra,56(sp)
    800019d0:	f822                	sd	s0,48(sp)
    800019d2:	f426                	sd	s1,40(sp)
    800019d4:	f04a                	sd	s2,32(sp)
    800019d6:	ec4e                	sd	s3,24(sp)
    800019d8:	e852                	sd	s4,16(sp)
    800019da:	e456                	sd	s5,8(sp)
    800019dc:	e05a                	sd	s6,0(sp)
    800019de:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    800019e0:	00006597          	auipc	a1,0x6
    800019e4:	79058593          	addi	a1,a1,1936 # 80008170 <etext+0x170>
    800019e8:	00012517          	auipc	a0,0x12
    800019ec:	13050513          	addi	a0,a0,304 # 80013b18 <pid_lock>
    800019f0:	9aeff0ef          	jal	80000b9e <initlock>
  initlock(&wait_lock, "wait_lock");
    800019f4:	00006597          	auipc	a1,0x6
    800019f8:	78458593          	addi	a1,a1,1924 # 80008178 <etext+0x178>
    800019fc:	00012517          	auipc	a0,0x12
    80001a00:	13450513          	addi	a0,a0,308 # 80013b30 <wait_lock>
    80001a04:	99aff0ef          	jal	80000b9e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a08:	00012497          	auipc	s1,0x12
    80001a0c:	54048493          	addi	s1,s1,1344 # 80013f48 <proc>
      initlock(&p->lock, "proc");
    80001a10:	00006b17          	auipc	s6,0x6
    80001a14:	778b0b13          	addi	s6,s6,1912 # 80008188 <etext+0x188>
      p->kstack = KSTACK((int) (p - proc));
    80001a18:	8aa6                	mv	s5,s1
    80001a1a:	ff4df937          	lui	s2,0xff4df
    80001a1e:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b9a95>
    80001a22:	0936                	slli	s2,s2,0xd
    80001a24:	6f590913          	addi	s2,s2,1781
    80001a28:	0936                	slli	s2,s2,0xd
    80001a2a:	bd390913          	addi	s2,s2,-1069
    80001a2e:	0932                	slli	s2,s2,0xc
    80001a30:	7a790913          	addi	s2,s2,1959
    80001a34:	040009b7          	lui	s3,0x4000
    80001a38:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a3a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a3c:	00018a17          	auipc	s4,0x18
    80001a40:	10ca0a13          	addi	s4,s4,268 # 80019b48 <tickslock>
      initlock(&p->lock, "proc");
    80001a44:	85da                	mv	a1,s6
    80001a46:	8526                	mv	a0,s1
    80001a48:	956ff0ef          	jal	80000b9e <initlock>
      p->state = UNUSED;
    80001a4c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001a50:	415487b3          	sub	a5,s1,s5
    80001a54:	8791                	srai	a5,a5,0x4
    80001a56:	032787b3          	mul	a5,a5,s2
    80001a5a:	07b6                	slli	a5,a5,0xd
    80001a5c:	6709                	lui	a4,0x2
    80001a5e:	9fb9                	addw	a5,a5,a4
    80001a60:	40f987b3          	sub	a5,s3,a5
    80001a64:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a66:	17048493          	addi	s1,s1,368
    80001a6a:	fd449de3          	bne	s1,s4,80001a44 <procinit+0x78>
}
    80001a6e:	70e2                	ld	ra,56(sp)
    80001a70:	7442                	ld	s0,48(sp)
    80001a72:	74a2                	ld	s1,40(sp)
    80001a74:	7902                	ld	s2,32(sp)
    80001a76:	69e2                	ld	s3,24(sp)
    80001a78:	6a42                	ld	s4,16(sp)
    80001a7a:	6aa2                	ld	s5,8(sp)
    80001a7c:	6b02                	ld	s6,0(sp)
    80001a7e:	6121                	addi	sp,sp,64
    80001a80:	8082                	ret

0000000080001a82 <cpuid>:
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a8a:	8512                	mv	a0,tp
}
    80001a8c:	2501                	sext.w	a0,a0
    80001a8e:	60a2                	ld	ra,8(sp)
    80001a90:	6402                	ld	s0,0(sp)
    80001a92:	0141                	addi	sp,sp,16
    80001a94:	8082                	ret

0000000080001a96 <mycpu>:
{
    80001a96:	1141                	addi	sp,sp,-16
    80001a98:	e406                	sd	ra,8(sp)
    80001a9a:	e022                	sd	s0,0(sp)
    80001a9c:	0800                	addi	s0,sp,16
    80001a9e:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001aa0:	2781                	sext.w	a5,a5
    80001aa2:	079e                	slli	a5,a5,0x7
}
    80001aa4:	00012517          	auipc	a0,0x12
    80001aa8:	0a450513          	addi	a0,a0,164 # 80013b48 <cpus>
    80001aac:	953e                	add	a0,a0,a5
    80001aae:	60a2                	ld	ra,8(sp)
    80001ab0:	6402                	ld	s0,0(sp)
    80001ab2:	0141                	addi	sp,sp,16
    80001ab4:	8082                	ret

0000000080001ab6 <myproc>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	1000                	addi	s0,sp,32
  push_off();
    80001ac0:	924ff0ef          	jal	80000be4 <push_off>
    80001ac4:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001ac6:	2781                	sext.w	a5,a5
    80001ac8:	079e                	slli	a5,a5,0x7
    80001aca:	00012717          	auipc	a4,0x12
    80001ace:	ece70713          	addi	a4,a4,-306 # 80013998 <tm>
    80001ad2:	97ba                	add	a5,a5,a4
    80001ad4:	1b07b783          	ld	a5,432(a5) # 21b0 <_entry-0x7fffde50>
    80001ad8:	84be                	mv	s1,a5
  pop_off();
    80001ada:	992ff0ef          	jal	80000c6c <pop_off>
}
    80001ade:	8526                	mv	a0,s1
    80001ae0:	60e2                	ld	ra,24(sp)
    80001ae2:	6442                	ld	s0,16(sp)
    80001ae4:	64a2                	ld	s1,8(sp)
    80001ae6:	6105                	addi	sp,sp,32
    80001ae8:	8082                	ret

0000000080001aea <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001aea:	7179                	addi	sp,sp,-48
    80001aec:	f406                	sd	ra,40(sp)
    80001aee:	f022                	sd	s0,32(sp)
    80001af0:	ec26                	sd	s1,24(sp)
    80001af2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001af4:	fc3ff0ef          	jal	80001ab6 <myproc>
    80001af8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001afa:	9c2ff0ef          	jal	80000cbc <release>

  if (first) {
    80001afe:	0000a797          	auipc	a5,0xa
    80001b02:	d227a783          	lw	a5,-734(a5) # 8000b820 <first.2>
    80001b06:	cf95                	beqz	a5,80001b42 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001b08:	4505                	li	a0,1
    80001b0a:	41a020ef          	jal	80003f24 <fsinit>

    first = 0;
    80001b0e:	0000a797          	auipc	a5,0xa
    80001b12:	d007a923          	sw	zero,-750(a5) # 8000b820 <first.2>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001b16:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001b1a:	00006797          	auipc	a5,0x6
    80001b1e:	67678793          	addi	a5,a5,1654 # 80008190 <etext+0x190>
    80001b22:	fcf43823          	sd	a5,-48(s0)
    80001b26:	fc043c23          	sd	zero,-40(s0)
    80001b2a:	fd040593          	addi	a1,s0,-48
    80001b2e:	853e                	mv	a0,a5
    80001b30:	5be030ef          	jal	800050ee <kexec>
    80001b34:	70bc                	ld	a5,96(s1)
    80001b36:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001b38:	70bc                	ld	a5,96(s1)
    80001b3a:	7bb8                	ld	a4,112(a5)
    80001b3c:	57fd                	li	a5,-1
    80001b3e:	02f70d63          	beq	a4,a5,80001b78 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001b42:	308010ef          	jal	80002e4a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b46:	6ca8                	ld	a0,88(s1)
    80001b48:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b4a:	04000737          	lui	a4,0x4000
    80001b4e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001b50:	0732                	slli	a4,a4,0xc
    80001b52:	00005797          	auipc	a5,0x5
    80001b56:	54a78793          	addi	a5,a5,1354 # 8000709c <userret>
    80001b5a:	00005697          	auipc	a3,0x5
    80001b5e:	4a668693          	addi	a3,a3,1190 # 80007000 <_trampoline>
    80001b62:	8f95                	sub	a5,a5,a3
    80001b64:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b66:	577d                	li	a4,-1
    80001b68:	177e                	slli	a4,a4,0x3f
    80001b6a:	8d59                	or	a0,a0,a4
    80001b6c:	9782                	jalr	a5
}
    80001b6e:	70a2                	ld	ra,40(sp)
    80001b70:	7402                	ld	s0,32(sp)
    80001b72:	64e2                	ld	s1,24(sp)
    80001b74:	6145                	addi	sp,sp,48
    80001b76:	8082                	ret
      panic("exec");
    80001b78:	00006517          	auipc	a0,0x6
    80001b7c:	62050513          	addi	a0,a0,1568 # 80008198 <etext+0x198>
    80001b80:	ca5fe0ef          	jal	80000824 <panic>

0000000080001b84 <allocpid>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b8e:	00012517          	auipc	a0,0x12
    80001b92:	f8a50513          	addi	a0,a0,-118 # 80013b18 <pid_lock>
    80001b96:	892ff0ef          	jal	80000c28 <acquire>
  pid = nextpid;
    80001b9a:	0000a797          	auipc	a5,0xa
    80001b9e:	c9278793          	addi	a5,a5,-878 # 8000b82c <nextpid>
    80001ba2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ba4:	0014871b          	addiw	a4,s1,1
    80001ba8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001baa:	00012517          	auipc	a0,0x12
    80001bae:	f6e50513          	addi	a0,a0,-146 # 80013b18 <pid_lock>
    80001bb2:	90aff0ef          	jal	80000cbc <release>
}
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	60e2                	ld	ra,24(sp)
    80001bba:	6442                	ld	s0,16(sp)
    80001bbc:	64a2                	ld	s1,8(sp)
    80001bbe:	6105                	addi	sp,sp,32
    80001bc0:	8082                	ret

0000000080001bc2 <proc_pagetable>:
{
    80001bc2:	1101                	addi	sp,sp,-32
    80001bc4:	ec06                	sd	ra,24(sp)
    80001bc6:	e822                	sd	s0,16(sp)
    80001bc8:	e426                	sd	s1,8(sp)
    80001bca:	e04a                	sd	s2,0(sp)
    80001bcc:	1000                	addi	s0,sp,32
    80001bce:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bd0:	e38ff0ef          	jal	80001208 <uvmcreate>
    80001bd4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bd6:	cd05                	beqz	a0,80001c0e <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bd8:	4729                	li	a4,10
    80001bda:	00005697          	auipc	a3,0x5
    80001bde:	42668693          	addi	a3,a3,1062 # 80007000 <_trampoline>
    80001be2:	6605                	lui	a2,0x1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	c74ff0ef          	jal	80001060 <mappages>
    80001bf0:	02054663          	bltz	a0,80001c1c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bf4:	4719                	li	a4,6
    80001bf6:	06093683          	ld	a3,96(s2)
    80001bfa:	6605                	lui	a2,0x1
    80001bfc:	020005b7          	lui	a1,0x2000
    80001c00:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c02:	05b6                	slli	a1,a1,0xd
    80001c04:	8526                	mv	a0,s1
    80001c06:	c5aff0ef          	jal	80001060 <mappages>
    80001c0a:	00054f63          	bltz	a0,80001c28 <proc_pagetable+0x66>
}
    80001c0e:	8526                	mv	a0,s1
    80001c10:	60e2                	ld	ra,24(sp)
    80001c12:	6442                	ld	s0,16(sp)
    80001c14:	64a2                	ld	s1,8(sp)
    80001c16:	6902                	ld	s2,0(sp)
    80001c18:	6105                	addi	sp,sp,32
    80001c1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001c1c:	4581                	li	a1,0
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fe2ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c24:	4481                	li	s1,0
    80001c26:	b7e5                	j	80001c0e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c28:	4681                	li	a3,0
    80001c2a:	4605                	li	a2,1
    80001c2c:	040005b7          	lui	a1,0x4000
    80001c30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c32:	05b2                	slli	a1,a1,0xc
    80001c34:	8526                	mv	a0,s1
    80001c36:	df8ff0ef          	jal	8000122e <uvmunmap>
    uvmfree(pagetable, 0);
    80001c3a:	4581                	li	a1,0
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fc4ff0ef          	jal	80001402 <uvmfree>
    return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	b7e9                	j	80001c0e <proc_pagetable+0x4c>

0000000080001c46 <proc_freepagetable>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
    80001c52:	84aa                	mv	s1,a0
    80001c54:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c56:	4681                	li	a3,0
    80001c58:	4605                	li	a2,1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	dccff0ef          	jal	8000122e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c66:	4681                	li	a3,0
    80001c68:	4605                	li	a2,1
    80001c6a:	020005b7          	lui	a1,0x2000
    80001c6e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c70:	05b6                	slli	a1,a1,0xd
    80001c72:	8526                	mv	a0,s1
    80001c74:	dbaff0ef          	jal	8000122e <uvmunmap>
  uvmfree(pagetable, sz);
    80001c78:	85ca                	mv	a1,s2
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	f86ff0ef          	jal	80001402 <uvmfree>
}
    80001c80:	60e2                	ld	ra,24(sp)
    80001c82:	6442                	ld	s0,16(sp)
    80001c84:	64a2                	ld	s1,8(sp)
    80001c86:	6902                	ld	s2,0(sp)
    80001c88:	6105                	addi	sp,sp,32
    80001c8a:	8082                	ret

0000000080001c8c <freeproc>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c98:	7128                	ld	a0,96(a0)
    80001c9a:	c119                	beqz	a0,80001ca0 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001c9c:	dc1fe0ef          	jal	80000a5c <kfree>
  p->trapframe = 0;
    80001ca0:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001ca4:	6ca8                	ld	a0,88(s1)
    80001ca6:	c501                	beqz	a0,80001cae <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001ca8:	68ac                	ld	a1,80(s1)
    80001caa:	f9dff0ef          	jal	80001c46 <proc_freepagetable>
  p->pagetable = 0;
    80001cae:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001cb2:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001cb6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001cba:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001cbe:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001cc2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cc6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cca:	0204a623          	sw	zero,44(s1)
  p->heat = 0;
    80001cce:	0204ac23          	sw	zero,56(s1)
  p->state = UNUSED;
    80001cd2:	0004ac23          	sw	zero,24(s1)
}
    80001cd6:	60e2                	ld	ra,24(sp)
    80001cd8:	6442                	ld	s0,16(sp)
    80001cda:	64a2                	ld	s1,8(sp)
    80001cdc:	6105                	addi	sp,sp,32
    80001cde:	8082                	ret

0000000080001ce0 <allocproc>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	e04a                	sd	s2,0(sp)
    80001cea:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cec:	00012497          	auipc	s1,0x12
    80001cf0:	25c48493          	addi	s1,s1,604 # 80013f48 <proc>
    80001cf4:	00018917          	auipc	s2,0x18
    80001cf8:	e5490913          	addi	s2,s2,-428 # 80019b48 <tickslock>
    acquire(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	f2bfe0ef          	jal	80000c28 <acquire>
    if(p->state == UNUSED) {
    80001d02:	4c9c                	lw	a5,24(s1)
    80001d04:	cb91                	beqz	a5,80001d18 <allocproc+0x38>
      release(&p->lock);
    80001d06:	8526                	mv	a0,s1
    80001d08:	fb5fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d0c:	17048493          	addi	s1,s1,368
    80001d10:	ff2496e3          	bne	s1,s2,80001cfc <allocproc+0x1c>
  return 0;
    80001d14:	4481                	li	s1,0
    80001d16:	a0a9                	j	80001d60 <allocproc+0x80>
  p->pid = allocpid();
    80001d18:	e6dff0ef          	jal	80001b84 <allocpid>
    80001d1c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d1e:	4785                	li	a5,1
    80001d20:	cc9c                	sw	a5,24(s1)
  p->waiting_tick = 0;
    80001d22:	0204aa23          	sw	zero,52(s1)
  p->heat = 0;              // new process starts cool
    80001d26:	0204ac23          	sw	zero,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d2a:	e1bfe0ef          	jal	80000b44 <kalloc>
    80001d2e:	892a                	mv	s2,a0
    80001d30:	f0a8                	sd	a0,96(s1)
    80001d32:	cd15                	beqz	a0,80001d6e <allocproc+0x8e>
  p->pagetable = proc_pagetable(p);
    80001d34:	8526                	mv	a0,s1
    80001d36:	e8dff0ef          	jal	80001bc2 <proc_pagetable>
    80001d3a:	892a                	mv	s2,a0
    80001d3c:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001d3e:	c121                	beqz	a0,80001d7e <allocproc+0x9e>
  memset(&p->context, 0, sizeof(p->context));
    80001d40:	07000613          	li	a2,112
    80001d44:	4581                	li	a1,0
    80001d46:	06848513          	addi	a0,s1,104
    80001d4a:	faffe0ef          	jal	80000cf8 <memset>
  p->context.ra = (uint64)forkret;
    80001d4e:	00000797          	auipc	a5,0x0
    80001d52:	d9c78793          	addi	a5,a5,-612 # 80001aea <forkret>
    80001d56:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d58:	64bc                	ld	a5,72(s1)
    80001d5a:	6705                	lui	a4,0x1
    80001d5c:	97ba                	add	a5,a5,a4
    80001d5e:	f8bc                	sd	a5,112(s1)
}
    80001d60:	8526                	mv	a0,s1
    80001d62:	60e2                	ld	ra,24(sp)
    80001d64:	6442                	ld	s0,16(sp)
    80001d66:	64a2                	ld	s1,8(sp)
    80001d68:	6902                	ld	s2,0(sp)
    80001d6a:	6105                	addi	sp,sp,32
    80001d6c:	8082                	ret
    freeproc(p);
    80001d6e:	8526                	mv	a0,s1
    80001d70:	f1dff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	f47fe0ef          	jal	80000cbc <release>
    return 0;
    80001d7a:	84ca                	mv	s1,s2
    80001d7c:	b7d5                	j	80001d60 <allocproc+0x80>
    freeproc(p);
    80001d7e:	8526                	mv	a0,s1
    80001d80:	f0dff0ef          	jal	80001c8c <freeproc>
    release(&p->lock);
    80001d84:	8526                	mv	a0,s1
    80001d86:	f37fe0ef          	jal	80000cbc <release>
    return 0;
    80001d8a:	84ca                	mv	s1,s2
    80001d8c:	bfd1                	j	80001d60 <allocproc+0x80>

0000000080001d8e <userinit>:
{
    80001d8e:	1101                	addi	sp,sp,-32
    80001d90:	ec06                	sd	ra,24(sp)
    80001d92:	e822                	sd	s0,16(sp)
    80001d94:	e426                	sd	s1,8(sp)
    80001d96:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d98:	f49ff0ef          	jal	80001ce0 <allocproc>
    80001d9c:	84aa                	mv	s1,a0
  initproc = p;
    80001d9e:	0000a797          	auipc	a5,0xa
    80001da2:	aea7b523          	sd	a0,-1302(a5) # 8000b888 <initproc>
  p->cwd = namei("/");
    80001da6:	00006517          	auipc	a0,0x6
    80001daa:	3fa50513          	addi	a0,a0,1018 # 800081a0 <etext+0x1a0>
    80001dae:	6b0020ef          	jal	8000445e <namei>
    80001db2:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001db6:	478d                	li	a5,3
    80001db8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	f01fe0ef          	jal	80000cbc <release>
}
    80001dc0:	60e2                	ld	ra,24(sp)
    80001dc2:	6442                	ld	s0,16(sp)
    80001dc4:	64a2                	ld	s1,8(sp)
    80001dc6:	6105                	addi	sp,sp,32
    80001dc8:	8082                	ret

0000000080001dca <growproc>:
{
    80001dca:	1101                	addi	sp,sp,-32
    80001dcc:	ec06                	sd	ra,24(sp)
    80001dce:	e822                	sd	s0,16(sp)
    80001dd0:	e426                	sd	s1,8(sp)
    80001dd2:	e04a                	sd	s2,0(sp)
    80001dd4:	1000                	addi	s0,sp,32
    80001dd6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dd8:	cdfff0ef          	jal	80001ab6 <myproc>
    80001ddc:	892a                	mv	s2,a0
  sz = p->sz;
    80001dde:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001de0:	02905963          	blez	s1,80001e12 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    80001de4:	00b48633          	add	a2,s1,a1
    80001de8:	020007b7          	lui	a5,0x2000
    80001dec:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001dee:	07b6                	slli	a5,a5,0xd
    80001df0:	02c7ea63          	bltu	a5,a2,80001e24 <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001df4:	4691                	li	a3,4
    80001df6:	6d28                	ld	a0,88(a0)
    80001df8:	d04ff0ef          	jal	800012fc <uvmalloc>
    80001dfc:	85aa                	mv	a1,a0
    80001dfe:	c50d                	beqz	a0,80001e28 <growproc+0x5e>
  p->sz = sz;
    80001e00:	04b93823          	sd	a1,80(s2)
  return 0;
    80001e04:	4501                	li	a0,0
}
    80001e06:	60e2                	ld	ra,24(sp)
    80001e08:	6442                	ld	s0,16(sp)
    80001e0a:	64a2                	ld	s1,8(sp)
    80001e0c:	6902                	ld	s2,0(sp)
    80001e0e:	6105                	addi	sp,sp,32
    80001e10:	8082                	ret
  } else if(n < 0){
    80001e12:	fe04d7e3          	bgez	s1,80001e00 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e16:	00b48633          	add	a2,s1,a1
    80001e1a:	6d28                	ld	a0,88(a0)
    80001e1c:	c9cff0ef          	jal	800012b8 <uvmdealloc>
    80001e20:	85aa                	mv	a1,a0
    80001e22:	bff9                	j	80001e00 <growproc+0x36>
      return -1;
    80001e24:	557d                	li	a0,-1
    80001e26:	b7c5                	j	80001e06 <growproc+0x3c>
      return -1;
    80001e28:	557d                	li	a0,-1
    80001e2a:	bff1                	j	80001e06 <growproc+0x3c>

0000000080001e2c <kfork>:
{
    80001e2c:	7139                	addi	sp,sp,-64
    80001e2e:	fc06                	sd	ra,56(sp)
    80001e30:	f822                	sd	s0,48(sp)
    80001e32:	f426                	sd	s1,40(sp)
    80001e34:	e456                	sd	s5,8(sp)
    80001e36:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e38:	c7fff0ef          	jal	80001ab6 <myproc>
    80001e3c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e3e:	ea3ff0ef          	jal	80001ce0 <allocproc>
    80001e42:	0e050a63          	beqz	a0,80001f36 <kfork+0x10a>
    80001e46:	e852                	sd	s4,16(sp)
    80001e48:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e4a:	050ab603          	ld	a2,80(s5)
    80001e4e:	6d2c                	ld	a1,88(a0)
    80001e50:	058ab503          	ld	a0,88(s5)
    80001e54:	de0ff0ef          	jal	80001434 <uvmcopy>
    80001e58:	04054863          	bltz	a0,80001ea8 <kfork+0x7c>
    80001e5c:	f04a                	sd	s2,32(sp)
    80001e5e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e60:	050ab783          	ld	a5,80(s5)
    80001e64:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e68:	060ab683          	ld	a3,96(s5)
    80001e6c:	87b6                	mv	a5,a3
    80001e6e:	060a3703          	ld	a4,96(s4)
    80001e72:	12068693          	addi	a3,a3,288
    80001e76:	6388                	ld	a0,0(a5)
    80001e78:	678c                	ld	a1,8(a5)
    80001e7a:	6b90                	ld	a2,16(a5)
    80001e7c:	e308                	sd	a0,0(a4)
    80001e7e:	e70c                	sd	a1,8(a4)
    80001e80:	eb10                	sd	a2,16(a4)
    80001e82:	6f90                	ld	a2,24(a5)
    80001e84:	ef10                	sd	a2,24(a4)
    80001e86:	02078793          	addi	a5,a5,32
    80001e8a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001e8e:	fed794e3          	bne	a5,a3,80001e76 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001e92:	060a3783          	ld	a5,96(s4)
    80001e96:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e9a:	0d8a8493          	addi	s1,s5,216
    80001e9e:	0d8a0913          	addi	s2,s4,216
    80001ea2:	158a8993          	addi	s3,s5,344
    80001ea6:	a831                	j	80001ec2 <kfork+0x96>
    freeproc(np);
    80001ea8:	8552                	mv	a0,s4
    80001eaa:	de3ff0ef          	jal	80001c8c <freeproc>
    release(&np->lock);
    80001eae:	8552                	mv	a0,s4
    80001eb0:	e0dfe0ef          	jal	80000cbc <release>
    return -1;
    80001eb4:	54fd                	li	s1,-1
    80001eb6:	6a42                	ld	s4,16(sp)
    80001eb8:	a885                	j	80001f28 <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001eba:	04a1                	addi	s1,s1,8
    80001ebc:	0921                	addi	s2,s2,8
    80001ebe:	01348963          	beq	s1,s3,80001ed0 <kfork+0xa4>
    if(p->ofile[i])
    80001ec2:	6088                	ld	a0,0(s1)
    80001ec4:	d97d                	beqz	a0,80001eba <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ec6:	355020ef          	jal	80004a1a <filedup>
    80001eca:	00a93023          	sd	a0,0(s2)
    80001ece:	b7f5                	j	80001eba <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001ed0:	158ab503          	ld	a0,344(s5)
    80001ed4:	527010ef          	jal	80003bfa <idup>
    80001ed8:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001edc:	4641                	li	a2,16
    80001ede:	160a8593          	addi	a1,s5,352
    80001ee2:	160a0513          	addi	a0,s4,352
    80001ee6:	f67fe0ef          	jal	80000e4c <safestrcpy>
  pid = np->pid;
    80001eea:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	dcdfe0ef          	jal	80000cbc <release>
  acquire(&wait_lock);
    80001ef4:	00012517          	auipc	a0,0x12
    80001ef8:	c3c50513          	addi	a0,a0,-964 # 80013b30 <wait_lock>
    80001efc:	d2dfe0ef          	jal	80000c28 <acquire>
  np->parent = p;
    80001f00:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001f04:	00012517          	auipc	a0,0x12
    80001f08:	c2c50513          	addi	a0,a0,-980 # 80013b30 <wait_lock>
    80001f0c:	db1fe0ef          	jal	80000cbc <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	d17fe0ef          	jal	80000c28 <acquire>
  np->state = RUNNABLE;
    80001f16:	478d                	li	a5,3
    80001f18:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f1c:	8552                	mv	a0,s4
    80001f1e:	d9ffe0ef          	jal	80000cbc <release>
  return pid;
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	69e2                	ld	s3,24(sp)
    80001f26:	6a42                	ld	s4,16(sp)
}
    80001f28:	8526                	mv	a0,s1
    80001f2a:	70e2                	ld	ra,56(sp)
    80001f2c:	7442                	ld	s0,48(sp)
    80001f2e:	74a2                	ld	s1,40(sp)
    80001f30:	6aa2                	ld	s5,8(sp)
    80001f32:	6121                	addi	sp,sp,64
    80001f34:	8082                	ret
    return -1;
    80001f36:	54fd                	li	s1,-1
    80001f38:	bfc5                	j	80001f28 <kfork+0xfc>

0000000080001f3a <scheduler>:
{
    80001f3a:	7119                	addi	sp,sp,-128
    80001f3c:	fc86                	sd	ra,120(sp)
    80001f3e:	f8a2                	sd	s0,112(sp)
    80001f40:	f4a6                	sd	s1,104(sp)
    80001f42:	f0ca                	sd	s2,96(sp)
    80001f44:	ecce                	sd	s3,88(sp)
    80001f46:	e8d2                	sd	s4,80(sp)
    80001f48:	e4d6                	sd	s5,72(sp)
    80001f4a:	e0da                	sd	s6,64(sp)
    80001f4c:	fc5e                	sd	s7,56(sp)
    80001f4e:	f862                	sd	s8,48(sp)
    80001f50:	f466                	sd	s9,40(sp)
    80001f52:	f06a                	sd	s10,32(sp)
    80001f54:	ec6e                	sd	s11,24(sp)
    80001f56:	0100                	addi	s0,sp,128
    80001f58:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5c:	00779693          	slli	a3,a5,0x7
    80001f60:	00012717          	auipc	a4,0x12
    80001f64:	a3870713          	addi	a4,a4,-1480 # 80013998 <tm>
    80001f68:	9736                	add	a4,a4,a3
    80001f6a:	1a073823          	sd	zero,432(a4)
        swtch(&c->context, &chosen->context);
    80001f6e:	00012717          	auipc	a4,0x12
    80001f72:	be270713          	addi	a4,a4,-1054 # 80013b50 <cpus+0x8>
    80001f76:	9736                	add	a4,a4,a3
    80001f78:	f8e43023          	sd	a4,-128(s0)
      for(p = proc; p < &proc[NPROC]; p++){
    80001f7c:	00018917          	auipc	s2,0x18
    80001f80:	bcc90913          	addi	s2,s2,-1076 # 80019b48 <tickslock>
        c->proc = chosen;
    80001f84:	00012717          	auipc	a4,0x12
    80001f88:	a1470713          	addi	a4,a4,-1516 # 80013998 <tm>
    80001f8c:	00d707b3          	add	a5,a4,a3
    80001f90:	f8f43423          	sd	a5,-120(s0)
    80001f94:	acfd                	j	80002292 <scheduler+0x358>
      for(p = proc; p < &proc[NPROC]; p++){
    80001f96:	00012497          	auipc	s1,0x12
    80001f9a:	fb248493          	addi	s1,s1,-78 # 80013f48 <proc>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001f9e:	4a25                	li	s4,9
    80001fa0:	00006997          	auipc	s3,0x6
    80001fa4:	22098993          	addi	s3,s3,544 # 800081c0 <etext+0x1c0>
    80001fa8:	a801                	j	80001fb8 <scheduler+0x7e>
        release(&p->lock);
    80001faa:	8526                	mv	a0,s1
    80001fac:	d11fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80001fb0:	17048493          	addi	s1,s1,368
    80001fb4:	03248663          	beq	s1,s2,80001fe0 <scheduler+0xa6>
        acquire(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	c6ffe0ef          	jal	80000c28 <acquire>
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80001fbe:	4c9c                	lw	a5,24(s1)
    80001fc0:	d7ed                	beqz	a5,80001faa <scheduler+0x70>
    80001fc2:	17ed                	addi	a5,a5,-5
    80001fc4:	d3fd                	beqz	a5,80001faa <scheduler+0x70>
           p->parent != 0 &&
    80001fc6:	60a8                	ld	a0,64(s1)
        if(p->state != UNUSED && p->state != ZOMBIE &&
    80001fc8:	d16d                	beqz	a0,80001faa <scheduler+0x70>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    80001fca:	8652                	mv	a2,s4
    80001fcc:	85ce                	mv	a1,s3
    80001fce:	16050513          	addi	a0,a0,352
    80001fd2:	dfbfe0ef          	jal	80000dcc <strncmp>
           p->parent != 0 &&
    80001fd6:	f971                	bnez	a0,80001faa <scheduler+0x70>
          release(&p->lock);
    80001fd8:	8526                	mv	a0,s1
    80001fda:	ce3fe0ef          	jal	80000cbc <release>
      if(!still_active){
    80001fde:	a4d5                	j	800022c2 <scheduler+0x388>
  printf("\n");
    80001fe0:	00006517          	auipc	a0,0x6
    80001fe4:	09850513          	addi	a0,a0,152 # 80008078 <etext+0x78>
    80001fe8:	d12fe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    80001fec:	00006517          	auipc	a0,0x6
    80001ff0:	1e450513          	addi	a0,a0,484 # 800081d0 <etext+0x1d0>
    80001ff4:	d06fe0ef          	jal	800004fa <printf>
  printf("  ===          THERMAL SCHEDULING SUMMARY                  ===\n");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	21850513          	addi	a0,a0,536 # 80008210 <etext+0x210>
    80002000:	cfafe0ef          	jal	800004fa <printf>
  printf("  ============================================================\n");
    80002004:	00006517          	auipc	a0,0x6
    80002008:	1cc50513          	addi	a0,a0,460 # 800081d0 <etext+0x1d0>
    8000200c:	ceefe0ef          	jal	800004fa <printf>
  printf("\n");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	06850513          	addi	a0,a0,104 # 80008078 <etext+0x78>
    80002018:	ce2fe0ef          	jal	800004fa <printf>
  int avg_temp = tm_temp_count > 0 ? tm_temp_sum / tm_temp_count : 0;
    8000201c:	0000a797          	auipc	a5,0xa
    80002020:	8647a783          	lw	a5,-1948(a5) # 8000b880 <tm_temp_count>
    80002024:	4481                	li	s1,0
    80002026:	00f05863          	blez	a5,80002036 <scheduler+0xfc>
    8000202a:	0000a497          	auipc	s1,0xa
    8000202e:	85a4a483          	lw	s1,-1958(s1) # 8000b884 <tm_temp_sum>
    80002032:	02f4c4bb          	divw	s1,s1,a5
  printf("  CPU Temperature\n");
    80002036:	00006517          	auipc	a0,0x6
    8000203a:	21a50513          	addi	a0,a0,538 # 80008250 <etext+0x250>
    8000203e:	cbcfe0ef          	jal	800004fa <printf>
  printf("  -----------------------------------------------------------\n");
    80002042:	00006517          	auipc	a0,0x6
    80002046:	22650513          	addi	a0,a0,550 # 80008268 <etext+0x268>
    8000204a:	cb0fe0ef          	jal	800004fa <printf>
  printf("    Average : %d    Min : %d    Max : %d\n", avg_temp, tm_temp_min, tm_temp_max);
    8000204e:	0000a697          	auipc	a3,0xa
    80002052:	82e6a683          	lw	a3,-2002(a3) # 8000b87c <tm_temp_max>
    80002056:	00009617          	auipc	a2,0x9
    8000205a:	7ce62603          	lw	a2,1998(a2) # 8000b824 <tm_temp_min>
    8000205e:	85a6                	mv	a1,s1
    80002060:	00006517          	auipc	a0,0x6
    80002064:	24850513          	addi	a0,a0,584 # 800082a8 <etext+0x2a8>
    80002068:	c92fe0ef          	jal	800004fa <printf>
  printf("    Cooling cycles (throttled) : %d\n", tm_cooling_cycles);
    8000206c:	0000a597          	auipc	a1,0xa
    80002070:	80c5a583          	lw	a1,-2036(a1) # 8000b878 <tm_cooling_cycles>
    80002074:	00006517          	auipc	a0,0x6
    80002078:	26450513          	addi	a0,a0,612 # 800082d8 <etext+0x2d8>
    8000207c:	c7efe0ef          	jal	800004fa <printf>
  printf("    Total schedule events      : %d\n", tm_temp_count);
    80002080:	0000a597          	auipc	a1,0xa
    80002084:	8005a583          	lw	a1,-2048(a1) # 8000b880 <tm_temp_count>
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	27850513          	addi	a0,a0,632 # 80008300 <etext+0x300>
    80002090:	c6afe0ef          	jal	800004fa <printf>
  printf("\n");
    80002094:	00006517          	auipc	a0,0x6
    80002098:	fe450513          	addi	a0,a0,-28 # 80008078 <etext+0x78>
    8000209c:	c5efe0ef          	jal	800004fa <printf>
  printf("  Per-Process Heat Metrics\n");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	28850513          	addi	a0,a0,648 # 80008328 <etext+0x328>
    800020a8:	c52fe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    800020ac:	00006517          	auipc	a0,0x6
    800020b0:	29c50513          	addi	a0,a0,668 # 80008348 <etext+0x348>
    800020b4:	c46fe0ef          	jal	800004fa <printf>
  printf("  PID  | Scheduled | Skipped | Avg Heat | Min Heat | Max Heat\n");
    800020b8:	00006517          	auipc	a0,0x6
    800020bc:	2d850513          	addi	a0,a0,728 # 80008390 <etext+0x390>
    800020c0:	c3afe0ef          	jal	800004fa <printf>
  printf("  ---------------------------------------------------------------\n");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	28450513          	addi	a0,a0,644 # 80008348 <etext+0x348>
    800020cc:	c2efe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800020d0:	00012497          	auipc	s1,0x12
    800020d4:	8c848493          	addi	s1,s1,-1848 # 80013998 <tm>
    800020d8:	00012c97          	auipc	s9,0x12
    800020dc:	a40c8c93          	addi	s9,s9,-1472 # 80013b18 <pid_lock>
  printf("  ---------------------------------------------------------------\n");
    800020e0:	89a6                	mv	s3,s1
    printf("  ");
    800020e2:	00006d17          	auipc	s10,0x6
    800020e6:	2eed0d13          	addi	s10,s10,750 # 800083d0 <etext+0x3d0>
    printpad(tm[i].pid, 4);
    800020ea:	4d91                	li	s11,4
    printf(" |");
    800020ec:	00006b17          	auipc	s6,0x6
    800020f0:	2f4b0b13          	addi	s6,s6,756 # 800083e0 <etext+0x3e0>
    800020f4:	a041                	j	80002174 <scheduler+0x23a>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    800020f6:	014a2783          	lw	a5,20(s4)
    800020fa:	8abe                	mv	s5,a5
    800020fc:	0a07c163          	bltz	a5,8000219e <scheduler+0x264>
    80002100:	2a81                	sext.w	s5,s5
    printf("  ");
    80002102:	856a                	mv	a0,s10
    80002104:	bf6fe0ef          	jal	800004fa <printf>
    printpad(tm[i].pid, 4);
    80002108:	85ee                	mv	a1,s11
    8000210a:	000a2503          	lw	a0,0(s4)
    8000210e:	f24ff0ef          	jal	80001832 <printpad>
    printf("  |");
    80002112:	00006517          	auipc	a0,0x6
    80002116:	2c650513          	addi	a0,a0,710 # 800083d8 <etext+0x3d8>
    8000211a:	be0fe0ef          	jal	800004fa <printf>
    printpad(tm[i].sched_count, 10);
    8000211e:	45a9                	li	a1,10
    80002120:	004a2503          	lw	a0,4(s4)
    80002124:	f0eff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002128:	855a                	mv	a0,s6
    8000212a:	bd0fe0ef          	jal	800004fa <printf>
    printpad(tm[i].skip_count, 8);
    8000212e:	45a1                	li	a1,8
    80002130:	008a2503          	lw	a0,8(s4)
    80002134:	efeff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002138:	855a                	mv	a0,s6
    8000213a:	bc0fe0ef          	jal	800004fa <printf>
    printpad(avg_heat, 9);
    8000213e:	45a5                	li	a1,9
    80002140:	855e                	mv	a0,s7
    80002142:	ef0ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002146:	855a                	mv	a0,s6
    80002148:	bb2fe0ef          	jal	800004fa <printf>
    printpad(mn, 9);
    8000214c:	45a5                	li	a1,9
    8000214e:	8562                	mv	a0,s8
    80002150:	ee2ff0ef          	jal	80001832 <printpad>
    printf(" |");
    80002154:	855a                	mv	a0,s6
    80002156:	ba4fe0ef          	jal	800004fa <printf>
    printpad(mx, 9);
    8000215a:	45a5                	li	a1,9
    8000215c:	8556                	mv	a0,s5
    8000215e:	ed4ff0ef          	jal	80001832 <printpad>
    printf("\n");
    80002162:	00006517          	auipc	a0,0x6
    80002166:	f1650513          	addi	a0,a0,-234 # 80008078 <etext+0x78>
    8000216a:	b90fe0ef          	jal	800004fa <printf>
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    8000216e:	09e1                	addi	s3,s3,24
    80002170:	03998963          	beq	s3,s9,800021a2 <scheduler+0x268>
    if(tm[i].pid == 0) continue;
    80002174:	8a4e                	mv	s4,s3
    80002176:	0009a783          	lw	a5,0(s3)
    8000217a:	dbf5                	beqz	a5,8000216e <scheduler+0x234>
    int avg_heat = tm[i].sched_count > 0
    8000217c:	0049a783          	lw	a5,4(s3)
    80002180:	4b81                	li	s7,0
                   ? tm[i].heat_sum / tm[i].sched_count : 0;
    80002182:	00f05663          	blez	a5,8000218e <scheduler+0x254>
    int avg_heat = tm[i].sched_count > 0
    80002186:	00c9ab83          	lw	s7,12(s3)
    8000218a:	02fbcbbb          	divw	s7,s7,a5
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    8000218e:	010a2c03          	lw	s8,16(s4)
    80002192:	06400793          	li	a5,100
    80002196:	f787d0e3          	bge	a5,s8,800020f6 <scheduler+0x1bc>
    8000219a:	4c01                	li	s8,0
    8000219c:	bfa9                	j	800020f6 <scheduler+0x1bc>
    int mx = tm[i].heat_max >= 0        ? tm[i].heat_max : 0;
    8000219e:	4a81                	li	s5,0
    800021a0:	b785                	j	80002100 <scheduler+0x1c6>
  printf("  ---------------------------------------------------------------\n");
    800021a2:	00006517          	auipc	a0,0x6
    800021a6:	1a650513          	addi	a0,a0,422 # 80008348 <etext+0x348>
    800021aa:	b50fe0ef          	jal	800004fa <printf>
  printf("\n");
    800021ae:	00006517          	auipc	a0,0x6
    800021b2:	eca50513          	addi	a0,a0,-310 # 80008078 <etext+0x78>
    800021b6:	b44fe0ef          	jal	800004fa <printf>
    tm[i].heat_min = MAX_HEAT + 1;
    800021ba:	06500713          	li	a4,101
    tm[i].heat_max = -1;
    800021be:	57fd                	li	a5,-1
    tm[i].pid = 0;
    800021c0:	0004a023          	sw	zero,0(s1)
    tm[i].sched_count = 0;
    800021c4:	0004a223          	sw	zero,4(s1)
    tm[i].skip_count = 0;
    800021c8:	0004a423          	sw	zero,8(s1)
    tm[i].heat_sum = 0;
    800021cc:	0004a623          	sw	zero,12(s1)
    tm[i].heat_min = MAX_HEAT + 1;
    800021d0:	c898                	sw	a4,16(s1)
    tm[i].heat_max = -1;
    800021d2:	c8dc                	sw	a5,20(s1)
  for(int i = 0; i < MAX_TRACKED_PIDS; i++){
    800021d4:	04e1                	addi	s1,s1,24
    800021d6:	ff9495e3          	bne	s1,s9,800021c0 <scheduler+0x286>
  tm_temp_sum = 0;
    800021da:	00009797          	auipc	a5,0x9
    800021de:	6a07a523          	sw	zero,1706(a5) # 8000b884 <tm_temp_sum>
  tm_temp_count = 0;
    800021e2:	00009797          	auipc	a5,0x9
    800021e6:	6807af23          	sw	zero,1694(a5) # 8000b880 <tm_temp_count>
  tm_temp_min = 100;
    800021ea:	06400713          	li	a4,100
    800021ee:	00009797          	auipc	a5,0x9
    800021f2:	62e7ab23          	sw	a4,1590(a5) # 8000b824 <tm_temp_min>
  tm_temp_max = 0;
    800021f6:	00009797          	auipc	a5,0x9
    800021fa:	6807a323          	sw	zero,1670(a5) # 8000b87c <tm_temp_max>
  tm_cooling_cycles = 0;
    800021fe:	00009797          	auipc	a5,0x9
    80002202:	6607ad23          	sw	zero,1658(a5) # 8000b878 <tm_cooling_cycles>
  tm_had_children = 0;
    80002206:	00009797          	auipc	a5,0x9
    8000220a:	6607a723          	sw	zero,1646(a5) # 8000b874 <tm_had_children>
}
    8000220e:	a855                	j	800022c2 <scheduler+0x388>
          if(p->heat < 0) p->heat = 0;
    80002210:	0204ac23          	sw	zero,56(s1)
      release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	aa7fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    8000221a:	17048493          	addi	s1,s1,368
    8000221e:	03248163          	beq	s1,s2,80002240 <scheduler+0x306>
      acquire(&p->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	a05fe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    80002228:	4c9c                	lw	a5,24(s1)
    8000222a:	37f9                	addiw	a5,a5,-2
    8000222c:	fef9e4e3          	bltu	s3,a5,80002214 <scheduler+0x2da>
        if(p->heat > 0){
    80002230:	5c9c                	lw	a5,56(s1)
    80002232:	fef051e3          	blez	a5,80002214 <scheduler+0x2da>
          p->heat -= HEAT_DECAY;
    80002236:	37f9                	addiw	a5,a5,-2
          if(p->heat < 0) p->heat = 0;
    80002238:	fc07cce3          	bltz	a5,80002210 <scheduler+0x2d6>
          p->heat -= HEAT_DECAY;
    8000223c:	dc9c                	sw	a5,56(s1)
    8000223e:	bfd9                	j	80002214 <scheduler+0x2da>
    if(cpu_temp >= THROTTLE_TEMP){
    80002240:	00009597          	auipc	a1,0x9
    80002244:	5e85a583          	lw	a1,1512(a1) # 8000b828 <cpu_temp>
    80002248:	05900793          	li	a5,89
    8000224c:	08b7da63          	bge	a5,a1,800022e0 <scheduler+0x3a6>
      tm_cooling_cycles++;
    80002250:	00009717          	auipc	a4,0x9
    80002254:	62870713          	addi	a4,a4,1576 # 8000b878 <tm_cooling_cycles>
    80002258:	431c                	lw	a5,0(a4)
    8000225a:	2785                	addiw	a5,a5,1
    8000225c:	c31c                	sw	a5,0(a4)
      if(sched_round % THERMAL_LOG_INTERVAL == 0)
    8000225e:	00009717          	auipc	a4,0x9
    80002262:	61272703          	lw	a4,1554(a4) # 8000b870 <sched_round.3>
    80002266:	666667b7          	lui	a5,0x66666
    8000226a:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    8000226e:	02f707b3          	mul	a5,a4,a5
    80002272:	9789                	srai	a5,a5,0x22
    80002274:	41f7569b          	sraiw	a3,a4,0x1f
    80002278:	9f95                	subw	a5,a5,a3
    8000227a:	0027969b          	slliw	a3,a5,0x2
    8000227e:	9fb5                	addw	a5,a5,a3
    80002280:	0017979b          	slliw	a5,a5,0x1
    80002284:	9f1d                	subw	a4,a4,a5
    80002286:	c721                	beqz	a4,800022ce <scheduler+0x394>
      update_cpu_temp(0);  // idle cooling
    80002288:	4501                	li	a0,0
    8000228a:	e20ff0ef          	jal	800018aa <update_cpu_temp>
      asm volatile("wfi");
    8000228e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002292:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002296:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000229a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000229e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800022a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022a4:	10079073          	csrw	sstatus,a5
    sched_round++;
    800022a8:	00009717          	auipc	a4,0x9
    800022ac:	5c870713          	addi	a4,a4,1480 # 8000b870 <sched_round.3>
    800022b0:	431c                	lw	a5,0(a4)
    800022b2:	2785                	addiw	a5,a5,1
    800022b4:	c31c                	sw	a5,0(a4)
    if(tm_had_children){
    800022b6:	00009797          	auipc	a5,0x9
    800022ba:	5be7a783          	lw	a5,1470(a5) # 8000b874 <tm_had_children>
    800022be:	cc079ce3          	bnez	a5,80001f96 <scheduler+0x5c>
    int mn = tm[i].heat_min <= MAX_HEAT ? tm[i].heat_min : 0;
    800022c2:	00012497          	auipc	s1,0x12
    800022c6:	c8648493          	addi	s1,s1,-890 # 80013f48 <proc>
      if(p->state == RUNNABLE || p->state == SLEEPING){
    800022ca:	4985                	li	s3,1
    800022cc:	bf99                	j	80002222 <scheduler+0x2e8>
        printf("  [COOLING] Temp: %d/%d  | Throttling -- idle cycle to cool down\n", cpu_temp, THROTTLE_TEMP);
    800022ce:	05a00613          	li	a2,90
    800022d2:	00006517          	auipc	a0,0x6
    800022d6:	11650513          	addi	a0,a0,278 # 800083e8 <etext+0x3e8>
    800022da:	a20fe0ef          	jal	800004fa <printf>
    800022de:	b76d                	j	80002288 <scheduler+0x34e>
    skipped = 0;
    800022e0:	4c81                	li	s9,0
    chosen = 0;
    800022e2:	4981                	li	s3,0
    for(p = proc; p < &proc[NPROC]; p++){
    800022e4:	00012497          	auipc	s1,0x12
    800022e8:	c6448493          	addi	s1,s1,-924 # 80013f48 <proc>
      if(p->state == RUNNABLE){
    800022ec:	4a0d                	li	s4,3
        if(p->waiting_tick < STARVE_TICKS){
    800022ee:	0c700a93          	li	s5,199
           strncmp(p->parent->name, "schedtest", 9) == 0){
    800022f2:	4c25                	li	s8,9
    800022f4:	00006b97          	auipc	s7,0x6
    800022f8:	eccb8b93          	addi	s7,s7,-308 # 800081c0 <etext+0x1c0>
          tm_had_children = 1;
    800022fc:	00009d97          	auipc	s11,0x9
    80002300:	578d8d93          	addi	s11,s11,1400 # 8000b874 <tm_had_children>
    80002304:	4d05                	li	s10,1
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002306:	00009b17          	auipc	s6,0x9
    8000230a:	522b0b13          	addi	s6,s6,1314 # 8000b828 <cpu_temp>
    8000230e:	a835                	j	8000234a <scheduler+0x410>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002310:	03b00713          	li	a4,59
    80002314:	08f74b63          	blt	a4,a5,800023aa <scheduler+0x470>
        if(p->parent != 0 &&
    80002318:	60a8                	ld	a0,64(s1)
    8000231a:	c10d                	beqz	a0,8000233c <scheduler+0x402>
           strncmp(p->parent->name, "schedtest", 9) == 0){
    8000231c:	8662                	mv	a2,s8
    8000231e:	85de                	mv	a1,s7
    80002320:	16050513          	addi	a0,a0,352
    80002324:	aa9fe0ef          	jal	80000dcc <strncmp>
        if(p->parent != 0 &&
    80002328:	e911                	bnez	a0,8000233c <scheduler+0x402>
          tm_had_children = 1;
    8000232a:	01ada023          	sw	s10,0(s11)
          if(chosen == 0 || p->pid < chosen->pid)
    8000232e:	0a098063          	beqz	s3,800023ce <scheduler+0x494>
    80002332:	5898                	lw	a4,48(s1)
    80002334:	0309a783          	lw	a5,48(s3)
    80002338:	08f74d63          	blt	a4,a5,800023d2 <scheduler+0x498>
      release(&p->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	97ffe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80002342:	17048493          	addi	s1,s1,368
    80002346:	09248863          	beq	s1,s2,800023d6 <scheduler+0x49c>
      acquire(&p->lock);
    8000234a:	8526                	mv	a0,s1
    8000234c:	8ddfe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE){
    80002350:	4c9c                	lw	a5,24(s1)
    80002352:	ff4795e3          	bne	a5,s4,8000233c <scheduler+0x402>
        if(p->waiting_tick < STARVE_TICKS){
    80002356:	58dc                	lw	a5,52(s1)
    80002358:	fcfac0e3          	blt	s5,a5,80002318 <scheduler+0x3de>
          if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    8000235c:	000b2783          	lw	a5,0(s6)
    80002360:	04f00713          	li	a4,79
    80002364:	faf756e3          	bge	a4,a5,80002310 <scheduler+0x3d6>
    80002368:	5c98                	lw	a4,56(s1)
    8000236a:	47f5                	li	a5,29
    8000236c:	fae7d6e3          	bge	a5,a4,80002318 <scheduler+0x3de>
          skipped++;
    80002370:	2c85                	addiw	s9,s9,1
          tm_record_skip(p->pid);
    80002372:	5888                	lw	a0,48(s1)
    80002374:	ca2ff0ef          	jal	80001816 <tm_record_skip>
          if(sched_round % THERMAL_LOG_INTERVAL == 0)
    80002378:	00009717          	auipc	a4,0x9
    8000237c:	4f872703          	lw	a4,1272(a4) # 8000b870 <sched_round.3>
    80002380:	666667b7          	lui	a5,0x66666
    80002384:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    80002388:	02f707b3          	mul	a5,a4,a5
    8000238c:	9789                	srai	a5,a5,0x22
    8000238e:	41f7569b          	sraiw	a3,a4,0x1f
    80002392:	9f95                	subw	a5,a5,a3
    80002394:	0027969b          	slliw	a3,a5,0x2
    80002398:	9fb5                	addw	a5,a5,a3
    8000239a:	0017979b          	slliw	a5,a5,0x1
    8000239e:	9f1d                	subw	a4,a4,a5
    800023a0:	cb19                	beqz	a4,800023b6 <scheduler+0x47c>
          release(&p->lock);
    800023a2:	8526                	mv	a0,s1
    800023a4:	919fe0ef          	jal	80000cbc <release>
          continue;
    800023a8:	bf69                	j	80002342 <scheduler+0x408>
          else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    800023aa:	5c98                	lw	a4,56(s1)
    800023ac:	03b00793          	li	a5,59
    800023b0:	fce7c0e3          	blt	a5,a4,80002370 <scheduler+0x436>
    800023b4:	b795                	j	80002318 <scheduler+0x3de>
            printf("  [SKIPPED] PID: %d | Heat: %d | Waited: %d | Temp: %d\n",
    800023b6:	000b2703          	lw	a4,0(s6)
    800023ba:	58d4                	lw	a3,52(s1)
    800023bc:	5c90                	lw	a2,56(s1)
    800023be:	588c                	lw	a1,48(s1)
    800023c0:	00006517          	auipc	a0,0x6
    800023c4:	07050513          	addi	a0,a0,112 # 80008430 <etext+0x430>
    800023c8:	932fe0ef          	jal	800004fa <printf>
    800023cc:	bfd9                	j	800023a2 <scheduler+0x468>
            chosen = p;
    800023ce:	89a6                	mv	s3,s1
    800023d0:	b7b5                	j	8000233c <scheduler+0x402>
    800023d2:	89a6                	mv	s3,s1
    800023d4:	b7a5                	j	8000233c <scheduler+0x402>
    if(chosen == 0){
    800023d6:	00098763          	beqz	s3,800023e4 <scheduler+0x4aa>
    for(p = proc; p < &proc[NPROC]; p++){
    800023da:	00012497          	auipc	s1,0x12
    800023de:	b6e48493          	addi	s1,s1,-1170 # 80013f48 <proc>
    800023e2:	a0d9                	j	800024a8 <scheduler+0x56e>
      int lowest_heat = MAX_HEAT + 1;
    800023e4:	06500a93          	li	s5,101
      for(p = proc; p < &proc[NPROC]; p++){
    800023e8:	00012497          	auipc	s1,0x12
    800023ec:	b6048493          	addi	s1,s1,-1184 # 80013f48 <proc>
        if(p->state == RUNNABLE){
    800023f0:	4a0d                	li	s4,3
          if(p->waiting_tick < STARVE_TICKS){
    800023f2:	0c700b13          	li	s6,199
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    800023f6:	00009c17          	auipc	s8,0x9
    800023fa:	432c0c13          	addi	s8,s8,1074 # 8000b828 <cpu_temp>
    800023fe:	04f00b93          	li	s7,79
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002402:	03b00d13          	li	s10,59
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002406:	4df5                	li	s11,29
    80002408:	a839                	j	80002426 <scheduler+0x4ec>
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    8000240a:	04fd4663          	blt	s10,a5,80002456 <scheduler+0x51c>
          if(p->heat < lowest_heat){
    8000240e:	5c9c                	lw	a5,56(s1)
    80002410:	0157d463          	bge	a5,s5,80002418 <scheduler+0x4de>
            lowest_heat = p->heat;
    80002414:	8abe                	mv	s5,a5
            chosen = p;
    80002416:	89a6                	mv	s3,s1
        release(&p->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	8a3fe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    8000241e:	17048493          	addi	s1,s1,368
    80002422:	03248e63          	beq	s1,s2,8000245e <scheduler+0x524>
        acquire(&p->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	801fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    8000242c:	4c9c                	lw	a5,24(s1)
    8000242e:	ff4795e3          	bne	a5,s4,80002418 <scheduler+0x4de>
          if(p->waiting_tick < STARVE_TICKS){
    80002432:	58dc                	lw	a5,52(s1)
    80002434:	fcfb4de3          	blt	s6,a5,8000240e <scheduler+0x4d4>
            if(cpu_temp >= HOT_TEMP && p->heat >= HEAT_COOL_THRESH)
    80002438:	000c2783          	lw	a5,0(s8)
    8000243c:	fcfbd7e3          	bge	s7,a5,8000240a <scheduler+0x4d0>
    80002440:	5c9c                	lw	a5,56(s1)
    80002442:	fcfdd6e3          	bge	s11,a5,8000240e <scheduler+0x4d4>
            skipped++;
    80002446:	2c85                	addiw	s9,s9,1
            tm_record_skip(p->pid);
    80002448:	5888                	lw	a0,48(s1)
    8000244a:	bccff0ef          	jal	80001816 <tm_record_skip>
            release(&p->lock);
    8000244e:	8526                	mv	a0,s1
    80002450:	86dfe0ef          	jal	80000cbc <release>
            continue;
    80002454:	b7e9                	j	8000241e <scheduler+0x4e4>
            else if(cpu_temp >= WARM_TEMP && p->heat >= HEAT_WARM_THRESH)
    80002456:	5c9c                	lw	a5,56(s1)
    80002458:	fefd47e3          	blt	s10,a5,80002446 <scheduler+0x50c>
    8000245c:	bf4d                	j	8000240e <scheduler+0x4d4>
    if(chosen == 0){
    8000245e:	f6099ee3          	bnez	s3,800023da <scheduler+0x4a0>
      for(p = proc; p < &proc[NPROC]; p++){
    80002462:	00012497          	auipc	s1,0x12
    80002466:	ae648493          	addi	s1,s1,-1306 # 80013f48 <proc>
        if(p->state == RUNNABLE){
    8000246a:	4a8d                	li	s5,3
      for(p = proc; p < &proc[NPROC]; p++){
    8000246c:	00017a17          	auipc	s4,0x17
    80002470:	6dca0a13          	addi	s4,s4,1756 # 80019b48 <tickslock>
        acquire(&p->lock);
    80002474:	8526                	mv	a0,s1
    80002476:	fb2fe0ef          	jal	80000c28 <acquire>
        if(p->state == RUNNABLE){
    8000247a:	4c9c                	lw	a5,24(s1)
    8000247c:	01578a63          	beq	a5,s5,80002490 <scheduler+0x556>
        release(&p->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	83bfe0ef          	jal	80000cbc <release>
      for(p = proc; p < &proc[NPROC]; p++){
    80002486:	17048493          	addi	s1,s1,368
    8000248a:	ff4495e3          	bne	s1,s4,80002474 <scheduler+0x53a>
    8000248e:	b7b1                	j	800023da <scheduler+0x4a0>
          release(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	82bfe0ef          	jal	80000cbc <release>
          chosen = p;
    80002496:	89a6                	mv	s3,s1
          break;
    80002498:	b789                	j	800023da <scheduler+0x4a0>
      release(&p->lock);
    8000249a:	8526                	mv	a0,s1
    8000249c:	821fe0ef          	jal	80000cbc <release>
    for(p = proc; p < &proc[NPROC]; p++){
    800024a0:	17048493          	addi	s1,s1,368
    800024a4:	01248e63          	beq	s1,s2,800024c0 <scheduler+0x586>
      acquire(&p->lock);
    800024a8:	8526                	mv	a0,s1
    800024aa:	f7efe0ef          	jal	80000c28 <acquire>
      if(p->state == RUNNABLE && p != chosen){
    800024ae:	4c9c                	lw	a5,24(s1)
    800024b0:	17f5                	addi	a5,a5,-3
    800024b2:	f7e5                	bnez	a5,8000249a <scheduler+0x560>
    800024b4:	fe9983e3          	beq	s3,s1,8000249a <scheduler+0x560>
        p->waiting_tick++;
    800024b8:	58dc                	lw	a5,52(s1)
    800024ba:	2785                	addiw	a5,a5,1
    800024bc:	d8dc                	sw	a5,52(s1)
    800024be:	bff1                	j	8000249a <scheduler+0x560>
    if(chosen == 0){
    800024c0:	00098f63          	beqz	s3,800024de <scheduler+0x5a4>
      acquire(&chosen->lock);
    800024c4:	84ce                	mv	s1,s3
    800024c6:	854e                	mv	a0,s3
    800024c8:	f60fe0ef          	jal	80000c28 <acquire>
      if(chosen->state == RUNNABLE){
    800024cc:	0189a703          	lw	a4,24(s3)
    800024d0:	478d                	li	a5,3
    800024d2:	00f70c63          	beq	a4,a5,800024ea <scheduler+0x5b0>
      release(&chosen->lock);
    800024d6:	8526                	mv	a0,s1
    800024d8:	fe4fe0ef          	jal	80000cbc <release>
    800024dc:	bb5d                	j	80002292 <scheduler+0x358>
      update_cpu_temp(0);  // idle cooling
    800024de:	4501                	li	a0,0
    800024e0:	bcaff0ef          	jal	800018aa <update_cpu_temp>
      asm volatile("wfi");
    800024e4:	10500073          	wfi
    800024e8:	b36d                	j	80002292 <scheduler+0x358>
        if(cpu_temp >= HOT_TEMP)       zone = "HOT ";
    800024ea:	00009597          	auipc	a1,0x9
    800024ee:	33e5a583          	lw	a1,830(a1) # 8000b828 <cpu_temp>
    800024f2:	04f00793          	li	a5,79
    800024f6:	00006617          	auipc	a2,0x6
    800024fa:	cb260613          	addi	a2,a2,-846 # 800081a8 <etext+0x1a8>
    800024fe:	00b7ce63          	blt	a5,a1,8000251a <scheduler+0x5e0>
        else if(cpu_temp >= WARM_TEMP) zone = "WARM";
    80002502:	03b00793          	li	a5,59
    80002506:	00006617          	auipc	a2,0x6
    8000250a:	cb260613          	addi	a2,a2,-846 # 800081b8 <etext+0x1b8>
    8000250e:	00b7c663          	blt	a5,a1,8000251a <scheduler+0x5e0>
        char *zone = "COOL";
    80002512:	00006617          	auipc	a2,0x6
    80002516:	c9e60613          	addi	a2,a2,-866 # 800081b0 <etext+0x1b0>
        if(sched_round % THERMAL_LOG_INTERVAL == 0){
    8000251a:	00009717          	auipc	a4,0x9
    8000251e:	35672703          	lw	a4,854(a4) # 8000b870 <sched_round.3>
    80002522:	666667b7          	lui	a5,0x66666
    80002526:	66778793          	addi	a5,a5,1639 # 66666667 <_entry-0x19999999>
    8000252a:	02f707b3          	mul	a5,a4,a5
    8000252e:	9789                	srai	a5,a5,0x22
    80002530:	41f7569b          	sraiw	a3,a4,0x1f
    80002534:	9f95                	subw	a5,a5,a3
    80002536:	0027969b          	slliw	a3,a5,0x2
    8000253a:	9fb5                	addw	a5,a5,a3
    8000253c:	0017979b          	slliw	a5,a5,0x1
    80002540:	9f1d                	subw	a4,a4,a5
    80002542:	c379                	beqz	a4,80002608 <scheduler+0x6ce>
        chosen->state = RUNNING;
    80002544:	4791                	li	a5,4
    80002546:	00f9ac23          	sw	a5,24(s3)
        c->proc = chosen;
    8000254a:	f8843783          	ld	a5,-120(s0)
    8000254e:	1b37b823          	sd	s3,432(a5)
        tm_record_schedule(chosen->pid, chosen->heat);
    80002552:	0389aa03          	lw	s4,56(s3)
  struct thermal_metrics *m = tm_find(pid);
    80002556:	0309a503          	lw	a0,48(s3)
    8000255a:	a46ff0ef          	jal	800017a0 <tm_find>
    8000255e:	87aa                	mv	a5,a0
  if(!m) return;
    80002560:	c925                	beqz	a0,800025d0 <scheduler+0x696>
  m->sched_count++;
    80002562:	4158                	lw	a4,4(a0)
    80002564:	2705                	addiw	a4,a4,1
    80002566:	c158                	sw	a4,4(a0)
  m->heat_sum += heat;
    80002568:	4558                	lw	a4,12(a0)
    8000256a:	0147073b          	addw	a4,a4,s4
    8000256e:	c558                	sw	a4,12(a0)
  if(heat < m->heat_min) m->heat_min = heat;
    80002570:	4918                	lw	a4,16(a0)
    80002572:	00ea5463          	bge	s4,a4,8000257a <scheduler+0x640>
    80002576:	01452823          	sw	s4,16(a0)
  if(heat > m->heat_max) m->heat_max = heat;
    8000257a:	4bd8                	lw	a4,20(a5)
    8000257c:	01475463          	bge	a4,s4,80002584 <scheduler+0x64a>
    80002580:	0147aa23          	sw	s4,20(a5)
  tm_temp_sum += cpu_temp;
    80002584:	00009797          	auipc	a5,0x9
    80002588:	2a47a783          	lw	a5,676(a5) # 8000b828 <cpu_temp>
    8000258c:	00009697          	auipc	a3,0x9
    80002590:	2f868693          	addi	a3,a3,760 # 8000b884 <tm_temp_sum>
    80002594:	4298                	lw	a4,0(a3)
    80002596:	9f3d                	addw	a4,a4,a5
    80002598:	c298                	sw	a4,0(a3)
  tm_temp_count++;
    8000259a:	00009697          	auipc	a3,0x9
    8000259e:	2e668693          	addi	a3,a3,742 # 8000b880 <tm_temp_count>
    800025a2:	4298                	lw	a4,0(a3)
    800025a4:	2705                	addiw	a4,a4,1
    800025a6:	c298                	sw	a4,0(a3)
  if(cpu_temp < tm_temp_min) tm_temp_min = cpu_temp;
    800025a8:	00009717          	auipc	a4,0x9
    800025ac:	27c72703          	lw	a4,636(a4) # 8000b824 <tm_temp_min>
    800025b0:	00e7d663          	bge	a5,a4,800025bc <scheduler+0x682>
    800025b4:	00009717          	auipc	a4,0x9
    800025b8:	26f72823          	sw	a5,624(a4) # 8000b824 <tm_temp_min>
  if(cpu_temp > tm_temp_max) tm_temp_max = cpu_temp;
    800025bc:	00009717          	auipc	a4,0x9
    800025c0:	2c072703          	lw	a4,704(a4) # 8000b87c <tm_temp_max>
    800025c4:	00f75663          	bge	a4,a5,800025d0 <scheduler+0x696>
    800025c8:	00009717          	auipc	a4,0x9
    800025cc:	2af72a23          	sw	a5,692(a4) # 8000b87c <tm_temp_max>
        chosen->waiting_tick = 0;
    800025d0:	0209aa23          	sw	zero,52(s3)
        chosen->heat += HEAT_INCREMENT;
    800025d4:	0389a783          	lw	a5,56(s3)
    800025d8:	27a9                	addiw	a5,a5,10
    800025da:	853e                	mv	a0,a5
        if(chosen->heat > MAX_HEAT)
    800025dc:	06400713          	li	a4,100
    800025e0:	00f75463          	bge	a4,a5,800025e8 <scheduler+0x6ae>
    800025e4:	06400513          	li	a0,100
    800025e8:	02a9ac23          	sw	a0,56(s3)
        update_cpu_temp(chosen->heat);
    800025ec:	2501                	sext.w	a0,a0
    800025ee:	abcff0ef          	jal	800018aa <update_cpu_temp>
        swtch(&c->context, &chosen->context);
    800025f2:	06898593          	addi	a1,s3,104
    800025f6:	f8043503          	ld	a0,-128(s0)
    800025fa:	7a6000ef          	jal	80002da0 <swtch>
        c->proc = 0;
    800025fe:	f8843783          	ld	a5,-120(s0)
    80002602:	1a07b823          	sd	zero,432(a5)
    80002606:	bdc1                	j	800024d6 <scheduler+0x59c>
          printf("  [THERMAL] Temp: %d [%s] | PID: %d | Heat: %d | %s",
    80002608:	16098793          	addi	a5,s3,352
    8000260c:	0389a703          	lw	a4,56(s3)
    80002610:	0309a683          	lw	a3,48(s3)
    80002614:	00006517          	auipc	a0,0x6
    80002618:	e5450513          	addi	a0,a0,-428 # 80008468 <etext+0x468>
    8000261c:	edffd0ef          	jal	800004fa <printf>
          if(skipped > 0)
    80002620:	01904963          	bgtz	s9,80002632 <scheduler+0x6f8>
          printf("\n");
    80002624:	00006517          	auipc	a0,0x6
    80002628:	a5450513          	addi	a0,a0,-1452 # 80008078 <etext+0x78>
    8000262c:	ecffd0ef          	jal	800004fa <printf>
    80002630:	bf11                	j	80002544 <scheduler+0x60a>
            printf(" | %d skipped", skipped);
    80002632:	85e6                	mv	a1,s9
    80002634:	00006517          	auipc	a0,0x6
    80002638:	e6c50513          	addi	a0,a0,-404 # 800084a0 <etext+0x4a0>
    8000263c:	ebffd0ef          	jal	800004fa <printf>
    80002640:	b7d5                	j	80002624 <scheduler+0x6ea>

0000000080002642 <sched>:
{
    80002642:	7179                	addi	sp,sp,-48
    80002644:	f406                	sd	ra,40(sp)
    80002646:	f022                	sd	s0,32(sp)
    80002648:	ec26                	sd	s1,24(sp)
    8000264a:	e84a                	sd	s2,16(sp)
    8000264c:	e44e                	sd	s3,8(sp)
    8000264e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002650:	c66ff0ef          	jal	80001ab6 <myproc>
    80002654:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002656:	d62fe0ef          	jal	80000bb8 <holding>
    8000265a:	c935                	beqz	a0,800026ce <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000265c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000265e:	2781                	sext.w	a5,a5
    80002660:	079e                	slli	a5,a5,0x7
    80002662:	00011717          	auipc	a4,0x11
    80002666:	33670713          	addi	a4,a4,822 # 80013998 <tm>
    8000266a:	97ba                	add	a5,a5,a4
    8000266c:	2287a703          	lw	a4,552(a5)
    80002670:	4785                	li	a5,1
    80002672:	06f71463          	bne	a4,a5,800026da <sched+0x98>
  if(p->state == RUNNING)
    80002676:	4c98                	lw	a4,24(s1)
    80002678:	4791                	li	a5,4
    8000267a:	06f70663          	beq	a4,a5,800026e6 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000267e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002682:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002684:	e7bd                	bnez	a5,800026f2 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002686:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002688:	00011917          	auipc	s2,0x11
    8000268c:	31090913          	addi	s2,s2,784 # 80013998 <tm>
    80002690:	2781                	sext.w	a5,a5
    80002692:	079e                	slli	a5,a5,0x7
    80002694:	97ca                	add	a5,a5,s2
    80002696:	22c7a983          	lw	s3,556(a5)
    8000269a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000269c:	2781                	sext.w	a5,a5
    8000269e:	079e                	slli	a5,a5,0x7
    800026a0:	07a1                	addi	a5,a5,8
    800026a2:	00011597          	auipc	a1,0x11
    800026a6:	4a658593          	addi	a1,a1,1190 # 80013b48 <cpus>
    800026aa:	95be                	add	a1,a1,a5
    800026ac:	06848513          	addi	a0,s1,104
    800026b0:	6f0000ef          	jal	80002da0 <swtch>
    800026b4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800026b6:	2781                	sext.w	a5,a5
    800026b8:	079e                	slli	a5,a5,0x7
    800026ba:	993e                	add	s2,s2,a5
    800026bc:	23392623          	sw	s3,556(s2)
}
    800026c0:	70a2                	ld	ra,40(sp)
    800026c2:	7402                	ld	s0,32(sp)
    800026c4:	64e2                	ld	s1,24(sp)
    800026c6:	6942                	ld	s2,16(sp)
    800026c8:	69a2                	ld	s3,8(sp)
    800026ca:	6145                	addi	sp,sp,48
    800026cc:	8082                	ret
    panic("sched p->lock");
    800026ce:	00006517          	auipc	a0,0x6
    800026d2:	de250513          	addi	a0,a0,-542 # 800084b0 <etext+0x4b0>
    800026d6:	94efe0ef          	jal	80000824 <panic>
    panic("sched locks");
    800026da:	00006517          	auipc	a0,0x6
    800026de:	de650513          	addi	a0,a0,-538 # 800084c0 <etext+0x4c0>
    800026e2:	942fe0ef          	jal	80000824 <panic>
    panic("sched RUNNING");
    800026e6:	00006517          	auipc	a0,0x6
    800026ea:	dea50513          	addi	a0,a0,-534 # 800084d0 <etext+0x4d0>
    800026ee:	936fe0ef          	jal	80000824 <panic>
    panic("sched interruptible");
    800026f2:	00006517          	auipc	a0,0x6
    800026f6:	dee50513          	addi	a0,a0,-530 # 800084e0 <etext+0x4e0>
    800026fa:	92afe0ef          	jal	80000824 <panic>

00000000800026fe <yield>:
{
    800026fe:	1101                	addi	sp,sp,-32
    80002700:	ec06                	sd	ra,24(sp)
    80002702:	e822                	sd	s0,16(sp)
    80002704:	e426                	sd	s1,8(sp)
    80002706:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002708:	baeff0ef          	jal	80001ab6 <myproc>
    8000270c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000270e:	d1afe0ef          	jal	80000c28 <acquire>
  p->state = RUNNABLE;
    80002712:	478d                	li	a5,3
    80002714:	cc9c                	sw	a5,24(s1)
  sched();
    80002716:	f2dff0ef          	jal	80002642 <sched>
  release(&p->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	da0fe0ef          	jal	80000cbc <release>
}
    80002720:	60e2                	ld	ra,24(sp)
    80002722:	6442                	ld	s0,16(sp)
    80002724:	64a2                	ld	s1,8(sp)
    80002726:	6105                	addi	sp,sp,32
    80002728:	8082                	ret

000000008000272a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000272a:	7179                	addi	sp,sp,-48
    8000272c:	f406                	sd	ra,40(sp)
    8000272e:	f022                	sd	s0,32(sp)
    80002730:	ec26                	sd	s1,24(sp)
    80002732:	e84a                	sd	s2,16(sp)
    80002734:	e44e                	sd	s3,8(sp)
    80002736:	1800                	addi	s0,sp,48
    80002738:	89aa                	mv	s3,a0
    8000273a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000273c:	b7aff0ef          	jal	80001ab6 <myproc>
    80002740:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002742:	ce6fe0ef          	jal	80000c28 <acquire>
  release(lk);
    80002746:	854a                	mv	a0,s2
    80002748:	d74fe0ef          	jal	80000cbc <release>

  // Go to sleep.
  p->chan = chan;
    8000274c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002750:	4789                	li	a5,2
    80002752:	cc9c                	sw	a5,24(s1)

  sched();
    80002754:	eefff0ef          	jal	80002642 <sched>

  // Tidy up.
  p->chan = 0;
    80002758:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	d5efe0ef          	jal	80000cbc <release>
  acquire(lk);
    80002762:	854a                	mv	a0,s2
    80002764:	cc4fe0ef          	jal	80000c28 <acquire>
}
    80002768:	70a2                	ld	ra,40(sp)
    8000276a:	7402                	ld	s0,32(sp)
    8000276c:	64e2                	ld	s1,24(sp)
    8000276e:	6942                	ld	s2,16(sp)
    80002770:	69a2                	ld	s3,8(sp)
    80002772:	6145                	addi	sp,sp,48
    80002774:	8082                	ret

0000000080002776 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80002776:	7139                	addi	sp,sp,-64
    80002778:	fc06                	sd	ra,56(sp)
    8000277a:	f822                	sd	s0,48(sp)
    8000277c:	f426                	sd	s1,40(sp)
    8000277e:	f04a                	sd	s2,32(sp)
    80002780:	ec4e                	sd	s3,24(sp)
    80002782:	e852                	sd	s4,16(sp)
    80002784:	e456                	sd	s5,8(sp)
    80002786:	0080                	addi	s0,sp,64
    80002788:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000278a:	00011497          	auipc	s1,0x11
    8000278e:	7be48493          	addi	s1,s1,1982 # 80013f48 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002792:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002794:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002796:	00017917          	auipc	s2,0x17
    8000279a:	3b290913          	addi	s2,s2,946 # 80019b48 <tickslock>
    8000279e:	a801                	j	800027ae <wakeup+0x38>
      }
      release(&p->lock);
    800027a0:	8526                	mv	a0,s1
    800027a2:	d1afe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800027a6:	17048493          	addi	s1,s1,368
    800027aa:	03248263          	beq	s1,s2,800027ce <wakeup+0x58>
    if(p != myproc()){
    800027ae:	b08ff0ef          	jal	80001ab6 <myproc>
    800027b2:	fe950ae3          	beq	a0,s1,800027a6 <wakeup+0x30>
      acquire(&p->lock);
    800027b6:	8526                	mv	a0,s1
    800027b8:	c70fe0ef          	jal	80000c28 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800027bc:	4c9c                	lw	a5,24(s1)
    800027be:	ff3791e3          	bne	a5,s3,800027a0 <wakeup+0x2a>
    800027c2:	709c                	ld	a5,32(s1)
    800027c4:	fd479ee3          	bne	a5,s4,800027a0 <wakeup+0x2a>
        p->state = RUNNABLE;
    800027c8:	0154ac23          	sw	s5,24(s1)
    800027cc:	bfd1                	j	800027a0 <wakeup+0x2a>
    }
  }
}
    800027ce:	70e2                	ld	ra,56(sp)
    800027d0:	7442                	ld	s0,48(sp)
    800027d2:	74a2                	ld	s1,40(sp)
    800027d4:	7902                	ld	s2,32(sp)
    800027d6:	69e2                	ld	s3,24(sp)
    800027d8:	6a42                	ld	s4,16(sp)
    800027da:	6aa2                	ld	s5,8(sp)
    800027dc:	6121                	addi	sp,sp,64
    800027de:	8082                	ret

00000000800027e0 <reparent>:
{
    800027e0:	7179                	addi	sp,sp,-48
    800027e2:	f406                	sd	ra,40(sp)
    800027e4:	f022                	sd	s0,32(sp)
    800027e6:	ec26                	sd	s1,24(sp)
    800027e8:	e84a                	sd	s2,16(sp)
    800027ea:	e44e                	sd	s3,8(sp)
    800027ec:	e052                	sd	s4,0(sp)
    800027ee:	1800                	addi	s0,sp,48
    800027f0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800027f2:	00011497          	auipc	s1,0x11
    800027f6:	75648493          	addi	s1,s1,1878 # 80013f48 <proc>
      pp->parent = initproc;
    800027fa:	00009a17          	auipc	s4,0x9
    800027fe:	08ea0a13          	addi	s4,s4,142 # 8000b888 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002802:	00017997          	auipc	s3,0x17
    80002806:	34698993          	addi	s3,s3,838 # 80019b48 <tickslock>
    8000280a:	a029                	j	80002814 <reparent+0x34>
    8000280c:	17048493          	addi	s1,s1,368
    80002810:	01348b63          	beq	s1,s3,80002826 <reparent+0x46>
    if(pp->parent == p){
    80002814:	60bc                	ld	a5,64(s1)
    80002816:	ff279be3          	bne	a5,s2,8000280c <reparent+0x2c>
      pp->parent = initproc;
    8000281a:	000a3503          	ld	a0,0(s4)
    8000281e:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002820:	f57ff0ef          	jal	80002776 <wakeup>
    80002824:	b7e5                	j	8000280c <reparent+0x2c>
}
    80002826:	70a2                	ld	ra,40(sp)
    80002828:	7402                	ld	s0,32(sp)
    8000282a:	64e2                	ld	s1,24(sp)
    8000282c:	6942                	ld	s2,16(sp)
    8000282e:	69a2                	ld	s3,8(sp)
    80002830:	6a02                	ld	s4,0(sp)
    80002832:	6145                	addi	sp,sp,48
    80002834:	8082                	ret

0000000080002836 <kexit>:
{
    80002836:	7179                	addi	sp,sp,-48
    80002838:	f406                	sd	ra,40(sp)
    8000283a:	f022                	sd	s0,32(sp)
    8000283c:	ec26                	sd	s1,24(sp)
    8000283e:	e84a                	sd	s2,16(sp)
    80002840:	e44e                	sd	s3,8(sp)
    80002842:	e052                	sd	s4,0(sp)
    80002844:	1800                	addi	s0,sp,48
    80002846:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002848:	a6eff0ef          	jal	80001ab6 <myproc>
    8000284c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000284e:	00009797          	auipc	a5,0x9
    80002852:	03a7b783          	ld	a5,58(a5) # 8000b888 <initproc>
    80002856:	0d850493          	addi	s1,a0,216
    8000285a:	15850913          	addi	s2,a0,344
    8000285e:	00a79b63          	bne	a5,a0,80002874 <kexit+0x3e>
    panic("init exiting");
    80002862:	00006517          	auipc	a0,0x6
    80002866:	c9650513          	addi	a0,a0,-874 # 800084f8 <etext+0x4f8>
    8000286a:	fbbfd0ef          	jal	80000824 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    8000286e:	04a1                	addi	s1,s1,8
    80002870:	01248963          	beq	s1,s2,80002882 <kexit+0x4c>
    if(p->ofile[fd]){
    80002874:	6088                	ld	a0,0(s1)
    80002876:	dd65                	beqz	a0,8000286e <kexit+0x38>
      fileclose(f);
    80002878:	1e8020ef          	jal	80004a60 <fileclose>
      p->ofile[fd] = 0;
    8000287c:	0004b023          	sd	zero,0(s1)
    80002880:	b7fd                	j	8000286e <kexit+0x38>
  begin_op();
    80002882:	5bb010ef          	jal	8000463c <begin_op>
  iput(p->cwd);
    80002886:	1589b503          	ld	a0,344(s3)
    8000288a:	528010ef          	jal	80003db2 <iput>
  end_op();
    8000288e:	61f010ef          	jal	800046ac <end_op>
  p->cwd = 0;
    80002892:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002896:	00011517          	auipc	a0,0x11
    8000289a:	29a50513          	addi	a0,a0,666 # 80013b30 <wait_lock>
    8000289e:	b8afe0ef          	jal	80000c28 <acquire>
  reparent(p);
    800028a2:	854e                	mv	a0,s3
    800028a4:	f3dff0ef          	jal	800027e0 <reparent>
  wakeup(p->parent);
    800028a8:	0409b503          	ld	a0,64(s3)
    800028ac:	ecbff0ef          	jal	80002776 <wakeup>
  acquire(&p->lock);
    800028b0:	854e                	mv	a0,s3
    800028b2:	b76fe0ef          	jal	80000c28 <acquire>
  p->xstate = status;
    800028b6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800028ba:	4795                	li	a5,5
    800028bc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800028c0:	00011517          	auipc	a0,0x11
    800028c4:	27050513          	addi	a0,a0,624 # 80013b30 <wait_lock>
    800028c8:	bf4fe0ef          	jal	80000cbc <release>
  sched();
    800028cc:	d77ff0ef          	jal	80002642 <sched>
  panic("zombie exit");
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	c3850513          	addi	a0,a0,-968 # 80008508 <etext+0x508>
    800028d8:	f4dfd0ef          	jal	80000824 <panic>

00000000800028dc <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800028dc:	7179                	addi	sp,sp,-48
    800028de:	f406                	sd	ra,40(sp)
    800028e0:	f022                	sd	s0,32(sp)
    800028e2:	ec26                	sd	s1,24(sp)
    800028e4:	e84a                	sd	s2,16(sp)
    800028e6:	e44e                	sd	s3,8(sp)
    800028e8:	1800                	addi	s0,sp,48
    800028ea:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800028ec:	00011497          	auipc	s1,0x11
    800028f0:	65c48493          	addi	s1,s1,1628 # 80013f48 <proc>
    800028f4:	00017997          	auipc	s3,0x17
    800028f8:	25498993          	addi	s3,s3,596 # 80019b48 <tickslock>
    acquire(&p->lock);
    800028fc:	8526                	mv	a0,s1
    800028fe:	b2afe0ef          	jal	80000c28 <acquire>
    if(p->pid == pid){
    80002902:	589c                	lw	a5,48(s1)
    80002904:	01278b63          	beq	a5,s2,8000291a <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002908:	8526                	mv	a0,s1
    8000290a:	bb2fe0ef          	jal	80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000290e:	17048493          	addi	s1,s1,368
    80002912:	ff3495e3          	bne	s1,s3,800028fc <kkill+0x20>
  }
  return -1;
    80002916:	557d                	li	a0,-1
    80002918:	a819                	j	8000292e <kkill+0x52>
      p->killed = 1;
    8000291a:	4785                	li	a5,1
    8000291c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000291e:	4c98                	lw	a4,24(s1)
    80002920:	4789                	li	a5,2
    80002922:	00f70d63          	beq	a4,a5,8000293c <kkill+0x60>
      release(&p->lock);
    80002926:	8526                	mv	a0,s1
    80002928:	b94fe0ef          	jal	80000cbc <release>
      return 0;
    8000292c:	4501                	li	a0,0
}
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6145                	addi	sp,sp,48
    8000293a:	8082                	ret
        p->state = RUNNABLE;
    8000293c:	478d                	li	a5,3
    8000293e:	cc9c                	sw	a5,24(s1)
    80002940:	b7dd                	j	80002926 <kkill+0x4a>

0000000080002942 <setkilled>:

void
setkilled(struct proc *p)
{
    80002942:	1101                	addi	sp,sp,-32
    80002944:	ec06                	sd	ra,24(sp)
    80002946:	e822                	sd	s0,16(sp)
    80002948:	e426                	sd	s1,8(sp)
    8000294a:	1000                	addi	s0,sp,32
    8000294c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000294e:	adafe0ef          	jal	80000c28 <acquire>
  p->killed = 1;
    80002952:	4785                	li	a5,1
    80002954:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002956:	8526                	mv	a0,s1
    80002958:	b64fe0ef          	jal	80000cbc <release>
}
    8000295c:	60e2                	ld	ra,24(sp)
    8000295e:	6442                	ld	s0,16(sp)
    80002960:	64a2                	ld	s1,8(sp)
    80002962:	6105                	addi	sp,sp,32
    80002964:	8082                	ret

0000000080002966 <killed>:

int
killed(struct proc *p)
{
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	e426                	sd	s1,8(sp)
    8000296e:	e04a                	sd	s2,0(sp)
    80002970:	1000                	addi	s0,sp,32
    80002972:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002974:	ab4fe0ef          	jal	80000c28 <acquire>
  k = p->killed;
    80002978:	549c                	lw	a5,40(s1)
    8000297a:	893e                	mv	s2,a5
  release(&p->lock);
    8000297c:	8526                	mv	a0,s1
    8000297e:	b3efe0ef          	jal	80000cbc <release>
  return k;
}
    80002982:	854a                	mv	a0,s2
    80002984:	60e2                	ld	ra,24(sp)
    80002986:	6442                	ld	s0,16(sp)
    80002988:	64a2                	ld	s1,8(sp)
    8000298a:	6902                	ld	s2,0(sp)
    8000298c:	6105                	addi	sp,sp,32
    8000298e:	8082                	ret

0000000080002990 <kwait>:
{
    80002990:	715d                	addi	sp,sp,-80
    80002992:	e486                	sd	ra,72(sp)
    80002994:	e0a2                	sd	s0,64(sp)
    80002996:	fc26                	sd	s1,56(sp)
    80002998:	f84a                	sd	s2,48(sp)
    8000299a:	f44e                	sd	s3,40(sp)
    8000299c:	f052                	sd	s4,32(sp)
    8000299e:	ec56                	sd	s5,24(sp)
    800029a0:	e85a                	sd	s6,16(sp)
    800029a2:	e45e                	sd	s7,8(sp)
    800029a4:	0880                	addi	s0,sp,80
    800029a6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800029a8:	90eff0ef          	jal	80001ab6 <myproc>
    800029ac:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800029ae:	00011517          	auipc	a0,0x11
    800029b2:	18250513          	addi	a0,a0,386 # 80013b30 <wait_lock>
    800029b6:	a72fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    800029ba:	4a15                	li	s4,5
        havekids = 1;
    800029bc:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800029be:	00017997          	auipc	s3,0x17
    800029c2:	18a98993          	addi	s3,s3,394 # 80019b48 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800029c6:	00011b17          	auipc	s6,0x11
    800029ca:	16ab0b13          	addi	s6,s6,362 # 80013b30 <wait_lock>
    800029ce:	a869                	j	80002a68 <kwait+0xd8>
          pid = pp->pid;
    800029d0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800029d4:	000b8c63          	beqz	s7,800029ec <kwait+0x5c>
    800029d8:	4691                	li	a3,4
    800029da:	02c48613          	addi	a2,s1,44
    800029de:	85de                	mv	a1,s7
    800029e0:	05893503          	ld	a0,88(s2)
    800029e4:	c71fe0ef          	jal	80001654 <copyout>
    800029e8:	02054a63          	bltz	a0,80002a1c <kwait+0x8c>
          freeproc(pp);
    800029ec:	8526                	mv	a0,s1
    800029ee:	a9eff0ef          	jal	80001c8c <freeproc>
          release(&pp->lock);
    800029f2:	8526                	mv	a0,s1
    800029f4:	ac8fe0ef          	jal	80000cbc <release>
          release(&wait_lock);
    800029f8:	00011517          	auipc	a0,0x11
    800029fc:	13850513          	addi	a0,a0,312 # 80013b30 <wait_lock>
    80002a00:	abcfe0ef          	jal	80000cbc <release>
}
    80002a04:	854e                	mv	a0,s3
    80002a06:	60a6                	ld	ra,72(sp)
    80002a08:	6406                	ld	s0,64(sp)
    80002a0a:	74e2                	ld	s1,56(sp)
    80002a0c:	7942                	ld	s2,48(sp)
    80002a0e:	79a2                	ld	s3,40(sp)
    80002a10:	7a02                	ld	s4,32(sp)
    80002a12:	6ae2                	ld	s5,24(sp)
    80002a14:	6b42                	ld	s6,16(sp)
    80002a16:	6ba2                	ld	s7,8(sp)
    80002a18:	6161                	addi	sp,sp,80
    80002a1a:	8082                	ret
            release(&pp->lock);
    80002a1c:	8526                	mv	a0,s1
    80002a1e:	a9efe0ef          	jal	80000cbc <release>
            release(&wait_lock);
    80002a22:	00011517          	auipc	a0,0x11
    80002a26:	10e50513          	addi	a0,a0,270 # 80013b30 <wait_lock>
    80002a2a:	a92fe0ef          	jal	80000cbc <release>
            return -1;
    80002a2e:	59fd                	li	s3,-1
    80002a30:	bfd1                	j	80002a04 <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a32:	17048493          	addi	s1,s1,368
    80002a36:	03348063          	beq	s1,s3,80002a56 <kwait+0xc6>
      if(pp->parent == p){
    80002a3a:	60bc                	ld	a5,64(s1)
    80002a3c:	ff279be3          	bne	a5,s2,80002a32 <kwait+0xa2>
        acquire(&pp->lock);
    80002a40:	8526                	mv	a0,s1
    80002a42:	9e6fe0ef          	jal	80000c28 <acquire>
        if(pp->state == ZOMBIE){
    80002a46:	4c9c                	lw	a5,24(s1)
    80002a48:	f94784e3          	beq	a5,s4,800029d0 <kwait+0x40>
        release(&pp->lock);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	a6efe0ef          	jal	80000cbc <release>
        havekids = 1;
    80002a52:	8756                	mv	a4,s5
    80002a54:	bff9                	j	80002a32 <kwait+0xa2>
    if(!havekids || killed(p)){
    80002a56:	cf19                	beqz	a4,80002a74 <kwait+0xe4>
    80002a58:	854a                	mv	a0,s2
    80002a5a:	f0dff0ef          	jal	80002966 <killed>
    80002a5e:	e919                	bnez	a0,80002a74 <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002a60:	85da                	mv	a1,s6
    80002a62:	854a                	mv	a0,s2
    80002a64:	cc7ff0ef          	jal	8000272a <sleep>
    havekids = 0;
    80002a68:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002a6a:	00011497          	auipc	s1,0x11
    80002a6e:	4de48493          	addi	s1,s1,1246 # 80013f48 <proc>
    80002a72:	b7e1                	j	80002a3a <kwait+0xaa>
      release(&wait_lock);
    80002a74:	00011517          	auipc	a0,0x11
    80002a78:	0bc50513          	addi	a0,a0,188 # 80013b30 <wait_lock>
    80002a7c:	a40fe0ef          	jal	80000cbc <release>
      return -1;
    80002a80:	59fd                	li	s3,-1
    80002a82:	b749                	j	80002a04 <kwait+0x74>

0000000080002a84 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a84:	7179                	addi	sp,sp,-48
    80002a86:	f406                	sd	ra,40(sp)
    80002a88:	f022                	sd	s0,32(sp)
    80002a8a:	ec26                	sd	s1,24(sp)
    80002a8c:	e84a                	sd	s2,16(sp)
    80002a8e:	e44e                	sd	s3,8(sp)
    80002a90:	e052                	sd	s4,0(sp)
    80002a92:	1800                	addi	s0,sp,48
    80002a94:	84aa                	mv	s1,a0
    80002a96:	8a2e                	mv	s4,a1
    80002a98:	89b2                	mv	s3,a2
    80002a9a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002a9c:	81aff0ef          	jal	80001ab6 <myproc>
  if(user_dst){
    80002aa0:	cc99                	beqz	s1,80002abe <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002aa2:	86ca                	mv	a3,s2
    80002aa4:	864e                	mv	a2,s3
    80002aa6:	85d2                	mv	a1,s4
    80002aa8:	6d28                	ld	a0,88(a0)
    80002aaa:	babfe0ef          	jal	80001654 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002aae:	70a2                	ld	ra,40(sp)
    80002ab0:	7402                	ld	s0,32(sp)
    80002ab2:	64e2                	ld	s1,24(sp)
    80002ab4:	6942                	ld	s2,16(sp)
    80002ab6:	69a2                	ld	s3,8(sp)
    80002ab8:	6a02                	ld	s4,0(sp)
    80002aba:	6145                	addi	sp,sp,48
    80002abc:	8082                	ret
    memmove((char *)dst, src, len);
    80002abe:	0009061b          	sext.w	a2,s2
    80002ac2:	85ce                	mv	a1,s3
    80002ac4:	8552                	mv	a0,s4
    80002ac6:	a92fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002aca:	8526                	mv	a0,s1
    80002acc:	b7cd                	j	80002aae <either_copyout+0x2a>

0000000080002ace <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002ace:	7179                	addi	sp,sp,-48
    80002ad0:	f406                	sd	ra,40(sp)
    80002ad2:	f022                	sd	s0,32(sp)
    80002ad4:	ec26                	sd	s1,24(sp)
    80002ad6:	e84a                	sd	s2,16(sp)
    80002ad8:	e44e                	sd	s3,8(sp)
    80002ada:	e052                	sd	s4,0(sp)
    80002adc:	1800                	addi	s0,sp,48
    80002ade:	8a2a                	mv	s4,a0
    80002ae0:	84ae                	mv	s1,a1
    80002ae2:	89b2                	mv	s3,a2
    80002ae4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002ae6:	fd1fe0ef          	jal	80001ab6 <myproc>
  if(user_src){
    80002aea:	cc99                	beqz	s1,80002b08 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002aec:	86ca                	mv	a3,s2
    80002aee:	864e                	mv	a2,s3
    80002af0:	85d2                	mv	a1,s4
    80002af2:	6d28                	ld	a0,88(a0)
    80002af4:	c1ffe0ef          	jal	80001712 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002af8:	70a2                	ld	ra,40(sp)
    80002afa:	7402                	ld	s0,32(sp)
    80002afc:	64e2                	ld	s1,24(sp)
    80002afe:	6942                	ld	s2,16(sp)
    80002b00:	69a2                	ld	s3,8(sp)
    80002b02:	6a02                	ld	s4,0(sp)
    80002b04:	6145                	addi	sp,sp,48
    80002b06:	8082                	ret
    memmove(dst, (char*)src, len);
    80002b08:	0009061b          	sext.w	a2,s2
    80002b0c:	85ce                	mv	a1,s3
    80002b0e:	8552                	mv	a0,s4
    80002b10:	a48fe0ef          	jal	80000d58 <memmove>
    return 0;
    80002b14:	8526                	mv	a0,s1
    80002b16:	b7cd                	j	80002af8 <either_copyin+0x2a>

0000000080002b18 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002b18:	715d                	addi	sp,sp,-80
    80002b1a:	e486                	sd	ra,72(sp)
    80002b1c:	e0a2                	sd	s0,64(sp)
    80002b1e:	fc26                	sd	s1,56(sp)
    80002b20:	f84a                	sd	s2,48(sp)
    80002b22:	f44e                	sd	s3,40(sp)
    80002b24:	f052                	sd	s4,32(sp)
    80002b26:	ec56                	sd	s5,24(sp)
    80002b28:	e85a                	sd	s6,16(sp)
    80002b2a:	e45e                	sd	s7,8(sp)
    80002b2c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002b2e:	00005517          	auipc	a0,0x5
    80002b32:	54a50513          	addi	a0,a0,1354 # 80008078 <etext+0x78>
    80002b36:	9c5fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b3a:	00011497          	auipc	s1,0x11
    80002b3e:	56e48493          	addi	s1,s1,1390 # 800140a8 <proc+0x160>
    80002b42:	00017917          	auipc	s2,0x17
    80002b46:	16690913          	addi	s2,s2,358 # 80019ca8 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b4a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002b4c:	00006997          	auipc	s3,0x6
    80002b50:	9cc98993          	addi	s3,s3,-1588 # 80008518 <etext+0x518>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002b54:	00006a97          	auipc	s5,0x6
    80002b58:	9cca8a93          	addi	s5,s5,-1588 # 80008520 <etext+0x520>
    printf("\n");
    80002b5c:	00005a17          	auipc	s4,0x5
    80002b60:	51ca0a13          	addi	s4,s4,1308 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b64:	00006b97          	auipc	s7,0x6
    80002b68:	04cb8b93          	addi	s7,s7,76 # 80008bb0 <states.1>
    80002b6c:	a839                	j	80002b8a <procdump+0x72>
    printf("%d %s %s heat=%d", p->pid, state, p->name, p->heat);
    80002b6e:	ed86a703          	lw	a4,-296(a3)
    80002b72:	ed06a583          	lw	a1,-304(a3)
    80002b76:	8556                	mv	a0,s5
    80002b78:	983fd0ef          	jal	800004fa <printf>
    printf("\n");
    80002b7c:	8552                	mv	a0,s4
    80002b7e:	97dfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b82:	17048493          	addi	s1,s1,368
    80002b86:	03248263          	beq	s1,s2,80002baa <procdump+0x92>
    if(p->state == UNUSED)
    80002b8a:	86a6                	mv	a3,s1
    80002b8c:	eb84a783          	lw	a5,-328(s1)
    80002b90:	dbed                	beqz	a5,80002b82 <procdump+0x6a>
      state = "???";
    80002b92:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b94:	fcfb6de3          	bltu	s6,a5,80002b6e <procdump+0x56>
    80002b98:	02079713          	slli	a4,a5,0x20
    80002b9c:	01d75793          	srli	a5,a4,0x1d
    80002ba0:	97de                	add	a5,a5,s7
    80002ba2:	6390                	ld	a2,0(a5)
    80002ba4:	f669                	bnez	a2,80002b6e <procdump+0x56>
      state = "???";
    80002ba6:	864e                	mv	a2,s3
    80002ba8:	b7d9                	j	80002b6e <procdump+0x56>
  }
}
    80002baa:	60a6                	ld	ra,72(sp)
    80002bac:	6406                	ld	s0,64(sp)
    80002bae:	74e2                	ld	s1,56(sp)
    80002bb0:	7942                	ld	s2,48(sp)
    80002bb2:	79a2                	ld	s3,40(sp)
    80002bb4:	7a02                	ld	s4,32(sp)
    80002bb6:	6ae2                	ld	s5,24(sp)
    80002bb8:	6b42                	ld	s6,16(sp)
    80002bba:	6ba2                	ld	s7,8(sp)
    80002bbc:	6161                	addi	sp,sp,80
    80002bbe:	8082                	ret

0000000080002bc0 <kps>:


int
kps(char *arguments)
{
    80002bc0:	7179                	addi	sp,sp,-48
    80002bc2:	f406                	sd	ra,40(sp)
    80002bc4:	f022                	sd	s0,32(sp)
    80002bc6:	ec26                	sd	s1,24(sp)
    80002bc8:	1800                	addi	s0,sp,48
    80002bca:	84aa                	mv	s1,a0
  [RUNNABLE]  "RUNNABLE",
  [RUNNING]   "RUNNING",
  [ZOMBIE]    "ZOMBIE"
  };

  if(strncmp(arguments, "-o", 2)==0) {
    80002bcc:	4609                	li	a2,2
    80002bce:	00006597          	auipc	a1,0x6
    80002bd2:	96a58593          	addi	a1,a1,-1686 # 80008538 <etext+0x538>
    80002bd6:	9f6fe0ef          	jal	80000dcc <strncmp>
    80002bda:	e931                	bnez	a0,80002c2e <kps+0x6e>
    80002bdc:	e84a                	sd	s2,16(sp)
    80002bde:	e44e                	sd	s3,8(sp)
    80002be0:	00011497          	auipc	s1,0x11
    80002be4:	4c848493          	addi	s1,s1,1224 # 800140a8 <proc+0x160>
    80002be8:	00017917          	auipc	s2,0x17
    80002bec:	0c090913          	addi	s2,s2,192 # 80019ca8 <bcache+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
      if (p->state != UNUSED){
        printf("%s ", p->name);
    80002bf0:	00006997          	auipc	s3,0x6
    80002bf4:	95098993          	addi	s3,s3,-1712 # 80008540 <etext+0x540>
    80002bf8:	a029                	j	80002c02 <kps+0x42>
    for(p=proc; p<&proc[NPROC]; p++){
    80002bfa:	17048493          	addi	s1,s1,368
    80002bfe:	01248a63          	beq	s1,s2,80002c12 <kps+0x52>
      if (p->state != UNUSED){
    80002c02:	eb84a783          	lw	a5,-328(s1)
    80002c06:	dbf5                	beqz	a5,80002bfa <kps+0x3a>
        printf("%s ", p->name);
    80002c08:	85a6                	mv	a1,s1
    80002c0a:	854e                	mv	a0,s3
    80002c0c:	8effd0ef          	jal	800004fa <printf>
    80002c10:	b7ed                	j	80002bfa <kps+0x3a>
      }
    }
    printf("\n");
    80002c12:	00005517          	auipc	a0,0x5
    80002c16:	46650513          	addi	a0,a0,1126 # 80008078 <etext+0x78>
    80002c1a:	8e1fd0ef          	jal	800004fa <printf>
    80002c1e:	6942                	ld	s2,16(sp)
    80002c20:	69a2                	ld	s3,8(sp)
    printf("Usage: ps [-o | -l | -t]\n");
  }

  return 0;

    80002c22:	4501                	li	a0,0
    80002c24:	70a2                	ld	ra,40(sp)
    80002c26:	7402                	ld	s0,32(sp)
    80002c28:	64e2                	ld	s1,24(sp)
    80002c2a:	6145                	addi	sp,sp,48
    80002c2c:	8082                	ret
  }else if(strncmp(arguments, "-l", 2)==0){
    80002c2e:	4609                	li	a2,2
    80002c30:	00006597          	auipc	a1,0x6
    80002c34:	91858593          	addi	a1,a1,-1768 # 80008548 <etext+0x548>
    80002c38:	8526                	mv	a0,s1
    80002c3a:	992fe0ef          	jal	80000dcc <strncmp>
    80002c3e:	e92d                	bnez	a0,80002cb0 <kps+0xf0>
    80002c40:	e84a                	sd	s2,16(sp)
    80002c42:	e44e                	sd	s3,8(sp)
    80002c44:	e052                	sd	s4,0(sp)
    printf("PID\tSTATE\t\tNAME\n");
    80002c46:	00006517          	auipc	a0,0x6
    80002c4a:	90a50513          	addi	a0,a0,-1782 # 80008550 <etext+0x550>
    80002c4e:	8adfd0ef          	jal	800004fa <printf>
    printf("-------------------------------\n");
    80002c52:	00006517          	auipc	a0,0x6
    80002c56:	9be50513          	addi	a0,a0,-1602 # 80008610 <etext+0x610>
    80002c5a:	8a1fd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002c5e:	00011497          	auipc	s1,0x11
    80002c62:	44a48493          	addi	s1,s1,1098 # 800140a8 <proc+0x160>
    80002c66:	00017917          	auipc	s2,0x17
    80002c6a:	04290913          	addi	s2,s2,66 # 80019ca8 <bcache+0x148>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002c6e:	00006a17          	auipc	s4,0x6
    80002c72:	f42a0a13          	addi	s4,s4,-190 # 80008bb0 <states.1>
    80002c76:	00006997          	auipc	s3,0x6
    80002c7a:	8f298993          	addi	s3,s3,-1806 # 80008568 <etext+0x568>
    80002c7e:	a029                	j	80002c88 <kps+0xc8>
    for(p=proc; p<&proc[NPROC]; p++){
    80002c80:	17048493          	addi	s1,s1,368
    80002c84:	03248263          	beq	s1,s2,80002ca8 <kps+0xe8>
      if (p->state != UNUSED){
    80002c88:	eb84a783          	lw	a5,-328(s1)
    80002c8c:	dbf5                	beqz	a5,80002c80 <kps+0xc0>
        printf("%d\t%s\t\t%s\n", p->pid, states[p->state], p->name);
    80002c8e:	02079713          	slli	a4,a5,0x20
    80002c92:	01d75793          	srli	a5,a4,0x1d
    80002c96:	97d2                	add	a5,a5,s4
    80002c98:	86a6                	mv	a3,s1
    80002c9a:	7b90                	ld	a2,48(a5)
    80002c9c:	ed04a583          	lw	a1,-304(s1)
    80002ca0:	854e                	mv	a0,s3
    80002ca2:	859fd0ef          	jal	800004fa <printf>
    80002ca6:	bfe9                	j	80002c80 <kps+0xc0>
    80002ca8:	6942                	ld	s2,16(sp)
    80002caa:	69a2                	ld	s3,8(sp)
    80002cac:	6a02                	ld	s4,0(sp)
    80002cae:	bf95                	j	80002c22 <kps+0x62>
  }else if(strncmp(arguments, "-t", 2)==0){
    80002cb0:	4609                	li	a2,2
    80002cb2:	00006597          	auipc	a1,0x6
    80002cb6:	8c658593          	addi	a1,a1,-1850 # 80008578 <etext+0x578>
    80002cba:	8526                	mv	a0,s1
    80002cbc:	910fe0ef          	jal	80000dcc <strncmp>
    80002cc0:	e969                	bnez	a0,80002d92 <kps+0x1d2>
    80002cc2:	e84a                	sd	s2,16(sp)
    80002cc4:	e44e                	sd	s3,8(sp)
    80002cc6:	e052                	sd	s4,0(sp)
    printf("===== Thermal Monitor =====\n");
    80002cc8:	00006517          	auipc	a0,0x6
    80002ccc:	8b850513          	addi	a0,a0,-1864 # 80008580 <etext+0x580>
    80002cd0:	82bfd0ef          	jal	800004fa <printf>
    printf("CPU Temperature: %d / 100", cpu_temp);
    80002cd4:	00009497          	auipc	s1,0x9
    80002cd8:	b5448493          	addi	s1,s1,-1196 # 8000b828 <cpu_temp>
    80002cdc:	408c                	lw	a1,0(s1)
    80002cde:	00006517          	auipc	a0,0x6
    80002ce2:	8c250513          	addi	a0,a0,-1854 # 800085a0 <etext+0x5a0>
    80002ce6:	815fd0ef          	jal	800004fa <printf>
    if(cpu_temp >= 80)
    80002cea:	409c                	lw	a5,0(s1)
    80002cec:	04f00713          	li	a4,79
    80002cf0:	04f74963          	blt	a4,a5,80002d42 <kps+0x182>
    else if(cpu_temp >= 60)
    80002cf4:	03b00713          	li	a4,59
    80002cf8:	04f75c63          	bge	a4,a5,80002d50 <kps+0x190>
      printf("  [WARM]\n");
    80002cfc:	00006517          	auipc	a0,0x6
    80002d00:	8d450513          	addi	a0,a0,-1836 # 800085d0 <etext+0x5d0>
    80002d04:	ff6fd0ef          	jal	800004fa <printf>
    printf("\nPID\tSTATE\t\tHEAT\tNAME\n");
    80002d08:	00006517          	auipc	a0,0x6
    80002d0c:	8e850513          	addi	a0,a0,-1816 # 800085f0 <etext+0x5f0>
    80002d10:	feafd0ef          	jal	800004fa <printf>
    printf("---------------------------------------\n");
    80002d14:	00006517          	auipc	a0,0x6
    80002d18:	8f450513          	addi	a0,a0,-1804 # 80008608 <etext+0x608>
    80002d1c:	fdefd0ef          	jal	800004fa <printf>
    for(p=proc; p<&proc[NPROC]; p++){
    80002d20:	00011497          	auipc	s1,0x11
    80002d24:	38848493          	addi	s1,s1,904 # 800140a8 <proc+0x160>
    80002d28:	00017917          	auipc	s2,0x17
    80002d2c:	f8090913          	addi	s2,s2,-128 # 80019ca8 <bcache+0x148>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002d30:	00006a17          	auipc	s4,0x6
    80002d34:	e80a0a13          	addi	s4,s4,-384 # 80008bb0 <states.1>
    80002d38:	00006997          	auipc	s3,0x6
    80002d3c:	90098993          	addi	s3,s3,-1792 # 80008638 <etext+0x638>
    80002d40:	a01d                	j	80002d66 <kps+0x1a6>
      printf("  [HOT]\n");
    80002d42:	00006517          	auipc	a0,0x6
    80002d46:	87e50513          	addi	a0,a0,-1922 # 800085c0 <etext+0x5c0>
    80002d4a:	fb0fd0ef          	jal	800004fa <printf>
    80002d4e:	bf6d                	j	80002d08 <kps+0x148>
      printf("  [COOL]\n");
    80002d50:	00006517          	auipc	a0,0x6
    80002d54:	89050513          	addi	a0,a0,-1904 # 800085e0 <etext+0x5e0>
    80002d58:	fa2fd0ef          	jal	800004fa <printf>
    80002d5c:	b775                	j	80002d08 <kps+0x148>
    for(p=proc; p<&proc[NPROC]; p++){
    80002d5e:	17048493          	addi	s1,s1,368
    80002d62:	03248463          	beq	s1,s2,80002d8a <kps+0x1ca>
      if (p->state != UNUSED){
    80002d66:	eb84a783          	lw	a5,-328(s1)
    80002d6a:	dbf5                	beqz	a5,80002d5e <kps+0x19e>
        printf("%d\t%s\t\t%d\t%s\n", p->pid, states[p->state], p->heat, p->name);
    80002d6c:	02079713          	slli	a4,a5,0x20
    80002d70:	01d75793          	srli	a5,a4,0x1d
    80002d74:	97d2                	add	a5,a5,s4
    80002d76:	8726                	mv	a4,s1
    80002d78:	ed84a683          	lw	a3,-296(s1)
    80002d7c:	7b90                	ld	a2,48(a5)
    80002d7e:	ed04a583          	lw	a1,-304(s1)
    80002d82:	854e                	mv	a0,s3
    80002d84:	f76fd0ef          	jal	800004fa <printf>
    80002d88:	bfd9                	j	80002d5e <kps+0x19e>
    80002d8a:	6942                	ld	s2,16(sp)
    80002d8c:	69a2                	ld	s3,8(sp)
    80002d8e:	6a02                	ld	s4,0(sp)
    80002d90:	bd49                	j	80002c22 <kps+0x62>
    printf("Usage: ps [-o | -l | -t]\n");
    80002d92:	00006517          	auipc	a0,0x6
    80002d96:	8b650513          	addi	a0,a0,-1866 # 80008648 <etext+0x648>
    80002d9a:	f60fd0ef          	jal	800004fa <printf>
    80002d9e:	b551                	j	80002c22 <kps+0x62>

0000000080002da0 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002da0:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002da4:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002da8:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002daa:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002dac:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002db0:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002db4:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002db8:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002dbc:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002dc0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002dc4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002dc8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002dcc:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002dd0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002dd4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002dd8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002ddc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002dde:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002de0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002de4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002de8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002dec:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002df0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002df4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002df8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002dfc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002e00:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002e04:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002e08:	8082                	ret

0000000080002e0a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002e0a:	1141                	addi	sp,sp,-16
    80002e0c:	e406                	sd	ra,8(sp)
    80002e0e:	e022                	sd	s0,0(sp)
    80002e10:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002e12:	00006597          	auipc	a1,0x6
    80002e16:	8c658593          	addi	a1,a1,-1850 # 800086d8 <etext+0x6d8>
    80002e1a:	00017517          	auipc	a0,0x17
    80002e1e:	d2e50513          	addi	a0,a0,-722 # 80019b48 <tickslock>
    80002e22:	d7dfd0ef          	jal	80000b9e <initlock>
}
    80002e26:	60a2                	ld	ra,8(sp)
    80002e28:	6402                	ld	s0,0(sp)
    80002e2a:	0141                	addi	sp,sp,16
    80002e2c:	8082                	ret

0000000080002e2e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002e2e:	1141                	addi	sp,sp,-16
    80002e30:	e406                	sd	ra,8(sp)
    80002e32:	e022                	sd	s0,0(sp)
    80002e34:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e36:	00003797          	auipc	a5,0x3
    80002e3a:	02a78793          	addi	a5,a5,42 # 80005e60 <kernelvec>
    80002e3e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002e42:	60a2                	ld	ra,8(sp)
    80002e44:	6402                	ld	s0,0(sp)
    80002e46:	0141                	addi	sp,sp,16
    80002e48:	8082                	ret

0000000080002e4a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002e4a:	1141                	addi	sp,sp,-16
    80002e4c:	e406                	sd	ra,8(sp)
    80002e4e:	e022                	sd	s0,0(sp)
    80002e50:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002e52:	c65fe0ef          	jal	80001ab6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e5a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e5c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002e60:	04000737          	lui	a4,0x4000
    80002e64:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002e66:	0732                	slli	a4,a4,0xc
    80002e68:	00004797          	auipc	a5,0x4
    80002e6c:	19878793          	addi	a5,a5,408 # 80007000 <_trampoline>
    80002e70:	00004697          	auipc	a3,0x4
    80002e74:	19068693          	addi	a3,a3,400 # 80007000 <_trampoline>
    80002e78:	8f95                	sub	a5,a5,a3
    80002e7a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e7c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002e80:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e82:	18002773          	csrr	a4,satp
    80002e86:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e88:	7138                	ld	a4,96(a0)
    80002e8a:	653c                	ld	a5,72(a0)
    80002e8c:	6685                	lui	a3,0x1
    80002e8e:	97b6                	add	a5,a5,a3
    80002e90:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002e92:	713c                	ld	a5,96(a0)
    80002e94:	00000717          	auipc	a4,0x0
    80002e98:	11c70713          	addi	a4,a4,284 # 80002fb0 <usertrap>
    80002e9c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002e9e:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ea0:	8712                	mv	a4,tp
    80002ea2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ea4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ea8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002eac:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eb0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002eb4:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002eb6:	6f9c                	ld	a5,24(a5)
    80002eb8:	14179073          	csrw	sepc,a5
}
    80002ebc:	60a2                	ld	ra,8(sp)
    80002ebe:	6402                	ld	s0,0(sp)
    80002ec0:	0141                	addi	sp,sp,16
    80002ec2:	8082                	ret

0000000080002ec4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002ec4:	1141                	addi	sp,sp,-16
    80002ec6:	e406                	sd	ra,8(sp)
    80002ec8:	e022                	sd	s0,0(sp)
    80002eca:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002ecc:	bb7fe0ef          	jal	80001a82 <cpuid>
    80002ed0:	c915                	beqz	a0,80002f04 <clockintr+0x40>
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  if (myproc() != 0 && myproc()->state == RUNNING) {
    80002ed2:	be5fe0ef          	jal	80001ab6 <myproc>
    80002ed6:	c519                	beqz	a0,80002ee4 <clockintr+0x20>
    80002ed8:	bdffe0ef          	jal	80001ab6 <myproc>
    80002edc:	4d18                	lw	a4,24(a0)
    80002ede:	4791                	li	a5,4
    80002ee0:	04f70963          	beq	a4,a5,80002f32 <clockintr+0x6e>
    update_cpu_temp(1);   // CPU is active
  } else {
    update_cpu_temp(0);   // CPU is idle
    80002ee4:	4501                	li	a0,0
    80002ee6:	9c5fe0ef          	jal	800018aa <update_cpu_temp>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002eea:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002eee:	000f4737          	lui	a4,0xf4
    80002ef2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002ef6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002ef8:	14d79073          	csrw	stimecmp,a5
}
    80002efc:	60a2                	ld	ra,8(sp)
    80002efe:	6402                	ld	s0,0(sp)
    80002f00:	0141                	addi	sp,sp,16
    80002f02:	8082                	ret
    acquire(&tickslock);
    80002f04:	00017517          	auipc	a0,0x17
    80002f08:	c4450513          	addi	a0,a0,-956 # 80019b48 <tickslock>
    80002f0c:	d1dfd0ef          	jal	80000c28 <acquire>
    ticks++;
    80002f10:	00009717          	auipc	a4,0x9
    80002f14:	98070713          	addi	a4,a4,-1664 # 8000b890 <ticks>
    80002f18:	431c                	lw	a5,0(a4)
    80002f1a:	2785                	addiw	a5,a5,1
    80002f1c:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002f1e:	853a                	mv	a0,a4
    80002f20:	857ff0ef          	jal	80002776 <wakeup>
    release(&tickslock);
    80002f24:	00017517          	auipc	a0,0x17
    80002f28:	c2450513          	addi	a0,a0,-988 # 80019b48 <tickslock>
    80002f2c:	d91fd0ef          	jal	80000cbc <release>
    80002f30:	b74d                	j	80002ed2 <clockintr+0xe>
    update_cpu_temp(1);   // CPU is active
    80002f32:	4505                	li	a0,1
    80002f34:	977fe0ef          	jal	800018aa <update_cpu_temp>
    80002f38:	bf4d                	j	80002eea <clockintr+0x26>

0000000080002f3a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002f3a:	1101                	addi	sp,sp,-32
    80002f3c:	ec06                	sd	ra,24(sp)
    80002f3e:	e822                	sd	s0,16(sp)
    80002f40:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f42:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002f46:	57fd                	li	a5,-1
    80002f48:	17fe                	slli	a5,a5,0x3f
    80002f4a:	07a5                	addi	a5,a5,9
    80002f4c:	00f70c63          	beq	a4,a5,80002f64 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002f50:	57fd                	li	a5,-1
    80002f52:	17fe                	slli	a5,a5,0x3f
    80002f54:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002f56:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002f58:	04f70863          	beq	a4,a5,80002fa8 <devintr+0x6e>
  }
}
    80002f5c:	60e2                	ld	ra,24(sp)
    80002f5e:	6442                	ld	s0,16(sp)
    80002f60:	6105                	addi	sp,sp,32
    80002f62:	8082                	ret
    80002f64:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002f66:	7a7020ef          	jal	80005f0c <plic_claim>
    80002f6a:	872a                	mv	a4,a0
    80002f6c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002f6e:	47a9                	li	a5,10
    80002f70:	00f50963          	beq	a0,a5,80002f82 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002f74:	4785                	li	a5,1
    80002f76:	00f50963          	beq	a0,a5,80002f88 <devintr+0x4e>
    return 1;
    80002f7a:	4505                	li	a0,1
    } else if(irq){
    80002f7c:	eb09                	bnez	a4,80002f8e <devintr+0x54>
    80002f7e:	64a2                	ld	s1,8(sp)
    80002f80:	bff1                	j	80002f5c <devintr+0x22>
      uartintr();
    80002f82:	a73fd0ef          	jal	800009f4 <uartintr>
    if(irq)
    80002f86:	a819                	j	80002f9c <devintr+0x62>
      virtio_disk_intr();
    80002f88:	41a030ef          	jal	800063a2 <virtio_disk_intr>
    if(irq)
    80002f8c:	a801                	j	80002f9c <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002f8e:	85ba                	mv	a1,a4
    80002f90:	00005517          	auipc	a0,0x5
    80002f94:	75050513          	addi	a0,a0,1872 # 800086e0 <etext+0x6e0>
    80002f98:	d62fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    80002f9c:	8526                	mv	a0,s1
    80002f9e:	78f020ef          	jal	80005f2c <plic_complete>
    return 1;
    80002fa2:	4505                	li	a0,1
    80002fa4:	64a2                	ld	s1,8(sp)
    80002fa6:	bf5d                	j	80002f5c <devintr+0x22>
    clockintr();
    80002fa8:	f1dff0ef          	jal	80002ec4 <clockintr>
    return 2;
    80002fac:	4509                	li	a0,2
    80002fae:	b77d                	j	80002f5c <devintr+0x22>

0000000080002fb0 <usertrap>:
{
    80002fb0:	1101                	addi	sp,sp,-32
    80002fb2:	ec06                	sd	ra,24(sp)
    80002fb4:	e822                	sd	s0,16(sp)
    80002fb6:	e426                	sd	s1,8(sp)
    80002fb8:	e04a                	sd	s2,0(sp)
    80002fba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fbc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002fc0:	1007f793          	andi	a5,a5,256
    80002fc4:	eba5                	bnez	a5,80003034 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fc6:	00003797          	auipc	a5,0x3
    80002fca:	e9a78793          	addi	a5,a5,-358 # 80005e60 <kernelvec>
    80002fce:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002fd2:	ae5fe0ef          	jal	80001ab6 <myproc>
    80002fd6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002fd8:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fda:	14102773          	csrr	a4,sepc
    80002fde:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fe0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002fe4:	47a1                	li	a5,8
    80002fe6:	04f70d63          	beq	a4,a5,80003040 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002fea:	f51ff0ef          	jal	80002f3a <devintr>
    80002fee:	892a                	mv	s2,a0
    80002ff0:	e945                	bnez	a0,800030a0 <usertrap+0xf0>
    80002ff2:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002ff6:	47bd                	li	a5,15
    80002ff8:	08f70863          	beq	a4,a5,80003088 <usertrap+0xd8>
    80002ffc:	14202773          	csrr	a4,scause
    80003000:	47b5                	li	a5,13
    80003002:	08f70363          	beq	a4,a5,80003088 <usertrap+0xd8>
    80003006:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000300a:	5890                	lw	a2,48(s1)
    8000300c:	00005517          	auipc	a0,0x5
    80003010:	71450513          	addi	a0,a0,1812 # 80008720 <etext+0x720>
    80003014:	ce6fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003018:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000301c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80003020:	00005517          	auipc	a0,0x5
    80003024:	73050513          	addi	a0,a0,1840 # 80008750 <etext+0x750>
    80003028:	cd2fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000302c:	8526                	mv	a0,s1
    8000302e:	915ff0ef          	jal	80002942 <setkilled>
    80003032:	a035                	j	8000305e <usertrap+0xae>
    panic("usertrap: not from user mode");
    80003034:	00005517          	auipc	a0,0x5
    80003038:	6cc50513          	addi	a0,a0,1740 # 80008700 <etext+0x700>
    8000303c:	fe8fd0ef          	jal	80000824 <panic>
    if(killed(p))
    80003040:	927ff0ef          	jal	80002966 <killed>
    80003044:	ed15                	bnez	a0,80003080 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80003046:	70b8                	ld	a4,96(s1)
    80003048:	6f1c                	ld	a5,24(a4)
    8000304a:	0791                	addi	a5,a5,4
    8000304c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000304e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003052:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003056:	10079073          	csrw	sstatus,a5
    syscall();
    8000305a:	240000ef          	jal	8000329a <syscall>
  if(killed(p))
    8000305e:	8526                	mv	a0,s1
    80003060:	907ff0ef          	jal	80002966 <killed>
    80003064:	e139                	bnez	a0,800030aa <usertrap+0xfa>
  prepare_return();
    80003066:	de5ff0ef          	jal	80002e4a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000306a:	6ca8                	ld	a0,88(s1)
    8000306c:	8131                	srli	a0,a0,0xc
    8000306e:	57fd                	li	a5,-1
    80003070:	17fe                	slli	a5,a5,0x3f
    80003072:	8d5d                	or	a0,a0,a5
}
    80003074:	60e2                	ld	ra,24(sp)
    80003076:	6442                	ld	s0,16(sp)
    80003078:	64a2                	ld	s1,8(sp)
    8000307a:	6902                	ld	s2,0(sp)
    8000307c:	6105                	addi	sp,sp,32
    8000307e:	8082                	ret
      kexit(-1);
    80003080:	557d                	li	a0,-1
    80003082:	fb4ff0ef          	jal	80002836 <kexit>
    80003086:	b7c1                	j	80003046 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003088:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000308c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80003090:	164d                	addi	a2,a2,-13
    80003092:	00163613          	seqz	a2,a2
    80003096:	6ca8                	ld	a0,88(s1)
    80003098:	d38fe0ef          	jal	800015d0 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000309c:	f169                	bnez	a0,8000305e <usertrap+0xae>
    8000309e:	b7a5                	j	80003006 <usertrap+0x56>
  if(killed(p))
    800030a0:	8526                	mv	a0,s1
    800030a2:	8c5ff0ef          	jal	80002966 <killed>
    800030a6:	c511                	beqz	a0,800030b2 <usertrap+0x102>
    800030a8:	a011                	j	800030ac <usertrap+0xfc>
    800030aa:	4901                	li	s2,0
    kexit(-1);
    800030ac:	557d                	li	a0,-1
    800030ae:	f88ff0ef          	jal	80002836 <kexit>
  if(which_dev == 2)
    800030b2:	4789                	li	a5,2
    800030b4:	faf919e3          	bne	s2,a5,80003066 <usertrap+0xb6>
    yield();
    800030b8:	e46ff0ef          	jal	800026fe <yield>
    800030bc:	b76d                	j	80003066 <usertrap+0xb6>

00000000800030be <kerneltrap>:
{
    800030be:	7179                	addi	sp,sp,-48
    800030c0:	f406                	sd	ra,40(sp)
    800030c2:	f022                	sd	s0,32(sp)
    800030c4:	ec26                	sd	s1,24(sp)
    800030c6:	e84a                	sd	s2,16(sp)
    800030c8:	e44e                	sd	s3,8(sp)
    800030ca:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030cc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030d0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030d4:	142027f3          	csrr	a5,scause
    800030d8:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800030da:	1004f793          	andi	a5,s1,256
    800030de:	c795                	beqz	a5,8000310a <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800030e4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800030e6:	eb85                	bnez	a5,80003116 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800030e8:	e53ff0ef          	jal	80002f3a <devintr>
    800030ec:	c91d                	beqz	a0,80003122 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800030ee:	4789                	li	a5,2
    800030f0:	04f50a63          	beq	a0,a5,80003144 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030f4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030f8:	10049073          	csrw	sstatus,s1
}
    800030fc:	70a2                	ld	ra,40(sp)
    800030fe:	7402                	ld	s0,32(sp)
    80003100:	64e2                	ld	s1,24(sp)
    80003102:	6942                	ld	s2,16(sp)
    80003104:	69a2                	ld	s3,8(sp)
    80003106:	6145                	addi	sp,sp,48
    80003108:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	66e50513          	addi	a0,a0,1646 # 80008778 <etext+0x778>
    80003112:	f12fd0ef          	jal	80000824 <panic>
    panic("kerneltrap: interrupts enabled");
    80003116:	00005517          	auipc	a0,0x5
    8000311a:	68a50513          	addi	a0,a0,1674 # 800087a0 <etext+0x7a0>
    8000311e:	f06fd0ef          	jal	80000824 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003122:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003126:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000312a:	85ce                	mv	a1,s3
    8000312c:	00005517          	auipc	a0,0x5
    80003130:	69450513          	addi	a0,a0,1684 # 800087c0 <etext+0x7c0>
    80003134:	bc6fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80003138:	00005517          	auipc	a0,0x5
    8000313c:	6b050513          	addi	a0,a0,1712 # 800087e8 <etext+0x7e8>
    80003140:	ee4fd0ef          	jal	80000824 <panic>
  if(which_dev == 2 && myproc() != 0)
    80003144:	973fe0ef          	jal	80001ab6 <myproc>
    80003148:	d555                	beqz	a0,800030f4 <kerneltrap+0x36>
    yield();
    8000314a:	db4ff0ef          	jal	800026fe <yield>
    8000314e:	b75d                	j	800030f4 <kerneltrap+0x36>

0000000080003150 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003150:	1101                	addi	sp,sp,-32
    80003152:	ec06                	sd	ra,24(sp)
    80003154:	e822                	sd	s0,16(sp)
    80003156:	e426                	sd	s1,8(sp)
    80003158:	1000                	addi	s0,sp,32
    8000315a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000315c:	95bfe0ef          	jal	80001ab6 <myproc>
  switch (n) {
    80003160:	4795                	li	a5,5
    80003162:	0497e163          	bltu	a5,s1,800031a4 <argraw+0x54>
    80003166:	048a                	slli	s1,s1,0x2
    80003168:	00006717          	auipc	a4,0x6
    8000316c:	aa870713          	addi	a4,a4,-1368 # 80008c10 <states.0+0x30>
    80003170:	94ba                	add	s1,s1,a4
    80003172:	409c                	lw	a5,0(s1)
    80003174:	97ba                	add	a5,a5,a4
    80003176:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003178:	713c                	ld	a5,96(a0)
    8000317a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000317c:	60e2                	ld	ra,24(sp)
    8000317e:	6442                	ld	s0,16(sp)
    80003180:	64a2                	ld	s1,8(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret
    return p->trapframe->a1;
    80003186:	713c                	ld	a5,96(a0)
    80003188:	7fa8                	ld	a0,120(a5)
    8000318a:	bfcd                	j	8000317c <argraw+0x2c>
    return p->trapframe->a2;
    8000318c:	713c                	ld	a5,96(a0)
    8000318e:	63c8                	ld	a0,128(a5)
    80003190:	b7f5                	j	8000317c <argraw+0x2c>
    return p->trapframe->a3;
    80003192:	713c                	ld	a5,96(a0)
    80003194:	67c8                	ld	a0,136(a5)
    80003196:	b7dd                	j	8000317c <argraw+0x2c>
    return p->trapframe->a4;
    80003198:	713c                	ld	a5,96(a0)
    8000319a:	6bc8                	ld	a0,144(a5)
    8000319c:	b7c5                	j	8000317c <argraw+0x2c>
    return p->trapframe->a5;
    8000319e:	713c                	ld	a5,96(a0)
    800031a0:	6fc8                	ld	a0,152(a5)
    800031a2:	bfe9                	j	8000317c <argraw+0x2c>
  panic("argraw");
    800031a4:	00005517          	auipc	a0,0x5
    800031a8:	65450513          	addi	a0,a0,1620 # 800087f8 <etext+0x7f8>
    800031ac:	e78fd0ef          	jal	80000824 <panic>

00000000800031b0 <fetchaddr>:
{
    800031b0:	1101                	addi	sp,sp,-32
    800031b2:	ec06                	sd	ra,24(sp)
    800031b4:	e822                	sd	s0,16(sp)
    800031b6:	e426                	sd	s1,8(sp)
    800031b8:	e04a                	sd	s2,0(sp)
    800031ba:	1000                	addi	s0,sp,32
    800031bc:	84aa                	mv	s1,a0
    800031be:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800031c0:	8f7fe0ef          	jal	80001ab6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800031c4:	693c                	ld	a5,80(a0)
    800031c6:	02f4f663          	bgeu	s1,a5,800031f2 <fetchaddr+0x42>
    800031ca:	00848713          	addi	a4,s1,8
    800031ce:	02e7e463          	bltu	a5,a4,800031f6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800031d2:	46a1                	li	a3,8
    800031d4:	8626                	mv	a2,s1
    800031d6:	85ca                	mv	a1,s2
    800031d8:	6d28                	ld	a0,88(a0)
    800031da:	d38fe0ef          	jal	80001712 <copyin>
    800031de:	00a03533          	snez	a0,a0
    800031e2:	40a0053b          	negw	a0,a0
}
    800031e6:	60e2                	ld	ra,24(sp)
    800031e8:	6442                	ld	s0,16(sp)
    800031ea:	64a2                	ld	s1,8(sp)
    800031ec:	6902                	ld	s2,0(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret
    return -1;
    800031f2:	557d                	li	a0,-1
    800031f4:	bfcd                	j	800031e6 <fetchaddr+0x36>
    800031f6:	557d                	li	a0,-1
    800031f8:	b7fd                	j	800031e6 <fetchaddr+0x36>

00000000800031fa <fetchstr>:
{
    800031fa:	7179                	addi	sp,sp,-48
    800031fc:	f406                	sd	ra,40(sp)
    800031fe:	f022                	sd	s0,32(sp)
    80003200:	ec26                	sd	s1,24(sp)
    80003202:	e84a                	sd	s2,16(sp)
    80003204:	e44e                	sd	s3,8(sp)
    80003206:	1800                	addi	s0,sp,48
    80003208:	89aa                	mv	s3,a0
    8000320a:	84ae                	mv	s1,a1
    8000320c:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000320e:	8a9fe0ef          	jal	80001ab6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003212:	86ca                	mv	a3,s2
    80003214:	864e                	mv	a2,s3
    80003216:	85a6                	mv	a1,s1
    80003218:	6d28                	ld	a0,88(a0)
    8000321a:	adefe0ef          	jal	800014f8 <copyinstr>
    8000321e:	00054c63          	bltz	a0,80003236 <fetchstr+0x3c>
  return strlen(buf);
    80003222:	8526                	mv	a0,s1
    80003224:	c5ffd0ef          	jal	80000e82 <strlen>
}
    80003228:	70a2                	ld	ra,40(sp)
    8000322a:	7402                	ld	s0,32(sp)
    8000322c:	64e2                	ld	s1,24(sp)
    8000322e:	6942                	ld	s2,16(sp)
    80003230:	69a2                	ld	s3,8(sp)
    80003232:	6145                	addi	sp,sp,48
    80003234:	8082                	ret
    return -1;
    80003236:	557d                	li	a0,-1
    80003238:	bfc5                	j	80003228 <fetchstr+0x2e>

000000008000323a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000323a:	1101                	addi	sp,sp,-32
    8000323c:	ec06                	sd	ra,24(sp)
    8000323e:	e822                	sd	s0,16(sp)
    80003240:	e426                	sd	s1,8(sp)
    80003242:	1000                	addi	s0,sp,32
    80003244:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003246:	f0bff0ef          	jal	80003150 <argraw>
    8000324a:	c088                	sw	a0,0(s1)
}
    8000324c:	60e2                	ld	ra,24(sp)
    8000324e:	6442                	ld	s0,16(sp)
    80003250:	64a2                	ld	s1,8(sp)
    80003252:	6105                	addi	sp,sp,32
    80003254:	8082                	ret

0000000080003256 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	e426                	sd	s1,8(sp)
    8000325e:	1000                	addi	s0,sp,32
    80003260:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003262:	eefff0ef          	jal	80003150 <argraw>
    80003266:	e088                	sd	a0,0(s1)
}
    80003268:	60e2                	ld	ra,24(sp)
    8000326a:	6442                	ld	s0,16(sp)
    8000326c:	64a2                	ld	s1,8(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret

0000000080003272 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	e04a                	sd	s2,0(sp)
    8000327c:	1000                	addi	s0,sp,32
    8000327e:	892e                	mv	s2,a1
    80003280:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80003282:	ecfff0ef          	jal	80003150 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80003286:	8626                	mv	a2,s1
    80003288:	85ca                	mv	a1,s2
    8000328a:	f71ff0ef          	jal	800031fa <fetchstr>
}
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	64a2                	ld	s1,8(sp)
    80003294:	6902                	ld	s2,0(sp)
    80003296:	6105                	addi	sp,sp,32
    80003298:	8082                	ret

000000008000329a <syscall>:
[SYS_kps]     sys_kps,
};

void
syscall(void)
{
    8000329a:	1101                	addi	sp,sp,-32
    8000329c:	ec06                	sd	ra,24(sp)
    8000329e:	e822                	sd	s0,16(sp)
    800032a0:	e426                	sd	s1,8(sp)
    800032a2:	e04a                	sd	s2,0(sp)
    800032a4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800032a6:	811fe0ef          	jal	80001ab6 <myproc>
    800032aa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800032ac:	06053903          	ld	s2,96(a0)
    800032b0:	0a893783          	ld	a5,168(s2)
    800032b4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800032b8:	37fd                	addiw	a5,a5,-1
    800032ba:	4755                	li	a4,21
    800032bc:	00f76f63          	bltu	a4,a5,800032da <syscall+0x40>
    800032c0:	00369713          	slli	a4,a3,0x3
    800032c4:	00006797          	auipc	a5,0x6
    800032c8:	96478793          	addi	a5,a5,-1692 # 80008c28 <syscalls>
    800032cc:	97ba                	add	a5,a5,a4
    800032ce:	639c                	ld	a5,0(a5)
    800032d0:	c789                	beqz	a5,800032da <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800032d2:	9782                	jalr	a5
    800032d4:	06a93823          	sd	a0,112(s2)
    800032d8:	a829                	j	800032f2 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800032da:	16048613          	addi	a2,s1,352
    800032de:	588c                	lw	a1,48(s1)
    800032e0:	00005517          	auipc	a0,0x5
    800032e4:	52050513          	addi	a0,a0,1312 # 80008800 <etext+0x800>
    800032e8:	a12fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032ec:	70bc                	ld	a5,96(s1)
    800032ee:	577d                	li	a4,-1
    800032f0:	fbb8                	sd	a4,112(a5)
  }
}
    800032f2:	60e2                	ld	ra,24(sp)
    800032f4:	6442                	ld	s0,16(sp)
    800032f6:	64a2                	ld	s1,8(sp)
    800032f8:	6902                	ld	s2,0(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret

00000000800032fe <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800032fe:	1101                	addi	sp,sp,-32
    80003300:	ec06                	sd	ra,24(sp)
    80003302:	e822                	sd	s0,16(sp)
    80003304:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003306:	fec40593          	addi	a1,s0,-20
    8000330a:	4501                	li	a0,0
    8000330c:	f2fff0ef          	jal	8000323a <argint>
  kexit(n);
    80003310:	fec42503          	lw	a0,-20(s0)
    80003314:	d22ff0ef          	jal	80002836 <kexit>
  return 0;  // not reached
}
    80003318:	4501                	li	a0,0
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003322:	1141                	addi	sp,sp,-16
    80003324:	e406                	sd	ra,8(sp)
    80003326:	e022                	sd	s0,0(sp)
    80003328:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000332a:	f8cfe0ef          	jal	80001ab6 <myproc>
}
    8000332e:	5908                	lw	a0,48(a0)
    80003330:	60a2                	ld	ra,8(sp)
    80003332:	6402                	ld	s0,0(sp)
    80003334:	0141                	addi	sp,sp,16
    80003336:	8082                	ret

0000000080003338 <sys_fork>:

uint64
sys_fork(void)
{
    80003338:	1141                	addi	sp,sp,-16
    8000333a:	e406                	sd	ra,8(sp)
    8000333c:	e022                	sd	s0,0(sp)
    8000333e:	0800                	addi	s0,sp,16
  return kfork();
    80003340:	aedfe0ef          	jal	80001e2c <kfork>
}
    80003344:	60a2                	ld	ra,8(sp)
    80003346:	6402                	ld	s0,0(sp)
    80003348:	0141                	addi	sp,sp,16
    8000334a:	8082                	ret

000000008000334c <sys_wait>:

uint64
sys_wait(void)
{
    8000334c:	1101                	addi	sp,sp,-32
    8000334e:	ec06                	sd	ra,24(sp)
    80003350:	e822                	sd	s0,16(sp)
    80003352:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003354:	fe840593          	addi	a1,s0,-24
    80003358:	4501                	li	a0,0
    8000335a:	efdff0ef          	jal	80003256 <argaddr>
  return kwait(p);
    8000335e:	fe843503          	ld	a0,-24(s0)
    80003362:	e2eff0ef          	jal	80002990 <kwait>
}
    80003366:	60e2                	ld	ra,24(sp)
    80003368:	6442                	ld	s0,16(sp)
    8000336a:	6105                	addi	sp,sp,32
    8000336c:	8082                	ret

000000008000336e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000336e:	7179                	addi	sp,sp,-48
    80003370:	f406                	sd	ra,40(sp)
    80003372:	f022                	sd	s0,32(sp)
    80003374:	ec26                	sd	s1,24(sp)
    80003376:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80003378:	fd840593          	addi	a1,s0,-40
    8000337c:	4501                	li	a0,0
    8000337e:	ebdff0ef          	jal	8000323a <argint>
  argint(1, &t);
    80003382:	fdc40593          	addi	a1,s0,-36
    80003386:	4505                	li	a0,1
    80003388:	eb3ff0ef          	jal	8000323a <argint>
  addr = myproc()->sz;
    8000338c:	f2afe0ef          	jal	80001ab6 <myproc>
    80003390:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80003392:	fdc42703          	lw	a4,-36(s0)
    80003396:	4785                	li	a5,1
    80003398:	02f70763          	beq	a4,a5,800033c6 <sys_sbrk+0x58>
    8000339c:	fd842783          	lw	a5,-40(s0)
    800033a0:	0207c363          	bltz	a5,800033c6 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800033a4:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800033a6:	02000737          	lui	a4,0x2000
    800033aa:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800033ac:	0736                	slli	a4,a4,0xd
    800033ae:	02f76a63          	bltu	a4,a5,800033e2 <sys_sbrk+0x74>
    800033b2:	0297e863          	bltu	a5,s1,800033e2 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    800033b6:	f00fe0ef          	jal	80001ab6 <myproc>
    800033ba:	fd842703          	lw	a4,-40(s0)
    800033be:	693c                	ld	a5,80(a0)
    800033c0:	97ba                	add	a5,a5,a4
    800033c2:	e93c                	sd	a5,80(a0)
    800033c4:	a039                	j	800033d2 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    800033c6:	fd842503          	lw	a0,-40(s0)
    800033ca:	a01fe0ef          	jal	80001dca <growproc>
    800033ce:	00054863          	bltz	a0,800033de <sys_sbrk+0x70>
  }
  return addr;
}
    800033d2:	8526                	mv	a0,s1
    800033d4:	70a2                	ld	ra,40(sp)
    800033d6:	7402                	ld	s0,32(sp)
    800033d8:	64e2                	ld	s1,24(sp)
    800033da:	6145                	addi	sp,sp,48
    800033dc:	8082                	ret
      return -1;
    800033de:	54fd                	li	s1,-1
    800033e0:	bfcd                	j	800033d2 <sys_sbrk+0x64>
      return -1;
    800033e2:	54fd                	li	s1,-1
    800033e4:	b7fd                	j	800033d2 <sys_sbrk+0x64>

00000000800033e6 <sys_pause>:

uint64
sys_pause(void)
{
    800033e6:	7139                	addi	sp,sp,-64
    800033e8:	fc06                	sd	ra,56(sp)
    800033ea:	f822                	sd	s0,48(sp)
    800033ec:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800033ee:	fcc40593          	addi	a1,s0,-52
    800033f2:	4501                	li	a0,0
    800033f4:	e47ff0ef          	jal	8000323a <argint>
  if(n < 0)
    800033f8:	fcc42783          	lw	a5,-52(s0)
    800033fc:	0607c863          	bltz	a5,8000346c <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003400:	00016517          	auipc	a0,0x16
    80003404:	74850513          	addi	a0,a0,1864 # 80019b48 <tickslock>
    80003408:	821fd0ef          	jal	80000c28 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    8000340c:	fcc42783          	lw	a5,-52(s0)
    80003410:	c3b9                	beqz	a5,80003456 <sys_pause+0x70>
    80003412:	f426                	sd	s1,40(sp)
    80003414:	f04a                	sd	s2,32(sp)
    80003416:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80003418:	00008997          	auipc	s3,0x8
    8000341c:	4789a983          	lw	s3,1144(s3) # 8000b890 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003420:	00016917          	auipc	s2,0x16
    80003424:	72890913          	addi	s2,s2,1832 # 80019b48 <tickslock>
    80003428:	00008497          	auipc	s1,0x8
    8000342c:	46848493          	addi	s1,s1,1128 # 8000b890 <ticks>
    if(killed(myproc())){
    80003430:	e86fe0ef          	jal	80001ab6 <myproc>
    80003434:	d32ff0ef          	jal	80002966 <killed>
    80003438:	ed0d                	bnez	a0,80003472 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    8000343a:	85ca                	mv	a1,s2
    8000343c:	8526                	mv	a0,s1
    8000343e:	aecff0ef          	jal	8000272a <sleep>
  while(ticks - ticks0 < n){
    80003442:	409c                	lw	a5,0(s1)
    80003444:	413787bb          	subw	a5,a5,s3
    80003448:	fcc42703          	lw	a4,-52(s0)
    8000344c:	fee7e2e3          	bltu	a5,a4,80003430 <sys_pause+0x4a>
    80003450:	74a2                	ld	s1,40(sp)
    80003452:	7902                	ld	s2,32(sp)
    80003454:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80003456:	00016517          	auipc	a0,0x16
    8000345a:	6f250513          	addi	a0,a0,1778 # 80019b48 <tickslock>
    8000345e:	85ffd0ef          	jal	80000cbc <release>
  return 0;
    80003462:	4501                	li	a0,0
}
    80003464:	70e2                	ld	ra,56(sp)
    80003466:	7442                	ld	s0,48(sp)
    80003468:	6121                	addi	sp,sp,64
    8000346a:	8082                	ret
    n = 0;
    8000346c:	fc042623          	sw	zero,-52(s0)
    80003470:	bf41                	j	80003400 <sys_pause+0x1a>
      release(&tickslock);
    80003472:	00016517          	auipc	a0,0x16
    80003476:	6d650513          	addi	a0,a0,1750 # 80019b48 <tickslock>
    8000347a:	843fd0ef          	jal	80000cbc <release>
      return -1;
    8000347e:	557d                	li	a0,-1
    80003480:	74a2                	ld	s1,40(sp)
    80003482:	7902                	ld	s2,32(sp)
    80003484:	69e2                	ld	s3,24(sp)
    80003486:	bff9                	j	80003464 <sys_pause+0x7e>

0000000080003488 <sys_kill>:

uint64
sys_kill(void)
{
    80003488:	1101                	addi	sp,sp,-32
    8000348a:	ec06                	sd	ra,24(sp)
    8000348c:	e822                	sd	s0,16(sp)
    8000348e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003490:	fec40593          	addi	a1,s0,-20
    80003494:	4501                	li	a0,0
    80003496:	da5ff0ef          	jal	8000323a <argint>
  return kkill(pid);
    8000349a:	fec42503          	lw	a0,-20(s0)
    8000349e:	c3eff0ef          	jal	800028dc <kkill>
}
    800034a2:	60e2                	ld	ra,24(sp)
    800034a4:	6442                	ld	s0,16(sp)
    800034a6:	6105                	addi	sp,sp,32
    800034a8:	8082                	ret

00000000800034aa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800034aa:	1101                	addi	sp,sp,-32
    800034ac:	ec06                	sd	ra,24(sp)
    800034ae:	e822                	sd	s0,16(sp)
    800034b0:	e426                	sd	s1,8(sp)
    800034b2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800034b4:	00016517          	auipc	a0,0x16
    800034b8:	69450513          	addi	a0,a0,1684 # 80019b48 <tickslock>
    800034bc:	f6cfd0ef          	jal	80000c28 <acquire>
  xticks = ticks;
    800034c0:	00008797          	auipc	a5,0x8
    800034c4:	3d07a783          	lw	a5,976(a5) # 8000b890 <ticks>
    800034c8:	84be                	mv	s1,a5
  release(&tickslock);
    800034ca:	00016517          	auipc	a0,0x16
    800034ce:	67e50513          	addi	a0,a0,1662 # 80019b48 <tickslock>
    800034d2:	feafd0ef          	jal	80000cbc <release>
  return xticks;
}
    800034d6:	02049513          	slli	a0,s1,0x20
    800034da:	9101                	srli	a0,a0,0x20
    800034dc:	60e2                	ld	ra,24(sp)
    800034de:	6442                	ld	s0,16(sp)
    800034e0:	64a2                	ld	s1,8(sp)
    800034e2:	6105                	addi	sp,sp,32
    800034e4:	8082                	ret

00000000800034e6 <sys_kps>:

uint64
sys_kps(void)
{
    800034e6:	1101                	addi	sp,sp,-32
    800034e8:	ec06                	sd	ra,24(sp)
    800034ea:	e822                	sd	s0,16(sp)
    800034ec:	1000                	addi	s0,sp,32
  //read from trap frame using argstr(…) into a string variable and pass that on to the system call.

  char buffer[4];

  if(argstr(0, buffer, sizeof(buffer)) < 0)
    800034ee:	4611                	li	a2,4
    800034f0:	fe840593          	addi	a1,s0,-24
    800034f4:	4501                	li	a0,0
    800034f6:	d7dff0ef          	jal	80003272 <argstr>
    800034fa:	87aa                	mv	a5,a0
    return -1;
    800034fc:	557d                	li	a0,-1
  if(argstr(0, buffer, sizeof(buffer)) < 0)
    800034fe:	0007c663          	bltz	a5,8000350a <sys_kps+0x24>

  return kps(buffer);
    80003502:	fe840513          	addi	a0,s0,-24
    80003506:	ebaff0ef          	jal	80002bc0 <kps>
    8000350a:	60e2                	ld	ra,24(sp)
    8000350c:	6442                	ld	s0,16(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	ec26                	sd	s1,24(sp)
    8000351a:	e84a                	sd	s2,16(sp)
    8000351c:	e44e                	sd	s3,8(sp)
    8000351e:	e052                	sd	s4,0(sp)
    80003520:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003522:	00005597          	auipc	a1,0x5
    80003526:	2fe58593          	addi	a1,a1,766 # 80008820 <etext+0x820>
    8000352a:	00016517          	auipc	a0,0x16
    8000352e:	63650513          	addi	a0,a0,1590 # 80019b60 <bcache>
    80003532:	e6cfd0ef          	jal	80000b9e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003536:	0001e797          	auipc	a5,0x1e
    8000353a:	62a78793          	addi	a5,a5,1578 # 80021b60 <bcache+0x8000>
    8000353e:	0001f717          	auipc	a4,0x1f
    80003542:	88a70713          	addi	a4,a4,-1910 # 80021dc8 <bcache+0x8268>
    80003546:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000354a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000354e:	00016497          	auipc	s1,0x16
    80003552:	62a48493          	addi	s1,s1,1578 # 80019b78 <bcache+0x18>
    b->next = bcache.head.next;
    80003556:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003558:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000355a:	00005a17          	auipc	s4,0x5
    8000355e:	2cea0a13          	addi	s4,s4,718 # 80008828 <etext+0x828>
    b->next = bcache.head.next;
    80003562:	2b893783          	ld	a5,696(s2)
    80003566:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003568:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000356c:	85d2                	mv	a1,s4
    8000356e:	01048513          	addi	a0,s1,16
    80003572:	328010ef          	jal	8000489a <initsleeplock>
    bcache.head.next->prev = b;
    80003576:	2b893783          	ld	a5,696(s2)
    8000357a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000357c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003580:	45848493          	addi	s1,s1,1112
    80003584:	fd349fe3          	bne	s1,s3,80003562 <binit+0x50>
  }
}
    80003588:	70a2                	ld	ra,40(sp)
    8000358a:	7402                	ld	s0,32(sp)
    8000358c:	64e2                	ld	s1,24(sp)
    8000358e:	6942                	ld	s2,16(sp)
    80003590:	69a2                	ld	s3,8(sp)
    80003592:	6a02                	ld	s4,0(sp)
    80003594:	6145                	addi	sp,sp,48
    80003596:	8082                	ret

0000000080003598 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003598:	7179                	addi	sp,sp,-48
    8000359a:	f406                	sd	ra,40(sp)
    8000359c:	f022                	sd	s0,32(sp)
    8000359e:	ec26                	sd	s1,24(sp)
    800035a0:	e84a                	sd	s2,16(sp)
    800035a2:	e44e                	sd	s3,8(sp)
    800035a4:	1800                	addi	s0,sp,48
    800035a6:	892a                	mv	s2,a0
    800035a8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800035aa:	00016517          	auipc	a0,0x16
    800035ae:	5b650513          	addi	a0,a0,1462 # 80019b60 <bcache>
    800035b2:	e76fd0ef          	jal	80000c28 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035b6:	0001f497          	auipc	s1,0x1f
    800035ba:	8624b483          	ld	s1,-1950(s1) # 80021e18 <bcache+0x82b8>
    800035be:	0001f797          	auipc	a5,0x1f
    800035c2:	80a78793          	addi	a5,a5,-2038 # 80021dc8 <bcache+0x8268>
    800035c6:	02f48b63          	beq	s1,a5,800035fc <bread+0x64>
    800035ca:	873e                	mv	a4,a5
    800035cc:	a021                	j	800035d4 <bread+0x3c>
    800035ce:	68a4                	ld	s1,80(s1)
    800035d0:	02e48663          	beq	s1,a4,800035fc <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800035d4:	449c                	lw	a5,8(s1)
    800035d6:	ff279ce3          	bne	a5,s2,800035ce <bread+0x36>
    800035da:	44dc                	lw	a5,12(s1)
    800035dc:	ff3799e3          	bne	a5,s3,800035ce <bread+0x36>
      b->refcnt++;
    800035e0:	40bc                	lw	a5,64(s1)
    800035e2:	2785                	addiw	a5,a5,1
    800035e4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035e6:	00016517          	auipc	a0,0x16
    800035ea:	57a50513          	addi	a0,a0,1402 # 80019b60 <bcache>
    800035ee:	ecefd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    800035f2:	01048513          	addi	a0,s1,16
    800035f6:	2da010ef          	jal	800048d0 <acquiresleep>
      return b;
    800035fa:	a889                	j	8000364c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035fc:	0001f497          	auipc	s1,0x1f
    80003600:	8144b483          	ld	s1,-2028(s1) # 80021e10 <bcache+0x82b0>
    80003604:	0001e797          	auipc	a5,0x1e
    80003608:	7c478793          	addi	a5,a5,1988 # 80021dc8 <bcache+0x8268>
    8000360c:	00f48863          	beq	s1,a5,8000361c <bread+0x84>
    80003610:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003612:	40bc                	lw	a5,64(s1)
    80003614:	cb91                	beqz	a5,80003628 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003616:	64a4                	ld	s1,72(s1)
    80003618:	fee49de3          	bne	s1,a4,80003612 <bread+0x7a>
  panic("bget: no buffers");
    8000361c:	00005517          	auipc	a0,0x5
    80003620:	21450513          	addi	a0,a0,532 # 80008830 <etext+0x830>
    80003624:	a00fd0ef          	jal	80000824 <panic>
      b->dev = dev;
    80003628:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000362c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003630:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003634:	4785                	li	a5,1
    80003636:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003638:	00016517          	auipc	a0,0x16
    8000363c:	52850513          	addi	a0,a0,1320 # 80019b60 <bcache>
    80003640:	e7cfd0ef          	jal	80000cbc <release>
      acquiresleep(&b->lock);
    80003644:	01048513          	addi	a0,s1,16
    80003648:	288010ef          	jal	800048d0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000364c:	409c                	lw	a5,0(s1)
    8000364e:	cb89                	beqz	a5,80003660 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003650:	8526                	mv	a0,s1
    80003652:	70a2                	ld	ra,40(sp)
    80003654:	7402                	ld	s0,32(sp)
    80003656:	64e2                	ld	s1,24(sp)
    80003658:	6942                	ld	s2,16(sp)
    8000365a:	69a2                	ld	s3,8(sp)
    8000365c:	6145                	addi	sp,sp,48
    8000365e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003660:	4581                	li	a1,0
    80003662:	8526                	mv	a0,s1
    80003664:	32d020ef          	jal	80006190 <virtio_disk_rw>
    b->valid = 1;
    80003668:	4785                	li	a5,1
    8000366a:	c09c                	sw	a5,0(s1)
  return b;
    8000366c:	b7d5                	j	80003650 <bread+0xb8>

000000008000366e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000366e:	1101                	addi	sp,sp,-32
    80003670:	ec06                	sd	ra,24(sp)
    80003672:	e822                	sd	s0,16(sp)
    80003674:	e426                	sd	s1,8(sp)
    80003676:	1000                	addi	s0,sp,32
    80003678:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000367a:	0541                	addi	a0,a0,16
    8000367c:	2d2010ef          	jal	8000494e <holdingsleep>
    80003680:	c911                	beqz	a0,80003694 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003682:	4585                	li	a1,1
    80003684:	8526                	mv	a0,s1
    80003686:	30b020ef          	jal	80006190 <virtio_disk_rw>
}
    8000368a:	60e2                	ld	ra,24(sp)
    8000368c:	6442                	ld	s0,16(sp)
    8000368e:	64a2                	ld	s1,8(sp)
    80003690:	6105                	addi	sp,sp,32
    80003692:	8082                	ret
    panic("bwrite");
    80003694:	00005517          	auipc	a0,0x5
    80003698:	1b450513          	addi	a0,a0,436 # 80008848 <etext+0x848>
    8000369c:	988fd0ef          	jal	80000824 <panic>

00000000800036a0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036a0:	1101                	addi	sp,sp,-32
    800036a2:	ec06                	sd	ra,24(sp)
    800036a4:	e822                	sd	s0,16(sp)
    800036a6:	e426                	sd	s1,8(sp)
    800036a8:	e04a                	sd	s2,0(sp)
    800036aa:	1000                	addi	s0,sp,32
    800036ac:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036ae:	01050913          	addi	s2,a0,16
    800036b2:	854a                	mv	a0,s2
    800036b4:	29a010ef          	jal	8000494e <holdingsleep>
    800036b8:	c125                	beqz	a0,80003718 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    800036ba:	854a                	mv	a0,s2
    800036bc:	25a010ef          	jal	80004916 <releasesleep>

  acquire(&bcache.lock);
    800036c0:	00016517          	auipc	a0,0x16
    800036c4:	4a050513          	addi	a0,a0,1184 # 80019b60 <bcache>
    800036c8:	d60fd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    800036cc:	40bc                	lw	a5,64(s1)
    800036ce:	37fd                	addiw	a5,a5,-1
    800036d0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800036d2:	e79d                	bnez	a5,80003700 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800036d4:	68b8                	ld	a4,80(s1)
    800036d6:	64bc                	ld	a5,72(s1)
    800036d8:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800036da:	68b8                	ld	a4,80(s1)
    800036dc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036de:	0001e797          	auipc	a5,0x1e
    800036e2:	48278793          	addi	a5,a5,1154 # 80021b60 <bcache+0x8000>
    800036e6:	2b87b703          	ld	a4,696(a5)
    800036ea:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036ec:	0001e717          	auipc	a4,0x1e
    800036f0:	6dc70713          	addi	a4,a4,1756 # 80021dc8 <bcache+0x8268>
    800036f4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036f6:	2b87b703          	ld	a4,696(a5)
    800036fa:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036fc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003700:	00016517          	auipc	a0,0x16
    80003704:	46050513          	addi	a0,a0,1120 # 80019b60 <bcache>
    80003708:	db4fd0ef          	jal	80000cbc <release>
}
    8000370c:	60e2                	ld	ra,24(sp)
    8000370e:	6442                	ld	s0,16(sp)
    80003710:	64a2                	ld	s1,8(sp)
    80003712:	6902                	ld	s2,0(sp)
    80003714:	6105                	addi	sp,sp,32
    80003716:	8082                	ret
    panic("brelse");
    80003718:	00005517          	auipc	a0,0x5
    8000371c:	13850513          	addi	a0,a0,312 # 80008850 <etext+0x850>
    80003720:	904fd0ef          	jal	80000824 <panic>

0000000080003724 <bpin>:

void
bpin(struct buf *b) {
    80003724:	1101                	addi	sp,sp,-32
    80003726:	ec06                	sd	ra,24(sp)
    80003728:	e822                	sd	s0,16(sp)
    8000372a:	e426                	sd	s1,8(sp)
    8000372c:	1000                	addi	s0,sp,32
    8000372e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003730:	00016517          	auipc	a0,0x16
    80003734:	43050513          	addi	a0,a0,1072 # 80019b60 <bcache>
    80003738:	cf0fd0ef          	jal	80000c28 <acquire>
  b->refcnt++;
    8000373c:	40bc                	lw	a5,64(s1)
    8000373e:	2785                	addiw	a5,a5,1
    80003740:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003742:	00016517          	auipc	a0,0x16
    80003746:	41e50513          	addi	a0,a0,1054 # 80019b60 <bcache>
    8000374a:	d72fd0ef          	jal	80000cbc <release>
}
    8000374e:	60e2                	ld	ra,24(sp)
    80003750:	6442                	ld	s0,16(sp)
    80003752:	64a2                	ld	s1,8(sp)
    80003754:	6105                	addi	sp,sp,32
    80003756:	8082                	ret

0000000080003758 <bunpin>:

void
bunpin(struct buf *b) {
    80003758:	1101                	addi	sp,sp,-32
    8000375a:	ec06                	sd	ra,24(sp)
    8000375c:	e822                	sd	s0,16(sp)
    8000375e:	e426                	sd	s1,8(sp)
    80003760:	1000                	addi	s0,sp,32
    80003762:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003764:	00016517          	auipc	a0,0x16
    80003768:	3fc50513          	addi	a0,a0,1020 # 80019b60 <bcache>
    8000376c:	cbcfd0ef          	jal	80000c28 <acquire>
  b->refcnt--;
    80003770:	40bc                	lw	a5,64(s1)
    80003772:	37fd                	addiw	a5,a5,-1
    80003774:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003776:	00016517          	auipc	a0,0x16
    8000377a:	3ea50513          	addi	a0,a0,1002 # 80019b60 <bcache>
    8000377e:	d3efd0ef          	jal	80000cbc <release>
}
    80003782:	60e2                	ld	ra,24(sp)
    80003784:	6442                	ld	s0,16(sp)
    80003786:	64a2                	ld	s1,8(sp)
    80003788:	6105                	addi	sp,sp,32
    8000378a:	8082                	ret

000000008000378c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000378c:	1101                	addi	sp,sp,-32
    8000378e:	ec06                	sd	ra,24(sp)
    80003790:	e822                	sd	s0,16(sp)
    80003792:	e426                	sd	s1,8(sp)
    80003794:	e04a                	sd	s2,0(sp)
    80003796:	1000                	addi	s0,sp,32
    80003798:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000379a:	00d5d79b          	srliw	a5,a1,0xd
    8000379e:	0001f597          	auipc	a1,0x1f
    800037a2:	a9e5a583          	lw	a1,-1378(a1) # 8002223c <sb+0x1c>
    800037a6:	9dbd                	addw	a1,a1,a5
    800037a8:	df1ff0ef          	jal	80003598 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800037ac:	0074f713          	andi	a4,s1,7
    800037b0:	4785                	li	a5,1
    800037b2:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800037b6:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800037b8:	90d9                	srli	s1,s1,0x36
    800037ba:	00950733          	add	a4,a0,s1
    800037be:	05874703          	lbu	a4,88(a4)
    800037c2:	00e7f6b3          	and	a3,a5,a4
    800037c6:	c29d                	beqz	a3,800037ec <bfree+0x60>
    800037c8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037ca:	94aa                	add	s1,s1,a0
    800037cc:	fff7c793          	not	a5,a5
    800037d0:	8f7d                	and	a4,a4,a5
    800037d2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800037d6:	000010ef          	jal	800047d6 <log_write>
  brelse(bp);
    800037da:	854a                	mv	a0,s2
    800037dc:	ec5ff0ef          	jal	800036a0 <brelse>
}
    800037e0:	60e2                	ld	ra,24(sp)
    800037e2:	6442                	ld	s0,16(sp)
    800037e4:	64a2                	ld	s1,8(sp)
    800037e6:	6902                	ld	s2,0(sp)
    800037e8:	6105                	addi	sp,sp,32
    800037ea:	8082                	ret
    panic("freeing free block");
    800037ec:	00005517          	auipc	a0,0x5
    800037f0:	06c50513          	addi	a0,a0,108 # 80008858 <etext+0x858>
    800037f4:	830fd0ef          	jal	80000824 <panic>

00000000800037f8 <balloc>:
{
    800037f8:	715d                	addi	sp,sp,-80
    800037fa:	e486                	sd	ra,72(sp)
    800037fc:	e0a2                	sd	s0,64(sp)
    800037fe:	fc26                	sd	s1,56(sp)
    80003800:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003802:	0001f797          	auipc	a5,0x1f
    80003806:	a227a783          	lw	a5,-1502(a5) # 80022224 <sb+0x4>
    8000380a:	0e078263          	beqz	a5,800038ee <balloc+0xf6>
    8000380e:	f84a                	sd	s2,48(sp)
    80003810:	f44e                	sd	s3,40(sp)
    80003812:	f052                	sd	s4,32(sp)
    80003814:	ec56                	sd	s5,24(sp)
    80003816:	e85a                	sd	s6,16(sp)
    80003818:	e45e                	sd	s7,8(sp)
    8000381a:	e062                	sd	s8,0(sp)
    8000381c:	8baa                	mv	s7,a0
    8000381e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003820:	0001fb17          	auipc	s6,0x1f
    80003824:	a00b0b13          	addi	s6,s6,-1536 # 80022220 <sb>
      m = 1 << (bi % 8);
    80003828:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000382a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000382c:	6c09                	lui	s8,0x2
    8000382e:	a09d                	j	80003894 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003830:	97ca                	add	a5,a5,s2
    80003832:	8e55                	or	a2,a2,a3
    80003834:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003838:	854a                	mv	a0,s2
    8000383a:	79d000ef          	jal	800047d6 <log_write>
        brelse(bp);
    8000383e:	854a                	mv	a0,s2
    80003840:	e61ff0ef          	jal	800036a0 <brelse>
  bp = bread(dev, bno);
    80003844:	85a6                	mv	a1,s1
    80003846:	855e                	mv	a0,s7
    80003848:	d51ff0ef          	jal	80003598 <bread>
    8000384c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000384e:	40000613          	li	a2,1024
    80003852:	4581                	li	a1,0
    80003854:	05850513          	addi	a0,a0,88
    80003858:	ca0fd0ef          	jal	80000cf8 <memset>
  log_write(bp);
    8000385c:	854a                	mv	a0,s2
    8000385e:	779000ef          	jal	800047d6 <log_write>
  brelse(bp);
    80003862:	854a                	mv	a0,s2
    80003864:	e3dff0ef          	jal	800036a0 <brelse>
}
    80003868:	7942                	ld	s2,48(sp)
    8000386a:	79a2                	ld	s3,40(sp)
    8000386c:	7a02                	ld	s4,32(sp)
    8000386e:	6ae2                	ld	s5,24(sp)
    80003870:	6b42                	ld	s6,16(sp)
    80003872:	6ba2                	ld	s7,8(sp)
    80003874:	6c02                	ld	s8,0(sp)
}
    80003876:	8526                	mv	a0,s1
    80003878:	60a6                	ld	ra,72(sp)
    8000387a:	6406                	ld	s0,64(sp)
    8000387c:	74e2                	ld	s1,56(sp)
    8000387e:	6161                	addi	sp,sp,80
    80003880:	8082                	ret
    brelse(bp);
    80003882:	854a                	mv	a0,s2
    80003884:	e1dff0ef          	jal	800036a0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003888:	015c0abb          	addw	s5,s8,s5
    8000388c:	004b2783          	lw	a5,4(s6)
    80003890:	04faf863          	bgeu	s5,a5,800038e0 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003894:	40dad59b          	sraiw	a1,s5,0xd
    80003898:	01cb2783          	lw	a5,28(s6)
    8000389c:	9dbd                	addw	a1,a1,a5
    8000389e:	855e                	mv	a0,s7
    800038a0:	cf9ff0ef          	jal	80003598 <bread>
    800038a4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a6:	004b2503          	lw	a0,4(s6)
    800038aa:	84d6                	mv	s1,s5
    800038ac:	4701                	li	a4,0
    800038ae:	fca4fae3          	bgeu	s1,a0,80003882 <balloc+0x8a>
      m = 1 << (bi % 8);
    800038b2:	00777693          	andi	a3,a4,7
    800038b6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800038ba:	41f7579b          	sraiw	a5,a4,0x1f
    800038be:	01d7d79b          	srliw	a5,a5,0x1d
    800038c2:	9fb9                	addw	a5,a5,a4
    800038c4:	4037d79b          	sraiw	a5,a5,0x3
    800038c8:	00f90633          	add	a2,s2,a5
    800038cc:	05864603          	lbu	a2,88(a2)
    800038d0:	00c6f5b3          	and	a1,a3,a2
    800038d4:	ddb1                	beqz	a1,80003830 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038d6:	2705                	addiw	a4,a4,1
    800038d8:	2485                	addiw	s1,s1,1
    800038da:	fd471ae3          	bne	a4,s4,800038ae <balloc+0xb6>
    800038de:	b755                	j	80003882 <balloc+0x8a>
    800038e0:	7942                	ld	s2,48(sp)
    800038e2:	79a2                	ld	s3,40(sp)
    800038e4:	7a02                	ld	s4,32(sp)
    800038e6:	6ae2                	ld	s5,24(sp)
    800038e8:	6b42                	ld	s6,16(sp)
    800038ea:	6ba2                	ld	s7,8(sp)
    800038ec:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800038ee:	00005517          	auipc	a0,0x5
    800038f2:	f8250513          	addi	a0,a0,-126 # 80008870 <etext+0x870>
    800038f6:	c05fc0ef          	jal	800004fa <printf>
  return 0;
    800038fa:	4481                	li	s1,0
    800038fc:	bfad                	j	80003876 <balloc+0x7e>

00000000800038fe <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038fe:	7179                	addi	sp,sp,-48
    80003900:	f406                	sd	ra,40(sp)
    80003902:	f022                	sd	s0,32(sp)
    80003904:	ec26                	sd	s1,24(sp)
    80003906:	e84a                	sd	s2,16(sp)
    80003908:	e44e                	sd	s3,8(sp)
    8000390a:	1800                	addi	s0,sp,48
    8000390c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000390e:	47ad                	li	a5,11
    80003910:	02b7e363          	bltu	a5,a1,80003936 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80003914:	02059793          	slli	a5,a1,0x20
    80003918:	01e7d593          	srli	a1,a5,0x1e
    8000391c:	00b509b3          	add	s3,a0,a1
    80003920:	0509a483          	lw	s1,80(s3)
    80003924:	e0b5                	bnez	s1,80003988 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003926:	4108                	lw	a0,0(a0)
    80003928:	ed1ff0ef          	jal	800037f8 <balloc>
    8000392c:	84aa                	mv	s1,a0
      if(addr == 0)
    8000392e:	cd29                	beqz	a0,80003988 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003930:	04a9a823          	sw	a0,80(s3)
    80003934:	a891                	j	80003988 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003936:	ff45879b          	addiw	a5,a1,-12
    8000393a:	873e                	mv	a4,a5
    8000393c:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000393e:	0ff00793          	li	a5,255
    80003942:	06e7e763          	bltu	a5,a4,800039b0 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003946:	08052483          	lw	s1,128(a0)
    8000394a:	e891                	bnez	s1,8000395e <bmap+0x60>
      addr = balloc(ip->dev);
    8000394c:	4108                	lw	a0,0(a0)
    8000394e:	eabff0ef          	jal	800037f8 <balloc>
    80003952:	84aa                	mv	s1,a0
      if(addr == 0)
    80003954:	c915                	beqz	a0,80003988 <bmap+0x8a>
    80003956:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003958:	08a92023          	sw	a0,128(s2)
    8000395c:	a011                	j	80003960 <bmap+0x62>
    8000395e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003960:	85a6                	mv	a1,s1
    80003962:	00092503          	lw	a0,0(s2)
    80003966:	c33ff0ef          	jal	80003598 <bread>
    8000396a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000396c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003970:	02099713          	slli	a4,s3,0x20
    80003974:	01e75593          	srli	a1,a4,0x1e
    80003978:	97ae                	add	a5,a5,a1
    8000397a:	89be                	mv	s3,a5
    8000397c:	4384                	lw	s1,0(a5)
    8000397e:	cc89                	beqz	s1,80003998 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003980:	8552                	mv	a0,s4
    80003982:	d1fff0ef          	jal	800036a0 <brelse>
    return addr;
    80003986:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003988:	8526                	mv	a0,s1
    8000398a:	70a2                	ld	ra,40(sp)
    8000398c:	7402                	ld	s0,32(sp)
    8000398e:	64e2                	ld	s1,24(sp)
    80003990:	6942                	ld	s2,16(sp)
    80003992:	69a2                	ld	s3,8(sp)
    80003994:	6145                	addi	sp,sp,48
    80003996:	8082                	ret
      addr = balloc(ip->dev);
    80003998:	00092503          	lw	a0,0(s2)
    8000399c:	e5dff0ef          	jal	800037f8 <balloc>
    800039a0:	84aa                	mv	s1,a0
      if(addr){
    800039a2:	dd79                	beqz	a0,80003980 <bmap+0x82>
        a[bn] = addr;
    800039a4:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800039a8:	8552                	mv	a0,s4
    800039aa:	62d000ef          	jal	800047d6 <log_write>
    800039ae:	bfc9                	j	80003980 <bmap+0x82>
    800039b0:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800039b2:	00005517          	auipc	a0,0x5
    800039b6:	ed650513          	addi	a0,a0,-298 # 80008888 <etext+0x888>
    800039ba:	e6bfc0ef          	jal	80000824 <panic>

00000000800039be <iget>:
{
    800039be:	7179                	addi	sp,sp,-48
    800039c0:	f406                	sd	ra,40(sp)
    800039c2:	f022                	sd	s0,32(sp)
    800039c4:	ec26                	sd	s1,24(sp)
    800039c6:	e84a                	sd	s2,16(sp)
    800039c8:	e44e                	sd	s3,8(sp)
    800039ca:	e052                	sd	s4,0(sp)
    800039cc:	1800                	addi	s0,sp,48
    800039ce:	892a                	mv	s2,a0
    800039d0:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039d2:	0001f517          	auipc	a0,0x1f
    800039d6:	86e50513          	addi	a0,a0,-1938 # 80022240 <itable>
    800039da:	a4efd0ef          	jal	80000c28 <acquire>
  empty = 0;
    800039de:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039e0:	0001f497          	auipc	s1,0x1f
    800039e4:	87848493          	addi	s1,s1,-1928 # 80022258 <itable+0x18>
    800039e8:	00020697          	auipc	a3,0x20
    800039ec:	30068693          	addi	a3,a3,768 # 80023ce8 <log>
    800039f0:	a809                	j	80003a02 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039f2:	e781                	bnez	a5,800039fa <iget+0x3c>
    800039f4:	00099363          	bnez	s3,800039fa <iget+0x3c>
      empty = ip;
    800039f8:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039fa:	08848493          	addi	s1,s1,136
    800039fe:	02d48563          	beq	s1,a3,80003a28 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a02:	449c                	lw	a5,8(s1)
    80003a04:	fef057e3          	blez	a5,800039f2 <iget+0x34>
    80003a08:	4098                	lw	a4,0(s1)
    80003a0a:	ff2718e3          	bne	a4,s2,800039fa <iget+0x3c>
    80003a0e:	40d8                	lw	a4,4(s1)
    80003a10:	ff4715e3          	bne	a4,s4,800039fa <iget+0x3c>
      ip->ref++;
    80003a14:	2785                	addiw	a5,a5,1
    80003a16:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a18:	0001f517          	auipc	a0,0x1f
    80003a1c:	82850513          	addi	a0,a0,-2008 # 80022240 <itable>
    80003a20:	a9cfd0ef          	jal	80000cbc <release>
      return ip;
    80003a24:	89a6                	mv	s3,s1
    80003a26:	a015                	j	80003a4a <iget+0x8c>
  if(empty == 0)
    80003a28:	02098a63          	beqz	s3,80003a5c <iget+0x9e>
  ip->dev = dev;
    80003a2c:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003a30:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003a34:	4785                	li	a5,1
    80003a36:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003a3a:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003a3e:	0001f517          	auipc	a0,0x1f
    80003a42:	80250513          	addi	a0,a0,-2046 # 80022240 <itable>
    80003a46:	a76fd0ef          	jal	80000cbc <release>
}
    80003a4a:	854e                	mv	a0,s3
    80003a4c:	70a2                	ld	ra,40(sp)
    80003a4e:	7402                	ld	s0,32(sp)
    80003a50:	64e2                	ld	s1,24(sp)
    80003a52:	6942                	ld	s2,16(sp)
    80003a54:	69a2                	ld	s3,8(sp)
    80003a56:	6a02                	ld	s4,0(sp)
    80003a58:	6145                	addi	sp,sp,48
    80003a5a:	8082                	ret
    panic("iget: no inodes");
    80003a5c:	00005517          	auipc	a0,0x5
    80003a60:	e4450513          	addi	a0,a0,-444 # 800088a0 <etext+0x8a0>
    80003a64:	dc1fc0ef          	jal	80000824 <panic>

0000000080003a68 <iinit>:
{
    80003a68:	7179                	addi	sp,sp,-48
    80003a6a:	f406                	sd	ra,40(sp)
    80003a6c:	f022                	sd	s0,32(sp)
    80003a6e:	ec26                	sd	s1,24(sp)
    80003a70:	e84a                	sd	s2,16(sp)
    80003a72:	e44e                	sd	s3,8(sp)
    80003a74:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a76:	00005597          	auipc	a1,0x5
    80003a7a:	e3a58593          	addi	a1,a1,-454 # 800088b0 <etext+0x8b0>
    80003a7e:	0001e517          	auipc	a0,0x1e
    80003a82:	7c250513          	addi	a0,a0,1986 # 80022240 <itable>
    80003a86:	918fd0ef          	jal	80000b9e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a8a:	0001e497          	auipc	s1,0x1e
    80003a8e:	7de48493          	addi	s1,s1,2014 # 80022268 <itable+0x28>
    80003a92:	00020997          	auipc	s3,0x20
    80003a96:	26698993          	addi	s3,s3,614 # 80023cf8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a9a:	00005917          	auipc	s2,0x5
    80003a9e:	e1e90913          	addi	s2,s2,-482 # 800088b8 <etext+0x8b8>
    80003aa2:	85ca                	mv	a1,s2
    80003aa4:	8526                	mv	a0,s1
    80003aa6:	5f5000ef          	jal	8000489a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003aaa:	08848493          	addi	s1,s1,136
    80003aae:	ff349ae3          	bne	s1,s3,80003aa2 <iinit+0x3a>
}
    80003ab2:	70a2                	ld	ra,40(sp)
    80003ab4:	7402                	ld	s0,32(sp)
    80003ab6:	64e2                	ld	s1,24(sp)
    80003ab8:	6942                	ld	s2,16(sp)
    80003aba:	69a2                	ld	s3,8(sp)
    80003abc:	6145                	addi	sp,sp,48
    80003abe:	8082                	ret

0000000080003ac0 <ialloc>:
{
    80003ac0:	7139                	addi	sp,sp,-64
    80003ac2:	fc06                	sd	ra,56(sp)
    80003ac4:	f822                	sd	s0,48(sp)
    80003ac6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ac8:	0001e717          	auipc	a4,0x1e
    80003acc:	76472703          	lw	a4,1892(a4) # 8002222c <sb+0xc>
    80003ad0:	4785                	li	a5,1
    80003ad2:	06e7f063          	bgeu	a5,a4,80003b32 <ialloc+0x72>
    80003ad6:	f426                	sd	s1,40(sp)
    80003ad8:	f04a                	sd	s2,32(sp)
    80003ada:	ec4e                	sd	s3,24(sp)
    80003adc:	e852                	sd	s4,16(sp)
    80003ade:	e456                	sd	s5,8(sp)
    80003ae0:	e05a                	sd	s6,0(sp)
    80003ae2:	8aaa                	mv	s5,a0
    80003ae4:	8b2e                	mv	s6,a1
    80003ae6:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003ae8:	0001ea17          	auipc	s4,0x1e
    80003aec:	738a0a13          	addi	s4,s4,1848 # 80022220 <sb>
    80003af0:	00495593          	srli	a1,s2,0x4
    80003af4:	018a2783          	lw	a5,24(s4)
    80003af8:	9dbd                	addw	a1,a1,a5
    80003afa:	8556                	mv	a0,s5
    80003afc:	a9dff0ef          	jal	80003598 <bread>
    80003b00:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b02:	05850993          	addi	s3,a0,88
    80003b06:	00f97793          	andi	a5,s2,15
    80003b0a:	079a                	slli	a5,a5,0x6
    80003b0c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b0e:	00099783          	lh	a5,0(s3)
    80003b12:	cb9d                	beqz	a5,80003b48 <ialloc+0x88>
    brelse(bp);
    80003b14:	b8dff0ef          	jal	800036a0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b18:	0905                	addi	s2,s2,1
    80003b1a:	00ca2703          	lw	a4,12(s4)
    80003b1e:	0009079b          	sext.w	a5,s2
    80003b22:	fce7e7e3          	bltu	a5,a4,80003af0 <ialloc+0x30>
    80003b26:	74a2                	ld	s1,40(sp)
    80003b28:	7902                	ld	s2,32(sp)
    80003b2a:	69e2                	ld	s3,24(sp)
    80003b2c:	6a42                	ld	s4,16(sp)
    80003b2e:	6aa2                	ld	s5,8(sp)
    80003b30:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003b32:	00005517          	auipc	a0,0x5
    80003b36:	d8e50513          	addi	a0,a0,-626 # 800088c0 <etext+0x8c0>
    80003b3a:	9c1fc0ef          	jal	800004fa <printf>
  return 0;
    80003b3e:	4501                	li	a0,0
}
    80003b40:	70e2                	ld	ra,56(sp)
    80003b42:	7442                	ld	s0,48(sp)
    80003b44:	6121                	addi	sp,sp,64
    80003b46:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003b48:	04000613          	li	a2,64
    80003b4c:	4581                	li	a1,0
    80003b4e:	854e                	mv	a0,s3
    80003b50:	9a8fd0ef          	jal	80000cf8 <memset>
      dip->type = type;
    80003b54:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b58:	8526                	mv	a0,s1
    80003b5a:	47d000ef          	jal	800047d6 <log_write>
      brelse(bp);
    80003b5e:	8526                	mv	a0,s1
    80003b60:	b41ff0ef          	jal	800036a0 <brelse>
      return iget(dev, inum);
    80003b64:	0009059b          	sext.w	a1,s2
    80003b68:	8556                	mv	a0,s5
    80003b6a:	e55ff0ef          	jal	800039be <iget>
    80003b6e:	74a2                	ld	s1,40(sp)
    80003b70:	7902                	ld	s2,32(sp)
    80003b72:	69e2                	ld	s3,24(sp)
    80003b74:	6a42                	ld	s4,16(sp)
    80003b76:	6aa2                	ld	s5,8(sp)
    80003b78:	6b02                	ld	s6,0(sp)
    80003b7a:	b7d9                	j	80003b40 <ialloc+0x80>

0000000080003b7c <iupdate>:
{
    80003b7c:	1101                	addi	sp,sp,-32
    80003b7e:	ec06                	sd	ra,24(sp)
    80003b80:	e822                	sd	s0,16(sp)
    80003b82:	e426                	sd	s1,8(sp)
    80003b84:	e04a                	sd	s2,0(sp)
    80003b86:	1000                	addi	s0,sp,32
    80003b88:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b8a:	415c                	lw	a5,4(a0)
    80003b8c:	0047d79b          	srliw	a5,a5,0x4
    80003b90:	0001e597          	auipc	a1,0x1e
    80003b94:	6a85a583          	lw	a1,1704(a1) # 80022238 <sb+0x18>
    80003b98:	9dbd                	addw	a1,a1,a5
    80003b9a:	4108                	lw	a0,0(a0)
    80003b9c:	9fdff0ef          	jal	80003598 <bread>
    80003ba0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ba2:	05850793          	addi	a5,a0,88
    80003ba6:	40d8                	lw	a4,4(s1)
    80003ba8:	8b3d                	andi	a4,a4,15
    80003baa:	071a                	slli	a4,a4,0x6
    80003bac:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003bae:	04449703          	lh	a4,68(s1)
    80003bb2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003bb6:	04649703          	lh	a4,70(s1)
    80003bba:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003bbe:	04849703          	lh	a4,72(s1)
    80003bc2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003bc6:	04a49703          	lh	a4,74(s1)
    80003bca:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003bce:	44f8                	lw	a4,76(s1)
    80003bd0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003bd2:	03400613          	li	a2,52
    80003bd6:	05048593          	addi	a1,s1,80
    80003bda:	00c78513          	addi	a0,a5,12
    80003bde:	97afd0ef          	jal	80000d58 <memmove>
  log_write(bp);
    80003be2:	854a                	mv	a0,s2
    80003be4:	3f3000ef          	jal	800047d6 <log_write>
  brelse(bp);
    80003be8:	854a                	mv	a0,s2
    80003bea:	ab7ff0ef          	jal	800036a0 <brelse>
}
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	64a2                	ld	s1,8(sp)
    80003bf4:	6902                	ld	s2,0(sp)
    80003bf6:	6105                	addi	sp,sp,32
    80003bf8:	8082                	ret

0000000080003bfa <idup>:
{
    80003bfa:	1101                	addi	sp,sp,-32
    80003bfc:	ec06                	sd	ra,24(sp)
    80003bfe:	e822                	sd	s0,16(sp)
    80003c00:	e426                	sd	s1,8(sp)
    80003c02:	1000                	addi	s0,sp,32
    80003c04:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c06:	0001e517          	auipc	a0,0x1e
    80003c0a:	63a50513          	addi	a0,a0,1594 # 80022240 <itable>
    80003c0e:	81afd0ef          	jal	80000c28 <acquire>
  ip->ref++;
    80003c12:	449c                	lw	a5,8(s1)
    80003c14:	2785                	addiw	a5,a5,1
    80003c16:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c18:	0001e517          	auipc	a0,0x1e
    80003c1c:	62850513          	addi	a0,a0,1576 # 80022240 <itable>
    80003c20:	89cfd0ef          	jal	80000cbc <release>
}
    80003c24:	8526                	mv	a0,s1
    80003c26:	60e2                	ld	ra,24(sp)
    80003c28:	6442                	ld	s0,16(sp)
    80003c2a:	64a2                	ld	s1,8(sp)
    80003c2c:	6105                	addi	sp,sp,32
    80003c2e:	8082                	ret

0000000080003c30 <ilock>:
{
    80003c30:	1101                	addi	sp,sp,-32
    80003c32:	ec06                	sd	ra,24(sp)
    80003c34:	e822                	sd	s0,16(sp)
    80003c36:	e426                	sd	s1,8(sp)
    80003c38:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c3a:	cd19                	beqz	a0,80003c58 <ilock+0x28>
    80003c3c:	84aa                	mv	s1,a0
    80003c3e:	451c                	lw	a5,8(a0)
    80003c40:	00f05c63          	blez	a5,80003c58 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003c44:	0541                	addi	a0,a0,16
    80003c46:	48b000ef          	jal	800048d0 <acquiresleep>
  if(ip->valid == 0){
    80003c4a:	40bc                	lw	a5,64(s1)
    80003c4c:	cf89                	beqz	a5,80003c66 <ilock+0x36>
}
    80003c4e:	60e2                	ld	ra,24(sp)
    80003c50:	6442                	ld	s0,16(sp)
    80003c52:	64a2                	ld	s1,8(sp)
    80003c54:	6105                	addi	sp,sp,32
    80003c56:	8082                	ret
    80003c58:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003c5a:	00005517          	auipc	a0,0x5
    80003c5e:	c7e50513          	addi	a0,a0,-898 # 800088d8 <etext+0x8d8>
    80003c62:	bc3fc0ef          	jal	80000824 <panic>
    80003c66:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c68:	40dc                	lw	a5,4(s1)
    80003c6a:	0047d79b          	srliw	a5,a5,0x4
    80003c6e:	0001e597          	auipc	a1,0x1e
    80003c72:	5ca5a583          	lw	a1,1482(a1) # 80022238 <sb+0x18>
    80003c76:	9dbd                	addw	a1,a1,a5
    80003c78:	4088                	lw	a0,0(s1)
    80003c7a:	91fff0ef          	jal	80003598 <bread>
    80003c7e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c80:	05850593          	addi	a1,a0,88
    80003c84:	40dc                	lw	a5,4(s1)
    80003c86:	8bbd                	andi	a5,a5,15
    80003c88:	079a                	slli	a5,a5,0x6
    80003c8a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c8c:	00059783          	lh	a5,0(a1)
    80003c90:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c94:	00259783          	lh	a5,2(a1)
    80003c98:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c9c:	00459783          	lh	a5,4(a1)
    80003ca0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003ca4:	00659783          	lh	a5,6(a1)
    80003ca8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003cac:	459c                	lw	a5,8(a1)
    80003cae:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003cb0:	03400613          	li	a2,52
    80003cb4:	05b1                	addi	a1,a1,12
    80003cb6:	05048513          	addi	a0,s1,80
    80003cba:	89efd0ef          	jal	80000d58 <memmove>
    brelse(bp);
    80003cbe:	854a                	mv	a0,s2
    80003cc0:	9e1ff0ef          	jal	800036a0 <brelse>
    ip->valid = 1;
    80003cc4:	4785                	li	a5,1
    80003cc6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003cc8:	04449783          	lh	a5,68(s1)
    80003ccc:	c399                	beqz	a5,80003cd2 <ilock+0xa2>
    80003cce:	6902                	ld	s2,0(sp)
    80003cd0:	bfbd                	j	80003c4e <ilock+0x1e>
      panic("ilock: no type");
    80003cd2:	00005517          	auipc	a0,0x5
    80003cd6:	c0e50513          	addi	a0,a0,-1010 # 800088e0 <etext+0x8e0>
    80003cda:	b4bfc0ef          	jal	80000824 <panic>

0000000080003cde <iunlock>:
{
    80003cde:	1101                	addi	sp,sp,-32
    80003ce0:	ec06                	sd	ra,24(sp)
    80003ce2:	e822                	sd	s0,16(sp)
    80003ce4:	e426                	sd	s1,8(sp)
    80003ce6:	e04a                	sd	s2,0(sp)
    80003ce8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cea:	c505                	beqz	a0,80003d12 <iunlock+0x34>
    80003cec:	84aa                	mv	s1,a0
    80003cee:	01050913          	addi	s2,a0,16
    80003cf2:	854a                	mv	a0,s2
    80003cf4:	45b000ef          	jal	8000494e <holdingsleep>
    80003cf8:	cd09                	beqz	a0,80003d12 <iunlock+0x34>
    80003cfa:	449c                	lw	a5,8(s1)
    80003cfc:	00f05b63          	blez	a5,80003d12 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003d00:	854a                	mv	a0,s2
    80003d02:	415000ef          	jal	80004916 <releasesleep>
}
    80003d06:	60e2                	ld	ra,24(sp)
    80003d08:	6442                	ld	s0,16(sp)
    80003d0a:	64a2                	ld	s1,8(sp)
    80003d0c:	6902                	ld	s2,0(sp)
    80003d0e:	6105                	addi	sp,sp,32
    80003d10:	8082                	ret
    panic("iunlock");
    80003d12:	00005517          	auipc	a0,0x5
    80003d16:	bde50513          	addi	a0,a0,-1058 # 800088f0 <etext+0x8f0>
    80003d1a:	b0bfc0ef          	jal	80000824 <panic>

0000000080003d1e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d1e:	7179                	addi	sp,sp,-48
    80003d20:	f406                	sd	ra,40(sp)
    80003d22:	f022                	sd	s0,32(sp)
    80003d24:	ec26                	sd	s1,24(sp)
    80003d26:	e84a                	sd	s2,16(sp)
    80003d28:	e44e                	sd	s3,8(sp)
    80003d2a:	1800                	addi	s0,sp,48
    80003d2c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d2e:	05050493          	addi	s1,a0,80
    80003d32:	08050913          	addi	s2,a0,128
    80003d36:	a021                	j	80003d3e <itrunc+0x20>
    80003d38:	0491                	addi	s1,s1,4
    80003d3a:	01248b63          	beq	s1,s2,80003d50 <itrunc+0x32>
    if(ip->addrs[i]){
    80003d3e:	408c                	lw	a1,0(s1)
    80003d40:	dde5                	beqz	a1,80003d38 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003d42:	0009a503          	lw	a0,0(s3)
    80003d46:	a47ff0ef          	jal	8000378c <bfree>
      ip->addrs[i] = 0;
    80003d4a:	0004a023          	sw	zero,0(s1)
    80003d4e:	b7ed                	j	80003d38 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d50:	0809a583          	lw	a1,128(s3)
    80003d54:	ed89                	bnez	a1,80003d6e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d56:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d5a:	854e                	mv	a0,s3
    80003d5c:	e21ff0ef          	jal	80003b7c <iupdate>
}
    80003d60:	70a2                	ld	ra,40(sp)
    80003d62:	7402                	ld	s0,32(sp)
    80003d64:	64e2                	ld	s1,24(sp)
    80003d66:	6942                	ld	s2,16(sp)
    80003d68:	69a2                	ld	s3,8(sp)
    80003d6a:	6145                	addi	sp,sp,48
    80003d6c:	8082                	ret
    80003d6e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d70:	0009a503          	lw	a0,0(s3)
    80003d74:	825ff0ef          	jal	80003598 <bread>
    80003d78:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d7a:	05850493          	addi	s1,a0,88
    80003d7e:	45850913          	addi	s2,a0,1112
    80003d82:	a021                	j	80003d8a <itrunc+0x6c>
    80003d84:	0491                	addi	s1,s1,4
    80003d86:	01248963          	beq	s1,s2,80003d98 <itrunc+0x7a>
      if(a[j])
    80003d8a:	408c                	lw	a1,0(s1)
    80003d8c:	dde5                	beqz	a1,80003d84 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003d8e:	0009a503          	lw	a0,0(s3)
    80003d92:	9fbff0ef          	jal	8000378c <bfree>
    80003d96:	b7fd                	j	80003d84 <itrunc+0x66>
    brelse(bp);
    80003d98:	8552                	mv	a0,s4
    80003d9a:	907ff0ef          	jal	800036a0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d9e:	0809a583          	lw	a1,128(s3)
    80003da2:	0009a503          	lw	a0,0(s3)
    80003da6:	9e7ff0ef          	jal	8000378c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003daa:	0809a023          	sw	zero,128(s3)
    80003dae:	6a02                	ld	s4,0(sp)
    80003db0:	b75d                	j	80003d56 <itrunc+0x38>

0000000080003db2 <iput>:
{
    80003db2:	1101                	addi	sp,sp,-32
    80003db4:	ec06                	sd	ra,24(sp)
    80003db6:	e822                	sd	s0,16(sp)
    80003db8:	e426                	sd	s1,8(sp)
    80003dba:	1000                	addi	s0,sp,32
    80003dbc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003dbe:	0001e517          	auipc	a0,0x1e
    80003dc2:	48250513          	addi	a0,a0,1154 # 80022240 <itable>
    80003dc6:	e63fc0ef          	jal	80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dca:	4498                	lw	a4,8(s1)
    80003dcc:	4785                	li	a5,1
    80003dce:	02f70063          	beq	a4,a5,80003dee <iput+0x3c>
  ip->ref--;
    80003dd2:	449c                	lw	a5,8(s1)
    80003dd4:	37fd                	addiw	a5,a5,-1
    80003dd6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dd8:	0001e517          	auipc	a0,0x1e
    80003ddc:	46850513          	addi	a0,a0,1128 # 80022240 <itable>
    80003de0:	eddfc0ef          	jal	80000cbc <release>
}
    80003de4:	60e2                	ld	ra,24(sp)
    80003de6:	6442                	ld	s0,16(sp)
    80003de8:	64a2                	ld	s1,8(sp)
    80003dea:	6105                	addi	sp,sp,32
    80003dec:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dee:	40bc                	lw	a5,64(s1)
    80003df0:	d3ed                	beqz	a5,80003dd2 <iput+0x20>
    80003df2:	04a49783          	lh	a5,74(s1)
    80003df6:	fff1                	bnez	a5,80003dd2 <iput+0x20>
    80003df8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003dfa:	01048793          	addi	a5,s1,16
    80003dfe:	893e                	mv	s2,a5
    80003e00:	853e                	mv	a0,a5
    80003e02:	2cf000ef          	jal	800048d0 <acquiresleep>
    release(&itable.lock);
    80003e06:	0001e517          	auipc	a0,0x1e
    80003e0a:	43a50513          	addi	a0,a0,1082 # 80022240 <itable>
    80003e0e:	eaffc0ef          	jal	80000cbc <release>
    itrunc(ip);
    80003e12:	8526                	mv	a0,s1
    80003e14:	f0bff0ef          	jal	80003d1e <itrunc>
    ip->type = 0;
    80003e18:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e1c:	8526                	mv	a0,s1
    80003e1e:	d5fff0ef          	jal	80003b7c <iupdate>
    ip->valid = 0;
    80003e22:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e26:	854a                	mv	a0,s2
    80003e28:	2ef000ef          	jal	80004916 <releasesleep>
    acquire(&itable.lock);
    80003e2c:	0001e517          	auipc	a0,0x1e
    80003e30:	41450513          	addi	a0,a0,1044 # 80022240 <itable>
    80003e34:	df5fc0ef          	jal	80000c28 <acquire>
    80003e38:	6902                	ld	s2,0(sp)
    80003e3a:	bf61                	j	80003dd2 <iput+0x20>

0000000080003e3c <iunlockput>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	addi	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e48:	e97ff0ef          	jal	80003cde <iunlock>
  iput(ip);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	f65ff0ef          	jal	80003db2 <iput>
}
    80003e52:	60e2                	ld	ra,24(sp)
    80003e54:	6442                	ld	s0,16(sp)
    80003e56:	64a2                	ld	s1,8(sp)
    80003e58:	6105                	addi	sp,sp,32
    80003e5a:	8082                	ret

0000000080003e5c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e5c:	0001e717          	auipc	a4,0x1e
    80003e60:	3d072703          	lw	a4,976(a4) # 8002222c <sb+0xc>
    80003e64:	4785                	li	a5,1
    80003e66:	0ae7fe63          	bgeu	a5,a4,80003f22 <ireclaim+0xc6>
{
    80003e6a:	7139                	addi	sp,sp,-64
    80003e6c:	fc06                	sd	ra,56(sp)
    80003e6e:	f822                	sd	s0,48(sp)
    80003e70:	f426                	sd	s1,40(sp)
    80003e72:	f04a                	sd	s2,32(sp)
    80003e74:	ec4e                	sd	s3,24(sp)
    80003e76:	e852                	sd	s4,16(sp)
    80003e78:	e456                	sd	s5,8(sp)
    80003e7a:	e05a                	sd	s6,0(sp)
    80003e7c:	0080                	addi	s0,sp,64
    80003e7e:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003e80:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003e82:	0001ea17          	auipc	s4,0x1e
    80003e86:	39ea0a13          	addi	s4,s4,926 # 80022220 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003e8a:	00005b17          	auipc	s6,0x5
    80003e8e:	a6eb0b13          	addi	s6,s6,-1426 # 800088f8 <etext+0x8f8>
    80003e92:	a099                	j	80003ed8 <ireclaim+0x7c>
    80003e94:	85ce                	mv	a1,s3
    80003e96:	855a                	mv	a0,s6
    80003e98:	e62fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003e9c:	85ce                	mv	a1,s3
    80003e9e:	8556                	mv	a0,s5
    80003ea0:	b1fff0ef          	jal	800039be <iget>
    80003ea4:	89aa                	mv	s3,a0
    brelse(bp);
    80003ea6:	854a                	mv	a0,s2
    80003ea8:	ff8ff0ef          	jal	800036a0 <brelse>
    if (ip) {
    80003eac:	00098f63          	beqz	s3,80003eca <ireclaim+0x6e>
      begin_op();
    80003eb0:	78c000ef          	jal	8000463c <begin_op>
      ilock(ip);
    80003eb4:	854e                	mv	a0,s3
    80003eb6:	d7bff0ef          	jal	80003c30 <ilock>
      iunlock(ip);
    80003eba:	854e                	mv	a0,s3
    80003ebc:	e23ff0ef          	jal	80003cde <iunlock>
      iput(ip);
    80003ec0:	854e                	mv	a0,s3
    80003ec2:	ef1ff0ef          	jal	80003db2 <iput>
      end_op();
    80003ec6:	7e6000ef          	jal	800046ac <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003eca:	0485                	addi	s1,s1,1
    80003ecc:	00ca2703          	lw	a4,12(s4)
    80003ed0:	0004879b          	sext.w	a5,s1
    80003ed4:	02e7fd63          	bgeu	a5,a4,80003f0e <ireclaim+0xb2>
    80003ed8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003edc:	0044d593          	srli	a1,s1,0x4
    80003ee0:	018a2783          	lw	a5,24(s4)
    80003ee4:	9dbd                	addw	a1,a1,a5
    80003ee6:	8556                	mv	a0,s5
    80003ee8:	eb0ff0ef          	jal	80003598 <bread>
    80003eec:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003eee:	05850793          	addi	a5,a0,88
    80003ef2:	00f9f713          	andi	a4,s3,15
    80003ef6:	071a                	slli	a4,a4,0x6
    80003ef8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003efa:	00079703          	lh	a4,0(a5)
    80003efe:	c701                	beqz	a4,80003f06 <ireclaim+0xaa>
    80003f00:	00679783          	lh	a5,6(a5)
    80003f04:	dbc1                	beqz	a5,80003e94 <ireclaim+0x38>
    brelse(bp);
    80003f06:	854a                	mv	a0,s2
    80003f08:	f98ff0ef          	jal	800036a0 <brelse>
    if (ip) {
    80003f0c:	bf7d                	j	80003eca <ireclaim+0x6e>
}
    80003f0e:	70e2                	ld	ra,56(sp)
    80003f10:	7442                	ld	s0,48(sp)
    80003f12:	74a2                	ld	s1,40(sp)
    80003f14:	7902                	ld	s2,32(sp)
    80003f16:	69e2                	ld	s3,24(sp)
    80003f18:	6a42                	ld	s4,16(sp)
    80003f1a:	6aa2                	ld	s5,8(sp)
    80003f1c:	6b02                	ld	s6,0(sp)
    80003f1e:	6121                	addi	sp,sp,64
    80003f20:	8082                	ret
    80003f22:	8082                	ret

0000000080003f24 <fsinit>:
fsinit(int dev) {
    80003f24:	1101                	addi	sp,sp,-32
    80003f26:	ec06                	sd	ra,24(sp)
    80003f28:	e822                	sd	s0,16(sp)
    80003f2a:	e426                	sd	s1,8(sp)
    80003f2c:	e04a                	sd	s2,0(sp)
    80003f2e:	1000                	addi	s0,sp,32
    80003f30:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f32:	4585                	li	a1,1
    80003f34:	e64ff0ef          	jal	80003598 <bread>
    80003f38:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f3a:	02000613          	li	a2,32
    80003f3e:	05850593          	addi	a1,a0,88
    80003f42:	0001e517          	auipc	a0,0x1e
    80003f46:	2de50513          	addi	a0,a0,734 # 80022220 <sb>
    80003f4a:	e0ffc0ef          	jal	80000d58 <memmove>
  brelse(bp);
    80003f4e:	8526                	mv	a0,s1
    80003f50:	f50ff0ef          	jal	800036a0 <brelse>
  if(sb.magic != FSMAGIC)
    80003f54:	0001e717          	auipc	a4,0x1e
    80003f58:	2cc72703          	lw	a4,716(a4) # 80022220 <sb>
    80003f5c:	102037b7          	lui	a5,0x10203
    80003f60:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003f64:	02f71263          	bne	a4,a5,80003f88 <fsinit+0x64>
  initlog(dev, &sb);
    80003f68:	0001e597          	auipc	a1,0x1e
    80003f6c:	2b858593          	addi	a1,a1,696 # 80022220 <sb>
    80003f70:	854a                	mv	a0,s2
    80003f72:	648000ef          	jal	800045ba <initlog>
  ireclaim(dev);
    80003f76:	854a                	mv	a0,s2
    80003f78:	ee5ff0ef          	jal	80003e5c <ireclaim>
}
    80003f7c:	60e2                	ld	ra,24(sp)
    80003f7e:	6442                	ld	s0,16(sp)
    80003f80:	64a2                	ld	s1,8(sp)
    80003f82:	6902                	ld	s2,0(sp)
    80003f84:	6105                	addi	sp,sp,32
    80003f86:	8082                	ret
    panic("invalid file system");
    80003f88:	00005517          	auipc	a0,0x5
    80003f8c:	99050513          	addi	a0,a0,-1648 # 80008918 <etext+0x918>
    80003f90:	895fc0ef          	jal	80000824 <panic>

0000000080003f94 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f94:	1141                	addi	sp,sp,-16
    80003f96:	e406                	sd	ra,8(sp)
    80003f98:	e022                	sd	s0,0(sp)
    80003f9a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f9c:	411c                	lw	a5,0(a0)
    80003f9e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fa0:	415c                	lw	a5,4(a0)
    80003fa2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fa4:	04451783          	lh	a5,68(a0)
    80003fa8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fac:	04a51783          	lh	a5,74(a0)
    80003fb0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fb4:	04c56783          	lwu	a5,76(a0)
    80003fb8:	e99c                	sd	a5,16(a1)
}
    80003fba:	60a2                	ld	ra,8(sp)
    80003fbc:	6402                	ld	s0,0(sp)
    80003fbe:	0141                	addi	sp,sp,16
    80003fc0:	8082                	ret

0000000080003fc2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fc2:	457c                	lw	a5,76(a0)
    80003fc4:	0ed7e663          	bltu	a5,a3,800040b0 <readi+0xee>
{
    80003fc8:	7159                	addi	sp,sp,-112
    80003fca:	f486                	sd	ra,104(sp)
    80003fcc:	f0a2                	sd	s0,96(sp)
    80003fce:	eca6                	sd	s1,88(sp)
    80003fd0:	e0d2                	sd	s4,64(sp)
    80003fd2:	fc56                	sd	s5,56(sp)
    80003fd4:	f85a                	sd	s6,48(sp)
    80003fd6:	f45e                	sd	s7,40(sp)
    80003fd8:	1880                	addi	s0,sp,112
    80003fda:	8b2a                	mv	s6,a0
    80003fdc:	8bae                	mv	s7,a1
    80003fde:	8a32                	mv	s4,a2
    80003fe0:	84b6                	mv	s1,a3
    80003fe2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fe4:	9f35                	addw	a4,a4,a3
    return 0;
    80003fe6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fe8:	0ad76b63          	bltu	a4,a3,8000409e <readi+0xdc>
    80003fec:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003fee:	00e7f463          	bgeu	a5,a4,80003ff6 <readi+0x34>
    n = ip->size - off;
    80003ff2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ff6:	080a8b63          	beqz	s5,8000408c <readi+0xca>
    80003ffa:	e8ca                	sd	s2,80(sp)
    80003ffc:	f062                	sd	s8,32(sp)
    80003ffe:	ec66                	sd	s9,24(sp)
    80004000:	e86a                	sd	s10,16(sp)
    80004002:	e46e                	sd	s11,8(sp)
    80004004:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004006:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000400a:	5c7d                	li	s8,-1
    8000400c:	a80d                	j	8000403e <readi+0x7c>
    8000400e:	020d1d93          	slli	s11,s10,0x20
    80004012:	020ddd93          	srli	s11,s11,0x20
    80004016:	05890613          	addi	a2,s2,88
    8000401a:	86ee                	mv	a3,s11
    8000401c:	963e                	add	a2,a2,a5
    8000401e:	85d2                	mv	a1,s4
    80004020:	855e                	mv	a0,s7
    80004022:	a63fe0ef          	jal	80002a84 <either_copyout>
    80004026:	05850363          	beq	a0,s8,8000406c <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000402a:	854a                	mv	a0,s2
    8000402c:	e74ff0ef          	jal	800036a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004030:	013d09bb          	addw	s3,s10,s3
    80004034:	009d04bb          	addw	s1,s10,s1
    80004038:	9a6e                	add	s4,s4,s11
    8000403a:	0559f363          	bgeu	s3,s5,80004080 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000403e:	00a4d59b          	srliw	a1,s1,0xa
    80004042:	855a                	mv	a0,s6
    80004044:	8bbff0ef          	jal	800038fe <bmap>
    80004048:	85aa                	mv	a1,a0
    if(addr == 0)
    8000404a:	c139                	beqz	a0,80004090 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000404c:	000b2503          	lw	a0,0(s6)
    80004050:	d48ff0ef          	jal	80003598 <bread>
    80004054:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004056:	3ff4f793          	andi	a5,s1,1023
    8000405a:	40fc873b          	subw	a4,s9,a5
    8000405e:	413a86bb          	subw	a3,s5,s3
    80004062:	8d3a                	mv	s10,a4
    80004064:	fae6f5e3          	bgeu	a3,a4,8000400e <readi+0x4c>
    80004068:	8d36                	mv	s10,a3
    8000406a:	b755                	j	8000400e <readi+0x4c>
      brelse(bp);
    8000406c:	854a                	mv	a0,s2
    8000406e:	e32ff0ef          	jal	800036a0 <brelse>
      tot = -1;
    80004072:	59fd                	li	s3,-1
      break;
    80004074:	6946                	ld	s2,80(sp)
    80004076:	7c02                	ld	s8,32(sp)
    80004078:	6ce2                	ld	s9,24(sp)
    8000407a:	6d42                	ld	s10,16(sp)
    8000407c:	6da2                	ld	s11,8(sp)
    8000407e:	a831                	j	8000409a <readi+0xd8>
    80004080:	6946                	ld	s2,80(sp)
    80004082:	7c02                	ld	s8,32(sp)
    80004084:	6ce2                	ld	s9,24(sp)
    80004086:	6d42                	ld	s10,16(sp)
    80004088:	6da2                	ld	s11,8(sp)
    8000408a:	a801                	j	8000409a <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000408c:	89d6                	mv	s3,s5
    8000408e:	a031                	j	8000409a <readi+0xd8>
    80004090:	6946                	ld	s2,80(sp)
    80004092:	7c02                	ld	s8,32(sp)
    80004094:	6ce2                	ld	s9,24(sp)
    80004096:	6d42                	ld	s10,16(sp)
    80004098:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000409a:	854e                	mv	a0,s3
    8000409c:	69a6                	ld	s3,72(sp)
}
    8000409e:	70a6                	ld	ra,104(sp)
    800040a0:	7406                	ld	s0,96(sp)
    800040a2:	64e6                	ld	s1,88(sp)
    800040a4:	6a06                	ld	s4,64(sp)
    800040a6:	7ae2                	ld	s5,56(sp)
    800040a8:	7b42                	ld	s6,48(sp)
    800040aa:	7ba2                	ld	s7,40(sp)
    800040ac:	6165                	addi	sp,sp,112
    800040ae:	8082                	ret
    return 0;
    800040b0:	4501                	li	a0,0
}
    800040b2:	8082                	ret

00000000800040b4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040b4:	457c                	lw	a5,76(a0)
    800040b6:	0ed7eb63          	bltu	a5,a3,800041ac <writei+0xf8>
{
    800040ba:	7159                	addi	sp,sp,-112
    800040bc:	f486                	sd	ra,104(sp)
    800040be:	f0a2                	sd	s0,96(sp)
    800040c0:	e8ca                	sd	s2,80(sp)
    800040c2:	e0d2                	sd	s4,64(sp)
    800040c4:	fc56                	sd	s5,56(sp)
    800040c6:	f85a                	sd	s6,48(sp)
    800040c8:	f45e                	sd	s7,40(sp)
    800040ca:	1880                	addi	s0,sp,112
    800040cc:	8aaa                	mv	s5,a0
    800040ce:	8bae                	mv	s7,a1
    800040d0:	8a32                	mv	s4,a2
    800040d2:	8936                	mv	s2,a3
    800040d4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040d6:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040da:	00043737          	lui	a4,0x43
    800040de:	0cf76963          	bltu	a4,a5,800041b0 <writei+0xfc>
    800040e2:	0cd7e763          	bltu	a5,a3,800041b0 <writei+0xfc>
    800040e6:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040e8:	0a0b0a63          	beqz	s6,8000419c <writei+0xe8>
    800040ec:	eca6                	sd	s1,88(sp)
    800040ee:	f062                	sd	s8,32(sp)
    800040f0:	ec66                	sd	s9,24(sp)
    800040f2:	e86a                	sd	s10,16(sp)
    800040f4:	e46e                	sd	s11,8(sp)
    800040f6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040f8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040fc:	5c7d                	li	s8,-1
    800040fe:	a825                	j	80004136 <writei+0x82>
    80004100:	020d1d93          	slli	s11,s10,0x20
    80004104:	020ddd93          	srli	s11,s11,0x20
    80004108:	05848513          	addi	a0,s1,88
    8000410c:	86ee                	mv	a3,s11
    8000410e:	8652                	mv	a2,s4
    80004110:	85de                	mv	a1,s7
    80004112:	953e                	add	a0,a0,a5
    80004114:	9bbfe0ef          	jal	80002ace <either_copyin>
    80004118:	05850663          	beq	a0,s8,80004164 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000411c:	8526                	mv	a0,s1
    8000411e:	6b8000ef          	jal	800047d6 <log_write>
    brelse(bp);
    80004122:	8526                	mv	a0,s1
    80004124:	d7cff0ef          	jal	800036a0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004128:	013d09bb          	addw	s3,s10,s3
    8000412c:	012d093b          	addw	s2,s10,s2
    80004130:	9a6e                	add	s4,s4,s11
    80004132:	0369fc63          	bgeu	s3,s6,8000416a <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80004136:	00a9559b          	srliw	a1,s2,0xa
    8000413a:	8556                	mv	a0,s5
    8000413c:	fc2ff0ef          	jal	800038fe <bmap>
    80004140:	85aa                	mv	a1,a0
    if(addr == 0)
    80004142:	c505                	beqz	a0,8000416a <writei+0xb6>
    bp = bread(ip->dev, addr);
    80004144:	000aa503          	lw	a0,0(s5)
    80004148:	c50ff0ef          	jal	80003598 <bread>
    8000414c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000414e:	3ff97793          	andi	a5,s2,1023
    80004152:	40fc873b          	subw	a4,s9,a5
    80004156:	413b06bb          	subw	a3,s6,s3
    8000415a:	8d3a                	mv	s10,a4
    8000415c:	fae6f2e3          	bgeu	a3,a4,80004100 <writei+0x4c>
    80004160:	8d36                	mv	s10,a3
    80004162:	bf79                	j	80004100 <writei+0x4c>
      brelse(bp);
    80004164:	8526                	mv	a0,s1
    80004166:	d3aff0ef          	jal	800036a0 <brelse>
  }

  if(off > ip->size)
    8000416a:	04caa783          	lw	a5,76(s5)
    8000416e:	0327f963          	bgeu	a5,s2,800041a0 <writei+0xec>
    ip->size = off;
    80004172:	052aa623          	sw	s2,76(s5)
    80004176:	64e6                	ld	s1,88(sp)
    80004178:	7c02                	ld	s8,32(sp)
    8000417a:	6ce2                	ld	s9,24(sp)
    8000417c:	6d42                	ld	s10,16(sp)
    8000417e:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004180:	8556                	mv	a0,s5
    80004182:	9fbff0ef          	jal	80003b7c <iupdate>

  return tot;
    80004186:	854e                	mv	a0,s3
    80004188:	69a6                	ld	s3,72(sp)
}
    8000418a:	70a6                	ld	ra,104(sp)
    8000418c:	7406                	ld	s0,96(sp)
    8000418e:	6946                	ld	s2,80(sp)
    80004190:	6a06                	ld	s4,64(sp)
    80004192:	7ae2                	ld	s5,56(sp)
    80004194:	7b42                	ld	s6,48(sp)
    80004196:	7ba2                	ld	s7,40(sp)
    80004198:	6165                	addi	sp,sp,112
    8000419a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000419c:	89da                	mv	s3,s6
    8000419e:	b7cd                	j	80004180 <writei+0xcc>
    800041a0:	64e6                	ld	s1,88(sp)
    800041a2:	7c02                	ld	s8,32(sp)
    800041a4:	6ce2                	ld	s9,24(sp)
    800041a6:	6d42                	ld	s10,16(sp)
    800041a8:	6da2                	ld	s11,8(sp)
    800041aa:	bfd9                	j	80004180 <writei+0xcc>
    return -1;
    800041ac:	557d                	li	a0,-1
}
    800041ae:	8082                	ret
    return -1;
    800041b0:	557d                	li	a0,-1
    800041b2:	bfe1                	j	8000418a <writei+0xd6>

00000000800041b4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041b4:	1141                	addi	sp,sp,-16
    800041b6:	e406                	sd	ra,8(sp)
    800041b8:	e022                	sd	s0,0(sp)
    800041ba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041bc:	4639                	li	a2,14
    800041be:	c0ffc0ef          	jal	80000dcc <strncmp>
}
    800041c2:	60a2                	ld	ra,8(sp)
    800041c4:	6402                	ld	s0,0(sp)
    800041c6:	0141                	addi	sp,sp,16
    800041c8:	8082                	ret

00000000800041ca <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041ca:	711d                	addi	sp,sp,-96
    800041cc:	ec86                	sd	ra,88(sp)
    800041ce:	e8a2                	sd	s0,80(sp)
    800041d0:	e4a6                	sd	s1,72(sp)
    800041d2:	e0ca                	sd	s2,64(sp)
    800041d4:	fc4e                	sd	s3,56(sp)
    800041d6:	f852                	sd	s4,48(sp)
    800041d8:	f456                	sd	s5,40(sp)
    800041da:	f05a                	sd	s6,32(sp)
    800041dc:	ec5e                	sd	s7,24(sp)
    800041de:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041e0:	04451703          	lh	a4,68(a0)
    800041e4:	4785                	li	a5,1
    800041e6:	00f71f63          	bne	a4,a5,80004204 <dirlookup+0x3a>
    800041ea:	892a                	mv	s2,a0
    800041ec:	8aae                	mv	s5,a1
    800041ee:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f0:	457c                	lw	a5,76(a0)
    800041f2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041f4:	fa040a13          	addi	s4,s0,-96
    800041f8:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800041fa:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041fe:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004200:	e39d                	bnez	a5,80004226 <dirlookup+0x5c>
    80004202:	a8b9                	j	80004260 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80004204:	00004517          	auipc	a0,0x4
    80004208:	72c50513          	addi	a0,a0,1836 # 80008930 <etext+0x930>
    8000420c:	e18fc0ef          	jal	80000824 <panic>
      panic("dirlookup read");
    80004210:	00004517          	auipc	a0,0x4
    80004214:	73850513          	addi	a0,a0,1848 # 80008948 <etext+0x948>
    80004218:	e0cfc0ef          	jal	80000824 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000421c:	24c1                	addiw	s1,s1,16
    8000421e:	04c92783          	lw	a5,76(s2)
    80004222:	02f4fe63          	bgeu	s1,a5,8000425e <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004226:	874e                	mv	a4,s3
    80004228:	86a6                	mv	a3,s1
    8000422a:	8652                	mv	a2,s4
    8000422c:	4581                	li	a1,0
    8000422e:	854a                	mv	a0,s2
    80004230:	d93ff0ef          	jal	80003fc2 <readi>
    80004234:	fd351ee3          	bne	a0,s3,80004210 <dirlookup+0x46>
    if(de.inum == 0)
    80004238:	fa045783          	lhu	a5,-96(s0)
    8000423c:	d3e5                	beqz	a5,8000421c <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    8000423e:	85da                	mv	a1,s6
    80004240:	8556                	mv	a0,s5
    80004242:	f73ff0ef          	jal	800041b4 <namecmp>
    80004246:	f979                	bnez	a0,8000421c <dirlookup+0x52>
      if(poff)
    80004248:	000b8463          	beqz	s7,80004250 <dirlookup+0x86>
        *poff = off;
    8000424c:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80004250:	fa045583          	lhu	a1,-96(s0)
    80004254:	00092503          	lw	a0,0(s2)
    80004258:	f66ff0ef          	jal	800039be <iget>
    8000425c:	a011                	j	80004260 <dirlookup+0x96>
  return 0;
    8000425e:	4501                	li	a0,0
}
    80004260:	60e6                	ld	ra,88(sp)
    80004262:	6446                	ld	s0,80(sp)
    80004264:	64a6                	ld	s1,72(sp)
    80004266:	6906                	ld	s2,64(sp)
    80004268:	79e2                	ld	s3,56(sp)
    8000426a:	7a42                	ld	s4,48(sp)
    8000426c:	7aa2                	ld	s5,40(sp)
    8000426e:	7b02                	ld	s6,32(sp)
    80004270:	6be2                	ld	s7,24(sp)
    80004272:	6125                	addi	sp,sp,96
    80004274:	8082                	ret

0000000080004276 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004276:	711d                	addi	sp,sp,-96
    80004278:	ec86                	sd	ra,88(sp)
    8000427a:	e8a2                	sd	s0,80(sp)
    8000427c:	e4a6                	sd	s1,72(sp)
    8000427e:	e0ca                	sd	s2,64(sp)
    80004280:	fc4e                	sd	s3,56(sp)
    80004282:	f852                	sd	s4,48(sp)
    80004284:	f456                	sd	s5,40(sp)
    80004286:	f05a                	sd	s6,32(sp)
    80004288:	ec5e                	sd	s7,24(sp)
    8000428a:	e862                	sd	s8,16(sp)
    8000428c:	e466                	sd	s9,8(sp)
    8000428e:	e06a                	sd	s10,0(sp)
    80004290:	1080                	addi	s0,sp,96
    80004292:	84aa                	mv	s1,a0
    80004294:	8b2e                	mv	s6,a1
    80004296:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004298:	00054703          	lbu	a4,0(a0)
    8000429c:	02f00793          	li	a5,47
    800042a0:	00f70f63          	beq	a4,a5,800042be <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042a4:	813fd0ef          	jal	80001ab6 <myproc>
    800042a8:	15853503          	ld	a0,344(a0)
    800042ac:	94fff0ef          	jal	80003bfa <idup>
    800042b0:	8a2a                	mv	s4,a0
  while(*path == '/')
    800042b2:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    800042b6:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    800042b8:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042ba:	4b85                	li	s7,1
    800042bc:	a879                	j	8000435a <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    800042be:	4585                	li	a1,1
    800042c0:	852e                	mv	a0,a1
    800042c2:	efcff0ef          	jal	800039be <iget>
    800042c6:	8a2a                	mv	s4,a0
    800042c8:	b7ed                	j	800042b2 <namex+0x3c>
      iunlockput(ip);
    800042ca:	8552                	mv	a0,s4
    800042cc:	b71ff0ef          	jal	80003e3c <iunlockput>
      return 0;
    800042d0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042d2:	8552                	mv	a0,s4
    800042d4:	60e6                	ld	ra,88(sp)
    800042d6:	6446                	ld	s0,80(sp)
    800042d8:	64a6                	ld	s1,72(sp)
    800042da:	6906                	ld	s2,64(sp)
    800042dc:	79e2                	ld	s3,56(sp)
    800042de:	7a42                	ld	s4,48(sp)
    800042e0:	7aa2                	ld	s5,40(sp)
    800042e2:	7b02                	ld	s6,32(sp)
    800042e4:	6be2                	ld	s7,24(sp)
    800042e6:	6c42                	ld	s8,16(sp)
    800042e8:	6ca2                	ld	s9,8(sp)
    800042ea:	6d02                	ld	s10,0(sp)
    800042ec:	6125                	addi	sp,sp,96
    800042ee:	8082                	ret
      iunlock(ip);
    800042f0:	8552                	mv	a0,s4
    800042f2:	9edff0ef          	jal	80003cde <iunlock>
      return ip;
    800042f6:	bff1                	j	800042d2 <namex+0x5c>
      iunlockput(ip);
    800042f8:	8552                	mv	a0,s4
    800042fa:	b43ff0ef          	jal	80003e3c <iunlockput>
      return 0;
    800042fe:	8a4a                	mv	s4,s2
    80004300:	bfc9                	j	800042d2 <namex+0x5c>
  len = path - s;
    80004302:	40990633          	sub	a2,s2,s1
    80004306:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000430a:	09ac5463          	bge	s8,s10,80004392 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    8000430e:	8666                	mv	a2,s9
    80004310:	85a6                	mv	a1,s1
    80004312:	8556                	mv	a0,s5
    80004314:	a45fc0ef          	jal	80000d58 <memmove>
    80004318:	84ca                	mv	s1,s2
  while(*path == '/')
    8000431a:	0004c783          	lbu	a5,0(s1)
    8000431e:	01379763          	bne	a5,s3,8000432c <namex+0xb6>
    path++;
    80004322:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004324:	0004c783          	lbu	a5,0(s1)
    80004328:	ff378de3          	beq	a5,s3,80004322 <namex+0xac>
    ilock(ip);
    8000432c:	8552                	mv	a0,s4
    8000432e:	903ff0ef          	jal	80003c30 <ilock>
    if(ip->type != T_DIR){
    80004332:	044a1783          	lh	a5,68(s4)
    80004336:	f9779ae3          	bne	a5,s7,800042ca <namex+0x54>
    if(nameiparent && *path == '\0'){
    8000433a:	000b0563          	beqz	s6,80004344 <namex+0xce>
    8000433e:	0004c783          	lbu	a5,0(s1)
    80004342:	d7dd                	beqz	a5,800042f0 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004344:	4601                	li	a2,0
    80004346:	85d6                	mv	a1,s5
    80004348:	8552                	mv	a0,s4
    8000434a:	e81ff0ef          	jal	800041ca <dirlookup>
    8000434e:	892a                	mv	s2,a0
    80004350:	d545                	beqz	a0,800042f8 <namex+0x82>
    iunlockput(ip);
    80004352:	8552                	mv	a0,s4
    80004354:	ae9ff0ef          	jal	80003e3c <iunlockput>
    ip = next;
    80004358:	8a4a                	mv	s4,s2
  while(*path == '/')
    8000435a:	0004c783          	lbu	a5,0(s1)
    8000435e:	01379763          	bne	a5,s3,8000436c <namex+0xf6>
    path++;
    80004362:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004364:	0004c783          	lbu	a5,0(s1)
    80004368:	ff378de3          	beq	a5,s3,80004362 <namex+0xec>
  if(*path == 0)
    8000436c:	cf8d                	beqz	a5,800043a6 <namex+0x130>
  while(*path != '/' && *path != 0)
    8000436e:	0004c783          	lbu	a5,0(s1)
    80004372:	fd178713          	addi	a4,a5,-47
    80004376:	cb19                	beqz	a4,8000438c <namex+0x116>
    80004378:	cb91                	beqz	a5,8000438c <namex+0x116>
    8000437a:	8926                	mv	s2,s1
    path++;
    8000437c:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    8000437e:	00094783          	lbu	a5,0(s2)
    80004382:	fd178713          	addi	a4,a5,-47
    80004386:	df35                	beqz	a4,80004302 <namex+0x8c>
    80004388:	fbf5                	bnez	a5,8000437c <namex+0x106>
    8000438a:	bfa5                	j	80004302 <namex+0x8c>
    8000438c:	8926                	mv	s2,s1
  len = path - s;
    8000438e:	4d01                	li	s10,0
    80004390:	4601                	li	a2,0
    memmove(name, s, len);
    80004392:	2601                	sext.w	a2,a2
    80004394:	85a6                	mv	a1,s1
    80004396:	8556                	mv	a0,s5
    80004398:	9c1fc0ef          	jal	80000d58 <memmove>
    name[len] = 0;
    8000439c:	9d56                	add	s10,s10,s5
    8000439e:	000d0023          	sb	zero,0(s10)
    800043a2:	84ca                	mv	s1,s2
    800043a4:	bf9d                	j	8000431a <namex+0xa4>
  if(nameiparent){
    800043a6:	f20b06e3          	beqz	s6,800042d2 <namex+0x5c>
    iput(ip);
    800043aa:	8552                	mv	a0,s4
    800043ac:	a07ff0ef          	jal	80003db2 <iput>
    return 0;
    800043b0:	4a01                	li	s4,0
    800043b2:	b705                	j	800042d2 <namex+0x5c>

00000000800043b4 <dirlink>:
{
    800043b4:	715d                	addi	sp,sp,-80
    800043b6:	e486                	sd	ra,72(sp)
    800043b8:	e0a2                	sd	s0,64(sp)
    800043ba:	f84a                	sd	s2,48(sp)
    800043bc:	ec56                	sd	s5,24(sp)
    800043be:	e85a                	sd	s6,16(sp)
    800043c0:	0880                	addi	s0,sp,80
    800043c2:	892a                	mv	s2,a0
    800043c4:	8aae                	mv	s5,a1
    800043c6:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043c8:	4601                	li	a2,0
    800043ca:	e01ff0ef          	jal	800041ca <dirlookup>
    800043ce:	ed1d                	bnez	a0,8000440c <dirlink+0x58>
    800043d0:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043d2:	04c92483          	lw	s1,76(s2)
    800043d6:	c4b9                	beqz	s1,80004424 <dirlink+0x70>
    800043d8:	f44e                	sd	s3,40(sp)
    800043da:	f052                	sd	s4,32(sp)
    800043dc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043de:	fb040a13          	addi	s4,s0,-80
    800043e2:	49c1                	li	s3,16
    800043e4:	874e                	mv	a4,s3
    800043e6:	86a6                	mv	a3,s1
    800043e8:	8652                	mv	a2,s4
    800043ea:	4581                	li	a1,0
    800043ec:	854a                	mv	a0,s2
    800043ee:	bd5ff0ef          	jal	80003fc2 <readi>
    800043f2:	03351163          	bne	a0,s3,80004414 <dirlink+0x60>
    if(de.inum == 0)
    800043f6:	fb045783          	lhu	a5,-80(s0)
    800043fa:	c39d                	beqz	a5,80004420 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043fc:	24c1                	addiw	s1,s1,16
    800043fe:	04c92783          	lw	a5,76(s2)
    80004402:	fef4e1e3          	bltu	s1,a5,800043e4 <dirlink+0x30>
    80004406:	79a2                	ld	s3,40(sp)
    80004408:	7a02                	ld	s4,32(sp)
    8000440a:	a829                	j	80004424 <dirlink+0x70>
    iput(ip);
    8000440c:	9a7ff0ef          	jal	80003db2 <iput>
    return -1;
    80004410:	557d                	li	a0,-1
    80004412:	a83d                	j	80004450 <dirlink+0x9c>
      panic("dirlink read");
    80004414:	00004517          	auipc	a0,0x4
    80004418:	54450513          	addi	a0,a0,1348 # 80008958 <etext+0x958>
    8000441c:	c08fc0ef          	jal	80000824 <panic>
    80004420:	79a2                	ld	s3,40(sp)
    80004422:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004424:	4639                	li	a2,14
    80004426:	85d6                	mv	a1,s5
    80004428:	fb240513          	addi	a0,s0,-78
    8000442c:	9dbfc0ef          	jal	80000e06 <strncpy>
  de.inum = inum;
    80004430:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004434:	4741                	li	a4,16
    80004436:	86a6                	mv	a3,s1
    80004438:	fb040613          	addi	a2,s0,-80
    8000443c:	4581                	li	a1,0
    8000443e:	854a                	mv	a0,s2
    80004440:	c75ff0ef          	jal	800040b4 <writei>
    80004444:	1541                	addi	a0,a0,-16
    80004446:	00a03533          	snez	a0,a0
    8000444a:	40a0053b          	negw	a0,a0
    8000444e:	74e2                	ld	s1,56(sp)
}
    80004450:	60a6                	ld	ra,72(sp)
    80004452:	6406                	ld	s0,64(sp)
    80004454:	7942                	ld	s2,48(sp)
    80004456:	6ae2                	ld	s5,24(sp)
    80004458:	6b42                	ld	s6,16(sp)
    8000445a:	6161                	addi	sp,sp,80
    8000445c:	8082                	ret

000000008000445e <namei>:

struct inode*
namei(char *path)
{
    8000445e:	1101                	addi	sp,sp,-32
    80004460:	ec06                	sd	ra,24(sp)
    80004462:	e822                	sd	s0,16(sp)
    80004464:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004466:	fe040613          	addi	a2,s0,-32
    8000446a:	4581                	li	a1,0
    8000446c:	e0bff0ef          	jal	80004276 <namex>
}
    80004470:	60e2                	ld	ra,24(sp)
    80004472:	6442                	ld	s0,16(sp)
    80004474:	6105                	addi	sp,sp,32
    80004476:	8082                	ret

0000000080004478 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004478:	1141                	addi	sp,sp,-16
    8000447a:	e406                	sd	ra,8(sp)
    8000447c:	e022                	sd	s0,0(sp)
    8000447e:	0800                	addi	s0,sp,16
    80004480:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004482:	4585                	li	a1,1
    80004484:	df3ff0ef          	jal	80004276 <namex>
}
    80004488:	60a2                	ld	ra,8(sp)
    8000448a:	6402                	ld	s0,0(sp)
    8000448c:	0141                	addi	sp,sp,16
    8000448e:	8082                	ret

0000000080004490 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	e04a                	sd	s2,0(sp)
    8000449a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000449c:	00020917          	auipc	s2,0x20
    800044a0:	84c90913          	addi	s2,s2,-1972 # 80023ce8 <log>
    800044a4:	01892583          	lw	a1,24(s2)
    800044a8:	02492503          	lw	a0,36(s2)
    800044ac:	8ecff0ef          	jal	80003598 <bread>
    800044b0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044b2:	02892603          	lw	a2,40(s2)
    800044b6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044b8:	00c05f63          	blez	a2,800044d6 <write_head+0x46>
    800044bc:	00020717          	auipc	a4,0x20
    800044c0:	85870713          	addi	a4,a4,-1960 # 80023d14 <log+0x2c>
    800044c4:	87aa                	mv	a5,a0
    800044c6:	060a                	slli	a2,a2,0x2
    800044c8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800044ca:	4314                	lw	a3,0(a4)
    800044cc:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800044ce:	0711                	addi	a4,a4,4
    800044d0:	0791                	addi	a5,a5,4
    800044d2:	fec79ce3          	bne	a5,a2,800044ca <write_head+0x3a>
  }
  bwrite(buf);
    800044d6:	8526                	mv	a0,s1
    800044d8:	996ff0ef          	jal	8000366e <bwrite>
  brelse(buf);
    800044dc:	8526                	mv	a0,s1
    800044de:	9c2ff0ef          	jal	800036a0 <brelse>
}
    800044e2:	60e2                	ld	ra,24(sp)
    800044e4:	6442                	ld	s0,16(sp)
    800044e6:	64a2                	ld	s1,8(sp)
    800044e8:	6902                	ld	s2,0(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret

00000000800044ee <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ee:	00020797          	auipc	a5,0x20
    800044f2:	8227a783          	lw	a5,-2014(a5) # 80023d10 <log+0x28>
    800044f6:	0cf05163          	blez	a5,800045b8 <install_trans+0xca>
{
    800044fa:	715d                	addi	sp,sp,-80
    800044fc:	e486                	sd	ra,72(sp)
    800044fe:	e0a2                	sd	s0,64(sp)
    80004500:	fc26                	sd	s1,56(sp)
    80004502:	f84a                	sd	s2,48(sp)
    80004504:	f44e                	sd	s3,40(sp)
    80004506:	f052                	sd	s4,32(sp)
    80004508:	ec56                	sd	s5,24(sp)
    8000450a:	e85a                	sd	s6,16(sp)
    8000450c:	e45e                	sd	s7,8(sp)
    8000450e:	e062                	sd	s8,0(sp)
    80004510:	0880                	addi	s0,sp,80
    80004512:	8b2a                	mv	s6,a0
    80004514:	00020a97          	auipc	s5,0x20
    80004518:	800a8a93          	addi	s5,s5,-2048 # 80023d14 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000451c:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000451e:	00004c17          	auipc	s8,0x4
    80004522:	44ac0c13          	addi	s8,s8,1098 # 80008968 <etext+0x968>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004526:	0001fa17          	auipc	s4,0x1f
    8000452a:	7c2a0a13          	addi	s4,s4,1986 # 80023ce8 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000452e:	40000b93          	li	s7,1024
    80004532:	a025                	j	8000455a <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004534:	000aa603          	lw	a2,0(s5)
    80004538:	85ce                	mv	a1,s3
    8000453a:	8562                	mv	a0,s8
    8000453c:	fbffb0ef          	jal	800004fa <printf>
    80004540:	a839                	j	8000455e <install_trans+0x70>
    brelse(lbuf);
    80004542:	854a                	mv	a0,s2
    80004544:	95cff0ef          	jal	800036a0 <brelse>
    brelse(dbuf);
    80004548:	8526                	mv	a0,s1
    8000454a:	956ff0ef          	jal	800036a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000454e:	2985                	addiw	s3,s3,1
    80004550:	0a91                	addi	s5,s5,4
    80004552:	028a2783          	lw	a5,40(s4)
    80004556:	04f9d563          	bge	s3,a5,800045a0 <install_trans+0xb2>
    if(recovering) {
    8000455a:	fc0b1de3          	bnez	s6,80004534 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000455e:	018a2583          	lw	a1,24(s4)
    80004562:	013585bb          	addw	a1,a1,s3
    80004566:	2585                	addiw	a1,a1,1
    80004568:	024a2503          	lw	a0,36(s4)
    8000456c:	82cff0ef          	jal	80003598 <bread>
    80004570:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004572:	000aa583          	lw	a1,0(s5)
    80004576:	024a2503          	lw	a0,36(s4)
    8000457a:	81eff0ef          	jal	80003598 <bread>
    8000457e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004580:	865e                	mv	a2,s7
    80004582:	05890593          	addi	a1,s2,88
    80004586:	05850513          	addi	a0,a0,88
    8000458a:	fcefc0ef          	jal	80000d58 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000458e:	8526                	mv	a0,s1
    80004590:	8deff0ef          	jal	8000366e <bwrite>
    if(recovering == 0)
    80004594:	fa0b17e3          	bnez	s6,80004542 <install_trans+0x54>
      bunpin(dbuf);
    80004598:	8526                	mv	a0,s1
    8000459a:	9beff0ef          	jal	80003758 <bunpin>
    8000459e:	b755                	j	80004542 <install_trans+0x54>
}
    800045a0:	60a6                	ld	ra,72(sp)
    800045a2:	6406                	ld	s0,64(sp)
    800045a4:	74e2                	ld	s1,56(sp)
    800045a6:	7942                	ld	s2,48(sp)
    800045a8:	79a2                	ld	s3,40(sp)
    800045aa:	7a02                	ld	s4,32(sp)
    800045ac:	6ae2                	ld	s5,24(sp)
    800045ae:	6b42                	ld	s6,16(sp)
    800045b0:	6ba2                	ld	s7,8(sp)
    800045b2:	6c02                	ld	s8,0(sp)
    800045b4:	6161                	addi	sp,sp,80
    800045b6:	8082                	ret
    800045b8:	8082                	ret

00000000800045ba <initlog>:
{
    800045ba:	7179                	addi	sp,sp,-48
    800045bc:	f406                	sd	ra,40(sp)
    800045be:	f022                	sd	s0,32(sp)
    800045c0:	ec26                	sd	s1,24(sp)
    800045c2:	e84a                	sd	s2,16(sp)
    800045c4:	e44e                	sd	s3,8(sp)
    800045c6:	1800                	addi	s0,sp,48
    800045c8:	84aa                	mv	s1,a0
    800045ca:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045cc:	0001f917          	auipc	s2,0x1f
    800045d0:	71c90913          	addi	s2,s2,1820 # 80023ce8 <log>
    800045d4:	00004597          	auipc	a1,0x4
    800045d8:	3b458593          	addi	a1,a1,948 # 80008988 <etext+0x988>
    800045dc:	854a                	mv	a0,s2
    800045de:	dc0fc0ef          	jal	80000b9e <initlock>
  log.start = sb->logstart;
    800045e2:	0149a583          	lw	a1,20(s3)
    800045e6:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800045ea:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800045ee:	8526                	mv	a0,s1
    800045f0:	fa9fe0ef          	jal	80003598 <bread>
  log.lh.n = lh->n;
    800045f4:	4d30                	lw	a2,88(a0)
    800045f6:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800045fa:	00c05f63          	blez	a2,80004618 <initlog+0x5e>
    800045fe:	87aa                	mv	a5,a0
    80004600:	0001f717          	auipc	a4,0x1f
    80004604:	71470713          	addi	a4,a4,1812 # 80023d14 <log+0x2c>
    80004608:	060a                	slli	a2,a2,0x2
    8000460a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000460c:	4ff4                	lw	a3,92(a5)
    8000460e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004610:	0791                	addi	a5,a5,4
    80004612:	0711                	addi	a4,a4,4
    80004614:	fec79ce3          	bne	a5,a2,8000460c <initlog+0x52>
  brelse(buf);
    80004618:	888ff0ef          	jal	800036a0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000461c:	4505                	li	a0,1
    8000461e:	ed1ff0ef          	jal	800044ee <install_trans>
  log.lh.n = 0;
    80004622:	0001f797          	auipc	a5,0x1f
    80004626:	6e07a723          	sw	zero,1774(a5) # 80023d10 <log+0x28>
  write_head(); // clear the log
    8000462a:	e67ff0ef          	jal	80004490 <write_head>
}
    8000462e:	70a2                	ld	ra,40(sp)
    80004630:	7402                	ld	s0,32(sp)
    80004632:	64e2                	ld	s1,24(sp)
    80004634:	6942                	ld	s2,16(sp)
    80004636:	69a2                	ld	s3,8(sp)
    80004638:	6145                	addi	sp,sp,48
    8000463a:	8082                	ret

000000008000463c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000463c:	1101                	addi	sp,sp,-32
    8000463e:	ec06                	sd	ra,24(sp)
    80004640:	e822                	sd	s0,16(sp)
    80004642:	e426                	sd	s1,8(sp)
    80004644:	e04a                	sd	s2,0(sp)
    80004646:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004648:	0001f517          	auipc	a0,0x1f
    8000464c:	6a050513          	addi	a0,a0,1696 # 80023ce8 <log>
    80004650:	dd8fc0ef          	jal	80000c28 <acquire>
  while(1){
    if(log.committing){
    80004654:	0001f497          	auipc	s1,0x1f
    80004658:	69448493          	addi	s1,s1,1684 # 80023ce8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000465c:	4979                	li	s2,30
    8000465e:	a029                	j	80004668 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004660:	85a6                	mv	a1,s1
    80004662:	8526                	mv	a0,s1
    80004664:	8c6fe0ef          	jal	8000272a <sleep>
    if(log.committing){
    80004668:	509c                	lw	a5,32(s1)
    8000466a:	fbfd                	bnez	a5,80004660 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000466c:	4cd8                	lw	a4,28(s1)
    8000466e:	2705                	addiw	a4,a4,1
    80004670:	0027179b          	slliw	a5,a4,0x2
    80004674:	9fb9                	addw	a5,a5,a4
    80004676:	0017979b          	slliw	a5,a5,0x1
    8000467a:	5494                	lw	a3,40(s1)
    8000467c:	9fb5                	addw	a5,a5,a3
    8000467e:	00f95763          	bge	s2,a5,8000468c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004682:	85a6                	mv	a1,s1
    80004684:	8526                	mv	a0,s1
    80004686:	8a4fe0ef          	jal	8000272a <sleep>
    8000468a:	bff9                	j	80004668 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000468c:	0001f797          	auipc	a5,0x1f
    80004690:	66e7ac23          	sw	a4,1656(a5) # 80023d04 <log+0x1c>
      release(&log.lock);
    80004694:	0001f517          	auipc	a0,0x1f
    80004698:	65450513          	addi	a0,a0,1620 # 80023ce8 <log>
    8000469c:	e20fc0ef          	jal	80000cbc <release>
      break;
    }
  }
}
    800046a0:	60e2                	ld	ra,24(sp)
    800046a2:	6442                	ld	s0,16(sp)
    800046a4:	64a2                	ld	s1,8(sp)
    800046a6:	6902                	ld	s2,0(sp)
    800046a8:	6105                	addi	sp,sp,32
    800046aa:	8082                	ret

00000000800046ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046ac:	7139                	addi	sp,sp,-64
    800046ae:	fc06                	sd	ra,56(sp)
    800046b0:	f822                	sd	s0,48(sp)
    800046b2:	f426                	sd	s1,40(sp)
    800046b4:	f04a                	sd	s2,32(sp)
    800046b6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046b8:	0001f497          	auipc	s1,0x1f
    800046bc:	63048493          	addi	s1,s1,1584 # 80023ce8 <log>
    800046c0:	8526                	mv	a0,s1
    800046c2:	d66fc0ef          	jal	80000c28 <acquire>
  log.outstanding -= 1;
    800046c6:	4cdc                	lw	a5,28(s1)
    800046c8:	37fd                	addiw	a5,a5,-1
    800046ca:	893e                	mv	s2,a5
    800046cc:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800046ce:	509c                	lw	a5,32(s1)
    800046d0:	e7b1                	bnez	a5,8000471c <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    800046d2:	04091e63          	bnez	s2,8000472e <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800046d6:	0001f497          	auipc	s1,0x1f
    800046da:	61248493          	addi	s1,s1,1554 # 80023ce8 <log>
    800046de:	4785                	li	a5,1
    800046e0:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800046e2:	8526                	mv	a0,s1
    800046e4:	dd8fc0ef          	jal	80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800046e8:	549c                	lw	a5,40(s1)
    800046ea:	06f04463          	bgtz	a5,80004752 <end_op+0xa6>
    acquire(&log.lock);
    800046ee:	0001f517          	auipc	a0,0x1f
    800046f2:	5fa50513          	addi	a0,a0,1530 # 80023ce8 <log>
    800046f6:	d32fc0ef          	jal	80000c28 <acquire>
    log.committing = 0;
    800046fa:	0001f797          	auipc	a5,0x1f
    800046fe:	6007a723          	sw	zero,1550(a5) # 80023d08 <log+0x20>
    wakeup(&log);
    80004702:	0001f517          	auipc	a0,0x1f
    80004706:	5e650513          	addi	a0,a0,1510 # 80023ce8 <log>
    8000470a:	86cfe0ef          	jal	80002776 <wakeup>
    release(&log.lock);
    8000470e:	0001f517          	auipc	a0,0x1f
    80004712:	5da50513          	addi	a0,a0,1498 # 80023ce8 <log>
    80004716:	da6fc0ef          	jal	80000cbc <release>
}
    8000471a:	a035                	j	80004746 <end_op+0x9a>
    8000471c:	ec4e                	sd	s3,24(sp)
    8000471e:	e852                	sd	s4,16(sp)
    80004720:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004722:	00004517          	auipc	a0,0x4
    80004726:	26e50513          	addi	a0,a0,622 # 80008990 <etext+0x990>
    8000472a:	8fafc0ef          	jal	80000824 <panic>
    wakeup(&log);
    8000472e:	0001f517          	auipc	a0,0x1f
    80004732:	5ba50513          	addi	a0,a0,1466 # 80023ce8 <log>
    80004736:	840fe0ef          	jal	80002776 <wakeup>
  release(&log.lock);
    8000473a:	0001f517          	auipc	a0,0x1f
    8000473e:	5ae50513          	addi	a0,a0,1454 # 80023ce8 <log>
    80004742:	d7afc0ef          	jal	80000cbc <release>
}
    80004746:	70e2                	ld	ra,56(sp)
    80004748:	7442                	ld	s0,48(sp)
    8000474a:	74a2                	ld	s1,40(sp)
    8000474c:	7902                	ld	s2,32(sp)
    8000474e:	6121                	addi	sp,sp,64
    80004750:	8082                	ret
    80004752:	ec4e                	sd	s3,24(sp)
    80004754:	e852                	sd	s4,16(sp)
    80004756:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004758:	0001fa97          	auipc	s5,0x1f
    8000475c:	5bca8a93          	addi	s5,s5,1468 # 80023d14 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004760:	0001fa17          	auipc	s4,0x1f
    80004764:	588a0a13          	addi	s4,s4,1416 # 80023ce8 <log>
    80004768:	018a2583          	lw	a1,24(s4)
    8000476c:	012585bb          	addw	a1,a1,s2
    80004770:	2585                	addiw	a1,a1,1
    80004772:	024a2503          	lw	a0,36(s4)
    80004776:	e23fe0ef          	jal	80003598 <bread>
    8000477a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000477c:	000aa583          	lw	a1,0(s5)
    80004780:	024a2503          	lw	a0,36(s4)
    80004784:	e15fe0ef          	jal	80003598 <bread>
    80004788:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000478a:	40000613          	li	a2,1024
    8000478e:	05850593          	addi	a1,a0,88
    80004792:	05848513          	addi	a0,s1,88
    80004796:	dc2fc0ef          	jal	80000d58 <memmove>
    bwrite(to);  // write the log
    8000479a:	8526                	mv	a0,s1
    8000479c:	ed3fe0ef          	jal	8000366e <bwrite>
    brelse(from);
    800047a0:	854e                	mv	a0,s3
    800047a2:	efffe0ef          	jal	800036a0 <brelse>
    brelse(to);
    800047a6:	8526                	mv	a0,s1
    800047a8:	ef9fe0ef          	jal	800036a0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ac:	2905                	addiw	s2,s2,1
    800047ae:	0a91                	addi	s5,s5,4
    800047b0:	028a2783          	lw	a5,40(s4)
    800047b4:	faf94ae3          	blt	s2,a5,80004768 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800047b8:	cd9ff0ef          	jal	80004490 <write_head>
    install_trans(0); // Now install writes to home locations
    800047bc:	4501                	li	a0,0
    800047be:	d31ff0ef          	jal	800044ee <install_trans>
    log.lh.n = 0;
    800047c2:	0001f797          	auipc	a5,0x1f
    800047c6:	5407a723          	sw	zero,1358(a5) # 80023d10 <log+0x28>
    write_head();    // Erase the transaction from the log
    800047ca:	cc7ff0ef          	jal	80004490 <write_head>
    800047ce:	69e2                	ld	s3,24(sp)
    800047d0:	6a42                	ld	s4,16(sp)
    800047d2:	6aa2                	ld	s5,8(sp)
    800047d4:	bf29                	j	800046ee <end_op+0x42>

00000000800047d6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800047d6:	1101                	addi	sp,sp,-32
    800047d8:	ec06                	sd	ra,24(sp)
    800047da:	e822                	sd	s0,16(sp)
    800047dc:	e426                	sd	s1,8(sp)
    800047de:	1000                	addi	s0,sp,32
    800047e0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800047e2:	0001f517          	auipc	a0,0x1f
    800047e6:	50650513          	addi	a0,a0,1286 # 80023ce8 <log>
    800047ea:	c3efc0ef          	jal	80000c28 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800047ee:	0001f617          	auipc	a2,0x1f
    800047f2:	52262603          	lw	a2,1314(a2) # 80023d10 <log+0x28>
    800047f6:	47f5                	li	a5,29
    800047f8:	04c7cd63          	blt	a5,a2,80004852 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047fc:	0001f797          	auipc	a5,0x1f
    80004800:	5087a783          	lw	a5,1288(a5) # 80023d04 <log+0x1c>
    80004804:	04f05d63          	blez	a5,8000485e <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004808:	4781                	li	a5,0
    8000480a:	06c05063          	blez	a2,8000486a <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000480e:	44cc                	lw	a1,12(s1)
    80004810:	0001f717          	auipc	a4,0x1f
    80004814:	50470713          	addi	a4,a4,1284 # 80023d14 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004818:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000481a:	4314                	lw	a3,0(a4)
    8000481c:	04b68763          	beq	a3,a1,8000486a <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004820:	2785                	addiw	a5,a5,1
    80004822:	0711                	addi	a4,a4,4
    80004824:	fef61be3          	bne	a2,a5,8000481a <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004828:	060a                	slli	a2,a2,0x2
    8000482a:	02060613          	addi	a2,a2,32
    8000482e:	0001f797          	auipc	a5,0x1f
    80004832:	4ba78793          	addi	a5,a5,1210 # 80023ce8 <log>
    80004836:	97b2                	add	a5,a5,a2
    80004838:	44d8                	lw	a4,12(s1)
    8000483a:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000483c:	8526                	mv	a0,s1
    8000483e:	ee7fe0ef          	jal	80003724 <bpin>
    log.lh.n++;
    80004842:	0001f717          	auipc	a4,0x1f
    80004846:	4a670713          	addi	a4,a4,1190 # 80023ce8 <log>
    8000484a:	571c                	lw	a5,40(a4)
    8000484c:	2785                	addiw	a5,a5,1
    8000484e:	d71c                	sw	a5,40(a4)
    80004850:	a815                	j	80004884 <log_write+0xae>
    panic("too big a transaction");
    80004852:	00004517          	auipc	a0,0x4
    80004856:	14e50513          	addi	a0,a0,334 # 800089a0 <etext+0x9a0>
    8000485a:	fcbfb0ef          	jal	80000824 <panic>
    panic("log_write outside of trans");
    8000485e:	00004517          	auipc	a0,0x4
    80004862:	15a50513          	addi	a0,a0,346 # 800089b8 <etext+0x9b8>
    80004866:	fbffb0ef          	jal	80000824 <panic>
  log.lh.block[i] = b->blockno;
    8000486a:	00279693          	slli	a3,a5,0x2
    8000486e:	02068693          	addi	a3,a3,32
    80004872:	0001f717          	auipc	a4,0x1f
    80004876:	47670713          	addi	a4,a4,1142 # 80023ce8 <log>
    8000487a:	9736                	add	a4,a4,a3
    8000487c:	44d4                	lw	a3,12(s1)
    8000487e:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004880:	faf60ee3          	beq	a2,a5,8000483c <log_write+0x66>
  }
  release(&log.lock);
    80004884:	0001f517          	auipc	a0,0x1f
    80004888:	46450513          	addi	a0,a0,1124 # 80023ce8 <log>
    8000488c:	c30fc0ef          	jal	80000cbc <release>
}
    80004890:	60e2                	ld	ra,24(sp)
    80004892:	6442                	ld	s0,16(sp)
    80004894:	64a2                	ld	s1,8(sp)
    80004896:	6105                	addi	sp,sp,32
    80004898:	8082                	ret

000000008000489a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000489a:	1101                	addi	sp,sp,-32
    8000489c:	ec06                	sd	ra,24(sp)
    8000489e:	e822                	sd	s0,16(sp)
    800048a0:	e426                	sd	s1,8(sp)
    800048a2:	e04a                	sd	s2,0(sp)
    800048a4:	1000                	addi	s0,sp,32
    800048a6:	84aa                	mv	s1,a0
    800048a8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800048aa:	00004597          	auipc	a1,0x4
    800048ae:	12e58593          	addi	a1,a1,302 # 800089d8 <etext+0x9d8>
    800048b2:	0521                	addi	a0,a0,8
    800048b4:	aeafc0ef          	jal	80000b9e <initlock>
  lk->name = name;
    800048b8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800048bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048c0:	0204a423          	sw	zero,40(s1)
}
    800048c4:	60e2                	ld	ra,24(sp)
    800048c6:	6442                	ld	s0,16(sp)
    800048c8:	64a2                	ld	s1,8(sp)
    800048ca:	6902                	ld	s2,0(sp)
    800048cc:	6105                	addi	sp,sp,32
    800048ce:	8082                	ret

00000000800048d0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048d0:	1101                	addi	sp,sp,-32
    800048d2:	ec06                	sd	ra,24(sp)
    800048d4:	e822                	sd	s0,16(sp)
    800048d6:	e426                	sd	s1,8(sp)
    800048d8:	e04a                	sd	s2,0(sp)
    800048da:	1000                	addi	s0,sp,32
    800048dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048de:	00850913          	addi	s2,a0,8
    800048e2:	854a                	mv	a0,s2
    800048e4:	b44fc0ef          	jal	80000c28 <acquire>
  while (lk->locked) {
    800048e8:	409c                	lw	a5,0(s1)
    800048ea:	c799                	beqz	a5,800048f8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800048ec:	85ca                	mv	a1,s2
    800048ee:	8526                	mv	a0,s1
    800048f0:	e3bfd0ef          	jal	8000272a <sleep>
  while (lk->locked) {
    800048f4:	409c                	lw	a5,0(s1)
    800048f6:	fbfd                	bnez	a5,800048ec <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800048f8:	4785                	li	a5,1
    800048fa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048fc:	9bafd0ef          	jal	80001ab6 <myproc>
    80004900:	591c                	lw	a5,48(a0)
    80004902:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004904:	854a                	mv	a0,s2
    80004906:	bb6fc0ef          	jal	80000cbc <release>
}
    8000490a:	60e2                	ld	ra,24(sp)
    8000490c:	6442                	ld	s0,16(sp)
    8000490e:	64a2                	ld	s1,8(sp)
    80004910:	6902                	ld	s2,0(sp)
    80004912:	6105                	addi	sp,sp,32
    80004914:	8082                	ret

0000000080004916 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004916:	1101                	addi	sp,sp,-32
    80004918:	ec06                	sd	ra,24(sp)
    8000491a:	e822                	sd	s0,16(sp)
    8000491c:	e426                	sd	s1,8(sp)
    8000491e:	e04a                	sd	s2,0(sp)
    80004920:	1000                	addi	s0,sp,32
    80004922:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004924:	00850913          	addi	s2,a0,8
    80004928:	854a                	mv	a0,s2
    8000492a:	afefc0ef          	jal	80000c28 <acquire>
  lk->locked = 0;
    8000492e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004932:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004936:	8526                	mv	a0,s1
    80004938:	e3ffd0ef          	jal	80002776 <wakeup>
  release(&lk->lk);
    8000493c:	854a                	mv	a0,s2
    8000493e:	b7efc0ef          	jal	80000cbc <release>
}
    80004942:	60e2                	ld	ra,24(sp)
    80004944:	6442                	ld	s0,16(sp)
    80004946:	64a2                	ld	s1,8(sp)
    80004948:	6902                	ld	s2,0(sp)
    8000494a:	6105                	addi	sp,sp,32
    8000494c:	8082                	ret

000000008000494e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000494e:	7179                	addi	sp,sp,-48
    80004950:	f406                	sd	ra,40(sp)
    80004952:	f022                	sd	s0,32(sp)
    80004954:	ec26                	sd	s1,24(sp)
    80004956:	e84a                	sd	s2,16(sp)
    80004958:	1800                	addi	s0,sp,48
    8000495a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000495c:	00850913          	addi	s2,a0,8
    80004960:	854a                	mv	a0,s2
    80004962:	ac6fc0ef          	jal	80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004966:	409c                	lw	a5,0(s1)
    80004968:	ef81                	bnez	a5,80004980 <holdingsleep+0x32>
    8000496a:	4481                	li	s1,0
  release(&lk->lk);
    8000496c:	854a                	mv	a0,s2
    8000496e:	b4efc0ef          	jal	80000cbc <release>
  return r;
}
    80004972:	8526                	mv	a0,s1
    80004974:	70a2                	ld	ra,40(sp)
    80004976:	7402                	ld	s0,32(sp)
    80004978:	64e2                	ld	s1,24(sp)
    8000497a:	6942                	ld	s2,16(sp)
    8000497c:	6145                	addi	sp,sp,48
    8000497e:	8082                	ret
    80004980:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004982:	0284a983          	lw	s3,40(s1)
    80004986:	930fd0ef          	jal	80001ab6 <myproc>
    8000498a:	5904                	lw	s1,48(a0)
    8000498c:	413484b3          	sub	s1,s1,s3
    80004990:	0014b493          	seqz	s1,s1
    80004994:	69a2                	ld	s3,8(sp)
    80004996:	bfd9                	j	8000496c <holdingsleep+0x1e>

0000000080004998 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004998:	1141                	addi	sp,sp,-16
    8000499a:	e406                	sd	ra,8(sp)
    8000499c:	e022                	sd	s0,0(sp)
    8000499e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800049a0:	00004597          	auipc	a1,0x4
    800049a4:	04858593          	addi	a1,a1,72 # 800089e8 <etext+0x9e8>
    800049a8:	0001f517          	auipc	a0,0x1f
    800049ac:	48850513          	addi	a0,a0,1160 # 80023e30 <ftable>
    800049b0:	9eefc0ef          	jal	80000b9e <initlock>
}
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049bc:	1101                	addi	sp,sp,-32
    800049be:	ec06                	sd	ra,24(sp)
    800049c0:	e822                	sd	s0,16(sp)
    800049c2:	e426                	sd	s1,8(sp)
    800049c4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049c6:	0001f517          	auipc	a0,0x1f
    800049ca:	46a50513          	addi	a0,a0,1130 # 80023e30 <ftable>
    800049ce:	a5afc0ef          	jal	80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049d2:	0001f497          	auipc	s1,0x1f
    800049d6:	47648493          	addi	s1,s1,1142 # 80023e48 <ftable+0x18>
    800049da:	00020717          	auipc	a4,0x20
    800049de:	40e70713          	addi	a4,a4,1038 # 80024de8 <disk>
    if(f->ref == 0){
    800049e2:	40dc                	lw	a5,4(s1)
    800049e4:	cf89                	beqz	a5,800049fe <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049e6:	02848493          	addi	s1,s1,40
    800049ea:	fee49ce3          	bne	s1,a4,800049e2 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049ee:	0001f517          	auipc	a0,0x1f
    800049f2:	44250513          	addi	a0,a0,1090 # 80023e30 <ftable>
    800049f6:	ac6fc0ef          	jal	80000cbc <release>
  return 0;
    800049fa:	4481                	li	s1,0
    800049fc:	a809                	j	80004a0e <filealloc+0x52>
      f->ref = 1;
    800049fe:	4785                	li	a5,1
    80004a00:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a02:	0001f517          	auipc	a0,0x1f
    80004a06:	42e50513          	addi	a0,a0,1070 # 80023e30 <ftable>
    80004a0a:	ab2fc0ef          	jal	80000cbc <release>
}
    80004a0e:	8526                	mv	a0,s1
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6105                	addi	sp,sp,32
    80004a18:	8082                	ret

0000000080004a1a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a1a:	1101                	addi	sp,sp,-32
    80004a1c:	ec06                	sd	ra,24(sp)
    80004a1e:	e822                	sd	s0,16(sp)
    80004a20:	e426                	sd	s1,8(sp)
    80004a22:	1000                	addi	s0,sp,32
    80004a24:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a26:	0001f517          	auipc	a0,0x1f
    80004a2a:	40a50513          	addi	a0,a0,1034 # 80023e30 <ftable>
    80004a2e:	9fafc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004a32:	40dc                	lw	a5,4(s1)
    80004a34:	02f05063          	blez	a5,80004a54 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004a38:	2785                	addiw	a5,a5,1
    80004a3a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a3c:	0001f517          	auipc	a0,0x1f
    80004a40:	3f450513          	addi	a0,a0,1012 # 80023e30 <ftable>
    80004a44:	a78fc0ef          	jal	80000cbc <release>
  return f;
}
    80004a48:	8526                	mv	a0,s1
    80004a4a:	60e2                	ld	ra,24(sp)
    80004a4c:	6442                	ld	s0,16(sp)
    80004a4e:	64a2                	ld	s1,8(sp)
    80004a50:	6105                	addi	sp,sp,32
    80004a52:	8082                	ret
    panic("filedup");
    80004a54:	00004517          	auipc	a0,0x4
    80004a58:	f9c50513          	addi	a0,a0,-100 # 800089f0 <etext+0x9f0>
    80004a5c:	dc9fb0ef          	jal	80000824 <panic>

0000000080004a60 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a60:	7139                	addi	sp,sp,-64
    80004a62:	fc06                	sd	ra,56(sp)
    80004a64:	f822                	sd	s0,48(sp)
    80004a66:	f426                	sd	s1,40(sp)
    80004a68:	0080                	addi	s0,sp,64
    80004a6a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a6c:	0001f517          	auipc	a0,0x1f
    80004a70:	3c450513          	addi	a0,a0,964 # 80023e30 <ftable>
    80004a74:	9b4fc0ef          	jal	80000c28 <acquire>
  if(f->ref < 1)
    80004a78:	40dc                	lw	a5,4(s1)
    80004a7a:	04f05a63          	blez	a5,80004ace <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004a7e:	37fd                	addiw	a5,a5,-1
    80004a80:	c0dc                	sw	a5,4(s1)
    80004a82:	06f04063          	bgtz	a5,80004ae2 <fileclose+0x82>
    80004a86:	f04a                	sd	s2,32(sp)
    80004a88:	ec4e                	sd	s3,24(sp)
    80004a8a:	e852                	sd	s4,16(sp)
    80004a8c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a8e:	0004a903          	lw	s2,0(s1)
    80004a92:	0094c783          	lbu	a5,9(s1)
    80004a96:	89be                	mv	s3,a5
    80004a98:	689c                	ld	a5,16(s1)
    80004a9a:	8a3e                	mv	s4,a5
    80004a9c:	6c9c                	ld	a5,24(s1)
    80004a9e:	8abe                	mv	s5,a5
  f->ref = 0;
    80004aa0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004aa4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004aa8:	0001f517          	auipc	a0,0x1f
    80004aac:	38850513          	addi	a0,a0,904 # 80023e30 <ftable>
    80004ab0:	a0cfc0ef          	jal	80000cbc <release>

  if(ff.type == FD_PIPE){
    80004ab4:	4785                	li	a5,1
    80004ab6:	04f90163          	beq	s2,a5,80004af8 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004aba:	ffe9079b          	addiw	a5,s2,-2
    80004abe:	4705                	li	a4,1
    80004ac0:	04f77563          	bgeu	a4,a5,80004b0a <fileclose+0xaa>
    80004ac4:	7902                	ld	s2,32(sp)
    80004ac6:	69e2                	ld	s3,24(sp)
    80004ac8:	6a42                	ld	s4,16(sp)
    80004aca:	6aa2                	ld	s5,8(sp)
    80004acc:	a00d                	j	80004aee <fileclose+0x8e>
    80004ace:	f04a                	sd	s2,32(sp)
    80004ad0:	ec4e                	sd	s3,24(sp)
    80004ad2:	e852                	sd	s4,16(sp)
    80004ad4:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004ad6:	00004517          	auipc	a0,0x4
    80004ada:	f2250513          	addi	a0,a0,-222 # 800089f8 <etext+0x9f8>
    80004ade:	d47fb0ef          	jal	80000824 <panic>
    release(&ftable.lock);
    80004ae2:	0001f517          	auipc	a0,0x1f
    80004ae6:	34e50513          	addi	a0,a0,846 # 80023e30 <ftable>
    80004aea:	9d2fc0ef          	jal	80000cbc <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004aee:	70e2                	ld	ra,56(sp)
    80004af0:	7442                	ld	s0,48(sp)
    80004af2:	74a2                	ld	s1,40(sp)
    80004af4:	6121                	addi	sp,sp,64
    80004af6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004af8:	85ce                	mv	a1,s3
    80004afa:	8552                	mv	a0,s4
    80004afc:	380000ef          	jal	80004e7c <pipeclose>
    80004b00:	7902                	ld	s2,32(sp)
    80004b02:	69e2                	ld	s3,24(sp)
    80004b04:	6a42                	ld	s4,16(sp)
    80004b06:	6aa2                	ld	s5,8(sp)
    80004b08:	b7dd                	j	80004aee <fileclose+0x8e>
    begin_op();
    80004b0a:	b33ff0ef          	jal	8000463c <begin_op>
    iput(ff.ip);
    80004b0e:	8556                	mv	a0,s5
    80004b10:	aa2ff0ef          	jal	80003db2 <iput>
    end_op();
    80004b14:	b99ff0ef          	jal	800046ac <end_op>
    80004b18:	7902                	ld	s2,32(sp)
    80004b1a:	69e2                	ld	s3,24(sp)
    80004b1c:	6a42                	ld	s4,16(sp)
    80004b1e:	6aa2                	ld	s5,8(sp)
    80004b20:	b7f9                	j	80004aee <fileclose+0x8e>

0000000080004b22 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b22:	715d                	addi	sp,sp,-80
    80004b24:	e486                	sd	ra,72(sp)
    80004b26:	e0a2                	sd	s0,64(sp)
    80004b28:	fc26                	sd	s1,56(sp)
    80004b2a:	f052                	sd	s4,32(sp)
    80004b2c:	0880                	addi	s0,sp,80
    80004b2e:	84aa                	mv	s1,a0
    80004b30:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004b32:	f85fc0ef          	jal	80001ab6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b36:	409c                	lw	a5,0(s1)
    80004b38:	37f9                	addiw	a5,a5,-2
    80004b3a:	4705                	li	a4,1
    80004b3c:	04f76263          	bltu	a4,a5,80004b80 <filestat+0x5e>
    80004b40:	f84a                	sd	s2,48(sp)
    80004b42:	f44e                	sd	s3,40(sp)
    80004b44:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004b46:	6c88                	ld	a0,24(s1)
    80004b48:	8e8ff0ef          	jal	80003c30 <ilock>
    stati(f->ip, &st);
    80004b4c:	fb840913          	addi	s2,s0,-72
    80004b50:	85ca                	mv	a1,s2
    80004b52:	6c88                	ld	a0,24(s1)
    80004b54:	c40ff0ef          	jal	80003f94 <stati>
    iunlock(f->ip);
    80004b58:	6c88                	ld	a0,24(s1)
    80004b5a:	984ff0ef          	jal	80003cde <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b5e:	46e1                	li	a3,24
    80004b60:	864a                	mv	a2,s2
    80004b62:	85d2                	mv	a1,s4
    80004b64:	0589b503          	ld	a0,88(s3)
    80004b68:	aedfc0ef          	jal	80001654 <copyout>
    80004b6c:	41f5551b          	sraiw	a0,a0,0x1f
    80004b70:	7942                	ld	s2,48(sp)
    80004b72:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004b74:	60a6                	ld	ra,72(sp)
    80004b76:	6406                	ld	s0,64(sp)
    80004b78:	74e2                	ld	s1,56(sp)
    80004b7a:	7a02                	ld	s4,32(sp)
    80004b7c:	6161                	addi	sp,sp,80
    80004b7e:	8082                	ret
  return -1;
    80004b80:	557d                	li	a0,-1
    80004b82:	bfcd                	j	80004b74 <filestat+0x52>

0000000080004b84 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b84:	7179                	addi	sp,sp,-48
    80004b86:	f406                	sd	ra,40(sp)
    80004b88:	f022                	sd	s0,32(sp)
    80004b8a:	e84a                	sd	s2,16(sp)
    80004b8c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b8e:	00854783          	lbu	a5,8(a0)
    80004b92:	cfd1                	beqz	a5,80004c2e <fileread+0xaa>
    80004b94:	ec26                	sd	s1,24(sp)
    80004b96:	e44e                	sd	s3,8(sp)
    80004b98:	84aa                	mv	s1,a0
    80004b9a:	892e                	mv	s2,a1
    80004b9c:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b9e:	411c                	lw	a5,0(a0)
    80004ba0:	4705                	li	a4,1
    80004ba2:	04e78363          	beq	a5,a4,80004be8 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ba6:	470d                	li	a4,3
    80004ba8:	04e78763          	beq	a5,a4,80004bf6 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bac:	4709                	li	a4,2
    80004bae:	06e79a63          	bne	a5,a4,80004c22 <fileread+0x9e>
    ilock(f->ip);
    80004bb2:	6d08                	ld	a0,24(a0)
    80004bb4:	87cff0ef          	jal	80003c30 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bb8:	874e                	mv	a4,s3
    80004bba:	5094                	lw	a3,32(s1)
    80004bbc:	864a                	mv	a2,s2
    80004bbe:	4585                	li	a1,1
    80004bc0:	6c88                	ld	a0,24(s1)
    80004bc2:	c00ff0ef          	jal	80003fc2 <readi>
    80004bc6:	892a                	mv	s2,a0
    80004bc8:	00a05563          	blez	a0,80004bd2 <fileread+0x4e>
      f->off += r;
    80004bcc:	509c                	lw	a5,32(s1)
    80004bce:	9fa9                	addw	a5,a5,a0
    80004bd0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bd2:	6c88                	ld	a0,24(s1)
    80004bd4:	90aff0ef          	jal	80003cde <iunlock>
    80004bd8:	64e2                	ld	s1,24(sp)
    80004bda:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004bdc:	854a                	mv	a0,s2
    80004bde:	70a2                	ld	ra,40(sp)
    80004be0:	7402                	ld	s0,32(sp)
    80004be2:	6942                	ld	s2,16(sp)
    80004be4:	6145                	addi	sp,sp,48
    80004be6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004be8:	6908                	ld	a0,16(a0)
    80004bea:	3f8000ef          	jal	80004fe2 <piperead>
    80004bee:	892a                	mv	s2,a0
    80004bf0:	64e2                	ld	s1,24(sp)
    80004bf2:	69a2                	ld	s3,8(sp)
    80004bf4:	b7e5                	j	80004bdc <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bf6:	02451783          	lh	a5,36(a0)
    80004bfa:	03079693          	slli	a3,a5,0x30
    80004bfe:	92c1                	srli	a3,a3,0x30
    80004c00:	4725                	li	a4,9
    80004c02:	02d76963          	bltu	a4,a3,80004c34 <fileread+0xb0>
    80004c06:	0792                	slli	a5,a5,0x4
    80004c08:	0001f717          	auipc	a4,0x1f
    80004c0c:	18870713          	addi	a4,a4,392 # 80023d90 <devsw>
    80004c10:	97ba                	add	a5,a5,a4
    80004c12:	639c                	ld	a5,0(a5)
    80004c14:	c78d                	beqz	a5,80004c3e <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004c16:	4505                	li	a0,1
    80004c18:	9782                	jalr	a5
    80004c1a:	892a                	mv	s2,a0
    80004c1c:	64e2                	ld	s1,24(sp)
    80004c1e:	69a2                	ld	s3,8(sp)
    80004c20:	bf75                	j	80004bdc <fileread+0x58>
    panic("fileread");
    80004c22:	00004517          	auipc	a0,0x4
    80004c26:	de650513          	addi	a0,a0,-538 # 80008a08 <etext+0xa08>
    80004c2a:	bfbfb0ef          	jal	80000824 <panic>
    return -1;
    80004c2e:	57fd                	li	a5,-1
    80004c30:	893e                	mv	s2,a5
    80004c32:	b76d                	j	80004bdc <fileread+0x58>
      return -1;
    80004c34:	57fd                	li	a5,-1
    80004c36:	893e                	mv	s2,a5
    80004c38:	64e2                	ld	s1,24(sp)
    80004c3a:	69a2                	ld	s3,8(sp)
    80004c3c:	b745                	j	80004bdc <fileread+0x58>
    80004c3e:	57fd                	li	a5,-1
    80004c40:	893e                	mv	s2,a5
    80004c42:	64e2                	ld	s1,24(sp)
    80004c44:	69a2                	ld	s3,8(sp)
    80004c46:	bf59                	j	80004bdc <fileread+0x58>

0000000080004c48 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004c48:	00954783          	lbu	a5,9(a0)
    80004c4c:	10078f63          	beqz	a5,80004d6a <filewrite+0x122>
{
    80004c50:	711d                	addi	sp,sp,-96
    80004c52:	ec86                	sd	ra,88(sp)
    80004c54:	e8a2                	sd	s0,80(sp)
    80004c56:	e0ca                	sd	s2,64(sp)
    80004c58:	f456                	sd	s5,40(sp)
    80004c5a:	f05a                	sd	s6,32(sp)
    80004c5c:	1080                	addi	s0,sp,96
    80004c5e:	892a                	mv	s2,a0
    80004c60:	8b2e                	mv	s6,a1
    80004c62:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c64:	411c                	lw	a5,0(a0)
    80004c66:	4705                	li	a4,1
    80004c68:	02e78a63          	beq	a5,a4,80004c9c <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c6c:	470d                	li	a4,3
    80004c6e:	02e78b63          	beq	a5,a4,80004ca4 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c72:	4709                	li	a4,2
    80004c74:	0ce79f63          	bne	a5,a4,80004d52 <filewrite+0x10a>
    80004c78:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c7a:	0ac05a63          	blez	a2,80004d2e <filewrite+0xe6>
    80004c7e:	e4a6                	sd	s1,72(sp)
    80004c80:	fc4e                	sd	s3,56(sp)
    80004c82:	ec5e                	sd	s7,24(sp)
    80004c84:	e862                	sd	s8,16(sp)
    80004c86:	e466                	sd	s9,8(sp)
    int i = 0;
    80004c88:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004c8a:	6b85                	lui	s7,0x1
    80004c8c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c90:	6785                	lui	a5,0x1
    80004c92:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004c96:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c98:	4c05                	li	s8,1
    80004c9a:	a8ad                	j	80004d14 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004c9c:	6908                	ld	a0,16(a0)
    80004c9e:	252000ef          	jal	80004ef0 <pipewrite>
    80004ca2:	a04d                	j	80004d44 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ca4:	02451783          	lh	a5,36(a0)
    80004ca8:	03079693          	slli	a3,a5,0x30
    80004cac:	92c1                	srli	a3,a3,0x30
    80004cae:	4725                	li	a4,9
    80004cb0:	0ad76f63          	bltu	a4,a3,80004d6e <filewrite+0x126>
    80004cb4:	0792                	slli	a5,a5,0x4
    80004cb6:	0001f717          	auipc	a4,0x1f
    80004cba:	0da70713          	addi	a4,a4,218 # 80023d90 <devsw>
    80004cbe:	97ba                	add	a5,a5,a4
    80004cc0:	679c                	ld	a5,8(a5)
    80004cc2:	cbc5                	beqz	a5,80004d72 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004cc4:	4505                	li	a0,1
    80004cc6:	9782                	jalr	a5
    80004cc8:	a8b5                	j	80004d44 <filewrite+0xfc>
      if(n1 > max)
    80004cca:	2981                	sext.w	s3,s3
      begin_op();
    80004ccc:	971ff0ef          	jal	8000463c <begin_op>
      ilock(f->ip);
    80004cd0:	01893503          	ld	a0,24(s2)
    80004cd4:	f5dfe0ef          	jal	80003c30 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004cd8:	874e                	mv	a4,s3
    80004cda:	02092683          	lw	a3,32(s2)
    80004cde:	016a0633          	add	a2,s4,s6
    80004ce2:	85e2                	mv	a1,s8
    80004ce4:	01893503          	ld	a0,24(s2)
    80004ce8:	bccff0ef          	jal	800040b4 <writei>
    80004cec:	84aa                	mv	s1,a0
    80004cee:	00a05763          	blez	a0,80004cfc <filewrite+0xb4>
        f->off += r;
    80004cf2:	02092783          	lw	a5,32(s2)
    80004cf6:	9fa9                	addw	a5,a5,a0
    80004cf8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cfc:	01893503          	ld	a0,24(s2)
    80004d00:	fdffe0ef          	jal	80003cde <iunlock>
      end_op();
    80004d04:	9a9ff0ef          	jal	800046ac <end_op>

      if(r != n1){
    80004d08:	02999563          	bne	s3,s1,80004d32 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004d0c:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004d10:	015a5963          	bge	s4,s5,80004d22 <filewrite+0xda>
      int n1 = n - i;
    80004d14:	414a87bb          	subw	a5,s5,s4
    80004d18:	89be                	mv	s3,a5
      if(n1 > max)
    80004d1a:	fafbd8e3          	bge	s7,a5,80004cca <filewrite+0x82>
    80004d1e:	89e6                	mv	s3,s9
    80004d20:	b76d                	j	80004cca <filewrite+0x82>
    80004d22:	64a6                	ld	s1,72(sp)
    80004d24:	79e2                	ld	s3,56(sp)
    80004d26:	6be2                	ld	s7,24(sp)
    80004d28:	6c42                	ld	s8,16(sp)
    80004d2a:	6ca2                	ld	s9,8(sp)
    80004d2c:	a801                	j	80004d3c <filewrite+0xf4>
    int i = 0;
    80004d2e:	4a01                	li	s4,0
    80004d30:	a031                	j	80004d3c <filewrite+0xf4>
    80004d32:	64a6                	ld	s1,72(sp)
    80004d34:	79e2                	ld	s3,56(sp)
    80004d36:	6be2                	ld	s7,24(sp)
    80004d38:	6c42                	ld	s8,16(sp)
    80004d3a:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004d3c:	034a9d63          	bne	s5,s4,80004d76 <filewrite+0x12e>
    80004d40:	8556                	mv	a0,s5
    80004d42:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d44:	60e6                	ld	ra,88(sp)
    80004d46:	6446                	ld	s0,80(sp)
    80004d48:	6906                	ld	s2,64(sp)
    80004d4a:	7aa2                	ld	s5,40(sp)
    80004d4c:	7b02                	ld	s6,32(sp)
    80004d4e:	6125                	addi	sp,sp,96
    80004d50:	8082                	ret
    80004d52:	e4a6                	sd	s1,72(sp)
    80004d54:	fc4e                	sd	s3,56(sp)
    80004d56:	f852                	sd	s4,48(sp)
    80004d58:	ec5e                	sd	s7,24(sp)
    80004d5a:	e862                	sd	s8,16(sp)
    80004d5c:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004d5e:	00004517          	auipc	a0,0x4
    80004d62:	cba50513          	addi	a0,a0,-838 # 80008a18 <etext+0xa18>
    80004d66:	abffb0ef          	jal	80000824 <panic>
    return -1;
    80004d6a:	557d                	li	a0,-1
}
    80004d6c:	8082                	ret
      return -1;
    80004d6e:	557d                	li	a0,-1
    80004d70:	bfd1                	j	80004d44 <filewrite+0xfc>
    80004d72:	557d                	li	a0,-1
    80004d74:	bfc1                	j	80004d44 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004d76:	557d                	li	a0,-1
    80004d78:	7a42                	ld	s4,48(sp)
    80004d7a:	b7e9                	j	80004d44 <filewrite+0xfc>

0000000080004d7c <pipealloc>:
  int turn;     // critical section turn
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d7c:	1101                	addi	sp,sp,-32
    80004d7e:	ec06                	sd	ra,24(sp)
    80004d80:	e822                	sd	s0,16(sp)
    80004d82:	e426                	sd	s1,8(sp)
    80004d84:	e04a                	sd	s2,0(sp)
    80004d86:	1000                	addi	s0,sp,32
    80004d88:	84aa                	mv	s1,a0
    80004d8a:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d8c:	0005b023          	sd	zero,0(a1)
    80004d90:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d94:	c29ff0ef          	jal	800049bc <filealloc>
    80004d98:	e088                	sd	a0,0(s1)
    80004d9a:	cd35                	beqz	a0,80004e16 <pipealloc+0x9a>
    80004d9c:	c21ff0ef          	jal	800049bc <filealloc>
    80004da0:	00a93023          	sd	a0,0(s2)
    80004da4:	c52d                	beqz	a0,80004e0e <pipealloc+0x92>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004da6:	d9ffb0ef          	jal	80000b44 <kalloc>
    80004daa:	cd39                	beqz	a0,80004e08 <pipealloc+0x8c>
    goto bad;
  pi->readopen = 1;
    80004dac:	4785                	li	a5,1
    80004dae:	20f52423          	sw	a5,520(a0)
  pi->writeopen = 1;
    80004db2:	20f52623          	sw	a5,524(a0)
  pi->nwrite = 0;
    80004db6:	20052223          	sw	zero,516(a0)
  pi->nread = 0;
    80004dba:	20052023          	sw	zero,512(a0)
  
  pi->flag[0] = 0;
    80004dbe:	20052823          	sw	zero,528(a0)
  pi->flag[1] = 0;
    80004dc2:	20052a23          	sw	zero,532(a0)
  pi->turn = 0;
    80004dc6:	20052c23          	sw	zero,536(a0)

  (*f0)->type = FD_PIPE;
    80004dca:	6098                	ld	a4,0(s1)
    80004dcc:	c31c                	sw	a5,0(a4)
  (*f0)->readable = 1;
    80004dce:	6098                	ld	a4,0(s1)
    80004dd0:	00f70423          	sb	a5,8(a4)
  (*f0)->writable = 0;
    80004dd4:	6098                	ld	a4,0(s1)
    80004dd6:	000704a3          	sb	zero,9(a4)
  (*f0)->pipe = pi;
    80004dda:	6098                	ld	a4,0(s1)
    80004ddc:	eb08                	sd	a0,16(a4)
  (*f1)->type = FD_PIPE;
    80004dde:	00093703          	ld	a4,0(s2)
    80004de2:	c31c                	sw	a5,0(a4)
  (*f1)->readable = 0;
    80004de4:	00093703          	ld	a4,0(s2)
    80004de8:	00070423          	sb	zero,8(a4)
  (*f1)->writable = 1;
    80004dec:	00093703          	ld	a4,0(s2)
    80004df0:	00f704a3          	sb	a5,9(a4)
  (*f1)->pipe = pi;
    80004df4:	00093783          	ld	a5,0(s2)
    80004df8:	eb88                	sd	a0,16(a5)
  return 0;
    80004dfa:	4501                	li	a0,0
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
    80004dfc:	60e2                	ld	ra,24(sp)
    80004dfe:	6442                	ld	s0,16(sp)
    80004e00:	64a2                	ld	s1,8(sp)
    80004e02:	6902                	ld	s2,0(sp)
    80004e04:	6105                	addi	sp,sp,32
    80004e06:	8082                	ret
  if(*f0)
    80004e08:	6088                	ld	a0,0(s1)
    80004e0a:	e501                	bnez	a0,80004e12 <pipealloc+0x96>
    80004e0c:	a029                	j	80004e16 <pipealloc+0x9a>
    80004e0e:	6088                	ld	a0,0(s1)
    80004e10:	cd01                	beqz	a0,80004e28 <pipealloc+0xac>
    fileclose(*f0);
    80004e12:	c4fff0ef          	jal	80004a60 <fileclose>
  if(*f1)
    80004e16:	00093783          	ld	a5,0(s2)
  return -1;
    80004e1a:	557d                	li	a0,-1
  if(*f1)
    80004e1c:	d3e5                	beqz	a5,80004dfc <pipealloc+0x80>
    fileclose(*f1);
    80004e1e:	853e                	mv	a0,a5
    80004e20:	c41ff0ef          	jal	80004a60 <fileclose>
  return -1;
    80004e24:	557d                	li	a0,-1
    80004e26:	bfd9                	j	80004dfc <pipealloc+0x80>
    80004e28:	557d                	li	a0,-1
    80004e2a:	bfc9                	j	80004dfc <pipealloc+0x80>

0000000080004e2c <peterson_enter>:

void 
peterson_enter(struct pipe *pi, int thread_id){
    80004e2c:	1141                	addi	sp,sp,-16
    80004e2e:	e406                	sd	ra,8(sp)
    80004e30:	e022                	sd	s0,0(sp)
    80004e32:	0800                	addi	s0,sp,16
  int other = 1 - thread_id;
    80004e34:	4785                	li	a5,1
    80004e36:	9f8d                	subw	a5,a5,a1
  pi->flag[thread_id] = 1;
    80004e38:	058a                	slli	a1,a1,0x2
    80004e3a:	21058593          	addi	a1,a1,528
    80004e3e:	95aa                	add	a1,a1,a0
    80004e40:	4705                	li	a4,1
    80004e42:	c198                	sw	a4,0(a1)
  pi->turn = other;
    80004e44:	20f52c23          	sw	a5,536(a0)
  while(pi->flag[other] == 1 && pi->turn == other);// busy wait
    80004e48:	078a                	slli	a5,a5,0x2
    80004e4a:	21078793          	addi	a5,a5,528
    80004e4e:	953e                	add	a0,a0,a5
    80004e50:	4118                	lw	a4,0(a0)
    80004e52:	4785                	li	a5,1
    80004e54:	00f70063          	beq	a4,a5,80004e54 <peterson_enter+0x28>
}
    80004e58:	60a2                	ld	ra,8(sp)
    80004e5a:	6402                	ld	s0,0(sp)
    80004e5c:	0141                	addi	sp,sp,16
    80004e5e:	8082                	ret

0000000080004e60 <peterson_exit>:

void
peterson_exit(struct pipe *pi, int thread_id){
    80004e60:	1141                	addi	sp,sp,-16
    80004e62:	e406                	sd	ra,8(sp)
    80004e64:	e022                	sd	s0,0(sp)
    80004e66:	0800                	addi	s0,sp,16
  pi->flag[thread_id] = 0;
    80004e68:	058a                	slli	a1,a1,0x2
    80004e6a:	21058593          	addi	a1,a1,528
    80004e6e:	952e                	add	a0,a0,a1
    80004e70:	00052023          	sw	zero,0(a0)
}
    80004e74:	60a2                	ld	ra,8(sp)
    80004e76:	6402                	ld	s0,0(sp)
    80004e78:	0141                	addi	sp,sp,16
    80004e7a:	8082                	ret

0000000080004e7c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e7c:	7179                	addi	sp,sp,-48
    80004e7e:	f406                	sd	ra,40(sp)
    80004e80:	f022                	sd	s0,32(sp)
    80004e82:	ec26                	sd	s1,24(sp)
    80004e84:	e84a                	sd	s2,16(sp)
    80004e86:	e44e                	sd	s3,8(sp)
    80004e88:	1800                	addi	s0,sp,48
    80004e8a:	84aa                	mv	s1,a0
    80004e8c:	89ae                	mv	s3,a1
  int id = writable ? 0 : 1;
    80004e8e:	0015b913          	seqz	s2,a1
  peterson_enter(pi, id);
    80004e92:	85ca                	mv	a1,s2
    80004e94:	f99ff0ef          	jal	80004e2c <peterson_enter>
  if(writable){
    80004e98:	02098b63          	beqz	s3,80004ece <pipeclose+0x52>
    pi->writeopen = 0;
    80004e9c:	2004a623          	sw	zero,524(s1)
    wakeup(&pi->nread);
    80004ea0:	20048513          	addi	a0,s1,512
    80004ea4:	8d3fd0ef          	jal	80002776 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ea8:	2084a783          	lw	a5,520(s1)
    80004eac:	e781                	bnez	a5,80004eb4 <pipeclose+0x38>
    80004eae:	20c4a783          	lw	a5,524(s1)
    80004eb2:	c78d                	beqz	a5,80004edc <pipeclose+0x60>
  pi->flag[thread_id] = 0;
    80004eb4:	090a                	slli	s2,s2,0x2
    80004eb6:	21090913          	addi	s2,s2,528
    80004eba:	94ca                	add	s1,s1,s2
    80004ebc:	0004a023          	sw	zero,0(s1)
    peterson_exit(pi, id);
    kfree((char*)pi);
  } else
    peterson_exit(pi, id);
}
    80004ec0:	70a2                	ld	ra,40(sp)
    80004ec2:	7402                	ld	s0,32(sp)
    80004ec4:	64e2                	ld	s1,24(sp)
    80004ec6:	6942                	ld	s2,16(sp)
    80004ec8:	69a2                	ld	s3,8(sp)
    80004eca:	6145                	addi	sp,sp,48
    80004ecc:	8082                	ret
    pi->readopen = 0;
    80004ece:	2004a423          	sw	zero,520(s1)
    wakeup(&pi->nwrite);
    80004ed2:	20448513          	addi	a0,s1,516
    80004ed6:	8a1fd0ef          	jal	80002776 <wakeup>
    80004eda:	b7f9                	j	80004ea8 <pipeclose+0x2c>
  pi->flag[thread_id] = 0;
    80004edc:	090a                	slli	s2,s2,0x2
    80004ede:	21090913          	addi	s2,s2,528
    80004ee2:	9926                	add	s2,s2,s1
    80004ee4:	00092023          	sw	zero,0(s2)
    kfree((char*)pi);
    80004ee8:	8526                	mv	a0,s1
    80004eea:	b73fb0ef          	jal	80000a5c <kfree>
    80004eee:	bfc9                	j	80004ec0 <pipeclose+0x44>

0000000080004ef0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ef0:	7159                	addi	sp,sp,-112
    80004ef2:	f486                	sd	ra,104(sp)
    80004ef4:	f0a2                	sd	s0,96(sp)
    80004ef6:	eca6                	sd	s1,88(sp)
    80004ef8:	e8ca                	sd	s2,80(sp)
    80004efa:	e4ce                	sd	s3,72(sp)
    80004efc:	e0d2                	sd	s4,64(sp)
    80004efe:	fc56                	sd	s5,56(sp)
    80004f00:	1880                	addi	s0,sp,112
    80004f02:	84aa                	mv	s1,a0
    80004f04:	8aae                	mv	s5,a1
    80004f06:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f08:	baffc0ef          	jal	80001ab6 <myproc>
    80004f0c:	89aa                	mv	s3,a0

  peterson_enter(pi, 0);
    80004f0e:	4581                	li	a1,0
    80004f10:	8526                	mv	a0,s1
    80004f12:	f1bff0ef          	jal	80004e2c <peterson_enter>
  while(i < n){
    80004f16:	0b405e63          	blez	s4,80004fd2 <pipewrite+0xe2>
    80004f1a:	f85a                	sd	s6,48(sp)
    80004f1c:	f45e                	sd	s7,40(sp)
    80004f1e:	f062                	sd	s8,32(sp)
    80004f20:	ec66                	sd	s9,24(sp)
    80004f22:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004f24:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, 0);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f26:	f9f40c13          	addi	s8,s0,-97
    80004f2a:	4b85                	li	s7,1
    80004f2c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f2e:	20048d13          	addi	s10,s1,512
      sleep(&pi->nwrite, 0);
    80004f32:	20448c93          	addi	s9,s1,516
    80004f36:	a825                	j	80004f6e <pipewrite+0x7e>
      return -1;
    80004f38:	597d                	li	s2,-1
}
    80004f3a:	7b42                	ld	s6,48(sp)
    80004f3c:	7ba2                	ld	s7,40(sp)
    80004f3e:	7c02                	ld	s8,32(sp)
    80004f40:	6ce2                	ld	s9,24(sp)
    80004f42:	6d42                	ld	s10,16(sp)
  pi->flag[thread_id] = 0;
    80004f44:	2004a823          	sw	zero,528(s1)
  }
  wakeup(&pi->nread);
  peterson_exit(pi, 0);

  return i;
}
    80004f48:	854a                	mv	a0,s2
    80004f4a:	70a6                	ld	ra,104(sp)
    80004f4c:	7406                	ld	s0,96(sp)
    80004f4e:	64e6                	ld	s1,88(sp)
    80004f50:	6946                	ld	s2,80(sp)
    80004f52:	69a6                	ld	s3,72(sp)
    80004f54:	6a06                	ld	s4,64(sp)
    80004f56:	7ae2                	ld	s5,56(sp)
    80004f58:	6165                	addi	sp,sp,112
    80004f5a:	8082                	ret
      wakeup(&pi->nread);
    80004f5c:	856a                	mv	a0,s10
    80004f5e:	819fd0ef          	jal	80002776 <wakeup>
      sleep(&pi->nwrite, 0);
    80004f62:	4581                	li	a1,0
    80004f64:	8566                	mv	a0,s9
    80004f66:	fc4fd0ef          	jal	8000272a <sleep>
  while(i < n){
    80004f6a:	05495a63          	bge	s2,s4,80004fbe <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004f6e:	2084a783          	lw	a5,520(s1)
    80004f72:	d3f9                	beqz	a5,80004f38 <pipewrite+0x48>
    80004f74:	854e                	mv	a0,s3
    80004f76:	9f1fd0ef          	jal	80002966 <killed>
    80004f7a:	fd5d                	bnez	a0,80004f38 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f7c:	2004a783          	lw	a5,512(s1)
    80004f80:	2044a703          	lw	a4,516(s1)
    80004f84:	2007879b          	addiw	a5,a5,512
    80004f88:	fcf70ae3          	beq	a4,a5,80004f5c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f8c:	86de                	mv	a3,s7
    80004f8e:	01590633          	add	a2,s2,s5
    80004f92:	85e2                	mv	a1,s8
    80004f94:	0589b503          	ld	a0,88(s3)
    80004f98:	f7afc0ef          	jal	80001712 <copyin>
    80004f9c:	03650d63          	beq	a0,s6,80004fd6 <pipewrite+0xe6>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa0:	2044a783          	lw	a5,516(s1)
    80004fa4:	0017871b          	addiw	a4,a5,1
    80004fa8:	20e4a223          	sw	a4,516(s1)
    80004fac:	1ff7f793          	andi	a5,a5,511
    80004fb0:	97a6                	add	a5,a5,s1
    80004fb2:	f9f44703          	lbu	a4,-97(s0)
    80004fb6:	00e78023          	sb	a4,0(a5)
      i++;
    80004fba:	2905                	addiw	s2,s2,1
    80004fbc:	b77d                	j	80004f6a <pipewrite+0x7a>
    80004fbe:	7b42                	ld	s6,48(sp)
    80004fc0:	7ba2                	ld	s7,40(sp)
    80004fc2:	7c02                	ld	s8,32(sp)
    80004fc4:	6ce2                	ld	s9,24(sp)
    80004fc6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004fc8:	20048513          	addi	a0,s1,512
    80004fcc:	faafd0ef          	jal	80002776 <wakeup>
}
    80004fd0:	bf95                	j	80004f44 <pipewrite+0x54>
  int i = 0;
    80004fd2:	4901                	li	s2,0
    80004fd4:	bfd5                	j	80004fc8 <pipewrite+0xd8>
    80004fd6:	7b42                	ld	s6,48(sp)
    80004fd8:	7ba2                	ld	s7,40(sp)
    80004fda:	7c02                	ld	s8,32(sp)
    80004fdc:	6ce2                	ld	s9,24(sp)
    80004fde:	6d42                	ld	s10,16(sp)
    80004fe0:	b7e5                	j	80004fc8 <pipewrite+0xd8>

0000000080004fe2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fe2:	711d                	addi	sp,sp,-96
    80004fe4:	ec86                	sd	ra,88(sp)
    80004fe6:	e8a2                	sd	s0,80(sp)
    80004fe8:	e4a6                	sd	s1,72(sp)
    80004fea:	e0ca                	sd	s2,64(sp)
    80004fec:	fc4e                	sd	s3,56(sp)
    80004fee:	f852                	sd	s4,48(sp)
    80004ff0:	f456                	sd	s5,40(sp)
    80004ff2:	1080                	addi	s0,sp,96
    80004ff4:	84aa                	mv	s1,a0
    80004ff6:	892e                	mv	s2,a1
    80004ff8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ffa:	abdfc0ef          	jal	80001ab6 <myproc>
    80004ffe:	8a2a                	mv	s4,a0
  char ch;

  peterson_enter(pi, 1);
    80005000:	4585                	li	a1,1
    80005002:	8526                	mv	a0,s1
    80005004:	e29ff0ef          	jal	80004e2c <peterson_enter>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005008:	2004a703          	lw	a4,512(s1)
    8000500c:	2044a783          	lw	a5,516(s1)
    if(killed(pr)){
      peterson_exit(pi, 1);
      return -1;
    }
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80005010:	20048993          	addi	s3,s1,512
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005014:	02f71763          	bne	a4,a5,80005042 <piperead+0x60>
    80005018:	20c4a783          	lw	a5,524(s1)
    8000501c:	c79d                	beqz	a5,8000504a <piperead+0x68>
    if(killed(pr)){
    8000501e:	8552                	mv	a0,s4
    80005020:	947fd0ef          	jal	80002966 <killed>
    80005024:	e15d                	bnez	a0,800050ca <piperead+0xe8>
    sleep(&pi->nread, 0); //DOC: piperead-sleep
    80005026:	4581                	li	a1,0
    80005028:	854e                	mv	a0,s3
    8000502a:	f00fd0ef          	jal	8000272a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000502e:	2004a703          	lw	a4,512(s1)
    80005032:	2044a783          	lw	a5,516(s1)
    80005036:	fef701e3          	beq	a4,a5,80005018 <piperead+0x36>
    8000503a:	f05a                	sd	s6,32(sp)
    8000503c:	ec5e                	sd	s7,24(sp)
    8000503e:	e862                	sd	s8,16(sp)
    80005040:	a801                	j	80005050 <piperead+0x6e>
    80005042:	f05a                	sd	s6,32(sp)
    80005044:	ec5e                	sd	s7,24(sp)
    80005046:	e862                	sd	s8,16(sp)
    80005048:	a021                	j	80005050 <piperead+0x6e>
    8000504a:	f05a                	sd	s6,32(sp)
    8000504c:	ec5e                	sd	s7,24(sp)
    8000504e:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005050:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005052:	faf40c13          	addi	s8,s0,-81
    80005056:	4b85                	li	s7,1
    80005058:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000505a:	05505163          	blez	s5,8000509c <piperead+0xba>
    if(pi->nread == pi->nwrite)
    8000505e:	2004a783          	lw	a5,512(s1)
    80005062:	2044a703          	lw	a4,516(s1)
    80005066:	02f70b63          	beq	a4,a5,8000509c <piperead+0xba>
    ch = pi->data[pi->nread % PIPESIZE];
    8000506a:	1ff7f793          	andi	a5,a5,511
    8000506e:	97a6                	add	a5,a5,s1
    80005070:	0007c783          	lbu	a5,0(a5)
    80005074:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005078:	86de                	mv	a3,s7
    8000507a:	8662                	mv	a2,s8
    8000507c:	85ca                	mv	a1,s2
    8000507e:	058a3503          	ld	a0,88(s4)
    80005082:	dd2fc0ef          	jal	80001654 <copyout>
    80005086:	03650e63          	beq	a0,s6,800050c2 <piperead+0xe0>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    8000508a:	2004a783          	lw	a5,512(s1)
    8000508e:	2785                	addiw	a5,a5,1
    80005090:	20f4a023          	sw	a5,512(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005094:	2985                	addiw	s3,s3,1
    80005096:	0905                	addi	s2,s2,1
    80005098:	fd3a93e3          	bne	s5,s3,8000505e <piperead+0x7c>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000509c:	20448513          	addi	a0,s1,516
    800050a0:	ed6fd0ef          	jal	80002776 <wakeup>
}
    800050a4:	7b02                	ld	s6,32(sp)
    800050a6:	6be2                	ld	s7,24(sp)
    800050a8:	6c42                	ld	s8,16(sp)
  pi->flag[thread_id] = 0;
    800050aa:	2004aa23          	sw	zero,532(s1)
  peterson_exit(pi, 1);
  return i;
}
    800050ae:	854e                	mv	a0,s3
    800050b0:	60e6                	ld	ra,88(sp)
    800050b2:	6446                	ld	s0,80(sp)
    800050b4:	64a6                	ld	s1,72(sp)
    800050b6:	6906                	ld	s2,64(sp)
    800050b8:	79e2                	ld	s3,56(sp)
    800050ba:	7a42                	ld	s4,48(sp)
    800050bc:	7aa2                	ld	s5,40(sp)
    800050be:	6125                	addi	sp,sp,96
    800050c0:	8082                	ret
      if(i == 0)
    800050c2:	fc099de3          	bnez	s3,8000509c <piperead+0xba>
        i = -1;
    800050c6:	89aa                	mv	s3,a0
    800050c8:	bfd1                	j	8000509c <piperead+0xba>
      return -1;
    800050ca:	59fd                	li	s3,-1
    800050cc:	bff9                	j	800050aa <piperead+0xc8>

00000000800050ce <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800050ce:	1141                	addi	sp,sp,-16
    800050d0:	e406                	sd	ra,8(sp)
    800050d2:	e022                	sd	s0,0(sp)
    800050d4:	0800                	addi	s0,sp,16
    800050d6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050d8:	0035151b          	slliw	a0,a0,0x3
    800050dc:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800050de:	8b89                	andi	a5,a5,2
    800050e0:	c399                	beqz	a5,800050e6 <flags2perm+0x18>
      perm |= PTE_W;
    800050e2:	00456513          	ori	a0,a0,4
    return perm;
}
    800050e6:	60a2                	ld	ra,8(sp)
    800050e8:	6402                	ld	s0,0(sp)
    800050ea:	0141                	addi	sp,sp,16
    800050ec:	8082                	ret

00000000800050ee <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800050ee:	de010113          	addi	sp,sp,-544
    800050f2:	20113c23          	sd	ra,536(sp)
    800050f6:	20813823          	sd	s0,528(sp)
    800050fa:	20913423          	sd	s1,520(sp)
    800050fe:	21213023          	sd	s2,512(sp)
    80005102:	1400                	addi	s0,sp,544
    80005104:	892a                	mv	s2,a0
    80005106:	dea43823          	sd	a0,-528(s0)
    8000510a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000510e:	9a9fc0ef          	jal	80001ab6 <myproc>
    80005112:	84aa                	mv	s1,a0

  begin_op();
    80005114:	d28ff0ef          	jal	8000463c <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80005118:	854a                	mv	a0,s2
    8000511a:	b44ff0ef          	jal	8000445e <namei>
    8000511e:	cd21                	beqz	a0,80005176 <kexec+0x88>
    80005120:	fbd2                	sd	s4,496(sp)
    80005122:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005124:	b0dfe0ef          	jal	80003c30 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005128:	04000713          	li	a4,64
    8000512c:	4681                	li	a3,0
    8000512e:	e5040613          	addi	a2,s0,-432
    80005132:	4581                	li	a1,0
    80005134:	8552                	mv	a0,s4
    80005136:	e8dfe0ef          	jal	80003fc2 <readi>
    8000513a:	04000793          	li	a5,64
    8000513e:	00f51a63          	bne	a0,a5,80005152 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005142:	e5042703          	lw	a4,-432(s0)
    80005146:	464c47b7          	lui	a5,0x464c4
    8000514a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000514e:	02f70863          	beq	a4,a5,8000517e <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005152:	8552                	mv	a0,s4
    80005154:	ce9fe0ef          	jal	80003e3c <iunlockput>
    end_op();
    80005158:	d54ff0ef          	jal	800046ac <end_op>
  }
  return -1;
    8000515c:	557d                	li	a0,-1
    8000515e:	7a5e                	ld	s4,496(sp)
}
    80005160:	21813083          	ld	ra,536(sp)
    80005164:	21013403          	ld	s0,528(sp)
    80005168:	20813483          	ld	s1,520(sp)
    8000516c:	20013903          	ld	s2,512(sp)
    80005170:	22010113          	addi	sp,sp,544
    80005174:	8082                	ret
    end_op();
    80005176:	d36ff0ef          	jal	800046ac <end_op>
    return -1;
    8000517a:	557d                	li	a0,-1
    8000517c:	b7d5                	j	80005160 <kexec+0x72>
    8000517e:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005180:	8526                	mv	a0,s1
    80005182:	a41fc0ef          	jal	80001bc2 <proc_pagetable>
    80005186:	8b2a                	mv	s6,a0
    80005188:	26050f63          	beqz	a0,80005406 <kexec+0x318>
    8000518c:	ffce                	sd	s3,504(sp)
    8000518e:	f7d6                	sd	s5,488(sp)
    80005190:	efde                	sd	s7,472(sp)
    80005192:	ebe2                	sd	s8,464(sp)
    80005194:	e7e6                	sd	s9,456(sp)
    80005196:	e3ea                	sd	s10,448(sp)
    80005198:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000519a:	e8845783          	lhu	a5,-376(s0)
    8000519e:	0e078963          	beqz	a5,80005290 <kexec+0x1a2>
    800051a2:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051a6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051a8:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051aa:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800051ae:	6c85                	lui	s9,0x1
    800051b0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800051b4:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800051b8:	6a85                	lui	s5,0x1
    800051ba:	a085                	j	8000521a <kexec+0x12c>
      panic("loadseg: address should exist");
    800051bc:	00004517          	auipc	a0,0x4
    800051c0:	86c50513          	addi	a0,a0,-1940 # 80008a28 <etext+0xa28>
    800051c4:	e60fb0ef          	jal	80000824 <panic>
    if(sz - i < PGSIZE)
    800051c8:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051ca:	874a                	mv	a4,s2
    800051cc:	009b86bb          	addw	a3,s7,s1
    800051d0:	4581                	li	a1,0
    800051d2:	8552                	mv	a0,s4
    800051d4:	deffe0ef          	jal	80003fc2 <readi>
    800051d8:	22a91b63          	bne	s2,a0,8000540e <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800051dc:	009a84bb          	addw	s1,s5,s1
    800051e0:	0334f263          	bgeu	s1,s3,80005204 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800051e4:	02049593          	slli	a1,s1,0x20
    800051e8:	9181                	srli	a1,a1,0x20
    800051ea:	95e2                	add	a1,a1,s8
    800051ec:	855a                	mv	a0,s6
    800051ee:	e39fb0ef          	jal	80001026 <walkaddr>
    800051f2:	862a                	mv	a2,a0
    if(pa == 0)
    800051f4:	d561                	beqz	a0,800051bc <kexec+0xce>
    if(sz - i < PGSIZE)
    800051f6:	409987bb          	subw	a5,s3,s1
    800051fa:	893e                	mv	s2,a5
    800051fc:	fcfcf6e3          	bgeu	s9,a5,800051c8 <kexec+0xda>
    80005200:	8956                	mv	s2,s5
    80005202:	b7d9                	j	800051c8 <kexec+0xda>
    sz = sz1;
    80005204:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005208:	2d05                	addiw	s10,s10,1
    8000520a:	e0843783          	ld	a5,-504(s0)
    8000520e:	0387869b          	addiw	a3,a5,56
    80005212:	e8845783          	lhu	a5,-376(s0)
    80005216:	06fd5e63          	bge	s10,a5,80005292 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000521a:	e0d43423          	sd	a3,-504(s0)
    8000521e:	876e                	mv	a4,s11
    80005220:	e1840613          	addi	a2,s0,-488
    80005224:	4581                	li	a1,0
    80005226:	8552                	mv	a0,s4
    80005228:	d9bfe0ef          	jal	80003fc2 <readi>
    8000522c:	1db51f63          	bne	a0,s11,8000540a <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80005230:	e1842783          	lw	a5,-488(s0)
    80005234:	4705                	li	a4,1
    80005236:	fce799e3          	bne	a5,a4,80005208 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    8000523a:	e4043483          	ld	s1,-448(s0)
    8000523e:	e3843783          	ld	a5,-456(s0)
    80005242:	1ef4e463          	bltu	s1,a5,8000542a <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005246:	e2843783          	ld	a5,-472(s0)
    8000524a:	94be                	add	s1,s1,a5
    8000524c:	1ef4e263          	bltu	s1,a5,80005430 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80005250:	de843703          	ld	a4,-536(s0)
    80005254:	8ff9                	and	a5,a5,a4
    80005256:	1e079063          	bnez	a5,80005436 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000525a:	e1c42503          	lw	a0,-484(s0)
    8000525e:	e71ff0ef          	jal	800050ce <flags2perm>
    80005262:	86aa                	mv	a3,a0
    80005264:	8626                	mv	a2,s1
    80005266:	85ca                	mv	a1,s2
    80005268:	855a                	mv	a0,s6
    8000526a:	892fc0ef          	jal	800012fc <uvmalloc>
    8000526e:	dea43c23          	sd	a0,-520(s0)
    80005272:	1c050563          	beqz	a0,8000543c <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005276:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000527a:	00098863          	beqz	s3,8000528a <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000527e:	e2843c03          	ld	s8,-472(s0)
    80005282:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005286:	4481                	li	s1,0
    80005288:	bfb1                	j	800051e4 <kexec+0xf6>
    sz = sz1;
    8000528a:	df843903          	ld	s2,-520(s0)
    8000528e:	bfad                	j	80005208 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005290:	4901                	li	s2,0
  iunlockput(ip);
    80005292:	8552                	mv	a0,s4
    80005294:	ba9fe0ef          	jal	80003e3c <iunlockput>
  end_op();
    80005298:	c14ff0ef          	jal	800046ac <end_op>
  p = myproc();
    8000529c:	81bfc0ef          	jal	80001ab6 <myproc>
    800052a0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800052a2:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800052a6:	6985                	lui	s3,0x1
    800052a8:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800052aa:	99ca                	add	s3,s3,s2
    800052ac:	77fd                	lui	a5,0xfffff
    800052ae:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800052b2:	4691                	li	a3,4
    800052b4:	6609                	lui	a2,0x2
    800052b6:	964e                	add	a2,a2,s3
    800052b8:	85ce                	mv	a1,s3
    800052ba:	855a                	mv	a0,s6
    800052bc:	840fc0ef          	jal	800012fc <uvmalloc>
    800052c0:	8a2a                	mv	s4,a0
    800052c2:	e105                	bnez	a0,800052e2 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800052c4:	85ce                	mv	a1,s3
    800052c6:	855a                	mv	a0,s6
    800052c8:	97ffc0ef          	jal	80001c46 <proc_freepagetable>
  return -1;
    800052cc:	557d                	li	a0,-1
    800052ce:	79fe                	ld	s3,504(sp)
    800052d0:	7a5e                	ld	s4,496(sp)
    800052d2:	7abe                	ld	s5,488(sp)
    800052d4:	7b1e                	ld	s6,480(sp)
    800052d6:	6bfe                	ld	s7,472(sp)
    800052d8:	6c5e                	ld	s8,464(sp)
    800052da:	6cbe                	ld	s9,456(sp)
    800052dc:	6d1e                	ld	s10,448(sp)
    800052de:	7dfa                	ld	s11,440(sp)
    800052e0:	b541                	j	80005160 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800052e2:	75f9                	lui	a1,0xffffe
    800052e4:	95aa                	add	a1,a1,a0
    800052e6:	855a                	mv	a0,s6
    800052e8:	9e6fc0ef          	jal	800014ce <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800052ec:	800a0b93          	addi	s7,s4,-2048
    800052f0:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800052f4:	e0043783          	ld	a5,-512(s0)
    800052f8:	6388                	ld	a0,0(a5)
  sp = sz;
    800052fa:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    800052fc:	4481                	li	s1,0
    ustack[argc] = sp;
    800052fe:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005302:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80005306:	cd21                	beqz	a0,8000535e <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80005308:	b7bfb0ef          	jal	80000e82 <strlen>
    8000530c:	0015079b          	addiw	a5,a0,1
    80005310:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005314:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005318:	13796563          	bltu	s2,s7,80005442 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000531c:	e0043d83          	ld	s11,-512(s0)
    80005320:	000db983          	ld	s3,0(s11)
    80005324:	854e                	mv	a0,s3
    80005326:	b5dfb0ef          	jal	80000e82 <strlen>
    8000532a:	0015069b          	addiw	a3,a0,1
    8000532e:	864e                	mv	a2,s3
    80005330:	85ca                	mv	a1,s2
    80005332:	855a                	mv	a0,s6
    80005334:	b20fc0ef          	jal	80001654 <copyout>
    80005338:	10054763          	bltz	a0,80005446 <kexec+0x358>
    ustack[argc] = sp;
    8000533c:	00349793          	slli	a5,s1,0x3
    80005340:	97e6                	add	a5,a5,s9
    80005342:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffda0d8>
  for(argc = 0; argv[argc]; argc++) {
    80005346:	0485                	addi	s1,s1,1
    80005348:	008d8793          	addi	a5,s11,8
    8000534c:	e0f43023          	sd	a5,-512(s0)
    80005350:	008db503          	ld	a0,8(s11)
    80005354:	c509                	beqz	a0,8000535e <kexec+0x270>
    if(argc >= MAXARG)
    80005356:	fb8499e3          	bne	s1,s8,80005308 <kexec+0x21a>
  sz = sz1;
    8000535a:	89d2                	mv	s3,s4
    8000535c:	b7a5                	j	800052c4 <kexec+0x1d6>
  ustack[argc] = 0;
    8000535e:	00349793          	slli	a5,s1,0x3
    80005362:	f9078793          	addi	a5,a5,-112
    80005366:	97a2                	add	a5,a5,s0
    80005368:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000536c:	00349693          	slli	a3,s1,0x3
    80005370:	06a1                	addi	a3,a3,8
    80005372:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005376:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000537a:	89d2                	mv	s3,s4
  if(sp < stackbase)
    8000537c:	f57964e3          	bltu	s2,s7,800052c4 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005380:	e9040613          	addi	a2,s0,-368
    80005384:	85ca                	mv	a1,s2
    80005386:	855a                	mv	a0,s6
    80005388:	accfc0ef          	jal	80001654 <copyout>
    8000538c:	f2054ce3          	bltz	a0,800052c4 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80005390:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80005394:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005398:	df043783          	ld	a5,-528(s0)
    8000539c:	0007c703          	lbu	a4,0(a5)
    800053a0:	cf11                	beqz	a4,800053bc <kexec+0x2ce>
    800053a2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053a4:	02f00693          	li	a3,47
    800053a8:	a029                	j	800053b2 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800053aa:	0785                	addi	a5,a5,1
    800053ac:	fff7c703          	lbu	a4,-1(a5)
    800053b0:	c711                	beqz	a4,800053bc <kexec+0x2ce>
    if(*s == '/')
    800053b2:	fed71ce3          	bne	a4,a3,800053aa <kexec+0x2bc>
      last = s+1;
    800053b6:	def43823          	sd	a5,-528(s0)
    800053ba:	bfc5                	j	800053aa <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800053bc:	4641                	li	a2,16
    800053be:	df043583          	ld	a1,-528(s0)
    800053c2:	160a8513          	addi	a0,s5,352
    800053c6:	a87fb0ef          	jal	80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    800053ca:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800053ce:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    800053d2:	054ab823          	sd	s4,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800053d6:	060ab783          	ld	a5,96(s5)
    800053da:	e6843703          	ld	a4,-408(s0)
    800053de:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053e0:	060ab783          	ld	a5,96(s5)
    800053e4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053e8:	85ea                	mv	a1,s10
    800053ea:	85dfc0ef          	jal	80001c46 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053ee:	0004851b          	sext.w	a0,s1
    800053f2:	79fe                	ld	s3,504(sp)
    800053f4:	7a5e                	ld	s4,496(sp)
    800053f6:	7abe                	ld	s5,488(sp)
    800053f8:	7b1e                	ld	s6,480(sp)
    800053fa:	6bfe                	ld	s7,472(sp)
    800053fc:	6c5e                	ld	s8,464(sp)
    800053fe:	6cbe                	ld	s9,456(sp)
    80005400:	6d1e                	ld	s10,448(sp)
    80005402:	7dfa                	ld	s11,440(sp)
    80005404:	bbb1                	j	80005160 <kexec+0x72>
    80005406:	7b1e                	ld	s6,480(sp)
    80005408:	b3a9                	j	80005152 <kexec+0x64>
    8000540a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000540e:	df843583          	ld	a1,-520(s0)
    80005412:	855a                	mv	a0,s6
    80005414:	833fc0ef          	jal	80001c46 <proc_freepagetable>
  if(ip){
    80005418:	79fe                	ld	s3,504(sp)
    8000541a:	7abe                	ld	s5,488(sp)
    8000541c:	7b1e                	ld	s6,480(sp)
    8000541e:	6bfe                	ld	s7,472(sp)
    80005420:	6c5e                	ld	s8,464(sp)
    80005422:	6cbe                	ld	s9,456(sp)
    80005424:	6d1e                	ld	s10,448(sp)
    80005426:	7dfa                	ld	s11,440(sp)
    80005428:	b32d                	j	80005152 <kexec+0x64>
    8000542a:	df243c23          	sd	s2,-520(s0)
    8000542e:	b7c5                	j	8000540e <kexec+0x320>
    80005430:	df243c23          	sd	s2,-520(s0)
    80005434:	bfe9                	j	8000540e <kexec+0x320>
    80005436:	df243c23          	sd	s2,-520(s0)
    8000543a:	bfd1                	j	8000540e <kexec+0x320>
    8000543c:	df243c23          	sd	s2,-520(s0)
    80005440:	b7f9                	j	8000540e <kexec+0x320>
  sz = sz1;
    80005442:	89d2                	mv	s3,s4
    80005444:	b541                	j	800052c4 <kexec+0x1d6>
    80005446:	89d2                	mv	s3,s4
    80005448:	bdb5                	j	800052c4 <kexec+0x1d6>

000000008000544a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000544a:	7179                	addi	sp,sp,-48
    8000544c:	f406                	sd	ra,40(sp)
    8000544e:	f022                	sd	s0,32(sp)
    80005450:	ec26                	sd	s1,24(sp)
    80005452:	e84a                	sd	s2,16(sp)
    80005454:	1800                	addi	s0,sp,48
    80005456:	892e                	mv	s2,a1
    80005458:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000545a:	fdc40593          	addi	a1,s0,-36
    8000545e:	dddfd0ef          	jal	8000323a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005462:	fdc42703          	lw	a4,-36(s0)
    80005466:	47bd                	li	a5,15
    80005468:	02e7ea63          	bltu	a5,a4,8000549c <argfd+0x52>
    8000546c:	e4afc0ef          	jal	80001ab6 <myproc>
    80005470:	fdc42703          	lw	a4,-36(s0)
    80005474:	00371793          	slli	a5,a4,0x3
    80005478:	0d078793          	addi	a5,a5,208
    8000547c:	953e                	add	a0,a0,a5
    8000547e:	651c                	ld	a5,8(a0)
    80005480:	c385                	beqz	a5,800054a0 <argfd+0x56>
    return -1;
  if(pfd)
    80005482:	00090463          	beqz	s2,8000548a <argfd+0x40>
    *pfd = fd;
    80005486:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000548a:	4501                	li	a0,0
  if(pf)
    8000548c:	c091                	beqz	s1,80005490 <argfd+0x46>
    *pf = f;
    8000548e:	e09c                	sd	a5,0(s1)
}
    80005490:	70a2                	ld	ra,40(sp)
    80005492:	7402                	ld	s0,32(sp)
    80005494:	64e2                	ld	s1,24(sp)
    80005496:	6942                	ld	s2,16(sp)
    80005498:	6145                	addi	sp,sp,48
    8000549a:	8082                	ret
    return -1;
    8000549c:	557d                	li	a0,-1
    8000549e:	bfcd                	j	80005490 <argfd+0x46>
    800054a0:	557d                	li	a0,-1
    800054a2:	b7fd                	j	80005490 <argfd+0x46>

00000000800054a4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800054a4:	1101                	addi	sp,sp,-32
    800054a6:	ec06                	sd	ra,24(sp)
    800054a8:	e822                	sd	s0,16(sp)
    800054aa:	e426                	sd	s1,8(sp)
    800054ac:	1000                	addi	s0,sp,32
    800054ae:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054b0:	e06fc0ef          	jal	80001ab6 <myproc>
    800054b4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054b6:	0d850793          	addi	a5,a0,216
    800054ba:	4501                	li	a0,0
    800054bc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054be:	6398                	ld	a4,0(a5)
    800054c0:	cb19                	beqz	a4,800054d6 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800054c2:	2505                	addiw	a0,a0,1
    800054c4:	07a1                	addi	a5,a5,8
    800054c6:	fed51ce3          	bne	a0,a3,800054be <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054ca:	557d                	li	a0,-1
}
    800054cc:	60e2                	ld	ra,24(sp)
    800054ce:	6442                	ld	s0,16(sp)
    800054d0:	64a2                	ld	s1,8(sp)
    800054d2:	6105                	addi	sp,sp,32
    800054d4:	8082                	ret
      p->ofile[fd] = f;
    800054d6:	00351793          	slli	a5,a0,0x3
    800054da:	0d078793          	addi	a5,a5,208
    800054de:	963e                	add	a2,a2,a5
    800054e0:	e604                	sd	s1,8(a2)
      return fd;
    800054e2:	b7ed                	j	800054cc <fdalloc+0x28>

00000000800054e4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054e4:	715d                	addi	sp,sp,-80
    800054e6:	e486                	sd	ra,72(sp)
    800054e8:	e0a2                	sd	s0,64(sp)
    800054ea:	fc26                	sd	s1,56(sp)
    800054ec:	f84a                	sd	s2,48(sp)
    800054ee:	f44e                	sd	s3,40(sp)
    800054f0:	f052                	sd	s4,32(sp)
    800054f2:	ec56                	sd	s5,24(sp)
    800054f4:	e85a                	sd	s6,16(sp)
    800054f6:	0880                	addi	s0,sp,80
    800054f8:	892e                	mv	s2,a1
    800054fa:	8a2e                	mv	s4,a1
    800054fc:	8ab2                	mv	s5,a2
    800054fe:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005500:	fb040593          	addi	a1,s0,-80
    80005504:	f75fe0ef          	jal	80004478 <nameiparent>
    80005508:	84aa                	mv	s1,a0
    8000550a:	10050763          	beqz	a0,80005618 <create+0x134>
    return 0;

  ilock(dp);
    8000550e:	f22fe0ef          	jal	80003c30 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005512:	4601                	li	a2,0
    80005514:	fb040593          	addi	a1,s0,-80
    80005518:	8526                	mv	a0,s1
    8000551a:	cb1fe0ef          	jal	800041ca <dirlookup>
    8000551e:	89aa                	mv	s3,a0
    80005520:	c131                	beqz	a0,80005564 <create+0x80>
    iunlockput(dp);
    80005522:	8526                	mv	a0,s1
    80005524:	919fe0ef          	jal	80003e3c <iunlockput>
    ilock(ip);
    80005528:	854e                	mv	a0,s3
    8000552a:	f06fe0ef          	jal	80003c30 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000552e:	4789                	li	a5,2
    80005530:	02f91563          	bne	s2,a5,8000555a <create+0x76>
    80005534:	0449d783          	lhu	a5,68(s3)
    80005538:	37f9                	addiw	a5,a5,-2
    8000553a:	17c2                	slli	a5,a5,0x30
    8000553c:	93c1                	srli	a5,a5,0x30
    8000553e:	4705                	li	a4,1
    80005540:	00f76d63          	bltu	a4,a5,8000555a <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005544:	854e                	mv	a0,s3
    80005546:	60a6                	ld	ra,72(sp)
    80005548:	6406                	ld	s0,64(sp)
    8000554a:	74e2                	ld	s1,56(sp)
    8000554c:	7942                	ld	s2,48(sp)
    8000554e:	79a2                	ld	s3,40(sp)
    80005550:	7a02                	ld	s4,32(sp)
    80005552:	6ae2                	ld	s5,24(sp)
    80005554:	6b42                	ld	s6,16(sp)
    80005556:	6161                	addi	sp,sp,80
    80005558:	8082                	ret
    iunlockput(ip);
    8000555a:	854e                	mv	a0,s3
    8000555c:	8e1fe0ef          	jal	80003e3c <iunlockput>
    return 0;
    80005560:	4981                	li	s3,0
    80005562:	b7cd                	j	80005544 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005564:	85ca                	mv	a1,s2
    80005566:	4088                	lw	a0,0(s1)
    80005568:	d58fe0ef          	jal	80003ac0 <ialloc>
    8000556c:	892a                	mv	s2,a0
    8000556e:	cd15                	beqz	a0,800055aa <create+0xc6>
  ilock(ip);
    80005570:	ec0fe0ef          	jal	80003c30 <ilock>
  ip->major = major;
    80005574:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80005578:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    8000557c:	4785                	li	a5,1
    8000557e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005582:	854a                	mv	a0,s2
    80005584:	df8fe0ef          	jal	80003b7c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005588:	4705                	li	a4,1
    8000558a:	02ea0463          	beq	s4,a4,800055b2 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000558e:	00492603          	lw	a2,4(s2)
    80005592:	fb040593          	addi	a1,s0,-80
    80005596:	8526                	mv	a0,s1
    80005598:	e1dfe0ef          	jal	800043b4 <dirlink>
    8000559c:	06054263          	bltz	a0,80005600 <create+0x11c>
  iunlockput(dp);
    800055a0:	8526                	mv	a0,s1
    800055a2:	89bfe0ef          	jal	80003e3c <iunlockput>
  return ip;
    800055a6:	89ca                	mv	s3,s2
    800055a8:	bf71                	j	80005544 <create+0x60>
    iunlockput(dp);
    800055aa:	8526                	mv	a0,s1
    800055ac:	891fe0ef          	jal	80003e3c <iunlockput>
    return 0;
    800055b0:	bf51                	j	80005544 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055b2:	00492603          	lw	a2,4(s2)
    800055b6:	00003597          	auipc	a1,0x3
    800055ba:	49258593          	addi	a1,a1,1170 # 80008a48 <etext+0xa48>
    800055be:	854a                	mv	a0,s2
    800055c0:	df5fe0ef          	jal	800043b4 <dirlink>
    800055c4:	02054e63          	bltz	a0,80005600 <create+0x11c>
    800055c8:	40d0                	lw	a2,4(s1)
    800055ca:	00003597          	auipc	a1,0x3
    800055ce:	48658593          	addi	a1,a1,1158 # 80008a50 <etext+0xa50>
    800055d2:	854a                	mv	a0,s2
    800055d4:	de1fe0ef          	jal	800043b4 <dirlink>
    800055d8:	02054463          	bltz	a0,80005600 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800055dc:	00492603          	lw	a2,4(s2)
    800055e0:	fb040593          	addi	a1,s0,-80
    800055e4:	8526                	mv	a0,s1
    800055e6:	dcffe0ef          	jal	800043b4 <dirlink>
    800055ea:	00054b63          	bltz	a0,80005600 <create+0x11c>
    dp->nlink++;  // for ".."
    800055ee:	04a4d783          	lhu	a5,74(s1)
    800055f2:	2785                	addiw	a5,a5,1
    800055f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055f8:	8526                	mv	a0,s1
    800055fa:	d82fe0ef          	jal	80003b7c <iupdate>
    800055fe:	b74d                	j	800055a0 <create+0xbc>
  ip->nlink = 0;
    80005600:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005604:	854a                	mv	a0,s2
    80005606:	d76fe0ef          	jal	80003b7c <iupdate>
  iunlockput(ip);
    8000560a:	854a                	mv	a0,s2
    8000560c:	831fe0ef          	jal	80003e3c <iunlockput>
  iunlockput(dp);
    80005610:	8526                	mv	a0,s1
    80005612:	82bfe0ef          	jal	80003e3c <iunlockput>
  return 0;
    80005616:	b73d                	j	80005544 <create+0x60>
    return 0;
    80005618:	89aa                	mv	s3,a0
    8000561a:	b72d                	j	80005544 <create+0x60>

000000008000561c <sys_dup>:
{
    8000561c:	7179                	addi	sp,sp,-48
    8000561e:	f406                	sd	ra,40(sp)
    80005620:	f022                	sd	s0,32(sp)
    80005622:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005624:	fd840613          	addi	a2,s0,-40
    80005628:	4581                	li	a1,0
    8000562a:	4501                	li	a0,0
    8000562c:	e1fff0ef          	jal	8000544a <argfd>
    return -1;
    80005630:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005632:	02054363          	bltz	a0,80005658 <sys_dup+0x3c>
    80005636:	ec26                	sd	s1,24(sp)
    80005638:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000563a:	fd843483          	ld	s1,-40(s0)
    8000563e:	8526                	mv	a0,s1
    80005640:	e65ff0ef          	jal	800054a4 <fdalloc>
    80005644:	892a                	mv	s2,a0
    return -1;
    80005646:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005648:	00054d63          	bltz	a0,80005662 <sys_dup+0x46>
  filedup(f);
    8000564c:	8526                	mv	a0,s1
    8000564e:	bccff0ef          	jal	80004a1a <filedup>
  return fd;
    80005652:	87ca                	mv	a5,s2
    80005654:	64e2                	ld	s1,24(sp)
    80005656:	6942                	ld	s2,16(sp)
}
    80005658:	853e                	mv	a0,a5
    8000565a:	70a2                	ld	ra,40(sp)
    8000565c:	7402                	ld	s0,32(sp)
    8000565e:	6145                	addi	sp,sp,48
    80005660:	8082                	ret
    80005662:	64e2                	ld	s1,24(sp)
    80005664:	6942                	ld	s2,16(sp)
    80005666:	bfcd                	j	80005658 <sys_dup+0x3c>

0000000080005668 <sys_read>:
{
    80005668:	7179                	addi	sp,sp,-48
    8000566a:	f406                	sd	ra,40(sp)
    8000566c:	f022                	sd	s0,32(sp)
    8000566e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005670:	fd840593          	addi	a1,s0,-40
    80005674:	4505                	li	a0,1
    80005676:	be1fd0ef          	jal	80003256 <argaddr>
  argint(2, &n);
    8000567a:	fe440593          	addi	a1,s0,-28
    8000567e:	4509                	li	a0,2
    80005680:	bbbfd0ef          	jal	8000323a <argint>
  if(argfd(0, 0, &f) < 0)
    80005684:	fe840613          	addi	a2,s0,-24
    80005688:	4581                	li	a1,0
    8000568a:	4501                	li	a0,0
    8000568c:	dbfff0ef          	jal	8000544a <argfd>
    80005690:	87aa                	mv	a5,a0
    return -1;
    80005692:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005694:	0007ca63          	bltz	a5,800056a8 <sys_read+0x40>
  return fileread(f, p, n);
    80005698:	fe442603          	lw	a2,-28(s0)
    8000569c:	fd843583          	ld	a1,-40(s0)
    800056a0:	fe843503          	ld	a0,-24(s0)
    800056a4:	ce0ff0ef          	jal	80004b84 <fileread>
}
    800056a8:	70a2                	ld	ra,40(sp)
    800056aa:	7402                	ld	s0,32(sp)
    800056ac:	6145                	addi	sp,sp,48
    800056ae:	8082                	ret

00000000800056b0 <sys_write>:
{
    800056b0:	7179                	addi	sp,sp,-48
    800056b2:	f406                	sd	ra,40(sp)
    800056b4:	f022                	sd	s0,32(sp)
    800056b6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056b8:	fd840593          	addi	a1,s0,-40
    800056bc:	4505                	li	a0,1
    800056be:	b99fd0ef          	jal	80003256 <argaddr>
  argint(2, &n);
    800056c2:	fe440593          	addi	a1,s0,-28
    800056c6:	4509                	li	a0,2
    800056c8:	b73fd0ef          	jal	8000323a <argint>
  if(argfd(0, 0, &f) < 0)
    800056cc:	fe840613          	addi	a2,s0,-24
    800056d0:	4581                	li	a1,0
    800056d2:	4501                	li	a0,0
    800056d4:	d77ff0ef          	jal	8000544a <argfd>
    800056d8:	87aa                	mv	a5,a0
    return -1;
    800056da:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056dc:	0007ca63          	bltz	a5,800056f0 <sys_write+0x40>
  return filewrite(f, p, n);
    800056e0:	fe442603          	lw	a2,-28(s0)
    800056e4:	fd843583          	ld	a1,-40(s0)
    800056e8:	fe843503          	ld	a0,-24(s0)
    800056ec:	d5cff0ef          	jal	80004c48 <filewrite>
}
    800056f0:	70a2                	ld	ra,40(sp)
    800056f2:	7402                	ld	s0,32(sp)
    800056f4:	6145                	addi	sp,sp,48
    800056f6:	8082                	ret

00000000800056f8 <sys_close>:
{
    800056f8:	1101                	addi	sp,sp,-32
    800056fa:	ec06                	sd	ra,24(sp)
    800056fc:	e822                	sd	s0,16(sp)
    800056fe:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005700:	fe040613          	addi	a2,s0,-32
    80005704:	fec40593          	addi	a1,s0,-20
    80005708:	4501                	li	a0,0
    8000570a:	d41ff0ef          	jal	8000544a <argfd>
    return -1;
    8000570e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005710:	02054163          	bltz	a0,80005732 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005714:	ba2fc0ef          	jal	80001ab6 <myproc>
    80005718:	fec42783          	lw	a5,-20(s0)
    8000571c:	078e                	slli	a5,a5,0x3
    8000571e:	0d078793          	addi	a5,a5,208
    80005722:	953e                	add	a0,a0,a5
    80005724:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80005728:	fe043503          	ld	a0,-32(s0)
    8000572c:	b34ff0ef          	jal	80004a60 <fileclose>
  return 0;
    80005730:	4781                	li	a5,0
}
    80005732:	853e                	mv	a0,a5
    80005734:	60e2                	ld	ra,24(sp)
    80005736:	6442                	ld	s0,16(sp)
    80005738:	6105                	addi	sp,sp,32
    8000573a:	8082                	ret

000000008000573c <sys_fstat>:
{
    8000573c:	1101                	addi	sp,sp,-32
    8000573e:	ec06                	sd	ra,24(sp)
    80005740:	e822                	sd	s0,16(sp)
    80005742:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005744:	fe040593          	addi	a1,s0,-32
    80005748:	4505                	li	a0,1
    8000574a:	b0dfd0ef          	jal	80003256 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000574e:	fe840613          	addi	a2,s0,-24
    80005752:	4581                	li	a1,0
    80005754:	4501                	li	a0,0
    80005756:	cf5ff0ef          	jal	8000544a <argfd>
    8000575a:	87aa                	mv	a5,a0
    return -1;
    8000575c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000575e:	0007c863          	bltz	a5,8000576e <sys_fstat+0x32>
  return filestat(f, st);
    80005762:	fe043583          	ld	a1,-32(s0)
    80005766:	fe843503          	ld	a0,-24(s0)
    8000576a:	bb8ff0ef          	jal	80004b22 <filestat>
}
    8000576e:	60e2                	ld	ra,24(sp)
    80005770:	6442                	ld	s0,16(sp)
    80005772:	6105                	addi	sp,sp,32
    80005774:	8082                	ret

0000000080005776 <sys_link>:
{
    80005776:	7169                	addi	sp,sp,-304
    80005778:	f606                	sd	ra,296(sp)
    8000577a:	f222                	sd	s0,288(sp)
    8000577c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000577e:	08000613          	li	a2,128
    80005782:	ed040593          	addi	a1,s0,-304
    80005786:	4501                	li	a0,0
    80005788:	aebfd0ef          	jal	80003272 <argstr>
    return -1;
    8000578c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000578e:	0c054e63          	bltz	a0,8000586a <sys_link+0xf4>
    80005792:	08000613          	li	a2,128
    80005796:	f5040593          	addi	a1,s0,-176
    8000579a:	4505                	li	a0,1
    8000579c:	ad7fd0ef          	jal	80003272 <argstr>
    return -1;
    800057a0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057a2:	0c054463          	bltz	a0,8000586a <sys_link+0xf4>
    800057a6:	ee26                	sd	s1,280(sp)
  begin_op();
    800057a8:	e95fe0ef          	jal	8000463c <begin_op>
  if((ip = namei(old)) == 0){
    800057ac:	ed040513          	addi	a0,s0,-304
    800057b0:	caffe0ef          	jal	8000445e <namei>
    800057b4:	84aa                	mv	s1,a0
    800057b6:	c53d                	beqz	a0,80005824 <sys_link+0xae>
  ilock(ip);
    800057b8:	c78fe0ef          	jal	80003c30 <ilock>
  if(ip->type == T_DIR){
    800057bc:	04449703          	lh	a4,68(s1)
    800057c0:	4785                	li	a5,1
    800057c2:	06f70663          	beq	a4,a5,8000582e <sys_link+0xb8>
    800057c6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800057c8:	04a4d783          	lhu	a5,74(s1)
    800057cc:	2785                	addiw	a5,a5,1
    800057ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057d2:	8526                	mv	a0,s1
    800057d4:	ba8fe0ef          	jal	80003b7c <iupdate>
  iunlock(ip);
    800057d8:	8526                	mv	a0,s1
    800057da:	d04fe0ef          	jal	80003cde <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800057de:	fd040593          	addi	a1,s0,-48
    800057e2:	f5040513          	addi	a0,s0,-176
    800057e6:	c93fe0ef          	jal	80004478 <nameiparent>
    800057ea:	892a                	mv	s2,a0
    800057ec:	cd21                	beqz	a0,80005844 <sys_link+0xce>
  ilock(dp);
    800057ee:	c42fe0ef          	jal	80003c30 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057f2:	854a                	mv	a0,s2
    800057f4:	00092703          	lw	a4,0(s2)
    800057f8:	409c                	lw	a5,0(s1)
    800057fa:	04f71263          	bne	a4,a5,8000583e <sys_link+0xc8>
    800057fe:	40d0                	lw	a2,4(s1)
    80005800:	fd040593          	addi	a1,s0,-48
    80005804:	bb1fe0ef          	jal	800043b4 <dirlink>
    80005808:	02054b63          	bltz	a0,8000583e <sys_link+0xc8>
  iunlockput(dp);
    8000580c:	854a                	mv	a0,s2
    8000580e:	e2efe0ef          	jal	80003e3c <iunlockput>
  iput(ip);
    80005812:	8526                	mv	a0,s1
    80005814:	d9efe0ef          	jal	80003db2 <iput>
  end_op();
    80005818:	e95fe0ef          	jal	800046ac <end_op>
  return 0;
    8000581c:	4781                	li	a5,0
    8000581e:	64f2                	ld	s1,280(sp)
    80005820:	6952                	ld	s2,272(sp)
    80005822:	a0a1                	j	8000586a <sys_link+0xf4>
    end_op();
    80005824:	e89fe0ef          	jal	800046ac <end_op>
    return -1;
    80005828:	57fd                	li	a5,-1
    8000582a:	64f2                	ld	s1,280(sp)
    8000582c:	a83d                	j	8000586a <sys_link+0xf4>
    iunlockput(ip);
    8000582e:	8526                	mv	a0,s1
    80005830:	e0cfe0ef          	jal	80003e3c <iunlockput>
    end_op();
    80005834:	e79fe0ef          	jal	800046ac <end_op>
    return -1;
    80005838:	57fd                	li	a5,-1
    8000583a:	64f2                	ld	s1,280(sp)
    8000583c:	a03d                	j	8000586a <sys_link+0xf4>
    iunlockput(dp);
    8000583e:	854a                	mv	a0,s2
    80005840:	dfcfe0ef          	jal	80003e3c <iunlockput>
  ilock(ip);
    80005844:	8526                	mv	a0,s1
    80005846:	beafe0ef          	jal	80003c30 <ilock>
  ip->nlink--;
    8000584a:	04a4d783          	lhu	a5,74(s1)
    8000584e:	37fd                	addiw	a5,a5,-1
    80005850:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005854:	8526                	mv	a0,s1
    80005856:	b26fe0ef          	jal	80003b7c <iupdate>
  iunlockput(ip);
    8000585a:	8526                	mv	a0,s1
    8000585c:	de0fe0ef          	jal	80003e3c <iunlockput>
  end_op();
    80005860:	e4dfe0ef          	jal	800046ac <end_op>
  return -1;
    80005864:	57fd                	li	a5,-1
    80005866:	64f2                	ld	s1,280(sp)
    80005868:	6952                	ld	s2,272(sp)
}
    8000586a:	853e                	mv	a0,a5
    8000586c:	70b2                	ld	ra,296(sp)
    8000586e:	7412                	ld	s0,288(sp)
    80005870:	6155                	addi	sp,sp,304
    80005872:	8082                	ret

0000000080005874 <sys_unlink>:
{
    80005874:	7151                	addi	sp,sp,-240
    80005876:	f586                	sd	ra,232(sp)
    80005878:	f1a2                	sd	s0,224(sp)
    8000587a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000587c:	08000613          	li	a2,128
    80005880:	f3040593          	addi	a1,s0,-208
    80005884:	4501                	li	a0,0
    80005886:	9edfd0ef          	jal	80003272 <argstr>
    8000588a:	14054d63          	bltz	a0,800059e4 <sys_unlink+0x170>
    8000588e:	eda6                	sd	s1,216(sp)
  begin_op();
    80005890:	dadfe0ef          	jal	8000463c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005894:	fb040593          	addi	a1,s0,-80
    80005898:	f3040513          	addi	a0,s0,-208
    8000589c:	bddfe0ef          	jal	80004478 <nameiparent>
    800058a0:	84aa                	mv	s1,a0
    800058a2:	c955                	beqz	a0,80005956 <sys_unlink+0xe2>
  ilock(dp);
    800058a4:	b8cfe0ef          	jal	80003c30 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058a8:	00003597          	auipc	a1,0x3
    800058ac:	1a058593          	addi	a1,a1,416 # 80008a48 <etext+0xa48>
    800058b0:	fb040513          	addi	a0,s0,-80
    800058b4:	901fe0ef          	jal	800041b4 <namecmp>
    800058b8:	10050b63          	beqz	a0,800059ce <sys_unlink+0x15a>
    800058bc:	00003597          	auipc	a1,0x3
    800058c0:	19458593          	addi	a1,a1,404 # 80008a50 <etext+0xa50>
    800058c4:	fb040513          	addi	a0,s0,-80
    800058c8:	8edfe0ef          	jal	800041b4 <namecmp>
    800058cc:	10050163          	beqz	a0,800059ce <sys_unlink+0x15a>
    800058d0:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058d2:	f2c40613          	addi	a2,s0,-212
    800058d6:	fb040593          	addi	a1,s0,-80
    800058da:	8526                	mv	a0,s1
    800058dc:	8effe0ef          	jal	800041ca <dirlookup>
    800058e0:	892a                	mv	s2,a0
    800058e2:	0e050563          	beqz	a0,800059cc <sys_unlink+0x158>
    800058e6:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800058e8:	b48fe0ef          	jal	80003c30 <ilock>
  if(ip->nlink < 1)
    800058ec:	04a91783          	lh	a5,74(s2)
    800058f0:	06f05863          	blez	a5,80005960 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058f4:	04491703          	lh	a4,68(s2)
    800058f8:	4785                	li	a5,1
    800058fa:	06f70963          	beq	a4,a5,8000596c <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800058fe:	fc040993          	addi	s3,s0,-64
    80005902:	4641                	li	a2,16
    80005904:	4581                	li	a1,0
    80005906:	854e                	mv	a0,s3
    80005908:	bf0fb0ef          	jal	80000cf8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000590c:	4741                	li	a4,16
    8000590e:	f2c42683          	lw	a3,-212(s0)
    80005912:	864e                	mv	a2,s3
    80005914:	4581                	li	a1,0
    80005916:	8526                	mv	a0,s1
    80005918:	f9cfe0ef          	jal	800040b4 <writei>
    8000591c:	47c1                	li	a5,16
    8000591e:	08f51863          	bne	a0,a5,800059ae <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005922:	04491703          	lh	a4,68(s2)
    80005926:	4785                	li	a5,1
    80005928:	08f70963          	beq	a4,a5,800059ba <sys_unlink+0x146>
  iunlockput(dp);
    8000592c:	8526                	mv	a0,s1
    8000592e:	d0efe0ef          	jal	80003e3c <iunlockput>
  ip->nlink--;
    80005932:	04a95783          	lhu	a5,74(s2)
    80005936:	37fd                	addiw	a5,a5,-1
    80005938:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000593c:	854a                	mv	a0,s2
    8000593e:	a3efe0ef          	jal	80003b7c <iupdate>
  iunlockput(ip);
    80005942:	854a                	mv	a0,s2
    80005944:	cf8fe0ef          	jal	80003e3c <iunlockput>
  end_op();
    80005948:	d65fe0ef          	jal	800046ac <end_op>
  return 0;
    8000594c:	4501                	li	a0,0
    8000594e:	64ee                	ld	s1,216(sp)
    80005950:	694e                	ld	s2,208(sp)
    80005952:	69ae                	ld	s3,200(sp)
    80005954:	a061                	j	800059dc <sys_unlink+0x168>
    end_op();
    80005956:	d57fe0ef          	jal	800046ac <end_op>
    return -1;
    8000595a:	557d                	li	a0,-1
    8000595c:	64ee                	ld	s1,216(sp)
    8000595e:	a8bd                	j	800059dc <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005960:	00003517          	auipc	a0,0x3
    80005964:	0f850513          	addi	a0,a0,248 # 80008a58 <etext+0xa58>
    80005968:	ebdfa0ef          	jal	80000824 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000596c:	04c92703          	lw	a4,76(s2)
    80005970:	02000793          	li	a5,32
    80005974:	f8e7f5e3          	bgeu	a5,a4,800058fe <sys_unlink+0x8a>
    80005978:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000597a:	4741                	li	a4,16
    8000597c:	86ce                	mv	a3,s3
    8000597e:	f1840613          	addi	a2,s0,-232
    80005982:	4581                	li	a1,0
    80005984:	854a                	mv	a0,s2
    80005986:	e3cfe0ef          	jal	80003fc2 <readi>
    8000598a:	47c1                	li	a5,16
    8000598c:	00f51b63          	bne	a0,a5,800059a2 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005990:	f1845783          	lhu	a5,-232(s0)
    80005994:	ebb1                	bnez	a5,800059e8 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005996:	29c1                	addiw	s3,s3,16
    80005998:	04c92783          	lw	a5,76(s2)
    8000599c:	fcf9efe3          	bltu	s3,a5,8000597a <sys_unlink+0x106>
    800059a0:	bfb9                	j	800058fe <sys_unlink+0x8a>
      panic("isdirempty: readi");
    800059a2:	00003517          	auipc	a0,0x3
    800059a6:	0ce50513          	addi	a0,a0,206 # 80008a70 <etext+0xa70>
    800059aa:	e7bfa0ef          	jal	80000824 <panic>
    panic("unlink: writei");
    800059ae:	00003517          	auipc	a0,0x3
    800059b2:	0da50513          	addi	a0,a0,218 # 80008a88 <etext+0xa88>
    800059b6:	e6ffa0ef          	jal	80000824 <panic>
    dp->nlink--;
    800059ba:	04a4d783          	lhu	a5,74(s1)
    800059be:	37fd                	addiw	a5,a5,-1
    800059c0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059c4:	8526                	mv	a0,s1
    800059c6:	9b6fe0ef          	jal	80003b7c <iupdate>
    800059ca:	b78d                	j	8000592c <sys_unlink+0xb8>
    800059cc:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800059ce:	8526                	mv	a0,s1
    800059d0:	c6cfe0ef          	jal	80003e3c <iunlockput>
  end_op();
    800059d4:	cd9fe0ef          	jal	800046ac <end_op>
  return -1;
    800059d8:	557d                	li	a0,-1
    800059da:	64ee                	ld	s1,216(sp)
}
    800059dc:	70ae                	ld	ra,232(sp)
    800059de:	740e                	ld	s0,224(sp)
    800059e0:	616d                	addi	sp,sp,240
    800059e2:	8082                	ret
    return -1;
    800059e4:	557d                	li	a0,-1
    800059e6:	bfdd                	j	800059dc <sys_unlink+0x168>
    iunlockput(ip);
    800059e8:	854a                	mv	a0,s2
    800059ea:	c52fe0ef          	jal	80003e3c <iunlockput>
    goto bad;
    800059ee:	694e                	ld	s2,208(sp)
    800059f0:	69ae                	ld	s3,200(sp)
    800059f2:	bff1                	j	800059ce <sys_unlink+0x15a>

00000000800059f4 <sys_open>:

uint64
sys_open(void)
{
    800059f4:	7131                	addi	sp,sp,-192
    800059f6:	fd06                	sd	ra,184(sp)
    800059f8:	f922                	sd	s0,176(sp)
    800059fa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059fc:	f4c40593          	addi	a1,s0,-180
    80005a00:	4505                	li	a0,1
    80005a02:	839fd0ef          	jal	8000323a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a06:	08000613          	li	a2,128
    80005a0a:	f5040593          	addi	a1,s0,-176
    80005a0e:	4501                	li	a0,0
    80005a10:	863fd0ef          	jal	80003272 <argstr>
    80005a14:	87aa                	mv	a5,a0
    return -1;
    80005a16:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a18:	0a07c363          	bltz	a5,80005abe <sys_open+0xca>
    80005a1c:	f526                	sd	s1,168(sp)

  begin_op();
    80005a1e:	c1ffe0ef          	jal	8000463c <begin_op>

  if(omode & O_CREATE){
    80005a22:	f4c42783          	lw	a5,-180(s0)
    80005a26:	2007f793          	andi	a5,a5,512
    80005a2a:	c3dd                	beqz	a5,80005ad0 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005a2c:	4681                	li	a3,0
    80005a2e:	4601                	li	a2,0
    80005a30:	4589                	li	a1,2
    80005a32:	f5040513          	addi	a0,s0,-176
    80005a36:	aafff0ef          	jal	800054e4 <create>
    80005a3a:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a3c:	c549                	beqz	a0,80005ac6 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a3e:	04449703          	lh	a4,68(s1)
    80005a42:	478d                	li	a5,3
    80005a44:	00f71763          	bne	a4,a5,80005a52 <sys_open+0x5e>
    80005a48:	0464d703          	lhu	a4,70(s1)
    80005a4c:	47a5                	li	a5,9
    80005a4e:	0ae7ee63          	bltu	a5,a4,80005b0a <sys_open+0x116>
    80005a52:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a54:	f69fe0ef          	jal	800049bc <filealloc>
    80005a58:	892a                	mv	s2,a0
    80005a5a:	c561                	beqz	a0,80005b22 <sys_open+0x12e>
    80005a5c:	ed4e                	sd	s3,152(sp)
    80005a5e:	a47ff0ef          	jal	800054a4 <fdalloc>
    80005a62:	89aa                	mv	s3,a0
    80005a64:	0a054b63          	bltz	a0,80005b1a <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a68:	04449703          	lh	a4,68(s1)
    80005a6c:	478d                	li	a5,3
    80005a6e:	0cf70363          	beq	a4,a5,80005b34 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a72:	4789                	li	a5,2
    80005a74:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a78:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a7c:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a80:	f4c42783          	lw	a5,-180(s0)
    80005a84:	0017f713          	andi	a4,a5,1
    80005a88:	00174713          	xori	a4,a4,1
    80005a8c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a90:	0037f713          	andi	a4,a5,3
    80005a94:	00e03733          	snez	a4,a4
    80005a98:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a9c:	4007f793          	andi	a5,a5,1024
    80005aa0:	c791                	beqz	a5,80005aac <sys_open+0xb8>
    80005aa2:	04449703          	lh	a4,68(s1)
    80005aa6:	4789                	li	a5,2
    80005aa8:	08f70d63          	beq	a4,a5,80005b42 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005aac:	8526                	mv	a0,s1
    80005aae:	a30fe0ef          	jal	80003cde <iunlock>
  end_op();
    80005ab2:	bfbfe0ef          	jal	800046ac <end_op>

  return fd;
    80005ab6:	854e                	mv	a0,s3
    80005ab8:	74aa                	ld	s1,168(sp)
    80005aba:	790a                	ld	s2,160(sp)
    80005abc:	69ea                	ld	s3,152(sp)
}
    80005abe:	70ea                	ld	ra,184(sp)
    80005ac0:	744a                	ld	s0,176(sp)
    80005ac2:	6129                	addi	sp,sp,192
    80005ac4:	8082                	ret
      end_op();
    80005ac6:	be7fe0ef          	jal	800046ac <end_op>
      return -1;
    80005aca:	557d                	li	a0,-1
    80005acc:	74aa                	ld	s1,168(sp)
    80005ace:	bfc5                	j	80005abe <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005ad0:	f5040513          	addi	a0,s0,-176
    80005ad4:	98bfe0ef          	jal	8000445e <namei>
    80005ad8:	84aa                	mv	s1,a0
    80005ada:	c11d                	beqz	a0,80005b00 <sys_open+0x10c>
    ilock(ip);
    80005adc:	954fe0ef          	jal	80003c30 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ae0:	04449703          	lh	a4,68(s1)
    80005ae4:	4785                	li	a5,1
    80005ae6:	f4f71ce3          	bne	a4,a5,80005a3e <sys_open+0x4a>
    80005aea:	f4c42783          	lw	a5,-180(s0)
    80005aee:	d3b5                	beqz	a5,80005a52 <sys_open+0x5e>
      iunlockput(ip);
    80005af0:	8526                	mv	a0,s1
    80005af2:	b4afe0ef          	jal	80003e3c <iunlockput>
      end_op();
    80005af6:	bb7fe0ef          	jal	800046ac <end_op>
      return -1;
    80005afa:	557d                	li	a0,-1
    80005afc:	74aa                	ld	s1,168(sp)
    80005afe:	b7c1                	j	80005abe <sys_open+0xca>
      end_op();
    80005b00:	badfe0ef          	jal	800046ac <end_op>
      return -1;
    80005b04:	557d                	li	a0,-1
    80005b06:	74aa                	ld	s1,168(sp)
    80005b08:	bf5d                	j	80005abe <sys_open+0xca>
    iunlockput(ip);
    80005b0a:	8526                	mv	a0,s1
    80005b0c:	b30fe0ef          	jal	80003e3c <iunlockput>
    end_op();
    80005b10:	b9dfe0ef          	jal	800046ac <end_op>
    return -1;
    80005b14:	557d                	li	a0,-1
    80005b16:	74aa                	ld	s1,168(sp)
    80005b18:	b75d                	j	80005abe <sys_open+0xca>
      fileclose(f);
    80005b1a:	854a                	mv	a0,s2
    80005b1c:	f45fe0ef          	jal	80004a60 <fileclose>
    80005b20:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005b22:	8526                	mv	a0,s1
    80005b24:	b18fe0ef          	jal	80003e3c <iunlockput>
    end_op();
    80005b28:	b85fe0ef          	jal	800046ac <end_op>
    return -1;
    80005b2c:	557d                	li	a0,-1
    80005b2e:	74aa                	ld	s1,168(sp)
    80005b30:	790a                	ld	s2,160(sp)
    80005b32:	b771                	j	80005abe <sys_open+0xca>
    f->type = FD_DEVICE;
    80005b34:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005b38:	04649783          	lh	a5,70(s1)
    80005b3c:	02f91223          	sh	a5,36(s2)
    80005b40:	bf35                	j	80005a7c <sys_open+0x88>
    itrunc(ip);
    80005b42:	8526                	mv	a0,s1
    80005b44:	9dafe0ef          	jal	80003d1e <itrunc>
    80005b48:	b795                	j	80005aac <sys_open+0xb8>

0000000080005b4a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b4a:	7175                	addi	sp,sp,-144
    80005b4c:	e506                	sd	ra,136(sp)
    80005b4e:	e122                	sd	s0,128(sp)
    80005b50:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b52:	aebfe0ef          	jal	8000463c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b56:	08000613          	li	a2,128
    80005b5a:	f7040593          	addi	a1,s0,-144
    80005b5e:	4501                	li	a0,0
    80005b60:	f12fd0ef          	jal	80003272 <argstr>
    80005b64:	02054363          	bltz	a0,80005b8a <sys_mkdir+0x40>
    80005b68:	4681                	li	a3,0
    80005b6a:	4601                	li	a2,0
    80005b6c:	4585                	li	a1,1
    80005b6e:	f7040513          	addi	a0,s0,-144
    80005b72:	973ff0ef          	jal	800054e4 <create>
    80005b76:	c911                	beqz	a0,80005b8a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b78:	ac4fe0ef          	jal	80003e3c <iunlockput>
  end_op();
    80005b7c:	b31fe0ef          	jal	800046ac <end_op>
  return 0;
    80005b80:	4501                	li	a0,0
}
    80005b82:	60aa                	ld	ra,136(sp)
    80005b84:	640a                	ld	s0,128(sp)
    80005b86:	6149                	addi	sp,sp,144
    80005b88:	8082                	ret
    end_op();
    80005b8a:	b23fe0ef          	jal	800046ac <end_op>
    return -1;
    80005b8e:	557d                	li	a0,-1
    80005b90:	bfcd                	j	80005b82 <sys_mkdir+0x38>

0000000080005b92 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b92:	7135                	addi	sp,sp,-160
    80005b94:	ed06                	sd	ra,152(sp)
    80005b96:	e922                	sd	s0,144(sp)
    80005b98:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b9a:	aa3fe0ef          	jal	8000463c <begin_op>
  argint(1, &major);
    80005b9e:	f6c40593          	addi	a1,s0,-148
    80005ba2:	4505                	li	a0,1
    80005ba4:	e96fd0ef          	jal	8000323a <argint>
  argint(2, &minor);
    80005ba8:	f6840593          	addi	a1,s0,-152
    80005bac:	4509                	li	a0,2
    80005bae:	e8cfd0ef          	jal	8000323a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bb2:	08000613          	li	a2,128
    80005bb6:	f7040593          	addi	a1,s0,-144
    80005bba:	4501                	li	a0,0
    80005bbc:	eb6fd0ef          	jal	80003272 <argstr>
    80005bc0:	02054563          	bltz	a0,80005bea <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bc4:	f6841683          	lh	a3,-152(s0)
    80005bc8:	f6c41603          	lh	a2,-148(s0)
    80005bcc:	458d                	li	a1,3
    80005bce:	f7040513          	addi	a0,s0,-144
    80005bd2:	913ff0ef          	jal	800054e4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bd6:	c911                	beqz	a0,80005bea <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bd8:	a64fe0ef          	jal	80003e3c <iunlockput>
  end_op();
    80005bdc:	ad1fe0ef          	jal	800046ac <end_op>
  return 0;
    80005be0:	4501                	li	a0,0
}
    80005be2:	60ea                	ld	ra,152(sp)
    80005be4:	644a                	ld	s0,144(sp)
    80005be6:	610d                	addi	sp,sp,160
    80005be8:	8082                	ret
    end_op();
    80005bea:	ac3fe0ef          	jal	800046ac <end_op>
    return -1;
    80005bee:	557d                	li	a0,-1
    80005bf0:	bfcd                	j	80005be2 <sys_mknod+0x50>

0000000080005bf2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bf2:	7135                	addi	sp,sp,-160
    80005bf4:	ed06                	sd	ra,152(sp)
    80005bf6:	e922                	sd	s0,144(sp)
    80005bf8:	e14a                	sd	s2,128(sp)
    80005bfa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bfc:	ebbfb0ef          	jal	80001ab6 <myproc>
    80005c00:	892a                	mv	s2,a0
  
  begin_op();
    80005c02:	a3bfe0ef          	jal	8000463c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c06:	08000613          	li	a2,128
    80005c0a:	f6040593          	addi	a1,s0,-160
    80005c0e:	4501                	li	a0,0
    80005c10:	e62fd0ef          	jal	80003272 <argstr>
    80005c14:	04054363          	bltz	a0,80005c5a <sys_chdir+0x68>
    80005c18:	e526                	sd	s1,136(sp)
    80005c1a:	f6040513          	addi	a0,s0,-160
    80005c1e:	841fe0ef          	jal	8000445e <namei>
    80005c22:	84aa                	mv	s1,a0
    80005c24:	c915                	beqz	a0,80005c58 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c26:	80afe0ef          	jal	80003c30 <ilock>
  if(ip->type != T_DIR){
    80005c2a:	04449703          	lh	a4,68(s1)
    80005c2e:	4785                	li	a5,1
    80005c30:	02f71963          	bne	a4,a5,80005c62 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c34:	8526                	mv	a0,s1
    80005c36:	8a8fe0ef          	jal	80003cde <iunlock>
  iput(p->cwd);
    80005c3a:	15893503          	ld	a0,344(s2)
    80005c3e:	974fe0ef          	jal	80003db2 <iput>
  end_op();
    80005c42:	a6bfe0ef          	jal	800046ac <end_op>
  p->cwd = ip;
    80005c46:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c4a:	4501                	li	a0,0
    80005c4c:	64aa                	ld	s1,136(sp)
}
    80005c4e:	60ea                	ld	ra,152(sp)
    80005c50:	644a                	ld	s0,144(sp)
    80005c52:	690a                	ld	s2,128(sp)
    80005c54:	610d                	addi	sp,sp,160
    80005c56:	8082                	ret
    80005c58:	64aa                	ld	s1,136(sp)
    end_op();
    80005c5a:	a53fe0ef          	jal	800046ac <end_op>
    return -1;
    80005c5e:	557d                	li	a0,-1
    80005c60:	b7fd                	j	80005c4e <sys_chdir+0x5c>
    iunlockput(ip);
    80005c62:	8526                	mv	a0,s1
    80005c64:	9d8fe0ef          	jal	80003e3c <iunlockput>
    end_op();
    80005c68:	a45fe0ef          	jal	800046ac <end_op>
    return -1;
    80005c6c:	557d                	li	a0,-1
    80005c6e:	64aa                	ld	s1,136(sp)
    80005c70:	bff9                	j	80005c4e <sys_chdir+0x5c>

0000000080005c72 <sys_exec>:

uint64
sys_exec(void)
{
    80005c72:	7105                	addi	sp,sp,-480
    80005c74:	ef86                	sd	ra,472(sp)
    80005c76:	eba2                	sd	s0,464(sp)
    80005c78:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005c7a:	e2840593          	addi	a1,s0,-472
    80005c7e:	4505                	li	a0,1
    80005c80:	dd6fd0ef          	jal	80003256 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c84:	08000613          	li	a2,128
    80005c88:	f3040593          	addi	a1,s0,-208
    80005c8c:	4501                	li	a0,0
    80005c8e:	de4fd0ef          	jal	80003272 <argstr>
    80005c92:	87aa                	mv	a5,a0
    return -1;
    80005c94:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c96:	0e07c063          	bltz	a5,80005d76 <sys_exec+0x104>
    80005c9a:	e7a6                	sd	s1,456(sp)
    80005c9c:	e3ca                	sd	s2,448(sp)
    80005c9e:	ff4e                	sd	s3,440(sp)
    80005ca0:	fb52                	sd	s4,432(sp)
    80005ca2:	f756                	sd	s5,424(sp)
    80005ca4:	f35a                	sd	s6,416(sp)
    80005ca6:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005ca8:	e3040a13          	addi	s4,s0,-464
    80005cac:	10000613          	li	a2,256
    80005cb0:	4581                	li	a1,0
    80005cb2:	8552                	mv	a0,s4
    80005cb4:	844fb0ef          	jal	80000cf8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cb8:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005cba:	89d2                	mv	s3,s4
    80005cbc:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cbe:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cc2:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005cc4:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cc8:	00391513          	slli	a0,s2,0x3
    80005ccc:	85d6                	mv	a1,s5
    80005cce:	e2843783          	ld	a5,-472(s0)
    80005cd2:	953e                	add	a0,a0,a5
    80005cd4:	cdcfd0ef          	jal	800031b0 <fetchaddr>
    80005cd8:	02054663          	bltz	a0,80005d04 <sys_exec+0x92>
    if(uarg == 0){
    80005cdc:	e2043783          	ld	a5,-480(s0)
    80005ce0:	c7a1                	beqz	a5,80005d28 <sys_exec+0xb6>
    argv[i] = kalloc();
    80005ce2:	e63fa0ef          	jal	80000b44 <kalloc>
    80005ce6:	85aa                	mv	a1,a0
    80005ce8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cec:	cd01                	beqz	a0,80005d04 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cee:	865a                	mv	a2,s6
    80005cf0:	e2043503          	ld	a0,-480(s0)
    80005cf4:	d06fd0ef          	jal	800031fa <fetchstr>
    80005cf8:	00054663          	bltz	a0,80005d04 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005cfc:	0905                	addi	s2,s2,1
    80005cfe:	09a1                	addi	s3,s3,8
    80005d00:	fd7914e3          	bne	s2,s7,80005cc8 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d04:	100a0a13          	addi	s4,s4,256
    80005d08:	6088                	ld	a0,0(s1)
    80005d0a:	cd31                	beqz	a0,80005d66 <sys_exec+0xf4>
    kfree(argv[i]);
    80005d0c:	d51fa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d10:	04a1                	addi	s1,s1,8
    80005d12:	ff449be3          	bne	s1,s4,80005d08 <sys_exec+0x96>
  return -1;
    80005d16:	557d                	li	a0,-1
    80005d18:	64be                	ld	s1,456(sp)
    80005d1a:	691e                	ld	s2,448(sp)
    80005d1c:	79fa                	ld	s3,440(sp)
    80005d1e:	7a5a                	ld	s4,432(sp)
    80005d20:	7aba                	ld	s5,424(sp)
    80005d22:	7b1a                	ld	s6,416(sp)
    80005d24:	6bfa                	ld	s7,408(sp)
    80005d26:	a881                	j	80005d76 <sys_exec+0x104>
      argv[i] = 0;
    80005d28:	0009079b          	sext.w	a5,s2
    80005d2c:	e3040593          	addi	a1,s0,-464
    80005d30:	078e                	slli	a5,a5,0x3
    80005d32:	97ae                	add	a5,a5,a1
    80005d34:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005d38:	f3040513          	addi	a0,s0,-208
    80005d3c:	bb2ff0ef          	jal	800050ee <kexec>
    80005d40:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d42:	100a0a13          	addi	s4,s4,256
    80005d46:	6088                	ld	a0,0(s1)
    80005d48:	c511                	beqz	a0,80005d54 <sys_exec+0xe2>
    kfree(argv[i]);
    80005d4a:	d13fa0ef          	jal	80000a5c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4e:	04a1                	addi	s1,s1,8
    80005d50:	ff449be3          	bne	s1,s4,80005d46 <sys_exec+0xd4>
  return ret;
    80005d54:	854a                	mv	a0,s2
    80005d56:	64be                	ld	s1,456(sp)
    80005d58:	691e                	ld	s2,448(sp)
    80005d5a:	79fa                	ld	s3,440(sp)
    80005d5c:	7a5a                	ld	s4,432(sp)
    80005d5e:	7aba                	ld	s5,424(sp)
    80005d60:	7b1a                	ld	s6,416(sp)
    80005d62:	6bfa                	ld	s7,408(sp)
    80005d64:	a809                	j	80005d76 <sys_exec+0x104>
  return -1;
    80005d66:	557d                	li	a0,-1
    80005d68:	64be                	ld	s1,456(sp)
    80005d6a:	691e                	ld	s2,448(sp)
    80005d6c:	79fa                	ld	s3,440(sp)
    80005d6e:	7a5a                	ld	s4,432(sp)
    80005d70:	7aba                	ld	s5,424(sp)
    80005d72:	7b1a                	ld	s6,416(sp)
    80005d74:	6bfa                	ld	s7,408(sp)
}
    80005d76:	60fe                	ld	ra,472(sp)
    80005d78:	645e                	ld	s0,464(sp)
    80005d7a:	613d                	addi	sp,sp,480
    80005d7c:	8082                	ret

0000000080005d7e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d7e:	7139                	addi	sp,sp,-64
    80005d80:	fc06                	sd	ra,56(sp)
    80005d82:	f822                	sd	s0,48(sp)
    80005d84:	f426                	sd	s1,40(sp)
    80005d86:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d88:	d2ffb0ef          	jal	80001ab6 <myproc>
    80005d8c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d8e:	fd840593          	addi	a1,s0,-40
    80005d92:	4501                	li	a0,0
    80005d94:	cc2fd0ef          	jal	80003256 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d98:	fc840593          	addi	a1,s0,-56
    80005d9c:	fd040513          	addi	a0,s0,-48
    80005da0:	fddfe0ef          	jal	80004d7c <pipealloc>
    return -1;
    80005da4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005da6:	0a054763          	bltz	a0,80005e54 <sys_pipe+0xd6>
  fd0 = -1;
    80005daa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dae:	fd043503          	ld	a0,-48(s0)
    80005db2:	ef2ff0ef          	jal	800054a4 <fdalloc>
    80005db6:	fca42223          	sw	a0,-60(s0)
    80005dba:	08054463          	bltz	a0,80005e42 <sys_pipe+0xc4>
    80005dbe:	fc843503          	ld	a0,-56(s0)
    80005dc2:	ee2ff0ef          	jal	800054a4 <fdalloc>
    80005dc6:	fca42023          	sw	a0,-64(s0)
    80005dca:	06054263          	bltz	a0,80005e2e <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dce:	4691                	li	a3,4
    80005dd0:	fc440613          	addi	a2,s0,-60
    80005dd4:	fd843583          	ld	a1,-40(s0)
    80005dd8:	6ca8                	ld	a0,88(s1)
    80005dda:	87bfb0ef          	jal	80001654 <copyout>
    80005dde:	00054e63          	bltz	a0,80005dfa <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005de2:	4691                	li	a3,4
    80005de4:	fc040613          	addi	a2,s0,-64
    80005de8:	fd843583          	ld	a1,-40(s0)
    80005dec:	95b6                	add	a1,a1,a3
    80005dee:	6ca8                	ld	a0,88(s1)
    80005df0:	865fb0ef          	jal	80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005df4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005df6:	04055f63          	bgez	a0,80005e54 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005dfa:	fc442783          	lw	a5,-60(s0)
    80005dfe:	078e                	slli	a5,a5,0x3
    80005e00:	0d078793          	addi	a5,a5,208
    80005e04:	97a6                	add	a5,a5,s1
    80005e06:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e0a:	fc042783          	lw	a5,-64(s0)
    80005e0e:	078e                	slli	a5,a5,0x3
    80005e10:	0d078793          	addi	a5,a5,208
    80005e14:	97a6                	add	a5,a5,s1
    80005e16:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e1a:	fd043503          	ld	a0,-48(s0)
    80005e1e:	c43fe0ef          	jal	80004a60 <fileclose>
    fileclose(wf);
    80005e22:	fc843503          	ld	a0,-56(s0)
    80005e26:	c3bfe0ef          	jal	80004a60 <fileclose>
    return -1;
    80005e2a:	57fd                	li	a5,-1
    80005e2c:	a025                	j	80005e54 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005e2e:	fc442783          	lw	a5,-60(s0)
    80005e32:	0007c863          	bltz	a5,80005e42 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005e36:	078e                	slli	a5,a5,0x3
    80005e38:	0d078793          	addi	a5,a5,208
    80005e3c:	97a6                	add	a5,a5,s1
    80005e3e:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e42:	fd043503          	ld	a0,-48(s0)
    80005e46:	c1bfe0ef          	jal	80004a60 <fileclose>
    fileclose(wf);
    80005e4a:	fc843503          	ld	a0,-56(s0)
    80005e4e:	c13fe0ef          	jal	80004a60 <fileclose>
    return -1;
    80005e52:	57fd                	li	a5,-1
}
    80005e54:	853e                	mv	a0,a5
    80005e56:	70e2                	ld	ra,56(sp)
    80005e58:	7442                	ld	s0,48(sp)
    80005e5a:	74a2                	ld	s1,40(sp)
    80005e5c:	6121                	addi	sp,sp,64
    80005e5e:	8082                	ret

0000000080005e60 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005e60:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005e62:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005e64:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005e66:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005e68:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005e6a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005e6c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005e6e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005e70:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005e72:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005e74:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005e76:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005e78:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005e7a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005e7c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005e7e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005e80:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005e82:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005e84:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005e86:	a38fd0ef          	jal	800030be <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005e8a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005e8c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005e8e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005e90:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005e92:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005e94:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005e96:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005e98:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005e9a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005e9c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005e9e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005ea0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005ea2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005ea4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005ea6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005ea8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005eaa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005eac:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005eae:	10200073          	sret
    80005eb2:	00000013          	nop
    80005eb6:	00000013          	nop
    80005eba:	00000013          	nop

0000000080005ebe <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005ebe:	1141                	addi	sp,sp,-16
    80005ec0:	e406                	sd	ra,8(sp)
    80005ec2:	e022                	sd	s0,0(sp)
    80005ec4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ec6:	0c000737          	lui	a4,0xc000
    80005eca:	4785                	li	a5,1
    80005ecc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ece:	c35c                	sw	a5,4(a4)
}
    80005ed0:	60a2                	ld	ra,8(sp)
    80005ed2:	6402                	ld	s0,0(sp)
    80005ed4:	0141                	addi	sp,sp,16
    80005ed6:	8082                	ret

0000000080005ed8 <plicinithart>:

void
plicinithart(void)
{
    80005ed8:	1141                	addi	sp,sp,-16
    80005eda:	e406                	sd	ra,8(sp)
    80005edc:	e022                	sd	s0,0(sp)
    80005ede:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee0:	ba3fb0ef          	jal	80001a82 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ee4:	0085171b          	slliw	a4,a0,0x8
    80005ee8:	0c0027b7          	lui	a5,0xc002
    80005eec:	97ba                	add	a5,a5,a4
    80005eee:	40200713          	li	a4,1026
    80005ef2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ef6:	00d5151b          	slliw	a0,a0,0xd
    80005efa:	0c2017b7          	lui	a5,0xc201
    80005efe:	97aa                	add	a5,a5,a0
    80005f00:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f04:	60a2                	ld	ra,8(sp)
    80005f06:	6402                	ld	s0,0(sp)
    80005f08:	0141                	addi	sp,sp,16
    80005f0a:	8082                	ret

0000000080005f0c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f0c:	1141                	addi	sp,sp,-16
    80005f0e:	e406                	sd	ra,8(sp)
    80005f10:	e022                	sd	s0,0(sp)
    80005f12:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f14:	b6ffb0ef          	jal	80001a82 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f18:	00d5151b          	slliw	a0,a0,0xd
    80005f1c:	0c2017b7          	lui	a5,0xc201
    80005f20:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f22:	43c8                	lw	a0,4(a5)
    80005f24:	60a2                	ld	ra,8(sp)
    80005f26:	6402                	ld	s0,0(sp)
    80005f28:	0141                	addi	sp,sp,16
    80005f2a:	8082                	ret

0000000080005f2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f2c:	1101                	addi	sp,sp,-32
    80005f2e:	ec06                	sd	ra,24(sp)
    80005f30:	e822                	sd	s0,16(sp)
    80005f32:	e426                	sd	s1,8(sp)
    80005f34:	1000                	addi	s0,sp,32
    80005f36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f38:	b4bfb0ef          	jal	80001a82 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f3c:	00d5179b          	slliw	a5,a0,0xd
    80005f40:	0c201737          	lui	a4,0xc201
    80005f44:	97ba                	add	a5,a5,a4
    80005f46:	c3c4                	sw	s1,4(a5)
}
    80005f48:	60e2                	ld	ra,24(sp)
    80005f4a:	6442                	ld	s0,16(sp)
    80005f4c:	64a2                	ld	s1,8(sp)
    80005f4e:	6105                	addi	sp,sp,32
    80005f50:	8082                	ret

0000000080005f52 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f52:	1141                	addi	sp,sp,-16
    80005f54:	e406                	sd	ra,8(sp)
    80005f56:	e022                	sd	s0,0(sp)
    80005f58:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f5a:	479d                	li	a5,7
    80005f5c:	04a7ca63          	blt	a5,a0,80005fb0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005f60:	0001f797          	auipc	a5,0x1f
    80005f64:	e8878793          	addi	a5,a5,-376 # 80024de8 <disk>
    80005f68:	97aa                	add	a5,a5,a0
    80005f6a:	0187c783          	lbu	a5,24(a5)
    80005f6e:	e7b9                	bnez	a5,80005fbc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f70:	00451693          	slli	a3,a0,0x4
    80005f74:	0001f797          	auipc	a5,0x1f
    80005f78:	e7478793          	addi	a5,a5,-396 # 80024de8 <disk>
    80005f7c:	6398                	ld	a4,0(a5)
    80005f7e:	9736                	add	a4,a4,a3
    80005f80:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005f84:	6398                	ld	a4,0(a5)
    80005f86:	9736                	add	a4,a4,a3
    80005f88:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f8c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f90:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f94:	97aa                	add	a5,a5,a0
    80005f96:	4705                	li	a4,1
    80005f98:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005f9c:	0001f517          	auipc	a0,0x1f
    80005fa0:	e6450513          	addi	a0,a0,-412 # 80024e00 <disk+0x18>
    80005fa4:	fd2fc0ef          	jal	80002776 <wakeup>
}
    80005fa8:	60a2                	ld	ra,8(sp)
    80005faa:	6402                	ld	s0,0(sp)
    80005fac:	0141                	addi	sp,sp,16
    80005fae:	8082                	ret
    panic("free_desc 1");
    80005fb0:	00003517          	auipc	a0,0x3
    80005fb4:	ae850513          	addi	a0,a0,-1304 # 80008a98 <etext+0xa98>
    80005fb8:	86dfa0ef          	jal	80000824 <panic>
    panic("free_desc 2");
    80005fbc:	00003517          	auipc	a0,0x3
    80005fc0:	aec50513          	addi	a0,a0,-1300 # 80008aa8 <etext+0xaa8>
    80005fc4:	861fa0ef          	jal	80000824 <panic>

0000000080005fc8 <virtio_disk_init>:
{
    80005fc8:	1101                	addi	sp,sp,-32
    80005fca:	ec06                	sd	ra,24(sp)
    80005fcc:	e822                	sd	s0,16(sp)
    80005fce:	e426                	sd	s1,8(sp)
    80005fd0:	e04a                	sd	s2,0(sp)
    80005fd2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fd4:	00003597          	auipc	a1,0x3
    80005fd8:	ae458593          	addi	a1,a1,-1308 # 80008ab8 <etext+0xab8>
    80005fdc:	0001f517          	auipc	a0,0x1f
    80005fe0:	f3450513          	addi	a0,a0,-204 # 80024f10 <disk+0x128>
    80005fe4:	bbbfa0ef          	jal	80000b9e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fe8:	100017b7          	lui	a5,0x10001
    80005fec:	4398                	lw	a4,0(a5)
    80005fee:	2701                	sext.w	a4,a4
    80005ff0:	747277b7          	lui	a5,0x74727
    80005ff4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ff8:	14f71863          	bne	a4,a5,80006148 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	43dc                	lw	a5,4(a5)
    80006002:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006004:	4709                	li	a4,2
    80006006:	14e79163          	bne	a5,a4,80006148 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000600a:	100017b7          	lui	a5,0x10001
    8000600e:	479c                	lw	a5,8(a5)
    80006010:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006012:	12e79b63          	bne	a5,a4,80006148 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006016:	100017b7          	lui	a5,0x10001
    8000601a:	47d8                	lw	a4,12(a5)
    8000601c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000601e:	554d47b7          	lui	a5,0x554d4
    80006022:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006026:	12f71163          	bne	a4,a5,80006148 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602a:	100017b7          	lui	a5,0x10001
    8000602e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006032:	4705                	li	a4,1
    80006034:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006036:	470d                	li	a4,3
    80006038:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000603a:	10001737          	lui	a4,0x10001
    8000603e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006040:	c7ffe6b7          	lui	a3,0xc7ffe
    80006044:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9837>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006048:	8f75                	and	a4,a4,a3
    8000604a:	100016b7          	lui	a3,0x10001
    8000604e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006050:	472d                	li	a4,11
    80006052:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006054:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006058:	439c                	lw	a5,0(a5)
    8000605a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000605e:	8ba1                	andi	a5,a5,8
    80006060:	0e078a63          	beqz	a5,80006154 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006064:	100017b7          	lui	a5,0x10001
    80006068:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000606c:	43fc                	lw	a5,68(a5)
    8000606e:	2781                	sext.w	a5,a5
    80006070:	0e079863          	bnez	a5,80006160 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006074:	100017b7          	lui	a5,0x10001
    80006078:	5bdc                	lw	a5,52(a5)
    8000607a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000607c:	0e078863          	beqz	a5,8000616c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80006080:	471d                	li	a4,7
    80006082:	0ef77b63          	bgeu	a4,a5,80006178 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80006086:	abffa0ef          	jal	80000b44 <kalloc>
    8000608a:	0001f497          	auipc	s1,0x1f
    8000608e:	d5e48493          	addi	s1,s1,-674 # 80024de8 <disk>
    80006092:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006094:	ab1fa0ef          	jal	80000b44 <kalloc>
    80006098:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000609a:	aabfa0ef          	jal	80000b44 <kalloc>
    8000609e:	87aa                	mv	a5,a0
    800060a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060a2:	6088                	ld	a0,0(s1)
    800060a4:	0e050063          	beqz	a0,80006184 <virtio_disk_init+0x1bc>
    800060a8:	0001f717          	auipc	a4,0x1f
    800060ac:	d4873703          	ld	a4,-696(a4) # 80024df0 <disk+0x8>
    800060b0:	cb71                	beqz	a4,80006184 <virtio_disk_init+0x1bc>
    800060b2:	cbe9                	beqz	a5,80006184 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800060b4:	6605                	lui	a2,0x1
    800060b6:	4581                	li	a1,0
    800060b8:	c41fa0ef          	jal	80000cf8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060bc:	0001f497          	auipc	s1,0x1f
    800060c0:	d2c48493          	addi	s1,s1,-724 # 80024de8 <disk>
    800060c4:	6605                	lui	a2,0x1
    800060c6:	4581                	li	a1,0
    800060c8:	6488                	ld	a0,8(s1)
    800060ca:	c2ffa0ef          	jal	80000cf8 <memset>
  memset(disk.used, 0, PGSIZE);
    800060ce:	6605                	lui	a2,0x1
    800060d0:	4581                	li	a1,0
    800060d2:	6888                	ld	a0,16(s1)
    800060d4:	c25fa0ef          	jal	80000cf8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060d8:	100017b7          	lui	a5,0x10001
    800060dc:	4721                	li	a4,8
    800060de:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060e0:	4098                	lw	a4,0(s1)
    800060e2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800060e6:	40d8                	lw	a4,4(s1)
    800060e8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800060ec:	649c                	ld	a5,8(s1)
    800060ee:	0007869b          	sext.w	a3,a5
    800060f2:	10001737          	lui	a4,0x10001
    800060f6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060fa:	9781                	srai	a5,a5,0x20
    800060fc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006100:	689c                	ld	a5,16(s1)
    80006102:	0007869b          	sext.w	a3,a5
    80006106:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000610a:	9781                	srai	a5,a5,0x20
    8000610c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006110:	4785                	li	a5,1
    80006112:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006114:	00f48c23          	sb	a5,24(s1)
    80006118:	00f48ca3          	sb	a5,25(s1)
    8000611c:	00f48d23          	sb	a5,26(s1)
    80006120:	00f48da3          	sb	a5,27(s1)
    80006124:	00f48e23          	sb	a5,28(s1)
    80006128:	00f48ea3          	sb	a5,29(s1)
    8000612c:	00f48f23          	sb	a5,30(s1)
    80006130:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006134:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006138:	07272823          	sw	s2,112(a4)
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6902                	ld	s2,0(sp)
    80006144:	6105                	addi	sp,sp,32
    80006146:	8082                	ret
    panic("could not find virtio disk");
    80006148:	00003517          	auipc	a0,0x3
    8000614c:	98050513          	addi	a0,a0,-1664 # 80008ac8 <etext+0xac8>
    80006150:	ed4fa0ef          	jal	80000824 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006154:	00003517          	auipc	a0,0x3
    80006158:	99450513          	addi	a0,a0,-1644 # 80008ae8 <etext+0xae8>
    8000615c:	ec8fa0ef          	jal	80000824 <panic>
    panic("virtio disk should not be ready");
    80006160:	00003517          	auipc	a0,0x3
    80006164:	9a850513          	addi	a0,a0,-1624 # 80008b08 <etext+0xb08>
    80006168:	ebcfa0ef          	jal	80000824 <panic>
    panic("virtio disk has no queue 0");
    8000616c:	00003517          	auipc	a0,0x3
    80006170:	9bc50513          	addi	a0,a0,-1604 # 80008b28 <etext+0xb28>
    80006174:	eb0fa0ef          	jal	80000824 <panic>
    panic("virtio disk max queue too short");
    80006178:	00003517          	auipc	a0,0x3
    8000617c:	9d050513          	addi	a0,a0,-1584 # 80008b48 <etext+0xb48>
    80006180:	ea4fa0ef          	jal	80000824 <panic>
    panic("virtio disk kalloc");
    80006184:	00003517          	auipc	a0,0x3
    80006188:	9e450513          	addi	a0,a0,-1564 # 80008b68 <etext+0xb68>
    8000618c:	e98fa0ef          	jal	80000824 <panic>

0000000080006190 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006190:	711d                	addi	sp,sp,-96
    80006192:	ec86                	sd	ra,88(sp)
    80006194:	e8a2                	sd	s0,80(sp)
    80006196:	e4a6                	sd	s1,72(sp)
    80006198:	e0ca                	sd	s2,64(sp)
    8000619a:	fc4e                	sd	s3,56(sp)
    8000619c:	f852                	sd	s4,48(sp)
    8000619e:	f456                	sd	s5,40(sp)
    800061a0:	f05a                	sd	s6,32(sp)
    800061a2:	ec5e                	sd	s7,24(sp)
    800061a4:	e862                	sd	s8,16(sp)
    800061a6:	1080                	addi	s0,sp,96
    800061a8:	89aa                	mv	s3,a0
    800061aa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061ac:	00c52b83          	lw	s7,12(a0)
    800061b0:	001b9b9b          	slliw	s7,s7,0x1
    800061b4:	1b82                	slli	s7,s7,0x20
    800061b6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800061ba:	0001f517          	auipc	a0,0x1f
    800061be:	d5650513          	addi	a0,a0,-682 # 80024f10 <disk+0x128>
    800061c2:	a67fa0ef          	jal	80000c28 <acquire>
  for(int i = 0; i < NUM; i++){
    800061c6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061c8:	0001fa97          	auipc	s5,0x1f
    800061cc:	c20a8a93          	addi	s5,s5,-992 # 80024de8 <disk>
  for(int i = 0; i < 3; i++){
    800061d0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800061d2:	5c7d                	li	s8,-1
    800061d4:	a095                	j	80006238 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800061d6:	00fa8733          	add	a4,s5,a5
    800061da:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061de:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061e0:	0207c563          	bltz	a5,8000620a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800061e4:	2905                	addiw	s2,s2,1
    800061e6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800061e8:	05490c63          	beq	s2,s4,80006240 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800061ec:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061ee:	0001f717          	auipc	a4,0x1f
    800061f2:	bfa70713          	addi	a4,a4,-1030 # 80024de8 <disk>
    800061f6:	4781                	li	a5,0
    if(disk.free[i]){
    800061f8:	01874683          	lbu	a3,24(a4)
    800061fc:	fee9                	bnez	a3,800061d6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800061fe:	2785                	addiw	a5,a5,1
    80006200:	0705                	addi	a4,a4,1
    80006202:	fe979be3          	bne	a5,s1,800061f8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80006206:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000620a:	01205d63          	blez	s2,80006224 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000620e:	fa042503          	lw	a0,-96(s0)
    80006212:	d41ff0ef          	jal	80005f52 <free_desc>
      for(int j = 0; j < i; j++)
    80006216:	4785                	li	a5,1
    80006218:	0127d663          	bge	a5,s2,80006224 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000621c:	fa442503          	lw	a0,-92(s0)
    80006220:	d33ff0ef          	jal	80005f52 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006224:	0001f597          	auipc	a1,0x1f
    80006228:	cec58593          	addi	a1,a1,-788 # 80024f10 <disk+0x128>
    8000622c:	0001f517          	auipc	a0,0x1f
    80006230:	bd450513          	addi	a0,a0,-1068 # 80024e00 <disk+0x18>
    80006234:	cf6fc0ef          	jal	8000272a <sleep>
  for(int i = 0; i < 3; i++){
    80006238:	fa040613          	addi	a2,s0,-96
    8000623c:	4901                	li	s2,0
    8000623e:	b77d                	j	800061ec <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006240:	fa042503          	lw	a0,-96(s0)
    80006244:	00451693          	slli	a3,a0,0x4

  if(write)
    80006248:	0001f797          	auipc	a5,0x1f
    8000624c:	ba078793          	addi	a5,a5,-1120 # 80024de8 <disk>
    80006250:	00451713          	slli	a4,a0,0x4
    80006254:	0a070713          	addi	a4,a4,160
    80006258:	973e                	add	a4,a4,a5
    8000625a:	01603633          	snez	a2,s6
    8000625e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006260:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006264:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006268:	6398                	ld	a4,0(a5)
    8000626a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000626c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006270:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006272:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006274:	6390                	ld	a2,0(a5)
    80006276:	00d60833          	add	a6,a2,a3
    8000627a:	4741                	li	a4,16
    8000627c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006280:	4585                	li	a1,1
    80006282:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80006286:	fa442703          	lw	a4,-92(s0)
    8000628a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000628e:	0712                	slli	a4,a4,0x4
    80006290:	963a                	add	a2,a2,a4
    80006292:	05898813          	addi	a6,s3,88
    80006296:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000629a:	0007b883          	ld	a7,0(a5)
    8000629e:	9746                	add	a4,a4,a7
    800062a0:	40000613          	li	a2,1024
    800062a4:	c710                	sw	a2,8(a4)
  if(write)
    800062a6:	001b3613          	seqz	a2,s6
    800062aa:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062ae:	8e4d                	or	a2,a2,a1
    800062b0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800062b4:	fa842603          	lw	a2,-88(s0)
    800062b8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062bc:	00451813          	slli	a6,a0,0x4
    800062c0:	02080813          	addi	a6,a6,32
    800062c4:	983e                	add	a6,a6,a5
    800062c6:	577d                	li	a4,-1
    800062c8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062cc:	0612                	slli	a2,a2,0x4
    800062ce:	98b2                	add	a7,a7,a2
    800062d0:	03068713          	addi	a4,a3,48
    800062d4:	973e                	add	a4,a4,a5
    800062d6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800062da:	6398                	ld	a4,0(a5)
    800062dc:	9732                	add	a4,a4,a2
    800062de:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062e0:	4689                	li	a3,2
    800062e2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800062e6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062ea:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    800062ee:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062f2:	6794                	ld	a3,8(a5)
    800062f4:	0026d703          	lhu	a4,2(a3)
    800062f8:	8b1d                	andi	a4,a4,7
    800062fa:	0706                	slli	a4,a4,0x1
    800062fc:	96ba                	add	a3,a3,a4
    800062fe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006302:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006306:	6798                	ld	a4,8(a5)
    80006308:	00275783          	lhu	a5,2(a4)
    8000630c:	2785                	addiw	a5,a5,1
    8000630e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006312:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006316:	100017b7          	lui	a5,0x10001
    8000631a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000631e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006322:	0001f917          	auipc	s2,0x1f
    80006326:	bee90913          	addi	s2,s2,-1042 # 80024f10 <disk+0x128>
  while(b->disk == 1) {
    8000632a:	84ae                	mv	s1,a1
    8000632c:	00b79a63          	bne	a5,a1,80006340 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006330:	85ca                	mv	a1,s2
    80006332:	854e                	mv	a0,s3
    80006334:	bf6fc0ef          	jal	8000272a <sleep>
  while(b->disk == 1) {
    80006338:	0049a783          	lw	a5,4(s3)
    8000633c:	fe978ae3          	beq	a5,s1,80006330 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006340:	fa042903          	lw	s2,-96(s0)
    80006344:	00491713          	slli	a4,s2,0x4
    80006348:	02070713          	addi	a4,a4,32
    8000634c:	0001f797          	auipc	a5,0x1f
    80006350:	a9c78793          	addi	a5,a5,-1380 # 80024de8 <disk>
    80006354:	97ba                	add	a5,a5,a4
    80006356:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000635a:	0001f997          	auipc	s3,0x1f
    8000635e:	a8e98993          	addi	s3,s3,-1394 # 80024de8 <disk>
    80006362:	00491713          	slli	a4,s2,0x4
    80006366:	0009b783          	ld	a5,0(s3)
    8000636a:	97ba                	add	a5,a5,a4
    8000636c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006370:	854a                	mv	a0,s2
    80006372:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006376:	bddff0ef          	jal	80005f52 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000637a:	8885                	andi	s1,s1,1
    8000637c:	f0fd                	bnez	s1,80006362 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000637e:	0001f517          	auipc	a0,0x1f
    80006382:	b9250513          	addi	a0,a0,-1134 # 80024f10 <disk+0x128>
    80006386:	937fa0ef          	jal	80000cbc <release>
}
    8000638a:	60e6                	ld	ra,88(sp)
    8000638c:	6446                	ld	s0,80(sp)
    8000638e:	64a6                	ld	s1,72(sp)
    80006390:	6906                	ld	s2,64(sp)
    80006392:	79e2                	ld	s3,56(sp)
    80006394:	7a42                	ld	s4,48(sp)
    80006396:	7aa2                	ld	s5,40(sp)
    80006398:	7b02                	ld	s6,32(sp)
    8000639a:	6be2                	ld	s7,24(sp)
    8000639c:	6c42                	ld	s8,16(sp)
    8000639e:	6125                	addi	sp,sp,96
    800063a0:	8082                	ret

00000000800063a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063a2:	1101                	addi	sp,sp,-32
    800063a4:	ec06                	sd	ra,24(sp)
    800063a6:	e822                	sd	s0,16(sp)
    800063a8:	e426                	sd	s1,8(sp)
    800063aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063ac:	0001f497          	auipc	s1,0x1f
    800063b0:	a3c48493          	addi	s1,s1,-1476 # 80024de8 <disk>
    800063b4:	0001f517          	auipc	a0,0x1f
    800063b8:	b5c50513          	addi	a0,a0,-1188 # 80024f10 <disk+0x128>
    800063bc:	86dfa0ef          	jal	80000c28 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063c0:	100017b7          	lui	a5,0x10001
    800063c4:	53bc                	lw	a5,96(a5)
    800063c6:	8b8d                	andi	a5,a5,3
    800063c8:	10001737          	lui	a4,0x10001
    800063cc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063ce:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063d2:	689c                	ld	a5,16(s1)
    800063d4:	0204d703          	lhu	a4,32(s1)
    800063d8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800063dc:	04f70863          	beq	a4,a5,8000642c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800063e0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063e4:	6898                	ld	a4,16(s1)
    800063e6:	0204d783          	lhu	a5,32(s1)
    800063ea:	8b9d                	andi	a5,a5,7
    800063ec:	078e                	slli	a5,a5,0x3
    800063ee:	97ba                	add	a5,a5,a4
    800063f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063f2:	00479713          	slli	a4,a5,0x4
    800063f6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    800063fa:	9726                	add	a4,a4,s1
    800063fc:	01074703          	lbu	a4,16(a4)
    80006400:	e329                	bnez	a4,80006442 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006402:	0792                	slli	a5,a5,0x4
    80006404:	02078793          	addi	a5,a5,32
    80006408:	97a6                	add	a5,a5,s1
    8000640a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000640c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006410:	b66fc0ef          	jal	80002776 <wakeup>

    disk.used_idx += 1;
    80006414:	0204d783          	lhu	a5,32(s1)
    80006418:	2785                	addiw	a5,a5,1
    8000641a:	17c2                	slli	a5,a5,0x30
    8000641c:	93c1                	srli	a5,a5,0x30
    8000641e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006422:	6898                	ld	a4,16(s1)
    80006424:	00275703          	lhu	a4,2(a4)
    80006428:	faf71ce3          	bne	a4,a5,800063e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000642c:	0001f517          	auipc	a0,0x1f
    80006430:	ae450513          	addi	a0,a0,-1308 # 80024f10 <disk+0x128>
    80006434:	889fa0ef          	jal	80000cbc <release>
}
    80006438:	60e2                	ld	ra,24(sp)
    8000643a:	6442                	ld	s0,16(sp)
    8000643c:	64a2                	ld	s1,8(sp)
    8000643e:	6105                	addi	sp,sp,32
    80006440:	8082                	ret
      panic("virtio_disk_intr status");
    80006442:	00002517          	auipc	a0,0x2
    80006446:	73e50513          	addi	a0,a0,1854 # 80008b80 <etext+0xb80>
    8000644a:	bdafa0ef          	jal	80000824 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
