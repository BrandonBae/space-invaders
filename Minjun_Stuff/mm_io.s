nop
nop
add $r1, $r0, $r0
addi $r2, $r0, 2147483647
_loop:
addi $r1, $r1, 1
sw $r1, 1234($r0)
bne $r1, $r2, _loop