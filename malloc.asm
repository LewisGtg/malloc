.section .text
.global main
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp

    movq $100, -8(%rbp)
    movq -8(%rbp), %rax
    cmp $100, %rax
    jge end_loop
    # malloc(100)
    # printf
    # free
    end_loop:
    addq $16, %rsp
    popq %rbp
    movq $60, %rax
    syscall