include iostream.inc  
.model small     
 EXTRN run:proc
.data   
 filename db "code.txt",0
 handle dw ?      
 b_size EQU 512
 buff db b_size dup('$')    
 ;////////////////////////////////  
 terminator equ ';'  
 equalsign equ '='
 commasign equ ','    
 qoute equ '"'
 instructions db '*','|','++','<=','$'
 functions db 'printf$'
 
 variables db 100 dup('$')  ;<-----variable container 
 varCnt db 0             
 errorCnt db 0
 ;////////////////////////////////
 ;prompts invalid or valid codes   
 pLine db 10,13,'Error in Line No:$' 
 pIncomplete db 10,13,'Incomplete instruction set$'
 pNoVariable db 10,13,'Variable not initialized or incorrect spelling$'
 pInvalidSyntax db 10,13,'Invalid syntax$'
 pValidVar db 10,13,'Invalid Variable name$'
 pInvalidFunc db 10,13,'Invalid function call$' 
 pLfcr db 10,13,'$'
    
 ;/////////////////////////////////////////////
 ;line handler           
 ;pointer for character of buff   left to right
 ;resets every newline  
 buffloc dw 0
 bufforiginloc dw 0  
 buffdistance dw 0  
 ;variable memory location
 varloc dw 0
 char db 0 
 ;line location for error handling and locating lines           
 line db 0  
 ;errorCnt db 0
 ;//////////////////////////////////////////////
 ;//////////flags
 isExpression db 'f'
 isFunction db 'f' 
 isValidVar db 't' 
 isDeclaration db 'f' 
 isIncomplete db 'f' 
 isNoVariable db 'f' 
 isEOF db 'f'   
 isInvalidSyntax db 'f'  
 isNumber db 'f'    
 isInvalidFunction db 'f'
 ;//////////////////////////////////////////////
 coloffset db 3
.code   
main proc
 mov ax,@data
 mov ds,ax  
 mov es,ax
 mov ss,ax   
 
 mov ax,0
 mov al,2  
 mov cx,offset variables
 mov varloc,cx
 lea dx,filename
 mov ah,3dh
 int 21h
 jc err
 mov handle,ax
 jmp k
 k:   
 mov bx,handle
 mov cx,b_size      
 lea dx,buff
 
 mov ah,3fh 
 int 21h   
 
 mov al,03h          ;open video display
 mov ah,0
 int 10h 
 
 ;call printBuff
 z: 
 call check ;interrupt to check syntax of the line       
 cmp isEOF,'t'
 je close
 call nextline;call nexline ;interrupt that moves to the nextline of codes 
 ;cmp isEndOfFile,1
 jne z
 
 ;print line+3,1,success       ;col,row    
 ;cursor 1,line+1
 close: 
 cmp errorCnt,0
 je anim
 err:
 mov ah,4ch
 int 21h
 anim:
    call run 
main endp        

printBuff proc
  
 lea si,buff
 print_loop:
 cmp byte ptr[si],'$'
 je disp
 inc si
 inc char
 jmp print_loop
 disp: 
 
 displaybuff 1,3,buff ;col,row,buff
 mov char,0
 ret
printBuff endp
nextline proc
 inc si  
 inc si ;goes to newline
 mov bufforiginloc,si
 mov buffloc,si
 inc line
 ret
nextline endp
check proc
 cmp bufforiginloc,0
 jg expression_
 cmp buffloc,0
 jg expression_
 
 
 
    
 expression:  
 lea si,buff ;checks forward for visible equal sign 
 lea di,buff 
 jmp expression_loop
 expression_:
 mov si,bufforiginloc
 mov di,buffloc
 expression_loop:   
    cmp byte ptr [di],'$'
    je endx
    cmp byte ptr [di],13
    je nexx
    cmp byte ptr [di],commasign
    je endcheck
    cmp byte ptr [di],equalsign 
    je checkvarlist
    cmp byte ptr [di],qoute
    je funxx
    je varcheck
    inc di
    jmp expression_loop        
    endx:
    jmp endapp
    nexx:
    jmp nextl
    funxx:
    jmp function
    
 checkvarlist: 
    mov cx,di
    sub cx,si 
    mov buffdistance,cx
    mov bufforiginloc,si
    mov buffloc,di
    lea si,variables 
    checkvarlist_loop: 
        mov di,bufforiginloc
        mov cx,buffdistance
        rep cmpsb
        cmp cx,0
        je endcheck  
        cmp byte ptr [si],'$'
        je varcheck
        jmp checkvarlist_loop
   
        
        
    
    
    
    
 varcheck:
    mov si,bufforiginloc
    varcheck_loop:
    lodsb
    cmp al,'A'
    jl special 
    cmp al,'Z'
    jg small
    jmp validVar  
    special:
        cmp al,'?'
        je validVar 
        jmp invalidVar
    small:
        cmp al,'a'
        jb underscore
        cmp al,'z'
        ja invalidVar
        jmp validVar
    underscore:
        cmp al,'_'
        je validVar  
        jmp invalidVar
    validVar:
        mov isValidVar,'t'
        call varload 
        jmp endcheck
    invalidVar:
        mov isValidVar,'f'
        call error
 endcheck: 
 clc 
 mov isNumber,'f'
 mov buffdistance,0
 inc buffloc
 mov si,buffloc
 mov bufforiginloc,si
 instruction:
    lodsb   
    cmp al,terminator
    je x    
    cmp al,39h
    jge y   
    cmp buffdistance,0
    jne d
    
    mov isNumber,'t' 
    d:
    jmp y
    x:
      cmp buffdistance,0
      je nexy 
      cmp isNumber,'t'
      je nexy      
      dec si 
      mov isDeclaration, 't'
      jmp instruction_end  
      nexy:
      jmp nextl
    y:  
    cmp al,'"'
    je instruction_end
    cmp al,instructions ;'*'
    je instruction_end    
    cmp al,instructions[1];'|' 
    je instruction_end
    cmp al,instructions[2];'+'
    je secondplus
    jmp greaterthancheck
    secondplus:
        lodsb
        cmp al,instructions[3];'+'
        je instruction_end
        jmp incomplete 
    greaterthancheck:   
    cmp al,instructions[4];'<'
    je secondgreater 
    jmp instruction_loop
    secondgreater:
        lodsb
        cmp al,instructions[5];'='
        je instruction_end
        jmp incomplete
    instruction_loop:
    inc buffdistance
    jmp instruction
 instruction_end:
 
 cmp byte ptr[si-1],'+'
 je searchvariable_
 cmp byte ptr[si-1],'=' 
 je searchvariable_
 cmp byte ptr[si-1],'"'
 je f  
 cmp isNumber,'t'
 je j    
 cmp byte ptr[si-1],'A'
 jge searchvariable_    
 cmp byte ptr[si],'A'
 jge searchvariable_ 
 jmp j
 f:
 mov cx,buffdistance
 m:
 inc buffloc
 loop m
 inc buffloc
 jmp searchvariable_  
 
 j:
 mov cx,buffdistance
 h:   
 inc buffloc
 loop h
 inc buffloc
 jmp endsearch  
 
 searchvariable_:
 mov buffloc,si  
 lea si,variables  
 
 searchvariable:
   
    mov di,bufforiginloc  
    mov cx,buffdistance
    rep cmpsb
    cmp cx,0
    je endsearch 
    cmp byte ptr [si],'$'
    je novariable
    jmp searchvariable 
 endsearch: 
    dec buffloc
    jmp endcheck
 novariable:
    mov isNoVariable,'t'  
    mov ax,bufforiginloc    
    mov buffloc,ax
    inc buffloc 
    call error   
    mov cx,buffdistance
    g:
    inc buffloc
    loop g
    jmp endsearch
 incomplete: 
 mov isIncomplete, 't' 
 call error
 ret 
 nextl:
 ret    
 endapp: 
 mov isEOF,'t'
 ret 
 function:
 mov cx,di
 sub cx,si 
 mov buffdistance,cx
 mov bufforiginloc,si
 mov buffloc,di
 lea si,functions 
    function_loop:
    mov di,bufforiginloc
    mov cx,buffdistance
    rep cmpsb
    cmp cx,0
    je validfunc  
    cmp byte ptr [si],'$'
    je invalidfunc
    jmp function_loop 
    validfunc: 
    inc buffloc 
    mov si,buffloc
    mov bufforiginloc,si 
    mov buffdistance,0
    jmp instruction
    invalidfunc:
    mov isInvalidFunction,'t'
    call error
    
    
    
 
check endp 
varload proc
 mov si,varloc  
 dec di
 mov cx,buffdistance
 varload_loop:
 mov al,[di]
 mov [si],al
 inc di
 inc si
 loop varload_loop
 mov varloc,si
 ret
varload endp  
error proc  
 mov ah,9  
 inc errorCnt
 lea dx,pLfcr
 int 21h  
 lea dx,pLine
 int 21h
 mov ah,2
 mov dl,line
 add dl,30h 
 int 21h    
 mov ah,9
 cmp isIncomplete,'t'
 je incomp
 cmp isNoVariable,'t'
 je novar  
 cmp isValidVar,'f'
 je validvare       
 cmp isInvalidSyntax,'t'
 je invalidsyntax
 ret
 invalidsyntax:
 mov isInvalidSyntax,'f'
 lea dx,pInvalidSyntax
 int 21h 
 ret
 validvare:  
 mov isValidVar,'t'
 lea dx,pValidVar
 int 21h
 ret
 incomp:
 mov isIncomplete,'f'
 lea dx,pIncomplete
 int 21h 
 ret
 novar: 
 mov isNoVariable,'f'
 lea dx,pNoVariable    
 int 21h
 ret
 
error endp

end main 