.section .data
    heapBegin: .quad 0
    validAddress: .quad 0
    strMapa: .string "\nmapa:\n"
    strHash: .string "################\n"
    strNull: .string "*"
    strIm: .string "Bloco ocupado: %d\nTamanho Bloco: %d\n\n"
.section .text
.globl main
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rdi
    movq $12, %rax
    syscall
    movq %rax, heapBegin
    movq %rax, validAddress
    popq %rbp
    ret

imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    subq $16, %rsp

    # Chama a brk
    movq $0, %rdi
    movq $12, %rax
    syscall

    movq heapBegin, %rbx # rbx = p = heapBegin
    movq %rbx, -8(%rbp)
    movq %rax, -16(%rbp) # rax = sbrk(0)

    im_while:
    cmp -16(%rbp), %rbx
    jge im_fim_while
    mov $strIm, %rdi
    
    mov (%rbx), %rsi

    movq %rbx, %rdx
    addq $8, %rdx
    mov (%rdx), %rdx
    call printf

    movq -8(%rbp), %rbx
    movq %rbx, %rdx
    addq $8, %rdx
    movq (%rdx), %rdx
    addq $16, %rdx
    addq %rdx, %rbx
    movq %rbx, -8(%rbp) 
    jmp im_while

    im_fim_while:
    addq $16, %rsp
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

    # rbx = blockBegin + blockSize
    addq %rax, %rbx

    # Chama a brk 
    movq $0, %rdi
    movq $12, %rax
    syscall

    # heapTop = sbrk(0)
    movq %rax, -8(%rbp)

    # "if"
    cmp validAddress, %rbx 
    jl sn_fim_if
    cmp %rbx, heapBegin
    jge sn_fim_if

    # *(blockBegin + blockSize) = 0 
    movq $0, (%rbx)

    # validAddress = blockBegin + blockSize
    movq %rbx, validAddress
    
    # *(blockBegin + blockSize + 1) = totalAllocated - blockSize;
    addq $8, %rbx
    subq -16(%rbp), %rsi
    movq %rsi, (%rbx)

    sn_fim_if:
    addq $24, %rsp
    popq %rbp
    ret

bestFitMalloc:
    pushq %rbp
    movq %rsp, %rbp
    subq $48, %rsp

    # salva parametro (num_bytes) em rdx
    movq %rdi, %rdx

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

    # bestFit = 0
    movq $0, -32(%rbp)

    # bestPlace = NULL
    movq $0, -40(%rbp)

    # %rax = num_bytes + 16
    movq %rdx, %rax
    addq $16, %rax

    # %rbx = 4096 * m
    # while (rax > rbx) ...
    movq -24(%rbp), %rcx
    movq %rcx, %rbx
    bfm_while_m:
    imul $4096, %rbx
    cmp %rbx, %rax
    jle bfm_fim_while_m
    addq $1, %rcx
    movq %rcx, %rbx
    jmp bfm_while_m
    bfm_fim_while_m:
    # totalBytes = 4096*m
    movq %rbx, -48(%rbp)

    movq -16(%rbp), %rax

    # while p < validAddress
    bfm_while_p:
    cmp validAddress, %rax
    jge bfm_fim_while_p

    # Sequência de if's

    # *p == 0
    cmp $0, (%rax)
    jne bfm_or_if_fit

    # *(p + 1)>= num_bytes
    movq %rax, %rbx
    addq $8, %rbx
    cmp %rdx, (%rbx)
    jl bfm_or_if_fit

    # *(p + 1) < bestFit
    movq -32(%rbp), %rcx
    cmp %rcx, (%rbx) # inverte para WF
    jge bfm_or_if_fit

    # Todas condições foram satisfeitas
    jmp bfm_true_if_fit

    # Segunda parte do if (or)
    bfm_or_if_fit:
    # *p == 0
    cmp $0, (%rax)
    jne bfm_fim_if_fit

    # *(p + 1)>= num_bytes
    cmp %rdx, (%rbx)
    jl bfm_fim_if_fit

    # bestFit == 0
    cmp $0, %rcx
    jne bfm_fim_if_fit

    bfm_true_if_fit:
    movq (%rbx), %rcx
    
    # bestFit = *(p + 1) 
    movq %rcx, -32(%rbp) 

    # bestPlace = p
    movq %rax, -40(%rbp)

    bfm_fim_if_fit:

    # p += (2 + *(p + 1))
    movq -16(%rbp), %rbx
    addq $8, %rbx
    movq (%rbx), %rbx
    addq $16, %rbx
    addq %rbx, %rax
    movq %rax, -16(%rbp)

    jmp bfm_while_p

    bfm_fim_while_p:

    cmp $0, -40(%rbp)
    jne bfm_fim_if_bp

    # rcx = validAddress + num_bytes + 2
    movq %rdx, %rcx
    addq $16, %rcx
    addq validAddress, %rcx

    # p = validAddress 
    movq validAddress, %rbx
    movq %rbx, %rdi
    movq %rbx, -16(%rbp) 

    cmp -8(%rbp), %rcx
    jge bfm_else_bp

    # oldValue = *(p + 1)
    movq %rbx, %r9
    addq $8, %r9
    movq (%r9), %r8 
    movq %r8, %rsi

    jmp bfm_set_heap

    bfm_else_bp:
    addq -48(%rbp), %rdi 
    movq $12, %rax
    # brk(p + totalBytes)
    syscall 

    movq -16(%rbp), %rdi
    movq -48(%rbp), %rsi

    bfm_set_heap:
    # *p = 1 
    # *(p + 1) = num_bytes
    movq $1, (%rbx)
    addq $8, %rbx
    movq %rdx, (%rbx)

    call setNext
    movq -16(%rbp), %rax
    jmp bfm_ret

    bfm_fim_if_bp:
    movq -40(%rbp), %rax
    movq $1, (%rax)

    bfm_ret:
    addq $16, %rax
    addq $48, %rsp
    popq %rbp
    ret

firstFitMalloc:
    pushq %rbp
    movq %rsp, %rbp

    subq $40, %rsp

    # salva parametro (num_bytes) em rdx
    movq %rdi, %rdx

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
    cmp %rbx, %rax
    jle ffm_fim_while_m
    addq $1, %rcx
    movq %rcx, %rbx
    jmp ffm_while_m
    ffm_fim_while_m:
    # totalBytes = 4096*m
    movq %rbx, -32(%rbp)
    
    # rax = p
    movq -16(%rbp), %rax 

    # p < (int*) validAdress
    ffm_while_va:
    cmp validAddress, %rax
    jge ffm_fim_while_va
    
    # (if *p == 0 && *(p + 1) >= num_bytes)
    movq $0, %r8
    cmp (%rax), %r8
    jne ffm_fim_if_0
    movq %rax, %rbx
    addq $8, %rbx
    cmp %rdx, (%rbx)
    jl ffm_fim_if_0

    movq $1, (%rax)

    # (if ((int *)validAdress <= p))
    cmp %rax, validAddress
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
    movq -16(%rbp), %rbx
    addq $8, %rbx
    movq (%rbx), %rbx
    addq $16, %rbx
    addq %rbx, %rax
    movq %rax, -16(%rbp)
    jmp ffm_while_va

    ffm_fim_while_va:
    movq %rax, -16(%rbp)

    # TODO: Nenhuma memória foi alocada ainda, ou falta memória

    # # if ((int *)validAdress + num_bytes + 2 >= currentTop)
    movq %rdx, %rcx
    addq $16, %rcx
    addq validAddress, %rcx

    # p = validAddress 
    movq validAddress, %rbx
    movq %rbx, %rdi
    movq %rbx, -16(%rbp) 

    cmp -8(%rbp), %rcx
    jl ffm_else

    # p + totalBytes
    addq -32(%rbp), %rdi 
    movq $12, %rax
    # brk(p + totalBytes)
    syscall 

    movq -16(%rbp), %rdi
    movq -32(%rbp), %rsi
    jmp ffm_set_heap

    ffm_else:
    # setNext(p, oldValue)
    movq %rbx, %r9
    addq $8, %r9
    movq (%r9), %r8 
    movq %r8, %rsi

    ffm_set_heap:
    # *p = 1 
    # *(p + 1) = num_bytes
    movq $1, (%rbx)
    addq $8, %rbx
    movq %rdx, (%rbx)

    call setNext
    
    ffm_ret:
    movq -16(%rbp), %rax
    addq $16, %rax
    addq $40, %rsp
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    subq $16, %rdi
    movq $0, (%rdi)

    popq %rbp
    ret

main:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    mov $strHash, %rdi
    call printf

    call iniciaAlocador

    movq $100, %rdi
    call bestFitMalloc

    movq $500, %rdi
    call bestFitMalloc

    movq %rax, -8(%rbp)    

    movq $300, %rdi
    call bestFitMalloc

    movq %rax, %rdi
    call liberaMem

    movq -8(%rbp), %rdi
    call liberaMem

    movq $200, %rdi
    call bestFitMalloc

    call imprimeMapa
    # movq $100, %rdi
    # call firstFitMalloc
    addq $16, %rsp
    popq %rbp
    movq $60, %rax
    syscall
