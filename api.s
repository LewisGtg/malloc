.section .data
    heapBegin: .quad 0
    validAddress: .quad 0   
.section .text
.globl _start
iniciaAlocador:
    # Chamar printf
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, heapBegin
    movq %rax, validAddress
    popq %rbp
    ret

setNext:
    # Arruma a pilha e aloca variáveis
    pushq %rbp
    movq %rsp, %rbp
    subq $24, %rsp

    # blockSize = *(p+1)
    movq %rdi, %rbx
    addq $8, %rbx
    movq (%rbx), %rax
    movq %rax, -16(%rbp)

    # blockBegin = p+2
    addq $8, %rbx
    movq %rbx, -24(%rbp)

    # rcx = blockBegin + blockSize
    movq %rbx, %rcx
    addq %rax, %rcx

    # Chama a brk 
    movq $0, %rdi
    movq $12, %rax
    syscall

    # heapTop = sbrk(0)
    movq %rax, -8(%rbp)

    # "if"
    cmp %rcx, validAddress
    jl fim_if
    cmp %rcx, heapBegin
    jge fim_if

    # *(blockBegin + blockSize) = 0 
    movq $0, (%rcx)

    # validAdress = blockBegin + blockSize
    movq %rcx, validAddress
    
    # *(blockBegin + blockSize + 1) = totalAllocated - blockSize;
    addq $1, %rcx
    subq %rax, %rsi
    movq %rsi, (%rcx)

    fim_if:
    addq $32, %rsp
    popq %rbp
    ret

bestFitMalloc:
    pushq %rbp
    movq %rsp, %rbp
    popq %rbp
    ret

firstFitMalloc:
    pushq %rbp
    movq %rsp, %rbp
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp
    popq %rbp
    ret

_start:
    pushq %rbp
    movq %rsp, %rbp
    call iniciaAlocador
    movq validAddress, %rdi
    movq $100, %rsi
    call setNext
    movq $60, %rax
    syscall
