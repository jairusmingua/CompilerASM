cursor macro col,row
    mov dh,row
    mov dl,col                                  
    mov bh,0
endm  
displaybuff macro col,row,msg 
    mov cx,0
    add cl,coloffset      
    add cl,col
    cursor 0,row
    mov cx,0
    mov al,0
    mov bh,0
    mov bl,0fh
    lea bp,msg
    mov cl,char
    mov ah,13h
    int 10h
endm
print macro col,row,msg  
    mov cx,0
    add cl,coloffset      
    add cl,col
    cursor cl,row
    mov cx,0
    mov al,0
    mov bh,0
    mov bl,0fh
    lea bp,msg+1
    mov cl,[bp-1]
    mov ah,13h
    int 10h
endm
printmenu macro menu,attrib 
    mov al,1  
    mov bh,0
    mov bl,attrib  
    lea bp,menu
    cursor [bp],[bp+1]
    mov cl,[bp+2]
    add bp,3
    mov ah,13h
    int 10h   
    
endm
printError macro errortype,line  
    lea dx,lfcr
    mov ah,9
    int 21h
    lea dx,ErrorInLine
    int 21h   
    mov dl,line
    add dl,30h
    mov ah,2
    int 21h
    lea dx,errortype
    mov ah,9
    int 21h  
      
endm    