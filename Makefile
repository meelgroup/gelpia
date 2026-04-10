
# Set paths to point to locally built requirements first.
# Use `make MACOS=1` on macOS, where gaol is typically installed via Homebrew
# and crlibm is built into requirements/.
MACOS ?= 0
HOMEBREW_PREFIX ?= $(shell if command -v brew >/dev/null 2>&1; then brew --prefix; else echo /opt/homebrew; fi)

export PATH := ${CURDIR}/requirements/bin:${PATH}
export LD_LIBRARY_PATH := $(CURDIR)/requirements/lib:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH := $(CURDIR)/requirements/include:${CPLUS_INCLUDE_PATH}
export LIBRARY_PATH := $(CURDIR)/requirements/lib:${LIBRARY_PATH}

ifeq ($(MACOS),1)
export GELPIA_MACOS := 1
export DYLD_LIBRARY_PATH := $(CURDIR)/requirements/lib:${DYLD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH := $(HOMEBREW_PREFIX)/include:${CPLUS_INCLUDE_PATH}
export LIBRARY_PATH := $(HOMEBREW_PREFIX)/lib:${LIBRARY_PATH}
GAOL_REPL_ARCH_FLAGS :=
GAOL_REPL_LIBS := -lgaol -lcrlibm
else
GAOL_REPL_ARCH_FLAGS := -msse3
GAOL_REPL_LIBS := -lgaol -lcrlibm -lgdtoa
endif


all: bin/gelpia src/func/comp_comm.sh bin/build_func.sh bin/gaol_repl
	@cargo build --release
	@cargo build

bin/build_func.sh: src/scripts/build_func.sh | bin
	@cp src/scripts/build_func.sh bin/
	@chmod +x bin/build_func.sh

bin/gelpia: src/frontend/gelpia.py src/frontend/*.py src/frontend/function_transforms/*.py | bin
	@cp src/frontend/function_transforms/*.py bin
	@cp src/frontend/*.py bin
	@cp src/frontend/gelpia.py bin/gelpia
	@chmod +x bin/gelpia

src/func/comp_comm.sh: src/func/src/lib_fillin.rs
	@cd src/func/ && ./make_command
	@mkdir -p .compiled

bin/gaol_repl: src/gaol_repl.cc | bin
	@${CXX} ${CXXFLAGS} -std=c++11 $(GAOL_REPL_ARCH_FLAGS) -O2 src/gaol_repl.cc -o bin/gaol_repl $(GAOL_REPL_LIBS)

bin:
	mkdir bin

.PHONY: cl
cl: #clean libs
	$(RM) src/func/src/lib_generated_*
	$(RM) -r .compiled
	$(RM) src/func/target/release/*lib_generated_*
	cd src/func && cargo clean

.PHONY: clean
clean: cl
	$(RM) libfunc.so
	$(RM) bin/*.py
	$(RM) bin/gelpia
	$(RM) bin/gelpia_mm
	$(RM) bin/dop_gelpia
	$(RM) bin/build_func.sh
	$(RM) bin/parser.out
	$(RM) -r  bin/__pycache__
	cargo clean
	$(RM) src/func/comp_comm.sh
	$(RM) Cargo.lock
	$(RM) src/func/Cargo.lock
	$(RM) bin/gaol_repl


.PHONY: requirements
requirements: requirements/build.sh
	cd requirements && ./build.sh


.PHONY: clean-requirements
clean-requirements:
	$(RM) -r requirements/bin
	$(RM) -r requirements/etc
	$(RM) -r requirements/include
	$(RM) -r requirements/lib
	$(RM) -r requirements/share
