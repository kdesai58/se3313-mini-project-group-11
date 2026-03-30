
user/_hello_world:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <demo_variables>:
#include "user/user.h"

// Example 1: Variables and types
void
demo_variables(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("\n=== Variables and Types ===\n");
   8:	00001517          	auipc	a0,0x1
   c:	d2850513          	addi	a0,a0,-728 # d30 <malloc+0xf4>
  10:	375000ef          	jal	b84 <printf>
  int x = 42;
  char c = 'A';
  
  printf("Integer x = %d\n", x);
  14:	02a00593          	li	a1,42
  18:	00001517          	auipc	a0,0x1
  1c:	d4050513          	addi	a0,a0,-704 # d58 <malloc+0x11c>
  20:	365000ef          	jal	b84 <printf>
  printf("Character c = %c\n", c);
  24:	04100593          	li	a1,65
  28:	00001517          	auipc	a0,0x1
  2c:	d4050513          	addi	a0,a0,-704 # d68 <malloc+0x12c>
  30:	355000ef          	jal	b84 <printf>
}
  34:	60a2                	ld	ra,8(sp)
  36:	6402                	ld	s0,0(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <add_numbers>:

// Example 2: Functions with parameters and return values
int
add_numbers(int a, int b)
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e406                	sd	ra,8(sp)
  40:	e022                	sd	s0,0(sp)
  42:	0800                	addi	s0,sp,16
  return a + b;
}
  44:	9d2d                	addw	a0,a0,a1
  46:	60a2                	ld	ra,8(sp)
  48:	6402                	ld	s0,0(sp)
  4a:	0141                	addi	sp,sp,16
  4c:	8082                	ret

000000000000004e <multiply>:

int
multiply(int a, int b)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e406                	sd	ra,8(sp)
  52:	e022                	sd	s0,0(sp)
  54:	0800                	addi	s0,sp,16
  int result = a * b;
  return result;
}
  56:	02b5053b          	mulw	a0,a0,a1
  5a:	60a2                	ld	ra,8(sp)
  5c:	6402                	ld	s0,0(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <demo_functions>:

void
demo_functions(void)
{
  62:	1141                	addi	sp,sp,-16
  64:	e406                	sd	ra,8(sp)
  66:	e022                	sd	s0,0(sp)
  68:	0800                	addi	s0,sp,16
  printf("\n=== Functions ===\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	d1650513          	addi	a0,a0,-746 # d80 <malloc+0x144>
  72:	313000ef          	jal	b84 <printf>
  int sum = add_numbers(10, 20);
  int product = multiply(5, 7);
  
  printf("10 + 20 = %d\n", sum);
  76:	45f9                	li	a1,30
  78:	00001517          	auipc	a0,0x1
  7c:	d2050513          	addi	a0,a0,-736 # d98 <malloc+0x15c>
  80:	305000ef          	jal	b84 <printf>
  printf("5 * 7 = %d\n", product);
  84:	02300593          	li	a1,35
  88:	00001517          	auipc	a0,0x1
  8c:	d2050513          	addi	a0,a0,-736 # da8 <malloc+0x16c>
  90:	2f5000ef          	jal	b84 <printf>
}
  94:	60a2                	ld	ra,8(sp)
  96:	6402                	ld	s0,0(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret

000000000000009c <demo_arrays>:

// Example 3: Arrays
void
demo_arrays(void)
{
  9c:	715d                	addi	sp,sp,-80
  9e:	e486                	sd	ra,72(sp)
  a0:	e0a2                	sd	s0,64(sp)
  a2:	fc26                	sd	s1,56(sp)
  a4:	f84a                	sd	s2,48(sp)
  a6:	f44e                	sd	s3,40(sp)
  a8:	f052                	sd	s4,32(sp)
  aa:	0880                	addi	s0,sp,80
  printf("\n=== Arrays ===\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	d0c50513          	addi	a0,a0,-756 # db8 <malloc+0x17c>
  b4:	2d1000ef          	jal	b84 <printf>
  int numbers[5] = {10, 20, 30, 40, 50};
  b8:	47a9                	li	a5,10
  ba:	faf42c23          	sw	a5,-72(s0)
  be:	47d1                	li	a5,20
  c0:	faf42e23          	sw	a5,-68(s0)
  c4:	47f9                	li	a5,30
  c6:	fcf42023          	sw	a5,-64(s0)
  ca:	02800793          	li	a5,40
  ce:	fcf42223          	sw	a5,-60(s0)
  d2:	03200793          	li	a5,50
  d6:	fcf42423          	sw	a5,-56(s0)
  
  printf("Array elements:\n");
  da:	00001517          	auipc	a0,0x1
  de:	cf650513          	addi	a0,a0,-778 # dd0 <malloc+0x194>
  e2:	2a3000ef          	jal	b84 <printf>
  for(int i = 0; i < 5; i++) {
  e6:	fb840913          	addi	s2,s0,-72
  ea:	4481                	li	s1,0
    printf("  numbers[%d] = %d\n", i, numbers[i]);
  ec:	00001a17          	auipc	s4,0x1
  f0:	cfca0a13          	addi	s4,s4,-772 # de8 <malloc+0x1ac>
  for(int i = 0; i < 5; i++) {
  f4:	4995                	li	s3,5
    printf("  numbers[%d] = %d\n", i, numbers[i]);
  f6:	00092603          	lw	a2,0(s2)
  fa:	85a6                	mv	a1,s1
  fc:	8552                	mv	a0,s4
  fe:	287000ef          	jal	b84 <printf>
  for(int i = 0; i < 5; i++) {
 102:	2485                	addiw	s1,s1,1
 104:	0911                	addi	s2,s2,4
 106:	ff3498e3          	bne	s1,s3,f6 <demo_arrays+0x5a>
  // Calculate sum
  int sum = 0;
  for(int i = 0; i < 5; i++) {
    sum += numbers[i];
  }
  printf("Sum of array = %d\n", sum);
 10a:	09600593          	li	a1,150
 10e:	00001517          	auipc	a0,0x1
 112:	cf250513          	addi	a0,a0,-782 # e00 <malloc+0x1c4>
 116:	26f000ef          	jal	b84 <printf>
}
 11a:	60a6                	ld	ra,72(sp)
 11c:	6406                	ld	s0,64(sp)
 11e:	74e2                	ld	s1,56(sp)
 120:	7942                	ld	s2,48(sp)
 122:	79a2                	ld	s3,40(sp)
 124:	7a02                	ld	s4,32(sp)
 126:	6161                	addi	sp,sp,80
 128:	8082                	ret

000000000000012a <demo_structs>:
  int id;
};

void
demo_structs(void)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e406                	sd	ra,8(sp)
 12e:	e022                	sd	s0,0(sp)
 130:	0800                	addi	s0,sp,16
  printf("\n=== Structures ===\n");
 132:	00001517          	auipc	a0,0x1
 136:	ce650513          	addi	a0,a0,-794 # e18 <malloc+0x1dc>
 13a:	24b000ef          	jal	b84 <printf>
  
  struct point p;
  p.x = 100;
  p.y = 200;
  printf("Point: (%d, %d)\n", p.x, p.y);
 13e:	0c800613          	li	a2,200
 142:	06400593          	li	a1,100
 146:	00001517          	auipc	a0,0x1
 14a:	cea50513          	addi	a0,a0,-790 # e30 <malloc+0x1f4>
 14e:	237000ef          	jal	b84 <printf>
  
  struct person student;
  student.age = 20;
  student.id = 12345;
  printf("Person: age=%d, id=%d\n", student.age, student.id);
 152:	660d                	lui	a2,0x3
 154:	03960613          	addi	a2,a2,57 # 3039 <base+0x1029>
 158:	45d1                	li	a1,20
 15a:	00001517          	auipc	a0,0x1
 15e:	cee50513          	addi	a0,a0,-786 # e48 <malloc+0x20c>
 162:	223000ef          	jal	b84 <printf>
}
 166:	60a2                	ld	ra,8(sp)
 168:	6402                	ld	s0,0(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <demo_strings>:

// Example 5: Strings (character arrays)
void
demo_strings(void)
{
 16e:	7159                	addi	sp,sp,-112
 170:	f486                	sd	ra,104(sp)
 172:	f0a2                	sd	s0,96(sp)
 174:	eca6                	sd	s1,88(sp)
 176:	1880                	addi	s0,sp,112
  printf("\n=== Strings ===\n");
 178:	00001517          	auipc	a0,0x1
 17c:	ce850513          	addi	a0,a0,-792 # e60 <malloc+0x224>
 180:	205000ef          	jal	b84 <printf>
  
  char greeting[] = "Hello";
 184:	6c6c67b7          	lui	a5,0x6c6c6
 188:	54878793          	addi	a5,a5,1352 # 6c6c6548 <base+0x6c6c4538>
 18c:	fcf42c23          	sw	a5,-40(s0)
 190:	06f00793          	li	a5,111
 194:	fcf41e23          	sh	a5,-36(s0)
  char name[] = "xv6";  // Need 4 chars: 'x', 'v', '6', '\0'
 198:	003677b7          	lui	a5,0x367
 19c:	67878793          	addi	a5,a5,1656 # 367678 <base+0x365668>
 1a0:	fcf42823          	sw	a5,-48(s0)
  
  printf("Greeting: %s\n", greeting);
 1a4:	fd840593          	addi	a1,s0,-40
 1a8:	00001517          	auipc	a0,0x1
 1ac:	cd050513          	addi	a0,a0,-816 # e78 <malloc+0x23c>
 1b0:	1d5000ef          	jal	b84 <printf>
  printf("Name: %s\n", name);
 1b4:	fd040493          	addi	s1,s0,-48
 1b8:	85a6                	mv	a1,s1
 1ba:	00001517          	auipc	a0,0x1
 1be:	cce50513          	addi	a0,a0,-818 # e88 <malloc+0x24c>
 1c2:	1c3000ef          	jal	b84 <printf>
  
  // String length
  int len = strlen(name);
 1c6:	8526                	mv	a0,s1
 1c8:	318000ef          	jal	4e0 <strlen>
 1cc:	862a                	mv	a2,a0
  printf("Length of '%s' = %d\n", name, len);
 1ce:	85a6                	mv	a1,s1
 1d0:	00001517          	auipc	a0,0x1
 1d4:	cc850513          	addi	a0,a0,-824 # e98 <malloc+0x25c>
 1d8:	1ad000ef          	jal	b84 <printf>
  
  // String concatenation (manual)
  char message[50] = "Welcome to ";
 1dc:	00001797          	auipc	a5,0x1
 1e0:	ce478793          	addi	a5,a5,-796 # ec0 <malloc+0x284>
 1e4:	0007cf03          	lbu	t5,0(a5)
 1e8:	0017ce83          	lbu	t4,1(a5)
 1ec:	0027ce03          	lbu	t3,2(a5)
 1f0:	0037c303          	lbu	t1,3(a5)
 1f4:	0047c883          	lbu	a7,4(a5)
 1f8:	0057c803          	lbu	a6,5(a5)
 1fc:	0067c503          	lbu	a0,6(a5)
 200:	0077c583          	lbu	a1,7(a5)
 204:	0087c603          	lbu	a2,8(a5)
 208:	0097c683          	lbu	a3,9(a5)
 20c:	00a7c703          	lbu	a4,10(a5)
 210:	f9e40c23          	sb	t5,-104(s0)
 214:	f9d40ca3          	sb	t4,-103(s0)
 218:	f9c40d23          	sb	t3,-102(s0)
 21c:	f8640da3          	sb	t1,-101(s0)
 220:	f9140e23          	sb	a7,-100(s0)
 224:	f9040ea3          	sb	a6,-99(s0)
 228:	f8a40f23          	sb	a0,-98(s0)
 22c:	f8b40fa3          	sb	a1,-97(s0)
 230:	fac40023          	sb	a2,-96(s0)
 234:	fad400a3          	sb	a3,-95(s0)
 238:	fae40123          	sb	a4,-94(s0)
 23c:	00b7c783          	lbu	a5,11(a5)
 240:	faf401a3          	sb	a5,-93(s0)
 244:	fa042223          	sw	zero,-92(s0)
 248:	fa042423          	sw	zero,-88(s0)
 24c:	fa042623          	sw	zero,-84(s0)
 250:	fa042823          	sw	zero,-80(s0)
 254:	fa042a23          	sw	zero,-76(s0)
 258:	fa042c23          	sw	zero,-72(s0)
 25c:	fa042e23          	sw	zero,-68(s0)
 260:	fc042023          	sw	zero,-64(s0)
 264:	fc042223          	sw	zero,-60(s0)
 268:	fc041423          	sh	zero,-56(s0)
  int i = strlen(message);
 26c:	f9840513          	addi	a0,s0,-104
 270:	270000ef          	jal	4e0 <strlen>
 274:	86aa                	mv	a3,a0
  int j = 0;
  while(name[j] != '\0') {
 276:	fd044703          	lbu	a4,-48(s0)
 27a:	cf09                	beqz	a4,294 <demo_strings+0x126>
 27c:	f9840793          	addi	a5,s0,-104
 280:	953e                	add	a0,a0,a5
 282:	87a6                	mv	a5,s1
    message[i++] = name[j++];
 284:	2685                	addiw	a3,a3,1
 286:	00e50023          	sb	a4,0(a0)
  while(name[j] != '\0') {
 28a:	0017c703          	lbu	a4,1(a5)
 28e:	0505                	addi	a0,a0,1
 290:	0785                	addi	a5,a5,1
 292:	fb6d                	bnez	a4,284 <demo_strings+0x116>
  }
  message[i] = '\0';
 294:	fe068793          	addi	a5,a3,-32
 298:	008786b3          	add	a3,a5,s0
 29c:	fa068c23          	sb	zero,-72(a3)
  printf("Message: %s\n", message);
 2a0:	f9840593          	addi	a1,s0,-104
 2a4:	00001517          	auipc	a0,0x1
 2a8:	c0c50513          	addi	a0,a0,-1012 # eb0 <malloc+0x274>
 2ac:	0d9000ef          	jal	b84 <printf>
}
 2b0:	70a6                	ld	ra,104(sp)
 2b2:	7406                	ld	s0,96(sp)
 2b4:	64e6                	ld	s1,88(sp)
 2b6:	6165                	addi	sp,sp,112
 2b8:	8082                	ret

00000000000002ba <demo_pointers>:

// Example 6: Pointers
void
demo_pointers(void)
{
 2ba:	1101                	addi	sp,sp,-32
 2bc:	ec06                	sd	ra,24(sp)
 2be:	e822                	sd	s0,16(sp)
 2c0:	1000                	addi	s0,sp,32
  printf("\n=== Pointers ===\n");
 2c2:	00001517          	auipc	a0,0x1
 2c6:	c0e50513          	addi	a0,a0,-1010 # ed0 <malloc+0x294>
 2ca:	0bb000ef          	jal	b84 <printf>
  
  int a = 5;           
 2ce:	4795                	li	a5,5
 2d0:	fef42623          	sw	a5,-20(s0)
  // a regular integer, stored somewhere in memory
  printf("a = %d\n", a);
 2d4:	85be                	mv	a1,a5
 2d6:	00001517          	auipc	a0,0x1
 2da:	c1250513          	addi	a0,a0,-1006 # ee8 <malloc+0x2ac>
 2de:	0a7000ef          	jal	b84 <printf>
  
  int *p = &a;         
 2e2:	fec40593          	addi	a1,s0,-20
 2e6:	feb43023          	sd	a1,-32(s0)
  // a pointer to an integer value, `p` stores the memory location of `a`
  printf("p = %p (address of a)\n", p);
 2ea:	00001517          	auipc	a0,0x1
 2ee:	c0650513          	addi	a0,a0,-1018 # ef0 <malloc+0x2b4>
 2f2:	093000ef          	jal	b84 <printf>
  printf("*p = %d (value at address p)\n", *p);
 2f6:	fe043783          	ld	a5,-32(s0)
 2fa:	438c                	lw	a1,0(a5)
 2fc:	00001517          	auipc	a0,0x1
 300:	c0c50513          	addi	a0,a0,-1012 # f08 <malloc+0x2cc>
 304:	081000ef          	jal	b84 <printf>
  
  *p = 6;              
 308:	fe043783          	ld	a5,-32(s0)
 30c:	4719                	li	a4,6
 30e:	c398                	sw	a4,0(a5)
  // when outside of declarations, * is a 'dereference' operator, i.e., give me the content in the address that variable p refers to
  printf("After *p = 6:\n");
 310:	00001517          	auipc	a0,0x1
 314:	c1850513          	addi	a0,a0,-1000 # f28 <malloc+0x2ec>
 318:	06d000ef          	jal	b84 <printf>
  printf("a = %d (changed via pointer)\n", a);
 31c:	fec42583          	lw	a1,-20(s0)
 320:	00001517          	auipc	a0,0x1
 324:	c1850513          	addi	a0,a0,-1000 # f38 <malloc+0x2fc>
 328:	05d000ef          	jal	b84 <printf>
  
  int **x = &p;        
  // a pointer to a pointer, `x` stores the memory location of `p`
  
  printf("x = %p (address of p)\n", x);
 32c:	fe040593          	addi	a1,s0,-32
 330:	00001517          	auipc	a0,0x1
 334:	c2850513          	addi	a0,a0,-984 # f58 <malloc+0x31c>
 338:	04d000ef          	jal	b84 <printf>
  printf("*x = %p (value at x, which is address of a)\n", *x);
 33c:	fe043583          	ld	a1,-32(s0)
 340:	00001517          	auipc	a0,0x1
 344:	c3050513          	addi	a0,a0,-976 # f70 <malloc+0x334>
 348:	03d000ef          	jal	b84 <printf>
  printf("**x = %d (value at address stored in p)\n", **x);
 34c:	fe043783          	ld	a5,-32(s0)
 350:	438c                	lw	a1,0(a5)
 352:	00001517          	auipc	a0,0x1
 356:	c4e50513          	addi	a0,a0,-946 # fa0 <malloc+0x364>
 35a:	02b000ef          	jal	b84 <printf>
}
 35e:	60e2                	ld	ra,24(sp)
 360:	6442                	ld	s0,16(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret

0000000000000366 <demo_file_read>:

// Example 7: File I/O - Reading a file
void
demo_file_read(char *file)
{
 366:	dd010113          	addi	sp,sp,-560
 36a:	22113423          	sd	ra,552(sp)
 36e:	22813023          	sd	s0,544(sp)
 372:	20913c23          	sd	s1,536(sp)
 376:	1c00                	addi	s0,sp,560
 378:	84aa                	mv	s1,a0
  printf("\n=== File Reading ===\n");
 37a:	00001517          	auipc	a0,0x1
 37e:	c5650513          	addi	a0,a0,-938 # fd0 <malloc+0x394>
 382:	003000ef          	jal	b84 <printf>
  
  char buf[512];
  int fd, n;
  
  // Open the file for reading
  fd = open(file, 0);  // 0 = O_RDONLY
 386:	4581                	li	a1,0
 388:	8526                	mv	a0,s1
 38a:	3ec000ef          	jal	776 <open>
  if(fd < 0){
 38e:	02054663          	bltz	a0,3ba <demo_file_read+0x54>
 392:	21213823          	sd	s2,528(sp)
 396:	21313423          	sd	s3,520(sp)
 39a:	21413023          	sd	s4,512(sp)
 39e:	892a                	mv	s2,a0
    printf("Error: cannot open %s\n", file);
    return;
  }
  
  printf("Reading from %s:\n", file);
 3a0:	85a6                	mv	a1,s1
 3a2:	00001517          	auipc	a0,0x1
 3a6:	c5e50513          	addi	a0,a0,-930 # 1000 <malloc+0x3c4>
 3aa:	7da000ef          	jal	b84 <printf>
  
  // Read and print file contents
  while((n = read(fd, buf, sizeof(buf))) > 0) {
 3ae:	dd040493          	addi	s1,s0,-560
 3b2:	20000993          	li	s3,512
    write(1, buf, n);  // Write to stdout (fd = 1)
 3b6:	4a05                	li	s4,1
  while((n = read(fd, buf, sizeof(buf))) > 0) {
 3b8:	a829                	j	3d2 <demo_file_read+0x6c>
    printf("Error: cannot open %s\n", file);
 3ba:	85a6                	mv	a1,s1
 3bc:	00001517          	auipc	a0,0x1
 3c0:	c2c50513          	addi	a0,a0,-980 # fe8 <malloc+0x3ac>
 3c4:	7c0000ef          	jal	b84 <printf>
    return;
 3c8:	a825                	j	400 <demo_file_read+0x9a>
    write(1, buf, n);  // Write to stdout (fd = 1)
 3ca:	85a6                	mv	a1,s1
 3cc:	8552                	mv	a0,s4
 3ce:	388000ef          	jal	756 <write>
  while((n = read(fd, buf, sizeof(buf))) > 0) {
 3d2:	864e                	mv	a2,s3
 3d4:	85a6                	mv	a1,s1
 3d6:	854a                	mv	a0,s2
 3d8:	376000ef          	jal	74e <read>
 3dc:	862a                	mv	a2,a0
 3de:	fea046e3          	bgtz	a0,3ca <demo_file_read+0x64>
  }
  
  // Close the file
  close(fd);
 3e2:	854a                	mv	a0,s2
 3e4:	37a000ef          	jal	75e <close>
  printf("\n");
 3e8:	00001517          	auipc	a0,0x1
 3ec:	c3050513          	addi	a0,a0,-976 # 1018 <malloc+0x3dc>
 3f0:	794000ef          	jal	b84 <printf>
 3f4:	21013903          	ld	s2,528(sp)
 3f8:	20813983          	ld	s3,520(sp)
 3fc:	20013a03          	ld	s4,512(sp)
}
 400:	22813083          	ld	ra,552(sp)
 404:	22013403          	ld	s0,544(sp)
 408:	21813483          	ld	s1,536(sp)
 40c:	23010113          	addi	sp,sp,560
 410:	8082                	ret

0000000000000412 <main>:

int
main(int argc, char *argv[])
{
 412:	1101                	addi	sp,sp,-32
 414:	ec06                	sd	ra,24(sp)
 416:	e822                	sd	s0,16(sp)
 418:	e426                	sd	s1,8(sp)
 41a:	e04a                	sd	s2,0(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	84aa                	mv	s1,a0
 420:	892e                	mv	s2,a1
  printf("=== Basic C Programming Examples ===\n");
 422:	00001517          	auipc	a0,0x1
 426:	bfe50513          	addi	a0,a0,-1026 # 1020 <malloc+0x3e4>
 42a:	75a000ef          	jal	b84 <printf>
  
  demo_variables();
 42e:	bd3ff0ef          	jal	0 <demo_variables>
  demo_functions();
 432:	c31ff0ef          	jal	62 <demo_functions>
  demo_arrays();
 436:	c67ff0ef          	jal	9c <demo_arrays>
  demo_structs();
 43a:	cf1ff0ef          	jal	12a <demo_structs>
  demo_strings();
 43e:	d31ff0ef          	jal	16e <demo_strings>
  demo_pointers();
 442:	e79ff0ef          	jal	2ba <demo_pointers>

  if(argc < 2) {
 446:	4785                	li	a5,1
 448:	0097cf63          	blt	a5,s1,466 <main+0x54>
    printf("\nNo file specified for reading demo. Skipping file read demo.\n");
 44c:	00001517          	auipc	a0,0x1
 450:	bfc50513          	addi	a0,a0,-1028 # 1048 <malloc+0x40c>
 454:	730000ef          	jal	b84 <printf>
    demo_file_read(argv[1]);
  }
  
  printf("\n=== All demos complete! ===\n");
  exit(0);
}
 458:	4501                	li	a0,0
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	64a2                	ld	s1,8(sp)
 460:	6902                	ld	s2,0(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret
    demo_file_read(argv[1]);
 466:	00893503          	ld	a0,8(s2)
 46a:	efdff0ef          	jal	366 <demo_file_read>
  printf("\n=== All demos complete! ===\n");
 46e:	00001517          	auipc	a0,0x1
 472:	c1a50513          	addi	a0,a0,-998 # 1088 <malloc+0x44c>
 476:	70e000ef          	jal	b84 <printf>
  exit(0);
 47a:	4501                	li	a0,0
 47c:	2ba000ef          	jal	736 <exit>

0000000000000480 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 480:	1141                	addi	sp,sp,-16
 482:	e406                	sd	ra,8(sp)
 484:	e022                	sd	s0,0(sp)
 486:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 488:	f8bff0ef          	jal	412 <main>
  exit(r);
 48c:	2aa000ef          	jal	736 <exit>

0000000000000490 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 490:	1141                	addi	sp,sp,-16
 492:	e406                	sd	ra,8(sp)
 494:	e022                	sd	s0,0(sp)
 496:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 498:	87aa                	mv	a5,a0
 49a:	0585                	addi	a1,a1,1
 49c:	0785                	addi	a5,a5,1
 49e:	fff5c703          	lbu	a4,-1(a1)
 4a2:	fee78fa3          	sb	a4,-1(a5)
 4a6:	fb75                	bnez	a4,49a <strcpy+0xa>
    ;
  return os;
}
 4a8:	60a2                	ld	ra,8(sp)
 4aa:	6402                	ld	s0,0(sp)
 4ac:	0141                	addi	sp,sp,16
 4ae:	8082                	ret

00000000000004b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b0:	1141                	addi	sp,sp,-16
 4b2:	e406                	sd	ra,8(sp)
 4b4:	e022                	sd	s0,0(sp)
 4b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4b8:	00054783          	lbu	a5,0(a0)
 4bc:	cb91                	beqz	a5,4d0 <strcmp+0x20>
 4be:	0005c703          	lbu	a4,0(a1)
 4c2:	00f71763          	bne	a4,a5,4d0 <strcmp+0x20>
    p++, q++;
 4c6:	0505                	addi	a0,a0,1
 4c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4ca:	00054783          	lbu	a5,0(a0)
 4ce:	fbe5                	bnez	a5,4be <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 4d0:	0005c503          	lbu	a0,0(a1)
}
 4d4:	40a7853b          	subw	a0,a5,a0
 4d8:	60a2                	ld	ra,8(sp)
 4da:	6402                	ld	s0,0(sp)
 4dc:	0141                	addi	sp,sp,16
 4de:	8082                	ret

00000000000004e0 <strlen>:

uint
strlen(const char *s)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e406                	sd	ra,8(sp)
 4e4:	e022                	sd	s0,0(sp)
 4e6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4e8:	00054783          	lbu	a5,0(a0)
 4ec:	cf91                	beqz	a5,508 <strlen+0x28>
 4ee:	00150793          	addi	a5,a0,1
 4f2:	86be                	mv	a3,a5
 4f4:	0785                	addi	a5,a5,1
 4f6:	fff7c703          	lbu	a4,-1(a5)
 4fa:	ff65                	bnez	a4,4f2 <strlen+0x12>
 4fc:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 500:	60a2                	ld	ra,8(sp)
 502:	6402                	ld	s0,0(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret
  for(n = 0; s[n]; n++)
 508:	4501                	li	a0,0
 50a:	bfdd                	j	500 <strlen+0x20>

000000000000050c <memset>:

void*
memset(void *dst, int c, uint n)
{
 50c:	1141                	addi	sp,sp,-16
 50e:	e406                	sd	ra,8(sp)
 510:	e022                	sd	s0,0(sp)
 512:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 514:	ca19                	beqz	a2,52a <memset+0x1e>
 516:	87aa                	mv	a5,a0
 518:	1602                	slli	a2,a2,0x20
 51a:	9201                	srli	a2,a2,0x20
 51c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 520:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 524:	0785                	addi	a5,a5,1
 526:	fee79de3          	bne	a5,a4,520 <memset+0x14>
  }
  return dst;
}
 52a:	60a2                	ld	ra,8(sp)
 52c:	6402                	ld	s0,0(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret

0000000000000532 <strchr>:

char*
strchr(const char *s, char c)
{
 532:	1141                	addi	sp,sp,-16
 534:	e406                	sd	ra,8(sp)
 536:	e022                	sd	s0,0(sp)
 538:	0800                	addi	s0,sp,16
  for(; *s; s++)
 53a:	00054783          	lbu	a5,0(a0)
 53e:	cf81                	beqz	a5,556 <strchr+0x24>
    if(*s == c)
 540:	00f58763          	beq	a1,a5,54e <strchr+0x1c>
  for(; *s; s++)
 544:	0505                	addi	a0,a0,1
 546:	00054783          	lbu	a5,0(a0)
 54a:	fbfd                	bnez	a5,540 <strchr+0xe>
      return (char*)s;
  return 0;
 54c:	4501                	li	a0,0
}
 54e:	60a2                	ld	ra,8(sp)
 550:	6402                	ld	s0,0(sp)
 552:	0141                	addi	sp,sp,16
 554:	8082                	ret
  return 0;
 556:	4501                	li	a0,0
 558:	bfdd                	j	54e <strchr+0x1c>

000000000000055a <gets>:

char*
gets(char *buf, int max)
{
 55a:	711d                	addi	sp,sp,-96
 55c:	ec86                	sd	ra,88(sp)
 55e:	e8a2                	sd	s0,80(sp)
 560:	e4a6                	sd	s1,72(sp)
 562:	e0ca                	sd	s2,64(sp)
 564:	fc4e                	sd	s3,56(sp)
 566:	f852                	sd	s4,48(sp)
 568:	f456                	sd	s5,40(sp)
 56a:	f05a                	sd	s6,32(sp)
 56c:	ec5e                	sd	s7,24(sp)
 56e:	e862                	sd	s8,16(sp)
 570:	1080                	addi	s0,sp,96
 572:	8baa                	mv	s7,a0
 574:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 576:	892a                	mv	s2,a0
 578:	4481                	li	s1,0
    cc = read(0, &c, 1);
 57a:	faf40b13          	addi	s6,s0,-81
 57e:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 580:	8c26                	mv	s8,s1
 582:	0014899b          	addiw	s3,s1,1
 586:	84ce                	mv	s1,s3
 588:	0349d463          	bge	s3,s4,5b0 <gets+0x56>
    cc = read(0, &c, 1);
 58c:	8656                	mv	a2,s5
 58e:	85da                	mv	a1,s6
 590:	4501                	li	a0,0
 592:	1bc000ef          	jal	74e <read>
    if(cc < 1)
 596:	00a05d63          	blez	a0,5b0 <gets+0x56>
      break;
    buf[i++] = c;
 59a:	faf44783          	lbu	a5,-81(s0)
 59e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5a2:	0905                	addi	s2,s2,1
 5a4:	ff678713          	addi	a4,a5,-10
 5a8:	c319                	beqz	a4,5ae <gets+0x54>
 5aa:	17cd                	addi	a5,a5,-13
 5ac:	fbf1                	bnez	a5,580 <gets+0x26>
    buf[i++] = c;
 5ae:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 5b0:	9c5e                	add	s8,s8,s7
 5b2:	000c0023          	sb	zero,0(s8)
  return buf;
}
 5b6:	855e                	mv	a0,s7
 5b8:	60e6                	ld	ra,88(sp)
 5ba:	6446                	ld	s0,80(sp)
 5bc:	64a6                	ld	s1,72(sp)
 5be:	6906                	ld	s2,64(sp)
 5c0:	79e2                	ld	s3,56(sp)
 5c2:	7a42                	ld	s4,48(sp)
 5c4:	7aa2                	ld	s5,40(sp)
 5c6:	7b02                	ld	s6,32(sp)
 5c8:	6be2                	ld	s7,24(sp)
 5ca:	6c42                	ld	s8,16(sp)
 5cc:	6125                	addi	sp,sp,96
 5ce:	8082                	ret

00000000000005d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 5d0:	1101                	addi	sp,sp,-32
 5d2:	ec06                	sd	ra,24(sp)
 5d4:	e822                	sd	s0,16(sp)
 5d6:	e04a                	sd	s2,0(sp)
 5d8:	1000                	addi	s0,sp,32
 5da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5dc:	4581                	li	a1,0
 5de:	198000ef          	jal	776 <open>
  if(fd < 0)
 5e2:	02054263          	bltz	a0,606 <stat+0x36>
 5e6:	e426                	sd	s1,8(sp)
 5e8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5ea:	85ca                	mv	a1,s2
 5ec:	1a2000ef          	jal	78e <fstat>
 5f0:	892a                	mv	s2,a0
  close(fd);
 5f2:	8526                	mv	a0,s1
 5f4:	16a000ef          	jal	75e <close>
  return r;
 5f8:	64a2                	ld	s1,8(sp)
}
 5fa:	854a                	mv	a0,s2
 5fc:	60e2                	ld	ra,24(sp)
 5fe:	6442                	ld	s0,16(sp)
 600:	6902                	ld	s2,0(sp)
 602:	6105                	addi	sp,sp,32
 604:	8082                	ret
    return -1;
 606:	57fd                	li	a5,-1
 608:	893e                	mv	s2,a5
 60a:	bfc5                	j	5fa <stat+0x2a>

000000000000060c <atoi>:

int
atoi(const char *s)
{
 60c:	1141                	addi	sp,sp,-16
 60e:	e406                	sd	ra,8(sp)
 610:	e022                	sd	s0,0(sp)
 612:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 614:	00054683          	lbu	a3,0(a0)
 618:	fd06879b          	addiw	a5,a3,-48
 61c:	0ff7f793          	zext.b	a5,a5
 620:	4625                	li	a2,9
 622:	02f66963          	bltu	a2,a5,654 <atoi+0x48>
 626:	872a                	mv	a4,a0
  n = 0;
 628:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 62a:	0705                	addi	a4,a4,1
 62c:	0025179b          	slliw	a5,a0,0x2
 630:	9fa9                	addw	a5,a5,a0
 632:	0017979b          	slliw	a5,a5,0x1
 636:	9fb5                	addw	a5,a5,a3
 638:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 63c:	00074683          	lbu	a3,0(a4)
 640:	fd06879b          	addiw	a5,a3,-48
 644:	0ff7f793          	zext.b	a5,a5
 648:	fef671e3          	bgeu	a2,a5,62a <atoi+0x1e>
  return n;
}
 64c:	60a2                	ld	ra,8(sp)
 64e:	6402                	ld	s0,0(sp)
 650:	0141                	addi	sp,sp,16
 652:	8082                	ret
  n = 0;
 654:	4501                	li	a0,0
 656:	bfdd                	j	64c <atoi+0x40>

0000000000000658 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 658:	1141                	addi	sp,sp,-16
 65a:	e406                	sd	ra,8(sp)
 65c:	e022                	sd	s0,0(sp)
 65e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 660:	02b57563          	bgeu	a0,a1,68a <memmove+0x32>
    while(n-- > 0)
 664:	00c05f63          	blez	a2,682 <memmove+0x2a>
 668:	1602                	slli	a2,a2,0x20
 66a:	9201                	srli	a2,a2,0x20
 66c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 670:	872a                	mv	a4,a0
      *dst++ = *src++;
 672:	0585                	addi	a1,a1,1
 674:	0705                	addi	a4,a4,1
 676:	fff5c683          	lbu	a3,-1(a1)
 67a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 67e:	fee79ae3          	bne	a5,a4,672 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 682:	60a2                	ld	ra,8(sp)
 684:	6402                	ld	s0,0(sp)
 686:	0141                	addi	sp,sp,16
 688:	8082                	ret
    while(n-- > 0)
 68a:	fec05ce3          	blez	a2,682 <memmove+0x2a>
    dst += n;
 68e:	00c50733          	add	a4,a0,a2
    src += n;
 692:	95b2                	add	a1,a1,a2
 694:	fff6079b          	addiw	a5,a2,-1
 698:	1782                	slli	a5,a5,0x20
 69a:	9381                	srli	a5,a5,0x20
 69c:	fff7c793          	not	a5,a5
 6a0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6a2:	15fd                	addi	a1,a1,-1
 6a4:	177d                	addi	a4,a4,-1
 6a6:	0005c683          	lbu	a3,0(a1)
 6aa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6ae:	fef71ae3          	bne	a4,a5,6a2 <memmove+0x4a>
 6b2:	bfc1                	j	682 <memmove+0x2a>

00000000000006b4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6b4:	1141                	addi	sp,sp,-16
 6b6:	e406                	sd	ra,8(sp)
 6b8:	e022                	sd	s0,0(sp)
 6ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6bc:	c61d                	beqz	a2,6ea <memcmp+0x36>
 6be:	1602                	slli	a2,a2,0x20
 6c0:	9201                	srli	a2,a2,0x20
 6c2:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 6c6:	00054783          	lbu	a5,0(a0)
 6ca:	0005c703          	lbu	a4,0(a1)
 6ce:	00e79863          	bne	a5,a4,6de <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 6d2:	0505                	addi	a0,a0,1
    p2++;
 6d4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6d6:	fed518e3          	bne	a0,a3,6c6 <memcmp+0x12>
  }
  return 0;
 6da:	4501                	li	a0,0
 6dc:	a019                	j	6e2 <memcmp+0x2e>
      return *p1 - *p2;
 6de:	40e7853b          	subw	a0,a5,a4
}
 6e2:	60a2                	ld	ra,8(sp)
 6e4:	6402                	ld	s0,0(sp)
 6e6:	0141                	addi	sp,sp,16
 6e8:	8082                	ret
  return 0;
 6ea:	4501                	li	a0,0
 6ec:	bfdd                	j	6e2 <memcmp+0x2e>

00000000000006ee <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6ee:	1141                	addi	sp,sp,-16
 6f0:	e406                	sd	ra,8(sp)
 6f2:	e022                	sd	s0,0(sp)
 6f4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6f6:	f63ff0ef          	jal	658 <memmove>
}
 6fa:	60a2                	ld	ra,8(sp)
 6fc:	6402                	ld	s0,0(sp)
 6fe:	0141                	addi	sp,sp,16
 700:	8082                	ret

0000000000000702 <sbrk>:

char *
sbrk(int n) {
 702:	1141                	addi	sp,sp,-16
 704:	e406                	sd	ra,8(sp)
 706:	e022                	sd	s0,0(sp)
 708:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 70a:	4585                	li	a1,1
 70c:	0b2000ef          	jal	7be <sys_sbrk>
}
 710:	60a2                	ld	ra,8(sp)
 712:	6402                	ld	s0,0(sp)
 714:	0141                	addi	sp,sp,16
 716:	8082                	ret

0000000000000718 <sbrklazy>:

char *
sbrklazy(int n) {
 718:	1141                	addi	sp,sp,-16
 71a:	e406                	sd	ra,8(sp)
 71c:	e022                	sd	s0,0(sp)
 71e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 720:	4589                	li	a1,2
 722:	09c000ef          	jal	7be <sys_sbrk>
}
 726:	60a2                	ld	ra,8(sp)
 728:	6402                	ld	s0,0(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret

000000000000072e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 72e:	4885                	li	a7,1
 ecall
 730:	00000073          	ecall
 ret
 734:	8082                	ret

0000000000000736 <exit>:
.global exit
exit:
 li a7, SYS_exit
 736:	4889                	li	a7,2
 ecall
 738:	00000073          	ecall
 ret
 73c:	8082                	ret

000000000000073e <wait>:
.global wait
wait:
 li a7, SYS_wait
 73e:	488d                	li	a7,3
 ecall
 740:	00000073          	ecall
 ret
 744:	8082                	ret

0000000000000746 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 746:	4891                	li	a7,4
 ecall
 748:	00000073          	ecall
 ret
 74c:	8082                	ret

000000000000074e <read>:
.global read
read:
 li a7, SYS_read
 74e:	4895                	li	a7,5
 ecall
 750:	00000073          	ecall
 ret
 754:	8082                	ret

0000000000000756 <write>:
.global write
write:
 li a7, SYS_write
 756:	48c1                	li	a7,16
 ecall
 758:	00000073          	ecall
 ret
 75c:	8082                	ret

000000000000075e <close>:
.global close
close:
 li a7, SYS_close
 75e:	48d5                	li	a7,21
 ecall
 760:	00000073          	ecall
 ret
 764:	8082                	ret

0000000000000766 <kill>:
.global kill
kill:
 li a7, SYS_kill
 766:	4899                	li	a7,6
 ecall
 768:	00000073          	ecall
 ret
 76c:	8082                	ret

000000000000076e <exec>:
.global exec
exec:
 li a7, SYS_exec
 76e:	489d                	li	a7,7
 ecall
 770:	00000073          	ecall
 ret
 774:	8082                	ret

0000000000000776 <open>:
.global open
open:
 li a7, SYS_open
 776:	48bd                	li	a7,15
 ecall
 778:	00000073          	ecall
 ret
 77c:	8082                	ret

000000000000077e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 77e:	48c5                	li	a7,17
 ecall
 780:	00000073          	ecall
 ret
 784:	8082                	ret

0000000000000786 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 786:	48c9                	li	a7,18
 ecall
 788:	00000073          	ecall
 ret
 78c:	8082                	ret

000000000000078e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 78e:	48a1                	li	a7,8
 ecall
 790:	00000073          	ecall
 ret
 794:	8082                	ret

0000000000000796 <link>:
.global link
link:
 li a7, SYS_link
 796:	48cd                	li	a7,19
 ecall
 798:	00000073          	ecall
 ret
 79c:	8082                	ret

000000000000079e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 79e:	48d1                	li	a7,20
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7a6:	48a5                	li	a7,9
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 7ae:	48a9                	li	a7,10
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7b6:	48ad                	li	a7,11
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 7be:	48b1                	li	a7,12
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 7c6:	48b5                	li	a7,13
 ecall
 7c8:	00000073          	ecall
 ret
 7cc:	8082                	ret

00000000000007ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7ce:	48b9                	li	a7,14
 ecall
 7d0:	00000073          	ecall
 ret
 7d4:	8082                	ret

00000000000007d6 <kps>:
.global kps
kps:
 li a7, SYS_kps
 7d6:	48d9                	li	a7,22
 ecall
 7d8:	00000073          	ecall
 ret
 7dc:	8082                	ret

00000000000007de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7de:	1101                	addi	sp,sp,-32
 7e0:	ec06                	sd	ra,24(sp)
 7e2:	e822                	sd	s0,16(sp)
 7e4:	1000                	addi	s0,sp,32
 7e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7ea:	4605                	li	a2,1
 7ec:	fef40593          	addi	a1,s0,-17
 7f0:	f67ff0ef          	jal	756 <write>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6105                	addi	sp,sp,32
 7fa:	8082                	ret

00000000000007fc <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 7fc:	715d                	addi	sp,sp,-80
 7fe:	e486                	sd	ra,72(sp)
 800:	e0a2                	sd	s0,64(sp)
 802:	f84a                	sd	s2,48(sp)
 804:	f44e                	sd	s3,40(sp)
 806:	0880                	addi	s0,sp,80
 808:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 80a:	c6d1                	beqz	a3,896 <printint+0x9a>
 80c:	0805d563          	bgez	a1,896 <printint+0x9a>
    neg = 1;
    x = -xx;
 810:	40b005b3          	neg	a1,a1
    neg = 1;
 814:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 816:	fb840993          	addi	s3,s0,-72
  neg = 0;
 81a:	86ce                	mv	a3,s3
  i = 0;
 81c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 81e:	00001817          	auipc	a6,0x1
 822:	89280813          	addi	a6,a6,-1902 # 10b0 <digits>
 826:	88ba                	mv	a7,a4
 828:	0017051b          	addiw	a0,a4,1
 82c:	872a                	mv	a4,a0
 82e:	02c5f7b3          	remu	a5,a1,a2
 832:	97c2                	add	a5,a5,a6
 834:	0007c783          	lbu	a5,0(a5)
 838:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 83c:	87ae                	mv	a5,a1
 83e:	02c5d5b3          	divu	a1,a1,a2
 842:	0685                	addi	a3,a3,1
 844:	fec7f1e3          	bgeu	a5,a2,826 <printint+0x2a>
  if(neg)
 848:	00030c63          	beqz	t1,860 <printint+0x64>
    buf[i++] = '-';
 84c:	fd050793          	addi	a5,a0,-48
 850:	00878533          	add	a0,a5,s0
 854:	02d00793          	li	a5,45
 858:	fef50423          	sb	a5,-24(a0)
 85c:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 860:	02e05563          	blez	a4,88a <printint+0x8e>
 864:	fc26                	sd	s1,56(sp)
 866:	377d                	addiw	a4,a4,-1
 868:	00e984b3          	add	s1,s3,a4
 86c:	19fd                	addi	s3,s3,-1
 86e:	99ba                	add	s3,s3,a4
 870:	1702                	slli	a4,a4,0x20
 872:	9301                	srli	a4,a4,0x20
 874:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 878:	0004c583          	lbu	a1,0(s1)
 87c:	854a                	mv	a0,s2
 87e:	f61ff0ef          	jal	7de <putc>
  while(--i >= 0)
 882:	14fd                	addi	s1,s1,-1
 884:	ff349ae3          	bne	s1,s3,878 <printint+0x7c>
 888:	74e2                	ld	s1,56(sp)
}
 88a:	60a6                	ld	ra,72(sp)
 88c:	6406                	ld	s0,64(sp)
 88e:	7942                	ld	s2,48(sp)
 890:	79a2                	ld	s3,40(sp)
 892:	6161                	addi	sp,sp,80
 894:	8082                	ret
  neg = 0;
 896:	4301                	li	t1,0
 898:	bfbd                	j	816 <printint+0x1a>

000000000000089a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 89a:	711d                	addi	sp,sp,-96
 89c:	ec86                	sd	ra,88(sp)
 89e:	e8a2                	sd	s0,80(sp)
 8a0:	e4a6                	sd	s1,72(sp)
 8a2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8a4:	0005c483          	lbu	s1,0(a1)
 8a8:	22048363          	beqz	s1,ace <vprintf+0x234>
 8ac:	e0ca                	sd	s2,64(sp)
 8ae:	fc4e                	sd	s3,56(sp)
 8b0:	f852                	sd	s4,48(sp)
 8b2:	f456                	sd	s5,40(sp)
 8b4:	f05a                	sd	s6,32(sp)
 8b6:	ec5e                	sd	s7,24(sp)
 8b8:	e862                	sd	s8,16(sp)
 8ba:	8b2a                	mv	s6,a0
 8bc:	8a2e                	mv	s4,a1
 8be:	8bb2                	mv	s7,a2
  state = 0;
 8c0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 8c2:	4901                	li	s2,0
 8c4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 8c6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 8ca:	06400c13          	li	s8,100
 8ce:	a00d                	j	8f0 <vprintf+0x56>
        putc(fd, c0);
 8d0:	85a6                	mv	a1,s1
 8d2:	855a                	mv	a0,s6
 8d4:	f0bff0ef          	jal	7de <putc>
 8d8:	a019                	j	8de <vprintf+0x44>
    } else if(state == '%'){
 8da:	03598363          	beq	s3,s5,900 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 8de:	0019079b          	addiw	a5,s2,1
 8e2:	893e                	mv	s2,a5
 8e4:	873e                	mv	a4,a5
 8e6:	97d2                	add	a5,a5,s4
 8e8:	0007c483          	lbu	s1,0(a5)
 8ec:	1c048a63          	beqz	s1,ac0 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 8f0:	0004879b          	sext.w	a5,s1
    if(state == 0){
 8f4:	fe0993e3          	bnez	s3,8da <vprintf+0x40>
      if(c0 == '%'){
 8f8:	fd579ce3          	bne	a5,s5,8d0 <vprintf+0x36>
        state = '%';
 8fc:	89be                	mv	s3,a5
 8fe:	b7c5                	j	8de <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 900:	00ea06b3          	add	a3,s4,a4
 904:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 908:	1c060863          	beqz	a2,ad8 <vprintf+0x23e>
      if(c0 == 'd'){
 90c:	03878763          	beq	a5,s8,93a <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 910:	f9478693          	addi	a3,a5,-108
 914:	0016b693          	seqz	a3,a3
 918:	f9c60593          	addi	a1,a2,-100
 91c:	e99d                	bnez	a1,952 <vprintf+0xb8>
 91e:	ca95                	beqz	a3,952 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 920:	008b8493          	addi	s1,s7,8
 924:	4685                	li	a3,1
 926:	4629                	li	a2,10
 928:	000bb583          	ld	a1,0(s7)
 92c:	855a                	mv	a0,s6
 92e:	ecfff0ef          	jal	7fc <printint>
        i += 1;
 932:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 934:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 936:	4981                	li	s3,0
 938:	b75d                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 93a:	008b8493          	addi	s1,s7,8
 93e:	4685                	li	a3,1
 940:	4629                	li	a2,10
 942:	000ba583          	lw	a1,0(s7)
 946:	855a                	mv	a0,s6
 948:	eb5ff0ef          	jal	7fc <printint>
 94c:	8ba6                	mv	s7,s1
      state = 0;
 94e:	4981                	li	s3,0
 950:	b779                	j	8de <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 952:	9752                	add	a4,a4,s4
 954:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 958:	f9460713          	addi	a4,a2,-108
 95c:	00173713          	seqz	a4,a4
 960:	8f75                	and	a4,a4,a3
 962:	f9c58513          	addi	a0,a1,-100
 966:	18051363          	bnez	a0,aec <vprintf+0x252>
 96a:	18070163          	beqz	a4,aec <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 96e:	008b8493          	addi	s1,s7,8
 972:	4685                	li	a3,1
 974:	4629                	li	a2,10
 976:	000bb583          	ld	a1,0(s7)
 97a:	855a                	mv	a0,s6
 97c:	e81ff0ef          	jal	7fc <printint>
        i += 2;
 980:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 982:	8ba6                	mv	s7,s1
      state = 0;
 984:	4981                	li	s3,0
        i += 2;
 986:	bfa1                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 988:	008b8493          	addi	s1,s7,8
 98c:	4681                	li	a3,0
 98e:	4629                	li	a2,10
 990:	000be583          	lwu	a1,0(s7)
 994:	855a                	mv	a0,s6
 996:	e67ff0ef          	jal	7fc <printint>
 99a:	8ba6                	mv	s7,s1
      state = 0;
 99c:	4981                	li	s3,0
 99e:	b781                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9a0:	008b8493          	addi	s1,s7,8
 9a4:	4681                	li	a3,0
 9a6:	4629                	li	a2,10
 9a8:	000bb583          	ld	a1,0(s7)
 9ac:	855a                	mv	a0,s6
 9ae:	e4fff0ef          	jal	7fc <printint>
        i += 1;
 9b2:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 9b4:	8ba6                	mv	s7,s1
      state = 0;
 9b6:	4981                	li	s3,0
 9b8:	b71d                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ba:	008b8493          	addi	s1,s7,8
 9be:	4681                	li	a3,0
 9c0:	4629                	li	a2,10
 9c2:	000bb583          	ld	a1,0(s7)
 9c6:	855a                	mv	a0,s6
 9c8:	e35ff0ef          	jal	7fc <printint>
        i += 2;
 9cc:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 9ce:	8ba6                	mv	s7,s1
      state = 0;
 9d0:	4981                	li	s3,0
        i += 2;
 9d2:	b731                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 9d4:	008b8493          	addi	s1,s7,8
 9d8:	4681                	li	a3,0
 9da:	4641                	li	a2,16
 9dc:	000be583          	lwu	a1,0(s7)
 9e0:	855a                	mv	a0,s6
 9e2:	e1bff0ef          	jal	7fc <printint>
 9e6:	8ba6                	mv	s7,s1
      state = 0;
 9e8:	4981                	li	s3,0
 9ea:	bdd5                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 9ec:	008b8493          	addi	s1,s7,8
 9f0:	4681                	li	a3,0
 9f2:	4641                	li	a2,16
 9f4:	000bb583          	ld	a1,0(s7)
 9f8:	855a                	mv	a0,s6
 9fa:	e03ff0ef          	jal	7fc <printint>
        i += 1;
 9fe:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 a00:	8ba6                	mv	s7,s1
      state = 0;
 a02:	4981                	li	s3,0
 a04:	bde9                	j	8de <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 a06:	008b8493          	addi	s1,s7,8
 a0a:	4681                	li	a3,0
 a0c:	4641                	li	a2,16
 a0e:	000bb583          	ld	a1,0(s7)
 a12:	855a                	mv	a0,s6
 a14:	de9ff0ef          	jal	7fc <printint>
        i += 2;
 a18:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 a1a:	8ba6                	mv	s7,s1
      state = 0;
 a1c:	4981                	li	s3,0
        i += 2;
 a1e:	b5c1                	j	8de <vprintf+0x44>
 a20:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 a22:	008b8793          	addi	a5,s7,8
 a26:	8cbe                	mv	s9,a5
 a28:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 a2c:	03000593          	li	a1,48
 a30:	855a                	mv	a0,s6
 a32:	dadff0ef          	jal	7de <putc>
  putc(fd, 'x');
 a36:	07800593          	li	a1,120
 a3a:	855a                	mv	a0,s6
 a3c:	da3ff0ef          	jal	7de <putc>
 a40:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a42:	00000b97          	auipc	s7,0x0
 a46:	66eb8b93          	addi	s7,s7,1646 # 10b0 <digits>
 a4a:	03c9d793          	srli	a5,s3,0x3c
 a4e:	97de                	add	a5,a5,s7
 a50:	0007c583          	lbu	a1,0(a5)
 a54:	855a                	mv	a0,s6
 a56:	d89ff0ef          	jal	7de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a5a:	0992                	slli	s3,s3,0x4
 a5c:	34fd                	addiw	s1,s1,-1
 a5e:	f4f5                	bnez	s1,a4a <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 a60:	8be6                	mv	s7,s9
      state = 0;
 a62:	4981                	li	s3,0
 a64:	6ca2                	ld	s9,8(sp)
 a66:	bda5                	j	8de <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 a68:	008b8493          	addi	s1,s7,8
 a6c:	000bc583          	lbu	a1,0(s7)
 a70:	855a                	mv	a0,s6
 a72:	d6dff0ef          	jal	7de <putc>
 a76:	8ba6                	mv	s7,s1
      state = 0;
 a78:	4981                	li	s3,0
 a7a:	b595                	j	8de <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 a7c:	008b8993          	addi	s3,s7,8
 a80:	000bb483          	ld	s1,0(s7)
 a84:	cc91                	beqz	s1,aa0 <vprintf+0x206>
        for(; *s; s++)
 a86:	0004c583          	lbu	a1,0(s1)
 a8a:	c985                	beqz	a1,aba <vprintf+0x220>
          putc(fd, *s);
 a8c:	855a                	mv	a0,s6
 a8e:	d51ff0ef          	jal	7de <putc>
        for(; *s; s++)
 a92:	0485                	addi	s1,s1,1
 a94:	0004c583          	lbu	a1,0(s1)
 a98:	f9f5                	bnez	a1,a8c <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 a9a:	8bce                	mv	s7,s3
      state = 0;
 a9c:	4981                	li	s3,0
 a9e:	b581                	j	8de <vprintf+0x44>
          s = "(null)";
 aa0:	00000497          	auipc	s1,0x0
 aa4:	60848493          	addi	s1,s1,1544 # 10a8 <malloc+0x46c>
        for(; *s; s++)
 aa8:	02800593          	li	a1,40
 aac:	b7c5                	j	a8c <vprintf+0x1f2>
        putc(fd, '%');
 aae:	85be                	mv	a1,a5
 ab0:	855a                	mv	a0,s6
 ab2:	d2dff0ef          	jal	7de <putc>
      state = 0;
 ab6:	4981                	li	s3,0
 ab8:	b51d                	j	8de <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 aba:	8bce                	mv	s7,s3
      state = 0;
 abc:	4981                	li	s3,0
 abe:	b505                	j	8de <vprintf+0x44>
 ac0:	6906                	ld	s2,64(sp)
 ac2:	79e2                	ld	s3,56(sp)
 ac4:	7a42                	ld	s4,48(sp)
 ac6:	7aa2                	ld	s5,40(sp)
 ac8:	7b02                	ld	s6,32(sp)
 aca:	6be2                	ld	s7,24(sp)
 acc:	6c42                	ld	s8,16(sp)
    }
  }
}
 ace:	60e6                	ld	ra,88(sp)
 ad0:	6446                	ld	s0,80(sp)
 ad2:	64a6                	ld	s1,72(sp)
 ad4:	6125                	addi	sp,sp,96
 ad6:	8082                	ret
      if(c0 == 'd'){
 ad8:	06400713          	li	a4,100
 adc:	e4e78fe3          	beq	a5,a4,93a <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 ae0:	f9478693          	addi	a3,a5,-108
 ae4:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 ae8:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 aea:	4701                	li	a4,0
      } else if(c0 == 'u'){
 aec:	07500513          	li	a0,117
 af0:	e8a78ce3          	beq	a5,a0,988 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 af4:	f8b60513          	addi	a0,a2,-117
 af8:	e119                	bnez	a0,afe <vprintf+0x264>
 afa:	ea0693e3          	bnez	a3,9a0 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 afe:	f8b58513          	addi	a0,a1,-117
 b02:	e119                	bnez	a0,b08 <vprintf+0x26e>
 b04:	ea071be3          	bnez	a4,9ba <vprintf+0x120>
      } else if(c0 == 'x'){
 b08:	07800513          	li	a0,120
 b0c:	eca784e3          	beq	a5,a0,9d4 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 b10:	f8860613          	addi	a2,a2,-120
 b14:	e219                	bnez	a2,b1a <vprintf+0x280>
 b16:	ec069be3          	bnez	a3,9ec <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 b1a:	f8858593          	addi	a1,a1,-120
 b1e:	e199                	bnez	a1,b24 <vprintf+0x28a>
 b20:	ee0713e3          	bnez	a4,a06 <vprintf+0x16c>
      } else if(c0 == 'p'){
 b24:	07000713          	li	a4,112
 b28:	eee78ce3          	beq	a5,a4,a20 <vprintf+0x186>
      } else if(c0 == 'c'){
 b2c:	06300713          	li	a4,99
 b30:	f2e78ce3          	beq	a5,a4,a68 <vprintf+0x1ce>
      } else if(c0 == 's'){
 b34:	07300713          	li	a4,115
 b38:	f4e782e3          	beq	a5,a4,a7c <vprintf+0x1e2>
      } else if(c0 == '%'){
 b3c:	02500713          	li	a4,37
 b40:	f6e787e3          	beq	a5,a4,aae <vprintf+0x214>
        putc(fd, '%');
 b44:	02500593          	li	a1,37
 b48:	855a                	mv	a0,s6
 b4a:	c95ff0ef          	jal	7de <putc>
        putc(fd, c0);
 b4e:	85a6                	mv	a1,s1
 b50:	855a                	mv	a0,s6
 b52:	c8dff0ef          	jal	7de <putc>
      state = 0;
 b56:	4981                	li	s3,0
 b58:	b359                	j	8de <vprintf+0x44>

0000000000000b5a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 b5a:	715d                	addi	sp,sp,-80
 b5c:	ec06                	sd	ra,24(sp)
 b5e:	e822                	sd	s0,16(sp)
 b60:	1000                	addi	s0,sp,32
 b62:	e010                	sd	a2,0(s0)
 b64:	e414                	sd	a3,8(s0)
 b66:	e818                	sd	a4,16(s0)
 b68:	ec1c                	sd	a5,24(s0)
 b6a:	03043023          	sd	a6,32(s0)
 b6e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 b72:	8622                	mv	a2,s0
 b74:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 b78:	d23ff0ef          	jal	89a <vprintf>
}
 b7c:	60e2                	ld	ra,24(sp)
 b7e:	6442                	ld	s0,16(sp)
 b80:	6161                	addi	sp,sp,80
 b82:	8082                	ret

0000000000000b84 <printf>:

void
printf(const char *fmt, ...)
{
 b84:	711d                	addi	sp,sp,-96
 b86:	ec06                	sd	ra,24(sp)
 b88:	e822                	sd	s0,16(sp)
 b8a:	1000                	addi	s0,sp,32
 b8c:	e40c                	sd	a1,8(s0)
 b8e:	e810                	sd	a2,16(s0)
 b90:	ec14                	sd	a3,24(s0)
 b92:	f018                	sd	a4,32(s0)
 b94:	f41c                	sd	a5,40(s0)
 b96:	03043823          	sd	a6,48(s0)
 b9a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b9e:	00840613          	addi	a2,s0,8
 ba2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ba6:	85aa                	mv	a1,a0
 ba8:	4505                	li	a0,1
 baa:	cf1ff0ef          	jal	89a <vprintf>
}
 bae:	60e2                	ld	ra,24(sp)
 bb0:	6442                	ld	s0,16(sp)
 bb2:	6125                	addi	sp,sp,96
 bb4:	8082                	ret

0000000000000bb6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bb6:	1141                	addi	sp,sp,-16
 bb8:	e406                	sd	ra,8(sp)
 bba:	e022                	sd	s0,0(sp)
 bbc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bbe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc2:	00001797          	auipc	a5,0x1
 bc6:	43e7b783          	ld	a5,1086(a5) # 2000 <freep>
 bca:	a039                	j	bd8 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bcc:	6398                	ld	a4,0(a5)
 bce:	00e7e463          	bltu	a5,a4,bd6 <free+0x20>
 bd2:	00e6ea63          	bltu	a3,a4,be6 <free+0x30>
{
 bd6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bd8:	fed7fae3          	bgeu	a5,a3,bcc <free+0x16>
 bdc:	6398                	ld	a4,0(a5)
 bde:	00e6e463          	bltu	a3,a4,be6 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 be2:	fee7eae3          	bltu	a5,a4,bd6 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 be6:	ff852583          	lw	a1,-8(a0)
 bea:	6390                	ld	a2,0(a5)
 bec:	02059813          	slli	a6,a1,0x20
 bf0:	01c85713          	srli	a4,a6,0x1c
 bf4:	9736                	add	a4,a4,a3
 bf6:	02e60563          	beq	a2,a4,c20 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 bfa:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 bfe:	4790                	lw	a2,8(a5)
 c00:	02061593          	slli	a1,a2,0x20
 c04:	01c5d713          	srli	a4,a1,0x1c
 c08:	973e                	add	a4,a4,a5
 c0a:	02e68263          	beq	a3,a4,c2e <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 c0e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 c10:	00001717          	auipc	a4,0x1
 c14:	3ef73823          	sd	a5,1008(a4) # 2000 <freep>
}
 c18:	60a2                	ld	ra,8(sp)
 c1a:	6402                	ld	s0,0(sp)
 c1c:	0141                	addi	sp,sp,16
 c1e:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 c20:	4618                	lw	a4,8(a2)
 c22:	9f2d                	addw	a4,a4,a1
 c24:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c28:	6398                	ld	a4,0(a5)
 c2a:	6310                	ld	a2,0(a4)
 c2c:	b7f9                	j	bfa <free+0x44>
    p->s.size += bp->s.size;
 c2e:	ff852703          	lw	a4,-8(a0)
 c32:	9f31                	addw	a4,a4,a2
 c34:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 c36:	ff053683          	ld	a3,-16(a0)
 c3a:	bfd1                	j	c0e <free+0x58>

0000000000000c3c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 c3c:	7139                	addi	sp,sp,-64
 c3e:	fc06                	sd	ra,56(sp)
 c40:	f822                	sd	s0,48(sp)
 c42:	f04a                	sd	s2,32(sp)
 c44:	ec4e                	sd	s3,24(sp)
 c46:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 c48:	02051993          	slli	s3,a0,0x20
 c4c:	0209d993          	srli	s3,s3,0x20
 c50:	09bd                	addi	s3,s3,15
 c52:	0049d993          	srli	s3,s3,0x4
 c56:	2985                	addiw	s3,s3,1
 c58:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 c5a:	00001517          	auipc	a0,0x1
 c5e:	3a653503          	ld	a0,934(a0) # 2000 <freep>
 c62:	c905                	beqz	a0,c92 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c64:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c66:	4798                	lw	a4,8(a5)
 c68:	09377663          	bgeu	a4,s3,cf4 <malloc+0xb8>
 c6c:	f426                	sd	s1,40(sp)
 c6e:	e852                	sd	s4,16(sp)
 c70:	e456                	sd	s5,8(sp)
 c72:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 c74:	8a4e                	mv	s4,s3
 c76:	6705                	lui	a4,0x1
 c78:	00e9f363          	bgeu	s3,a4,c7e <malloc+0x42>
 c7c:	6a05                	lui	s4,0x1
 c7e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c82:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c86:	00001497          	auipc	s1,0x1
 c8a:	37a48493          	addi	s1,s1,890 # 2000 <freep>
  if(p == SBRK_ERROR)
 c8e:	5afd                	li	s5,-1
 c90:	a83d                	j	cce <malloc+0x92>
 c92:	f426                	sd	s1,40(sp)
 c94:	e852                	sd	s4,16(sp)
 c96:	e456                	sd	s5,8(sp)
 c98:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 c9a:	00001797          	auipc	a5,0x1
 c9e:	37678793          	addi	a5,a5,886 # 2010 <base>
 ca2:	00001717          	auipc	a4,0x1
 ca6:	34f73f23          	sd	a5,862(a4) # 2000 <freep>
 caa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 cac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 cb0:	b7d1                	j	c74 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 cb2:	6398                	ld	a4,0(a5)
 cb4:	e118                	sd	a4,0(a0)
 cb6:	a899                	j	d0c <malloc+0xd0>
  hp->s.size = nu;
 cb8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 cbc:	0541                	addi	a0,a0,16
 cbe:	ef9ff0ef          	jal	bb6 <free>
  return freep;
 cc2:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 cc4:	c125                	beqz	a0,d24 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cc6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 cc8:	4798                	lw	a4,8(a5)
 cca:	03277163          	bgeu	a4,s2,cec <malloc+0xb0>
    if(p == freep)
 cce:	6098                	ld	a4,0(s1)
 cd0:	853e                	mv	a0,a5
 cd2:	fef71ae3          	bne	a4,a5,cc6 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 cd6:	8552                	mv	a0,s4
 cd8:	a2bff0ef          	jal	702 <sbrk>
  if(p == SBRK_ERROR)
 cdc:	fd551ee3          	bne	a0,s5,cb8 <malloc+0x7c>
        return 0;
 ce0:	4501                	li	a0,0
 ce2:	74a2                	ld	s1,40(sp)
 ce4:	6a42                	ld	s4,16(sp)
 ce6:	6aa2                	ld	s5,8(sp)
 ce8:	6b02                	ld	s6,0(sp)
 cea:	a03d                	j	d18 <malloc+0xdc>
 cec:	74a2                	ld	s1,40(sp)
 cee:	6a42                	ld	s4,16(sp)
 cf0:	6aa2                	ld	s5,8(sp)
 cf2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 cf4:	fae90fe3          	beq	s2,a4,cb2 <malloc+0x76>
        p->s.size -= nunits;
 cf8:	4137073b          	subw	a4,a4,s3
 cfc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 cfe:	02071693          	slli	a3,a4,0x20
 d02:	01c6d713          	srli	a4,a3,0x1c
 d06:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d08:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d0c:	00001717          	auipc	a4,0x1
 d10:	2ea73a23          	sd	a0,756(a4) # 2000 <freep>
      return (void*)(p + 1);
 d14:	01078513          	addi	a0,a5,16
  }
}
 d18:	70e2                	ld	ra,56(sp)
 d1a:	7442                	ld	s0,48(sp)
 d1c:	7902                	ld	s2,32(sp)
 d1e:	69e2                	ld	s3,24(sp)
 d20:	6121                	addi	sp,sp,64
 d22:	8082                	ret
 d24:	74a2                	ld	s1,40(sp)
 d26:	6a42                	ld	s4,16(sp)
 d28:	6aa2                	ld	s5,8(sp)
 d2a:	6b02                	ld	s6,0(sp)
 d2c:	b7f5                	j	d18 <malloc+0xdc>
