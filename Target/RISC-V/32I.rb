require_relative "encoding"
require_relative "regfile"
require_relative "ir_ops"
require_relative "../../Generic/base"

module RV32I
    extend SimInfra

    Instruction(:ADD, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:add, rd, rs1, rs2)
        asm { "add #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) + read_reg(rs2)) }
    }

    Instruction(:SUB, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sub, rd, rs1, rs2)
        asm { "sub #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) - read_reg(rs2)) }
    }

    Instruction(:SLL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sll, rd, rs1, rs2)
        asm { "sll #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) << (read_reg(rs2) & 0x1f)) }
    }

    Instruction(:SLT, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:slt, rd, rs1, rs2)
        asm { "slt #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) < read_reg(rs2)) }
    }

    Instruction(:SLTU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sltu, rd, rs1, rs2)
        asm { "sltu #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, sltu(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:XOR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:xor, rd, rs1, rs2)
        asm { "xor #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) ^ read_reg(rs2)) }
    }

    Instruction(:SRL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:srl, rd, rs1, rs2)
        asm { "srl #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) >> (read_reg(rs2) & 0x1f)) }
    }

    Instruction(:SRA, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:sra, rd, rs1, rs2)
        asm { "sra #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, sra(read_reg(rs1), read_reg(rs2) & 0x1f)) }
    }

    Instruction(:OR, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:or, rd, rs1, rs2)
        asm { "or #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) | read_reg(rs2)) }
    }

    Instruction(:AND, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_alu(:and, rd, rs1, rs2)
        asm { "and #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, read_reg(rs1) & read_reg(rs2)) }
    }

    Instruction(:ADDI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:addi, rd, rs1, imm)
        asm { "addi #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, read_reg(rs1) + imm) }
    }

    Instruction(:SLTI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:slti, rd, rs1, imm)
        asm { "slti #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, read_reg(rs1) < imm) }
    }

    Instruction(:SLTIU, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:sltiu, rd, rs1, imm)
        asm { "sltiu #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, sltu(read_reg(rs1), imm)) }
    }

    Instruction(:XORI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:xori, rd, rs1, imm)
        asm { "xori #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, read_reg(rs1) ^ imm) }
    }

    Instruction(:ORI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:ori, rd, rs1, imm)
        asm { "ori #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, read_reg(rs1) | imm) }
    }

    Instruction(:ANDI, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_alu(:andi, rd, rs1, imm)
        asm { "andi #{rd}, #{rs1}, #{imm}" }
        code { write_reg(rd, read_reg(rs1) & imm) }
    }

    Instruction(:SLLI, XReg(:rd), XReg(:rs1), Imm(:shamt, 5, false)) {
        encoding *format_i_shift_alu(:slli, rd, rs1, shamt)
        asm { "slli #{rd}, #{rs1}, #{shamt}" }
        code { write_reg(rd, read_reg(rs1) << shamt) }
    }

    Instruction(:SRLI, XReg(:rd), XReg(:rs1), Imm(:shamt, 5, false)) {
        encoding *format_i_shift_alu(:srli, rd, rs1, shamt)
        asm { "srli #{rd}, #{rs1}, #{shamt}" }
        code { write_reg(rd, read_reg(rs1) >> shamt) }
    }

    Instruction(:SRAI, XReg(:rd), XReg(:rs1), Imm(:shamt, 5, false)) {
        encoding *format_i_shift_alu(:srai, rd, rs1, shamt)
        asm { "srai #{rd}, #{rs1}, #{shamt}" }
        code { write_reg(rd, sra(read_reg(rs1), shamt)) }
    }

    Instruction(:LB, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_load(:lb, rd, rs1, imm)
        asm { "lb #{rd}, #{imm}(#{rs1})" }
        code { write_reg(rd, load8(read_reg(rs1) + imm)) }
    }

    Instruction(:LH, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_load(:lh, rd, rs1, imm)
        asm { "lh #{rd}, #{imm}(#{rs1})" }
        code { write_reg(rd, load16(read_reg(rs1) + imm)) }
    }

    Instruction(:LW, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_load(:lw, rd, rs1, imm)
        asm { "lw #{rd}, #{imm}(#{rs1})" }
        code { write_reg(rd, load32(read_reg(rs1) + imm)) }
    }

    Instruction(:LBU, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_load(:lbu, rd, rs1, imm)
        asm { "lbu #{rd}, #{imm}(#{rs1})" }
        code { write_reg(rd, load8u(read_reg(rs1) + imm)) }
    }

    Instruction(:LHU, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i_load(:lhu, rd, rs1, imm)
        asm { "lhu #{rd}, #{imm}(#{rs1})" }
        code { write_reg(rd, load16u(read_reg(rs1) + imm)) }
    }

    Instruction(:SB, XReg(:rs1), XReg(:rs2), Imm(:imm)) {
        encoding *format_s_store(:sb, rs1, rs2, imm)
        asm { "sb #{rs2}, #{imm}(#{rs1})" }
        code { store8(read_reg(rs1) + imm, read_reg(rs2)) }
    }

    Instruction(:SH, XReg(:rs1), XReg(:rs2), Imm(:imm)) {
        encoding *format_s_store(:sh, rs1, rs2, imm)
        asm { "sh #{rs2}, #{imm}(#{rs1})" }
        code { store16(read_reg(rs1) + imm, read_reg(rs2)) }
    }

    Instruction(:SW, XReg(:rs1), XReg(:rs2), Imm(:imm)) {
        encoding *format_s_store(:sw, rs1, rs2, imm)
        asm { "sw #{rs2}, #{imm}(#{rs1})" }
        code { store32(read_reg(rs1) + imm, read_reg(rs2)) }
    }

    Instruction(:BEQ, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:beq, rs1, rs2, imm)
        asm { "beq #{rs1}, #{rs2}, #{imm}" }
        code { branch(eq(read_reg(rs1), read_reg(rs2)), get_pc + imm) }
    }

    Instruction(:BNE, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:bne, rs1, rs2, imm)
        asm { "bne #{rs1}, #{rs2}, #{imm}" }
        code { branch(ne(read_reg(rs1), read_reg(rs2)), get_pc + imm) }
    }

    Instruction(:BLT, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:blt, rs1, rs2, imm)
        asm { "blt #{rs1}, #{rs2}, #{imm}" }
        code { branch(read_reg(rs1) < read_reg(rs2), get_pc + imm) }
    }

    Instruction(:BGE, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:bge, rs1, rs2, imm)
        asm { "bge #{rs1}, #{rs2}, #{imm}" }
        code { branch(read_reg(rs1) >= read_reg(rs2), get_pc + imm) }
    }

    Instruction(:BLTU, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:bltu, rs1, rs2, imm)
        asm { "bltu #{rs1}, #{rs2}, #{imm}" }
        code { branch(ltu(read_reg(rs1), read_reg(rs2)), get_pc + imm) }
    }

    Instruction(:BGEU, XReg(:rs1), XReg(:rs2), Imm(:imm, 13, true)) {
        encoding *format_b_branch(:bgeu, rs1, rs2, imm)
        asm { "bgeu #{rs1}, #{rs2}, #{imm}" }
        code { branch(geu(read_reg(rs1), read_reg(rs2)), get_pc + imm) }
    }

    Instruction(:JAL, XReg(:rd), Imm(:imm, 21, true)) {
        encoding *format_j(0b1101111, rd, imm)
        asm { "jal #{rd}, #{imm}" }
        code {
            write_reg(rd, get_pc + 4)
            set_next_pc(get_pc + imm)
        }
    }

    Instruction(:JALR, XReg(:rd), XReg(:rs1), Imm(:imm)) {
        encoding *format_i(0b1100111, 0b000, rd, rs1, imm)
        asm { "jalr #{rd}, #{rs1}, #{imm}" }
        code {
            write_reg(rd, get_pc + 4)
            set_next_pc((read_reg(rs1) + imm) & 0xFFFFFFFE)
        }
    }

    Instruction(:LUI, XReg(:rd), Imm(:imm, 20, false)) {
        encoding *format_u(0b0110111, rd, imm)
        asm { "lui #{rd}, #{imm}" }
        code { write_reg(rd, imm) }
    }

    Instruction(:AUIPC, XReg(:rd), Imm(:imm, 20, false)) {
        encoding *format_u(0b0010111, rd, imm)
        asm { "auipc #{rd}, #{imm}" }
        code { write_reg(rd, get_pc + imm) } 
    }

    Instruction(:ECALL, ) {
        encoding :I, [
            field(:imm, 31, 20, 0),
            field(:rs1, 19, 15, 0),
            field(:funct3, 14, 12, 0),
            field(:rd, 11, 7, 0),
            field(:opcode, 6, 0, 0b1110011),
        ]
        asm { "ecall" }
        code {}
    }

    Instruction(:EBREAK, ) {
        encoding :I, [
            field(:imm, 31, 20, 1),
            field(:rs1, 19, 15, 0),
            field(:funct3, 14, 12, 0),
            field(:rd, 11, 7, 0),
            field(:opcode, 6, 0, 0b1110011),
        ]
        asm { "ebreak" }
        code {}
    }

    Instruction(:FENCE, Imm(:pred, 4, false), Imm(:succ, 4, false)) {
        encoding :I, [
            field(:fm, 31, 28, 0),
            field(:pred, 27, 24, :imm4),
            field(:succ, 23, 20, :imm4),
            field(:rs1, 19, 15, 0),
            field(:funct3, 14, 12, 0),
            field(:rd, 11, 7, 0),
            field(:opcode, 6, 0, 0b0001111),
        ]
        asm { "fence #{pred}, #{succ}" }
        code {}
    }
end
