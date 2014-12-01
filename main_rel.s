/***********************************
 SELECT and PROJECT main file - Nathan Braswell
 ***********************************/

 .perm x
 .entry

 /*stack = r15 for now*/
 /*Demotable = r13 for now*/

 .global
 entry:     ldi %r15, stack;

            ldi %r7, __WORD                     /* *(int*)toPrint*/
            jali %r5, printdec

            ldi %r7, demo_string                    /* get the string*/
            jali %r5, puts                          /* Print out what we're doing*/

            jali %r5, createDemoRelationalTable     /* Table returned on stack*/
            addi %r13, %r15, #0                     /* Copy the address of the demo table into r13*/


            ldi %r7, demo_string                    /* get the string*/
            jali %r5, puts                          /* Print out what we're doing*/

            ldi %r0, printFunc                      /* second argument, the printFunc, passed as r0*/
            jali %r5, printTable                    /* Table returned on stack sent to printTable as first argument*/

            halt

            /* Calling SELECT(table, column1, column2, selectFunc, copyFunc)*/
            /* table is passed on the stack, which is where it is right now anyway*/
            /* The rest is passed as registers r0-r3*/
            ldi %r0, #0                             /* 0 - column 1*/
            ldi %r1, #1                             /* 1 - column 2*/
            ldi %r2, selectFunc                     /* selectFunc*/
            ldi %r3, copyFunc                       /* copyFunc*/
            jali %r5, SELECT                        /* Call SELECT*/

            ldi %r7, demo_string                    /* get the string*/
            jali %r5, puts                          /* Print out what we're doing*/

            ldi %r0, printFunc                      /* second argument, the printFunc, passed as r0*/
            jali %r5, printTable                    /* Table returned on stack sent to printTable as first argument*/

            /* Calling PROJECT(table, numSelectColumns, selectColumns, copyFunc))*/
            /* table is passed on the stack, which is in r13*/
            addi %r15, %r13, #0                     /* Put the stack back to the first table*/
            /* The rest is passed as registers r0-r2*/
            ldi %r0, #3                             /* 0 - number of columns*/
            ldi %r1, projectColumns                 /* 1 - array of columns*/
            ldi %r2, copyFunc                       /* copyFunc*/
            jali %r5, PROJECT                        /* Call SELECT*/

            ldi %r7, demo_string                    /* get the string*/
            jali %r5, puts                          /* Print out what we're doing*/

            ldi %r0, printFunc                      /* second argument, the printFunc, passed as r0*/
            jali %r5, printTable                    /* Table returned on stack sent to printTable as first argument*/

            halt;



/* Function that compares 2 columns*/
/* int selectFunc(void* a, void* b) /* Returns int (used as boolean, nonzero is true)*/
/* return *((int*)a) < 20;*/
selectFunc:     ld %r0, %r0, #0                     /* r0 = *a*/
                subi %r0, %r0, #20                  /* r0 = *a - 20*/
                isneg @p0, %r0                      /* p0 = *a < 20*/
        @p0 ?   ldi %r0, #1                         /* r0 = 1 if *a < 20*/
                notp @p0, @p0                       /* p0 = !p0*/
        @p0 ?   ldi %r0, #0                         /* r0 = 0 if *a >= 20*/
                jmpr %r5                            /* return *a < 20*/


/* Function that copies the data at the pointer*/
copyFunc:       subi %r15, %r15, (__WORD*2);           /* Push 2 onto stack*/
                st %r0, %r15, #0                    /* Save our argument*/
                st %r5, %r15, #1                    /* Save our return address*/
                ldi %r0, __WORD                     /* We want to malloc 1 word*/

                ld %r1, %r15, #0                    /* Restore our argument to r1*/
                ld %r5, %r15, #1                    /* Restore our return address*/
                addi %r15, %r15, (__WORD*2);           /* Pop 2 off stack*/

                ld %r1, %r1, #0                     /* Load the data through r1*/
                st %r1, %r0, #0                     /* Store it to our newly allocated memory*/
                jmpr %r5                            /* return*/
/*void printFunc(void* toPrint) {*/
printFunc:      
                subi %r15, %r15, (__WORD*1);        /* Push 1 word onto the stack for the return address*/
                st %r5, %r15, #0                    /* push r5 onto stack*/
                ld %r7, %r0, #0                     /* *(int*)toPrint*/
                jali %r5, printdec
                ld %r5, %r15, #0                    /* pop r5 from stack*/
                addi %r15, %r15, __WORD             /* pop r5 from stack*/
                jmpr %r5                            /* return*/

/* void* malloc(int num)*/
malloc:         ldi %r1, heap_cnt                   /* r1 = &heap_cnt*/
                ld %r2, %r1, #0                     /* r2 = heap_cnt*/
                addi %r0, %r2, heap                 /* return = heap + heap_cnt */
                add %r2, %r2, %r0                   /* r2 = heap_cnt + size*/
                st %r2, %r1, #0                     /* heap_cnt = heap_cnt + size */
                jmpr %r5                            /* actually return*/

 .perm rw
 .space 100
 stack: .word 0x0                          /* stack goes negative */
 /*stack:         .word 0xface*/
 heap_cnt:        .word 0x0
 heap: .space 1000
 demo_string:   .string "Demo table:  \n"
projectColumns: .word 0x1
                .word 0x3
                .word 0x5
