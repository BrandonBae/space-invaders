# width = 640, height = 480
# number of lives is in $r22, $r23
addi $r22, $r0, 10
sw $r22, 1250($r0)
addi $r23, $r0, 1
addi $r24, $r0, 0
sw $r24, 1300($r0)
# number of points is in $r24
# player left = 400, player right = 800
# playerX = 2000, playerY = 2001
# spriteX = 1010, 1020, ..., 1100
# laser on? address 1200 is a 1
# else: address 1200 is a 0
# player lives: 1250
# player score: 1300

# playerX = $r1, playerY = $r2
addi $r1, $r1, 295
addi $r2, $r2, 430
# enemy1X = $r3, enemy1Y = $r4
addi $r3, $r3, 13
addi $r5, $r5, 76
addi $r7, $r7, 139
addi $r9, $r9, 202
addi $r11, $r11, 265
addi $r13, $r13, 328
addi $r15, $r15, 391
addi $r17, $r17, 454
addi $r19, $r19, 517
addi $r21, $r21, 580
sw $r1, 2000($r0)
sw $r2, 2001($r0)
sw $r3, 1010($r0)
sw $r5, 1020($r0)
sw $r7, 1030($r0)
sw $r9, 1040($r0)
sw $r11, 1050($r0)
sw $r13, 1060($r0)
sw $r15, 1070($r0)
sw $r17, 1080($r0)
sw $r19, 1090($r0)
sw $r21, 1100($r0)

_repeat:

blt $r22, $r23, game_over

jal update_player

#if laser is shot then do this function
lw $r2, 1200($r0)
blt $r0, $r2, shoot

j dont_shoot

shoot:
  jal shoot_logic

dont_shoot:
jal update_enemies

jal _stall

j _repeat

update_player:
  # if 400 is 1: move player left
  lw $r1, 400($r0)
  blt $r0, $r1, move_left
  j maybe_move_right

  # store the value at address 2000 minus 10 at address 2000
  move_left:
    lw $r3, 2000($r0)
    addi $r3, $r3, -5
    addi $r4, $r0, -30
    blt $r3, $r4, wrap_around_right
    sw $r3, 2000($r0)
    j dont_move

  wrap_around_right:
    addi $r5, $r0, 615
    sw $r5, 2000($r0)
    j dont_move

  # if 800 is 1: move player right
  maybe_move_right:
    lw $r1, 800($r0)
    blt $r0, $r1, move_right
    j dont_move

  # store the value at address 2000 plus 10 at address 2000
  move_right:
    lw $r3, 2000($r0)
    addi $r3, $r3, 5
    addi $r4, $r0, 620
    blt $r4, $r3, wrap_around_left
    sw $r3, 2000($r0)
    j dont_move
    
  wrap_around_left:
    addi $r5, $r0, -25
    sw $r5, 2000($r0)

  dont_move:
  jr $r31

shoot_logic:
  # get playerX coord
  lw $r10, 2000($r0)
  # check if laser overlaps with enemy, if so, set enemy's y-coord memory address to 0
  # left side of laser in register r28, right side of laser in register r29
  addi $r28, $r10, 24
  addi $r29, $r10, 26
  
  # initialize registers with enemy X positions
  lw $r1, 1010($r0)
  addi $r2, $r1, 50
  lw $r3, 1020($r0)
  addi $r4, $r3, 50
  lw $r5, 1030($r0)
  addi $r6, $r5, 50
  lw $r7, 1040($r0)
  addi $r8, $r7, 50
  lw $r9, 1050($r0)
  addi $r10, $r9, 50
  lw $r11, 1060($r0)
  addi $r12, $r11, 50
  lw $r13, 1070($r0)
  addi $r14, $r13, 50
  lw $r15, 1080($r0)
  addi $r16, $r15, 50
  lw $r17, 1090($r0)
  addi $r18, $r17, 50
  lw $r19, 1100($r0)
  addi $r20, $r19, 50

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r1, miss1
  blt $r2, $r28, miss1
  # HIT, so move enemy back to top
  sw $r1, 1010($r0)
  sw $r0, 1011($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss1:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r3, miss2
  blt $r4, $r28, miss2
  # HIT, so move enemy back to top
  sw $r3, 1020($r0)
  sw $r0, 1021($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss2:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r5, miss3
  blt $r6, $r28, miss3
  # HIT, so move enemy back to top
  sw $r5, 1030($r0)
  sw $r0, 1031($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)
  
  miss3:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r7, miss4
  blt $r8, $r28, miss4
  # HIT, so move enemy back to top
  sw $r7, 1040($r0)
  sw $r0, 1041($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss4:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r9, miss5
  blt $r10, $r28, miss5
  # HIT, so move enemy back to top
  sw $r9, 1050($r0)
  sw $r0, 1051($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss5:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r11, miss6
  blt $r12, $r28, miss6
  # HIT, so move enemy back to top
  sw $r11, 1060($r0)
  sw $r0, 1061($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss6:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r13, miss7
  blt $r14, $r28, miss7
  # HIT, so move enemy back to top
  sw $r13, 1070($r0)
  sw $r0, 1071($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss7:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r15, miss8
  blt $r16, $r28, miss8
  # HIT, so move enemy back to top
  sw $r15, 1080($r0)
  sw $r0, 1081($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss8:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r17, miss9
  blt $r18, $r28, miss9
  # HIT, so move enemy back to top
  sw $r17, 1090($r0)
  sw $r0, 1091($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss9:

  # if laser's left < enemy's right && laser's right > enemy's left => HIT
  blt $r29, $r19, miss_all
  blt $r20, $r28, miss_all
  # HIT, so move enemy back to top
  sw $r19, 1100($r0)
  sw $r0, 1101($r0)
  # increment score
  addi $r24, $r24, 1
  sw $r24, 1300($r0)

  miss_all:
    jr $r31

update_enemies:

  enemy1:
    lw $r3, 1010($r0)
    lw $r4, 1011($r0)
    addi $r25, $r0, 430
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down1
    # decrement life
    bne $r22, $r0, decrement1
    j not_decrement1
    decrement1:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement1:
      # move back to top
      sw $r3, 1010($r0)
      sw $r0, 1011($r0)
      j enemy2
    move_down1:
      sw $r3, 1010($r0)
      addi $r4, $r4, 3
      sw $r4, 1011($r0)

  enemy2:
    lw $r3, 1020($r0)
    lw $r4, 1021($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down2
    # decrement life
    bne $r22, $r0, decrement2
    j not_decrement2
    decrement2:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement2:
      # move back to top
      sw $r3, 1020($r0)
      sw $r0, 1021($r0)
      j enemy3
    move_down2:
      sw $r3, 1020($r0)
      addi $r4, $r4, 3
      sw $r4, 1021($r0)

  enemy3:
    lw $r3, 1030($r0)
    lw $r4, 1031($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down3
    # decrement life
    bne $r22, $r0, decrement3
    j not_decrement3
    decrement3:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement3:
      # move back to top
      sw $r3, 1030($r0)
      sw $r0, 1031($r0)
      j enemy4
    move_down3:
      sw $r3, 1030($r0)
      addi $r4, $r4, 3
      sw $r4, 1031($r0)

  enemy4:
    lw $r3, 1040($r0)
    lw $r4, 1041($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down4
    # decrement life
    bne $r22, $r0, decrement4
    j not_decrement4
    decrement4:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement4:
      # move back to top
      sw $r3, 1040($r0)
      sw $r0, 1041($r0)
      j enemy5
    move_down4:
      sw $r3, 1040($r0)
      addi $r4, $r4, 3
      sw $r4, 1041($r0)

  enemy5:
    lw $r3, 1050($r0)
    lw $r4, 1051($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down5
    # decrement life
    bne $r22, $r0, decrement5
    j not_decrement5
    decrement5:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement5:
      # move back to top
      sw $r3, 1050($r0)
      sw $r0, 1051($r0)
      j enemy6
    move_down5:
      sw $r3, 1050($r0)
      addi $r4, $r4, 3
      sw $r4, 1051($r0)

  enemy6:
    lw $r3, 1060($r0)
    lw $r4, 1061($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down6
    # decrement life
    bne $r22, $r0, decrement6
    j not_decrement6
    decrement6:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement6:
      # move back to top
      sw $r3, 1060($r0)
      sw $r0, 1061($r0)
      j enemy7
    move_down6:
      sw $r3, 1060($r0)
      addi $r4, $r4, 3
      sw $r4, 1061($r0)

  enemy7:
    lw $r3, 1070($r0)
    lw $r4, 1071($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down7
    # decrement life
    bne $r22, $r0, decrement7
    j not_decrement7
    decrement7:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement7:
      # move back to top
      sw $r3, 1070($r0)
      sw $r0, 1071($r0)
      j enemy8
    move_down7:
      sw $r3, 1070($r0)
      addi $r4, $r4, 3
      sw $r4, 1071($r0)

  enemy8:
    lw $r3, 1080($r0)
    lw $r4, 1081($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down8
    # decrement life
    bne $r22, $r0, decrement8
    j not_decrement8
    decrement8:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement8:
      # move back to top
      sw $r3, 1080($r0)
      sw $r0, 1081($r0)
      j enemy9
    move_down8:
      sw $r3, 1080($r0)
      addi $r4, $r4, 3
      sw $r4, 1081($r0)

  enemy9:
    lw $r3, 1090($r0)
    lw $r4, 1091($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down9
    # decrement life
    bne $r22, $r0, decrement9
    j not_decrement9
    decrement9:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement9:
      # move back to top
      sw $r3, 1090($r0)
      sw $r0, 1091($r0)
      j enemy10
    move_down9:
      sw $r3, 1090($r0)
      addi $r4, $r4, 3
      sw $r4, 1091($r0)

  enemy10:
    lw $r3, 1100($r0)
    lw $r4, 1101($r0)
    # if enemy y coord is at 430, move them back up to top, decrement life
    blt $r4, $r25, move_down10
    # decrement life
    bne $r22, $r0, decrement10
    j not_decrement10
    decrement10:
      addi $r22, $r22, -1
      sw $r22, 1250($r0)
    not_decrement10:
      # move back to top
      sw $r3, 1100($r0)
      sw $r0, 1101($r0)
      j enemy_done
    move_down10:
      sw $r3, 1100($r0)
      addi $r4, $r4, 3
      sw $r4, 1101($r0)

  enemy_done:
    jr $r31

# stall logic (800 * 2 cycles approximately)
_stall:
addi $r28, $r0, 0
addi $r29, $r0, 800
_stall_repeat:
addi $r28, $r28, 1
bne $r28, $r29, _stall_repeat
jr $r31

game_over:
jal _stall
j game_over