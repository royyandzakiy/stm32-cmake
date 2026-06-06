.PHONY: all build cmake clean format

BUILD_DIR := build
BUILD_TYPE ?= Debug

# Detect OS and set appropriate commands
ifeq ($(OS),Windows_NT)
    # Windows settings
    RM := rmdir /s /q
    CMAKE_GENERATOR := "MinGW Makefiles"
    FIND_FILES := dir /s /b *.c *.h *.cpp *.hpp 2>nul
    # Remove quotes from generator for Windows
    CMAKE_GEN := MinGW Makefiles
else
    # Linux/Unix settings
    RM := rm -rf
    CMAKE_GENERATOR := "Unix Makefiles"
    FIND_FILES := find . -name '*.[ch]' -or -name '*.[ch]pp'
    CMAKE_GEN := Unix Makefiles
endif

all: build

${BUILD_DIR}/Makefile:
	cmake \
		-G $(CMAKE_GENERATOR) \
		-B${BUILD_DIR} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-DCMAKE_TOOLCHAIN_FILE=gcc-arm-none-eabi.cmake \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
		-DDUMP_ASM=OFF

cmake: ${BUILD_DIR}/Makefile

build: cmake
	$(MAKE) -C ${BUILD_DIR} --no-print-directory

# Source files for formatting
SRCS := $(shell $(FIND_FILES))

%.format: %
	clang-format -i $<

format: $(addsuffix .format, ${SRCS})

# Clean target
clean:
	$(RM) $(BUILD_DIR)