#!/bin/bash
set +e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RISCV_TESTS="$SCRIPT_DIR/tests/riscv-tests/isa"
SIMULATOR="$SCRIPT_DIR/generated/rv32im_sim"
CC=riscv64-unknown-elf-gcc

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0

echo "  RV32IM Test Suite"
echo ""

if [ ! -f "$SIMULATOR" ]; then
    echo -e "${RED}ERROR: Simulator not found at $SIMULATOR${NC}"
    echo "Run: ruby main.rb && ruby generate_cpp.rb && g++ -O2 -o rv32im_sim rv32im_sim.cpp"
    exit 1
fi

echo "Simulator: $SIMULATOR"
echo "Source:    $SCRIPT_DIR/generated/"
echo ""

run_test() {
    local test_path=$1
    local test_name=$(basename "$test_path")
    
    if [ ! -f "$test_path" ]; then
        return 1
    fi
    
    if [[ "$test_name" == *.dump ]]; then
        return 1
    fi
    
    "$SIMULATOR" "$test_path" >/dev/null 2>&1
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "  ${GREEN}PASS${NC}  $test_name"
        ((PASS++))
    else
        echo -e "  ${RED}FAIL${NC}  $test_name"
        ((FAIL++))
    fi
}

build_rv32um_if_needed() {
    local need_build=0
    
    for t in mul mulh mulhsu mulhu div divu rem remu; do
        if [ ! -f "$RISCV_TESTS/rv32um-p-$t" ]; then
            need_build=1
            break
        fi
    done
    
    if [ $need_build -eq 1 ]; then
        echo "Building RV32UM tests..."
        cd "$RISCV_TESTS"
        for t in mul mulh mulhsu mulhu div divu rem remu; do
            if [ ! -f "rv32um-p-$t" ]; then
                $CC -march=rv32im -mabi=ilp32 -nostdlib -nostartfiles \
                    -I../env/p -Imacros/scalar -T../env/p/link.ld \
                    rv32um/$t.S -o rv32um-p-$t 2>/dev/null || true
            fi
        done
        cd "$SCRIPT_DIR"
        echo ""
    fi
}

echo "=== RV32UI Tests (Base Integer) ==="
for test in $RISCV_TESTS/rv32ui-p-*; do
    run_test "$test"
done
echo ""


echo "=== RV32UM Tests (Multiply/Divide) ==="
build_rv32um_if_needed
for test in $RISCV_TESTS/rv32um-p-*; do
    run_test "$test"
done
echo ""


echo "=============================================="
echo "  SUMMARY"
echo "=============================================="
TOTAL=$((PASS + FAIL))
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASS${NC}"
if [ $FAIL -gt 0 ]; then
    echo -e "  ${RED}Failed: $FAIL${NC}"
else
    echo -e "  Failed: $FAIL"
fi
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests PASSED${NC}"
    exit 0
else
    echo -e "${RED}Some tests FAILED${NC}"
    exit 1
fi
