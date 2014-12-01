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
	rm *.o $(EXECUTABLE) *.HOF *.bin *.out *.d *~
run:
	./$(EXECUTABLE)

# ASM Stuff
HARP_MAIN = ~/harptool/src/harptool
HARPLD  = $(HARP_MAIN) -L
HARPAS  = $(HARP_MAIN) -A
HARPEM  = $(HARP_MAIN) -E
HARPDIS = $(HARP_MAIN) -D
4BARCH  = 4b16/16/2

asm: main_rel.bin main_rel.4b.bin 

go: main_rel.bin
	$(HARPEM) -c main_rel.bin

run_asm: main_rel.out main_rel.4b.out 

disas: main_rel.d main_rel.4b.d 

%.4b.out : %.4b.bin
	$(HARPEM) -a $(4BARCH) -c $< > $@

%.out : %.bin
	$(HARPEM) -c $< > $@

%.4b.bin : boot.4b.HOF lib.4b.HOF relational.4b.HOF %.4b.HOF
	$(HARPLD) --arch $(4BARCH) -o $@ $^

%.bin : boot.HOF lib.HOF relational.HOF %.HOF
	$(HARPLD) -o $@ $^

%.4b.HOF : %.s
	$(HARPAS) --arch $(4BARCH) -o $@ $<

%.HOF : %.s
	$(HARPAS) -o $@ $<

%.4b.d : %.4b.HOF
	$(HARPDIS) -o $@ --arch $(4BARCH) $<

%.d : %.HOF
	$(HARPDIS) -o $@ $<

