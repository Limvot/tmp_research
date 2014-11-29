#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

#define NUM_THREADS 5

typedef struct {
    void** data;
    int rows, columns;
} RelationalTable;

typedef void* (*copyFunc_t)(void* toCopy);
typedef int (*compFunc_t)(void* a, void* b);
typedef void(*printFunc_t)(void* toPrint);

typedef struct {
    void*** fromSel;
    int* columnsToSelectProj;
    RelationalTable* fromPro;
    RelationalTable* to;
    int id;
    copyFunc_t copyFunc;
} CopyInfo;

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

void* selectCopyFunc(void* param) {
    CopyInfo info = *(CopyInfo*)param;

    for (int i = info.id; i < info.to->rows; i+=NUM_THREADS) {
        for (int j = 0; j < info.to->columns; j++) {
            info.to->data[i*info.to->columns + j] = info.copyFunc(info.fromSel[i][j]);
        }
    }
    pthread_exit(NULL);
}

typedef struct {
    RelationalTable table;
    int columnA, columnB;
    int numToCopy;
    void*** toCopy;
    int id;
    compFunc_t compFunc;
} SelectionData;

void* selectSelFunc(void* param) {
    SelectionData *info = (SelectionData*)param;

    int index = 0;
    for (int i = info->id; i < info->table.rows; i+=NUM_THREADS) {
        if (info->compFunc(info->table.data[i * info->table.columns + info->columnA], info->table.data[i * info->table.columns + info->columnB])) {
            info->toCopy[index++] = info->table.data + i*info->table.columns;
        }
    }
    info->numToCopy = index;
    pthread_exit(NULL);
}

RelationalTable select(RelationalTable table, int columnA, int columnB,
                        compFunc_t compFunc, copyFunc_t copyFunc)
{
    pthread_t threads[NUM_THREADS];

    // Multithreaded Selection
    SelectionData selDat[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        printf("Creating thread %d\n", i);
        selDat[i] = (SelectionData){table, columnA, columnB, 0, malloc((table.rows/NUM_THREADS + 1) * sizeof(void***)), i, compFunc};
        int rc = pthread_create(&threads[i], NULL, selectSelFunc, (void*)&selDat[i]);
        if (rc) {
            printf("Error, return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    // Join them
    for (int i = 0; i < NUM_THREADS; i++) {
        void* status;
        pthread_join(threads[i], &status);
    }

    // Ok, now collect these into a single array
    int totalToCopy = 0;
    for (int i = 0; i < NUM_THREADS; i++)
        totalToCopy += selDat[i].numToCopy;
    void*** toCopy = malloc(totalToCopy * sizeof(void***));
    int index = 0;
    for (int i = 0; i < NUM_THREADS; i++){
        for (int j = 0; j < selDat[i].numToCopy; j++)
            toCopy[index++] = selDat[i].toCopy[j] ;
        free(selDat[i].toCopy);
    }

    // Old single threaded selection
    //void*** toCopy = malloc(table.rows * sizeof(void***));
    //int index = 0;
    //for (int i = 0; i < table.rows; i++) {
        //if (compFunc(table.data[i * table.columns + columnA], table.data[i * table.columns + columnB])) {
            //toCopy[index++] = table.data + i*table.columns;
        //}
    //}
    RelationalTable newTable;
    newTable.rows = index;
    newTable.columns = table.columns;
    newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));


    CopyInfo info[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        printf("Creating thread %d\n", i);
        info[i] = (CopyInfo){toCopy, NULL, NULL, &newTable, i, copyFunc};
        int rc = pthread_create(&threads[i], NULL, selectCopyFunc, (void*)&info[i]);
        if (rc) {
            printf("Error, return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    free(toCopy);
    for (int i = 0; i < NUM_THREADS; i++) {
        void* status;
        pthread_join(threads[i], &status);
    }
    return newTable;
}

void* projCopyFunc(void* param) {
    CopyInfo info = *(CopyInfo*)param;
    for (int i = info.id; i < info.to->rows; i+=NUM_THREADS) {
        for (int j = 0; j < info.to->columns; j++) {
            info.to->data[i*info.to->columns + j] = info.copyFunc(info.fromPro->data[i * info.fromPro->columns + info.columnsToSelectProj[j]]);
        }
    }
    pthread_exit(NULL);
}

RelationalTable project(RelationalTable table, int arrSize, int* columnsToSelect,
                        copyFunc_t copyFunc)
{
    RelationalTable newTable;
    newTable.rows = table.rows;
    newTable.columns = arrSize;
    newTable.data = malloc(newTable.rows * newTable.columns * sizeof(void*));

    pthread_t threads[NUM_THREADS];
    CopyInfo info[NUM_THREADS];
    for (int i = 0; i < NUM_THREADS; i++) {
        printf("Creating thread %d\n", i);
        info[i] = (CopyInfo){NULL, columnsToSelect, &table, &newTable, i, copyFunc};
        int rc = pthread_create(&threads[i], NULL, projCopyFunc, (void*)&info[i]);
        if (rc) {
            printf("Error, return code from pthread_create() is %d\n", rc);
            exit(-1);
        }
    }
    for (int i = 0; i < NUM_THREADS; i++) {
        void* status;
        pthread_join(threads[i], &status);
    }
    return newTable;

}

void printTable(RelationalTable table, printFunc_t printFunc)
{
    for (int i = 0; i < table.rows; i++) {
        for (int j = 0; j < table.columns; j++) {
            printFunc(table.data[i * table.columns + j]);
            printf(" ");
        }
        printf("\n");
    }
}

