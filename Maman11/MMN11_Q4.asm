# Author: Omer Kvartler
# Course: Computer Design
# Assignment: Maman11 - Q4

.data
input_prompt:   .asciiz "Enter a string of octal pairs separated by $ (max 30 chars): "
error_message:  .asciiz "Wrong input\n"
convert_prompt: .asciiz "\nConverted values in decimal:\n"
sort_prompt:    .asciiz "\nSorted array in decimal:\n"
stringocta:     .space 31   # Array to store input string
NUM:            .space 10   # Array to store converted decimal values
sortarray:      .space 10   # Array to store sorted values
eos:	      .asciiz "\n"
separator:      .asciiz " "

.text
.globl main
main:
    # Prompt user for input
    li $v0, 4
    la $a0, input_prompt
    syscall
    
input_loop:
    # Read input string
    li $v0, 8
    la $a0, stringocta
    li $a1, 31
    syscall
    
    # Call is_valid to check input validity
    la $a0, stringocta
    jal is_valid
    beqz $v0, input_loop   # If input is not valid, prompt again
    
main_logic:
    # Convert octal pairs to decimal
    la $a0, stringocta
    la $a1, NUM
    move $a2, $v0
    jal convert
    
    # Print converted values
    move $s0, $v0  # save pair count
    li $v0, 4
    la $a0, convert_prompt
    syscall
    
    move $a0, $s0   # Number of elements to print
    la $a1, NUM
    jal print
    
    # Sort the array
    la $a0, sortarray
    la $a1, NUM  
    move $a2, $s0
    jal sort
    
    # Print sorted array
    li $v0, 4
    la $a0, sort_prompt
    syscall
    
    move $a0, $s0  # Number of elements to print
    la $a1, sortarray
    jal print
    
    # Exit
    li $v0, 10
    syscall

# Procedure to check input validity
# $a0: address of stringocta
is_valid:
    li $v0, 0       # Invalid input flag
    li $t0, 0       # Counter for pairs
    
valid_loop:
    lb $t1, ($a0)   # Load first character
    lb $t2, 1($a0)	# Load second character
    lb $t3, 2($a0)	# Load third character//seperator
    
    # Check if first and second characters are digits between 0 and 7
    li	$t5, 48     # ASCII code for '0'
    li    $t6, 55     # ASCII code for '7'
    blt   $t1, $t5, invalid
    bgt   $t2, $t6, invalid
    blt   $t2, $t5, invalid
    bgt   $t2, $t6, invalid
    
    # Check if third character is a EOS or dollar sign
    li	$t7, 36
    bne   $t3, $t7, invalid
    
    # checks the if it is the end of the string
    lb  $t3, 3($a0)
    li  $t7, '\n'
    beq $t3, $t7, valid_end
    beq $t3, $zero, valid_end
    

next_iteration:
    addi $v0, $v0, 1
    addi $a0, $a0, 3 # Move to the next set of characters  	
    jal  valid_loop
    
valid_end:
    addi    $v0, $v0, 1
    jal	  main_logic

invalid:
    li $v0, 0       # Set return value to 0 for invalid input
    la $a0, error_message
    li $v0, 4
    syscall
    j main

# Procedure to convert octal pairs to decimal
# $a0: address of stringocta
# $a1: address of num
# $a2: number of pairs
convert:
    li $t0, 0       # Loop counter
    
convert_loop:
    bge $t0, $a2, convert_end
    
    lb $t1, ($a0)   # Load first character
    lb $t2, 1($a0)  # Load second character
    
    sub $t1, $t1, 48    # Convert ASCII digit to integer
    sub $t2, $t2, 48
    
    sll $t1, $t1, 3     # Shift left by 3 bits (multiply by 8)
    
    add $t3, $t1, $t2   # Sum the two digits
    
    sb $t3, ($a1)   # Store the result in NUM
    
    addi $a0, $a0, 3    # Move to next pair
    addi $a1, $a1, 1    # Move to next location in NUM
    
    addi $t0, $t0, 1    # Increment loop counter
    j convert_loop
    
convert_end:
    jr $ra

# Procedure to print an array
# $a0: number of elements to print
# $a1: address of array
print:
    li $v0, 1       # Print integer sys call
    li $t2, 0	# Print Counter
    move $t3, $a0 # save $a0 to temp $t3
print_loop:
    beq $t2, $t3, print_end
    
    li $a0, 32  # 32 ascii == " "
    li $v0, 11  # syscall number for printing character
    syscall
    
    lbu  $a0, ($a1)  # Load unsigned byte value from array
    li   $v0, 1
    syscall
 
    addi $a1, $a1, 1    # Move to next location in array
    addi $t2, $t2, 1   # add to loop counter
    j print_loop
    
print_end:
    jr $ra

#Procedure to sort an array in ascending order
# $a0 = sortarray
# $a1 = NUM array
# $a2 = number of pairs
sort:
    li $t0, 0
    
# Phase 1: Initialize the new sorted array by copying values from the input array 
copy_array:
    bge $t0, $a2, begin_sort     # while counter not equal to num of pairs (a2)
    add $t3, $a1, $t0            
    lbu $t4, ($t3)               
    add $t5, $a0, $t0            
    sb $t4, ($t5)               
    addi $t0, $t0, 1
    j copy_array

# Phase 2: Perform bubble sort on the sorted array
begin_sort:
    li $t0, 0

outer_loop:
    bge $t0, $a2, end_sort       # looping the array by it's length (a2)
    li $t1, 0                    # Initialize index for inner loop
    li $t2, 0                    # Flag to indicate if any swaps occurred
    sub $t3, $a2, $t0            
    addi $t3, $t3, -1

inner_loop:
    bge $t1, $t3, increment_outer
    
    # Get Addresses
    add $t4, $a0, $t1            # get address for sortarray[$t1]
    addi $t5, $t4, 1             # get address for sortarray[$t1 + 1]
    # Load Values
    lbu $t6, ($t4)
    lbu $t7, ($t5)
    
    swap:
    	ble $t6, $t7, inner_continue # if no need to swap
    	sb $t6, ($t5)                # sortarray[$t1+1] = sortarray[$t1]
    	sb $t7, ($t4)                # sortarray[$t1] = sortarray[$t1+1]
    	addi $t2, $t2, 1
    
    inner_continue:
          addi $t1, $t1, 1          # increment $t1
          j inner_loop

increment_outer:
    beqz $t2, end_sort           # if no swaps occurred
    addi $t0, $t0, 1             # $t0++
    j outer_loop

end_sort:
    jr $ra