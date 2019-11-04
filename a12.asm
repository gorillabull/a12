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




;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

WaitForThreadCompletion:
	mov	rdi, qword [pthreadID0]
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


    whileLoop:
    call spinLock
    mov r15, qword[idxCounter]
    inc r15  
    mov qword[idxCounter], r15
    ;done modifying mem so unlock 
    call spinUnlock
    
    cmp r15, 500000
    jl whileLoop
    
    mov r15, qword[hpCount]
    inc r15 
    mov qword[hpCount],r15 


    
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
;	1) integer, value
;	2) string, address
; -----
;  Returns:
;	ASCII/Quinary string (NULL terminated)

global	int2quinary
int2quinary:


;	YOUR CODE GOES HERE


	ret

; ******************************************************************
;  Function: Check and convert ASCII/Quinary to integer

;  Example HLL Call:
;	stat = quinary2int(qStr, &num);

global	quinary2int
quinary2int:


;	YOUR CODE GOES HERE


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
;	-th <1|2|3|4> -lm <quinaryNumber>

; -----
;  Arguments:
;	1) ARGC, value
;	2) ARGV, address
;	3) thread count (dword), address
;	4) prime limit (qword), address

global getParams
getParams:


;	YOUR CODE GOES HERE
    mov dword[rdx], 1 
    mov dword[rcx], 500000
    mov rax, TRUE

	ret

; ******************************************************************
