DYLIB_NAME = libsecurity.dylib
SO_NAME = libsecurity.so

CXX = g++
CLANGXX = clang++
CXXFLAGS = -O2 -Wall -fPIC -I./include -std=c++17
OBJCFLAGS = -fobjc-arc -framework Foundation

all: build_all

# Tự động tạo thư mục nếu chưa có
prepare:
	@mkdir -p include src

dylib: prepare
	@echo "===> Building Dynamic Library (.dylib) for macOS..."
	$(CLANGXX) $(CXXFLAGS) $(OBJCFLAGS) -dynamiclib \
		src/security_core.cpp src/controller.mm \
		-o $(DYLIB_NAME)

so: prepare
	@echo "===> Building Shared Object (.so) for Linux..."
	$(CXX) $(CXXFLAGS) -shared \
		src/security_core.cpp \
		-o $(SO_NAME)

build_all:
ifeq ($(shell uname -s), Darwin)
	$(MAKE) dylib
	$(MAKE) so
else
	$(MAKE) so
endif

clean:
	rm -rf $(DYLIB_NAME) $(SO_NAME) *.o

.PHONY: all dylib so build_all prepare clean
