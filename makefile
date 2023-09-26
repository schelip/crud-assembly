# Makefile for assembling and linking crud-assembly

# Define the source and object files
SOURCE = crud-assembly.s
OBJECT = crud-assembly.o
EXECUTABLE = crud-assembly

# Define compiler and linker flags
ASFLAGS = -g -32
LDFLAGS = -m elf_i386 -dynamic-linker /lib/ld-linux.so.2

# Default target
all: $(EXECUTABLE)

# Compile the assembly source file
$(OBJECT): $(SOURCE)
	@as $(ASFLAGS) $(SOURCE) -o $(OBJECT)

# Link the object file to create the executable
$(EXECUTABLE): $(OBJECT)
	@ld $(LDFLAGS) $(OBJECT) -o $(EXECUTABLE) -lc

# Clean up intermediate files
clean:
	@rm -f $(OBJECT)

# Clean everything, including the executable
distclean: clean
	@rm -f $(EXECUTABLE)
