.MODEL MEDIUM
.STACK 100H
.DATA

W0 DB "WELLCOME TO ENCS 311 ASSEMBLY LAB PROJECT ",10,13,"$"
W1 DB 10," ENTER THE PASSWORD TO CONTINUE $"
W2 DB 10,13," PASSWORD CORRECT , PRESS ANY KEY TO CONTINUE",10,13,"$"
W3 DB 10,13," PASSWORD INCORRECT , PRESS ANY KEY TO TRY AGAIN ",10,13,"$" 
W4 DB "ENTER A VALID STATEMENT THAT CONTAIN LETTERS AND SPACES ONLY",10,13,"$"
NL DB 10,13,"$"  

FILE DB "C:\Tasm\PASSWORD.TXT",0   ;FILE DIRECTORY IN THE C:
HANDLE DW (0)                      ;FILE HANDLER IS AN INTEGER VALUE WHICH IS USED TO ADRESS AN OPEN FILE  
PASSWORD DB 20 DUP("$")            ;PASSWORD THAT HAVE BEEN READ FROM THE FILE 
PASS_LENGTH DB (0)                 ;THE LENGTH OF THE PASSWORD 
USER_PASS DB 30 DUP(" ")           ;THE PASSWORD ENTERED BY THE USER 

STATEMENT DB 100                   ;MAXIMUM LENGTH OF THE STRING   
          DB 0                     ;REAL LENGTH OF THE READED STRING
          DB 100 dup ('$')         ;BUFFER TO HOLD THE 
		  
ER DB "INVALID STATEMENT , ONLY YOU CAN USE ALPHAPITIC LETTERS CAPITAL OR SMALL",10,13,"$"
NER DB "THE STATEMENT ENTERED IS VALED , PRESS ANY KEY TO CONTINUE...",10,13,"$"

CHOICE DB (0)  
QUITMESS DB 10,10,10,10,"HAVE A NICE DAY",10,13,"$"

M0 DB "<*** MAIN MENU ***>",10,13,10,"$"
M1 DB " Press S To Convert The Statement into Small Letters only",10,13,"$"
M2 DB " Press C To Convert The Statement into Capital letters only",10,13,"$"
M3 DB " Press O To Convert The First Letter in each word into capital Letter",10,13,"$"
M4 DB " Press R To Reverse The StateMent",10,13,"$"
M5 DB " Press G To Search For Specefic String in the Statement",10,13,"$"
M9 DB 10,13," Press Q To Quit Program ",10,13,"$"
M10 DB 10,13," Press B To Back To Main Menu",10,13,"$" 
M11 DB 10,13,"  ENTER YOUR CHOICE $" 

N0 DB "The Statement in Small letter Case :",10,13,"$"
N1 DB "The Statement in Capital letter case :",10,13,"$"
N2 DB "The First word Capitalized in the Statement",10,13,"$"
N3 DB "The reversed Statement is",10,13,"$"
N4 DB "Enter Any Word To Search For In The Statement:",10,13,"$"
N5 DB "The Word Exist In The Statement",10,13,"$"
N6 DB "The Word Does Not Exist In The Statement",10,13,"$"

BUFF DB 10                 ;LENGTH OF BUFFER USED TO READ THE WORD 
     DB 0                  ;ACTUAL LENGTH OF THE WORD 
	 DB 10 DUP ("$")       ;THE BUFFER THAT HOLD THE CHARACTERS 
	 

STATE DB 100 DUP("$")
TEMP DB 20 DUP("$")
TEMP2 DB 20 DUP ("$")  


;_______________________Start Of Main___________________________________;
.CODE
MOV AX,@DATA            ;DEFINE THE DATA SEGMENT ADDRESS
MOV DS,AX               

CALL OPEN_FILE          ;PROCEDURE THAT OPEN FILE DEFINED IN THE FILE VARIABLE DIRECTORY
CALL COUNT              ;CALCULATE THE LENGTH OF THE PASSWORD (USED FOR COMPARISION)

INPUT:                  ; LABEL TO RETURN IF PASSWORD IN CORRECT

 CALL WELLCOME_MENU      ;PRINT WELLCOME MENUE START OF THE PROJECT               
 CALL INPUT_PASSWORD       ;FUNCTION THAT ENABLE THE USER TO INPUT A PASSWORD FIELD 
         
 MOV CL,PASS_LENGTH        ;WE WILL COMPARE THE PASSWROD CHARACTER BY CHARACTER UNTIL THE LENGTH END 
 
 ;DI USED FOR PASSWORD
 ;SI USED FOR USER PASSWORD
 
 LTEST: 
       MOV BL,USER_PASS[SI]
       CMP PASSWORD[DI],BL
       JNZ EPRINT                           ;IF NOT EQUAL PRINT PASSWORD ERROR , IT COULD TERMINATE WHEN A CHARACTER DIFFER
       
       INC SI
       INC DI
       LOOP LTEST                            
	   
       JMP PRESS                             ;IF THE CHARACTER ARE THE SAME UNTIL WE FINISHED COMPAIR ALL CHARACTERS THEN ENTER THE PROGRAM
       
     EPRINT: MOV AH,09H                      ;PRINT ERROR MESSAGE
             MOV DX,OFFSET W3
             INT 21H  
             
             MOV AH,08H                      ;WAIT STATE UNTIL WE PRESS ENTER TO RE ENTER THE PASSWORD
             INT 21H
             JMP INPUT
     PRESS:                        
           MOV AH,09H
           MOV DX,OFFSET W2
           INT 21H
           
           MOV AH,08H
           INT 21H 
		   
 ;UNTIL THIS STAGE WE READ A PASSWORD FROM A FILE , THEN WE ASKED THE USER TO ENTER AN PASSWORD THEN CHECK IF CORRECT OR NOT     
 ;NEXT STAGE IS TO READ A STRING ENTERED BY USER AND TEST IF IT IS CORRECT OR NOT 
 
 WRONGSTATE:            ; IF THE STATEMENT CONTAIN ILLEGAL CHARACTERS ("SPECIAL CHARACTER") WE READ THE STRING AGAIN 
 CALL CLRSCREEN 
 MOV DL,3
 CALL CURSER
 MOV DX,OFFSET W4
 CALL PRINT_STRING
 CALL NEWLINE
 
 CALL SCAN_STATEMENT    ;SCAN THE STATEMENT TO MAKE OPERATIONS ON THE STRING SCANNED 
 CALL NEWLINE
 
 CALL VALIDSTATE       ;CHECK IF THE STATEMENT CONTAIL ILLEGAL CHARACTER TO SCAN IT AGAIN 
 ;--------------------------------------------------------------------------------
 ;SHOW THE MENU OF OPTION ( OPRATION ON THE ENTERED STRING )
 BACK:
 
 CALL MENU   
 
 MOV AH,01H
 INT 21H
 MOV CHOICE ,AL
 
 CALL CASE_MENU

QUIT:  
      
CALL CLRSCREEN  

MOV DL,30
CALL CURSER  

MOV DX,OFFSET QUITMESS
CALL PRINT_STRING
 
MOV AH,4CH  ; TERMINATE THE PROGRAM
INT 21H

;_________________________Menu Interface ____________________;
;PRINT THE MAIN MENU MESSAGES   
 ;PROCEDURE THAT TEST IF THE STATEMENT HAVE UN LEGAL CHARACTER 
 VALIDSTATE PROC NEAR 
    
    CALL CLR_REGISTER 
    MOV DI,2
    MOV CL,STATEMENT+1
    
    LTCV:CMP STATEMENT[DI],'A'
         JGE NEXTTCV 
         CMP STATEMENT[DI],' '
         JE NEXTTCV   ; IF SPACE CONTINUE
         
         ;IF BELOW A THEN IT UNLEGAL CHARACTER SO WE PRINT ERROR MESSAGE AND RETURN TO INPUT STRING  
      ERRR:		 
         CALL NEWLINE         
         MOV DX,OFFSET ER
         CALL PRINT_STRING 

         MOV AH,08H
         INT 21H
         
         JMP WRONGSTATE 
		
        NEXTTCV:
		CMP STATEMENT[DI],'z'
		JGE ERRR
		CMP STATEMENT[DI],'a'
		JNG NCT
		
		JMP NEXTCT
		NCT:
		CMP STATEMENT[DI],'Z'
		JGE ERRR
		NEXTCT:

        INC DI
        LOOP LTCV    ;IF THE FIRST CHARACTER PASSED THE TEST THEN IT IS LEGAL 
 	 
	 CALL NEWLINE
     LEA DX,NER
	 CALL PRINT_STRING
	 NOP
     MOV AH,08H   
     INT 21H
    RET
ENDP
MENU PROC NEAR  
    
    CALL CLRSCREEN
            
    MOV DL,25
    CALL CURSER
    MOV DX,OFFSET M0
    CALL PRINT_STRING 
    
    MOV DX,OFFSET M1
    CALL PRINT_STRING 
    
    MOV DX,OFFSET M2
    CALL PRINT_STRING
    
    MOV DX,OFFSET M3
    CALL PRINT_STRING

    MOV DX,OFFSET M4
    CALL PRINT_STRING

    MOV DX,OFFSET M5
    CALL PRINT_STRING
    
    MOV DX,OFFSET M11
    CALL PRINT_STRING
 
  RET
  ENDP

CASE_MENU  PROC NEAR 
    
    CMP CHOICE,"S"
    JZ  SMALLL
    CMP CHOICE,"C"
    JZ  CAPITAL
    CMP CHOICE,"O"
    JZ  FCAPITAL 
    CMP CHOICE,"R" 
    JZ REVERSE
	CMP CHOICE,"G"
    JZ SEARCH
    CMP CHOICE,"B"
    JZ BACK
    CMP CHOICE,"Q"
    JZ QUIT
 
      
    SMALLL:
            CALL SMALLCONVERT
    CAPITAL:
            CALL CAPITALCONVERT
    FCAPITAL:
            CALL FIRSTCAPITAL   
    REVERSE: 
            CALL REVERSE_STATE 
    SEARCH:
	        CALL SEARCHH
  
    RET
    ENDP
;_________________________FUNCTIONS ____________________;
; SEARCH FOR A SPICIFIC STRING IN THE STATEMENT
 SEARCHH PROC NEAR
     
	 CALL CLR_REGISTER
	 CALL CLRSCREEN
	 
     MOV DL,5
     CALL CURSER
	 CALL NEWLINE
	 
     LEA DX,N4
     CALL PRINT_STRING
	 CALL NEWLINE
	 
	 MOV AH,0AH                    ;SCAN STRING THAT WE WANT TO SEARCH FOR IN THE STATEMENT
	 MOV DX,OFFSET BUFF
	 INT 21H
	 
	 CALL NEWLINE
	 
	 MOV AX,@DATA
     MOV DS,AX
     MOV ES,AX

     MOV CL,STATEMENT+1
	 MOV CH,0
     MOV SI,OFFSET STATEMENT+2
     MOV DI,OFFSET BUFF+2

LL:
  PUSH CX
  MOV CL,BUFF+1
  CLD
  MOV DI,OFFSET BUFF+2
  MOV CH,0
  REPE CMPSB
  JZ EQUAL
  POP CX
  LOOP LL
  
  LEA DX,N6
  CALL PRINT_STRING
  JMP E
 
  EQUAL:
     LEA DX,N5
	 CALL PRINT_STRING
E:
 
 CALL OPTIONN
 RET
 ENDP
 
 CAPITALCONVERT PROC NEAR 
    ;CONVERT THE STRING INTO CAPITAL LETTERS ONLY
    ;FILTER_STATE IS THE ORIGINAL STRING
    ;MODIFIED STRING WILL BE IN STATEMENT
    CALL MAKEDOLLAR    ; RESET STATEMENT STRING 
    CALL CLR_REGISTER
    
    LEA SI,STATE
    LEA DI,STATEMENT+2
    MOV CL,STATEMENT+1  
    
    LCAPITAL: 
           MOV BL,[DI]
           CMP BL," "
           JZ MOVSPACEC
           CMP BL ,'a'
           JGE CONVERTSMALL 
           MOV [SI],BL
           INC SI
           INC DI
           JMP NEXTLOOPC 
           
       MOVSPACEC:MOV [SI],BL
                INC SI
                INC DI
                JMP NEXTLOOPC
       CONVERTSMALL:SUB BL,32D
                      MOV [SI],BL
                      INC SI
                      INC DI
                       
                       
       NEXTLOOPC:
       LOOP LCAPITAL   
            
       CALL CLRSCREEN
       MOV DL,5
       CALL CURSER
       
       MOV DX,OFFSET N1
       CALL PRINT_STRING
       
       CALL NEWLINE
       
       MOV DX,OFFSET STATE
       CALL PRINT_STRING 
       
       CALL NEWLINE 
       CALL NEWLINE
       
       CALL OPTIONN 
       
       RET
       ENDP
    

 SMALLCONVERT PROC NEAR 
    ;CONVERT THE STRING INTO SMALL LETTERS ONLY
    ;FILTER_STATE IS THE ORIGINAL STRING 
    ;MODIFIED STRING WILL BE IN STATEMENT 
    CALL MAKEDOLLAR
    
    LEA SI,STATE
    LEA DI,STATEMENT+2
    MOV CL,STATEMENT+1
    LSMALL: 
           MOV BL,[DI]
           CMP BL," "
           JZ MOVSPACE
           CMP BL ,'a'
           JNGE CONVERTCAPITAL 
           MOV [SI],BL
           INC SI
           INC DI
           JMP NEXTLOOP 
           
       MOVSPACE:MOV [SI],BL
                INC SI
                INC DI
                JMP NEXTLOOP
       CONVERTCAPITAL:ADD BL,32D
                      MOV [SI],BL
                      INC SI
                      INC DI
                       
                       
       NEXTLOOP:
       LOOP LSMALL 
       
             
       CALL CLRSCREEN
       MOV DL,5
       CALL CURSER
       
       MOV DX,OFFSET N0
       CALL PRINT_STRING
       
       CALL NEWLINE
              
       MOV DX,OFFSET STATE
       CALL PRINT_STRING 
       
       CALL NEWLINE 
       CALL NEWLINE
       
       CALL OPTIONN
       
    RET
ENDP 

REVERSE_STATE PROC NEAR
    
    ;REVERSE THE STATEMENT WORD EX- BASSAM JABER --> JABER BASSAM        
    CALL MAKEDOLLAR    ; RESET STATEMENT STRING 
    CALL CLR_REGISTER
    
    MOV SI,0
    MOV DI,2
    MOV CL,STATEMENT+1     
    
    ADD SI,CX
    DEC SI
    
    LREVERSE: MOV BL,STATEMENT[DI]
              MOV STATE[SI],BL 
              INC DI
              DEC SI
              LOOP LREVERSE
              
       CALL REVERSE_WORD         
              
            
       CALL CLRSCREEN
       MOV DL,5
       CALL CURSER
      
       MOV DX,OFFSET N3
       CALL PRINT_STRING
       
       CALL NEWLINE
    
       MOV DX,OFFSET STATE
       CALL PRINT_STRING 
       
       CALL NEWLINE 
       CALL NEWLINE
       
       CALL OPTIONN
    
    RET
ENDP   

REVERSE_WORD PROC NEAR 
      CALL CLR_REGISTER
      MOV CL,STATEMENT+1 
      INC CL
      
      ;DI INDEX OF THE STATEMENT
      ;SI INDEX OF EACH WORD 
      MOV SI,CX
      MOV STATE[SI-1]," "    ; MOVE TO THE LAST POSITION SPACE ^_^ 
      XOR SI,SI
      
      LRWORD: MOV BL,STATE[DI]
              CMP BL," "
              JZ POPWORD                 ; IF WE REACH SPACE POP CHARACTER IN REVERSE MODE
              PUSH BX                    ; ELSE PUSH CHARACTER TO THE STACK
              INC DI                     ;INDEX INCREMENT
              INC SI                     ; NUMBER OF CHARACTER IN WORD
              JMP NEXTWORD
              
              POPWORD: MOV DX,CX       ; SAVE THE COUNTER VALUE IN DX BECAUSE WE NEED C TO LOOP 
                       MOV CX,SI       ; SI INDICATES THE NUMBER OF CHARACTER THAT WE WILL POP AND AFTER WE RESET IT TO 0 
                       XOR SI,SI       ; SOURCE INDEX REGISTER WILL BE USED AS INDEX TO CHANGE CHARACTER 
                       MOV SI,AX       ; AX WILL HOLD THE START OF THE WORD TO CHANGE
                       
                       LOPOP: 
                             POP BX                       ; PUSH THA CHARACTER TO MOV OT 
                             MOV STATE[SI],BL
                             INC SI
                             LOOP LOPOP  
                             
                       ;WHEN FINISH REVERSEING THE CHARACTER THREE THNGS MUST BE DONE
                       ; SAVING THE NEW START VALUE IN AX WHICH IS DI+1
                       ;RESET SI TO COUNT AGAIN THE  NUMBER OF CHARACTER ON WORD
                       ;RETURN THE VALUE OF CX WHICH WAS SAVED IN DX
                       
                       MOV AX,DI
                       INC AX
                       
                       XOR SI,SI   
                       MOV CX,DX 
                       INC DI
                                            
             NEXTWORD:
       LOOP LRWORD
                               
    RET
ENDP



 FIRSTCAPITAL PROC NEAR 
    ;CONVERT FIRST LETTER OF EACH WORD TO CAPITAL
    
    CALL MAKEDOLLAR    ; RESET STATEMENT STRING 
    CALL CLR_REGISTER
    
    MOV SI,0
    MOV DI,2
    MOV CL,STATEMENT+1 
    
    
    MOV BL,STATEMENT[DI]
    CMP BL,'a'             ;FIRST CHARACTER IN THE STATEMENT MUST BE CAPITAL
    JGE TOCAPITAL 
    MOV STATE[SI],BL
    INC SI
    INC DI  
    JMP NEXTCHAR  
    
    LFCES: 
           MOV BL,STATEMENT[DI]                   ;MOV THE CHARACTER TO BX TO TEST IT
           CMP STATEMENT[DI-1]," "                ;IF BEFORE IT IS A SPACE THEN GO TEST IF CAPITAL OR SMALL TO MAKE IT CAPITAL
           JZ TESTC                      ;IF FIRST CHARACTER MAKE THEM CAPITAL
           JMP TESTS                     ; ELSE MAKE IT SMALL
        
           
           TESTC: CMP BL,'a'             ;TEST TO MAKE CAPITAL
                  JGE TOCAPITAL
                  MOV STATE[SI],BL
                  INC SI
                  INC DI
                  JMP NEXTCHAR 
                  
           TESTS: CMP BL,'a'
                  JNGE TOSMALL                    ;TEST TO MAKE SMALL  
                  MOV STATE[SI],BL
                  INC SI
                  INC DI
                  JMP NEXTCHAR
          
      
          
    TOSMALL: ADD BL,32D               ;MAKE CHARACTER SMALL
             MOV STATE[SI],BL 
             INC SI
             INC DI
             JMP NEXTCHAR 
             
      TOCAPITAL:SUB BL,32D            ;MAKE CHARACTER CAPITAL
              MOV STATE[SI],BL 
              INC SI
              INC DI
              JMP NEXTCHAR 
      NEXTCHAR: 
              
   LOOP LFCES 
   
   ;AFTER FINISH SPACE IS CONVERTED TO @ SO WE MUST REPLACE IT
   ;EASIER FROM MAKE IF STATEMENT IN THE MIDDLE OF THE CODE  
   
   
   CALL REPLACESPACE 
   
          
       CALL CLRSCREEN
       MOV DL,5
       CALL CURSER
       
       MOV DX,OFFSET N2
       CALL PRINT_STRING
       
       CALL NEWLINE

       MOV DX,OFFSET STATE
       CALL PRINT_STRING 
       
       CALL NEWLINE 
       CALL NEWLINE
       
       CALL OPTIONN
    
    RET
 ENDP   
 
 REPLACESPACE PROC NEAR
    
    CALL CLR_REGISTER  
    
    MOV SI,0
    MOV CL,STATEMENT+1 
    LRSA:
         CMP STATE[SI],"@"
         JZ REPL
         INC SI
         JMP NEXTT
         REPL:
         MOV STATE[SI]," "
         INC SI
         
         NEXTT:
         LOOP LRSA 
    
    RET
 ENDP

OPTIONN PROC NEAR  

    MOV DX,OFFSET M10
    CALL PRINT_STRING
    
    MOV DX,OFFSET M9
    CALL PRINT_STRING 
    
     MOV AH,08H
     INT 21H
     MOV CHOICE ,AL 
          
     CALL CASE_MENU 

    RET
ENDP

;RESET BUFFER
MAKEDOLLAR PROC NEAR
    MOV CX,99
    MOV SI,0
    LDO:
        MOV STATE[SI],"$"
        INC SI
        LOOP LDO
        
    RET
    ENDP	
	

;_________________________STATEMENT OPERATIONS____________________;

;SCAN STATMENT 
SCAN_STATEMENT PROC NEAR 
  
    MOV AH,0AH
    LEA DX,STATEMENT
    INT 21H 
	
    RET
ENDP

;PRINT ANY STATEMENT ADDRESS IN DX
PRINT_STRING PROC NEAR
    MOV AH,09H
	INT 21H
   RET
 ENDP


;_______________FILE PROCEDURES__________________;
OPEN_FILE PROC NEAR 
    
   MOV AH,3DH             ; SUBROUTINE TO OPEN FILE
   MOV CL,00H             ;BIT FIELD USED FOR READ ACCESS ONLY 40 FOR READ/WRITE
   MOV DX,OFFSET FILE     ; POINTS TO THE FILE
   INT 21H     
  
   MOV HANDLE,AX           ;STORE THE FILE HANDLER FROM AX 
   
   MOV BX,AX               ; MOVE HANDLE TO BX
   MOV AX,3F00H            ; READ FILE SUBROUTINE
   MOV CX,20               ; NUMBER OF BYTES TO READ
   MOV DX, OFFSET PASSWORD ; ADDRESS OF THE BUFFER
   INT 21H
    
   
   MOV BX,AX              ;MOV THE FILE HANDLE TO BX
   MOV AX,3E00H           ; SUBROUTINE THAT CLOSE THE FILE
   INT 21H

    RET 
ENDP 

; COUNT THE NUMBER OF CHARACTER IN THE PASSWORD
COUNT PROC NEAR
    CALL CLR_REGISTER 
    MOV  DI,0  
    
    ;AL WILL USED TO COUNT CHARACTER
    ;DI USED AS INDEX FOR THE PASSWORD
    L: CMP PASSWORD[DI],"$"
       JZ FINISH_COUNT 
       INC DI
       INC AL
       JMP L
     FINISH_COUNT:
     
     LEA SI,PASS_LENGTH
     MOV [SI],AL
      
    RET
ENDP


INPUT_PASSWORD PROC NEAR 
    
   CALL CLR_REGISTER  
   
   MOV CL,PASS_LENGTH
  
   LP:
      MOV AH,08H            ; SCAN A CHARACTER WITHOUT ECHO 
      INT 21H
      
      MOV USER_PASS[BX],AL    ;SAVE THE SCANNED CHARACTER INTO USER PASS ENTERED 
      CALL PRINT_STAR       ; PRINT STAR WHEN SCANNING PASSWORD
      
      INC BX
      LOOP LP   
      
      MOV USER_PASS[BX+1],"$"   
    
    RET
ENDP 

;______________INTERFACE PROCEDURES_______________;
WELLCOME_MENU PROC NEAR
    
    CALL CLRSCREEN 
    MOV DL,18
    CALL CURSER
    MOV DX,OFFSET W0
    CALL PRINT_STRING
    
    MOV DX,OFFSET W1
    CALL PRINT_STRING   
    
    RET
ENDP
                       
CURSER PROC NEAR        ;MOV THE CURSER TO SPECIFIC PLACE ON SCREEN
                                                           
 ;USER MUST DETERMINE THE COLOMN OF THE CURSER ON DL                                                                  
 MOV AH,02H              ;CURSER SUBROUTINE           
 MOV BH,00               ;PAGE NUMBER
 MOV DH,02               ;ROW NUMBER
 INT 10H      
  
RET 
ENDP    

;PRINT STAR "USED FOR PASSWORD "
PRINT_STAR PROC NEAR
    MOV AH,02H
    MOV DL,'*'
    INT 21H
    RET
    ENDP

;PRINT NEW LINE
NEWLINE PROC NEAR 
    MOV AH,09H
    MOV DX,OFFSET NL
    INT 21H
    RET
ENDP

;CLEAR THE SCREEN 
CLRSCREEN PROC NEAR  
    
  MOV AX,0600H             ;SUBROUTINE TO CLEAR SCREEN
  MOV BH,3FH              ;LETTERS AND BACK GROUND COLOR
  MOV CX,0000H
  MOV DX,184FH
  INT 10H 
    
    RET
    ENDP
	
; CLEAR ALL THE SYSTEM REGISTERS
CLR_REGISTER PROC NEAR     
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
    XOR DI,DI
    XOR SI,SI
  RET
  ENDP

;NOT USED YET
PUSHALL PROC NEAR      ;PUSH ALL REGISTER TO STACK 
    POP BP

  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI 
  PUSH BP
  
  RET  
ENDP
        

POPALL PROC NEAR       ; POP ALL REGISTER VALUE IN REVERSE 
    POP BP
    
    POP SI
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX 
	
    PUSH BP
  RET
ENDP


END