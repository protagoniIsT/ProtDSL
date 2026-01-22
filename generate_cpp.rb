#!/usr/bin/ruby

require_relative "Generic/base"
require_relative "Target/RISC-V/ir_ops"
require_relative "Generic/builder"
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
    def initialize(instructions)
        @instructions = instructions
        @output_dir = "generated"
        @tree_builder = DecodeTreeBuilder.new(instructions)
        @decode_tree = @tree_builder.build_tree
    end

    def generate
        Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
        
        generate_decoder_h
        generate_executor_h
        generate_executor_cpp
        generate_hart_h
        generate_hart_cpp
        generate_machine_h
        generate_machine_cpp
        generate_main_cpp
        generate_makefile
        
        puts "Generated files in #{@output_dir}/"
    end

    private

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

        #include "../simlib/defs.h"
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

        #include "../simlib/defs.h"
        #include "../simlib/cpu_state.h"
        #include "../simlib/memory.h"
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
        when :EBREAK then "#{pfx}cpu.running = false; // EBREAK"
        when :FENCE then "#{pfx}// FENCE - no-op"
        else
            return "#{pfx}// #{insn.name} - no code" unless insn.code
            compiler = IrCompiler.new(insn.code, insn.args, insn.format, insn.fields)
            "#{pfx}// #{insn.name}\n" + compiler.compile.lines.map { |l| "#{pfx}#{l.rstrip}" }.join("\n")
        end
    end

    def ecall_code(pfx)
        <<~CPP.lines.map { |l| "#{pfx}#{l.rstrip}" }.join("\n")
// ECALL
{
    word_t a7 = cpu.read_reg(17);
    switch (a7) {
        case 64: { // write
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

        #include "../simlib/cpu_state.h"
        #include "../simlib/memory.h"
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

        #include "../simlib/memory.h"
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
        CXXFLAGS = -O2 -Wall -std=c++17 -I../simlib
        TARGET = rv32im_sim
        SRCS = main.cpp machine.cpp hart.cpp executor.cpp
        OBJS = $(SRCS:.cpp=.o)

        all: $(TARGET)
        $(TARGET): $(OBJS)
        \t$(CXX) $(CXXFLAGS) -o $@ $^
        %.o: %.cpp
        \t$(CXX) $(CXXFLAGS) -c $< -o $@
        clean:
        \trm -f $(OBJS) $(TARGET)
        .PHONY: all clean
        MAKE

        File.write("#{@output_dir}/Makefile", code)
    end
end

CppGenerator.new(SimInfra.instructions).generate
