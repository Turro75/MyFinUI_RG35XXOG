ifeq (,$(CROSS_COMPILE))
$(error missing CROSS_COMPILE for this toolchain)
endif

TARGET = minput

CC = $(CROSS_COMPILE)gcc
CFLAGS   = -Os -marm -mtune=cortex-a9 -mfpu=neon-fp16 -mfloat-abi=${FBABI} -march=armv7-a -fomit-frame-pointer
CFLAGS  += -I. -I../common -DPLATFORM=\"$(UNION_PLATFORM)\" -Ofast -std=gnu99
LDFLAGS	 = -ldl -lSDL -lSDL_image -lSDL_ttf -lmsettings -lpthread -lm -lz
# CFLAGS  += -fsanitize=address -fno-common
# LDFLAGS += -lasan

all:
	$(CC) $(TARGET).c ../common/utils.c ../common/api.c -o $(TARGET).elf $(CFLAGS) $(LDFLAGS)
clean:
	rm -f $(TARGET).elf
