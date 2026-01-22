// Auto generated from ProtDSL
#include "executor.h"
#include "../simlib/sext.h"
#include <cstdio>

void Executor::execute(CpuState& cpu, const DecodedInsn& d, Memory& mem) {
    switch (d.opcode) {
    case Opcode::ADD: {
        // ADD
        word_t _tmp0 = cpu.read_reg(d.op_rs1);
        word_t _tmp1 = cpu.read_reg(d.op_rs2);
        word_t _tmp2 = _tmp0 + _tmp1;
        cpu.write_reg(d.op_rd, _tmp2);
        break;
    }
    case Opcode::SUB: {
        // SUB
        word_t _tmp3 = cpu.read_reg(d.op_rs1);
        word_t _tmp4 = cpu.read_reg(d.op_rs2);
        word_t _tmp5 = _tmp3 - _tmp4;
        cpu.write_reg(d.op_rd, _tmp5);
        break;
    }
    case Opcode::SLL: {
        // SLL
        word_t _tmp6 = cpu.read_reg(d.op_rs1);
        word_t _tmp7 = cpu.read_reg(d.op_rs2);
        word_t _tmp9 = _tmp7 & 31;
        word_t _tmp10 = _tmp6 << _tmp9;
        cpu.write_reg(d.op_rd, _tmp10);
        break;
    }
    case Opcode::SLT: {
        // SLT
        word_t _tmp11 = cpu.read_reg(d.op_rs1);
        word_t _tmp12 = cpu.read_reg(d.op_rs2);
        word_t _tmp13 = ((sword_t)_tmp11 < (sword_t)_tmp12) ? 1 : 0;
        cpu.write_reg(d.op_rd, _tmp13);
        break;
    }
    case Opcode::SLTU: {
        // SLTU
        word_t _tmp14 = cpu.read_reg(d.op_rs1);
        word_t _tmp15 = cpu.read_reg(d.op_rs2);
        word_t _tmp16 = (_tmp14 < _tmp15) ? 1 : 0;
        cpu.write_reg(d.op_rd, _tmp16);
        break;
    }
    case Opcode::XOR: {
        // XOR
        word_t _tmp17 = cpu.read_reg(d.op_rs1);
        word_t _tmp18 = cpu.read_reg(d.op_rs2);
        word_t _tmp19 = _tmp17 ^ _tmp18;
        cpu.write_reg(d.op_rd, _tmp19);
        break;
    }
    case Opcode::SRL: {
        // SRL
        word_t _tmp20 = cpu.read_reg(d.op_rs1);
        word_t _tmp21 = cpu.read_reg(d.op_rs2);
        word_t _tmp23 = _tmp21 & 31;
        word_t _tmp24 = _tmp20 >> _tmp23;
        cpu.write_reg(d.op_rd, _tmp24);
        break;
    }
    case Opcode::SRA: {
        // SRA
        word_t _tmp25 = cpu.read_reg(d.op_rs1);
        word_t _tmp26 = cpu.read_reg(d.op_rs2);
        word_t _tmp28 = _tmp26 & 31;
        word_t _tmp29 = trunc32((sword_t)_tmp25 >> _tmp28);
        cpu.write_reg(d.op_rd, _tmp29);
        break;
    }
    case Opcode::OR: {
        // OR
        word_t _tmp30 = cpu.read_reg(d.op_rs1);
        word_t _tmp31 = cpu.read_reg(d.op_rs2);
        word_t _tmp32 = _tmp30 | _tmp31;
        cpu.write_reg(d.op_rd, _tmp32);
        break;
    }
    case Opcode::AND: {
        // AND
        word_t _tmp33 = cpu.read_reg(d.op_rs1);
        word_t _tmp34 = cpu.read_reg(d.op_rs2);
        word_t _tmp35 = _tmp33 & _tmp34;
        cpu.write_reg(d.op_rd, _tmp35);
        break;
    }
    case Opcode::ADDI: {
        // ADDI
        word_t _tmp36 = cpu.read_reg(d.op_rs1);
        word_t _tmp37 = _tmp36 + d.op_imm_imm12;
        cpu.write_reg(d.op_rd, _tmp37);
        break;
    }
    case Opcode::SLTI: {
        // SLTI
        word_t _tmp38 = cpu.read_reg(d.op_rs1);
        word_t _tmp39 = ((sword_t)_tmp38 < (sword_t)d.op_imm_imm12) ? 1 : 0;
        cpu.write_reg(d.op_rd, _tmp39);
        break;
    }
    case Opcode::SLTIU: {
        // SLTIU
        word_t _tmp40 = cpu.read_reg(d.op_rs1);
        word_t _tmp41 = (_tmp40 < d.op_imm_imm12) ? 1 : 0;
        cpu.write_reg(d.op_rd, _tmp41);
        break;
    }
    case Opcode::XORI: {
        // XORI
        word_t _tmp42 = cpu.read_reg(d.op_rs1);
        word_t _tmp43 = _tmp42 ^ d.op_imm_imm12;
        cpu.write_reg(d.op_rd, _tmp43);
        break;
    }
    case Opcode::ORI: {
        // ORI
        word_t _tmp44 = cpu.read_reg(d.op_rs1);
        word_t _tmp45 = _tmp44 | d.op_imm_imm12;
        cpu.write_reg(d.op_rd, _tmp45);
        break;
    }
    case Opcode::ANDI: {
        // ANDI
        word_t _tmp46 = cpu.read_reg(d.op_rs1);
        word_t _tmp47 = _tmp46 & d.op_imm_imm12;
        cpu.write_reg(d.op_rd, _tmp47);
        break;
    }
    case Opcode::SLLI: {
        // SLLI
        word_t _tmp48 = cpu.read_reg(d.op_rs1);
        word_t _tmp49 = _tmp48 << d.op_shamt;
        cpu.write_reg(d.op_rd, _tmp49);
        break;
    }
    case Opcode::SRLI: {
        // SRLI
        word_t _tmp50 = cpu.read_reg(d.op_rs1);
        word_t _tmp51 = _tmp50 >> d.op_shamt;
        cpu.write_reg(d.op_rd, _tmp51);
        break;
    }
    case Opcode::SRAI: {
        // SRAI
        word_t _tmp52 = cpu.read_reg(d.op_rs1);
        word_t _tmp53 = trunc32((sword_t)_tmp52 >> d.op_shamt);
        cpu.write_reg(d.op_rd, _tmp53);
        break;
    }
    case Opcode::LB: {
        // LB
        word_t _tmp54 = cpu.read_reg(d.op_rs1);
        word_t _tmp55 = _tmp54 + d.op_imm_imm12;
        word_t _tmp56 = sext<8, sword_t>(mem.load8(_tmp55, cpu.pc));
        cpu.write_reg(d.op_rd, _tmp56);
        break;
    }
    case Opcode::LH: {
        // LH
        word_t _tmp57 = cpu.read_reg(d.op_rs1);
        word_t _tmp58 = _tmp57 + d.op_imm_imm12;
        word_t _tmp59 = sext<16, sword_t>(mem.load16(_tmp58, cpu.pc));
        cpu.write_reg(d.op_rd, _tmp59);
        break;
    }
    case Opcode::LW: {
        // LW
        word_t _tmp60 = cpu.read_reg(d.op_rs1);
        word_t _tmp61 = _tmp60 + d.op_imm_imm12;
        word_t _tmp62 = mem.load32(_tmp61, cpu.pc);
        cpu.write_reg(d.op_rd, _tmp62);
        break;
    }
    case Opcode::LBU: {
        // LBU
        word_t _tmp63 = cpu.read_reg(d.op_rs1);
        word_t _tmp64 = _tmp63 + d.op_imm_imm12;
        word_t _tmp65 = mem.load8(_tmp64, cpu.pc);
        cpu.write_reg(d.op_rd, _tmp65);
        break;
    }
    case Opcode::LHU: {
        // LHU
        word_t _tmp66 = cpu.read_reg(d.op_rs1);
        word_t _tmp67 = _tmp66 + d.op_imm_imm12;
        word_t _tmp68 = mem.load16(_tmp67, cpu.pc);
        cpu.write_reg(d.op_rd, _tmp68);
        break;
    }
    case Opcode::SB: {
        // SB
        word_t _tmp69 = cpu.read_reg(d.op_rs1);
        word_t _tmp70 = _tmp69 + d.op_imm_imm12_s;
        word_t _tmp71 = cpu.read_reg(d.op_rs2);
        mem.store8(_tmp70, _tmp71, cpu.pc);
        break;
    }
    case Opcode::SH: {
        // SH
        word_t _tmp72 = cpu.read_reg(d.op_rs1);
        word_t _tmp73 = _tmp72 + d.op_imm_imm12_s;
        word_t _tmp74 = cpu.read_reg(d.op_rs2);
        mem.store16(_tmp73, _tmp74, cpu.pc);
        break;
    }
    case Opcode::SW: {
        // SW
        word_t _tmp75 = cpu.read_reg(d.op_rs1);
        word_t _tmp76 = _tmp75 + d.op_imm_imm12_s;
        word_t _tmp77 = cpu.read_reg(d.op_rs2);
        mem.store32(_tmp76, _tmp77, cpu.pc);
        break;
    }
    case Opcode::BEQ: {
        // BEQ
        word_t _tmp78 = cpu.read_reg(d.op_rs1);
        word_t _tmp79 = cpu.read_reg(d.op_rs2);
        word_t _tmp80 = (_tmp78 == _tmp79) ? 1 : 0;
        word_t _tmp81 = cpu.pc;
        word_t _tmp82 = _tmp81 + d.op_imm_imm13_b;
        if (_tmp80) cpu.next_pc = _tmp82;
        break;
    }
    case Opcode::BNE: {
        // BNE
        word_t _tmp83 = cpu.read_reg(d.op_rs1);
        word_t _tmp84 = cpu.read_reg(d.op_rs2);
        word_t _tmp85 = (_tmp83 != _tmp84) ? 1 : 0;
        word_t _tmp86 = cpu.pc;
        word_t _tmp87 = _tmp86 + d.op_imm_imm13_b;
        if (_tmp85) cpu.next_pc = _tmp87;
        break;
    }
    case Opcode::BLT: {
        // BLT
        word_t _tmp88 = cpu.read_reg(d.op_rs1);
        word_t _tmp89 = cpu.read_reg(d.op_rs2);
        word_t _tmp90 = ((sword_t)_tmp88 < (sword_t)_tmp89) ? 1 : 0;
        word_t _tmp91 = cpu.pc;
        word_t _tmp92 = _tmp91 + d.op_imm_imm13_b;
        if (_tmp90) cpu.next_pc = _tmp92;
        break;
    }
    case Opcode::BGE: {
        // BGE
        word_t _tmp93 = cpu.read_reg(d.op_rs1);
        word_t _tmp94 = cpu.read_reg(d.op_rs2);
        word_t _tmp95 = ((sword_t)_tmp94 < (sword_t)_tmp93) ? 1 : 0;
        word_t _tmp96 = (_tmp93 == _tmp94) ? 1 : 0;
        word_t _tmp97 = _tmp95 | _tmp96;
        word_t _tmp98 = cpu.pc;
        word_t _tmp99 = _tmp98 + d.op_imm_imm13_b;
        if (_tmp97) cpu.next_pc = _tmp99;
        break;
    }
    case Opcode::BLTU: {
        // BLTU
        word_t _tmp100 = cpu.read_reg(d.op_rs1);
        word_t _tmp101 = cpu.read_reg(d.op_rs2);
        word_t _tmp102 = (_tmp100 < _tmp101) ? 1 : 0;
        word_t _tmp103 = cpu.pc;
        word_t _tmp104 = _tmp103 + d.op_imm_imm13_b;
        if (_tmp102) cpu.next_pc = _tmp104;
        break;
    }
    case Opcode::BGEU: {
        // BGEU
        word_t _tmp105 = cpu.read_reg(d.op_rs1);
        word_t _tmp106 = cpu.read_reg(d.op_rs2);
        word_t _tmp107 = (_tmp105 >= _tmp106) ? 1 : 0;
        word_t _tmp108 = cpu.pc;
        word_t _tmp109 = _tmp108 + d.op_imm_imm13_b;
        if (_tmp107) cpu.next_pc = _tmp109;
        break;
    }
    case Opcode::JAL: {
        // JAL
        word_t _tmp110 = cpu.pc;
        word_t _tmp112 = _tmp110 + 4;
        cpu.write_reg(d.op_rd, _tmp112);
        word_t _tmp113 = cpu.pc;
        word_t _tmp114 = _tmp113 + d.op_imm_imm21_j;
        cpu.next_pc = _tmp114;
        break;
    }
    case Opcode::JALR: {
        // JALR
        word_t _tmp115 = cpu.pc;
        word_t _tmp117 = _tmp115 + 4;
        cpu.write_reg(d.op_rd, _tmp117);
        word_t _tmp118 = cpu.read_reg(d.op_rs1);
        word_t _tmp119 = _tmp118 + d.op_imm_imm12;
        word_t _tmp121 = _tmp119 & 4294967294;
        cpu.next_pc = _tmp121;
        break;
    }
    case Opcode::LUI: {
        // LUI
        cpu.write_reg(d.op_rd, d.op_imm_imm20_u);
        break;
    }
    case Opcode::AUIPC: {
        // AUIPC
        word_t _tmp122 = cpu.pc;
        word_t _tmp123 = _tmp122 + d.op_imm_imm20_u;
        cpu.write_reg(d.op_rd, _tmp123);
        break;
    }
    case Opcode::ECALL: {
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
                default: fprintf(stderr, "Unknown syscall %u\n", a7); cpu.running = false;
            }
        }
        break;
    }
    case Opcode::EBREAK: {
        cpu.running = false; // EBREAK
        break;
    }
    case Opcode::FENCE: {
        // FENCE - no-op
        break;
    }
    case Opcode::MUL: {
        // MUL
        word_t _tmp124 = cpu.read_reg(d.op_rs1);
        word_t _tmp125 = cpu.read_reg(d.op_rs2);
        word_t _tmp126 = trunc32(sext64(_tmp124) * sext64(_tmp125));
        cpu.write_reg(d.op_rd, _tmp126);
        break;
    }
    case Opcode::MULH: {
        // MULH
        word_t _tmp127 = cpu.read_reg(d.op_rs1);
        word_t _tmp128 = cpu.read_reg(d.op_rs2);
        word_t _tmp129 = trunc32((sext64(_tmp127) * sext64(_tmp128)) >> 32);
        cpu.write_reg(d.op_rd, _tmp129);
        break;
    }
    case Opcode::MULHSU: {
        // MULHSU
        word_t _tmp130 = cpu.read_reg(d.op_rs1);
        word_t _tmp131 = cpu.read_reg(d.op_rs2);
        word_t _tmp132 = trunc32((sext64(_tmp130) * zext64(_tmp131)) >> 32);
        cpu.write_reg(d.op_rd, _tmp132);
        break;
    }
    case Opcode::MULHU: {
        // MULHU
        word_t _tmp133 = cpu.read_reg(d.op_rs1);
        word_t _tmp134 = cpu.read_reg(d.op_rs2);
        word_t _tmp135 = trunc32((zext64(_tmp133) * zext64(_tmp134)) >> 32);
        cpu.write_reg(d.op_rd, _tmp135);
        break;
    }
    case Opcode::DIV: {
        // DIV
        word_t _tmp136 = cpu.read_reg(d.op_rs1);
        word_t _tmp137 = cpu.read_reg(d.op_rs2);
        word_t _tmp138 = _tmp137 == 0 ? (word_t)-1 : (_tmp137 == (word_t)-1 && _tmp136 == 0x80000000u) ? _tmp136 : trunc32((sword_t)_tmp136 / (sword_t)_tmp137);
        cpu.write_reg(d.op_rd, _tmp138);
        break;
    }
    case Opcode::DIVU: {
        // DIVU
        word_t _tmp139 = cpu.read_reg(d.op_rs1);
        word_t _tmp140 = cpu.read_reg(d.op_rs2);
        word_t _tmp141 = _tmp140 == 0 ? (word_t)-1 : _tmp139 / _tmp140;
        cpu.write_reg(d.op_rd, _tmp141);
        break;
    }
    case Opcode::REM: {
        // REM
        word_t _tmp142 = cpu.read_reg(d.op_rs1);
        word_t _tmp143 = cpu.read_reg(d.op_rs2);
        word_t _tmp144 = _tmp143 == 0 ? _tmp142 : (_tmp143 == (word_t)-1 && _tmp142 == 0x80000000u) ? 0 : trunc32((sword_t)_tmp142 % (sword_t)_tmp143);
        cpu.write_reg(d.op_rd, _tmp144);
        break;
    }
    case Opcode::REMU: {
        // REMU
        word_t _tmp145 = cpu.read_reg(d.op_rs1);
        word_t _tmp146 = cpu.read_reg(d.op_rs2);
        word_t _tmp147 = _tmp146 == 0 ? _tmp145 : _tmp145 % _tmp146;
        cpu.write_reg(d.op_rd, _tmp147);
        break;
    }
    case Opcode::UNKNOWN:
    default:
        fprintf(stderr, "Unknown instruction at PC=0x%08x (raw=0x%08x)\n", cpu.pc, d.raw);
        cpu.running = false;
        break;
    }
}
