CC=g++
CPPFLAGS=-g -Wall
SRC=$(wildcard *.cpp)
INC=-I../ -I/usr/local/include/ -I/usr/include
LIB_INC=-L../
OBJS=$(patsubst %.cpp,%.o,${SRC})
LIBS=-ljsoncpp -lcsv_tool
TARGET=main

all:$(OBJS)
	@cd .. && make && cd -
	$(CC) $(CPPFLAGS) $(INC) $(LIB_INC) $(OBJS) -o $(TARGET) $(LIBS)

%.o:%.cpp
	$(CC) $(CPPFLAGS) $(INC) -c $< -o $@ -std=c++11

clean:
	rm -rf $(TARGET) $(OBJS)
	@cd .. && make clean
