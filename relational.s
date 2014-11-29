/***********************************
 SELECT and PROJECT library file - Nathan Braswell
 ***********************************/

 .perm x

 .global

 //stack = r15 for now
 
;typedef struct {
    ;void** data;
    ;int rows, columns;
;} RelationalTable;

createDemoRelationalTable:
            subi %r15, %r15, __WORD*3               // Push 3 words onto stack (like the above struct)
            ldi %r0, #8                             // 8
            st %r0, %r15, #1                        // table.rows = 8
            st %r0, %r15, #0                        // table.columns = 8

            subi %r15, %r15, __WORD                 // push r5 onto stack
            st %r5, %r15, #0                        // push r5 onto stack

            ldi %r0, 8*8*__WORD                     // r0 = rows*columns*sizeof(void*)
            jali %r5, malloc                        // r0 = malloc(rows*columns*sizeof(void*))

            st %r0, %r15, #2                        // table.data = malloc(rows*columns*sizeof(void*))

            addi %r3, %r0, #0                       // r3 = table.data
            ldi %r1, #8                             // int i = 8
 loop_i:    ldi %r2, #8                             // int j = 8
 loop_j:    ldi %r0, __WORD                         // sizeof(int)
            jali %r5, malloc                        // malloc(sizeof(int))
            muli %r4, %r1, #8                       // i*table.columns
            add %r4, %r4, %r2                       // i*table.columns + i
            st %r4, %r0, #0                         // *dat = i*table.columns + j
            add %r4, %r3, %r4                       // r4 = table.data + i*table.columns + j
            st %r0, %r4, #0                         // *(table.data + i*table.columns + j) = dat

            subi %r2, %r2, #1                       // j--;

            ld %r5, %r15, #0                        // pop r5 from stack
            addi %r15, %r15, __WORD                 // pop r5 from stack
            jmpr %r5                                // return


// RelationalTable project(RelationalTable table, int arrSize, int* columnsToSelect,
//                         void* (copyFunc)(void* toCopy))
PROJECT:
            addi %r3, %r15, #0                      // r3 = old table on stack
            subi %r15, %r15, __WORD*3               // Push 3 words onto stack for table struct
            addi %r4, %r15, #0                      // r4 = new table on stack

            subi %r15, %r15, __WORD*1               // Push 1 word onto the stack for the return address
            st %r5, %r15, #0                        // push r5 onto stack

            ld %r6, %r3, 1*__WORD                   // oldTable.rows 
            st %r6, %r4, 1*__WORD                   // newTable.rows = oldTable.rows
            st %r0, %r4, 2*__WORD                   // newTable.columns = arrSize
            

            ldi %r9, saveReg                   // save and load (should really do with saved registers and save at beginning
            st %r0, %r9, #0                         // and end, but later...
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r6, %r9, #6
            st %r7, %r9, #7

            muli %r0, %r0, __WORD                   // newTable.rows * newTable.columns * __WORD
            jali %r5, malloc                        // malloc(newTable.rows * newTable.columns * sizeof(void*))
            addi %r5, %r0, #0                       // r5 = malloc(newTable.rows * newTable.columns * sizeof(void*))

            ldi %r9, saveReg                        // save and load (should really do with saved registers and save at beginning
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r6, %r9, #6
            ld %r7, %r9, #7

            st %r5, %r4, 0*__WORD                   // newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));


            ldi %r7, #0                             // int i = 0
loop_i:     ldi %r8, #0                             // int j = 0

loop_j:     
            ldi %r9, saveReg                        // save and load (should really do with saved registers and save at beginning
            st %r0, %r9, #0                         // and end, but later...
            st %r1, %r9, #1
            st %r2, %r9, #2
            st %r3, %r9, #3
            st %r4, %r9, #4
            st %r6, %r9, #6
            st %r7, %r9, #7
            st %r8, %r9, #8

            ld %r6, %r3, 2*__WORD                   // r6 = oldtable.columns
            mul %r5, %r7, %r6                       // i * oldtable.columns
            add %r6, %r1, %r8                       // r6 = columnstoselect+j
            ld %r6, %r6, #0                         // r6 = *(columnstoselect+j)
            add %r5, %r5, %r6                       // r5 = i * oldtable.columns + *(columnstoselect+j)
            ld %r6, %r3, 0*__WORD                   // r6 = oldtable.data
            add %r6, %r6, %r5                       // r5 = oldtable.data + i * oldtable.columns + *(columnstoselect+j)
            ld %r5, %r6, #0                         // r5 = *(oldtable.data + i * oldtable.columns + *(columnstoselect+j))
            addi %r0, %r5, #0                       // r0 = r5 (for the function call)
            jalr %r5, %r2                           // copyFunc(*(oldtable.data + i * oldtable.columns + *(columnstoselect+j)))
            addi %r5, %r0, #0                       // r5 = copyFunc(*(oldtable.data + i * oldtable.columns + *(columnstoselect+j)))

            ldi %r9, saveReg                        // save and load (should really do with saved registers and save at beginning
            ld %r0, %r9, #0
            ld %r1, %r9, #1
            ld %r2, %r9, #2
            ld %r3, %r9, #3
            ld %r4, %r9, #4
            ld %r6, %r9, #6
            ld %r7, %r9, #7
            ld %r8, %r9, #8

            mul %r6, %r7, %r0                       // i*newtable.columns
            add %r6, %r6, %r8                       // i*newtable.columns + j
            ld %r9, %r4, 0*__WORD                   // r9 = newTable.data 
            add %r6, %r6, %r9                       // r6 = newtable.data + i*newtable.columns + j
            st %r5, %r6, #0                         // newtable.data + i*newtable.columns + j = 
                                                            // copyFunc(*(oldtable.data + i * oldtable.columns + *(columnstoselect+j)))


            addi %r7, %r7, #1                       // i++
            ld %r6, %r4, 1*__WORD                   // r6 = newTable.rows
            sub %r5, %r7, %r6                       // i - newtable.rows
            top @p0, %r5                            // i - newtable.rows != 0
    @p0     jmpi loop_i                             // i < newtable.rows => continue for loop
            addi %r8, %r8, #1                       // j++
            sub %r5, %r8, %r0                       // j - newtable.columns
            top @p0, %r5                            // j - newtable.columns != 0
    @p0     jmpi loop_j                             // j < newtable.columns => continue for loop


            ld %r5, %r15, #0                        // pop r5 from stack
            addi %r15, %r15, __WORD                 // pop r5 from stack
            jmpr %r5                                // return



//void printTable(RelationalTable table, void(*printFunc)(void* toPrint))
printTable: ld %r3, %r15, __WORD*1                  // r3 = table.rows
            ld %r4, %r15, __WORD*2                  // r4 = table.columns
            ld %r6, %r15, #0                        // r6 = table.data
            addi %r7, %r0, #0                       // r7 = printFunc
            subi %r15, %r15, __WORD*1               // Push 1 word onto the stack for the return address
            st %r5, %r15, #0                        // push r5 onto stack
            ldi %r1, #0                             // int i = 0
loop_i:     ldi %r2, #0                             // int j = 0

loop_j:     mul %r0, %r1, %r4                       // i * table.columns
            addi %r0, %r0, %r2                      // i * table.columns + j
            addi %r0, %r0, %r6                      // table.data + i * table.columns + j
            ld %r0, %r0, #0                         // *(table.data + i * table.columns + j)

            ldi %r8, saveReg                   // save and load (should really do with saved registers and save at beginning
            st %r0, %r8, #0                         // and end, but later...
            st %r1, %r8, #1
            st %r2, %r8, #2
            st %r3, %r8, #3
            st %r4, %r8, #4
            st %r5, %r8, #5
            st %r6, %r8, #6
            st %r7, %r8, #7

            jalr %r5, %r7                           // printFunc(*(table.data + i * table.columns + j))

            ldi %r8, saveReg                   // save and load (should really do with saved registers and save at beginning
            ld %r0, %r8, #0
            ld %r1, %r8, #1
            ld %r2, %r8, #2
            ld %r3, %r8, #3
            ld %r4, %r8, #4
            ld %r5, %r8, #5
            ld %r6, %r8, #6
            ld %r7, %r8, #7


            addi %r1, %r1, #1                       // i++
            sub %r8, %r1, %r3                       // i - table.rows
            top @p0, %r8                            // i - table.rows != 0
    @p0     jmpi loop_i                             // i < table.rows => continue for loop
            addi %r2, %r2, #1                       // j++
            sub %r8, %r2, %r4                       // j - table.columns
            top @p0, %r8                            // j - table.columns != 0
    @p0     jmpi loop_j                             // j < table.columns => continue for loop

            ld %r5, %r15, #0                        // pop r5 from stack
            addi %r15, %r15, __WORD                 // pop r5 from stack
            jmpr %r5                                // return


 entry:     ldi r15, stack;
            jali %r5, createDemoRelationalTable     // Table returned on stack
            addi %r13, %r15, #0                     // Copy the address of the demo table into r13
                                                    // so we can get back to it after the first select

            ldi %r0, demo_string                    // get the string
            jali %r5, puts                          // Print out what we're doing

            ldi %r0, printFunc                      // second argument, the printFunc, passed as r0
            jali %r5, printTable                    // Table returned on stack sent to printTable as first argument

            // Calling SELECT(table, column1, column2, selectFunc, copyFunc)
            // table is passed on the stack, which is where it is right now anyway
            // The rest is passed as registers r0-r3
            ldi %r0, #0                             // 0 - column 1
            ldi %r1, #1                             // 1 - column 2
            ldi %r2, selectFunc                     // selectFunc
            ldi %r3, copyFunc                       // copyFunc
            jali %r5, SELECT                        // Call SELECT

            ldi %r0, demo_string                    // get the string
            jali %r5, puts                          // Print out what we're doing

            ldi %r0, printFunc                      // second argument, the printFunc, passed as r0
            jali %r5, printTable                    // Table returned on stack sent to printTable as first argument

            // Calling PROJECT(table, numSelectColumns, selectColumns, copyFunc))
            // table is passed on the stack, which is in r13
            addi %r15, %r13, #0                     // Put the stack back to the first table
            // The rest is passed as registers r0-r2
            ldi %r0, #3                             // 0 - number of columns
            ldi %r1, projectColumns                 // 1 - array of columns
            ldi %r2, copyFunc                       // copyFunc
            jali %r5, PROJECT                        // Call SELECT

            ldi %r0, demo_string                    // get the string
            jali %r5, puts                          // Print out what we're doing

            ldi %r0, printFunc                      // second argument, the printFunc, passed as r0
            jali %r5, printTable                    // Table returned on stack sent to printTable as first argument

            halt;



// Function that compares 2 columns
// int selectFunc(void* a, void* b) // Returns int (used as boolean, nonzero is true)
// return *((int*)a) < 20;
selectFunc:     ld %r0, %r0, #0                     // r0 = *a
                subi %r0, %r0, #20                  // r0 = *a - 20
                isneg @p0, %r0                      // p0 = *a < 20
        @p0 ?   ldi %r0, #1                         // r0 = 1 if *a < 20
                notp @p0, @p0                       // p0 = !p0
        @p0 ?   ldi %r0, #0                         // r0 = 0 if *a >= 20
                jmpr %r5                            // return *a < 20


// Function that copies the data at the pointer
copyFunc:       subi %r15, %r15, __WORD*2           // Push 2 onto stack
                st %r0, %r15, #0                    // Save our argument
                st %r5, %r15, #1                    // Save our return address
                ldi %r0, __WORD                     // We want to malloc 1 word
                jali %r5, malloc                    // do the malloc

                ld %r1, %r15, #0                    // Restore our argument to r1
                ld %r5, %r15, #1                    // Restore our return address
                addi %r15, %r15, __WORD*2           // Pop 2 off stack

                ld %r1, %r1, #0                     // Load the data through r1
                st %r1, %r0, #0                     // Store it to our newly allocated memory
                jmpr %r5                            // return

// void* malloc(int num)
malloc:         ldi %r1, heap                       // r1 = &heap
                ld %r2, %r1, #0                     // r2 = heap
                addi %r0, %r2, #0                  // return = heap
                add %r2, %r2, %r0                   // r2 = heap + size
                st %r2, %r1, #0                     // heap = heap + size
                jmpr %r5                            // actually return

 .perm rw
 stack:         .word 0xface
 heap:          .word 0xbeef
 demo_string:   .string "Demo table:  \n"
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
