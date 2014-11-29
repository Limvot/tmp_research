#include <stdlib.h>
#include <stdio.h>

typedef struct {
    void** data;
    int rows, columns;
} RelationalTable;

RelationalTable createDemoRelationalTable() {
    RelationalTable table;
    table.rows = 8;
    table.columns = 8;
    table.data = malloc(table.rows*table.columns * sizeof(void*));
    for (int i = 0; i < table.rows; i++) {
        for (int j = 0; j < table.columns; j++) {
            int* dat = malloc(sizeof(int));
            *dat = i*table.columns + j;
            table.data[i*table.columns + j] = dat;
        }
    }
    return table;
}

RelationalTable select(RelationalTable table, int columnA, int columnB,
                        int (*compFunc)(void* a, void* b),
                        void* (copyFunc)(void* toCopy))
{
    void*** toCopy = malloc(table.rows * sizeof(void***));
    int index = 0;
    for (int i = 0; i < table.rows; i++) {
        if (compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB])) {
            toCopy[index++] = table.data + i*table.columns;
        }
    }
    RelationalTable newTable;
    newTable.rows = index;
    newTable.columns = table.columns;
    newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));
    for (int i = 0; i < newTable.rows; i++) {
        for (int j = 0; j < newTable.columns; j++) {
            newTable.data[i*newTable.columns + j] = copyFunc(toCopy[i][j]);
        }
    }
    return newTable;
}

RelationalTable project(RelationalTable table, int arrSize, int* columnsToSelect,
                        void* (copyFunc)(void* toCopy))
{
    RelationalTable newTable;
    newTable.rows = table.rows;
    newTable.columns = arrSize;
    newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));
    for (int i = 0; i < newTable.rows; i++) {
        for (int j = 0; j < newTable.columns; j++) {
            newTable.data[i*newTable.columns + j] = copyFunc(table.data[i * table.columns + columnsToSelect[j]]);
        }
    }
    return newTable;
}

void printTable(RelationalTable table, void(*printFunc)(void* toPrint))
{
    for (int i = 0; i < table.rows; i++) {
        for (int j = 0; j < table.columns; j++) {
            printFunc(table.data[i * table.columns + j]);
            printf(" ");
        }
        printf("\n");
    }
}

