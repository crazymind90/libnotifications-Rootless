

export SDKVERSION = 14.5

include $(THEOS)/makefiles/common.mk

export THEOS_PACKAGE_SCHEME = rootless

TOOL_NAME = libnotificationde
libnotificationde_FILES = main.m
libnotificationde_INSTALL_PATH = /usr/libexec
libnotificationde_CODESIGN_FLAGS = -Smonkeydev.entitlements
libnotificationde_CFLAGS = -Wno-deprecated-declarations -Wno-unused-function # -fobjc-arc 
libnotificationde_PRIVATE_FRAMEWORKS = SpringBoardServices
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN -Wno-shorten-64-to-32

include $(THEOS_MAKE_PATH)/tool.mk
