;Nadav Moshe 211882212
.model small 
.stack 100h
.data
player_pos  dw 2000;defoult location
wall_position dw 3 dup(?); array to store walls locations
wall_count db 0;number of wall located
pointLocation dw 0
score db '0';score of player
point db 'A'
wallmsg db 'You hit the wall $' 
msg db 'Your score is $' 
.code
wall proc
	push ax
	push si
	push bx
	push dx
	push cx
try_again:
;this block gives the time into AX reg AH contain seconds and AL contains minutes
	mov si,00h
	mov al,00h
	out 70h,al
	in al,71h
	mov ah,al
	mov al,02h
	out 70h,al
	in al,71h
;performing scrambaling to creates more veriety of the walls location
	xor dx,dx
	mov cx,ax
	and cx,000fh
	rol ax,cl
	mov cx,2000
	mov dx,03ffh
	mul dx
	div word ptr cx; modulo of 2000 to stay in screem frame
	shl dx,1;multiply by 2 to get a a valid number
	mov si, dx   
;checking if landed on players location if yes find diffrent location
	cmp si,player_pos
	je try_again
;checking if landed on existing wall, if yes find diffrent location
	mov cl, wall_count
	cmp cl, 0
	je diffLocation
	mov di, offset wall_position
;checking if equall to existing wall positionn
	check_loop:
	cmp si, [di]
	je try_again
	add di, 2
	loop check_loop
diffLocation:
	; --- Store in wall_positions[wall_count] ---
	mov cx,0
	mov cl, wall_count
	mov bx, offset wall_position
	shl cx,1
	add bx,cx
	mov [bx], si;inserting new wall location into the array
	inc wall_count; added a wall
	mov bl, 35
	mov bh, 04h
	mov es:[si],bx
	pop cx
	pop dx
	pop bx
	pop si
	pop ax
	ret
wall endp

newPoint proc
	push ax
	push si
	push bx
	push dx
	push cx
	push bp
try_again2:
;this block gives the time into AX reg AH contain seconds and AL contains minutes
	mov si,00h
	mov al,00h
	out 70h,al
	in al,71h
	mov ah,al
	mov al,02h
	out 70h,al
	in al,71h
;performing scrambaling to creates more veriety of the walls location
	xor dx,dx
	mov cx,ax
	and cx,000fh
	rol ax,cl
	mov cx,2000
	mov dx,03ffh
	mul dx
	div word ptr cx; modulo of 2000 to stay in screem frame
	shl dx,1;multiply by 2 to get a a valid number
	mov si, dx   
;checking if landed on players location if yes find diffrent location
	cmp si,player_pos
	je try_again2
;checking if equall to existing wall positionn
	mov cx,3
	mov di, offset wall_position
check_loop2:
	cmp si, ds:[di]
	je try_again2
	add di, 2
	loop check_loop2
	mov bl, point
	inc point
	mov bh,04h
	push bx;storing current bx value
	mov bx, offset pointLocation
	mov [bx],si
	pop bx
	mov es:[si],bx
	pop bp
	pop cx
	pop dx
	pop bx
	pop si
	pop ax
ret
newPoint endp






START:
	mov dx, @data ;adress for data segment
	mov ds, dx ;sets data segment
	mov dx, 0b800h
	mov es, dx ;sets es to screen address
	mov al,32;space kay
	mov ah,00;black background
	mov cx, 2000d;200 chars on the screen (80*25)
;filling the screen with black
	mov si,0
screenBlack:
	mov es:[si],ax
	add si,2
	dec cx
	jnz screenBlack
;disabling keyboard defoult interupts
	in al, 21h
	or al, 02h
	out 21h, al
	;creating 3 walls
	call wall
	call wall
	call wall
	call newPoint
;printing red 0 in the middle of screen
	mov bl, 30h
	mov bh, 04h
	mov si, 2000
	mov es:[si],bx

chekKeyPress:
	in al, 64h
	test al, 01h;check if key was released
	je chekKeyPress
	in al,60h
	cmp al,9Eh;A
	je left_w
	cmp al,9Fh;S
	je down_s
	cmp al,0A0h;D
	je right_d
	cmp al,91h;W
	je up_w
	cmp al,94h;T
	je stopGame
	jmp chekKeyPress
;-------------------------
left_w:
mov ax,si;div is deviding AX reg
mov bp,160d
mov dx,0;16 bit division so dx equals 0
div word ptr bp; 16 bit division
cmp dx,0;checking if reminder is zero, means at start of line
je chekKeyPress;if at left location dont go left
;else go left
sub player_pos,2d
mov es:[si],0032
sub si,2


mov cx,3
mov di, offset wall_position
loop2:
cmp si, ds:[di]
je wallHit
add di, 2
loop loop2
jmp comp
wallHit:
mov ah, 09h
mov dx, offset wallmsg
int 21h
jmp printScore
comp:
cmp si,[pointLocation];checking is player reached point
je changepoint;create new point and update score value
mov es:[si],bx
jmp chekKeyPress
changepoint:
mov es:[si],0032;blacking char
inc score;increase score by one
mov bl, score
cmp bl,39h;check if score reached 9
je printScore;plotting the score
mov es:[si],bx
call newPoint;creating new point
jmp chekKeyPress
;this label printing the currect score the player got
printScore:
mov ah, 09h
mov dx, offset msg
int 21h
mov ah,02h
mov dl,score
int 21h
jmp stopGame
;------------------
down_s:
cmp si,3840;location of last row
ja chekKeyPress;if above dont go down
;else go down
add player_pos,160d
mov es:[si],0032
add si,160



mov cx,3
mov di, offset wall_position
loop3:
cmp si, ds:[di]
je wallHit
add di, 2
loop loop3


mov es:[si],bx

cmp si,pointLocation
je changepoint
jmp chekKeyPress
;-----------------
right_d:
mov ax,si;div is deviding AX reg
mov bp,160d
mov dx,0;16 bit division so dx equals 0
div word ptr bp; 16 bit division
cmp dx,158;checking if reminder is 158, means at end of line
je chekKeyPress;if at right location dont go right
;else go right
add player_pos,2d
mov es:[si],0032
add si,2


mov cx,3
mov di, offset wall_position
loop4:
cmp si, ds:[di]
je wallHit
add di, 2
loop loop4


mov es:[si],bx

cmp si,pointLocation
je changepoint
jmp chekKeyPress
;------------------
up_w:
cmp si,160;location of first row
jb chekKeyPress;if below dont go up
;else go up
sub player_pos,160d
mov es:[si],0032
sub si,160


mov cx,3
mov di, offset wall_position
loop5:
cmp si, ds:[di]
je wallHit
add di, 2
loop loop5


mov es:[si],bx
cmp si,pointLocation
je changepoint
jmp chekKeyPress

stopGame:
	in al, 21h 
	and al, 0Dh 
	out 21h, al
	mov ax, 4c00h
	int 21h;program ended
END START