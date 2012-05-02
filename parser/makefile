all: parser

parser: parser.o scanner.o
	gcc -o parser parser.c scanner.c

parser.o: parser.c parser.h scanner.h
	gcc -c parser.c

parser.c parser.h: parser.y
	bison --report=state -d parser.y -o parser.c

scanner.o: scanner.c parser.h
	gcc -c scanner.c

scanner.c scanner.h: scanner.l
	flex --header-file=scanner.h -o scanner.c scanner.l

clean:
	rm *.o scanner.c parser.c parser.h parser scanner.h parser.output

