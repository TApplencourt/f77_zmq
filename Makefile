# ZeroMQ header file

ifndef ZMQ_H
$(error Please set the ZMQ_H environment variable to the full path of zmq.h)
endif

CC=gcc
#CFLAGS=-O3 -fPIC -Wall -pedantic -g
CFLAGS=-O3 -fPIC -g

.PHONY: default

default: f77_zmq.o f77_zmq.h

zmq.h: $(ZMQ_H)
	cp $(ZMQ_H) .

f77_zmq.o: f77_zmq.c
	$(CC) $(CFLAGS) -c $^ -o $@

f77_zmq.h: create_f77_zmq_h.py zmq.h f77_zmq.c
	python create_f77_zmq_h.py zmq.h

clean:
	$(RM) -f -- f77_zmq.o f77_zmq.h
	$(MAKE) -C examples clean
