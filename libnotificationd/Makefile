

export SDKVERSION = 14.5

include $(THEOS)/makefiles/common.mk

export THEOS_PACKAGE_SCHEME = rootless

TOOL_NAME = libnotificationd
libnotificationd_FILES = main.m
libnotificationd_INSTALL_PATH = /usr/libexec
libnotificationd_CODESIGN_FLAGS = -Smonkeydev.entitlements
libnotificationd_CFLAGS = -Wno-deprecated-declarations -Wno-unused-function # -fobjc-arc 
libnotificationd_LIBRARIES = MobileGestalt rocketbootstrap 
libnotificationd_PRIVATE_FRAMEWORKS = AppSupport SpringBoardServices
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN -Wno-shorten-64-to-32

include $(THEOS_MAKE_PATH)/tool.mk
