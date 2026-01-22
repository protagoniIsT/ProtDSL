# Auto generated from ProtDSL
CXX = g++
CXXFLAGS = -O2 -Wall -std=c++17 -I../simlib
TARGET = rv32im_sim
SRCS = main.cpp machine.cpp hart.cpp executor.cpp
OBJS = $(SRCS:.cpp=.o)

all: $(TARGET)
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
clean:
	rm -f $(OBJS) $(TARGET)
.PHONY: all clean
