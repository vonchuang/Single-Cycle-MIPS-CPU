# Single-Cycle-MIPS-CPU
## Design
A implementation of single cycle MIPS processor in Verilog. This version of the MIPS single-cycle processor can execute the following instructions:
*  R Type : ```nop```, ```add```, ```sub```, ```and```, ```or```, ```xor```, ```nor```, ```slt```, ```sll```, ```srl```, ```jr```, ```jarl```
*  I Type : ```addi```, ```andi```, ```slti```, ```beq```, ```bne```, ```lw```, ```lh```, ```sw```, ```sh```
*  J Typr ; ```j```, ```jal```

Environment : ModelSim
## DapaPath
![image](https://github.com/vonchuang/Single-Cycle-MIPS-CPU/blob/master/img/Single-Cycle-MIPS-CPU-DataPath.PNG)
## Test MIPS Instructions
```MIPS
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
00000000  //nop
20041000  //addi $4, $0, 4096  main  ; 7: addi $a0, $0, 4096 
00042400  //sll $4, $4, 16           ; 8: sll $a0, $a0, 16 
20100010  //addi $16, $0, 16         ; 9: addi $s0, $0, 16 # $s0 = 0 + 16 = 16 (10000) 
ac900000  //sw $16, 0($4)            ; 10: sw $s0, 0($a0) 
2011001f  //addi $17, $0, 31         ; 11: addi $s1, $0, 31 # $s1 = 0 + 31 = 31 (11111) 
ac910004  //sw $17, 4($4)            ; 12: sw $s1, 4($a0) 
02119020  //add $18, $16, $17        ; 13: add $s2, $s0, $s1 # $s2 = 16 + 31 = 47 (101111) 
ac920008  //sw $18, 8($4)            ; 14: sw $s2, 8($a0) 
02519822  //sub $19, $18, $17        ; 15: sub $s3, $s2, $s1 # $s3 = 47 - 31 = 16 (10000) 
ac93000c  //sw $19, 12($4)           ; 16: sw $s3, 12($a0) 
0211a024  //and $20, $16, $17        ; 17: and $s4, $s0, $s1 # $s4 = 10000 and 11111 = 10000 
ac940010  //sw $20, 16($4)           ; 18: sw $s4, 16($a0) 
3215000f  //andi $21, $16, 15        ; 19: andi $s5, $s0, 15 # $s5 = 10000 and 01111 = 00000 
ac950014  //sw $21, 20($4)           ; 20: sw $s5, 20($a0) 
0211b026  //xor $22, $16, $17        ; 21: xor $s6, $s0, $s1 # $s6 = 10000 xor 11111 = 01111 
ac960018  //sw $22, 24($4)           ; 22: sw $s6, 24($a0) 
0216b825  //or $23, $16, $22         ; 23: or $s7, $s0, $s6 # $s6 = 10000 or 01111 = 11111 
ac97001c  //sw $23, 28($4)           ; 24: sw $s7, 28($a0) 
02164027  //nor $8, $16, $22         ; 25: nor $t0, $s0, $s6 # $t0 = 10000 nor 01111 = -32 (11111111111111111111111111100000) 
ac880020  //sw $8, 32($4)            ; 26: sw $t0, 32($a0) 
01004827  //nor $9, $8, $0           ; 27: not $t1, $t0 # $t0 = 31 (11111) 
ac890024  //sw $9, 36($4)            ; 28: sw $t1, 36($a0) 
20107fff  //addi $16, $0, 32767      ; 30: addi $s0, $0, 32767 # $s0 = 0 + 32727 
00108040  //sll $16, $16, 1          ; 31: sll $s0, $s0, 1 # $s0 = 32727 * 2 = 65534 
22100001  //addi $16, $16, 1         ; 32: addi $s0, $s0, 1 # $s0 = 65535 
ac900028  //sw $16, 40($4)           ; 33: sw $s0, 40($a0) 
00108842  //srl $17, $16, 1          ; 34: srl $s1, $s0, 1 # $s1 = 65535 / 2 = 32767 
ac91002c  //sw $17, 44($4)           ; 35: sw $s1, 44($a0) 
8c900028  //lw $16, 40($4)           ; 37: lw $s0, 40($a0) # $s0 = 65535 
ac900030  //sw $16, 48($4)           ; 38: sw $s0, 48($a0) 
84910028  //lh $17, 40($4)           ; 39: lh $s1, 40($a0) # $s1 = -1 
ac910034  //sw $17, 52($4)           ; 40: sw $s1, 52($a0) # store -1 to memory 
a4910038  //sh $17, 56($4)           ; 41: sh $s1, 56($a0) # store 65535 to memory 
0230402a  //slt $8, $17, $16         ; 43: slt $t0, $s1, $s0 # is -1 
2a29ffff  //slti $9, $17, -1         ; 44: slti $t1, $s1, -1 # is -1 
0c100033  //jal 0x004000cc [fun1]    ; 45: jal to fun1 
00000000  //nop                      ; 46: nop 
20100040  //addi $16, $0, 64         ; 47: addi $s0, $0, 64 # compute address of fun2 
00108400  //sll $16, $16, 16         ; 48: sll $s0, $s0, 16 
22100100  //addi $16, $16, 256       ; 49: addi $s0, $s0,256 
0200f809  //jalr $31, $16            ; 50: jalr to fun2 
00000000  //nop                      ; 51: nop 
201001aa  //fun1: addi $16, $0, 426  ; 53: addi $s0, $0, 426 # $s0 = 0 + 426 
ac90003c  //sw $16, 60($4)           ; 54: sw $s0, 60($a0) # store 426 to memory 
03e00008  //jr $31                   ; 55: return jal 0x004000cc + 8
15000000  //fun3: bne $8, $0, 0 [fun4-0x004000d8]; Jump to fun4 
201077d6  //fun4: addi $16, $0, 30678; 59: addi $s0, $0, 30678 # $s0 = 0 + 30678 
ac900040  //sw $16, 64($4)           ; 60: sw $s0, 64($a0) # store 30678 to memory 
00000000  //nop                      ; 61: nop 
00000000  //nop                      ; 62: nop 
00000000  //nop                      ; 63: nop 
00000000  //nop                      ; 64: nop 
00000000  //nop                      ; 65: nop 
00000000  //nop                      ; 66: nop 
00000000  //nop                      ; 67: nop
1120fff5  //fun2: beq $9, $0, -44 [fun3-0x00400100] branch to fun3
00000000  //nop                      ; 70: nop 
00000000  //nop                      ; 71: nop 
00000000  //nop                      ; 72: nop 
00000000  //nop                      ; 73: nop 
00000000  //nop                      ; 74: nop 
```
## Execution Result
```rsult
run -all
# [ testfuxture1.v ] Rtype test START !!
# ============================================================================
# 
#  \(^o^)/  The Rtype result of DM_data is PASS!!!
# 
# ============================================================================
# [ testfuxture1.v ] Itype test START !!
# ============================================================================
# 
#  \(^o^)/  The Itype result of DM_data is PASS!!!
# 
# ============================================================================
# [ testfuxture1.v ] Jtype test START !!
# ============================================================================
# 
#  \(^o^)/  The Jtype result of DM_data is PASS!!!
# 
# ============================================================================
# 
# 
#         Single Cycle CPU				            
#         ****************************              
#         **                        **       /|__/|
#         **  Congratulations !!    **      / O,O  |
#         **                        **    /_____   |
#         **  Simulation PASS!!     **   /^ ^ ^ \  |
#         **                        **  |^ ^ ^ ^ |w|
#         *************** ************   \m___m__|_|
#       
```
