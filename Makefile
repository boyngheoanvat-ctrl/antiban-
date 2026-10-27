# Tên file thư viện đầu ra
DYLIB_NAME = libsecurity.dylib
SO_NAME = libsecurity.so

# Trình biên dịch
CXX = g++
CLANGXX = clang++

# Flags chung
CXXFLAGS = -O2 -Wall -fPIC -I./include -std=c++17
OBJCFLAGS = -fobjc-arc -framework Foundation

# Target mặc định
all: build_all

# Build dylib (Dành cho macOS)
dylib:
	@echo "===> Building Dynamic Library (.dylib) for macOS..."
	$(CLANGXX) $(CXXFLAGS) $(OBJCFLAGS) -dynamiclib \
		src/security_core.cpp src/controller.mm \
		-o $(DYLIB_NAME)

# Build so (Dành cho Linux - không bao gồm Objective-C .mm)
so:
	@echo "===> Building Shared Object (.so) for Linux..."
	$(CXX) $(CXXFLAGS) -shared \
		src/security_core.cpp \
		-o $(SO_NAME)

# Tự động build theo OS hiện tại
build_all:
ifeq ($(shell uname -s), Darwin)
	$(MAKE) dylib
	$(MAKE) so
else
	$(MAKE) so
endif

clean:
	rm -f $(DYLIB_NAME) $(SO_NAME) *.o

.PHONY: all dylib so build_all clean
