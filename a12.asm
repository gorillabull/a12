;  CS 218
;  k-hyperperfect numbers
;  Threading program, provided template

; ***************************************************************

section	.data

; -----
;  Define standard constants.




LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	-1

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

; -----
;  Message strings

header		db	LF, "*******************************************", LF
		db	ESC, "[1m", "Number Type Counting Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Counting", LF, NULL
pMsgMain	db	"Perfect Count: ", NULL
aMsgMain	db	"hp num: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

numberLimit	dq	0
threadCount	dd	0

; -----
;  Globals (used by threads)

idxCounter	dq	2
hpCount		dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0
pthreadID3	dq	0, 0, 0, 0, 0

; -----
;  Variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Variables for getParams function

LIMITMIN	equ	100
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./hyperPerfect -th <1|2|3|4> ",
		db	"-lm <quinaryNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errTHspec	db	"Error, invalid thread count specifier."
		db	LF, NULL
errTHvalue	db	"Error, invalid thread count value."
		db	LF, NULL
errLSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLValue	db	"Error, limit out of range."
		db	LF, NULL

; -----
;  Variables for int2quinary function

; -----
;  Variables for quinary2int function

dFive		dd	10
tmpNum		dq	0

; -----

section	.bss
tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Number type counting program.

global main
main:
	push	rbp
	mov	rbp, rsp

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, threadCount
	mov	rcx, numberLimit
	call	getParams

	cmp	rax, TRUE
	jne	progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

; -----
;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);
;  if sequntial, start 1 thread
;  if parallel, start 3 threads

	mov	rdi, pthreadID0
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create


;	YOUR CODE GOES HERE

    mov eax, dword[threadCount]
    mov ebx,  2
    cmp eax, ebx 
    je twoThreads
    mov ebx,  3
    cmp eax, ebx 
    je threeThreads
    mov ebx,  4
    cmp eax, ebx 
    je fourThreads
    jmp WaitForThreadCompletion

    twoThreads:
    mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create
    jmp WaitForThreadCompletion

    threeThreads:
    mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

    mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create
    jmp WaitForThreadCompletion

    fourThreads:
    mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

    mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create

    mov	rdi, pthreadID3
	mov	rsi, NULL
	mov	rdx, hpNumberCounter
	mov	rcx, NULL
	call	pthread_create
    jmp WaitForThreadCompletion
;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

WaitForThreadCompletion:
	mov	rdi, qword [pthreadID0]
	mov	rsi, NULL
	call	pthread_join

	mov	rdi, qword [pthreadID1]
	mov	rsi, NULL
	call	pthread_join

	mov	rdi, qword [pthreadID2]
	mov	rsi, NULL
	call	pthread_join

	mov	rdi, qword [pthreadID3]
	mov	rsi, NULL
	call	pthread_join
;	YOUR CODE GOES HERE



; -----
;  Display final count

showFinalResults:
	mov	rdi, newLine
	call	printString

	mov	rdi, pMsgMain
	call	printString
	mov	rdi, qword [hpCount]
	mov	rsi, tmpString
	call	int2quinary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	pop	rbp
	mov	rdi, SYS_exit			; system call for exit
	mov	rsi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, hpNumberCounter()
;	Determine if the numbers is 2-hyperperfect for
;	numbers between 1 and numberLimit (gloabally available)

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)

global hpNumberCounter
hpNumberCounter:


;	YOUR CODE GOES HERE

    mov r14, qword[numberLimit] ;eg 500 000
    mov r15, 0  ; I 
    mov r13, 0  ;sumArr 
    mov r11, 0  ;rhs 

    whileLoop:
    ;sum up the divisors 
    mov r12, 1  ;i 
    divisorsSum:
    mov rax, r15
    mov rdx, 0 
    div r12     ;I%i

    cmp rdx, 0  ;==0? 
    jne notDivisor
    add r13,r12             ;sumArr +=i 

    notDivisor:
    inc r12 
    cmp r12, r15
    jl divisorsSum

    dec r13                 ;sumarr -1 
    mov rax, r13 
    mov r13, 2 
    mul r13                 ;2*  sumarr -1 
    mov r13, rax 
    inc r13                 ;1+ 2*(sumarr-1)

    cmp r13, r15 
    jne notHP
    mov rax, qword[hpCount]
    inc rax 
    mov qword[hpCount], rax 
    notHP:


    ;I++
    call spinLock
    mov r15, qword[idxCounter]
    inc r15  
    mov qword[idxCounter], r15
    ;done modifying mem so unlock 
    call spinUnlock
    
    cmp r15, r14
    jle whileLoop
    
    
	ret

; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Convert integer to ASCII/Quinary string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value - rdi 
;	2) string, address - rsi 
; -----
;  Returns:
;	ASCII/Quinary string (NULL terminated)

global	int2quinary
int2quinary:


;	YOUR CODE GOES HERE
	push r15 
	push r14 
	push r13 
	push r12 
	push r11 
	push r10 

	;null terminate 
	mov byte[rsi+19], 0  
	;init with spaces 
	mov rax, 0 
	i2qInitZeroesLoop:
	mov byte[rsi+rax], 32 
	inc rax 
	cmp rax, 19 
	jl i2qInitZeroesLoop

	mov r15, 5 		;base divisor 
	mov r14, 0 		;store remainder here 
	mov r13 ,18 	;iterator 
	mov r11, rdi 	;copy integer 

	mov rax, r11  
	i2qLoop:
	mov rax, r11 
	mov rdx , 0 
	div r15 
	mov r14, rdx 	
	sub r11, r14 	;n = n - rem 
	mov rax, r11 
	mov rdx, 0 
	div r15 
	mov r11, rax 	;n = n /5 
	add r14, 48 
	mov byte[rsi+r13], r14b ;str[i] = rem + 48 
	dec r13 
	cmp r11, 0 
	jg i2qLoop


	pop r10 
	pop r11 
	pop r12 
	pop r13 
	pop r14 
	pop r15 


	ret

; ******************************************************************
;  Function: Check and convert ASCII/Quinary to integer

;  Example HLL Call:
;	stat = quinary2int(qStr, &num); - no 
;	rdi - quinary string 
;	rsi - return address or use rax 
;	returns rax - quinary int converted to b10 


global	quinary2int
quinary2int:
	push r13 
	push r14 
	push r15 


;	YOUR CODE GOES HERE
	mov r15, 1 ;base  b
	mov r14, 5 ;power mul 
	mov r13, 0	;rem  
	mov r11, 0 ;result 
	mov r12, rdi 					;the int 
	mov r10, 0 					;iterator 

    ;find # of digits 
    findNumOfDigits:
    mov al, byte[rdi+r10]
    inc r10
    cmp al, 0
    jne findNumOfDigits

    dec r10                     ;iter-- 
    dec r10

	q2iLoop:
    mov r13b, byte[rdi+r10] ;arr[iter] - 48
    sub r13b, 48 
    mov rax, r13 
    mul r15                 ;rem * b 
    add r11, rax            ;result +=rem * b 
    mov rax, r15            ;b 
    mul r14                 ;b*5 
    mov r15, rax            ;b=b*b

    dec r10 
	cmp r10, 0
	jge q2iLoop
	
	mov rax, r11 

	pop r15
	pop r14 
	pop r13 


	ret

; ******************************************************************
;  Generic funciton to display a string to the screen.
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

; -----
; Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	thread count and user entered limit.

;  Example HLL call:
;	stat = getParams(argc, argv, &isSequntial, &primeLimit)

;  This routine performs all error checking, conversion of ASCII/Quinary
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;./main	-th <1|2|3|4> -lm <quinaryNumber>
; 0       1     2  	    3    4 
; -----
;  Arguments:
;	1) ARGC, value	- rdi 
;	2) ARGV, address - rsi 
;	3) thread count (dword), address - rdx 
;	4) prime limit (qword), address - rcx 


global getParams
getParams:


;	YOUR CODE GOES HERE
		
	;cmp first identifier to see if its valid 
	mov rax, [rsi+8*1] 	;-th  
	cmp byte[rax ], 45 	;- 
	jne commandLineOptError
	cmp byte[rax+1] , 116; t 
	jne commandLineOptError
	cmp byte[rax+2] , 104; h 
	jne commandLineOptError
	cmp byte[rax+3] , 0;  
	jne commandLineOptError

	;check the second identifier 
	mov rax, [rsi+8*3] 	;-lm  
	cmp byte[rax ], 45 	;- 
	jne commandLineOptError
	cmp byte[rax+1] , 108; l 
	jne commandLineOptError
	cmp byte[rax+2] , 109; m 
	jne commandLineOptError
	cmp byte[rax+3] , 0; 
	jne commandLineOptError


	;get thread ct 
	mov rax, [rsi+8*2]
	mov r15b, byte[rax]
	sub r15b, 48 
	mov dword[rdx], r15d 	;return thread count 
	push rcx 

	
	;convert from quinary to int  
	mov rax, [rsi+8*4]	;quinary number 
	mov rdi, rax; qword[rax]
	call quinary2int

    pop rcx 
	mov r15, rax 		;store in base 10 
	mov qword[rcx], r15  ;return limit 
	jmp funcDone;


	commandLineOptError:

    mov dword[rdx], 1 
    mov dword[rcx], 500000
    mov rax, TRUE

	funcDone;
	mov rax,TRUE

	ret

; ******************************************************************
