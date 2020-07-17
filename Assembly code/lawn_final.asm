#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0000h#	; same as loading segment
#ES=0000h#	; same as loading segment

; set stack
#SS=0000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here

		jmp st1
		db 509 dup(0)		; 512 - the size of the previous instructions
		db 512 dup(0)

; MAIN PROGRAM

st1:	cli

; Initialise DS, ES and SS to start of RAM

		
		mov       ax,0200h	; Starting address of RAM according to our memory interfacing is 02000H. Which means the segment
        mov       ds,ax     ; register has a starting address of 0200H
        mov       es,ax
        mov       ss,ax
        mov       sp,0FFFEH

; Writing the control word to 8253

		mov al, 00010001b	; Control Word for 8253 #1 counter 0(Mode 0, 8 bit bcd count)
		out 56h, al

		mov al, 01010000b	; Control Word for 8253 #1 counter 1(Mode 0, 8 bit binary count)
		out 56h, al

		mov al, 00010000b	; Control Word for 8253 #2 counter 0(Mode 0, 8 bit bcd count)
		out 5eh, al

		mov al, 01010000b	; Control Word for 8253 #2 counter 1(Mode 0, 8 bit bcd count)
		out 5eh, al

		mov al, 10010000b	; Control Word for 8253 #2 counter 2(Mode 0, 8 bit bcd count) 
		out 5eh, al

		mov al, 00010000b	; Control Word for 8253 #3 counter 0(Mode 0, 8 bit bcd count)
		out 66h, al

		mov al, 01010000b	; Control Word for 8253 #3 counter 1(Mode 0, 8 bit bcd count)
		out 66h, al
		
		mov al, 10010000b	; Control Word for 8253 #3 counter 2(Mode 0, 8 bit bcd count)
		out 66h, al

		mov al, 05h			; LSB for 11AM counter
		out 50h, al

		mov al, 28h			; LSB for 6PM counter
		out 52h, al 

;===============================================================================================		

; Initialising 8255 #1

		; Writing the control word
		mov al, 10011000b	; Port A is input port, B is output, CL is output. CU is input
		out 46h, al 		; 46H is the address of the control register of 8255 #1

; Initialising 8255 #2
		mov al, 10011000b	; Port A is input port, B is output, CL is output. CU is input
		out 4eh, al

; Checking overhead tank		
		in al, 44h
		rol al, 2
		jc end

;============================================SPRINKLER 0, 1, 2==========================================================

		mov bh, 00h
		mov ch, 01h
		mov dx, 0058h

start0:

; Which input to convert to output in ADC (IN0)
		mov al, bh
		out 42h, al  

x3:		mov al, 00000000b	; make ALE low
		out 44h, al
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000001b	; make ALE high
		out 44h, al
		mov al, 00000011b   ; making SOC high
		out 44h, al
		nop
		nop
		nop
		nop 
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000000b	; make ALE low 
		out 44h, al

; Checking for EOC
x4:		in al, 44h 
		and al,80h
		jnz x2
		jmp x4 

; Taking input from port A	   
x2:		in  al, 40h
		mov cl, al

; Which input to convert to output in ADC (IN1)
		mov al, ch
		out 42h, al  

x13:	mov al, 00000000b	; make ALE low	
		out 44h, al
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000001b	; make ALE high
		out 44h, al
		mov al, 00000011b   ; making SOC high
		out 44h, al
		nop
		nop
		nop
		nop 
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000000b	; make ALE low 
		out 44h, al

; Checking for EOC
x14:    in al, 44h 
		and al,80h
		jnz x12
		jmp x14 

; Taking input from port A	   
x12:	in  al, 40h
		mov bl, al  

; Adding the output from 2 potentiometers
		add cl, bl 
		cmp cl, 0ffh 		; 0ffh is 5v
		jl lsb
		
		mov al, 01h
		out dx,al
		jmp incr

; Writing the LSB to the required counter
lsb:	mov ah, 0ffh
		sub ah, cl
		mov al, ah
		out dx, al 
		
incr:   add bh, 02h
		cmp bh, 04h
		jg end
		add ch, 02h
		add dx, 0002h
		jmp start0


;============================================SPRINKLER 3.4.5==========================================================

		mov bh, 00h
		mov ch, 01h
		mov dx, 0058h

start1:

; Which input to convert to output in ADC (IN0)
		mov al, bh
		out 42h, al  

x23:	mov al, 00000000b	; make ALE low
		out 44h, al
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000001b	; make ALE high
		out 44h, al
		mov al, 00000011b   ; making SOC high
		out 44h, al
		nop
		nop
		nop
		nop 
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000000b	; make ALE low 
		out 44h, al

; Checking for EOC
x24:	in al, 44h 
		and al,80h
		jnz x22
		jmp x24 

; Taking input from port A	   
x22:	in  al, 40h
		mov cl, al

; Which input to convert to output in ADC (IN1)
		mov al, ch
		out 42h, al  

x33:	mov al, 00000000b	; make ALE low	
		out 44h, al
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000001b	; make ALE high
		out 44h, al
		mov al, 00000011b   ; making SOC high
		out 44h, al
		nop
		nop
		nop
		nop 
		mov al, 00000010b   ; making SOC low
		out 44h, al
		mov al, 00000000b	; make ALE low 
		out 44h, al

; Checking for EOC
x34:    in al, 44h 
		and al,80h
		jnz x32
		jmp x34 

; Taking input from port A	   
x32:	in  al, 40h
		mov bl, al  

; Adding the output from 2 potentiometers
		add cl, bl 
		cmp cl, 0ffh 		; 0ffh is 5v
		jl lsb1
		
		mov al, 01h
		out dx,al
		jmp incr1

; Initiating 8253 #2 again
		mov al, 00010000b	; Control Word for 8253 #2 counter 0(Mode 0, 8 bit bcd count)
		out 5eh, al

		mov al, 01010000b	; Control Word for 8253 #2 counter 1(Mode 0, 8 bit bcd count)
		out 5eh, al

		mov al, 10010000b	; Control Word for 8253 #2 counter 2(Mode 0, 8 bit bcd count) 
		out 5eh, al

; Writing the LSB to the required counter
lsb1:	mov ah, 0ffh
		sub ah, cl
		mov al, ah
		out dx, al 
		
incr1:  add bh, 02h
		cmp bh, 04h
		jg finalend
		add ch, 02h
		add dx, 0002h
		jmp start1



finalend:	jmp finalend

	