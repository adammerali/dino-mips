# Dino Game — MIPS Assembly
#
# Memory map (byte addresses, word-aligned):
#   0x00  dino_y     height above ground (0 = on ground)
#   0x04  dino_vy    vertical velocity (positive = up)
#   0x08  cactus_x   column 0-39, moves right to left
#   0x0C  score
#
# Memory-mapped I/O:
#   0x100  jump_input  read: 1 if player wants to jump
#   0x104  frame_done  write: 1 = normal frame, 2 = game over
#
# Register conventions:
#   $s0 = dino_y
#   $s1 = dino_vy
#   $s2 = cactus_x
#   $s3 = score
#   $t0-$t5 = temporaries

main:
    # initialise game state
    add  $s0, $zero, $zero      # dino_y  = 0
    add  $s1, $zero, $zero      # dino_vy = 0
    addi $s2, $zero, 39         # cactus_x = 39
    add  $s3, $zero, $zero      # score = 0

    sw $s0, 0($zero)
    sw $s1, 4($zero)
    sw $s2, 8($zero)
    sw $s3, 12($zero)

game_loop:
    # read jump input from I/O
    lw   $t0, 256($zero)        # $t0 = jump_input (addr 0x100)
    beq  $t0, $zero, no_jump    # if not pressed, skip
    bne  $s0, $zero, no_jump    # if already in air, skip
    addi $s1, $zero, 6          # dino_vy = 6 (jump!)

no_jump:
    # physics: update position and apply gravity
    add  $s0, $s0, $s1          # dino_y += dino_vy
    addi $s1, $s1, -1           # dino_vy -= 1 (gravity)

    # clamp dino to ground
    slt  $t0, $s0, $zero        # $t0 = (dino_y < 0)
    beq  $t0, $zero, above_ground
    add  $s0, $zero, $zero      # dino_y = 0
    add  $s1, $zero, $zero      # dino_vy = 0

above_ground:
    # move cactus left
    addi $s2, $s2, -1           # cactus_x--

    # reset cactus when it exits screen
    slt  $t0, $s2, $zero        # $t0 = (cactus_x < 0)
    beq  $t0, $zero, check_collision
    addi $s2, $zero, 39         # cactus_x = 39
    addi $s3, $s3, 1            # score++

check_collision:
    # t1 = cactus_x - DINO_X(4)
    addi $t1, $zero, 4
    sub  $t2, $s2, $t1          # $t2 = cactus_x - 4

    # if cactus already passed dino (t2 < 0) -> no hit
    slt  $t3, $t2, $zero
    bne  $t3, $zero, no_collision

    # if cactus still 2+ units away (t2 >= 2) -> no hit
    addi $t4, $zero, 2
    slt  $t3, $t2, $t4          # $t3 = (t2 < 2)
    beq  $t3, $zero, no_collision

    # if dino jumped high enough (dino_y >= 3) -> no hit
    addi $t4, $zero, 3
    slt  $t3, $s0, $t4          # $t3 = (dino_y < 3)
    beq  $t3, $zero, no_collision

    # collision — game over
    addi $t0, $zero, 2
    sw   $t0, 260($zero)        # frame_done = 2 (game over)
    j    game_over

no_collision:
    # save state to memory
    sw $s0, 0($zero)
    sw $s1, 4($zero)
    sw $s2, 8($zero)
    sw $s3, 12($zero)

    # signal frame complete
    addi $t0, $zero, 1
    sw   $t0, 260($zero)        # frame_done = 1
    j    game_loop

game_over:
    # save final state so testbench can read score
    sw $s0, 0($zero)
    sw $s1, 4($zero)
    sw $s2, 8($zero)
    sw $s3, 12($zero)

    # keep signaling game over
    addi $t0, $zero, 2
    sw   $t0, 260($zero)
    j    game_over
