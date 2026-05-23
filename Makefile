CC = gcc
CFLAGS = -Wall -Wno-unused-function

all: pjp.exe

pjp.tab.c pjp.tab.h: pjp.y
	bison -d pjp.y

pjp.yy.c: pjp.l pjp.tab.h
	flex -o pjp.yy.c pjp.l

pjp.exe: pjp.tab.c pjp.yy.c
	$(CC) $(CFLAGS) pjp.tab.c pjp.yy.c -o pjp.exe

clean:
	rm -f pjp.tab.c pjp.tab.h pjp.yy.c pjp.output pjp.exe

.PHONY: all clean
