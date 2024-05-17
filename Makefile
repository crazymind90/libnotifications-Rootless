ARCHS = arm64e arm64

 
# FINALPACKAGE=1 
THEOS_PACKAGE_SCHEME=rootless

export SDKVERSION = 14.5

export iP = 192.168.1.102
export Port = 22
export Pass = alpine
export Bundle = com.apple.springboard

include $(THEOS)/makefiles/common.mk
 
export LIBRARY_NAME = libnotifications

libnotifications_FILES = libnotifications/libnotifications.mm
libnotifications_CFLAGS = -Wno-objc-designated-initializers  
libnotifications_CODESIGN_FLAGS = -Slibnotificationd/monkeydev.entitlements
libnotifications_INSTALL_PATH = /usr/lib
libnotifications_CFLAGS += -DXINA_SUPPORT
libnotifications_LIBRARIES = MobileGestalt rocketbootstrap 
libnotifications_PRIVATE_FRAMEWORKS = AppSupport CoreServices CoreTelephony SpringBoardServices

include $(THEOS_MAKE_PATH)/library.mk

after-install::
	install.exec "ldrestart"
SUBPROJECTS += libnotificationd


include $(THEOS_MAKE_PATH)/aggregate.mk


before-package::
		$(ECHO_NOTHING) chmod 755 $(CURDIR)/.theos/_/DEBIAN/*  $(ECHO_END)
		$(ECHO_NOTHING) chmod 755 $(CURDIR)/.theos/_/DEBIAN  $(ECHO_END)


install6::
		install6.exec
