require_relative "../../Generic/base"

module SimInfra
    def format_r(opcode, funct3, funct7, rd, rs1, rs2)
        return :R, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(:opcode, 6, 0, opcode),
            field(:funct7, 31, 25, funct7),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_i(opcode, funct3, rd, rs1, imm)
        return :I, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(imm.name, 31, 20, :imm12),
            field(:opcode, 6, 0, opcode),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_i_shift(opcode, funct3, funct7, rd, rs1, shamt)
        return :I_SHIFT, [
            field(rd.name, 11, 7, :reg),
            field(rs1.name, 19, 15, :reg),
            field(shamt.name, 24, 20, :shamt),
            field(:opcode, 6, 0, opcode),
            field(:funct7, 31, 25, funct7),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_s(opcode, funct3, rs1, rs2, imm)
        return :S, [
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(imm.name, 31, 7, :imm12_s),
            field(:opcode, 6, 0, opcode),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_b(opcode, funct3, rs1, rs2, imm)
        return :B, [
            field(rs1.name, 19, 15, :reg),
            field(rs2.name, 24, 20, :reg),
            field(imm.name, 31, 7, :imm13_b),
            field(:opcode, 6, 0, opcode),
            field(:funct3, 14, 12, funct3),
        ]
    end

    def format_u(opcode, rd, imm)
        return :U, [
            field(rd.name, 11, 7, :reg),
            field(imm.name, 31, 12, :imm20_u),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_j(opcode, rd, imm)
        return :J, [
            field(rd.name, 11, 7, :reg),
            field(imm.name, 31, 12, :imm21_j),
            field(:opcode, 6, 0, opcode),
        ]
    end

    def format_r_alu(name, rd, rs1, rs2)
        funct3, funct7 = {
            add:  [0b000, 0b0000000],
            sub:  [0b000, 0b0100000],
            sll:  [0b001, 0b0000000],
            slt:  [0b010, 0b0000000],
            sltu: [0b011, 0b0000000],
            xor:  [0b100, 0b0000000],
            srl:  [0b101, 0b0000000],
            sra:  [0b101, 0b0100000],
            or:   [0b110, 0b0000000],
            and:  [0b111, 0b0000000],
        }[name]
        format_r(0b0110011, funct3, funct7, rd, rs1, rs2)
    end

    def format_r_muldiv(name, rd, rs1, rs2)
        funct3, funct7 = {
            mul:    [0b000, 0b0000001],
            mulh:   [0b001, 0b0000001],
            mulhsu: [0b010, 0b0000001],
            mulhu:  [0b011, 0b0000001],
            div:    [0b100, 0b0000001],
            divu:   [0b101, 0b0000001],
            rem:    [0b110, 0b0000001],
            remu:   [0b111, 0b0000001],
        }[name]
        format_r(0b0110011, funct3, funct7, rd, rs1, rs2)
    end

    def format_i_alu(name, rd, rs1, imm)
        funct3 = {
            addi:  0b000,
            slti:  0b010,
            sltiu: 0b011,
            xori:  0b100,
            ori:   0b110,
            andi:  0b111,
        }[name]
        format_i(0b0010011, funct3, rd, rs1, imm)
    end

    def format_i_shift_alu(name, rd, rs1, shamt)
        funct3, funct7 = {
            slli: [0b001, 0b0000000],
            srli: [0b101, 0b0000000],
            srai: [0b101, 0b0100000],
        }[name]
        format_i_shift(0b0010011, funct3, funct7, rd, rs1, shamt)
    end

    def format_i_load(name, rd, rs1, imm)
        funct3 = {
            lb:  0b000,
            lh:  0b001,
            lw:  0b010,
            lbu: 0b100,
            lhu: 0b101,
        }[name]
        format_i(0b0000011, funct3, rd, rs1, imm)
    end

    def format_s_store(name, rs1, rs2, imm)
        funct3 = {
            sb: 0b000,
            sh: 0b001,
            sw: 0b010,
        }[name]
        format_s(0b0100011, funct3, rs1, rs2, imm)
    end

    def format_b_branch(name, rs1, rs2, imm)
        funct3 = {
            beq:  0b000,
            bne:  0b001,
            blt:  0b100,
            bge:  0b101,
            bltu: 0b110,
            bgeu: 0b111,
        }[name]
        format_b(0b1100011, funct3, rs1, rs2, imm)
    end
end
