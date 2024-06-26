# Adding additional cores

In the makefile: first add the core name to the list of `CORES`, eg. `CORES+=<core_name>`. By default, this will `git clone https://github.com/libretro/<core_name>` but you can override the repo path by setting `<core_name>_REPO`. You can select a specific commit by setting `<core_name>_HASH`. If the resulting lib name doesn't match the `<core_name>` you can specify the actual name by setting `<core_name>_CORE`. Additional flags required to build the core can be added by setting `<core_name>_FLAGS`. If the core does not use a makefile named `Makefile` you can specify a custom makefile by setting `<core_name>_MAKEFILE`. If building takes place in a subfolder you can specify that by setting `<core_name>_BUILD_PATH`.

In the patches directory: create a patch file that adds an RG35XX target to the makefile. To do this I run `make clone-<core_name>` then seach the makefile for `MIYOO` and add a new `else ifeq ($(platform), rg35xx)` condition. I'll find a comparable device to base this addition on (either the Miyoo Mini or a Dingux device). The architecture flags should be something like `-marm -mtune=cortex-a9 -mfpu=neon-fp16 -mfloat-abi=hard -march=armv7-a`. I usually enable `-fPIC -flto` as well. Then I'll try manually building the core. If the build succeeds and runs on the device I'll create the patch with git and name it `<core_name>.patch`. Then I delete the core folder and run `make <core_name>` and confirm the build succeeds and runs on the device.

In the `skeleton/EXTRAS/Emus/rg35xx/` directory I create a new pak for the emulator and add it to the bundle step of MinUI's makefile. I also create the requisite Bios, Roms, and Saves folders and document the addition in the extras readme.

Fin

# Adding precompiled cores

by using the softfp toolchain it is possible use as is the cores available on garlicos 