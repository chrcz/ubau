all: scanner

scanner: scanner.o
	gcc -o scanner scanner.c

scanner.o: scanner.c
	gcc -c scanner.c

scanner.c: scanner.l
	flex -t scanner.l > scanner.c

clean:
	rm *.o scanner.c scanner

