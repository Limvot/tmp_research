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
createDemoRelationalTable:
            subi %r15, %r15, (__WORD*3);            /* Push 3 words onto stack (like the above struct)*/
            ldi %r0, #8                             /* 8*/
            st %r0, %r15, (1*__WORD);               /* table.rows = 8*/
            st %r0, %r15, (2*__WORD);               /* table.columns = 8*/

            subi %r15, %r15, __WORD                 /* push r5 onto stack*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

            ldi %r0, (8*8*__WORD);                  /* r0 = rows*columns*sizeof(void*)*/
            jali %r5, malloc                        /* r0 = malloc(rows*columns*sizeof(void*))*/

            st %r0, %r15, __WORD                    /* table.data = malloc(rows*columns*sizeof(void*))*/

            addi %r4, %r0, #0                       /* r4 = table.data*/

            ldi %r8, #7                             /* int i = 7*/
 loop_i1:   ldi %r9, #7                             /* int j = 7*/
 loop_j1:   ldi %r0, __WORD                         /* sizeof(int)*/
            jali %r5, malloc                        /* malloc(sizeof(int))*/
            muli %r1, %r8, #8                       /* i*table.columns*/
            add %r1, %r1, %r9                       /* i*table.columns + j*/

            st %r1, %r0, #0                         /* *dat = i*table.columns + j*/
            muli %r1, %r1, __WORD                   /* handle the word = 8 bytes for ptr arithmatic */


            add %r1, %r4, %r1                       /* r1 = table.data + i*table.columns + j*/
            st %r0, %r1, #0                         /* *(table.data + i*table.columns + j) = dat*/
            

            subi %r9, %r9, #1                       /* j--;*/
            isneg @p0, %r9                          /* j >= 0*/
            notp @p0, @p0
    @p0 ?   jmpi loop_j1                            /* j >= 0 => continue for loop*/

            subi %r8, %r8, #1                       /* i--;*/
            isneg @p0, %r8                          /* i >= 0*/
            notp @p0, @p0
    @p0 ?   jmpi loop_i1                            /* i >= 0 => continue for loop*/
    


            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/

                                                    /* so we can get back to it after the first select*/
            jmpr %r5                                /* return*/


/* RelationalTable project(RelationalTable table, int arrSize, int* columnsToSelect,*/
/*                         void* (copyFunc)(void* toCopy))*/
 .global
PROJECT:
            addi %r3, %r15, #0                      /* r3 = old table on stack*/
            subi %r15, %r15, (__WORD*3);            /* Push 3 words onto stack for table struct*/
            addi %r4, %r15, #0                      /* r4 = new table on stack*/

            subi %r15, %r15, (__WORD*1);            /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

            ld %r6, %r3, (1*__WORD);                /* oldTable.rows */
            st %r6, %r4, (1*__WORD);                /* newTable.rows = oldTable.rows*/
            st %r0, %r4, (2*__WORD);                /* newTable.columns = arrSize*/
            addi %r10, %r0, #0                      /* save newTable.columns for j loop later */
            

            ldi %r9, saveReg                          /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, (0*__WORD);                  /* and end, but later...*/
            st %r1, %r9, (1*__WORD);
            st %r2, %r9, (2*__WORD);
            st %r3, %r9, (3*__WORD);
            st %r4, %r9, (4*__WORD);
            st %r6, %r9, (6*__WORD);
            st %r7, %r9, (7*__WORD);

            mul %r0, %r6, %r0                       /* newTable.rows * newTable.columns*/
            muli %r0, %r0, __WORD                   /* newTable.rows * newTable.columns * __WORD*/
            jali %r5, malloc                        /* malloc(newTable.rows * newTable.columns * sizeof(void*))*/
            addi %r5, %r0, #0                       /* r5 = malloc(newTable.rows * newTable.columns * sizeof(void*))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, (0*__WORD);
            ld %r1, %r9, (1*__WORD);
            ld %r2, %r9, (2*__WORD);
            ld %r3, %r9, (3*__WORD);
            ld %r4, %r9, (4*__WORD);
            ld %r6, %r9, (6*__WORD);
            ld %r7, %r9, (7*__WORD);

            st %r5, %r4, (0*__WORD);                /* newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));*/
            addi %r11, %r5, #0                      /* save for loop below */

            addi %r12, %r0, #0                      /* ditto */


            ldi %r7, #0                             /* int i = 0*/
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
            isneg @p0, %r5                          /* j < newtable.columns */
            notp @p0, @p0                           /* j >= newtable.columns */
    @p0 ?   split
    @p0 ?   jmpi after_j                             /* j >= newtable.columns => end for loop*/


            mul %r0, %r12, %r7                      /* i * newtable.columns*/
            add %r0, %r0, %r8                       /* i * newtable.columns + j*/
            muli %r0, %r0, __WORD                   /* ptr arithmatic */
            add %r0, %r0, %r11                      /* newtable.data + i * table.columns + j*/


            addi %r9, %r13, #1
            muli %r9, %r9, (9*__WORD);             /* stack offset based on current lane
            sub %r15, %r15, %r9                     /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r15, (0*__WORD);                /* and end, but later...*/
            st %r1, %r15, (1*__WORD);
            st %r2, %r15, (2*__WORD);
            st %r3, %r15, (3*__WORD);
            st %r4, %r15, (4*__WORD);
            st %r6, %r15, (6*__WORD);
            st %r7, %r15, (7*__WORD);
            st %r8, %r15, (8*__WORD);


            ld %r6, %r3, (2*__WORD);                /* r6 = oldtable.columns*/
            mul %r5, %r7, %r6                       /* i * oldtable.columns*/
            muli %r6, %r8, __WORD                   /* ptr arith */
            add %r6, %r1, %r6                       /* r6 = columnstoselect+j*/
            ld %r6, %r6, #0                         /* r6 = *(columnstoselect+j)*/
            add %r5, %r5, %r6                       /* r5 = i * oldtable.columns + *(columnstoselect+j)*/
            muli %r5, %r5, __WORD                   /* ptr arith */
            ld %r6, %r3, (0*__WORD);                /* r6 = oldtable.data*/
            add %r6, %r6, %r5                       /* r5 = oldtable.data + i * oldtable.columns + *(columnstoselect+j)*/
            ld %r0, %r6, #0                         /* r5 = *(oldtable.data + i * oldtable.columns + *(columnstoselect+j))*/
            jalr %r5, %r2                           /* copyFunc(*(oldtable.data + i * oldtable.columns + *(columnstoselect+j)))*/
            addi %r5, %r0, #0                       /* r5 = copyFunc(...) */

            ld %r0, %r15, (0*__WORD);
            ld %r1, %r15, (1*__WORD);
            ld %r2, %r15, (2*__WORD);
            ld %r3, %r15, (3*__WORD);
            ld %r4, %r15, (4*__WORD);
            ld %r6, %r15, (6*__WORD);
            ld %r7, %r15, (7*__WORD);
            ld %r8, %r15, (8*__WORD);

            addi %r9, %r13, #1
            muli %r9, %r9, (9*__WORD);             /* stack offset based on current lane
            add %r15, %r15, %r9                     /* revert stack to previous position */
            
            st %r5, %r0, #0                         /* newTable.data[i*newTable.columns + j] = copyFunc(table.data[i * table.columns + columnsToSelect[j]]); */
            add %r8, %r8, %r14                      /* j += num_lanes*/
            jmpi loop_j2                            /* back to check block */
after_j:
            join
            

            addi %r7, %r7, #1                       /* i++ */
            sub %r5, %r7, %r6                       /* i - newtable.rows*/
            subi %r5, %r5, #1                       /* i - newtable.rows -1 */
            isneg @p0, %r5                           /* i <= newtable.rows */
   /* @p0 ?   split */
    @p0 ?   jmpi loop_i2                            /* i < newtable.rows => continue for loop*/
        /*    join */
/* SIMD END */
            ldi %r13, end                           /* end SIMD */
            jmprt %r13                              /* back to a single lane */

end:
            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/


/* RelationalTable select(RelationalTable table, int columnA, int columnB,*/
/*                        int (*compFunc)(void* a, void* b),*/
/*                        void* (copyFunc)(void* toCopy))*/
 .global
SELECT:
            addi %r4, %r15, #0                      /* r4 = old table on stack*/
            subi %r15, %r15, (__WORD*3);            /* Push 3 words onto stack for table struct*/
            addi %r6, %r15, #0                      /* r6 = new table on stack*/

            subi %r15, %r15, (__WORD*1);            /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

/* void*** toCopy*/
            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, (0*__WORD);                /* and end, but later...*/
            st %r1, %r9, (1*__WORD);
            st %r2, %r9, (2*__WORD);
            st %r3, %r9, (3*__WORD);
            st %r4, %r9, (4*__WORD);
            st %r6, %r9, (6*__WORD);
            st %r7, %r9, (7*__WORD);

            ld %r0, %r4, (1*__WORD);                /* r0 = table.rows*/
            muli %r0, %r0, __WORD                   /* table.rows * __WORD*/
            jali %r5, malloc                        /* malloc(table.rows * sizeof(void***))*/
            addi %r5, %r0, #0                       /* r5 = malloc(table.rows * sizeof(void***))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, (0*__WORD);
            ld %r1, %r9, (1*__WORD);
            ld %r2, %r9, (2*__WORD);
            ld %r3, %r9, (3*__WORD);
            ld %r4, %r9, (4*__WORD);
            ld %r6, %r9, (6*__WORD);
            ld %r7, %r9, (7*__WORD);

            addi %r8, %r5, #0                       /* toCopy = malloc(table.rows * sizeof(void***))*/
            ldi %r11, #0                            /* int index = 0*/
            ldi %r7, #0                             /* int i = 0*/

loop_i3:     
            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, (0*__WORD);                /* and end, but later...*/
            st %r1, %r9, (1*__WORD);
            st %r2, %r9, (2*__WORD);
            st %r3, %r9, (3*__WORD);
            st %r4, %r9, (4*__WORD);
            st %r6, %r9, (6*__WORD);
            st %r7, %r9, (7*__WORD);
            st %r8, %r9, (8*__WORD);

            ld  %r9, %r4, (2*__WORD);               /* r9 = table.columns*/
            mul %r9, %r7, %r9                       /* i * table.columns*/
            ld %r10, %r4, (0*__WORD);               /* table.data*/
            add %r0, %r9, %r0                       /* i * table.columns + columnA*/
            muli %r0, %r0, __WORD                   /* ptr arithmatic */
            add %r0, %r0, %r10                      /* i * table.columns + columnA + table.data*/
            ld %r0, %r0, (0*__WORD);                /* table.data[i * table.columns + columnA]*/
            add %r1, %r9, %r1                       /* i * table.columns + columnB*/
            muli %r1, %r1, __WORD                   /* ptr arithmatic */
            add %r1, %r1, %r10                      /* i * table.columns + columnB + table.data*/
            ld %r1, %r1, (0*__WORD);                /* table.data[i * table.columns + columnB]*/

            muli %r9, %r9, __WORD                   /* ptr arithmatic */
            add %r12, %r9, %r10                     /* r12 = i * table.columns + table.data*/


            jalr %r5, %r2                           /* compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB])*/
            addi %r5, %r0, #0                       /* r5 = compFunc*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, (0*__WORD);
            ld %r1, %r9, (1*__WORD);
            ld %r2, %r9, (2*__WORD);
            ld %r3, %r9, (3*__WORD);
            ld %r4, %r9, (4*__WORD);
            ld %r6, %r9, (6*__WORD);
            ld %r7, %r9, (7*__WORD);
            ld %r8, %r9, (8*__WORD);

            rtop @p0, %r5                           /* if (compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB]))*/
    @p0  ?  muli %r10, %r11, __WORD                 /* r10 = take care of word size so that we can*/
    @p0  ?  add %r10, %r8, %r10                     /* r10 = toCopy + index make this pointer arithmatic work*/
    @p0  ?  st %r12, %r10, (0*__WORD);              /* toCopy[index] = table.data + i*table.columns */
    @p0  ?  addi %r11, %r11, #1                     /* index++*/


            addi %r7, %r7, #1                       /* i++*/
            ld %r5, %r4, (1*__WORD);                /* r5 = table.rows*/
            sub %r5, %r7, %r5                       /* i - table.rows*/
            rtop @p0, %r5                           /* i - table.rows != 0*/
    @p0  ?  jmpi loop_i3                            /* i < table.rows => continue for loop*/


/* Relationaltable newtable*/
            st %r11, %r6, (1*__WORD);               /* newTable.rows = index*/
            ld %r5, %r4, (2*__WORD);                /* oldTable.columns */
            st %r5, %r6, (2*__WORD);                /* newTable.columns = oldTable.columns*/
            

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, (0*__WORD);                /* and end, but later...*/
            st %r1, %r9, (1*__WORD);
            st %r2, %r9, (2*__WORD);
            st %r3, %r9, (3*__WORD);
            st %r4, %r9, (4*__WORD);
            st %r6, %r9, (6*__WORD);
            st %r7, %r9, (7*__WORD);

            ld %r0, %r6, (1*__WORD);                /* r0 = newTable.rows*/
            mul %r0, %r0, %r5                       /* r0 = newTable.rows * newtable.columns*/
            muli %r0, %r0, __WORD                   /* newTable.rows * newtable.columns * __WORD*/
            jali %r5, malloc                        /* malloc(newTable.rows * newtable.columns * sizeof(void*))*/
            addi %r5, %r0, #0                       /* r5 = malloc(newTable.rows * newtable.columns * sizeof(void*))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, (0*__WORD);
            ld %r1, %r9, (1*__WORD);
            ld %r2, %r9, (2*__WORD);
            ld %r3, %r9, (3*__WORD);
            ld %r4, %r9, (4*__WORD);
            ld %r6, %r9, (6*__WORD);
            ld %r7, %r9, (7*__WORD);

            st %r5, %r6, (0*__WORD);                /* newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));*/


            addi %r1, %r8, #0                       /* r1 = toCopy*/
            ldi %r7, #0                             /* int i = 0*/
loop_i4:    ldi %r8, #0                             /* int j = 0*/
loop_j4:

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, (0*__WORD);                /* and end, but later...*/
            st %r1, %r9, (1*__WORD);
            st %r2, %r9, (2*__WORD);
            st %r3, %r9, (3*__WORD);
            st %r4, %r9, (4*__WORD);
            st %r6, %r9, (6*__WORD);
            st %r7, %r9, (7*__WORD);
            st %r8, %r9, (8*__WORD);

            muli %r0, %r7, __WORD
            add %r0, %r1, %r0                       /* toCopy + i*/
            ld %r0, %r0, #0                         /* toCopy[i]*/
            muli %r2, %r8, __WORD
            add %r0, %r0, %r2                       /* toCopy[i] + j*/
            ld %r0, %r0, #0                         /* toCopy[i][j]*/




            jalr %r5, %r3                           /* copyFunc(toCopy[i][j])*/


            addi %r5, %r0, #0                       /* r5 = copyFunc(toCopy[i][j])*/


            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, (0*__WORD);
            ld %r1, %r9, (1*__WORD);
            ld %r2, %r9, (2*__WORD);
            ld %r3, %r9, (3*__WORD);
            ld %r4, %r9, (4*__WORD);
            ld %r6, %r9, (6*__WORD);
            ld %r7, %r9, (7*__WORD);
            ld %r8, %r9, (8*__WORD);


            ld %r0, %r6, (2*__WORD);                /* newTable.columns*/
            mul %r0, %r0, %r7                       /* i*newTable.columns*/
            add %r0, %r0, %r8                       /* i*newTable.columns + j*/
            muli %r0, %r0, __WORD                   /* pointer arithmatic */
            ld %r9, %r6, (0*__WORD);                /* newTable.data*/
            add %r0, %r0, %r9                       /* newTable.data + i*newTable.columns + j*/
            st %r5, %r0, #0                         /* newTable.data[i*newTable.columns + j] = copyFunc(toCopy[i][j])*/

            addi %r8, %r8, #1                       /* j++*/
            ld %r0, %r6, (2*__WORD);                /* newTable.columns*/
            sub %r5, %r8, %r0                       /* j - newTable.columns*/
            rtop @p0, %r5                           /* j - newTable.columns != 0*/
    @p0  ?  jmpi loop_j4                            /* j < newTable.columns => continue for loop*/


            addi %r7, %r7, #1                       /* i++*/
            ld %r0, %r6, (1*__WORD);                /* newTable.rows*/
            sub %r5, %r7, %r0                       /* i - newTable.rows*/
            rtop @p0, %r5                           /* i - newTable.rows != 0*/
    @p0  ?  jmpi loop_i4                            /* i < newTable.rows => continue for loop*/


            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/



/*void printTable(RelationalTable table, void(*printFunc)(void* toPrint))*/
 .global
printTable: ld %r3, %r15, (__WORD*1);               /* r3 = table.rows*/
            ld %r4, %r15, (__WORD*2);               /* r4 = table.columns*/
            ld %r6, %r15, #0                        /* r6 = table.data*/


            addi %r7, %r0, #0                       /* r7 = printFunc*/
            subi %r15, %r15, (__WORD*1);            /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

            ldi %r1, #0                             /* int i = 0*/
loop_i5:    ldi %r2, #0                             /* int j = 0*/
loop_j5:    mul %r0, %r1, %r4                       /* i * table.columns*/
            add %r0, %r0, %r2                       /* i * table.columns + j*/
            muli %r0, %r0, __WORD
            add %r0, %r0, %r6                       /* table.data + i * table.columns + j*/
            ld %r0, %r0, #0                         /* *(table.data + i * table.columns + j)*/


            ldi %r8, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r8, (0*__WORD);                         /* and end, but later...*/
            st %r1, %r8, (1*__WORD);
            st %r2, %r8, (2*__WORD);
            st %r3, %r8, (3*__WORD);
            st %r4, %r8, (4*__WORD);
            st %r5, %r8, (5*__WORD);
            st %r6, %r8, (6*__WORD);
            st %r7, %r8, (7*__WORD);
            
            jalr %r5, %r7                           /* printFunc(*(table.data + i * table.columns + j))*/

            ldi %r8, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r8, (0*__WORD);
            ld %r1, %r8, (1*__WORD);
            ld %r2, %r8, (2*__WORD);
            ld %r3, %r8, (3*__WORD);
            ld %r4, %r8, (4*__WORD);
            ld %r5, %r8, (5*__WORD);
            ld %r6, %r8, (6*__WORD);
            ld %r7, %r8, (7*__WORD);


            addi %r2, %r2, #1                       /* j++*/
            sub %r8, %r2, %r4                       /* j - table.columns*/
            rtop @p0, %r8                           /* j - table.columns != 0*/
    @p0  ?  jmpi loop_j5                            /* j < table.columns => continue for loop*/

            addi %r1, %r1, #1                       /* i++*/
            sub %r8, %r1, %r3                       /* i - table.rows*/
            rtop @p0, %r8                           /* i - table.rows != 0*/
    @p0  ?  jmpi loop_i5                            /* i < table.rows => continue for loop*/

            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/



/* void* malloc(int num)*/
 .global
malloc:         ldi %r1, heap_cnt                   /* r1 = &heap_cnt*/
                ld %r2, %r1, #0                     /* r2 = heap_cnt*/
                addi %r3, %r2, heap                 /* r3 = heap + heap_cnt */
                add %r2, %r2, %r0                   /* r2 = heap_cnt + size*/
                st %r2, %r1, #0                     /* heap_cnt = heap_cnt + size */
                addi %r0, %r3, #0                   /* return = heap + heap_cnt */
                jmpr %r5                            /* actually return*/

 .perm rw
projectColumns: .word 0x1
                .word 0x3
                .word 0x5

saveReg:   .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0
                .word 0x0

 heap_cnt:      .word 0x0
 heap: .space   1000000
/* stack:         .word 0xface
 heap:          .word 0xfeef
 */
