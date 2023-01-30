
.PHONY: clean
clean:
	rm -rf build/

.PHONY: directories
directories:
	mkdir -p build/

# ===============================
# Common Build steps.
# ===============================

.PHONY: build-bootscript
build-bootscript: directories
	mkimage \
		-A arm \
		-T script \
		-d scripts/$(BOOTSCRIPT) \
		build/boot.scr

.PHONY: build-common
build-common: clean directories
	cp bcm2710-rpi-3-b.dtb build/
	cp bootcode.bin build/
	cp config.txt build/
	cp start.elf build/
	cp u-boot.bin build/
	cp fixup.dat build/

# Boots from TFTP server from my desk.
.PHONY: build-tftpboot-tsdesk
build-tftpboot-tsdesk: build-common
	$(MAKE) build-bootscript \
		BOOTSCRIPT="tftpboot-tsdesk.script"

# Boots from TFTP server on Machine Queue.
.PHONY: build-tftpboot-tsmq
build-tftpboot-tsmq: build-common
	$(MAKE) build-bootscript \
		BOOTSCRIPT="tftpboot-tsmq.script"

# ===============================
# Flashing the SD card
# ===============================

.PHONY: ls-sdcard
ls-sdcard:
	@echo "===> Listing files on SD card at $(SDCARD_PATH)"
	ls -la $(SDCARD_PATH)

.PHONY: flash-common
flash-common:
# Don't flash if the SD card does not exist.
ifeq ("$(wildcard $(SDCARD_PATH))","")
	@echo "The SD card does not exist."
else
	# Clear out everything on the SD card.
	rm -vrf $(SDCARD_PATH)/*
	# Copy everything from build onto SD card.
	cp -vR build/* $(SDCARD_PATH)
endif

# Flashing for TS personal desk.
# E.g. $ make flash-tftpboot-tsdesk SDCARD_PATH="/Volumes/SDCARD/"
.PHONY: flash-tftpboot-tsdesk
flash-tftpboot-tsdesk: \
	build-tftpboot-tsdesk \
	flash-common
	@echo "===> Finished flashing SD card at $(SDCARD_PATH) for TFTP boot at TS on my own Desk."
	$(MAKE) ls-sdcard

# Flashing for TS Machine Queue.
# E.g. $ make flash-tftpboot-tsmq SDCARD_PATH="/Volumes/SDCARD/"
.PHONY: flash-tftpboot-tsmq
flash-tftpboot-tsmq: \
	build-tftpboot-tsmq \
	flash-common
	@echo "===> Finished flashing SD card at $(SDCARD_PATH) for TFTP boot at TS on Machine Queue."
	$(MAKE) ls-sdcard

