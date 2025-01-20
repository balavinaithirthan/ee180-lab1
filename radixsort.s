#==============================================================================
# File:         radixsort.s (PA 1)
#
# Description:  Skeleton for assembly radixsort routine. 
#
#       To complete this assignment, add the following functionality:
#
#       1. Call find_exp. (See radixsort.c)
#          Pass 2 arguments:
#
#          ARG 1: Pointer to the first element of the array
#          (referred to as "array" in the C code)
#
#          ARG 2: Number of elements in the array
#          
#          Remember to use the correct CALLING CONVENTIONS !!!
#          Pass all arguments in the conventional way!
#
#       2. Call radsort. (See radixsort.c)
#          Pass 3 arguments:
#
#          ARG 1: Pointer to the first element of the array
#          (referred to as "array" in the C code)
#
#          ARG 2: Number of elements in the array
#
#          ARG 3: Exponentiated radix
#          (output of find_exp)
#                 
#          Remember to use the correct CALLING CONVENTIONS !!!
#          Pass all arguments in the conventional way!
#
#       2. radsort routine.
#          The routine is recursive by definition, so radsort MUST 
#          call itself. There are also two helper functions to implement:
#          find_exp, and arrcpy.
#          Again, make sure that you use the correct calling conventions!
#
#==============================================================================

.data
HOW_MANY:   .asciiz "How many elements to be sorted? "
ENTER_ELEM: .asciiz "Enter next element: "
ANS:        .asciiz "The sorted list is:\n"
SPACE:      .asciiz " "
EOL:        .asciiz "\n"

.text
.globl main

#==========================================================================
main:
#==========================================================================

    #----------------------------------------------------------
    # Register Definitions
    #----------------------------------------------------------
    # $s0 - pointer to the first element of the array
    # $s1 - number of elements in the array
    # $s2 - number of bytes in the array
    #----------------------------------------------------------
    
    #---- Store the old values into stack ---------------------
    addiu   $sp, $sp, -32
    sw      $ra, 28($sp)

    #---- Prompt user for array size --------------------------
    li      $v0, 4              # print_string
    la      $a0, HOW_MANY       # "How many elements to be sorted? "
    syscall         
    li      $v0, 5              # read_int
    syscall 
    move    $s1, $v0            # save number of elements

    #---- Create dynamic array --------------------------------
    li      $v0, 9              # sbrk
    sll     $s2, $s1, 2         # number of bytes needed
    move    $a0, $s2            # set up the argument for sbrk
    syscall
    move    $s0, $v0            # the addr of allocated memory


    #---- Prompt user for array elements ----------------------
    addu    $t1, $s0, $s2       # address of end of the array
    move    $t0, $s0            # address of the current element
    j       read_loop_cond

read_loop:
    li      $v0, 4              # print_string
    la      $a0, ENTER_ELEM     # text to be displayed
    syscall
    li      $v0, 5              # read_int
    syscall
    sw      $v0, 0($t0)     
    addiu   $t0, $t0, 4

read_loop_cond:
    bne     $t0, $t1, read_loop 

    #---- Call find_exp, then radixsort ------------------------

    # Pass the two arguments in $a0 and $a1 before calling
    # find_exp. Again, make sure to use proper calling 
    # conventions!

    # TODO: Somehow do array > 0
    move $a0 $s0
    move $a1 $s1

    # ---- Function call to find_exp() ----
    jal find_exp

    # Load return of find_exp as 3rd argument
    move $a2 $v0

    # Pass the three arguments in $a0, $a1, and $a2 before
    # calling radsort (radixsort)
    jal radsort


    #---- Print sorted array -----------------------------------
    li      $v0, 4              # print_string
    la      $a0, ANS            # "The sorted list is:\n"
    syscall

    #---- For loop to print array elements ---------------------
    
    #---- Initiazing variables ---------------------------------
    move    $t0, $s0            # address of start of the array
    addu    $t1, $s0, $s2       # address of end of the array
    j       print_loop_cond



print_loop:
    li      $v0, 1              # print_integer
    lw      $a0, 0($t0)         # array[i]
    syscall
    li      $v0, 4              # print_string
    la      $a0, SPACE          # print a space
    syscall            
    addiu   $t0, $t0, 4         # increment array pointer

print_loop_cond:
    bne     $t0, $t1, print_loop

    li      $v0, 4              # print_string
    la      $a0, EOL            # "\n"
    syscall          

    #---- Exit -------------------------------------------------
    lw      $ra, 28($sp)
    addiu   $sp, $sp, 32
    jr      $ra

# ---------- Register Definitions ----------
# a0 - pointer to first element of array
# a1 - size of the array, `n`
# a2 - exp, the maximum power of RADIX (10) less than the largest element (i.e. 1000 if largest is 1500)
.globl radsort
radsort:
    # ---------- Set up Stack Frame ----------
    # Stack Frame Size: 32
    addiu $sp, $sp, -100 # Move stack pointer to allocate space
    sw $ra, 28($sp)     # Since we'll be making function calls, save $ra at the top of s.f.

    # NOTE: Don't think we need to save arguments a0-a2 becuase don't use original values after recursive call

    # ---------- Base Case ----------
    slti $t0 $a1 2 # t0 = condition: n < 2
    seq $t1 $a2 $0 # t1 = condition: exp == 0
    or $t1 $t0 $t1 # t1 = n < 2 || exp == 0

    bne $t1 $0 radsort_exit

    # ---------- Recursive Case ----------
    # ---------- Register Definitions ----------
    # We will soon override a0-a2
    # t0 - sp - pointer to first element of array
    # t1 - sp + 4 - size of the array, `n`
    # t2 - sp + 8 - exp, the maximum power of RADIX (10) less than the largest element (i.e. 1000 if largest is 1500)
    # t3 - sp + 12 - # bytes to alloc (same for both `children` and `children_len` bc. unsigned and unsigned* are 4 bytes)
    # t4 - sp + 16 - address of children
    # t5 - sp + 20 - address of children_len
    # t6 - sp + 24 - RADIX
    # ra - sp + 28 - return address
    move    $t0, $a0
    sw      $t0, ($sp) 
    move    $t1, $a1
    sw      $t1, 4($sp)
    move    $t2, $a2
    sw      $t2, 8($sp)

    addiu   $t6, $0, 10 # RADIX = 10
    sw      $t6, 24($sp) 
    sll     $t3, $t6, 2 # bytes = RADIX * 4
    sw      $t3, 12($sp)

    # --- Malloc `children` ---
    li      $v0, 9              # sbrk
    move    $a0, $t3            # set up the argument for sbrk
    syscall
    move    $t4, $v0            # the addr of allocated memory
    sw      $t4, 16($sp)        

    # --- Malloc `children_len` ---
    li      $v0, 9              # sbrk
    move    $a0, $t3            # set up the argument for sbrk
    syscall
    move    $t5, $v0            # the addr of allocated memory
    sw      $t5, 20($sp)
    
    # TODO: --- Init Buckets Loop ---
    # t0 is loop variable
    # t1 is i * 2
    # t2 is addr of children
    # t3 is RADIX
    # t4 addr of children + offset
    # t5 is branch indic
    # move $t9, $ra
    # jal print
    # move $ra, $t9
    # move $t9, $ra
    # jal print
    # move $ra, $t9
    j       bucket_init_test

bucket_init_body: 
    sll     $t1, $t0, 2             # temp = i << 2
    add     $t4, $t1, $t2           # temp = temp + addr children len
    sw      $zero 0($t4)
    addu    $t0, 1                 # i += 1


bucket_init_test:
    slt     $t5, $t0, $t3           # t8 = i < RADIX
    beq     $t5, 1, bucket_init_body

   # --- Assign Array Values to Buckets Loop ---
    # t0 is loop var
    # t1 is temp
    # t2 is original array addr
    # t3 is temp
    # t4 is temp
    # t5 is temp
    # t6 is children len
    # t7 is children
    # t8 is sort index

    move    $t0 $zero
    lw      $t2, 0($sp)
    lw      $t6, 20($sp)
    lw      $t7, 16($sp)

    j       bucket_assign_test

empty_child_len:
            # children[sort_index] = (unsigned *)malloc(sizeof(unsigned) * n);
    lw      $t1 4($sp)          # t1 = n
    sll     $t1, $t1, 2            # n * 4
    li      $v0, 9              # sbrk
    move    $a0, $t1            # alloc n * 4
    syscall
    move    $t5, $v0            # t5 = addr of allocated memory
    sll     $t4, $t8, 2         # t4 = sort_index << 2 = sort_index * 4
    add     $t4, $t7, $t4       # t4 = children + sort_index
    sw      $t5, ($t4)          # children[sort_index] = pointer to mem
    j non_empty_child_len

# .globl bucket_assign_body
bucket_assign_body:
    sll     $t4, $t0, 2             # t8 = i << 2 = i * 4
    addu    $t4, $t2, $t4           # t4 (next addr) = t1 + t2
    lw      $t4, 0($t4)             # $t4 = arr[i]
    lw      $t3, 8($sp)             # t3 = exp
    divu    $t4, $t3                # t1 = arr[i] / exp
    mflo    $t4                     # t4 is reminder
    lw      $t5, 24($sp)            # t5 = RADIX
    divu    $t4, $t5                # t1 / RADIX
    mfhi    $t4                     # t4 is reminder, t4 is sort_index
    move    $t8, $t4                # t8 = sort index
    sll     $t4, $t8, 2             # t4 = sort_index << 2 = sort_index * 4
    add     $t4, $t6, $t4           # t4 = &children_len + sort_index
    lw      $t4, ($t4)              # t4 = children_len[sort_index]
    beq $t4, 0, empty_child_len     # beq arr[i] == 0, empty_children_len_if

non_empty_child_len:
    sll     $t1, $t8, 2             # t1 = sort_index << 2 = sort_index * 4
    add     $t4, $t6, $t1           # t4 = &children_len + sort_index
    add     $t5, $t7, $t1           # t5 = &children + sort_index 
    lw      $t3, ($t5)              # t3 = *(children + sort index)
    lw      $t4, ($t4)              # t4 = *(children_len + sort_index)
    sll     $t4, $t4, 2             # t4 index *= 4
    add     $t3, $t4, $t3           # t3 = children[sort_index] an addr [t4 index]
    sll     $t1, $t0, 2             # i = i * 4, t1
    add     $t1, $t1, $t2           # t1 = i * 4 + orig_array
    lw      $t1, ($t1)              # t1 = arr[i]
    sw      $t1, ($t3)              # in t3, place arr[i]
    sll     $t1, $t8, 2             # t1 = sort_index << 2 = sort_index * 4
    add     $t4, $t6, $t1           # t4 = children_len + sort_index
    lw      $t3, ($t4)              # t3 = children_len[sort_index]
    addu    $t3, $t3, 1             # t3 += 1
    sw      $t3, ($t4)              # children_len[sort_index] = t4 
    addu    $t0, 1                  # i += 1


bucket_assign_test:
    lw      $t1 4($sp)              # t1 = n
    slt     $t4, $t0, $t1           # t8 = i < n
    beq     $t4, 1, bucket_assign_body

    # TODO: --- Recursive Radsort Loop ---
    # t0: i
    # t1: idx
    # t2: &children_len
    # t3: &children
    # t4: temp
    # t5: temp
    # t6: i2
    # t7: array
    # t8: temp
    move    $t0, $0
    move    $t1, $0
    lw      $t2, 20($sp)
    lw      $t3, 16($sp)
    j rad_test

recurse_rad_sort:
    sll     $t5, $t0, 2             # t5 = i << 2 = i * 4
    add     $t5, $t5, $t3           # t5 = &(children + t5)
    lw      $t5, ($t5)              # t5 = children[i]
    move    $a0, $t5                # arg 0 = children[i]
    sll     $t4, $t0, 2             # t4 = i * 4
    add     $t4, $t2, $t4           # t4 = children_len + i
    lw      $t4, ($t4)              # t4 = children_len[i]
    move    $a1, $t4                # arg 1 = children_len[i]
    lw      $t4, 8($sp)             # t4 = exp
    lw      $t5, 24($sp)            # t5 = RADIX
    divu    $t4, $t5                # t1 = exp / RADIX
    mfhi    $t4                     # t4 is quotient
    move    $a2, $t4                # arg 2 = exp/RAD
    sw   $t0, 32($sp)
    sw   $t1, 36($sp)
    sw   $t2, 40($sp)
    sw   $t3, 44($sp)
    sw   $t4, 48($sp)
    sw   $t5, 52($sp)
    sw   $t6, 56($sp)
    sw   $t7, 60($sp)
    sw   $t8, 64($sp)
    jal     radsort                 #radsort(children[i], children_len[i], exp/RADIX);
    lw   $t0, 32($sp)
    lw   $t1, 36($sp)
    lw   $t2, 40($sp)
    lw   $t3, 44($sp)
    lw   $t4, 48($sp)
    lw   $t5, 52($sp)
    lw   $t6, 56($sp)
    lw   $t7, 60($sp)
    lw   $t8, 64($sp)
    j       copy_array_jump

copy_array_body:    
    sll     $t8, $t6, 2             # t8 = i2 << 2 = i2 * 4
    add     $t4, $t7, $t1           # dst = array + idx
    add     $t8, $t4, $t8           # dst + i = t8 = array + idx + i

    sll     $t5, $t0, 2             # t5 = i << 2 = i * 4
    add     $t5, $t5, $t3           # t5 = &(children + t5)
    lw      $t5, ($t5)              # t5 = children[i]
    sll     $t4, $t6, 2             # t4 = i2 << 2 = i2 * 4
    add     $t5, $t4, $t5           # src = t5 = &(children[i] + t4)
    lw      $t5, ($t5)              # t5 = children[i][i2]
    sw      $t5, ($t8)              # *t8 = t5 
    add     $t6, $t6, 1

copy_array_test:
    sll     $t5, $t0, 2             # t5 = i << 2 = i * 4
    add     $t5, $t5, $t2           # t5 = &(children_len + t5)
    lw      $t5, ($t5)              # t5 = children_len[i]
    slt     $t5, $t6, $t5           # t8 = i < children_len[i]
    beq     $t5, 1, copy_array_body
    j       rest_rad_body

rad_body:
    sll     $t4, $t0, 2             # t4 = i * 4
    add     $t4, $t2, $t4           # t4 = children_len + i
    lw      $t4, ($t4)              # t4 = children_len[i]
    bne     $t4, $0, recurse_rad_sort

copy_array_jump:
    move    $t6, $0
    lw      $t7, ($sp)
    j       copy_array_test

rest_rad_body:
    sll     $t4, $t0, 2             # t4 = i * 4
    add     $t4, $t2, $t4           # t4 = children_len + i
    lw      $t4, ($t4)              # t4 = children_len[i]
    add     $t1, $t1, $t4           # idx += children_len[i]
    addu    $t0, 1                  # i += 1

rad_test:
    lw      $t4 24($sp)              # t4 = RADIX
    slt     $t4, $t0, $t4           # t8 = i < RADIX
    beq     $t4, 1, rad_body
 


    # TODO: --- Free Children Array Loop ---

    # TODO: Free Children

    # TODO: Free Children Len

    # move $t0, $ra
    # jal print
    # move $ra, $t0


radsort_exit:
    # ---------- Reset Stack Frame and Return ----------
    lw $ra, 28($sp)
    addiu $sp, $sp, 100
    jr      $ra

# ---------- Register Definitions ----------
# a0 - pointer to first element of array
# a1 - size of the array, `n`
find_exp:
# NOTE: Don't actually think we need to set up the stack frame here
# Since everything is done in registers and we don't make any function calls

# ---------- Find Largest Loop ----------
    # ----- Register Definitions -----
    # t0 - i
    # t1 - arr_ptr
    # t2 - condition: i < n
    # t3 - array[array_ptr]
    # t4 - `largest`
    # t5 - condition: largest < array[array_ptr]
    # t6 - condition: largest == array[array_ptr], then condition: largest <= array[array_ptr] 
    
    # -- Loop Initialization --
    lw $t4, 0($a0)      # int largest = arr[0]
    add $t0, $0, $0     # i = 0
    add $t1, $a0, $0    # array_ptr = addr

    # Jump to loop condition
    j find_largest_test

find_largest_body:
    # -- Loop Body --

    lw $t3, 0($t1) # temp = arr[array_ptr]

    slt $t5, $t4, $t3   # largest < arr[array_ptr]
    seq $t6 $4 $t3      # largest == array[array_ptr]
    or $t6, $t5, $t6    # t6 = largest <= arr[array_ptr]

    # If not entering if statement, skip the reassignment of largest
    beq $t6 $zero after_set_largest 
    move $t4 $t3 # largest = array[array_ptr]

after_set_largest:
    addi $t0, $t0, 1 # i++
    addiu $t1, $t1, 4 # array_ptr += 4

find_largest_test:
    # -- Loop Condition --
    slt $t2, $t0, $a1               # i < n
    bne $t2, $0, find_largest_body  # If condition passed, execute body

# ---------- End Loop ----------

#---------- Exponent Loop ----------
    # ----- Register Definitions -----
    # t0 = exp
    # t1 = RADIX = 10
    # t2 = condition: largest > RADIX
    # t3 = condition: largest == RADIX, then largest >= RADIX
    # t4 = largest
    
    # -- Loop Initialization --
    addi $t0 $0 1 # exp = 1
    addi $t1 $0 10 # RADIX = 10
    
    # Jump to loop condition
    j exp_loop_test

exp_loop_body:
    # -- Loop Body --

    # NOTE: Mult/Div results stored in special 64-bit register
    # For divison, lower 32 = quotient, upper 32 = remainder
    # mfhi loads upper 32, mflo loads lower 32    

    divu $t4 $t1 # largest / RADIX
    mflo $t4 # largest = largest / RADIX

    # Special case of multu that discards upper 32 bits. This should be
    # fine because our inputs will not exceed 32 bit numbers, and exp
    # will never be greater than our input
    mul $t0 $t0 $t1 # exp = exp * RADIX

exp_loop_test:
    # -- Loop Condition --
    sgt $t2 $t4 $t1 # largest > RADIX
    seq $t3 $t4 $t1 # largest == RADIX
    or $t3 $t2 $t3 # largest >= RADIX

    # Jump to body if true
    bne $t3 $zero exp_loop_body

# ---------- End Loop ----------

# Return exp
    move $v0 $t0
    jr      $ra

arrcpy:
    jr      $ra

print:
    li $v0, 1
    # lw $t3, ($t5)
    # lw $a0, 0($t3)
    move $a0, $ra
    syscall

    li $v0, 4
    la $a0, EOL
    syscall

    jr $ra