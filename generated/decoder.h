// Auto generated from ProtDSL
#ifndef DECODER_H
#define DECODER_H

#include "../simlib/defs.h"
#include "../simlib/sext.h"

enum class Opcode {
    UNKNOWN = 0,
    ADD,
    SUB,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    SRA,
    OR,
    AND,
    ADDI,
    SLTI,
    SLTIU,
    XORI,
    ORI,
    ANDI,
    SLLI,
    SRLI,
    SRAI,
    LB,
    LH,
    LW,
    LBU,
    LHU,
    SB,
    SH,
    SW,
    BEQ,
    BNE,
    BLT,
    BGE,
    BLTU,
    BGEU,
    JAL,
    JALR,
    LUI,
    AUIPC,
    ECALL,
    EBREAK,
    FENCE,
    MUL,
    MULH,
    MULHSU,
    MULHU,
    DIV,
    DIVU,
    REM,
    REMU,
};

struct DecodedInsn {
    word_t raw;
    Opcode opcode;
    word_t op_rd;
    word_t op_rs1;
    word_t op_rs2;
    sword_t op_imm_imm12;
    word_t op_shamt;
    sword_t op_imm_imm12_s;
    sword_t op_imm_imm13_b;
    sword_t op_imm_imm21_j;
    sword_t op_imm_imm20_u;
    word_t op_pred;
    word_t op_succ;
};

class Decoder {
public:
    static DecodedInsn decode(word_t insn) {
        DecodedInsn d;
        d.raw = insn;
        d.opcode = Opcode::UNKNOWN;
        
        d.op_rd = (insn >> 7) & 0x1f;
        d.op_rs1 = (insn >> 15) & 0x1f;
        d.op_rs2 = (insn >> 20) & 0x1f;
        d.op_imm_imm12 = sext<12, sword_t>(insn >> 20);
        d.op_shamt = (insn >> 20) & 0x1f;
        d.op_imm_imm12_s = sext<12, sword_t>(((insn >> 25) << 5) | ((insn >> 7) & 0x1F));
        d.op_imm_imm13_b = sext<13, sword_t>(((insn >> 31) << 12) | (((insn >> 7) & 1) << 11) | (((insn >> 25) & 0x3F) << 5) | (((insn >> 8) & 0xF) << 1));
        d.op_imm_imm21_j = sext<21, sword_t>(((insn >> 31) << 20) | (((insn >> 12) & 0xFF) << 12) | (((insn >> 20) & 1) << 11) | (((insn >> 21) & 0x3FF) << 1));
        d.op_imm_imm20_u = insn & 0xFFFFF000;
        d.op_pred = (insn >> 24) & 0xF;
        d.op_succ = (insn >> 20) & 0xF;
        
        switch ((insn >> 2) & 0x1f) {
        case 0x0: {
            switch ((insn >> 12) & 0x7) {
            case 0x0: {
                d.opcode = Opcode::LB;
                break;
            }
            case 0x1: {
                d.opcode = Opcode::LH;
                break;
            }
            case 0x2: {
                d.opcode = Opcode::LW;
                break;
            }
            case 0x4: {
                d.opcode = Opcode::LBU;
                break;
            }
            case 0x5: {
                d.opcode = Opcode::LHU;
                break;
            }
            }
            break;
        }
        case 0x3: {
            d.opcode = Opcode::FENCE;
            break;
        }
        case 0x4: {
            switch ((insn >> 12) & 0x7) {
            case 0x0: {
                d.opcode = Opcode::ADDI;
                break;
            }
            case 0x1: {
                d.opcode = Opcode::SLLI;
                break;
            }
            case 0x2: {
                d.opcode = Opcode::SLTI;
                break;
            }
            case 0x3: {
                d.opcode = Opcode::SLTIU;
                break;
            }
            case 0x4: {
                d.opcode = Opcode::XORI;
                break;
            }
            case 0x5: {
                switch ((insn >> 30) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::SRLI;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::SRAI;
                    break;
                }
                }
                break;
            }
            case 0x6: {
                d.opcode = Opcode::ORI;
                break;
            }
            case 0x7: {
                d.opcode = Opcode::ANDI;
                break;
            }
            }
            break;
        }
        case 0x5: {
            d.opcode = Opcode::AUIPC;
            break;
        }
        case 0x8: {
            switch ((insn >> 12) & 0x3) {
            case 0x0: {
                d.opcode = Opcode::SB;
                break;
            }
            case 0x1: {
                d.opcode = Opcode::SH;
                break;
            }
            case 0x2: {
                d.opcode = Opcode::SW;
                break;
            }
            }
            break;
        }
        case 0xc: {
            switch ((insn >> 12) & 0x7) {
            case 0x0: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    switch ((insn >> 30) & 0x1) {
                    case 0x0: {
                        d.opcode = Opcode::ADD;
                        break;
                    }
                    case 0x1: {
                        d.opcode = Opcode::SUB;
                        break;
                    }
                    }
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::MUL;
                    break;
                }
                }
                break;
            }
            case 0x1: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::SLL;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::MULH;
                    break;
                }
                }
                break;
            }
            case 0x2: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::SLT;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::MULHSU;
                    break;
                }
                }
                break;
            }
            case 0x3: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::SLTU;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::MULHU;
                    break;
                }
                }
                break;
            }
            case 0x4: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::XOR;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::DIV;
                    break;
                }
                }
                break;
            }
            case 0x5: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    switch ((insn >> 30) & 0x1) {
                    case 0x0: {
                        d.opcode = Opcode::SRL;
                        break;
                    }
                    case 0x1: {
                        d.opcode = Opcode::SRA;
                        break;
                    }
                    }
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::DIVU;
                    break;
                }
                }
                break;
            }
            case 0x6: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::OR;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::REM;
                    break;
                }
                }
                break;
            }
            case 0x7: {
                switch ((insn >> 25) & 0x1) {
                case 0x0: {
                    d.opcode = Opcode::AND;
                    break;
                }
                case 0x1: {
                    d.opcode = Opcode::REMU;
                    break;
                }
                }
                break;
            }
            }
            break;
        }
        case 0xd: {
            d.opcode = Opcode::LUI;
            break;
        }
        case 0x18: {
            switch ((insn >> 12) & 0x7) {
            case 0x0: {
                d.opcode = Opcode::BEQ;
                break;
            }
            case 0x1: {
                d.opcode = Opcode::BNE;
                break;
            }
            case 0x4: {
                d.opcode = Opcode::BLT;
                break;
            }
            case 0x5: {
                d.opcode = Opcode::BGE;
                break;
            }
            case 0x6: {
                d.opcode = Opcode::BLTU;
                break;
            }
            case 0x7: {
                d.opcode = Opcode::BGEU;
                break;
            }
            }
            break;
        }
        case 0x19: {
            d.opcode = Opcode::JALR;
            break;
        }
        case 0x1b: {
            d.opcode = Opcode::JAL;
            break;
        }
        case 0x1c: {
            switch ((insn >> 20) & 0x1) {
            case 0x0: {
                d.opcode = Opcode::ECALL;
                break;
            }
            case 0x1: {
                d.opcode = Opcode::EBREAK;
                break;
            }
            }
            break;
        }
        }
        
        return d;
    }
};

#endif // DECODER_H
