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
    jl sn_fim_if
    cmp %rcx, heapBegin
    jge sn_fim_if

    # *(blockBegin + blockSize) = 0 
    movq $0, (%rcx)

    # validAddress = blockBegin + blockSize
    movq %rcx, validAddress
    
    # *(blockBegin + blockSize + 1) = totalAllocated - blockSize;
    addq $1, %rcx
    subq %rax, %rsi
    movq %rsi, (%rcx)

    sn_fim_if:
    addq $24, %rsp
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

    subq $40, %rsp

    movq %rdi, %rdx # salva parametro (num_bytes) em rdx

    # Chama a brk - currentTop = sbrk(0)
    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, -8(%rbp)

    # *p = heapBegin
    movq heapBegin, %rbx
    movq %rbx, -16(%rbp)

    # m = 1
    movq $1, -24(%rbp)

    # %rax = num_bytes + 16
    movq %rdx, %rax
    addq $16, %rax

    # %rbx = 4096 * m
    # while (rax > rbx) ...
    movq -24(%rbp), %rcx
    movq %rcx, %rbx
    ffm_while_m:
    imul $4096, %rbx
    cmp %rax, %rbx
    jle ffm_fim_while_m
    addq $1, %rcx
    movq %rcx, %rbx
    jmp ffm_while_m
    ffm_fim_while_m:
    movq %rbx, -32(%rbp) # totalBytes = 4096*m
    
    movq -16(%rbp), %rax # rax = p

    # p < (int*) validAdress
    ffm_while_va:
    cmp %rax, validAddress
    jge ffm_fim_while_va
    
    # (if *p == 0 && *(p + 1) >= num_bytes)
    movq $0, %r8
    cmp (%rax), %r8
    jne ffm_fim_if_0
    movq %rax, %rbx
    addq $8, %rbx
    cmp (%rbx), %rdx
    jl ffm_fim_if_0

    movq $1, (%rax)

    # (if ((int *)validAdress <= p))
    cmp validAddress, %rax
    jg ffm_fim_if_1

    movq (%rbx), %r8
    movq %r8, -40(%rbp)
    movq %rdx, (%rbx)

    movq %rax, %rdi
    movq -40(%rbp), %rsi
    call setNext

    ffm_fim_if_1:
    # return p + 2;
    jmp ffm_ret

    ffm_fim_if_0:
    movq (%rbx), %rbx
    addq $2, %rbx
    addq %rbx, %rax
    jmp ffm_while_va

    ffm_fim_while_va:
    movq %rax, -16(%rbp)

    # TODO: Nenhuma memória foi alocada ainda, ou falta memória
    
    ffm_ret:
    movq -16(%rbp), %rax
    addq  $16, %rax
    addq $40, %rsp
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
