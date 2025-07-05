include irvine32.inc
.data

;titleMsg byte ' SNAKE ',0
titleLine1 byte '  *****   *   *  *****   *  *  ***** ', 0
titleLine2 byte '  *       **  *  *   *   * *   *     ', 0
titleLine3 byte '  *****   * * *  *****   **    ***** ', 0
titleLine4 byte '      *   *  **  *   *   * *   *     ', 0
titleLine5 byte '  *****   *   *  *   *   *  *  ***** ', 0

gameOverLine1 byte '  *****   *****   *********  *****   *****   *       *   *****   ***** ', 0
gameOverLine2 byte '  *       *   *   *   *   *  *       *   *    *     *    *       *   * ', 0
gameOverLine3 byte '  *  **   *****   *   *   *  *****   *   *     *   *     *****   ***** ',0
gameOverLine4 byte '  *   *   *   *   *   *   *  *       *   *      * *      *       *   * ', 0
gameOverLine5 byte '  *****   *   *   *   *   *  *****   *****       *       *****   *    *',0
startMsg byte ' Start Game: Press any key to continue ',0
speedMsg byte ' Speed ',0
levelMsg byte ' Level ',0
levelsMsg byte ' 1. Box 2. Rooms ' , 0
lvl byte 0
speedsMsg byte ' 1. Slow 2. Medium 3. Fast',0
selLevelMsg byte ' Select Level: ',0
selSpeedMsg byte ' Select Speed: ',0
delayTime dword 100
score dword 0
highScore dword 0
foodRow byte 0
foodCol byte 0
gameOverMsg byte "Game Over",0
FinalScore byte "Score: ", 0
MaxScore byte "High Score: ",0
snake BYTE "X", 40 DUP("x")
xPos BYTE 47,46,45,44,43, 100 DUP(?)
yPos BYTE 10,10,10,10,10, 100 DUP(?)
snakeLength dword 5
check dword 0
xWall BYTE 80 DUP("#"),0
xPosWall BYTE 0,0,80,80
yPosWall BYTE 0,24,0,24
xRoom byte 40 dup("#"),0
xPosRoom byte 0,40,40,40
yPosRoom byte 12,12,0,24
replayMsg byte "Do you want to replay? (1/0): ",0
invalidOpt byte "Invalid choice, exiting program ",0
flag byte 0
inputchar byte ?
previnput byte ?

WriteMessage MACRO msg
    mov edx, OFFSET msg ; Load the address of the message into EDX
    call WriteString ; Call the WriteString procedure
    ;call Crlf ; Add a new line
ENDM
.code
main proc
startt:
      call DisplaySnakeTitle
    writeMessage startMSg
    call crlf
    call readchar
    call crlf
    call clrscr
    writeMessage speedMsg
    call crlf
    writeMessage speedsMsg
    call crlf
    mov edx, offset selSpeedMsg
    call writeString
    mov eax, 0
speedInput:
    call readint
    cmp al, 1
    je speed1
    cmp al, 2
    je speed2
    cmp al, 3
    je speed3
    jmp speedInput
speed1:
    mov delayTime, 150
    jmp done
speed2:
    mov delayTime,100
    jmp done
speed3:
    mov delayTime, 50
    jmp done
done:
    writeMessage levelMsg
    call crlf
    writeMessage levelsMsg
    call crlf
    writeMessage selLevelMsg
levelInput:
    call readint
    cmp al, 1
    je level1
    cmp al, 2
    je level2
    jmp levelInput
level1:
    mov lvl, 1
    call clrscr
    call printWalls
    jmp redo
level2:
    mov lvl, 2
    call clrscr
    call printRooms
redo:
    call randomfood
    mov dh, 0
    mov dl, 82
    call gotoxy
    writeMessage finalScore

    mov ecx, 5
    mov esi, 0
drawSnake:
    call drawPlayer
    inc esi
loop drawSnake

    mov ecx, 20
space:
    call crlf
loop space
    cmp lvl, 1
    je moveBox
    cmp lvl, 2
    je moveRoom
moveBox:
    call moveSnake
    writeMessage replayMsg
    mov eax, 0
    call readint
    cmp eax, 1
    je replay
    cmp eax, 0
    je endd
    call crlf
    writeMEssage invalidOpt
exit

moveRoom:
    call moveSnakeRooms
    writeMessage replayMsg
    mov eax, 0
    call readint
    cmp eax, 0
    je endd
    cmp eax, 1
    je replay
    call crlf
    writeMEssage invalidOpt
replay:
    call restart
    jmp startt
endd:
exit
main endp

DisplayGameOverTitle PROC
    call Clrscr                ; Clear the screen first
    writeMessage gameOverLine1
    call crlf
    writeMessage gameOverLine2
    call crlf
    writeMessage gameOverLine3
    call crlf
    writeMessage gameOverLine4
    call crlf
    writeMessage gameOverLine5
    call crlf
    ret
DisplayGameOverTitle ENDP

DisplaySnakeTitle PROC
    call Clrscr                ; Clear the screen first
    writeMessage titleLine1          
    call crlf
    writeMessage titleLine2
    call crlf
    writeMessage titleLine3
    call crlf
    writeMessage titleLine4
    call crlf
    writeMessage titleLine5
    call crlf
    ret
DisplaySnakeTitle ENDP

drawPlayer proc
    mov dl,xPos[esi]
    mov dh,yPos[esi]
    call Gotoxy
    mov dl, al ;temporarily save al in dl
    mov al, snake[esi]
    call writechar
    mov al, dl
ret
DrawPlayer endp

UpdatePlayer proc
    mov dl, xPos[esi]
    mov dh, yPos[esi]
    call gotoxy
    mov dl, al
    mov al, " "
    call writechar
    mov al, dl
ret
UpdatePlayer endp

drawBody proc
    mov ecx, snakeLength   ; Use snakeLength to determine loop limit
    mov esi, 0
draw:
    inc esi
    call updatePlayer
    mov dl, xPos[esi]
    mov dh, yPos[esi]
    mov xPos[esi], al
    mov yPos[esi], ah
    mov al, dl
    mov ah, dh
    call drawPlayer
    cmp esi, ecx
    jnl done
    loop draw
done:
    ret
drawBody endp

PrintWalls proc
    mov dl,xPosWall[0]
    mov dh,yPosWall[0]
    call Gotoxy
    writeMessage xWall

    mov dl,xPosWall[1]
    mov dh,yPosWall[1]
    call Gotoxy
    writeMessage xWall ; lower wall
 
    mov dl, xPosWall[2]
    mov dh, yPosWall[2]
    mov eax,"#"
    inc yPosWall[3]
    L11:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosWall[3] ;draw right wall
    jl L11

    mov dl, xPosWall[0]
    mov dh, yPosWall[0]
    mov eax,"#"
L12:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosWall[3] ;draw left wall
    jl L12
ret
PrintWalls endp

PrintRooms proc
    mov dl,xPosRoom[0]
    mov dh,yPosRoom[0]
    call Gotoxy
    writeMessage xRoom

    mov dl,xPosRoom[1]
    mov dh,yPosRoom[1]
    call Gotoxy
    writeMessage xRoom ;draw lower wall

    mov dl, xPosRoom[2]
    mov dh, yPosRoom[2]
    mov eax,"#"
    inc yPosRoom[3]
    L21:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosRoom[3] ;draw right wall
    jl L21

    mov dl, xPosRoom[2]
    mov dh, yPosRoom[2]
    mov eax,"#"
    inc yPosRoom[3]
    L22:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosRoom[3] ;draw left wall
    jl L22
    ret
printRooms endp

moveSnake proc
l1:
    call readkey
    jz input
    mov bl, inputchar
    mov previnput, bl
    mov inputchar, al
input:
    cmp inputchar, 'w'
    je up
    cmp inputchar, 's'
    je down
    cmp inputchar, 'a'
    je left
    cmp inputchar, 'd'
    je right
    jmp invalidKey         ; For invalid keys,
    ;do nothing and go back to main loop
up:
    cmp previnput, 's'
    je noinput
    mov esi, 0
    mov eax, delaytime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    dec yPos[esi]
    mov cl, yPosWall[0]
    cmp yPos, cl
    jle gameOver
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
jmp done

down:
    cmp previnput, 'w'
    je noinput
    mov esi, 0
    mov eax, delaytime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    inc yPos[esi]
    mov cl, yPosWall[1]
    cmp yPos, cl
    jge gameOver
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done

right:
    cmp previnput, 'a'
    je noinput
    mov esi, 0
    mov eax, delaytime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    inc xPos[esi]
    mov cl, xPosWall[2]
    cmp xPos, cl
    jge gameOver
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done

left:
    cmp flag, 0
    je invalidKey
    cmp previnput, 'd'
    je noinput
    mov esi, 0
    mov eax, delaytime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    dec xPos[esi]
    mov cl, xPosWall[0]
    cmp xPos, cl
    jle gameOver
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver

done:
    inc flag
    call checkPoints
    jmp l1
invalidKey:
    mov ebx, 0
    mov bl, previnput ; Retain the previous direction
    mov inputchar, bl
    jmp l1
noinput:
    mov bl, previnput
    mov inputchar, bl
    jmp input
gameOver:
  call clrscr
    call DisplayGameOverTitle  ; Display "GAME OVER" title in stars
    writeMessage gameOverMsg
    call crlf
    writeMessage FinalScore
    mov eax, score
    call writedec
    call crlf
    writeMessage MaxScore
    mov eax, highScore
    call writedec
    call crlf
    ret
moveSnake endp

moveSnakeRooms proc
l1:
    call readkey
    jz input
    mov bl, inputchar
    mov previnput, bl
    mov inputchar, al
input:
    cmp inputchar, 'w'
    je up
    cmp inputchar, 's'
    je down
    cmp inputchar, 'a'
    je left
    cmp inputchar, 'd'
    je right
    jmp invalidKey         ; For invalid keys,
    ;do nothing and go back to main loop
up:
    cmp previnput, 's'
    je noinput
    mov esi, 0
    mov eax, delayTime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    dec yPos[esi]
    mov bl,yPosRoom[0]
    cmp yPos, bl
    je gameOver
    mov cl, yPosWall[0]
    cmp yPos, cl
    jle goDown
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done
goDown:
    mov cl, yPosWall[1]
    mov yPos, cl
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done

down:
    cmp previnput, 'w'
    je noinput
    mov esi, 0
    mov eax, delayTime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    inc yPos[esi]
    mov bl,yPosRoom[0]
    cmp yPos, bl
    je gameOver
    mov cl, yPosWall[1]
    cmp yPos, cl
    jge goUp
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done
goUp:
    mov cl, yPosWall[0]
    mov yPos, cl
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done

right:
    cmp previnput, 'a'
    je noinput
    mov esi, 0
    mov eax, delayTime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    inc xPos[esi]
    mov bl,xPosRoom[2]
    cmp xPos, bl
    je gameOver
    mov cl, xPosWall[2]
    cmp xPos, cl
    jge goLeft
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done
goLeft:
    mov cl, xPosWall[0]
    mov xPos, cl
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done

left:
    cmp flag, 0
    je invalidKey
    cmp previnput, 'd'
    je noinput
    mov esi, 0
    mov eax, delayTime
    call delay
    mov al, xPos[esi]
    mov ah, yPos[esi]
    dec xPos[esi]
    mov bl,xPosRoom[2]
    cmp xPos, bl
    je gameOver
    mov cl, xPosWall[0]
    cmp xPos, cl
    jle goRight
    call drawPlayer
    call drawBody
    jmp done
goRight:
    mov cl, xPosWall[2]
    mov xPos, cl
    call drawPlayer
    call drawBody
    call checkSnake
    cmp check, 1
    je gameOver
    jmp done
done:
    inc flag
    call checkPoints
    jmp l1
invalidKey:
    mov ebx, 0
    mov bl, previnput ; Retain the previous direction
    mov inputchar, bl
    jmp l1
noinput:
    mov bl, previnput
    mov inputchar, bl
    jmp input
gameOver:
     call clrscr
    call DisplayGameOverTitle  ; Display "GAME OVER" title in stars
    writeMessage gameOverMsg
    call crlf
    writeMessage FinalScore
    mov eax, score
    call writedec
    call crlf
    writeMessage MaxScore
    mov eax, highScore
    call writedec
    call crlf
    ret
ret
moveSnakeRooms endp


checkPoints proc
    mov al, xPos[0]      
    mov bl, foodCol      
    cmp al, bl            
    jne done              
    mov al, yPos[0]      
    mov bl, foodRow    
    cmp al, bl          
    jne done
    call newscore      
    call scoreDisplay
    call randomfood
done:
    ret
checkPoints endp

checkSnake proc  
    mov al, xPos[0]          
    mov ah, yPos[0]          
    mov esi, 4              
checkLoop:
    cmp xPos[esi], al        
    jne skipCheck    
    cmp yPos[esi], ah        
    je collisionDetected    
skipCheck:
    inc esi                  
    cmp esi, snakeLength    
    jl checkLoop            
    mov check, 0            
    ret

    collisionDetected:
    mov check, 1            
    ret
checkSnake endp

randomfood proc
    add snakeLength, 2
    redo:
    mov eax, 23
    call randomrange
    mov dh, al
    mov eax, 79
    call randomrange
    mov dl, al
    cmp lvl, 2
    jne skipp
    cmp dh, 12              
    je redo
    cmp dl, 40
    je redo
    skipp:
    cmp dh, 0  
    je redo
    cmp dl, 0                ; Left wall
    je redo
    cmp dl, 80               ; Right wall
    je redo
    cmp dh, 24
    je redo
    mov foodRow, dh
    mov foodCol, dl

    mov eax, white + (red * 16)
    call settextcolor
    call gotoxy
    mov al, ' '
    call writechar
    MOV EAX, white + (black * 16)
    CALL SetTextColor
    ret
randomfood endp

newscore proc
    add score, 1
    mov eax, score
    cmp highScore, eax
    jge nchange
    mov highScore, eax
    nchange:
    ret
newscore endp

scoreDisplay proc
    mov dh, 0
    mov dl, 90
    call gotoxy
    mov eax, score
    call writedec
    ret
scoreDisplay endp

restart proc

call clrscr
 mov snakeLength, 5
    mov flag, 0
    mov score, 0
    mov foodRow, 0
    mov foodCol, 0
    mov inputchar, 0
    mov previnput, 0
    dec yPosWall[3]
    sub yPosRoom[3], 2
    mov xPos[0], 47          
    mov xPos[1], 46
    mov xPos[2], 45
    mov xPos[3], 44
    mov xPos[4], 43
    mov yPos[0], 10        
    mov yPos[1], 10
    mov yPos[2], 10
    mov yPos[3], 10
    mov yPos[4], 10
    mov lvl, 0
ret
restart endp
end main
