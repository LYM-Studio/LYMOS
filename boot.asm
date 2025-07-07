; boot.asm - 加载内核并跳转
org 0x7C00
bits 16

start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; 栈指针

    ; 打印启动信息
    mov si, boot_msg
    call print_string

    ; 加载内核（从磁盘第2扇区开始）
    mov ah, 0x02    ; BIOS读磁盘功能
    mov al, 4        ; 读取4个扇区（足够容纳kernel.bin）
    mov ch, 0        ; 柱面0
    mov dh, 0        ; 磁头0
    mov cl, 2        ; 从扇区2开始（引导扇区是1）
    mov bx, 0x7E00   ; 加载到内存 0x7E00
    int 0x13
    jc disk_error    ; 出错则跳转

    ; 跳转到内核
    jmp 0x7E00

; 打印字符串函数
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

; 错误处理
disk_error:
    mov si, error_msg
    call print_string
    jmp $

; 数据区
boot_msg db "Bootloader: Loading kernel...", 0x0D, 0x0A, 0
error_msg db "Error: Disk read failed!", 0x0D, 0x0A, 0

; 填充引导扇区
times 510-($-$$) db 0
dw 0xAA55          ; 引导标志