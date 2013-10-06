##########################################################################################################

PRODUCTNAME=StackController

##########################################################################################################

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
HEAVENLY=/usr/local/heavenly
CC=@arm-apple-darwin-gcc
CXX=@arm-apple-darwin-g++
LD=$(CC)
LDFLAGS=-I./mDNSShared -Wl,-syslibroot,$(HEAVENLY) -lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit -framework CoreGraphics

##########################################################################################################

all:	clear obj stack_binary stack_controller install

clear:
	@clear


obj: stackmain.o MobileStack.o
	

stack_binary:	stackmain.o MobileStack.o
		@echo "[Linking] $@"
		@$(LD) $(LDFLAGS) -o $@ $^

stack_controller: main.o MobileStackController.o
		@echo "[Linking] $@"
		@$(LD) $(LDFLAGS) -o $@ $^

install:
		@echo "[Packaging] $(PRODUCTNAME).app"
		@mkdir -p ./$(PRODUCTNAME).app/Stack.app
		@cp -f ./stack_binary ./$(PRODUCTNAME).app/Stack.app/stack_binary
		@cp -f ./stack_controller ./$(PRODUCTNAME).app/stack_controller
		@cp -f ./images/StackControllerIcon.png ./$(PRODUCTNAME).app/icon.png
		@cp -f ./images/Default.png ./$(PRODUCTNAME).app/Default.png
		@cp -f ./images/icon.png ./$(PRODUCTNAME).app/Stack.app/icon.png
		@cp -f ./images/UIButtonLarge.png ./$(PRODUCTNAME).app/UIButtonLarge.png
		@cp -f ./images/UIDeleteButtonLarge.png ./$(PRODUCTNAME).app/UIDeleteButtonLarge.png
		@cp -f ./images/stackicon.png ./$(PRODUCTNAME).app/Stack.app/stackicon.png
		@cp -f ./Info.plist ./$(PRODUCTNAME).app/Info.plist
		@cp -f ./StackInfo.plist ./$(PRODUCTNAME).app/Stack.app/Info.plist
		@cp -f ./com.steventroughtonsmith.stack ./$(PRODUCTNAME).app/com.steventroughtonsmith.stack
		@echo "[Zipping] $(PRODUCTNAME).zip"
		@zip -r ./$(PRODUCTNAME).zip ./$(PRODUCTNAME).app > /dev/null



%.o:	%.m
		@echo "[Compiling] $@"
		@$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

##########################################################################################################

clean: clear
	@echo "[Cleaning Up]"
	@rm -rf stack_binary
	@rm -rf stack_controller
	@rm -rf *.o
	@rm -rf *.zip
	@rm -rf ./$(PRODUCTNAME).app
	@echo "[Fully Cleaned]"
