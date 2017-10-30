	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x73, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47 //TODO: put 0 to F 7-Seg LED pattern here

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_BASE, 0x48000000
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDER, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_IDR, 0x48000010
	.equ GPIOA_ODR, 0x48000014
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28

	.equ DIGIT_0, 0x01
	.equ DECODE_MODE, 0x09
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT, 0x0B
	.equ INTENSITY, 0x0A
	.equ SHUTDOWN, 0x0C
	.equ DATA, 0x20
	.equ LOAD, 0x40
	.equ CLOCK, 0x80

	.equ X, 1200
	.equ Y, 1200

main:
    BL   GPIO_init
    BL   max7219_init
loop:
	movs r10, #0
    BL   Display0toF
    B loop

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, #0x1
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	ldr r1, =GPIOA_MODER
	ldr r2, =#0xABFF5400
	str r2, [r1]

	BX LR

Display0toF:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one per second.
	push {lr}
Display0toF_LOOP:
	ldr r0, =arr
	ldrb r1, [r0,r10]
	ldr r0, =DIGIT_0
	BL MAX7219Send
	BL Delay

	add r10, #1
	cmp r10, #16
	bne Display0toF_LOOP

	pop {pc}

	BX LR

MAX7219Send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =GPIOA_BASE
	ldr r2, =LOAD
	ldr r3, =DATA
	ldr r4, =CLOCK
	ldr r5, =GPIO_BSRR_OFFSET
	ldr r6, =GPIO_BRR_OFFSET
	mov r7, #16
.max7219send_loop:
	mov r8, #1
	sub r9, r7, #1
	lsl r8, r8, r9 // r8 = mask
	str r4, [r1,r6]//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
	tst r0, r8
	beq .bit_not_set//bit not set
	str r3, [r1,r5]
	b .if_done
.bit_not_set:
	str r3, [r1,r6]
.if_done:
	str r4, [r1,r5]
	subs r7, r7, #1
	bgt .max7219send_loop
	str r2, [r1,r6]
	str r2, [r1,r5]

	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	push {r2}
	push {r1}
	push {r0}

	ldr r0, =DECODE_MODE
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send
	ldr r0, =SCAN_LIMIT
	ldr r1, =0x0
	BL MAX7219Send
	ldr r0, =INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send
	ldr r0, =SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	pop {r0}
	pop {r1}
	pop {r2}
	pop {pc}
	BX LR

Delay:
	//TODO: Write a delay 1sec function
		ldr		r3, =X
	L1:	ldr		r4, =Y
	L2:	subs	r4, #1
		bne		L2
		subs	r3, #1
		bne		L1
		bx		LR
	BX LR
