#!/usr/bin/ruby

require_relative "Generic/base"
require_relative "Generic/regfile_config"
require_relative "Target/RISC-V/ir_ops"
require_relative "Generic/builder"
require_relative "Target/RISC-V/config"
require_relative "Target/RISC-V/32I"

class DecodeTreeBuilder
    InsnEncoding = Struct.new(:name, :mask, :match, :info)

    def initialize(instructions)
        @encodings = extract_encodings(instructions)
    end

    attr_reader :encodings

    def extract_encodings(instructions)
        result = []
        instructions.each do |insn|
            next unless insn.fields
            
            mask = 0
            match = 0
            
            insn.fields.each do |field|
                next unless field.value.is_a?(Integer)
                
                msb, lsb = field.from, field.to
                width = msb - lsb + 1
                field_mask = ((1 << width) - 1) << lsb
                field_val = (field.value & ((1 << width) - 1)) << lsb
                
                mask |= field_mask
                match |= field_val
            end
            
            result << InsnEncoding.new(insn.name, mask, match, insn)
        end
        result
    end

    def get_lead_bits(insn_list, separ_mask)
        lead_bits = []
        
        32.times do |bit|
            bit_mask = 1 << bit
            next if (separ_mask & bit_mask) != 0 
            
            all_fixed = insn_list.all? { |enc| (enc.mask & bit_mask) != 0 }
            next unless all_fixed
            
            values = insn_list.map { |enc| (enc.match >> bit) & 1 }.uniq
            
            lead_bits << bit if values.size > 1
        end
        
        lead_bits.sort
    end

    def get_maj_range(lead_bits)
        return nil if lead_bits.empty?
        
        ranges = []
        start_bit = lead_bits[0]
        end_bit = lead_bits[0]
        
        (1...lead_bits.size).each do |i|
            if lead_bits[i] == end_bit + 1
                end_bit = lead_bits[i]
            else
                ranges << [end_bit, start_bit]
                start_bit = lead_bits[i]
                end_bit = lead_bits[i]
            end
        end
        ranges << [end_bit, start_bit]
        
        ranges.max_by { |r| r[0] - r[1] + 1 }
    end

    def filter_instructions(insn_list, node, separ_mask)
        insn_list.select do |enc|
            fixed_in_both = enc.mask & separ_mask
            (enc.match & fixed_in_both) == (node & fixed_in_both)
        end
    end

    def make_child(node, separ_mask, insn_list)
        sublist = filter_instructions(insn_list, node, separ_mask)
        
        return nil if sublist.empty?
        return { leaf: sublist.first } if sublist.size == 1
        
        lead_bits = get_lead_bits(sublist, separ_mask)
        
        return { leaf: sublist.first } if lead_bits.empty?
        
        maj_range = get_maj_range(lead_bits)
        return { leaf: sublist.first } unless maj_range
        
        msb, lsb = maj_range
        width = msb - lsb + 1
        field_mask = ((1 << width) - 1) << lsb
        
        subtree = {
            range: [msb, lsb],
            nodes: {}
        }
        
        new_mask = separ_mask | field_mask
        
        seen_values = sublist.map { |enc| (enc.match >> lsb) & ((1 << width) - 1) }.uniq.sort
        
        seen_values.each do |node_value|
            actual_node = node | (node_value << lsb)
            child = make_child(actual_node, new_mask, sublist)
            subtree[:nodes][node_value] = child if child
        end
        
        return nil if subtree[:nodes].empty?
        subtree
    end

    def build_tree
        return nil if @encodings.empty?
        
        lead_bits = get_lead_bits(@encodings, 0)
        return nil if lead_bits.empty?
        
        maj_range = get_maj_range(lead_bits)
        return nil unless maj_range
        
        msb, lsb = maj_range
        width = msb - lsb + 1
        field_mask = ((1 << width) - 1) << lsb
        
        tree = {
            range: [msb, lsb],
            nodes: {}
        }
        
        seen_values = @encodings.map { |enc| (enc.match >> lsb) & ((1 << width) - 1) }.uniq.sort
        
        seen_values.each do |node_value|
            actual_node = node_value << lsb
            child = make_child(actual_node, field_mask, @encodings)
            tree[:nodes][node_value] = child if child
        end
        
        tree
    end
end



class IrCompiler
    def initialize(scope, args, format, fields)
        @scope = scope
        @args = args
        @format = format
        @fields = fields || []
        @operand_map = build_operand_map
    end

    def build_operand_map
        map = {}
        @fields.each do |f|
            next if f.value.is_a?(Integer)
            
            name = f.name.to_s
            case f.value
            when :reg
                map[name] = "d.op_#{name}"
            when :shamt
                map[name] = "d.op_#{name}"
            when :imm12, :imm12_s, :imm13_b, :imm20_u, :imm21_j
                map[name] = "d.op_#{name}_#{f.value}"
            when :imm4
                map[name] = "d.op_#{name}"
            end
        end
        map
    end

    def compile
        lines = []
        @scope.tree.each do |stmt|
            line = compile_stmt(stmt)
            lines << line if line
        end
        lines.join("\n")
    end

    private

    def compile_stmt(stmt)
        return nil if stmt.name == :new_var || stmt.name == :new_const
        
        op = SimInfra::IR_OPS[stmt.name]
        
        unless op
            return "// Unknown IR operation: #{stmt.name}"
        end
        
        return nil unless op.cpp_template
        
        result = op.cpp_template.dup
        stmt.oprnds.each_with_index do |oprnd, idx|
            result.gsub!("%#{idx}", vn(oprnd))
        end
        
        result
    end

    def vn(v)
        case v
        when SimInfra::Var
            n = v.name.to_s
            @operand_map[n] || n
        when SimInfra::Constant then v.value.to_s
        when Integer then v.to_s
        else v.inspect
        end
    end
end



class CppGenerator
    def initialize(instructions, cpu_config = nil)
        @instructions = instructions
        @cpu_config = cpu_config || SimInfra.cpu_config
        @output_dir = "generated"
        @tree_builder = DecodeTreeBuilder.new(instructions)
        @decode_tree = @tree_builder.build_tree
    end

    def generate
        Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
        
        generate_defs_h
        generate_cpu_state_h
        generate_memory_h
        generate_decoder_h
        generate_executor_h
        generate_executor_cpp
        generate_hart_h
        generate_hart_cpp
        generate_machine_h
        generate_machine_cpp
        generate_main_cpp
        generate_makefile
    end

    private

    def get_word_type
        return "uint32_t" unless @cpu_config
        case @cpu_config.word_size
        when 32 then "uint32_t"
        when 64 then "uint64_t"
        else "uint32_t"
        end
    end

    def get_sword_type
        return "int32_t" unless @cpu_config
        case @cpu_config.word_size
        when 32 then "int32_t"
        when 64 then "int64_t"
        else "int32_t"
        end
    end

    def get_num_regs
        return 32 unless @cpu_config && @cpu_config.reg_files[:x]
        @cpu_config.reg_files[:x].num_regs
    end

    def get_zero_reg
        return 0 unless @cpu_config && @cpu_config.reg_files[:x]
        @cpu_config.reg_files[:x].zero_reg
    end

    def get_insn_size
        return 4 unless @cpu_config
        @cpu_config.insn_size
    end

    def get_mem_base
        return 0x80000000 unless @cpu_config
        @cpu_config.memory_config.base_addr
    end

    def get_mem_size
        return 128 * 1024 * 1024 unless @cpu_config
        @cpu_config.memory_config.mem_size
    end

    def get_reset_pc
        return 0x80000000 unless @cpu_config
        @cpu_config.reset_config.pc_value
    end

    def generate_defs_h
        word_type = get_word_type
        sword_type = get_sword_type
        num_regs = get_num_regs
        insn_size = get_insn_size
        mem_base = get_mem_base
        mem_size = get_mem_size
        reset_pc = get_reset_pc
        
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef DEFS_H
        #define DEFS_H

        #include <cstdint>

        using word_t = #{word_type};
        using sword_t = #{sword_type};
        using dword_t = uint64_t;
        using sdword_t = int64_t;

        constexpr word_t INSN_SIZE = #{insn_size};
        constexpr int NUM_REGS = #{num_regs};
        constexpr word_t MEM_BASE = 0x#{mem_base.to_s(16)}u;
        constexpr word_t MEM_SIZE = #{mem_size}u;
        constexpr word_t RESET_PC = 0x#{reset_pc.to_s(16)}u;

        #endif
        CPP

        File.write("#{@output_dir}/defs.h", code)
    end

    def generate_cpu_state_h
        zero_reg = get_zero_reg
        zero_check = zero_reg ? "if (rd != #{zero_reg}) " : ""
        zero_read = zero_reg ? "(rs == #{zero_reg}) ? 0 : " : ""
        
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef CPU_STATE_H
        #define CPU_STATE_H

        #include "defs.h"

        class Memory;

        struct CpuState {
            word_t regs[NUM_REGS];
            word_t pc;
            word_t next_pc;
            bool running;
            int exit_code;
            uint64_t insn_count;
            Memory* mem;

            CpuState() : running(false), exit_code(0), insn_count(0), mem(nullptr) {
                reset();
            }

            void reset() {
                for (int i = 0; i < NUM_REGS; i++) regs[i] = 0;
                pc = RESET_PC;
                next_pc = pc + INSN_SIZE;
                running = true;
                exit_code = 0;
                insn_count = 0;
            }

            void write_reg(int rd, word_t val) {
                #{zero_check}regs[rd] = val;
            }

            word_t read_reg(int rs) const {
                return #{zero_read}regs[rs];
            }
        };

        #endif
        CPP

        File.write("#{@output_dir}/cpu_state.h", code)
    end

    def generate_memory_h
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef MEMORY_H
        #define MEMORY_H

        #include <cstdint>
        #include <cstring>
        #include <cstdio>
        #include "defs.h"

        class Memory {
        public:
            static constexpr word_t BASE = MEM_BASE;
            static constexpr word_t SIZE = MEM_SIZE;

        private:
            uint8_t* data;
            word_t tohost_addr;
            bool tohost_written;

        public:
            Memory() : tohost_addr(0), tohost_written(false) {
                data = new uint8_t[SIZE];
                memset(data, 0, SIZE);
            }

            ~Memory() { delete[] data; }
            Memory(const Memory&) = delete;
            Memory& operator=(const Memory&) = delete;

            void reset() {
                memset(data, 0, SIZE);
                tohost_written = false;
            }

            uint8_t* raw() { return data; }
            const uint8_t* raw() const { return data; }

            void set_tohost_addr(word_t addr) { tohost_addr = addr; }
            word_t get_tohost_addr() const { return tohost_addr; }
            bool was_tohost_written() const { return tohost_written; }
            void clear_tohost_written() { tohost_written = false; }

            word_t translate_addr(word_t addr, word_t pc) const {
                if (addr >= BASE && addr < BASE + SIZE) return addr - BASE;
                if (addr < SIZE) return addr;
                fprintf(stderr, "Invalid memory access at 0x%08x (PC=0x%08x)\\n", addr, pc);
                return 0;
            }

            uint8_t load8(word_t addr, word_t pc) const {
                word_t phys = translate_addr(addr, pc);
                return data[phys];
            }

            uint16_t load16(word_t addr, word_t pc) const {
                word_t phys = translate_addr(addr, pc);
                return data[phys] | (data[phys + 1] << 8);
            }

            uint32_t load32(word_t addr, word_t pc) const {
                word_t phys = translate_addr(addr, pc);
                return data[phys] | (data[phys + 1] << 8) |
                       (data[phys + 2] << 16) | (data[phys + 3] << 24);
            }

            void store8(word_t addr, uint8_t val, word_t pc) {
                word_t phys = translate_addr(addr, pc);
                data[phys] = val;
                check_tohost(addr);
            }

            void store16(word_t addr, uint16_t val, word_t pc) {
                word_t phys = translate_addr(addr, pc);
                data[phys] = val & 0xFF;
                data[phys + 1] = (val >> 8) & 0xFF;
                check_tohost(addr);
            }

            void store32(word_t addr, word_t val, word_t pc) {
                word_t phys = translate_addr(addr, pc);
                data[phys] = val & 0xFF;
                data[phys + 1] = (val >> 8) & 0xFF;
                data[phys + 2] = (val >> 16) & 0xFF;
                data[phys + 3] = (val >> 24) & 0xFF;
                check_tohost(addr);
            }

        private:
            void check_tohost(word_t addr) {
                if (tohost_addr != 0 && addr == tohost_addr) tohost_written = true;
            }
        };

        #endif
        CPP

        File.write("#{@output_dir}/memory.h", code)
    end

    def collect_operand_fields
        fields = {}
        @instructions.each do |insn|
            next unless insn.fields
            insn.fields.each do |f|
                next if f.value.is_a?(Integer)
                name = f.name.to_s
                key = case f.value
                      when :imm12, :imm12_s, :imm13_b, :imm20_u, :imm21_j
                          "#{name}_#{f.value}"
                      else
                          name
                      end
                fields[key] ||= { name: name, msb: f.from, lsb: f.to, type: f.value }
            end
        end
        fields
    end

    def generate_field_extraction(key, info)
        msb, lsb = info[:msb], info[:lsb]
        width = msb - lsb + 1
        mask = (1 << width) - 1
        
        case info[:type]
        when :reg
            "d.op_#{key} = (insn >> #{lsb}) & 0x#{mask.to_s(16)};"
        when :shamt
            "d.op_#{key} = (insn >> #{lsb}) & 0x#{mask.to_s(16)};"
        when :imm12
            "d.op_#{key} = sext<12, sword_t>(insn >> #{lsb});"
        when :imm12_s
            "d.op_#{key} = sext<12, sword_t>(((insn >> 25) << 5) | ((insn >> 7) & 0x1F));"
        when :imm13_b
            "d.op_#{key} = sext<13, sword_t>(((insn >> 31) << 12) | (((insn >> 7) & 1) << 11) | (((insn >> 25) & 0x3F) << 5) | (((insn >> 8) & 0xF) << 1));"
        when :imm20_u
            "d.op_#{key} = insn & 0xFFFFF000;"
        when :imm21_j
            "d.op_#{key} = sext<21, sword_t>(((insn >> 31) << 20) | (((insn >> 12) & 0xFF) << 12) | (((insn >> 20) & 1) << 11) | (((insn >> 21) & 0x3FF) << 1));"
        when :imm4
            "d.op_#{key} = (insn >> #{lsb}) & 0xF;"
        else
            "// Unknown field type: #{info[:type]} for #{key}"
        end
    end

    def generate_decoder_h
        op_fields = collect_operand_fields
        
        struct_fields = op_fields.map do |name, info|
            case info[:type]
            when :reg, :shamt, :imm4
                "    word_t op_#{name};"
            else
                "    sword_t op_#{name};"
            end
        end.join("\n")
        
        extractions = op_fields.map { |name, info| "        " + generate_field_extraction(name, info) }.join("\n")
        
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef DECODER_H
        #define DECODER_H

        #include "defs.h"
        #include "../simlib/sext.h"

        enum class Opcode {
            UNKNOWN = 0,
        #{@instructions.select(&:fields).map { |i| "    #{i.name}," }.join("\n")}
        };

        struct DecodedInsn {
            word_t raw;
            Opcode opcode;
        #{struct_fields}
        };

        class Decoder {
        public:
            static DecodedInsn decode(word_t insn) {
                DecodedInsn d;
                d.raw = insn;
                d.opcode = Opcode::UNKNOWN;
                
        #{extractions}
                
        #{generate_decode_tree(@decode_tree, 8)}
                
                return d;
            }
        };

        #endif // DECODER_H
        CPP

        File.write("#{@output_dir}/decoder.h", code)
    end

    def generate_decode_tree(node, indent)
        pfx = " " * indent
        return "#{pfx}// Empty decode tree" unless node
        
        if node[:leaf]
            return "#{pfx}d.opcode = Opcode::#{node[:leaf].name};"
        end
        
        msb, lsb = node[:range]
        width = msb - lsb + 1
        mask = (1 << width) - 1
        
        lines = []
        lines << "#{pfx}switch ((insn >> #{lsb}) & 0x#{mask.to_s(16)}) {"
        
        node[:nodes].keys.sort.each do |val|
            child = node[:nodes][val]
            lines << "#{pfx}case 0x#{val.to_s(16)}: {"
            lines << generate_decode_tree(child, indent + 4)
            lines << "#{pfx}    break;"
            lines << "#{pfx}}"
        end
        
        lines << "#{pfx}}"
        lines.join("\n")
    end

    def generate_executor_h
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef EXECUTOR_H
        #define EXECUTOR_H

        #include "defs.h"
        #include "cpu_state.h"
        #include "memory.h"
        #include "decoder.h"

        class Executor {
        public:
            static void execute(CpuState& cpu, const DecodedInsn& d, Memory& mem);
        };

        #endif // EXECUTOR_H
        CPP

        File.write("#{@output_dir}/executor.h", code)
    end

    def generate_executor_cpp
        code = <<~CPP
        // Auto generated from ProtDSL
        #include "executor.h"
        #include "../simlib/sext.h"
        #include <cstdio>

        void Executor::execute(CpuState& cpu, const DecodedInsn& d, Memory& mem) {
            switch (d.opcode) {
        #{generate_executor_cases}
            case Opcode::UNKNOWN:
            default:
                fprintf(stderr, "Unknown instruction at PC=0x%08x (raw=0x%08x)\\n", cpu.pc, d.raw);
                cpu.running = false;
                break;
            }
        }
        CPP

        File.write("#{@output_dir}/executor.cpp", code)
    end

    def generate_executor_cases
        lines = []
        @instructions.each do |insn|
            next unless insn.fields
            lines << "    case Opcode::#{insn.name}: {"
            lines << gen_insn_code(insn, 8)
            lines << "        break;"
            lines << "    }"
        end
        lines.join("\n")
    end

    def gen_insn_code(insn, indent)
        pfx = " " * indent
        case insn.name
        when :ECALL then ecall_code(pfx)
        when :EBREAK then "#{pfx}cpu.running = false;"
        when :FENCE then "#{pfx};"
        else
            return "#{pfx};" unless insn.code
            compiler = IrCompiler.new(insn.code, insn.args, insn.format, insn.fields)
            compiler.compile.lines.map { |l| "#{pfx}#{l.rstrip}" }.join("\n")
        end
    end

    def ecall_code(pfx)
        <<~CPP.lines.map { |l| "#{pfx}#{l.rstrip}" }.join("\n")
{
    word_t a7 = cpu.read_reg(17);
    switch (a7) {
        case 64: {
            word_t fd = cpu.read_reg(10);
            word_t buf = cpu.read_reg(11);
            word_t len = cpu.read_reg(12);
            if (fd == 1 || fd == 2) {
                for (word_t i = 0; i < len; i++) putchar(mem.load8(buf + i, cpu.pc));
                cpu.write_reg(10, len);
            } else cpu.write_reg(10, (word_t)-1);
            break;
        }
        case 93: cpu.exit_code = cpu.read_reg(10); cpu.running = false; break;
        default: fprintf(stderr, "Unknown syscall %u\\n", a7); cpu.running = false;
    }
}
        CPP
    end

    def generate_hart_h
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef HART_H
        #define HART_H

        #include "defs.h"
        #include "cpu_state.h"
        #include "memory.h"
        #include "decoder.h"
        #include "executor.h"

        class Hart {
        public:
            Hart(Memory& mem) : mem_(mem) { reset(); }
            
            void reset() { cpu_.reset(); }
            void set_pc(word_t pc) { cpu_.pc = pc; cpu_.next_pc = pc + INSN_SIZE; }
            
            bool step() {
                if (!cpu_.running) return false;
                word_t raw = mem_.load32(cpu_.pc, cpu_.pc);
                DecodedInsn d = Decoder::decode(raw);
                cpu_.next_pc = cpu_.pc + INSN_SIZE;
                Executor::execute(cpu_, d, mem_);
                cpu_.pc = cpu_.next_pc;
                return cpu_.running;
            }
            
            CpuState& cpu() { return cpu_; }

        private:
            CpuState cpu_;
            Memory& mem_;
        };

        #endif // HART_H
        CPP

        File.write("#{@output_dir}/hart.h", code)
    end

    def generate_hart_cpp
        File.write("#{@output_dir}/hart.cpp", "// Auto generated from ProtDSL\n#include \"hart.h\"\n")
    end

    def generate_machine_h
        code = <<~CPP
        // Auto generated from ProtDSL
        #ifndef MACHINE_H
        #define MACHINE_H

        #include "defs.h"
        #include "memory.h"
        #include "../simlib/elf_loader.h"
        #include "hart.h"

        class Machine {
        public:
            Machine() : hart_(mem_) {}

            bool load_elf(const char* filename) {
                word_t entry = 0;
                if (!ElfLoader::load(filename, mem_, entry)) return false;
                hart_.set_pc(entry);
                return true;
            }

            int run() {
                while (hart_.step()) {
                    if (mem_.was_tohost_written()) {
                        word_t tohost = mem_.load32(mem_.get_tohost_addr(), 0);
                        if (tohost & 1) { hart_.cpu().exit_code = tohost >> 1; break; }
                        mem_.clear_tohost_written();
                    }
                }
                return hart_.cpu().exit_code;
            }

            Hart& hart() { return hart_; }
            Memory& memory() { return mem_; }

        private:
            Memory mem_;
            Hart hart_;
        };

        #endif // MACHINE_H
        CPP

        File.write("#{@output_dir}/machine.h", code)
    end

    def generate_machine_cpp
        File.write("#{@output_dir}/machine.cpp", "// Auto generated from ProtDSL\n#include \"machine.h\"\n")
    end

    def generate_main_cpp
        code = <<~CPP
        // Auto generated from ProtDSL
        #include <cstdio>
        #include "machine.h"

        int main(int argc, char* argv[]) {
            if (argc < 2) { fprintf(stderr, "Usage: %s <elf>\\n", argv[0]); return 1; }
            Machine m;
            if (!m.load_elf(argv[1])) { fprintf(stderr, "Failed to load: %s\\n", argv[1]); return 1; }
            return m.run();
        }
        CPP

        File.write("#{@output_dir}/main.cpp", code)
    end

    def generate_makefile
        code = <<~MAKE
        # Auto generated from ProtDSL
        CXX = g++
        CXXFLAGS = -O2 -Wall -Wno-sign-compare -std=c++17 -I../simlib
        TARGET = rv32im_sim
        SRCS = main.cpp machine.cpp hart.cpp executor.cpp
        OBJS = $(SRCS:.cpp=.o)

        all: $(TARGET)
        $(TARGET): $(OBJS)
        \t@$(CXX) $(CXXFLAGS) -o $@ $^
        %.o: %.cpp
        \t@$(CXX) $(CXXFLAGS) -c $< -o $@
        clean:
        \t@rm -f $(OBJS) $(TARGET)
        .PHONY: all clean
        MAKE

        File.write("#{@output_dir}/Makefile", code)
    end
end

CppGenerator.new(SimInfra.instructions).generate
