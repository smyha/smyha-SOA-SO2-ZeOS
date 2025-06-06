#include<asm.h>

# ECX and EBX which will be modified by sysexit 
#define SAVE_REG \
    pushl %ecx;\
    pushl %edx;

#define RESTORE_REG \
    popl %edx;\
    popl %ecx;\

# ------------------------- FAST SYSTEM CALL WRAPPERS ------------------------- 

/* ENTRY(write) - FAST System call wrapper for write
 * int write (int fd, char * buffer, int size);
 * Parameters:
 *   - fd (8(%esp)): File descriptor
 *   - buffer (12(%esp)): Pointer to data to write
 *   - count (16(%esp)): Number of bytes to write
 * Returns:
 *   - Number of bytes written or error code
*/
ENTRY(write)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $4, %eax        # System call number for write (4) 
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here
    pushl %ebx 

    movl 8(%ebp), %edx   # First param: fd -> edx 
    movl 12(%ebp), %ecx  # Second param: buffer -> ecx 
    movl 16(%ebp), %ebx  # Third param: size -> ebx 

    SAVE_REG        

    # Store return addres write_return 
    pushl $write_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt 

write_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG
    popl %ebx

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge write_end        # If positive or zero, return as is 

write_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error             

write_end:
    movl %ebp, %esp      # Restore stack pointer  esp = ebp
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller 

/** ENTRY(gettime) - System call wrapper for gettime
 *  int gettime() - Returns the current time in seconds
 *  Return: 
 *      int - The current time in seconds
 */
ENTRY(gettime)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $10, %eax        # System call number for gettime (10)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    # No arguments to pass

    # Store return addres gettime_return 
    pushl $gettime_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt 

gettime_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

gettime_end:
    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller 

/** ENTRY(getpid) - System call wrapper for getpid 
 *  int getpid() - Returns the process ID of the current process
 *  Return: 
 *      int - The process ID of the current process
 */
ENTRY(getpid)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $20, %eax        # System call number for getpid (20)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    # No arguments to pass

    # Store return addres getpid_return 
    pushl $getpid_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt

getpid_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge getpid_end        # If positive or zero, return as is

getpid_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error        

getpid_end:
    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller


/** ENTRY(fork) - System call wrapper for fork
 *  int fork() - Creates a new process by duplicating the calling process
 *  Return: 
 *      int - The process ID of the child process in the parent, 0 in the child, -1 on error
 */
ENTRY(fork)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $2, %eax        # System call number for fork (2)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    # No arguments to pass

    # Store return addres fork_return 
    pushl $fork_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt

fork_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge fork_end        # If positive or zero, return as is

fork_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error        

fork_end:
    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller


/** ENTRY(exit) - System call wrapper for exit
 *  void exit(void) - Terminates the calling process with the given status
 */
ENTRY(exit)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $1, %eax        # System call number for exit (1)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    # Store return addres exit_return 
    pushl $exit_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt

exit_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

    # ! No need to check for error as exit never returns

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

/** ENTRY(block) - System call wrapper for block
 *  void block(void) - Blocks the calling process until it is unblocked
 */
ENTRY(block)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $12, %eax        # System call number for block (12)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    # No arguments to pass

    # Store return addres block_return 
    pushl $block_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt

block_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

    # ! No need to check for error as block never returns

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

/** ENTRY(unblock) - System call wrapper for unblock
    * int unblock(int pid) - Unblocks the process with the given process ID
    * Parameters:
    *   - pid (8(%esp)): Process ID of the process to unblock
    * Returns:
    *   - 0 on success, -1 on error
*/
ENTRY(unblock)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    movl $13, %eax        # System call number for unblock (13)
    
    # ! Follow the System V ABI contract 
    # Save registers that will be used here 
    SAVE_REG        

    movl 8(%ebp), %edx   # First param: pid -> edx 

    # Store return addres unblock_return 
    pushl $unblock_return

    # Create fake dynamic link 
    pushl %ebp
    movl %esp, %ebp

    SYSENTER            # Generate FAST system call interrupt

unblock_return:
    # Clean up the stack 
    popl %ebp
    addl $4, %esp

    # Restore saved registers 
    RESTORE_REG

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge unblock_end        # If positive or zero, return as is

unblock_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error

unblock_end:
    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

# ------------------------- SYSTEM CALL WRAPPERS ------------------------- 

ENTRY(write_int)
    push %ebp            # Save old ebp 
    mov %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save registers that will be used here 
    SAVE_REG   

    movl 8(%ebp), %edx   # First param: fd -> edx 
    movl 12(%ebp), %ecx  # Second param: buffer -> ecx 
    movl 16(%ebp), %ebx  # Third param: size -> ebx 

    movl $4, %eax        # System call number for write (4)
    int $0x80            # Generate system call interrupt 

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge writeINT_end        # If positive or zero, return as is 

writeINT_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error 
writeINT_end:
    # Restore saved registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller 

ENTRY(gettime_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    # No arguments to pass 

    movl $10, %eax        # System call number for gettime (10) 
    int $0x80
    
    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge gettimeINT_end   # If positive or zero, return as is 
 
gettimeINT_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error   

gettimeINT_end:
    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller 

ENTRY(getpid_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    # No arguments to pass 

    movl $20, %eax        # System call number for getpid (20) 
    int $0x80

getpidINT_end:
    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

ENTRY(fork_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    # No arguments to pass 

    movl $2, %eax        # System call number for fork (2) 
    int $0x80

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge forkINT_end     # If positive or zero, return as is

forkINT_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error

forkINT_end:
    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

ENTRY(exit_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    movl $1, %eax        # System call number for exit (1) 
    int $0x80

    # ! No need to check for error as exit never returns

    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

# 
ENTRY(block_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    # No arguments to pass 

    movl $12, %eax        # System call number for block (12) 
    int $0x80

    # ! No need to check for error as block 

    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller

# 
ENTRY(unblock_int)
    pushl %ebp            # Save old ebp 
    movl %esp, %ebp       # Set up new stack frame 

    # ! Follow the ABI contract 
    # Save the registers 
    SAVE_REG

    movl 8(%ebp), %edx   # First param: pid -> edx 

    movl $13, %eax        # System call number for unblock (13) 
    int $0x80

    # Check if it returns an error (negative value) 
    cmpl $0, %eax        # Compare result with 0 
    jge unblockINT_end   # If positive or zero, return as is

unblockINT_error:
    # Handle error case 
    negl %eax            # Convert to positive value 
    movl %eax, errno     # Store error code in errno 
    movl $-1, %eax       # Return -1 to indicate error

unblockINT_end:
    # Restore the registers 
    RESTORE_REG

    movl %ebp, %esp      # Restore stack pointer 
    popl %ebp            # Restore old ebp 
    ret                  # Return to caller