# Tên thư viện đầu ra
DYLIB_NAME = libsecurity.dylib
SO_NAME = libsecurity.so

# Trình biên dịch
CXX = g++
CLANGXX = clang++

# Flags
CXXFLAGS = -O2 -Wall -fPIC -I./include -std=c++17
OBJCFLAGS = -fobjc-arc -framework Foundation

# Thư mục build (nếu cần tách biệt)
BUILD_DIR = build

all: build_all

# Đảm bảo thư mục tồn tại trước khi build
prepare:
	@mkdir -p $(BUILD_DIR)

# Build dylib (macOS - bao gồm cả Objective-C .mm)
dylib: prepare
	@echo "===> Building Dynamic Library (.dylib) for macOS..."
	$(CLANGXX) $(CXXFLAGS) $(OBJCFLAGS) -dynamiclib \
		src/security_core.cpp src/controller.mm \
		-o $(DYLIB_NAME)

# Build so (Linux - chỉ build phần C++)
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
	rm -rf $(DYLIB_NAME) $(SO_NAME) $(BUILD_DIR) *.o

.PHONY: all dylib so build_all prepare clean
