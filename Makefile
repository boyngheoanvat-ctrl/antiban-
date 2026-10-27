DYLIB_NAME = libsecurity.dylib
SO_NAME = libsecurity.so

CXX = g++
CLANGXX = clang++
CXXFLAGS = -O2 -Wall -fPIC -I./include -std=c++17
OBJCFLAGS = -fobjc-arc -framework Foundation

all: build_all

# Tự động tạo thư mục và nội dung file nếu trên GitHub chưa có
auto_generate_files:
	@mkdir -p include src
	@if [ ! -f "include/security_core.h" ]; then \
		echo "Generating include/security_core.h..."; \
		printf "#ifndef SECURITY_CORE_H\n#define SECURITY_CORE_H\n#ifdef __cplusplus\nextern \"C\" {\n#endif\nint check_and_block_ai_bot(const char* ua);\nint process_match_history_action(int uid, int mid, int act);\n#ifdef __OBJC__\n#import <Foundation/Foundation.h>\n@interface SecurityController : NSObject\n- (BOOL)isRequestFromAIBot:(NSString *)userAgent;\n- (BOOL)deleteOrHideMatchHistoryForUser:(NSInteger)userId matchId:(NSInteger)matchId actionType:(NSInteger)actionType;\n@end\n#endif\n#ifdef __cplusplus\n}\n#endif\n#endif\n" > include/security_core.h; \
	fi
	@if [ ! -f "src/security_core.cpp" ]; then \
		echo "Generating src/security_core.cpp..."; \
		printf "#include \"../include/security_core.h\"\n#include <iostream>\n#include <string>\n#include <vector>\n#include <algorithm>\nint check_and_block_ai_bot(const char* user_agent_str) {\n    if (!user_agent_str) return 1;\n    std::string ua(user_agent_str);\n    std::transform(ua.begin(), ua.end(), ua.begin(), ::tolower);\n    std::vector<string> bots = {\"gptbot\", \"chatgpt-user\", \"google-extended\", \"anthropic-ai\"};\n    for (const auto& b : bots) { if (ua.find(b) != std::string::npos) return 1; }\n    return 0;\n}\nint process_match_history_action(int uid, int mid, int act) {\n    if (act < 1 || act > 2) return -1;\n    return 0;\n}\n" > src/security_core.cpp; \
	fi
	@if [ ! -f "src/controller.mm" ]; then \
		echo "Generating src/controller.mm..."; \
		printf "#import \"../include/security_core.h\"\n#import <Foundation/Foundation.h>\n@implementation SecurityController\n- (BOOL)isRequestFromAIBot:(NSString *)userAgent {\n    if (!userAgent) return YES;\n    return (check_and_block_ai_bot([userAgent UTF8String]) == 1);\n}\n- (BOOL)deleteOrHideMatchHistoryForUser:(NSInteger)userId matchId:(NSInteger)matchId actionType:(NSInteger)actionType {\n    return (process_match_history_action((int)userId, (int)matchId, (int)actionType) == 0);\n}\n@end\n" > src/controller.mm; \
	fi

dylib: auto_generate_files
	@echo "===> Building Dynamic Library (.dylib) for macOS..."
	$(CLANGXX) $(CXXFLAGS) $(OBJCFLAGS) -dynamiclib \
		src/security_core.cpp src/controller.mm \
		-o $(DYLIB_NAME)

so: auto_generate_files
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

.PHONY: all dylib so build_all auto_generate_files clean
