ALL = asino.c 
LOCPATH = ./bin
INSTALLPATH = /usr/local
LFLAGS =  -lm
DEBFLAGS = -g -Wall

all:
	mkdir -p $(LOCPATH)
	gcc $(ALL) -o $(LOCPATH)/asino $(LFLAGS) 
debug:
	mkdir -p $(LOCPATH)/debug
	gcc $(ALL) -o $(LOCPATH)/debug/asino_debug $(LFLAGS) $(DEBFLAGS)
asan:
	gcc $(ALL) -o $(LOCPATH)/debug/asino_debug_asan $(LFLAGS) $(DEBFLAGS) -fsanitize=address
clean:
	rm $(LOCPATH)/asino
	rm $(LOCPATH)/debug/asino_debug
distclean:
	rm -r $(LOCPATH)
install:
	cp $(LOCPATH)/asino $(INSTALLPATH)/bin/asino
uninstall:
	rm $(INSTALLPATH)/bin/asino



	
