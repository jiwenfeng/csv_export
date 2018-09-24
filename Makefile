CC=g++
CPPFLAGS=-g -Wall
SRC=$(wildcard *.cpp)
INC=-I/usr/local/include/ -I/usr/include
OBJS=$(patsubst %.cpp,%.o,${SRC})
LIBS=-ljsoncpp
TARGET=libcsv_tool.a

all:$(OBJS)
	ar -rc $(TARGET) $(OBJS)

%.o:%.cpp
	$(CC) $(CPPFLAGS) $(INC) -c $< -o $@ -std=c++11

clean:
	rm -rf $(TARGET) $(OBJS)
