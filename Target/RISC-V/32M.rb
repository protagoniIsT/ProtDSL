module RV32M
    extend SimInfra

    Instruction(:MUL, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:mul, rd, rs1, rs2)
        asm { "mul #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, mul(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:MULH, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:mulh, rd, rs1, rs2)
        asm { "mulh #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, mulh(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:MULHSU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:mulhsu, rd, rs1, rs2)
        asm { "mulhsu #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, mulhsu(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:MULHU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:mulhu, rd, rs1, rs2)
        asm { "mulhu #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, mulhu(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:DIV, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:div, rd, rs1, rs2)
        asm { "div #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, div(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:DIVU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:divu, rd, rs1, rs2)
        asm { "divu #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, divu(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:REM, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:rem, rd, rs1, rs2)
        asm { "rem #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, rem(read_reg(rs1), read_reg(rs2))) }
    }

    Instruction(:REMU, XReg(:rd), XReg(:rs1), XReg(:rs2)) {
        encoding *format_r_muldiv(:remu, rd, rs1, rs2)
        asm { "remu #{rd}, #{rs1}, #{rs2}" }
        code { write_reg(rd, remu(read_reg(rs1), read_reg(rs2))) }
    }
end
