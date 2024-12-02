include C:\irvine\Irvine32.inc
includelib C:\irvine\Irvine32.lib
includelib C:\irvine\Kernel32.lib
includelib C:\irvine\User32.lib

.data
	BUFFER_SIZE = 5000
	buffer BYTE BUFFER_SIZE DUP(?)
	byteCount DWORD ?
	fileName BYTE BUFFER_SIZE DUP (?)
	fileHandle DWORD ?
	fileContent BYTE BUFFER_SIZE DUP (?)

	nScores DWORD 0					;user input for number of scores
	kStudents DWORD 0				;user unput for number of students
	mCourses DWORD 0				;user input for number of courses
	StudentName BYTE 50 DUP (?)
	StudentGrade DWORD 0
	SGradeTotal DWORD 0
	StudentCounter DWORD 0
	GradeCounter DWORD 0
	temp DWORD 0

	startprompt BYTE "Enter your gradebook text file name. Example: GradeBook.txt", 0
	message1 BYTE "How many scores are there?", 0
	message2 BYTE "How many students are there?", 0
	message3 BYTE "How many courses are there?", 0
	GradeF BYTE "		F", 0
	GradeD BYTE "		D", 0
	GradeC BYTE "		C", 0
	GradeB BYTE "		B", 0
	GradeA BYTE "		A", 0

	Error BYTE "File not found.", 0
	Error1 BYTE "Your input was not a positive number.", 0

;------------------------------------------------------------------

.code
main proc
;this entire first block is to just open a file, read it, and then close it again
;if file cannot be found, program shows error message and quits instantly
	mov EDX, OFFSET startprompt
	call WriteString
	call crlf

	mov EDX, OFFSET filename
	mov ECX, SIZEOF filename
	call ReadString

	mov EDX, OFFSET filename
	call OpenInputFile
	mov fileHandle, EAX

	cmp EAX, INVALID_HANDLE_VALUE
    je FileError

	mov EDX, OFFSET fileContent
	mov ECX, SIZEOF fileContent
	call ReadFromFile

	mov EAX, fileHandle
	call CloseFile

;------------------------------------------------------------------

M1:		;asks user for number of scores input. quits if input is invalid
	mov EDX, OFFSET message1
	call WriteString
	call crlf

	mov EDX, OFFSET buffer
	mov ECX, SIZEOF buffer
	call ReadString
	call ParseDecimal32
	mov nScores, EAX

	mov ESI, OFFSET buffer
	XOR EDX, EDX

L1:
	mov AL, [ESI + EDX]
	inc EDX
	cmp AL, 0
	je M2
	cmp AL, 30h
	jl InputError
	cmp AL, 39h
	jg InputError
	jmp L1

;------------------------------------------------------------------

M2:		;asks user for number of students input. quits if input is invalid
	mov EDX, OFFSET message2
	call WriteString
	call crlf

	mov EDX, OFFSET buffer
	mov ECX, SIZEOF buffer
	call ReadString
	call ParseDecimal32
	mov kStudents, EAX

	mov ESI, OFFSET buffer
	XOR EDX, EDX

L2:
	mov AL, [ESI + EDX]
	inc EDX
	cmp AL, 0
	je M3
	cmp AL, 30h
	jl InputError
	cmp AL, 39h
	jg InputError
	jmp L2

;------------------------------------------------------------------

M3:		;asks user for number of courses input. quits if input is invalid
	mov EDX, OFFSET message3
	call WriteString
	call crlf

	mov EDX, OFFSET buffer
	mov ECX, SIZEOF buffer
	call ReadString
	call ParseDecimal32
	mov mCourses, EAX

	mov ESI, OFFSET buffer
	XOR EDX, EDX

L3:
	mov AL, [ESI + EDX]
	inc EDX
	cmp AL, 0
	je fileinput
	cmp AL, 30h
	jl InputError
	cmp AL, 39h
	jg InputError
	jmp L3

;------------------------------------------------------------------

fileinput:
	mov ESI, OFFSET fileContent
	XOR EAX, EAX
	XOR EBX, EBX
	XOR ECX, ECX
	XOR EDX, EDX

L4:
	mov AL, [ESI+ECX]		;we go char by char to determine if its a letter or number, and sort it accordingly
	cmp AL, 0
	je StudentDelimiter		;if char is a null input (the end of the string) or a new line, we go to StudentDelimiter
	cmp AL, 0Ah
	je StudentDelimiter
	cmp AL, 0Ch
	je StudentDelimiter
	cmp AL, 0Dh
	je StudentDelimiter

	cmp AL, 2Ch				;using commas as delimiters, we can tell when each number ends, allowing us to turn input from string to int
	je GradeDelimiter

	cmp AL, 39h				;if char>'9' it is letter, else it is number
	jg sName
	jng sGrade

sName:
	mov StudentName, AL			;takes each char if it is a letter and outputs them one by one to show name of student
	mov EDX, OFFSET StudentName
	call WriteString
	call Skip

sGrade:
	mov temp, EAX				;takes char and turns it to int, then either stores it, or multiplies what is already stored by 10 and adds the new int to that
	mov EDX, OFFSET temp
	call ParseInteger32
	cmp StudentGrade, 0
	je CND1
	jg CND2
	call Skip

CND1:
	add EAX, StudentGrade
	mov StudentGrade, EAX		;store int in StudentGrade
	call Skip

CND2:
	mov EDX, StudentGrade
	mov EBX, EAX
	mov EAX, 10
	mul EDX						;mult stored num by 10 and adds new num to it, then re-stores
	add EAX, EBX
	mov StudentGrade, EAX
	call Skip

;------------------------------------------------------------------

FileError:
	mov EDX, OFFSET Error
	call WriteString
	jmp Quit

;------------------------------------------------------------------

InputError:
	mov EDX, OFFSET Error1
	call WriteString
	jmp Quit

;------------------------------------------------------------------

Skip:					;if end of the inputted file, jumps to quit, else increases counter at ECX and reloops L4
	mov EDX, StudentCounter
	cmp EDX, kStudents
	je Quit
	inc ECX
	jmp L4

;------------------------------------------------------------------

GradeDelimiter:				;adds grade to make a large sum of one students' grades
	inc GradeCounter
	mov EAX, StudentGrade
	add EAX, SGradeTotal
	mov SGradeTotal, EAX
	XOR EAX, EAX
	mov StudentGrade, EAX
	call Skip

;------------------------------------------------------------------

StudentDelimiter:			;divides one student's total grade by amount of grades there are depending on what user inputted
	inc StudentCounter
	inc ECX
	mov EAX, StudentGrade
	add EAX, SGradeTotal
	mov SGradeTotal, EAX
	XOR EAX, EAX
	mov StudentGrade, EAX
	mov EAX, SGradeTotal
	mov EBX, nScores
	XOR EDX, EDX

	div EBX
	
	mov StudentGrade, 0
	mov SGradeTotal, 0
	
	cmp EAX, 3Bh			;depending on what the average is, student gets a letter grade from A-F
	jle GF
	cmp EAX, 45h
	jle GD
	cmp EAX, 4Fh
	jle GC
	cmp EAX, 59h
	jle GB
	cmp EAX, 64h
	jle GA

GF:
	mov EDX, OFFSET GradeF
	call WriteString
	call crlf
	call Skip

GD:
	mov EDX, OFFSET GradeD
	call WriteString
	call crlf
	call Skip

GC:
	mov EDX, OFFSET GradeC
	call WriteString
	call crlf
	call Skip

GB:
	mov EDX, OFFSET GradeB
	call WriteString
	call crlf
	call Skip

GA:
	mov EDX, OFFSET GradeA
	call WriteString
	call crlf
	call Skip

;------------------------------------------------------------------

Quit:
	call crlf

	invoke ExitProcess,0
main endp
end main	