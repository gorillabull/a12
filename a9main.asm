;  CS 218 - Assignment 9
;  Functions Template.
;	Leonardo Vasilev
;	Section 1003 

; --------------------------------------------------------------------
;  Write assembly language functions.

;  The value returning function, rdQuinaryNum(), should read
;  a quinary number from the user (STDIN) and perform
;  apprpriate error checking and conversion (string to integer).

;  The void function, countSort(), sorts the numbers into
;  ascending order (small to large).  Uses the insertion sort
;  algorithm modified to sort in ascending order.

;  The value returning function, lstAverage(), to return the
;  average of a list.

;  The void function, listStats(), finds the minimum, median,
;  and maximum, sum, and average for a list of numbers.
;  The median is determined after the list is sorted.
;  Must call the lstAverage() function.

;  The value returning function, coVariance(), computes the
;  co-variance for the two passed data sets.

;  The boolean function, rdQuinaryNum(), reads a quinary
;  number from standard input, performs conversion, and
;  error checks and range checks the value.

; ********************************************************************************
 

section	.data

; -----
;  Define standard constants.



TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

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

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

MIN_NUM		equ	5
MAX_NUM		equ	156250
STRLEN		equ 50 
BUFFSIZE	equ	51			; 50 chars plus NULL

LIMIT		equ	MAX_NUM+1

; -----
;  NO static local variables allowed...


; ********************************************************************************


section	.text

; --------------------------------------------------------
;  Read an ASCII/quinary number from the user.
;  Perform appropriate error checking and, if OK,
;  convert to integer and return true.

;  If there is an error, print the applicable passed
;  error message string.

;  If the user enters a return (no other input, no
;  leading spaces), the function should return true.
;  This indicates no further input.

; -----
;  HLL Call:
;	status = rdQuinaryNum(&numberRead, promptStr, errMsg1,
;					errMsg2, errMSg3);

;  Arguments Passed:
;	1) numberRead, addr - rdi
;	2) promptStr, addr - rsi
;	3) errMsg1, addr - rdx
;	3) errMsg2, addr - rcx
;	3) errMsg3, addr - r8

;  Returns:
;	number read (via reference)
;	TRUE or FALSE



;	YOUR CODE GOES HERE
global rdQuinaryNum
rdQuinaryNum:

push rbp 
mov rbp,  rsp 
sub rsp, BUFFSIZE                   ;allocate buffer on stack 
sub rsp, 1                          ;allocate space for read ch
sub rsp , 8							;hold prompt addr in here

sub rsp , 8							;first err message here
sub rsp, 8							;second err 
sub rsp, 8							;third 
sub rsp, 1 							;count how many times the loop 
									;was reset 


;push rdi                            ;pres return value addr

mov r9, rdi 						 ;store return ref

lea rax, qword[rbp-BUFFSIZE-1-8]
mov qword[rax], rsi 				;prompt addr 

;put error messages on stack 
lea rax, qword[rbp-BUFFSIZE-1-8-8]
mov qword[rax],rdx 

lea rax, qword[rbp-BUFFSIZE-1-8-16]
mov qword[rax],rcx 


lea rax, qword[rbp-BUFFSIZE-1-8-24]
mov qword[rax],r8 

lea rax, byte[rbp-BUFFSIZE-1-8-24-1]
mov byte[rax], 0 					;set reset counter to 0 




mov rdi, rsi            

call printString 


resetRead:

lea rax, byte[rbp-BUFFSIZE-1-8-24-1]
inc byte[rax]						;counter ++ 



									;clear buffer
mov r15, 0 
lea r14, byte[rbp-BUFFSIZE]
clearBuffer:
mov byte[r14], 0
inc r14 

inc r15 
cmp r15, BUFFSIZE
jl clearBuffer

									;clear char buffer
lea r14, byte[rbp-BUFFSIZE-1]
mov byte[r14], 0

;mov rsi, r9   
lea rax, qword[rbp-BUFFSIZE-1-8]
mov rsi, qword[rax] 				;prompt addr 


;************************************************************************************
;read characters from the user (one at a time)
lea rbx, byte[rbp-BUFFSIZE]          ;address of buffer 
mov r12, 0 
readCharacters:
;----read character from user 
mov rax, SYS_read                   ;syscode for read 
mov rdi, STDIN                      ;standard in 
lea rsi, byte[rbp-BUFFSIZE-1]       ;address of chr 
mov rdx, 1                          ;count how many to read 
syscall

mov al, byte[rbp-BUFFSIZE-1]        ;get char just read 
cmp al, LF                          ;if /n done 
je readDone 

;check if its a valid digit 
cmp al,48
jl invalidChar
cmp al, 52
jg invalidChar


inc r12 
cmp r12, STRLEN                     ;if # chars >=STRLEN
jae readCharacters                  ;stop placing in buff, wait for LF

mov byte[rbx], al                   ;buffer[i]  = char 
inc rbx                             ;update tmpStr addr 

jmp readCharacters
readDone:

cmp r12, 0
je nothingRead

cmp r12, STRLEN
ja readTooMany




;if the first two conditions are false null terminate and move 
;onto converting it 

mov byte[rbx], NULL                 ;null termination 
jmp gotoConvert



gotoConvert:



mov r15, 1                          ;base 
mov r14, 0                          ;result 
mov rax , 0
mov r10, r12
dec r10  
conversionLoop:
mov al ,byte[rbp-BUFFSIZE+r10]      ;temp = buff[i] 
sub eax, 48                          ;convert to a number 
mul r15d                            ;temp * base 
add r14, rax                        ;res = res + temp * base 
mov rax , r15 
mov r13, 5                          ;base mult 
mul r13                             ;base *=5 go to next power                  
mov r15, rax 
dec r12 
dec r10 
cmp r12, 0
jne conversionLoop                     ;

;check if too big or small 
mov rax, r14 
cmp rax, MIN_NUM
jl outOfRange
cmp rax, MAX_NUM
jg outOfRange

;pop rdi 
mov rdi , r9 
                                        ;finally return value 
mov dword[rdi], eax 
mov eax, TRUE
jmp return 

readTooMany:

mov eax, FALSE

lea rax, qword[rbp-BUFFSIZE-1-8-24]
mov rdi, qword[rax] ;r8 addr 

;mov rdi, r8                            ;1st 
call printString
jmp resetRead 

nothingRead:
mov eax, FALSE
jmp return 

invalidChar:


mov eax, FALSE
lea rax, qword[rbp-BUFFSIZE-1-8-8]
mov rdi, qword[rax]	;rdx  
;mov rdi, rdx                            ;2nd error 
call printString
jmp resetRead; 

outOfRange:


mov eax, FALSE
lea rax, qword[rbp-BUFFSIZE-1-8-16]
mov rdi, qword[rax]	;rcx 

;mov rdi, rcx                             ;3rd error  
call printString
jmp resetRead; 
 


return:

mov rsp, rbp 
pop rbp 

ret 


; --------------------------------------------------------
;  Count sort function.

; -----
;  Count Sort Algorithm:

;	for  i = 0 to (len-1)
;	    count[list[i]] = count[list[i]] + 1
;	endFor

;	p = 0
;	for  i = 0 to (limit-1) do
;	    if  count[i] <> 0  then
;		for  j = 1 to count[i]
;		    list[p] = i
;		    p = p + 1
;		endFor
;	    endIf
;	endFor


; -----
;  HLL Call:
;	call countSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)



;	YOUR CODE GOES HERE

global countSort
countSort:


;**********************************************************************************
;sorting 
;paramaters
;rdi    list addr 
;esi    dword[length]
 


;stack variables 
push rbp 
mov rbp, rsp
sub rsp, LIMIT*4 	;allocate dwords for count arr 
sub rsp, 4; LimBytes+4 // value of p  
push rbx
push r12 


			                                ;init everything to 0 
mov rcx, 0 
mov rcx, LIMIT
mov rbx, 0 
;dec rcx                                     ;n-1 for array 

;-----
;init p to 0 
mov dword [rbp -LIMIT*4 -4], 0

;-----
;init count array to zeroes 
mov rbx, 0 
lea rbx, dword[rbp-LIMIT*4]                   ;count address 
mov r12, 0                                     ;index

initZeroes1:
mov dword[rbx + r12*4], 0
inc r12 
cmp r12, LIMIT
jl  initZeroes1



mov rcx, 0 

;dec rcx                                     ;n-1 for array 
;**********************************************************************************
initCount:
                                            ;get index in list 
                                            
mov rax, rdi                                ;list  
mov rbx, 0
lea rbx, dword[rbp-LIMIT*4]                               ;count address 
mov r10, 0
mov r10d, dword[rax+rcx*4]                  ;list[i] (paramater to func) 
                                            
mov r11d, dword[rbx+r10*4]                  ;count[arr[i]] 
inc r11d                                    ;++
mov dword[rbx+r10*4], r11d                  


;loop initCount
inc rcx 
cmp rcx, rsi 
jl initCount 


;**********************************************************************************
                                           
mov rcx, LIMIT
dec rcx 

limitLoop:
lea rax, dword[rbp-LIMIT*4] 
mov rbx, 0 
mov ebx, dword[rax+rcx*4]                   ;count[i] 
mov rax, 0 
cmp rbx, rax 
je noSecondLoop
                                            ;for j=1 to count[i] 
mov r12d, 1 
secondLoop:
mov rax, 0
mov eax, dword [rbp- LIMIT*4 -4]                      ;p 
mov r10, rdi                                ;list  
mov dword[rdi+rax*4], ecx                   ;arr[p] = i ;

                                            ;p++ 

inc eax 
mov dword [rbp- LIMIT*4 -4], eax 


inc r12d
cmp r12d, ebx 
jle secondLoop


noSecondLoop:


dec rcx 
mov r15, 0
cmp rcx, r15 
jge limitLoop




pop r12 
pop rbx 
mov rsp, rbp 
pop rbp 



ret


; --------------------------------------------------------
;  Find statistical information for a list of integers:
;	sum, average, minimum, median, and maximum

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstAvergae() function
;  to get the average.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	call listStats(list, len, sum, ave, min, med, max)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	6) sum, addr - rdx
;	7) ave, addr - rcx
;	3) minimum, addr - r8
;	4) median, addr - r9
;	5) maximum, addr - stack, rbp+16

;  Returns:
;	sum, average, minimum, median, and maximum
;		via pass-by-reference



;	YOUR CODE GOES HERE

global listStats
listStats:
push rbp 
mov rbp, rsp 
push r12 

;copy sum address so we can use rdx 
mov r15, rdx 

;min and max 
mov eax, dword[rdi]
mov r12, qword[rbp+16]
mov dword[r12], eax                     ;max 

mov r12, rsi 
dec r12 
mov eax, dword[rdi+r12*4]
mov dword[r8], eax                      ;min 

;median 
mov rax, rsi 
mov rdx, 0 
mov r12, 2
div r12                                 ;len /2 

cmp rdx, 0                              ;even odd check 
je evenLen 

mov r12d, dword[rdi+rax*4]               ;arr[len/2]
mov dword[r9], r12d                     ;return median 
jmp medDone 
evenLen:
mov r12d, dword[rdi+rax*4]              ;arr[len/2]
mov dword[r9], r12d 
dec rax 
mov r12d, dword[rdi+rax*4]
add dword[r9], r12d 
mov r12d, dword[r9]
shl r12d, 1 
mov dword[r9], r12d                     ;divide bytwo and return 

medDone:

;sum 

mov r12, 0
mov rax, 0 
lstSumLoop:
add eax, dword[rdi+r12*4]               ;sum += list[i] 
inc r12 
cmp r12, rsi 
jl lstSumLoop

mov dword[r15], eax                     ;return sum 

;average 
;rdi and rsi are already set 
call lstAverage

mov dword[rcx], eax 


pop r12
pop rbp 
ret 


; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() function.

; -----
;  HLL Call:
;	ans = lstAverage(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	2) length, value - rsi

;  Returns:
;	average (in eax)



;	YOUR CODE GOES HERE
global lstAverage
lstAverage:

push r12 
push rax 
push rsi
push rdi 

mov r12, 0 
mov rax, 0 


AverageLoop:
add eax, dword[rdi+r12*4]
inc r12 
cmp r12, rsi 
jl AverageLoop

cdq 
idiv esi 

pop rdi 
pop rsi 
pop rax 
pop r12 

ret 



; --------------------------------------------------------
;  Function to calculate the co-variance between two lists.
;  Note, the two data sets must be of equal size.

; -----
;  HLL Call:
;	coVariance(xList, yList, len)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - rdx

;  Returns:
;	covariance (in rax)



;	YOUR CODE GOES HERE
global coVariance
coVariance:

	;alloc space on the stack for temp vars 
	push rbp 
	mov rbp, rsp 
	sub rsp, 4 					;temp 1 
	sub rsp, 4					;temp 2

	;mov  r12, rdi
	mov  r13, rdx

	push rdi 
	push rsi 
	push rdx 

	mov rsi, rdx  
	call lstAverage
	
	pop rdx 
	pop rsi 
	pop rdi 

	lea r15, dword[rbp-4];		;temp1 
	mov dword [r15], eax
	
	push rdi 
	push rsi 
	push rdx 
	
	mov rdi , rsi 
	mov rsi, rdx 
	
	call lstAverage
	
	pop rdx 
	pop rsi 
	pop rdi  
	
	lea r15, dword[rbp-8]
	mov dword[r15], eax 
	
	mov r14, 0
	mov r9, 0
	mov r12, 0
	

	coVarloop: 
	
	mov eax, dword [rdi+r14*4]
	lea r8, dword[rbp-4]
	mov r9d, dword [r8]
	sub rax, r9
	mov r15d, dword[rsi+r14*4]
	lea r8, dword[rbp-8]
	mov r9d, dword [r8]
	sub r15, r9
	imul r15
	add r12, rax

	inc r14
	cmp r14, r13
	jl coVarloop
	
	
	mov rax, r12
	dec r13
	cqo
	idiv r13
	
	mov rsp , rbp 
	pop rbp 

ret



; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.
push rdi 
push rdx 
push rsi
push rax 

	mov	rdx, 0
strCountLoop:
	;cmp	byte [rdi+rdx], LF
	;je	strCountLoopDone
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
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:

pop rax 
pop rsi 
pop rdx 
pop rdi 

	ret

; ******************************************************************
