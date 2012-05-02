all: codea

codea: parser.o scanner.o gs_list.o tree.o codea.o codegen.o
	gcc -o codea parser.o scanner.o gs_list.o tree.o codea.o codegen.o -lfl

codea.o: codea.c tree.h
	gcc -c codea.c

codea.c: codea.bfe
	bfe < codea.bfe | iburg > codea.c

parser.o: parser.c gs_list.h tree.h codegen.h
	gcc -c parser.c

parser.c parser.h: oxout.y
	bison --report=state -d oxout.y -o parser.c

scanner.o: scanner.c parser.h
	gcc -c scanner.c

scanner.c: oxout.l
	flex -o scanner.c oxout.l

oxout.y oxout.l: parser.y scanner.l
	ox parser.y scanner.l

gs_list.o: gs_list.c gs_list.h
	gcc -c gs_list.c

tree.o: tree.c tree.h
	gcc -c tree.c

codegen.o: codegen.c codegen.h
	gcc -c codegen.c

clean:
	rm *.o oxout.* scanner.c parser.c parser.h parser.output codea.c codea

