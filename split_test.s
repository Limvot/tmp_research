/***********************************
 SELECT and PROJECT library file- SIMD - Nathan Braswell
 ***********************************/

 /*
  * Only SIMD on copys right now
  */

 .perm x


/*stack = r15 for now*/
 
/*typedef struct {
    void** data;
    int rows, columns;
} RelationalTable; */

 .global
entry:
            ldi %r7, #0                             /* int i = 0*/
            ldi %r10, #4
            ldi %r6, #4
/* WE GOING SIMD */
            ldi %r14, #2                            /* num lanes */
            addi %r13, %r14, #0                     /* 0-index lane indicator */
simd_loop:  
            subi %r13, %r13, #1                     /* decrement */
            iszero @p0, %r13                         /* if we're zero, time to jump into it! */
    @p0 ?   jalis %r9, %r14, loop_i2                /* we don't care about the link */
            clone %r13                              /* simd clone */
            jmpi simd_loop                          /* continue loop */

loop_i2:    addi %r8,%r13, #0                       /* int j = lane_indicator */

loop_j2:    
/* Since SIMD, add a pre-check to the loop */
            sub %r5, %r8, %r10                      /* j - newtable.columns*/
            isneg @p0, %r5                          /* j <  newtable.columns */
            notp @p0, @p0                           /*  j >= newTable.columns */
    @p0 ?   split
    @p0 ?   jmpi after_j                             /* j == newtable.columns => end for loop*/


            add %r8, %r8, %r14                      /* j += num_lanes*/
            jmpi loop_j2                            /* back to check block */
after_j:
            join 

            addi %r7, %r7, #1                       /* i++ */
            sub %r5, %r7, %r6                       /* i - 2*/
            subi %r5, %r5, #1                       /* i - 2 - 1*/
            isneg @p0, %r5                           /* i - 2 <= 0*/
    @p0 ?   jmpi loop_i2                            /* i < newtable.rows => continue for loop*/
/* SIMD END */
            ldi %r13, end                           /* end SIMD */
            jmprt %r13                              /* back to a single lane */

end:
    halt



