# TODO: This is lab1.1
/* Real Mode Hello World */
/*
.code16

.global start
start:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $0x7d00, %ax
	movw %ax, %sp # setting stack pointer to 0x7d00
	# TODO:通过中断输出Hello World
	pushw $13		#长度是13
	pushw $message  #实模式下地址16位
	call displayStr

loop:
	jmp loop

message:
	.string "Hello, World!\n\0"

displayStr:                  #采用ah=13的中断，显示字符串
	pushw %bp               #调用函数储存返回的栈基址
	movw 4(%esp), %ax
	movw %ax, %bp           #bp存串地址
	movw 6(%esp), %cx       #cx存串长度
	movw $0x1301, %ax   	#ah=13 al=01表示属性
	movw $0x0007, %bx		#bh起始页为0 bl=07属性
	movw $0x0000, %dx		#dh dx 起始行列 都为0
	int $0x10
	popw %bp
	ret
*/


# TODO: This is lab1.2 
/* Protected Mode Hello World */
/*
.code16

.global start
start:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	# TODO:关闭中断
	cli				#cli为关闭中断指令


	# 启动A20总线
	inb $0x92, %al 
	orb $0x02, %al
	outb %al, $0x92

	# 加载GDTR
	data32 addr32 lgdt gdtDesc # loading gdtr, data32, addr32

	# TODO：设置CR0的PE位（第0位）为1
	movl %cr0, %eax     #CR0末尾为PE位
	orl $1, %eax 		
	movl %eax, %cr0


	# 长跳转切换至保护模式
	data32 ljmp $0x08, $start32 # reload code segment selector and ljmp to start32, data32

.code32
start32:
	movw $0x10, %ax # setting data segment selector
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %ss
	movw $0x18, %ax # setting graphics data segment selector
	movw %ax, %gs
	
	movl $0x8000, %eax # setting esp
	movl %eax, %esp
	# TODO:输出Hello World
	movl $message,%esi             
	movl $0xb8000,%ebx          #写到显存地址就能输出

print_per:						#一个字节一个字节输出
	movb (%esi),%al
	add $1,%esi
	andb %al,%al				#如果是0说明没有字节全部输出完毕
	jz loop32
	movb %al,(%ebx)				#移到显存地址
	add $2,%ebx                 #显存中两个字节表示一个输出字节，有一个字节高位对应字符属性      
	jmp print_per                  

loop32:
	jmp loop32

message:
	.string "Hello, World!\n\0"



.p2align 2
gdt: # 8 bytes for each table entry, at least 1 entry
	# .word limit[15:0],base[15:0]
	# .byte base[23:16],(0x90|(type)),(0xc0|(limit[19:16])),base[31:24]
	# GDT第一个表项为空
	.word 0,0
	.byte 0,0,0,0

	# TODO：code segment entry
	.word 0xffff,0
	.byte 0,0x9a,0xcf,0

	# TODO：data segment entry
	.word 0xffff,0
	.byte 0,0x92,0xcf,0

	# TODO：graphics segment entry
	.word 0xffff,0x8000
	.byte 0xb,0x92,0xcf,0

gdtDesc: 
	.word (gdtDesc - gdt -1) 
	.long gdt 
*/
/*
# TODO: This is lab1.3*/
/* Protected Mode Loading Hello World APP */

.code16

.global start
start:
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	# TODO:关闭中断
	cli


	# 启动A20总线
	inb $0x92, %al 
	orb $0x02, %al
	outb %al, $0x92

	# 加载GDTR
	data32 addr32 lgdt gdtDesc # loading gdtr, data32, addr32

	# TODO：设置CR0的PE位（第0位）为1
	movl %cr0, %eax
	orl $1,%eax 
	movl %eax, %cr0

	# 长跳转切换至保护模式
	data32 ljmp $0x08, $start32 # reload code segment selector and ljmp to start32, data32

.code32
start32:
	movw $0x10, %ax # setting data segment selector
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %ss
	movw $0x18, %ax # setting graphics data segment selector
	movw %ax, %gs
	
	movl $0x8000, %eax # setting esp
	movl %eax, %esp
	jmp bootMain # jump to bootMain in boot.c

.p2align 2
gdt: # 8 bytes for each table entry, at least 1 entry
	# .word limit[15:0],base[15:0]
	# .byte base[23:16],(0x90|(type)),(0xc0|(limit[19:16])),base[31:24]
	# GDT第一个表项为空
	.word 0,0
	.byte 0,0,0,0

	# TODO：code segment entry
	.word 0xffff,0
	.byte 0,0x9a,0xcf,0

	# TODO：data segment entry
	.word 0xffff,0
	.byte 0,0x92,0xcf,0

	# TODO：graphics segment entry
	.word 0xffff,0x8000
	.byte 0xb,0x92,0xcf,0

gdtDesc: 
	.word (gdtDesc - gdt - 1) 
	.long gdt 
