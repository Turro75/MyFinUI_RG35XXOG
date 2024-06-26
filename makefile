.PHONY: clean

###########################################################

ifeq (,$(PLATFORM))
PLATFORM=$(UNION_PLATFORM)
endif

ifeq (,$(PLATFORM))
$(error please specify PLATFORM, eg. PLATFORM=trimui make)
endif

###########################################################

#BUILD_HASH!=git rev-parse --short HEAD
BUILD_HASH=HEAD

RELEASE_TIME!=TZ=GMT date +%Y%m%d
RELEASE_BASE=MyFinUI-$(RELEASE_TIME)-$(FBABI)
RELEASE_DOT!=find ./releases/. -regex ".*/$(RELEASE_BASE)-[0-9]+-base\.zip" -printf '.' | wc -m
RELEASE_NAME=$(RELEASE_BASE)-$(RELEASE_DOT)

# TODO: this needs to consider the different platforms, eg. rootfs.ext2 should only be copied in rg35xx-toolchain

all: lib sys tools all-cores dtb bundle readmes zip report

repack: bundle readmes zip report

lib:
	cd ./src/libmsettings && make

sys:
	cd ./src/keymon && make
	cd ./src/minarch && make
	cd ./src/minui && make
	cd ./src/minput && make
	cd ./src/overclock && make
	cd ./src/boot && ./build.sh

all-cores:
	cd ./cores && make

tools:
	cd ./src/clock && make
	cd ./src/clear_recent && make
	cd ./other/DinguxCommander && make 

dtb:
	cd ./src/dts/ && make

bundle:
	# ready build
	rm -rf ./build
	mkdir -p ./releases
	cp -R ./skeleton ./build

ifeq ($(FBABI),softfp)
# overwrite launchers for retroarch and dinguxcommander which both require LD_PRELOAD=/root/build/SDL-1.2/build/.libs/libSDL-1.2.so.0.11.4 to properly handle inputs
	cp -rf ./toolchain-soft/modifiedfiles/retroarch_doom_launch.sh ./build/EXTRAS/Emus/rg35xx/DOOM.pak/launch.sh
	cp -rf ./toolchain-soft/modifiedfiles/retroarch_tools_launch.sh ./build/EXTRAS/Tools/rg35xx/RetroArch.pak/launch.sh
	cp -rf ./toolchain-soft/modifiedfiles/Dinguxcommander_tools_launch.sh ./build/EXTRAS/Tools/rg35xx/Files.pak/launch.sh
endif

	# remove authoring detritus
	cd ./build && find . -type f -name '.keep' -delete
	cd ./build && find . -type f -name '*.meta' -delete

	cp ./src/boot/output/dmenu.bin ./build/BASE
	cp ./src/boot/output/dmenu.bin ./build/SYSTEM/rg35xx/dat
	cp ./src/install/install.sh ./build/SYSTEM/rg35xx/bin

	# prepare boot logo
	cd ./build/SYSTEM/rg35xx/dat && convert boot_logo.png -type truecolor boot_logo.bmp && rm boot_logo.png && gzip -n boot_logo.bmp

	# populate system
	cp ./src/dts/kernel.dtb ./build/SYSTEM/rg35xx/dat
	cp ~/buildroot/output/images/rootfs.ext2 ./build/SYSTEM/rg35xx
	cp ./src/ramdisk/patched-ramdisk.img ./build/SYSTEM/rg35xx/dat/ramdisk.img
	cp ./src/ramdisk/charging.png ./build/SYSTEM/rg35xx/dat/
	cp ./src/libmsettings/libmsettings.so ./build/SYSTEM/rg35xx/lib
	cp ./src/keymon/keymon.elf ./build/SYSTEM/rg35xx/bin
	cp ./src/minarch/minarch.elf ./build/SYSTEM/rg35xx/bin
	cp ./cores/output/retroarch.elf ./build/SYSTEM/rg35xx/bin
	cp ./src/overclock/overclock.elf ./build/SYSTEM/rg35xx/bin
	cp ./src/minui/minui.elf ./build/SYSTEM/rg35xx/paks/MinUI.pak
	cp ./src/clock/clock.elf ./build/EXTRAS/Tools/rg35xx/Clock.pak
	cp ./src/clear_recent/clear_recent.elf "./build/EXTRAS/Tools/rg35xx/Clear Recently Played.pak"
	# stock cores
ifeq ($(FBABI),hard)
	cp ./cores/output/fceumm_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/output/gambatte_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/output/gpsp_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/output/pcsx_rearmed_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/output/picodrive_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/output/fbneo_libretro.so ./build/EXTRAS/Emus/rg35xx/FBN.pak
	cp ./cores/output/mame2003_plus_libretro.so ./build/EXTRAS/Emus/rg35xx/MAME.pak
	cp ./cores/output/prboom_libretro.so ./build/EXTRAS/Emus/rg35xx/DOOM.pak
	cp ./cores/output/puae2021_libretro.so ./build/EXTRAS/Emus/rg35xx/PUAE.pak
	cp ./cores/output/fake08_libretro.so ./build/EXTRAS/Emus/rg35xx/P8.pak
	cp ./cores/output/mgba_libretro.so ./build/EXTRAS/Emus/rg35xx/MGBA.pak
	cp ./cores/output/mgba_libretro.so ./build/EXTRAS/Emus/rg35xx/SGB.pak
	cp ./cores/output/mednafen_pce_fast_libretro.so ./build/EXTRAS/Emus/rg35xx/PCE.pak
	cp ./cores/output/mednafen_supafaust_libretro.so ./build/EXTRAS/Emus/rg35xx/SUPA.pak
	cp ./cores/output/mednafen_vb_libretro.so ./build/EXTRAS/Emus/rg35xx/VB.pak
	cp ./cores/output/pokemini_libretro.so ./build/EXTRAS/Emus/rg35xx/PKM.pak
else
	cp /root/build/SDL-1.2/build/.libs/libSDL-1.2.so.0.11.4 ./build/SYSTEM/rg35xx/lib
	cp ./cores/softfp/fceumm_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/softfp/gambatte_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/softfp/gpsp_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/softfp/pcsx_rearmed_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/softfp/picodrive_libretro.so ./build/SYSTEM/rg35xx/cores
	cp ./cores/softfp/fbneo_libretro.so ./build/EXTRAS/Emus/rg35xx/FBN.pak
	cp ./cores/softfp/mame2003_plus_libretro.so ./build/EXTRAS/Emus/rg35xx/MAME.pak
	cp ./cores/softfp/prboom_libretro.so ./build/EXTRAS/Emus/rg35xx/DOOM.pak
	cp ./cores/softfp/puae2021_libretro.so ./build/EXTRAS/Emus/rg35xx/PUAE.pak
	cp ./cores/softfp/fake08_libretro.so ./build/EXTRAS/Emus/rg35xx/P8.pak
	cp ./cores/softfp/mgba_libretro.so ./build/EXTRAS/Emus/rg35xx/MGBA.pak
	cp ./cores/softfp/mgba_libretro.so ./build/EXTRAS/Emus/rg35xx/SGB.pak
	cp ./cores/softfp/mednafen_pce_fast_libretro.so ./build/EXTRAS/Emus/rg35xx/PCE.pak
	cp ./cores/softfp/mednafen_supafaust_libretro.so ./build/EXTRAS/Emus/rg35xx/SUPA.pak
	cp ./cores/softfp/mednafen_vb_libretro.so ./build/EXTRAS/Emus/rg35xx/VB.pak
	cp ./cores/softfp/pokemini_libretro.so ./build/EXTRAS/Emus/rg35xx/PKM.pak
endif
	cp ./cores/output/snes9x2005_plus_libretro.so ./build/SYSTEM/rg35xx/cores

	cp ./other/DinguxCommander/output/DinguxCommander.elf ./build/EXTRAS/Tools/rg35xx/Files.pak
	cp -R ./other/DinguxCommander/res ./build/EXTRAS/Tools/rg35xx/Files.pak/
	cp ./src/minput/minput.elf ./build/EXTRAS/Tools/rg35xx/Input.pak

readmes:
	fmt -w 40 -s ./skeleton/BASE/README.txt > ./build/BASE/README.txt
	fmt -w 40 -s ./skeleton/EXTRAS/README.txt > ./build/EXTRAS/README.txt

zip:
	cd ./build/SYSTEM && echo "$(RELEASE_NAME)\n$(BUILD_HASH)" > version.txt
	./commits.sh > ./build/SYSTEM/commits.txt
	cd ./build && find . -type f -name '.DS_Store' -delete
	mkdir -p ./build/PAYLOAD
	mv ./build/SYSTEM ./build/PAYLOAD/.system

	cd ./build/PAYLOAD && zip -r MinUI.zip .system
	mv ./build/PAYLOAD/MinUI.zip ./build/BASE

	rm -fr ./build/FULL
	mkdir ./build/FULL
	cp -fR ./build/BASE/* ./build/FULL/
	cp -fR ./build/EXTRAS/* ./build/FULL/
#	rm -rf ./build/BASE
#	rm -rf ./build/EXTRAS
#	rm -rf ./build/PAYLOAD
	cd ./build/FULL && zip -r ../../releases/$(RELEASE_NAME).zip Bios Emus Roms Saves Tools dmenu.bin MinUI.zip INSTALL.txt SHORTCUTS.txt

	echo "$(RELEASE_NAME)" > ./build/latest.txt

report:
	echo "finished building r${RELEASE_TIME}-${RELEASE_DOT}"

clean:
	rm -rf ./build
#	rm -rf ./releases
	cd ./src/libmsettings && make clean
	cd ./src/keymon && make clean
	cd ./src/minui && make clean
	cd ./src/minput && make clean
	cd ./src/minarch && make clean
	cd ./src/boot && rm -rf ./output
	cd ./src/clock && make clean
	cd ./src/clear_recent && make clean
	cd ./other/DinguxCommander && make clean
	cd ./cores && make clean

