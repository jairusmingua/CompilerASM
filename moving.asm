clear macro 
    push ax 
    mov ah,0
	mov al,03h
	int 10h   
	pop ax
    
endm
print macro msg,c,size
    mov al,1
    mov bh,0  
    mov bl,c
    mov cx,size   
    lea bp,msg
    mov ah,13h
    int 10h
endm
getloc macro 
    mov ah,03h
    int 10h  
    
endm
cursor macro row,col  
    mov dh,row
    mov dl,col
    mov bh,0
    mov ah,2
    int 10h
endm  


.model small 
PUBLIC run
.data
   xpos db 12
   ypos db 40
   size db 50,50   
   screensize db 50,50 
   maxsize db 23,78   
   direction db 'r','d' ;right down
   success db 'Compilation Successful!!!'  
   press db 'Press esc to close app....'
   color db 1 
   about db 12,36,'About..', 50 dup('')
   hightlight db 0fh     
   isNamedisplayed db 'f'
    
   names db 10,13,'Jairus Mingua',10,13,'Exequiel Bjorn',10,13,'Trexil'
.code           
 run proc
    mov ax,@data
    mov ds,ax
    mov es,ax 
    mov ah,0
    mov al,03h
    int 10h    
    mov ax, 0
    int 33h 
    mov ax, 1
    int 33h
    getloc
    cursor xpos,ypos
    j:
    call check 
    call move  
    call checkmouse
    call delay       ;delay
    mov ah, 01h
    int 16h
    jz  j
                   ;galing sa snake
    mov ah, 00h
    int 16h

    cmp al, 1bh    ; esc - key?
    je  endapp  ;
    endapp:  
    clear
    mov ah,4ch
    int 21h
                                                                
 run endp 
 move proc
    xmove:
    cmp direction,'r'
    jne left
    inc xpos
    jmp ymove
    left:
    dec xpos
    ymove:
    cmp direction[1],'d'
    jne up
    inc ypos
    jmp endmove
    up:
    dec ypos
    jmp endmove
    endmove:   
    clear  
    cursor 10,27    
     
    print press,04fh,25               
   
    cursor about[0],about[1],about[2] 
    print about[2],hightlight,5        
    cursor xpos,ypos 
    print success,color,25   
    call displayNames 
   
    ret
 move endp   
 displayNames proc
    cmp isNamedisplayed,'t'
    jne i  
    cursor 13,20
    print names,0fh,37
    ret 
    i:
    ret
 displayNames endp
 checkmouse proc
    mov ax, 3
    int 33h  
    cmp bx,1
    jne exitmouse  
    ;cmp cx,word ptr about[1]
    ;jne exitmouse
    ;cmp dx,word ptr about[0]
    ;jne exitmouse  
    mov al,0Bh
    mov hightlight,al
    cmp isNamedisplayed,'f'
    jne exitmouse
    mov isNamedisplayed,'t'
    ret
    exitmouse: 
    cmp isNamedisplayed,'f'      
    mov al,0fh
    mov hightlight,al 
    mov ax, 1
    int 33h 
    ret
 checkmouse endp
 check proc 
    getloc
    call checkbound
    ret
 check endp
 checkbound proc   
    cmp color,0fh
    jne v 
    mov color,1
    
    v:
    cmp dh,maxsize
    jg invertx  
    cmp dh,0
    je invertx
    jmp y
    invertx:
    cmp direction,'r'
    jne changex
    mov direction,'l'  
    inc color
    jmp y 
    changex:
    mov direction,'r'
    inc color
    y:
    cmp dl,maxsize[1]
    jg inverty  
    cmp dl,25
    je inverty
    jmp exit
    inverty:
    cmp direction[1],'d'
    jne changey
    mov direction[1],'u' 
    inc color
    jmp exit
    changey:
    mov direction[1],'d'  
    inc color
    exit: 
    ret
 checkbound endp
 delay       proc
            mov     cx, 002H
    delRep: push    cx
            mov     cx, 0D040H
    delDec: dec     cx
            jnz     delDec
            pop     cx
            dec     cx
            jnz     delRep
            ret
delay       endp
end run   
 
  
    
