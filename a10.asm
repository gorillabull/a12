;  Assignment #10
;	Leonardo Vasilev
;	Section 1003 

;  Support Functions.
;  Provided Template

; -----
;  Function getArguments()
;	Gets, checks, converts, and returns command line arguments.

;  Function drawDancingLine()
;	Plots provided dancing function

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

SZ_MIN		equ	200
SZ_MAX		equ	1200

BC_MIN		equ	0
BC_MAX		equ	16777215

LC_MIN		equ	0
LC_MAX		equ	16777215

DS_MIN		equ	0
DS_MAX		equ	15


; -----
;  Variables for getArguments function.

STR_LENGTH	equ	12

ddFive	dd	5

errUsage	db	"Usage: dancingLine -sz <quinaryNumber> -bc <quinaryNumber> "
		db	"-lc <quinaryNumber> -ds <quinaryNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSZsp		db	"Error, image size specifier incorrect."
		db	LF, NULL
errSZvalue	db	"Error, image size value must be between 1300(5) and 14300(5)."
		db	LF, NULL

errBCsp		db	"Error, base color specifier incorrect."
		db	LF, NULL
errBCvalue	db	"Error, base color value must be between "
		db	"0 and 13243332330(5)."
		db	LF, NULL

errLCsp		db	"Error, line color specifier incorrect."
		db	LF, NULL
errLCvalue	db	"Error, line color value must be between "
		db	"0 and 13243332330(5)."
		db	LF, NULL

errBCLCsame	db	"Error, base color and line color can "
		db	"not be the same."
		db	LF, NULL

errDSsp		db	"Error, draw speed specifier incorrect."
		db	LF, NULL
errDSvalue	db	"Error, draw speed color value must be between "
		db	"0 and 30(5)."
		db	LF, NULL

; -----
;  Variables for draw dancing line function.

pi		dq	3.14159265358979	; constant
fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0

tBase		dq	0.0016			; values tStep formula
tOffset		dq	0.00025
tScale		dq	200.0

drawScale	dq	5000.0			; scale factor for draw speed

tStep		dq	0.0			; t step
sStep		dq	0.0			; s step


bcRed		dd	0			; base color
bcGreen		dd	0
bcBlue		dd	0

lcRed		dd	0			; line color
lcGreen		dd	0
lcBlue		dd	0

t		dq	0.0			; loop index variable
x		dq	0.0			; current x
y		dq	0.0			; current y
s		dq	0.0			; s variable (for line dance)

; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize
extern	glutInitWindowPosition, glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern	glPointSize, glutPostRedisplay

extern	cos, sin


; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx
	push	rsi
	push	rdi
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rdx
	pop	rdi
	pop	rsi
	pop	rbx
	ret

; ******************************************************************
;  Boolean value returning function getArguments()
;	Gets size, draw speed, square color, and line color
;	from the command line.
;	- converts ASCII/Quinary parameters to integer
;	- performs all applicable error checking

;	Command line format (fixed order):
;	  "-sz <quinaryNumber> -bc <quinaryNumber> -lc <quinaryNumber>
;					-ds <quinaryNumber>"

; -----
;  HLL CAll:
;	bool = getArguments(argc, argv, &size, &baseColor,
;					&lineColor, &drawSpeed);

; -----
;  Arguments:
;	1) ARGC, double-word, value rdi 
;	2) ARGV, double-word, address rsi 
;	3) size, double-word, address rdx 
;	4) base color, double-word, address rcx 
;	5) line color, double-word, address r8 
;	6) draw speed, double-word, address r9 

global getArguments
getArguments:
push r12 
push r13
push r14
push r15

;stack
push rbp 
mov rbp, rsp 

;local vars
sub rsp, 20								;should be enough for len 
sub rsp, 20-8	;line color func param addr
sub rsp, 20-8-8	;draw speed param  addr
sub rsp, 20-8-8-8	;rdx...............

;store func params on stack 
lea rax, qword[rbp-20-8]
mov qword[rax], r8
lea rax, qword[rbp-20-8-8]
mov qword[rax],r8
lea rax, qword[rbp-20-8-8-8]
mov qword[rax],rdx

;check if user has not entered any agruments 
cmp rdi , 1
je  usageMessageError 
;check if user has entered too few arguments
cmp rdi , 9 
jl tooFewArgsError

;check arg 1 -sz to see if its written correctly 
mov rax, [rsi+8*1] 									;first char 
cmp byte[rax ], 45
jne incorrectImageSizeSpec
cmp byte[rax+1 ], 115								;second char		
jne incorrectImageSizeSpec
cmp byte[rax+2 ], 122									;3rd 
jne incorrectImageSizeSpec
cmp byte[rax+3 ], 0									
jne incorrectImageSizeSpec								;null terminat

;---------------------------------------------------
;check base color specifier -bc 
mov rax, [rsi+8*3] 										;first char 
cmp byte[rax ], 45
jne incorrectBaseColorSpec
cmp byte[rax+1 ], 98									;second char		
jne incorrectBaseColorSpec
cmp byte[rax+2 ], 99									;3rd 
jne incorrectBaseColorSpec
cmp byte[rax+3 ], 0									
jne incorrectBaseColorSpec								;null terminat


;check line colors 
mov rax, [rsi+8*5] 										;first char 
cmp byte[rax ], 45
jne incorrectLineColorSpec
cmp byte[rax+1 ], 108									;second char		
jne incorrectLineColorSpec
cmp byte[rax+2 ], 99									;3rd 
jne incorrectLineColorSpec
cmp byte[rax+3 ], 0									
jne incorrectLineColorSpec								;null terminat


;check draw speed 
mov rax, [rsi+8*7] 										;first char 
cmp byte[rax ], 45
jne incorrectDrawSpeedSpec
cmp byte[rax+1 ], 100									;second char		
jne incorrectDrawSpeedSpec
cmp byte[rax+2 ], 115									;3rd 
jne incorrectDrawSpeedSpec
cmp byte[rax+3 ], 0									
jne incorrectDrawSpeedSpec								;null terminat



;convert numbers and check ranges, also check for invalid chars like 
;33a0 
;start with the first param.

;init local arr with 0 
mov r12, 0 
lea rax, qword[rbp-20]	
initzero1:
mov byte[rax], 0 
inc rax
inc r12 
cmp r12, 20
jne initzero1

lea rax, qword[rbp-20]							;start of list 
mov r12, [rsi+8*2]					;addr of leftmost digit 
mov r8, 0 							;counter
invertLoop1:
mov r13b, byte[r12]
mov byte[rax], r13b 
inc r12 
inc rax 
inc r8 							;counter 
cmp byte[r12], NULL
jne invertLoop1

;now digits are in stack with first one at rbp + r1r84 
mov r15, 1                          ;base 
mov r14, 0                          ;result 
mov rax , 0
mov r10, r8
dec r10  
conversionLoop1:
mov rax, 0
mov al ,byte[rbp-20+r10]      ;temp = buff[i] 
sub eax, 48                          ;convert to a number 
cmp eax, 5
jae letterRead 
mul r15d                            ;temp * base 
add r14, rax                        ;res = res + temp * base 
mov rax , r15 
mov r13, 5                          ;base mult 
mul r13                             ;base *=5 go to next power                  
mov r15, rax 
dec r8 
dec r10 
cmp r8, 0
jne conversionLoop1 ;^^

;check for sizes 
cmp r14, SZ_MIN
jl imageSizeIncorrect
cmp r14, SZ_MAX
jg imageSizeIncorrect



;^^^
lea rax, qword[rbp-20-8-8-8]
mov r8, qword[rax]
mov dword[r8], r14d 
;2nd -------------;-------------;-------------;-------------


;init local arr with 0 
mov r12, 0 
lea rax, qword[rbp-20]	
initzero2:
mov byte[rax], 0 
inc rax
inc r12 
cmp r12, 20
jne initzero2

lea rax, qword[rbp-20]							;start of list 
mov r12, [rsi+8*4]					;addr of leftmost digit 
mov r8, 0 							;counter
invertLoop2:
mov r13b, byte[r12]
mov byte[rax], r13b 
inc r12 
inc rax 
inc r8 							;counter 
cmp byte[r12], NULL
jne invertLoop2

;now digits are in stack with first one at rbp + r1r84 
mov r15, 1                          ;base 
mov r14, 0                          ;result 
mov rax , 0
mov r10, r8
dec r10  
conversionLoop2:
mov rax, 0
mov al ,byte[rbp-20+r10]      ;temp = buff[i] 
sub eax, 48                          ;convert to a number 
cmp eax, 5
jae letterRead 
mul r15d                            ;temp * base 
add r14, rax                        ;res = res + temp * base 
mov rax , r15 
mov r13, 5                          ;base mult 
mul r13                             ;base *=5 go to next power                  
mov r15, rax 
dec r8 
dec r10 
cmp r8, 0
jne conversionLoop2 ;^^

;base color 
cmp r14, BC_MIN
jl baseColorSizeIncorrect
cmp r14, BC_MAX
jg baseColorSizeIncorrect



;^^^
mov dword[rcx], r14d 


;3rd-------------;-------------;-------------;-------------


;init local arr with 0 
mov r12, 0 
lea rax, qword[rbp-20]	
initzero3:
mov byte[rax], 0 
inc rax
inc r12 
cmp r12, 20
jne initzero3

lea rax, qword[rbp-20]							;start of list 
mov r12, [rsi+8*6]					;addr of leftmost digit 
mov r8, 0 							;counter
invertLoop3:
mov r13b, byte[r12]
mov byte[rax], r13b 
inc r12 
inc rax 
inc r8 							;counter 
cmp byte[r12], NULL
jne invertLoop3

;now digits are in stack with first one at rbp + r1r84 
mov r15, 1                          ;base 
mov r14, 0                          ;result 
mov rax , 0
mov r10, r8
dec r10  
conversionLoop3:
mov rax, 0
mov al ,byte[rbp-20+r10]      ;temp = buff[i] 
sub eax, 48                          ;convert to a number
cmp eax, 5
jae letterRead  
mul r15d                            ;temp * base 
add r14, rax                        ;res = res + temp * base 
mov rax , r15 
mov r13, 5                          ;base mult 
mul r13                             ;base *=5 go to next power                  
mov r15, rax 
dec r8 
dec r10 
cmp r8, 0
jne conversionLoop3 ;^^


;line color
cmp r14, LC_MIN
jl lineColorSizeIncorrect
cmp r14, LC_MAX
jg lineColorSizeIncorrect



;^^^
lea rax, qword[rbp-20-8]
mov r8, qword[rax]
mov dword[r8], r14d 


;4th-------------;-------------;-------------;-------------


;init local arr with 0 
mov r12, 0 
lea rax, qword[rbp-20]	
initzero4:
mov byte[rax], 0 
inc rax
inc r12 
cmp r12, 20
jne initzero4

lea rax, qword[rbp-20]							;start of list 
mov r12, [rsi+8*8]					;addr of leftmost digit 
mov r8, 0 							;counter
invertLoop4:
mov r13b, byte[r12]
mov byte[rax], r13b 
inc r12 
inc rax 
inc r8 							;counter 
cmp byte[r12], NULL
jne invertLoop4

;now digits are in stack with first one at rbp + r1r84 
mov r15, 1                          ;base 
mov r14, 0                          ;result 
mov rax , 0
mov r10, r8
dec r10  
conversionLoop4:
mov rax, 0
mov al ,byte[rbp-20+r10]      ;temp = buff[i] 
sub eax, 48                          ;convert to a number 
cmp eax, 5
jae letterRead 
mul r15d                            ;temp * base 
add r14, rax                        ;res = res + temp * base 
mov rax , r15 
mov r13, 5                          ;base mult 
mul r13                             ;base *=5 go to next power                  
mov r15, rax 
dec r8 
dec r10 
cmp r8, 0
jne conversionLoop4 ;^^

;draw speed
cmp r14, DS_MIN
jl drawSpeedColorIncorrect
cmp r14, DS_MAX
jg drawSpeedColorIncorrect

;^^^
lea rax, qword[rbp-20-8-8]
mov r8, qword[rax]
mov dword[r8], r14d 
;-------------;-------------;-------------;-------------


;finally check base color and line color, they must be different. 
;cmp baseClr, lineClr
mov eax, dword[rcx]	;base color
mov ebx, dword[r8]	;line color 
cmp eax, ebx 
je lineColBaseColSame

;otherwise everything else is set so return
jmp returnTrue


usageMessageError:
;print usage message 
mov rdi, errUsage
call printString
jmp return 

tooFewArgsError:
;print invalid or incomplete number of arguments ;(too few args entered)
mov rdi,errBadCL
call printString
jmp return 

incorrectImageSizeSpec:
;print incorrect image size spec error 
mov rdi, errSZsp
call printString
jmp return 

incorrectLineColorSpec:
;print incorrect line color spec 
mov rdi, errLCsp
call printString
jmp return 

incorrectBaseColorSpec:
mov rdi, errBCsp
call printString
jmp return 

incorrectDrawSpeedSpec:
mov rdi, errDSsp
call printString
jmp return 

;size errors 
imageSizeIncorrect:
mov rdi, errSZvalue
call printString
jmp return 

baseColorSizeIncorrect:
mov rdi, errBCvalue
call printString
jmp return 

lineColorSizeIncorrect:
mov rdi, errLCvalue
call printString
jmp return 

drawSpeedColorIncorrect:
mov rdi , errDSvalue
call printString
jmp return 

lineColBaseColSame:
mov rdi, errBCLCsame
call printString
jmp return 

letterRead:
mov rdi, errBadCL
call printString
jmp return 


return: 
mov rsp,rbp  
pop rbp

pop r15
pop r14
pop r13 
pop r12 


mov rax, FALSE 
jmp returnFinal

returnTrue:
mov rsp,rbp  
pop rbp 

pop r15
pop r14
pop r13 
pop r12 


mov rax, TRUE
jmp returnFinal

returnFinal:

ret 




; ******************************************************************
;  Draw dancing line function.
;  Plots the following equations:

;	for (t=0.0; t<1.0; t+=tStep) {

;		x = cos(2.0*pi*t)^3;
;		y = sin(2.0*pi*t)^3;
;		glColor3ub(255,0,255);
;		glVertex2d(x, y);

;		x = cos(2.0*pi*s)*t;
;		y = sin(2.0*pi*s)*(1.0-t);
;		glColor3ub(0,255,0);
;		glVertex2d(x, y);

;	}

; -----
;  Global variables accessed.

common	imageSize	1:4			; image size
common	baseColor	1:4			; base color (for square)
common	lineColor	1:4			; line color (for dancing line)
common	drawSpeed	1:4			; draw speed

global drawDancingLine
drawDancingLine:
	push	rbp
	push	rbx
	push	r12

; -----
;  set base color(r,g,b) values
mov eax, bcRed
mov dword[eax],255
mov eax, bcGreen
mov dword[eax],0
mov eax, bcBlue
mov dword[eax], 255





; -----
;  set line color(r,g,b) values
mov eax, lcRed
mov dword[eax],255
mov eax, lcGreen
mov dword[eax],0
mov eax, lcBlue
mov dword[eax], 255



; -----
;  Set tStep speed based on user entered image size
;	tStep = tBase - (tOffset * (real(imageSize)/tScale))
movsd xmm0, qword[tOffset]
cvtsi2sd xmm1, dword[imageSize]
movsd xmm2, qword[tScale]
divsd xmm1,xmm2 
mulsd xmm1, xmm0
movsd xmm0, qword[tBase]
subsd xmm0, xmm1
movsd qword[tStep], xmm0 



; -----
;  Set sStep speed based on user entered drawSpeed
;	sStep = drawSpeed / drawScale
cvtsi2sd xmm0, dword[drawSpeed]
cvtsi2sd xmm1, dword[drawScale]
divsd xmm0, xmm1 
movsd qword[sStep], xmm0 



; -----
;  Prepare for drawing
;  Initialize for drawing points

	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Main plot loop.
;	find iterations -> (1.0 / tStep)

movsd xmm12, qword[t]
;find x 
movsd xmm0, qword[pi] 
movsd xmm1, qword[t]
mulsd xmm0, xmm1 		;pi*t 
movsd xmm1, qword[fltTwo]
mulsd xmm0, xmm1 				;2*pi*t 
;^3 
;call cos
mulsd xmm0, xmm0
mulsd xmm0, xmm0
mulsd xmm0, xmm0 
movsd xmm6, xmm0 ;x in xmm6
movsd qword[x], xmm0

;find y
movsd xmm0, qword[pi] 
movsd xmm1, qword[t]
mulsd xmm0, xmm1 		;pi*t 
movsd xmm1, qword[fltTwo]
mulsd xmm0, xmm1 				;2*pi*t 
;^3 
;call sin
mulsd xmm0, xmm0
mulsd xmm0, xmm0
mulsd xmm0, xmm0 
movsd xmm5, xmm0 ;y in xmm5
movsd qword[y], xmm0

mov rdi ,255; dword[bcRed]
mov rsi, 255 ;dword[bcGreen]
mov rdx , 123 ;dword[bcBlue]
call glColor3ub


mov r14, 0

forLoop1:
movsd xmm0, qword[x]
mov eax, 1 
cvtsi2sd xmm2, eax 
addsd xmm0, xmm2
movsd qword[x], xmm0 
movsd xmm1, qword[y]
addsd xmm1, xmm2
movsd qword[y], xmm1
call glVertex2d

inc r14 
cmp r14, 2000
jb forLoop1

addsd xmm12, qword[fltOne]



; -----
;  Main loop done, call required openGL functions

	call	glEnd
	call	glFlush

	call	glutPostRedisplay

; -----
;  Update s before leaving function




; -----
;  Check if s is > 1.0 and if so, reset s to 0.0

	ucomisd	xmm0, qword [fltOne]
	jb	sIsSet
	movsd	xmm0, qword [fltZero]
	movsd	qword [s], xmm0
sIsSet:

; -----
;  Done, return

	pop	r12
	pop	rbx
	pop	rbp
	ret

; ******************************************************************
