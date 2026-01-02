export THEOS_PACKAGE_SCHEME=rootful
export TARGET = iphone:clang:latest:9.0
export ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = YouTube

THEOS_DEVICE_IP = localhost

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ytnoalerts

ytnoalerts_FILES = Tweak.xm
ytnoalerts_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
