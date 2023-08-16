# Author: Omer Kvartler
# Course: Computer Design
# Assignment: Maman11 - Q3

.data
input:      .space 31       # Space for input string (max 30 characters + null terminator)
output:     .space 31       # Space for output string (max 30 characters + null terminator)
newline:    .asciiz "\n"    # Newline character

.text
.globl main
main:
    # Prompt user for input string
    li $v0, 8                # syscall 8: read string
    la $a0, input            # Load address of input buffer
    li $a1, 31               # Maximum number of characters to read (including null terminator)
    syscall

    # Copy input string to output string for manipulation
    move $t0, $a0             # Save address of input string
    la $t1, output            # Load address of output buffer

loop_copy:
    lb $t2, ($t0)            # Load a byte from input string
    beqz $t2, display        # If null terminator is encountered, move to display

    sb $t2, ($t1)            # Store the byte in the output string
    addi $t0, $t0, 1        # Increment input string pointer
    addi $t1, $t1, 1        # Increment output string pointer
    j loop_copy

display:
    sb $zero, ($t1)           # Null-terminate the output string

    # Display staggered form of the string
    la $t3, output            # Load address of output string
    li $t4, 0                 # Counter for string length

    # Find the length of the string
length_loop:
    lb $t5, ($t3)             # Load a byte from the output string
    beqz $t5, break_length   # If null terminator is encountered, exit length loop

    addi $t3, $t3, 1        # Increment output string pointer
    addi $t4, $t4, 1        # Increment string length counter
    j length_loop

break_length:
    beqz $t4, exit_display   # If string length is zero, exit

display_lines_loop:
    # Display the string
    li $v0, 4                # syscall 4: print string
    la $a0, output           # Load address of the string to print
    syscall

    # Print newline character
    li $v0, 11               # syscall 11: print character
    li $a0, 10               # Load ASCII code for newline character
    syscall

    # Decrement string length counter
    subi $t4, $t4, 1

    # Remove character from the end of the string
    la $t3, output           # Reset output string pointer
    add $t3, $t3, $t4        # Move to the position to remove the character
    sb $zero, ($t3)          # add null to the string at this position

    # Check if the end of the string is reached
    bnez $t4, display_lines_loop

exit_display:
    li $v0, 10               # syscall 10: exit
    syscall
