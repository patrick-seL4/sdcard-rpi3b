
.PHONY: clean
clean:
	rm -rf build/

.PHONY: build
build: clean
	mkdir -p build/
	cp bootcode.bin build/
	cp start.elf build/
	cp u-boot.bin build/
	cp config.txt build/
