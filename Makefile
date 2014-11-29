CC=gcc
CFLAGS=-std=c99 -Wall
LDFLAGS=-pthread
SOURCES=multithreaded_main_rel.c
DEPS=multithreaded_relational.h
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=multithreaded_main_rel

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS) $(DEPS)
	$(CC) $(LDFLAGS) $(CFLAGS) $(OBJECTS) -o $@

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

clean:
	rm *.o $(EXECUTABLE)
run:
	./$(EXECUTABLE)


