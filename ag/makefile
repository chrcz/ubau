all: ag

ag:	parser.o scanner.o gs_list.o
	gcc -o ag parser.c scanner.c gs_list.o -lfl

gs_list.o: gs_list.c gs_list.h
	gcc -c gs_list.c

parser.o: parser.c gs_list.h
	gcc -c parser.c

parser.c parser.h: oxout.y
	bison --report=state -d oxout.y -o parser.c

scanner.o: scanner.c parser.h
	gcc -c scanner.c

scanner.c: oxout.l
	flex -o scanner.c oxout.l

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

clean:
	rm *.o oxout.* scanner.c parser.c parser.h parser.output ag

