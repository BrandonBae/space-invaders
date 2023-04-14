addi $r1, $r1, 0
addi $r2, $r2, 0
loop:
    sw $r1, 1000($r0)
    sw $r2, 1001($r0)
    addi $r1, $r1, 10
    addi $r2, $r2, 10
    j loop