.section .data
    heapBegin: .quad 0
    validAddress: .quad 0
    strMapa: .string "\nmapa:\n"
    strHash: .string "################"
    strOcupado: .string "-"
    strFree: .string "+"
    strNull: .string "\n"
    strFim: .string "\n\n"
.section .text
.globl imprimeMapa
.globl iniciaAlocador
.globl bestFitMalloc
.globl firstFitMalloc
.globl liberaMem

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
    subq $32, %rsp                              
    movq heapBegin, %r8                        
    movq %r8, -8(%rbp)                          
    print_while:
    movq $0, -32(%rbp)                          

    movq $12, %rax                              
    movq $0, %rdi                               
    syscall                                     

    movq %rax, %rcx                             
    movq -8(%rbp), %r8                          

    cmpq %rcx, %r8                              
    jge end_print_while                         

    movq $0, %rdx                               
    cmpq %rdx, (%r8)                            
    jg else_print_free_if                       
    movq $1, -16(%rbp)                          
    jmp exit_print_free_if                      
    else_print_free_if:
    movq $0, -16(%rbp)                          
    exit_print_free_if:
    movq $strHash, %rdi                   
    call printf                                 

    movq -8(%rbp), %r8                          

    addq $8, %r8                                
    movq (%r8), %r10                            
    movq %r10, -24(%rbp)                        

    addq $8, %r8                                
    movq %r8, -8(%rbp)                          
    print_for:
    movq -32(%rbp), %r11                        
    movq -24(%rbp), %r10                        
    cmpq %r10, %r11                             
    jge end_print_for                           

    movq -16(%rbp), %r9                         
    movq $1, %rcx                               
    cmpq %r9, %rcx                              
    je else_char_select                         
    movq $strOcupado, %rdi                    
    jmp exit_char_select                        
    else_char_select:
    movq $strFree, %rdi                       
    exit_char_select:
    call printf                                 

    movq -32(%rbp), %r11                        
    addq $1, %r11                               
    movq %r11, -32(%rbp)                        
    
    jmp print_for                               
    end_print_for:
    movq -24(%rbp), %r10                        
    movq -8(%rbp), %r8                          
    
    addq %r10, %r8                              
    movq %r8, -8(%rbp)                          
    jmp print_while                             
    end_print_while:
    movq $strNull, %rdi                              
    call printf                                 

    addq $32, %rsp                              
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

__main:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    mov $strMapa, %rdi
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

    mov $strFim, %rdi
    call printf

    addq $16, %rsp
    popq %rbp
    movq $60, %rax
    syscall
