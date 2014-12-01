/***********************************
 SELECT and PROJECT library file - Nathan Braswell
 ***********************************/

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
            st %r0, %r15, (1*__WORD);                        /* table.rows = 8*/
            st %r0, %r15, (2*__WORD);                        /* table.columns = 8*/

            subi %r15, %r15, __WORD                 /* push r5 onto stack*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

            ldi %r0, (8*8*__WORD);                  /* r0 = rows*columns*sizeof(void*)*/
            jali %r5, malloc                        /* r0 = malloc(rows*columns*sizeof(void*))*/

            st %r0, %r15, __WORD                    /* table.data = malloc(rows*columns*sizeof(void*))*/

            addi %r4, %r0, #0                       /* r4 = table.data*/

             ldi %r8, #8                             /* int i = 8*/
 loop_i1:    ldi %r9, #8                            /* int j = 8*/
 loop_j1:    ldi %r0, __WORD                        /* sizeof(int)*/
            jali %r5, malloc                        /* malloc(sizeof(int))*/
            muli %r1, %r8, #8                       /* i*table.columns*/
            add %r1, %r1, %r9                       /* i*table.columns + j*/
            st %r1, %r0, #0                         /* *dat = i*table.columns + j*/
            add %r1, %r4, %r1                       /* r1 = table.data + i*table.columns + j*/
            st %r0, %r1, #0                         /* *(table.data + i*table.columns + j) = dat*/

            subi %r9, %r9, #1                       /* j--;*/
            rtop @p0, %r9                           /* j != 0*/
    @p0 ?   jmpi loop_j1                            /* j != 0 => continue for loop*/

            subi %r8, %r8, #1                       /* i--;*/
            rtop @p0, %r8                           /* i != 0*/
    @p0 ?   jmpi loop_i1                            /* i != 0 => continue for loop*/

            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/


/* RelationalTable project(RelationalTable table, int arrSize, int* columnsToSelect,*/
/*                         void* (copyFunc)(void* toCopy))*/
 .global
PROJECT:
            addi %r3, %r15, #0                      /* r3 = old table on stack*/
            subi %r15, %r15, (__WORD*3);               /* Push 3 words onto stack for table struct*/
            addi %r4, %r15, #0                      /* r4 = new table on stack*/

            subi %r15, %r15, (__WORD*1);               /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

            ld %r6, %r3, (1*__WORD);                   /* oldTable.rows */
            st %r6, %r4, (1*__WORD);                   /* newTable.rows = oldTable.rows*/
            st %r0, %r4, (2*__WORD);                   /* newTable.columns = arrSize*/
            

            ldi %r9, saveReg                   /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r6, %r9, #6
            st %r7, %r9, #7

            mul %r0, %r6, __WORD                    /* newTable.rows * newTable.columns*/
            muli %r0, %r0, __WORD                   /* newTable.rows * newTable.columns * __WORD*/
            jali %r5, malloc                        /* malloc(newTable.rows * newTable.columns * sizeof(void*))*/
            addi %r5, %r0, #0                       /* r5 = malloc(newTable.rows * newTable.columns * sizeof(void*))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r6, %r9, #6
            ld %r7, %r9, #7

            st %r5, %r4, (0*__WORD);                   /* newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));*/


            ldi %r7, #0                             /* int i = 0*/
loop_i2:     ldi %r8, #0                             /* int j = 0*/

loop_j2:     mul %r0, %r1, %r4                       /* i * table.columns*/
            addi %r0, %r0, %r2                      /* i * table.columns + j*/
            addi %r0, %r0, %r6                      /* table.data + i * table.columns + j*/
            ld %r0, %r0, #0                         /* *(table.data + i * table.columns + j)*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r5, %r9, #5
            st %r6, %r9, #6
            st %r7, %r9, #7
            st %r8, %r9, #8

            ld %r6, %r3, (2*__WORD);                   /* r6 = oldtable.columns*/
            mul %r5, %r7, %r6                       /* i * oldtable.columns*/
            add %r6, %r1, %r8                       /* r6 = columnstoselect+j*/
            ld %r6, %r6, #0                         /* r6 = *(columnstoselect+j)*/
            add %r5, %r5, %r6                       /* r5 = i * oldtable.columns + *(columnstoselect+j)*/
            ld %r6, %r3, (0*__WORD);                   /* r6 = oldtable.data*/
            add %r6, %r6, %r5                       /* r5 = oldtable.data + i * oldtable.columns + *(columnstoselect+j)*/
            ld %r5, %r6, #0                         /* r5 = *(oldtable.data + i * oldtable.columns + *(columnstoselect+j))*/
            addi %r0, %r5, #0                       /* r0 = r5 (for the function call)*/
            jalr %r5, %r2                           /* copyFunc(*(oldtable.data + i * oldtable.columns + *(columnstoselect+j)))*/


            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r5, %r9, #5
            ld %r6, %r9, #6
            ld %r7, %r9, #7
            ld %r8, %r9, #8


            addi %r8, %r8, #1                       /* j++*/
            sub %r5, %r8, %r4                       /* j - table.columns*/
            rtop @p0, %r5                            /* j - table.columns != 0*/
    @p0 ?   jmpi loop_j2                             /* j < table.columns => continue for loop*/
            addi %r7, %r7, #1                       /* i++*/
            sub %r5, %r7, %r3                       /* i - table.rows*/
            rtop @p0, %r5                            /* i - table.rows != 0*/
    @p0 ?   jmpi loop_i2                             /* i < table.rows => continue for loop*/


            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/


/* RelationalTable select(RelationalTable table, int columnA, int columnB,*/
/*                        int (*compFunc)(void* a, void* b),*/
/*                        void* (copyFunc)(void* toCopy))*/
 .global
SELECT:
            addi %r4, %r15, #0                      /* r4 = old table on stack*/
            subi %r15, %r15, (__WORD*3);               /* Push 3 words onto stack for table struct*/
            addi %r6, %r15, #0                      /* r6 = new table on stack*/

            subi %r15, %r15, (__WORD*1);               /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/

/* void*** toCopy*/
            ldi %r9, saveReg                   /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r6, %r9, #6
            st %r7, %r9, #7

            ld %r0, %r4, (1*__WORD);                   /* r0 = table.rows*/
            muli %r0, %r0, __WORD                   /* table.rows * __WORD*/
            jali %r5, malloc                        /* malloc(table.rows * sizeof(void***))*/
            addi %r5, %r0, #0                       /* r5 = malloc(table.rows * sizeof(void***))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r6, %r9, #6
            ld %r7, %r9, #7

            addi %r8, %r5, #0                       /* toCopy = malloc(table.rows * sizeof(void***))*/
            ldi %r11, #0                            /* int index = 0*/
            ldi %r7, #0                             /* int i = 0*/

loop_i3:     
            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r5, %r9, #5
            st %r6, %r9, #6
            st %r7, %r9, #7
            st %r8, %r9, #8

            ld  %r9, %r4, (2*__WORD);                  /* r9 = table.columns*/
            mul %r9, %r7, %r9                       /* i * table.columns*/
            ld %r10, %r4, (0*__WORD);                  /* table.data*/
            add %r9, %r9, %r10                      /* i * table.columns + table.data*/
            add %r0, %r9, %r0                       /* i * table.columns + table.data + columnA*/
            ld %r0, %r0, (0*__WORD);                   /* table.data[i * table.columns + columnA]*/
            add %r1, %r9, %r1                       /* i * table.columns + table.data + columnB*/
            ld %r1, %r1, (0*__WORD);                   /* table.data[i * table.columns + columnB]*/
            ld %r0, %r0, #0                         /* *(table.data + i * table.columns + j)*/

            jalr %r5, %r2                           /* compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB])*/
            addi %r5, %r0, #0                       /* r5 = compFunc*/
            addi %r12, %r9, #0                      /* r12 = i * table.columns + table.data*/
 
            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r5, %r9, #5
            ld %r6, %r9, #6
            ld %r7, %r9, #7
            ld %r8, %r9, #8

            rtop @p0, %r0                            /* if (compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB]))*/
    @p0  ?  add %r10, %r8, %r11                     /* r10 = toCopy + index*/
    @p0  ?  st %r12, %r10, (0*__WORD);                  /* toCopy[index] = table.data + i*table.columns */
    @p0  ?  addi %r11, %r11, #1                     /* index++*/


            addi %r7, %r7, #1                       /* i++*/
            ld %r5, %r4, (1*__WORD);                   /* r5 = table.rows*/
            sub %r5, %r7, %r5                       /* i - table.rows*/
            rtop @p0, %r5                            /* i - table.rows != 0*/
    @p0  ?  jmpi loop_i3                             /* i < table.rows => continue for loop*/

/* Relationaltable newtable*/
            st %r11, %r6, (1*__WORD);                  /* newTable.rows = index*/
            ld %r5, %r4, (2*__WORD);                   /* oldTable.columns */
            st %r5, %r6, (2*__WORD);                   /* newTable.columns = oldTable.columns*/
            

            ldi %r9, saveReg                   /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r6, %r9, #6
            st %r7, %r9, #7

            ld %r0, %r6, (1*__WORD);                   /* r0 = newTable.rows*/
            mul %r0, %r0, %r5                       /* r0 = newTable.rows * newtable.columns*/
            muli %r0, %r0, __WORD                   /* newTable.rows * newtable.columns * __WORD*/
            jali %r5, malloc                        /* malloc(newTable.rows * newtable.columns * sizeof(void*))*/
            addi %r5, %r0, #0                       /* r5 = malloc(newTable.rows * newtable.columns * sizeof(void*))*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r6, %r9, #6
            ld %r7, %r9, #7

            st %r5, %r6, (0*__WORD);                   /* newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));*/


            addi %r1, %r8, #0                       /* r1 = toCopy*/
            ldi %r7, #0                             /* int i = 0*/
loop_i4:     ldi %r8, #0                             /* int j = 0*/
loop_j4:

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r9, #0                         /* and end, but later...*/
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r5, %r9, #5
            st %r6, %r9, #6
            st %r7, %r9, #7
            st %r8, %r9, #8

            add %r0, %r1, %r7                        /* toCopy + i*/
            ld %r0, %r0, #0                         /* toCopy[i]*/
            add %r0, %r0, %r8                        /* toCopy[i] + j*/
            ld %r0, %r0, #0                         /* toCopy[i][j]*/
            jalr %r5, %r3                           /* copyFunc(toCopy[i][j])*/
            addi %r5, %r0, #0                       /* r5 = copyFunc(toCopy[i][j])*/

            ldi %r9, saveReg                        /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r5, %r9, #5
            ld %r6, %r9, #6
            ld %r7, %r9, #7
            ld %r8, %r9, #8


            ld %r0, %r6, (2*__WORD);                   /* newTable.columns*/
            mul %r0, %r0, %r7                       /* i*newTable.columns*/
            add %r0, %r0, %r8                       /* i*newTable.columns + j*/
            ld %r1, %r6, (0*__WORD);                   /* newTable.data*/
            add %r0, %r0, %r1                       /* newTable.data + i*newTable.columns + j*/
            st %r5, %r0, #0                         /* newTable.data[i*newTable.columns + j] = copyFunc(toCopy[i][j])*/


            addi %r8, %r8, #1                       /* j++*/
            ld %r0, %r6, (2*__WORD);                   /* newTable.columns*/
            sub %r5, %r8, %r0                       /* j - newTable.columns*/
            rtop @p0, %r5                            /* j - newTable.columns != 0*/
    @p0  ?  jmpi loop_j4                             /* j < newTable.columns => continue for loop*/
            addi %r7, %r7, #1                       /* i++*/
            ld %r0, %r6, (1*__WORD);                   /* newTable.rows*/
            sub %r5, %r7, %r0                       /* i - newTable.rows*/
            rtop @p0, %r5                            /* i - newTable.rows != 0*/
    @p0  ?  jmpi loop_i4                             /* i < newTable.rows => continue for loop*/



            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/



/*void printTable(RelationalTable table, void(*printFunc)(void* toPrint))*/
 .global
printTable: ld %r3, %r15, (__WORD*1);                  /* r3 = table.rows*/
            ld %r4, %r15, (__WORD*2);                  /* r4 = table.columns*/
            ld %r6, %r15, #0                        /* r6 = table.data*/
            addi %r7, %r0, #0                       /* r7 = printFunc*/
            subi %r15, %r15, (__WORD*1);               /* Push 1 word onto the stack for the return address*/
            st %r5, %r15, #0                        /* push r5 onto stack*/
            ldi %r1, #0                             /* int i = 0*/
loop_i5:     ldi %r2, #0                             /* int j = 0*/

loop_j5:     mul %r0, %r1, %r4                       /* i * table.columns*/
            addi %r0, %r0, %r2                      /* i * table.columns + j*/
            addi %r0, %r0, %r6                      /* table.data + i * table.columns + j*/
            ld %r0, %r0, #0                         /* *(table.data + i * table.columns + j)*/

            ldi %r8, saveReg                   /* save and load (should really do with saved registers and save at beginning*/
            st %r0, %r8, #0                         /* and end, but later...*/
            st %r1, %r8, #1
            st %r2, %r8, #2
            st %r3, %r8, #3
            st %r4, %r8, #4
            st %r5, %r8, #5
            st %r6, %r8, #6
            st %r7, %r8, #7

            jalr %r5, %r7                           /* printFunc(*(table.data + i * table.columns + j))*/

            ldi %r8, saveReg                   /* save and load (should really do with saved registers and save at beginning*/
            ld %r0, %r8, #0
            ld %r1, %r8, #1
            ld %r2, %r8, #2
            ld %r3, %r8, #3
            ld %r4, %r8, #4
            ld %r5, %r8, #5
            ld %r6, %r8, #6
            ld %r7, %r8, #7


            addi %r1, %r1, #1                       /* i++*/
            sub %r8, %r1, %r3                       /* i - table.rows*/
            rtop @p0, %r8                            /* i - table.rows != 0*/
    @p0  ?  jmpi loop_i5                             /* i < table.rows => continue for loop*/
            addi %r2, %r2, #1                       /* j++*/
            sub %r8, %r2, %r4                       /* j - table.columns*/
            rtop @p0, %r8                            /* j - table.columns != 0*/
    @p0  ?  jmpi loop_j5                             /* j < table.columns => continue for loop*/

            ld %r5, %r15, #0                        /* pop r5 from stack*/
            addi %r15, %r15, __WORD                 /* pop r5 from stack*/
            jmpr %r5                                /* return*/



/* void* malloc(int num)*/
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
 heap: .space   100000000
/* stack:         .word 0xface
 heap:          .word 0xfeef
 */
