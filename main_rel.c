#include <stdlib.h>
#include <stdio.h>

#include "relational.h"

int selectFunc(void* a, void* b) {
    /*return *((int*)a) < *((int*) b);*/
    return *((int*)a) < 20;
}

void* copyFunc(void* toCopy) {
    int* result = malloc(sizeof(int));
    *result = *((int*)toCopy);
    return result;
}

void printFunc(void* toPrint) {
    printf("%d", *((int*)toPrint));
}

int main() {
    // num row, column
    /*RelationalTable rel = createRelationalTable();*/
    RelationalTable rel = createDemoRelationalTable();
    printf("Demo table (%d, %d):\n", rel.rows, rel.columns);
    printTable(rel, printFunc);
    printf("\n");


    RelationalTable selected = select(rel, 0, 1, selectFunc, copyFunc);
    printf("Selected table (%d, %d):\n", selected.rows, selected.columns);
    printTable(selected, printFunc);
    printf("\n");


    int columnsToSelect[3] = {1,3,5};
    RelationalTable projected = project(rel, 3, columnsToSelect, copyFunc);
    printf("Projected table (%d, %d):\n", projected.rows, projected.columns);
    printTable(projected, printFunc);

    return 0;
}
