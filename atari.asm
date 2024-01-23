.MODEL small
.STACK 100h
.DATA
padmov dw 0
speedx dw 1   
speedy dw -2 
timeadder dw 2
note dw 1387
x dw 0
Clock  equ es:6Ch
y dw 0
savekey db 0 
count dw 0
tempx dw 0 
ballminy dw 0
ballmaxy dw 0  
padminx dw 0
padmaxx dw 0 
savedcolor db 0
pady dw 185 
ballx dw 0 
bally dw 0 
ballrightx dw 0 
balltopy dw 0 
balldowny dw 0 
ballleftx dw 0
ballmiddlex dw 0 
balltempy dw 0
balltempx dw 0 
counter dw 10     
timerspeed dw 12 
cubcolor dw 0 
linecounter dw 0  
gamewinbol dw 0 
gameoverbol dw 0
brickcounter dw 0
destroyedbricks dw 0  
lifecounter dw 3 
lifeleft3 db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,"lives: 3         $"  
lifeleft2 db 13,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,"lives: 2         $" 
lifeleft1 db 13,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,"lives: 1         $" 
secounter dw 0 
milisecounter dw 0 
startx dw 0 
starty dw 0 
cheatx dw -1 
cheaty dw 0 
wallbol dw 0 
speedbol dw 0 
brickbol dw 0 
speed db "Press A and D to move."
dollar db 3 dup ('$') 
fasterbol dw 0 
slowbol dw 0
fastestball dw 2 
keybol dw 1  
.CODE

ball proc near
	mov cx, [ballx] 
	mov [balltempx], cx 
	add cx, 5 
	mov [ballrightx], cx 
	sub cx, 6 
	mov [ballleftx], cx 
	mov cx, [bally] 
	mov [balltempy], cx 
	mov [balltopy], cx 
	add cx, 5  
	mov [balldowny], cx 
	mov cx, [ballx] 
	inc cx 
	mov [ballmiddlex], cx  
	mov ah, 0ch 
	xor bx, bx   
	mov cx, 5   

	nextballline:
	push cx 
	cmp cx, 5 
	je ballmaker 
	cmp cx, 1 
	je ballmaker 


	mov cx, [ballx]
	dec cx    
	mov [tempx], cx 
	mov cx, [bally] 
	inc cx 
	mov [bally], cx 
	mov cx, 5 	  
	jmp balline 

	ballmaker:
	mov cx, [ballx]  
	mov [tempx], cx 
	mov cx, [bally] 
	inc cx 
	mov [bally], cx 
	mov cx, 3



	balline:
	push cx 
	mov cx, [tempx] 
	mov dx, [bally]
	int 10h
	inc cx 
	mov [tempx], cx 
	pop cx 
	loop balline


	pop cx 
	loop nextballline
	ret 
ball endp
   
bricks proc near
	mov bx, 0 
	mov dx, -1  
	;generate random number 
	mov ax, 40h 
	mov es, ax 
	mov ax, [clock] 
	and al, 255     
	mov [savedcolor] ,al 
	mov cx, 3 ;k=5 for normal 
	mov [linecounter], cx 
	cubscreen: ;print k lines of cubes
	push cx
	mov [savedcolor], al 
	add al, cl 
	dec al
	inc dx 
	mov [y], dx 
	mov dx, -1  
	mov [x], dx
	mov cx, 8 

	cubline: ;print one line of cubes 
	push cx 
	dec al

	;checks for unwanted colors  
	cmp al, 222 
	ja secondblack 
	cmp al, 8 
	je gray 
	cmp al, 7 
	je gray 
	cmp al, 0 
	je black 
	cmp al, 15   
	jae whit  
	jmp next101
	;223-255 are black 
	secondblack:
	mov al, 222 
	jmp next101 
	;15-31 are black too no racist 
	whit:   
	cmp al, 32 
	jae next101 
	add al, 17 
	jmp next101 
	;gray is bad 
	gray:
	mov al, 6 
	jmp next101 
	;if you are 0 you are black  
	black: 
	mov al, 12
	next101: 

	inc [brickcounter] 
	call cube 
	 
	pop cx 
	loop cubline

	 
	pop cx
	mov [savedcolor], al 
	loop cubscreen
	ret  
bricks endp

cube proc near
	mov ah, 0ch 
	xor bx, bx  
	mov cx, 40 
	cub: ; print cube  
	push cx  
	mov cx, 10 
	mov dx, [x]
	inc dx 
	mov [x], dx 
	mov dx, [y]   


	prp: ;print pixels in a line
	push cx
	mov cx, [x]
	int 10h
	inc dx ;y 
	   
	pop cx  
	loop prp

	pop cx 
	loop cub
	ret 
cube endp

finalcheck proc near
	mov bx, 0 
	mov dx, -1 
	mov cx, 0 
	mov [destroyedbricks], cx  
	mov cx, [linecounter]    
	cubscreen2: ;print k lines of cubes
	push cx
	inc dx 
	mov [y], dx 
	mov dx, -1  
	mov [x], dx
	mov cx, 8 

	cubline2: ;print one line of cubes 
	push cx 
	mov ah, 0dh 
	xor bx, bx 
	mov cx, [x] 
	mov [startx], cx 
	mov cx, [y] 
	mov [starty], cx  
	mov cx, 40 

	cub2: ; print cube  
	push cx  
	mov cx, 10 
	mov dx, [x]
	inc dx 
	mov [x], dx 
	mov dx, [y]   


	prp2: ;print pixels in a line
	push cx
	mov cx, [x]
	int 10h

	cmp al, 0 
	je stoploop 
	inc dx ;y 

	   
	pop cx  
	loop prp2

	pop cx 
	loop cub2
	jmp nextloop 
	stoploop:
	pop cx 
	pop cx 
	mov cx, [startx] 
	mov [x], cx 
	mov cx, [starty] 
	mov [y], cx 
	mov al, 0 
	call cube 
	inc [destroyedbricks] 

	nextloop: 
	pop cx 
	loop cubline2

	 
	pop cx 
	loop cubscreen2


	 
	ret 
finalcheck endp

printboard proc near
	mov ax, [x] 
	mov [padminx], ax 
	mov al, 14
	mov ah, 0ch 
	mov dx, [pady]  
	mov cx, 48

	prpb: ;print line 
	push cx
	mov cx, [x]
	int 10h
	inc cx 
	mov [x], cx  
	pop cx  
	loop prpb  
	mov ax, [x]
	mov [padmaxx], ax  
	ret 
printboard endp


cls proc near
	mov ax, 13h 
	int 10h 
	ret
cls endp

Beep proc near;plays a beep when the ball lands on the paddle (uses ax) ;taken from gavhim website
	; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play frequency 860Hz
	mov ax, [note]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	; wait for any key
	mov cx, 8 
	beeeeeeeeeeeeep:
	push cx 
	call keycheck
	call delayproc
	pop cx 
	loop beeeeeeeeeeeeep
	; close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
beep endp


paintcorrection proc near
	mov ah, 0dh 
	mov cx, 0 
	mov [x], cx 
	mov [savedcolor], cl 
	mov dx, [pady] 
	mov cx, 319

	  mispaint: ;check for miss painted areas 
	push cx 
	mov cx, [x] 
	int 10h 
	inc cx 
	mov [x], cx


	cmp al, [savedcolor]
	jne potantialymissed  
	jmp lop 

	 potantialymissed:
	int 10h 
	cmp al, [savedcolor]
	jne lop 

	mov ah, 0ch 
	dec cx 
	int 10h 
	mov ah, 0dh
	 
	 lop:
	mov [savedcolor], al
	pop cx 
	  loop mispaint
	ret 
paintcorrection endp

keycheck proc near

	 waitforkey:
	 
	in al, 64h
	cmp al, 10b 
	je fin
	in al, 60h

	;check what key is pressed

	cmp al, 1 
	je fin 

	mov cx, [padmaxx]
	cmp cx, 317
	jae checkforleft


	mov cx, [padminx]
	cmp cx, 3 
	jbe checkforright


	checkforleft: 
	cmp al, 1eh 
	je left

	mov cx, [padmaxx]
	cmp cx, 317	
	jae fin 	

	checkforright:
	cmp al, 20h 
	je right


	fin:
	ret 
	   left:   ;move the paddle to the left  
	xor bx, bx 
	mov [padmov], bx
	mov dx, [pady] 
	mov ah, 0ch 
	mov al, 14
	   
	mov cx, [padminx] 
	sub cx, 4
	mov [padminx], cx 
	mov [x], cx
	mov cx, 4
	  
	 paintleft:
	push cx  
	mov cx, [x] 
	int 10h 
	inc cx
	mov [x], cx 
	pop cx 
	 loop paintleft

	mov al, 0 
	 

	mov cx, [padmaxx]
	sub cx, 4  
	mov [padmaxx], cx
	mov [x], cx
	mov cx, 4
	jmp delright

	  
	 delright:
	push cx  
	mov cx, [x] 
	int 10h 
	inc cx
	mov [x], cx 
	pop cx 
	 loop delright

	call paintcorrection
	 
	ret 

	 right: ;move the paddle to the right 
	mov ax, 1 
	mov [padmov], ax 
	mov dx, [pady] 
	mov ah, 0ch 
	mov al, 0
	 
	 
	mov cx, [padminx] 
	add cx, 4
	mov [padminx], cx 
	mov [x], cx
	mov cx, 4
	  
	 delleft:
	push cx  
	mov cx, [x] 
	int 10h 
	dec cx
	mov [x], cx 
	pop cx 
	 loop delleft

	mov al, 14 
	mov cx, [padmaxx]
	mov [x], cx
	add cx, 4  
	mov [padmaxx], cx
	mov [x], cx
	mov cx, 4
	  
	 paintright:
	push cx  
	mov cx, [x] 
	int 10h 
	dec cx
	mov [x], cx 
	pop cx 
	 loop paintright

	call paintcorrection

	ret  
keycheck endp

delball proc near 
	mov cx, [balltempy]        
	mov [bally], cx
	mov cx, [balltempx]
	mov [ballx], cx      
	mov al, 0 
	call ball; delete the ball before
	ret 
delball endp

timeiskey proc near
	mov cx, [timerspeed] 
	thekey:
	push cx 
	call delayproc 
	call keycheck
	inc [milisecounter]
	pop cx 
	loop thekey 
	cmp [milisecounter], 70 
	jae countsec 
	ret 

	 countsec:
	mov [milisecounter], 0 
	inc [secounter] 
	ret 
timeiskey endp

addtoball proc near
	cmp [speedY], 0;if the y speed is higher then 0 it means the ball is moving down  
	jge addtodown
	;else it moves up   
	mov ax, [speedY]  
	add ax, [balltopy]   
	mov [bally], ax 
	jmp after 


	addtodown: 
	mov ax, [speedY]  
	add ax, [balldowny]   
	mov [bally], ax

	after:
	cmp [speedX], 0
	je nomove 
	jl addtoleft 
	mov ax, [ballrightx] 
	add ax, [speedX] 
	mov [ballx], ax
	ret

	nomove:
	ret 
	 
	addtoleft:
	mov ax, [ballleftx] 
	add ax, [speedX] 
	mov [ballx], ax   
	ret 
addtoball endp

checkhit proc near
   checkTHEplace:
 cmp [speedY], 0 
jg checkpadhit
jl checkupperwall
ret 
	checkupperwall:
     cmp [balltopy], 6        
     jbe upperWall
	cmp [speedX], 0 
    jg checkrightwall 
	jl checkleftwall
	ret 
     checkleftwall:
     cmp [ballleftx],6 
     jbe leftwall
	ret 
     checkrightwall: 
     cmp [ballrightx],314     
	jae rightwall
	ret 
	checkpadhit:
	cmp [balldowny], 174    
	jae padhit
	cmp [speedX], 0 
    jg checkrightwall 
	jl checkleftwall
	ret 

upperWall: 
cmp [speedY], 0 
jl negate2 
ret 
negate2: 
mov [note], 0e1fh 
call beep  
neg [speedY] 	
ret 

leftWall:
mov [wallbol], 3 
call delball 
 mov ax, [balltempy] 
 mov [bally], ax 
 mov ax, 6    
 mov [ballx], ax
 mov al, 10
 call ball
mov [note], 0e1fh 
call beep  
neg [speedX]
ret 

rightwall:
mov [wallbol], 3  
call delball 
 mov ax, [balltempy] 
 mov [bally], ax 
 mov ax, 314   
 mov [ballx], ax
 mov al, 10
 call ball
 mov [note], 0e1fh 
 call beep   
neg [speedX]  
ret 

padhit:
 cmp [balldowny], 187  
 jae lost

 call delball 
 
 
 mov ax, [balltempx] 
 mov [ballx], ax 
 mov ax, 179 
 mov [bally], ax
 mov al, 10
 call ball
 
 
 mov cx, [padminx]  
 mov [x], cx 
 mov cx, [pady]  
 mov [y], cx
 call printboard
 
 
 call timeiskey
 
 mov [note], 0d5ah
 call beep  
 
 mov ax, [ballmiddlex] 
 
 
 mov bx, [padminx] 
 sub bx, 2 
 cmp ax, bx  
 jb lost 
 
 
 mov bx, [padmaxx] 
 add bx, 2    
 cmp ax, bx  
 ja lost 
 
 cmp [padmov], 0 
 jz left2 
 cmp [padmov], 1 
 je right2
 ret
 lost: 
mov ax, 1 
mov [gameoverbol], ax 
ret 
	right2:
	mov ax, [padminx]  
	add ax, 22   
	cmp [ballmiddlex], ax    
	jb leftoftheright
	add ax, 4    
	cmp [ballmiddlex], ax 
	jb middleoftheright 
	add ax, 22  
	cmp [ballmiddlex], ax 
	jbe rightoftheright
	ret  
	leftoftheright:
mov ax, -8       
mov [speedY], ax
mov ax, 1      
mov [speedX], ax 
	ret 
	middleoftheright:
mov ax, -4           
mov [speedY], ax
mov ax, 2      
mov [speedX], ax 
	ret 
	rightoftheright: 
mov ax, -2    
mov [speedY], ax
mov ax, 6     
mov [speedX], ax 
    ret  
	
	left2: 
	mov ax, [padminx]    
	add ax, 22 
	cmp [ballmiddlex], ax 
	jb leftoftheleft  
	add ax, 4 
	cmp [ballmiddlex], ax 
	jb middleoftheleft  
	add ax, 22    
	cmp [ballmiddlex], ax
	jbe rightoftheleft 
	ret  
	leftoftheleft:
      mov ax, -2    
      mov [speedY], ax
      mov ax, -6     
      mov [speedX], ax 
   	ret 
   	middleoftheleft:
      mov ax, -4           
      mov [speedY], ax
      mov ax, -2      
      mov [speedX], ax 
   	ret 
   	rightoftheleft: 
     mov ax, -8       
     mov [speedY], ax
     mov ax, -1      
     mov [speedX], ax 

ret 						
checkhit endp

DelayProc proc near
  mov cx,1 
  mov dx,3dah
  loop11:
    push cx
    l1:
      in al,dx
      and al,08h
      jnz l1
    l2:
      in al,dx
      and al,08h
      jz l2
   pop cx
   loop loop11
   ret
DelayProc endp

brickhit proc near
	cmp [wallbol], 1 
	jae dontcheck
	cmp [brickbol], 1 
	jae dontbrick  
	xor bx, bx 
	mov ah, 0dh 
	mov dx, 90 
	mov cx, [ballmiddlex]
	cmp [balltopy] , 14
	jbe lowercheck
	checkbrokenbricks: 
	int 10h 
	cmp al, 0 
	jne nextcheck
	sub dx, 10 
	cmp dx, 0 
	jz bricksof 
	jmp checkbrokenbricks

	dontcheck:
	dec [wallbol] 
	ret 

	dontbrick: 
	dec [brickbol] 
	ret 

	bricksof: 
	ret 

	nextcheck: 
	add dx, 5   
	cmp [balltopy], dx ;dangerzone 
	jbe posshit 
	ret 
	posshit: 
	cmp [speedY], 0 ;check if the ball is going to hit the brick from up or down
	jl lowercheck   

	uppercheck: 
	mov dx, [balldowny]
	add dx, [speedY]
	jmp nextcheck101 


	lowercheck: 
	mov dx, [balltopy]
	add dx, [speedY]


	nextcheck101: 
	cmp [speedX], 0 ;check if to use the right or the left ballx 
	jge rightercheck

	leftercheck: 
	mov cx, [ballrightx] 
	cmp cx, 8 
	jbe finalcheck2 
	mov cx, [ballleftx]
	cmp cx, 8 
	jbe finalcheck2
	add cx, [speedX] 
	jmp finalcheck2 

	rightercheck:
	mov cx, [ballleftx]
	cmp cx, 312 
	jae finalcheck2
	mov cx, [ballrightx]
	cmp cx, 312 
	jae finalcheck2
	add cx, [speedX]   

	finalcheck2:
	int 10h 
	cmp al, 0 
	jne hit 
	ret 
	;first we need to find the head of the cube in order to delete it 
	hit:
	mov [savedcolor], al

	;find the leftest x 
	xsub:
	int 10h 
	dec cx 
	cmp [savedcolor], al 
	je xsub  


	add cx, 2 
	jmp ysub 

	firstbrick: 
	mov cx, 279 
	jmp ysub 

	lastbrick:
	mov cx, -1 

	;find the uppest y 
	ysub:
	int 10h 
	dec dx  
	cmp [savedcolor], al 
	je ysub 

	;add the things that were downed during the loops and delete the cube 
	add dx, 2 
	dec cx 
	mov [x], cx 
	mov [y], dx

	mov al, 0 
	call cube

	cmp [balltopy], 10 
	jbe check0 


	mov [note], 0fdah
	call beep


	neg [speedX]
	neg [speedY] 


	ret 

	check0: 
	cmp [speedY], 0 
	jl negate 
	ret 

	negate: 

	neg [speedX] 
	neg [speedY]  


	mov [note], 0fdah
	call beep

	ret 
	brickhit endp


	vichecker proc near
	 
	  
	mov bx, 0 
	mov [x], bx 
	mov cx, 320  
	xchecker:
	push cx 

	;calculate the final y 	
	mov ax, [linecounter]
	mov bx, 10 
	mul bx 
	add ax, 10 
	mov cx, ax 

	  
	mov dx, 0 
	mov ah, 0ch 
	mov al, 9
	mov bx, 0 
	mov ah, 0dh
	 
	ychecker: 
	push cx

	mov cx, [x]
	 
	int 10h 
	cmp al, 0 
	je goodtogo

	pop cx 
	pop cx  
	ret 

	goodtogo:
	inc dx  
	pop cx
	loop ychecker 

	inc [x] 
	pop cx
	loop xchecker  

	mov [gamewinbol], 1 
	mov [brickbol], 2 
	ret 
vichecker endp

keys proc near
	cmp al, 1Fh ;press s for slowing the ball 
	je slow 


	cmp al, 21h ;press F for making the ball faster 
	je fast 


	cmp al, 2ch ;press z for cheating  
	jne notcheat
	jmp cheat 

	notcheat: 

	;cmp al, 2Eh ;press c for comp mode 
	;je compmode

	cmp al, 50h ;press down for fastest ball alive 
	je youaskedforit 

	mov [keybol], 0 ;no key was pressed 
	cmp [secounter], 10     
	je highspeed 
	ret 

	youaskedforit:
	cmp [timerspeed], 2 
	jne n0p 
	mov [fastestball], 1  
	inc [lifecounter]

	mov cx, 10 ;~some delay 
	delayed99:
	push cx 
	call delayproc
	pop cx 
	loop delayed99  
	ret 

	n0p:
	mov [timerspeed], 3;reset the timerspeed 
	mov [fastestball], 2 ;reset the counter 
	ret 


	slow:
	cmp [slowbol], 1 
	jae decslow 
	inc [timerspeed]
	mov [slowbol], 2 
	ret  
	decslow:
	dec [slowbol] 
	ret 

	fast: 
	cmp [fasterbol], 1 
	jae decfast
	mov ax, [fastestball]     
	cmp [timerspeed], ax     
	jbe nothighh
	mov [speedbol], 1 
	dec [timerspeed]
	mov [fasterbol], 2 
	nothighh: 
	ret  
	decfast:
	dec [fasterbol] 
	ret  

	highspeed:
	mov [secounter], 0
	cmp [speedbol], 3  
	je nothigh
	cmp [timerspeed], 3    
	jbe nothigh
	dec [timerspeed] 
	nothigh: 
	ret 

	cheat: 
	mov ax, [cheatx] 
	mov [x], ax 
	mov ax, [cheaty]
	mov [y], ax  
	mov al, 0 
	call cube 

	mov ax, [cheatx] 
	cmp ax, 319 
	je resetto0
	add ax, 40 
	mov [cheatx], ax 
	ret 
	resetto0:
	mov ax, [cheaty] 
	add ax, 10 
	mov [cheaty], ax 
	mov ax, -1 
	mov [cheatx], ax 
	ret 
keys endp

main proc near
	mov ax, @data
	mov ds, ax

printagain: 
call cls 	 								
call bricks  ;print the bricks

mov dx, offset lifeleft3 ;print a message in white(al, 15) 
mov ah, 9 
int 21h  

mov dx, offset speed  
int 21h 


mov cx, 138 
mov [x], cx 
mov cx, [pady] 
mov [y], cx
call printboard ;print the paddle 

mov [lifecounter], 3 
mov [timerspeed], 5   

startgame:
mov [speedbol], 0 
mov [gameoverbol] , 0 
mov [gamewinbol], 0 

mov cx, 160              
mov [ballx], cx
mov cx, 100         	 
mov [bally], cx
mov al, 10   
call ball ;print the ball 

;press space if you dont like the bricks color   
mov ah, 0ch
mov al, 7h
int 21h 
cmp al, 20h 
je printagain 

mov ax, 2        
mov [speedY], ax
mov ax, 0        
mov [speedX], ax 

mov ax, [timerspeed] 
add ax, 2 
mov [timerspeed], ax 

	game: ;3,2,1 Action!!
mov ah, 0ch 
mov al, 0 
int 21h 

notneeded2:
cmp [gameoverbol], 1 
jne gamenotover  
jmp gameover
gamenotover:
cmp [gamewinbol], 1 
je exit
call delball
call addtoball

call vichecker

call finalcheck

mov al, 10 
call ball 

call checkhit

call brickhit 

call timeiskey

cmp al, 39h ;press space for reset 
jne next999 
jmp printagain

next999:
cmp al, 1 ;press exit for pause  
je paus2  
call keys 
 
jmp game  

mov cx, 50 ;~half a second 
delayed:
push cx 
call delayproc
pop cx 
loop delayed


mov ah, 0ch
mov al, 7h
int 21h
cmp al, 20h 
jne exit2 

jmp printagain

exit2: 
jmp exit 

paus2: ;pauses the game and w8 for key 
mov cx, 10 ;~some delay 
delayed5:
push cx 
call delayproc
pop cx 
loop delayed5  

paus: 
mov ah, 0ch 
mov al, 0 
int 21h

;check if a key was entered 
in al, 64h
cmp al, 10b 
je paus 
in al, 60h

cmp al, 1ch 
je exit2 

mov [keybol], 1 

call keys 

cmp [keybol], 1 
je paus2 

cmp al, 1 
jne paus2 


mov cx, 10 ;~half a second 
delayed4:
push cx 
call delayproc
pop cx 
loop delayed4 
jmp game 

gameover: 
call delball 
cmp [lifecounter] , 3 
je two2go 
cmp [lifecounter], 2 
je one2go 
cmp [lifecounter], 1  
je exit
two2go:
;set cursor postion to 0,0 in order to print again 
mov ah, 2 
mov bh, 0 
mov dh, 0 
mov dl, 0 
int 10h

mov dx, offset lifeleft2 
mov ah, 9 
int 21h 

mov dx, offset speed   
int 21h
 
dec [lifecounter]
jmp startgame
 
one2go:
;set cursor postion to 0,0 in order to print again 
mov ah, 2 
mov bh, 0 
mov dh, 0 
mov dl, 0 
int 10h

mov dx, offset lifeleft1 
mov ah, 9 
int 21h

mov dx, offset speed   
int 21h
 
dec [lifecounter]
jmp startgame

mov cx, 50 ;~half a second 
delayed2:
push cx 
call delayproc
pop cx 
loop delayed2

mov ah, 0ch
mov al, 7h
int 21h 
cmp al, 20h 
jne exit 
jmp printagain 
; --------------------------	
exit:
	mov ah, 0 
	mov al, 2 
	int 10h
	mov ax, 4c00h
	int 21h
main endp
end main