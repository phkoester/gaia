#
# Makefile-Rust.mk
#
# Parameters:
#
# - COVERAGE
#     If set to 1, determine test coverage
# - GAIA_DIR
# - GAIA_BUILD_TYPE
#     The build type: `debug` or `release`
#
# Targets:
#
# - bench
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

# Local Rustdoc invocation needs an absolute path
KATEX_HTML := $(realpath $(GAIA_DIR)/src/main/html/katex.html)
TARGET_DIR := target/$(GAIA_BUILD_TYPE)

TEST_BIN_DIR := $(TARGET_DIR)/deps
TEST_COVERAGE_DIR := $(TARGET_DIR)/coverage

# Configure Cargo -------------------------------------------------------------------------------------------

CARGO_FLAGS :=
ifeq ($(GAIA_BUILD_TYPE),release)
  CARGO_FLAGS += --release
endif

# Targets ---------------------------------------------------------------------------------------------------

bench:
	@$(call print-target,$@)
	@cargo +nightly bench

build:
	@$(call print-target,$@)
	@cargo build $(CARGO_FLAGS)

check:
	@$(call print-target,$@)
	@cargo +nightly clippy $(CARGO_FLAGS) --all-features --all-targets

clean:
	@$(call print-target,$@)
	@cargo clean

doc:
	@$(call print-target,$@)
	RUSTDOCFLAGS="--cfg docsrs --html-in-header $(KATEX_HTML)" \
	  cargo +nightly doc $(CARGO_FLAGS) --all-features --no-deps

run:
	@$(call print-target,$@)
	@cargo run $(CARGO_FLAGS)

test:
	@$(call print-target,$@)
ifneq ($(COVERAGE),1)
	@cargo test $(CARGO_FLAGS)
else
	@rm -rf $(TEST_COVERAGE_DIR)
	@CARGO_INCREMENTAL=0 \
	    LLVM_PROFILE_FILE=cargo-test-%p-%m.profraw \
	    RUSTDOCFLAGS="-C instrument-coverage -Z unstable-options --persist-doctests $(TEST_BIN_DIR)" \
	    RUSTFLAGS="-C instrument-coverage" \
   	    cargo +nightly test $(CARGO_FLAGS)
	@grcov --binary-path $(TEST_BIN_DIR) -s . -t html --branch --ignore-not-existing \
	  -o $(TEST_COVERAGE_DIR)/html .
	@# Remove `.profraw` files
	@rm -v $$(find -name "cargo-test-*.profraw")
	@# Remove documentation-test executables
	@rm -frv $(TEST_BIN_DIR)/src_*_rs_*
	@echo Created $(TEST_COVERAGE_DIR)/html/index.html
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
