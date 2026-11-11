#
# Makefile-Rust.mk
#
# Parameters:
#
# - COVERAGE
#     If set to 1, determine test coverage using `llvm-profdata` and `llvm-cov`
# - GAIA_DIR
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
# - LLVM_COV, LLVM_PROFDATA
#     The LLVM coverage tools. Default to the tools of the `llvm-tools` Rustup component of the nightly
#     toolchain, which match the toolchain's LLVM version; fall back to `llvm-cov` and `llvm-profdata` on
#     the `PATH`
#
# Targets (parameters):
#
# - bench (GAIA_BUILD_TYPE)
# - build (GAIA_BUILD_TYPE)
# - check (GAIA_BUILD_TYPE)
# - clean
# - doc (GAIA_BUILD_TYPE)
# - run (GAIA_BUILD_TYPE)
# - test (COVERAGE, GAIA_BUILD_TYPE)
#

ifndef GAIA_DIR
  $(error `GAIA_DIR` not set)
endif
include $(GAIA_DIR)/src/main/make/Makefile-common.mk

# Constants -------------------------------------------------------------------------------------------------

KATEX_HTML := $(GAIA_DIR)/src/main/html/katex.html
ifdef GAIA_OS_WINDOWS
  KATEX_HTML := $(shell cygpath -w $(KATEX_HTML))
endif

TARGET_DIR := target/$(GAIA_BUILD_TYPE)

COVERAGE_DIR := $(TARGET_DIR)/code-coverage
DOCTEST_BIN_DIR := $(COVERAGE_DIR)/doctests
PROFRAW_DIR := $(COVERAGE_DIR)/profraw
PROFDATA_FILE := $(COVERAGE_DIR)/coverage.profdata

# Source files to exclude from coverage reports: dependencies and the standard library
COVERAGE_IGNORE_REGEX := [/\\](\.cargo|\.rustup|rustc)[/\\]

COVERAGE_RUSTFLAGS := -C instrument-coverage -Z coverage-options=branch

# Configure Cargo -------------------------------------------------------------------------------------------

CARGO_FLAGS :=
ifeq ($(GAIA_BUILD_TYPE),release)
  CARGO_FLAGS += --release
endif

# Configure LLVM tools --------------------------------------------------------------------------------------

# Recursively expanded, so `rustc` is only invoked if the tools are actually needed
RUST_LLVM_BIN_DIR = $(dir $(shell rustc +nightly --print target-libdir))bin

LLVM_COV ?= $(firstword \
  $(wildcard $(RUST_LLVM_BIN_DIR)/llvm-cov $(RUST_LLVM_BIN_DIR)/llvm-cov.exe) llvm-cov)
LLVM_PROFDATA ?= $(firstword \
  $(wildcard $(RUST_LLVM_BIN_DIR)/llvm-profdata $(RUST_LLVM_BIN_DIR)/llvm-profdata.exe) llvm-profdata)

# Targets ---------------------------------------------------------------------------------------------------

bench:
	@$(call print-target,$@)
	@cargo +nightly bench

# @todo Build specific target using the TARGET parameter
build:
	@$(call print-target,$@)
	@cargo build $(CARGO_FLAGS)

check:
	@$(call print-target,$@)
	@cargo +nightly clippy $(CARGO_FLAGS) --all-features --all-targets

clean:
	@$(call print-target,$@)
	@cargo clean
	@rm -frv $(shell find -name __pycache__ -type d)

doc:
	@$(call print-target,$@)
	RUSTDOCFLAGS="--cfg docsrs --html-in-header $(KATEX_HTML)" \
	  cargo +nightly doc $(CARGO_FLAGS) --all-features --no-deps

# @todo Run specific target using the TARGET parameter
run:
	@$(call print-target,$@)
	@cargo run $(CARGO_FLAGS)

test:
	@$(call print-target,$@)
ifneq ($(COVERAGE),1)
	@cargo test $(CARGO_FLAGS)
else
	@# The raw profile format depends on the LLVM version, so the LLVM tools must match `rustc`'s LLVM
	@rustc_llvm=$$(rustc +nightly -vV | sed -n 's/^LLVM version: \([0-9]*\).*/\1/p'); \
	  for tool in $(LLVM_PROFDATA) $(LLVM_COV); do \
	    tool_llvm=$$($$tool --version 2>/dev/null | sed -n 's/.*LLVM version \([0-9]*\).*/\1/p' | head -n 1); \
	    if [ "$$tool_llvm" != "$$rustc_llvm" ]; then \
	      echo "error: \`$$tool\` uses LLVM $${tool_llvm:-?}, but \`rustc +nightly\` uses LLVM $$rustc_llvm." >&2; \
	      echo "Install the matching tools with \`rustup +nightly component add llvm-tools\`, or set" >&2; \
	      echo "\`LLVM_PROFDATA\` and \`LLVM_COV\` to LLVM $$rustc_llvm tools." >&2; \
	      exit 1; \
	    fi; \
	  done
	@rm -fr $(COVERAGE_DIR)
	@mkdir -p $(PROFRAW_DIR)
	@# Run instrumented tests. Each process writes its own `.profraw` file to `PROFRAW_DIR`; absolute
	@# paths are required because documentation tests run in a different working directory.
	@# Documentation-test executables are kept so that `llvm-cov` can read their coverage mappings
	@CARGO_INCREMENTAL=0 \
	  LLVM_PROFILE_FILE="$(abspath $(PROFRAW_DIR))/cargo-test-%p-%m.profraw" \
	  RUSTDOCFLAGS="$(COVERAGE_RUSTFLAGS) -Z unstable-options --persist-doctests $(abspath $(DOCTEST_BIN_DIR))" \
	  RUSTFLAGS="$(COVERAGE_RUSTFLAGS)" \
	  cargo +nightly test $(CARGO_FLAGS)
	@# Merge raw profiles
	@$(LLVM_PROFDATA) merge -sparse $(PROFRAW_DIR)/*.profraw -o $(PROFDATA_FILE)
	@# Collect the instrumented executables: test executables as reported by Cargo (same flags, so
	@# nothing is rebuilt) and documentation-test executables. Then create the HTML and the summary
	@# report
	@set -e; \
	  objects=$$( \
	    CARGO_INCREMENTAL=0 RUSTFLAGS="$(COVERAGE_RUSTFLAGS)" \
	      cargo +nightly test $(CARGO_FLAGS) --no-run --message-format=json 2>/dev/null \
	      | grep -o '"executable":"[^"]*"' | sed 's/^"executable":"//; s/"$$//; s/\\\\/\\/g'; \
	    if [ -d $(DOCTEST_BIN_DIR) ]; then \
	      find $(DOCTEST_BIN_DIR) -type f \( -name rust_out -o -name rust_out.exe \); \
	    fi); \
	  object_args=$$(for o in $$objects; do printf -- '-object %s ' "$$o"; done); \
	  $(LLVM_COV) show $$object_args \
	    -instr-profile=$(PROFDATA_FILE) \
	    -ignore-filename-regex='$(COVERAGE_IGNORE_REGEX)' \
	    -format=html -output-dir=$(COVERAGE_DIR)/html \
	    -show-branches=count -show-line-counts-or-regions -show-instantiations=false; \
	  $(LLVM_COV) report $$object_args \
	    -instr-profile=$(PROFDATA_FILE) \
	    -ignore-filename-regex='$(COVERAGE_IGNORE_REGEX)'
	@# Remove raw profiles and documentation-test executables
	@rm -fr $(PROFRAW_DIR) $(DOCTEST_BIN_DIR)
	@echo Created $(COVERAGE_DIR)/html/index.html
endif

# Rust-specific targets -------------------------------------------------------------------------------------

fmt-check:
	@$(call print-target,$@)
	@cargo +nightly fmt --check

miri-run:
	@$(call print-target,$@)
	@cargo +nightly miri run

miri-test:
	@$(call print-target,$@)
	@cargo +nightly miri test

# Find the minimum supported Rust version (MSRV)
msrv:
	@$(call print-target,$@)
	@cargo msrv find

# Run documentation tests exclusively
test-doc:
	@$(call print-target,$@)
	@cargo test $(CARGO_FLAGS) --doc -- --show-output

# EOF
