VLCLIB=DYLD_LIBRARY_PATH=/usr/lib:/Applications/VLC.app/Contents/MacOS/lib:$DYLD_LIBRARY_PATH

all:
	dsss build
	$(VLCLIB) ./test

gdb:
	dsss build
	$(VLCLIB) gdb ./test


VGLTEX_MODULE_NAME=vgltex
VGLTEX_OUTPUT=lib$(VGLTEX_MODULE_NAME)_plugin.dylib
VGLTEX_SRCS=$(VGLTEX_MODULE_NAME).c
VLC_INCLUDE_PATH=/Users/theo/Development/vlc-0.9.8/include
VLC_LIBRARY_PATH=/Applications/VLC.app/Contents/MacOS/lib

modules/$(VGLTEX_OUTPUT): $(VGLTEX_SRCS)
	gcc $(VGLTEX_SRCS) -o modules/$(VGLTEX_OUTPUT) -bundle -arch i386 -I$(VLC_INCLUDE_PATH) -L$(VLC_LIBRARY_PATH) -DMODULE_NAME=$(VGLTEX_MODULE_NAME) -DMODULE_NAME_IS_$(VGLTEX_MODULE_NAME) -DMODULE_STRING=\"$(VGLTEX_MODULE_NAME)\" -D__PLUGIN__ -std=gnu99 -lvlccore -undefined error

plugin: modules/$(VGLTEX_OUTPUT)