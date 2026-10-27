DYLIB_NAME = libsecurity.dylib
SO_NAME = libsecurity.so

CXX = g++
CLANGXX = clang++
CXXFLAGS = -O2 -Wall -fPIC -I./include -std=c++17
OBJCFLAGS = -fobjc-arc -framework Foundation

all: build_all

# Đảm bảo thư mục và file luôn tồn tại trước khi build
ensure_files:
	@mkdir -p include src
	@if [ ! -f "include/security_core.h" ]; then \
		echo "Creating default include/security_core.h..."; \
		printf "#ifndef SECURITY_CORE_H\n#define SECURITY_CORE_H\n#ifdef __cplusplus\nextern \"C\" {\n#endif\nint check_and_block_ai_bot(const char* ua);\nint process_match_history_action(int uid, int mid, int act);\n#ifdef __cplusplus\n}\n#endif\n#endif\n" > include/security_core.h; \
	fi
	@if [ ! -f "src/security_core.cpp" ]; then \
		echo "Creating default src/security_core.cpp..."; \
		printf "#include \"../include/security_core.h\"\nint check_and_block_ai_bot(const char* ua) { return 0; }\nint process_match_history_action(int uid, int mid, int act) { return 0; }\n" > src/security_core.cpp; \
	fi
	@if [ ! -f "src/controller.mm" ]; then \
		echo "Creating default src/controller.mm..."; \
		printf "#import \"../include/security_core.h\"\n#import <Foundation/Foundation.h>\n@implementation SecurityController\n@end\n" > src/controller.mm; \
	fi

dylib: ensure_files
	@echo "===> Building Dynamic Library (.dylib) for macOS..."
	$(CLANGXX) $(CXXFLAGS) $(OBJCFLAGS) -dynamiclib \
		src/security_core.cpp src/controller.mm \
		-o $(DYLIB_NAME)

so: ensure_files
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
	rm -rf $(DYLIB_NAME) $(SO_NAME) *.o build

.PHONY: all dylib so build_all ensure_files clean
