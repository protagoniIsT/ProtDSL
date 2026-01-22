module SimInfra
  IrOp = Struct.new(:name, :kind, :operands, :cpp_template)

  IR_OPS = {}

  def self.define_ir_op(name, kind, operands, cpp_template)
    IR_OPS[name] = IrOp.new(name, kind, operands, cpp_template)
  end

  define_ir_op :add, :binary, [:dst, :a, :b],
    "word_t %0 = %1 + %2;"

  define_ir_op :sub, :binary, [:dst, :a, :b],
    "word_t %0 = %1 - %2;"

  define_ir_op :mul, :binary, [:dst, :a, :b],
    "word_t %0 = trunc32(sext64(%1) * sext64(%2));"

  define_ir_op :mulh, :binary, [:dst, :a, :b],
    "word_t %0 = trunc32((sext64(%1) * sext64(%2)) >> 32);"

  define_ir_op :mulhsu, :binary, [:dst, :a, :b],
    "word_t %0 = trunc32((sext64(%1) * zext64(%2)) >> 32);"
 
  define_ir_op :mulhu, :binary, [:dst, :a, :b],
    "word_t %0 = trunc32((zext64(%1) * zext64(%2)) >> 32);"

  define_ir_op :div, :binary, [:dst, :a, :b],
    "word_t %0 = %2 == 0 ? (word_t)-1 : (%2 == (word_t)-1 && %1 == 0x80000000u) ? %1 : trunc32((sword_t)%1 / (sword_t)%2);"

  define_ir_op :divu, :binary, [:dst, :a, :b],
    "word_t %0 = %2 == 0 ? (word_t)-1 : %1 / %2;"

  define_ir_op :rem, :binary, [:dst, :a, :b],
    "word_t %0 = %2 == 0 ? %1 : (%2 == (word_t)-1 && %1 == 0x80000000u) ? 0 : trunc32((sword_t)%1 % (sword_t)%2);"

  define_ir_op :remu, :binary, [:dst, :a, :b],
    "word_t %0 = %2 == 0 ? %1 : %1 % %2;"

  define_ir_op :and, :binary, [:dst, :a, :b],
    "word_t %0 = %1 & %2;"

  define_ir_op :or, :binary, [:dst, :a, :b],
    "word_t %0 = %1 | %2;"

  define_ir_op :xor, :binary, [:dst, :a, :b],
    "word_t %0 = %1 ^ %2;"

  define_ir_op :sll, :binary, [:dst, :a, :b],
    "word_t %0 = %1 << %2;"

  define_ir_op :srl, :binary, [:dst, :a, :b],
    "word_t %0 = %1 >> %2;"

  define_ir_op :sra, :binary, [:dst, :a, :b],
    "word_t %0 = trunc32((sword_t)%1 >> %2);"

  define_ir_op :slt, :binary, [:dst, :a, :b],
    "word_t %0 = ((sword_t)%1 < (sword_t)%2) ? 1 : 0;"

  define_ir_op :sltu, :binary, [:dst, :a, :b],
    "word_t %0 = (%1 < %2) ? 1 : 0;"

  define_ir_op :lt, :binary, [:dst, :a, :b],
    "word_t %0 = ((sword_t)%1 < (sword_t)%2) ? 1 : 0;"

  define_ir_op :ltu, :binary, [:dst, :a, :b],
    "word_t %0 = (%1 < %2) ? 1 : 0;"

  define_ir_op :eq, :binary, [:dst, :a, :b],
    "word_t %0 = (%1 == %2) ? 1 : 0;"

  define_ir_op :ne, :binary, [:dst, :a, :b],
    "word_t %0 = (%1 != %2) ? 1 : 0;"

  define_ir_op :ge, :binary, [:dst, :a, :b],
    "word_t %0 = ((sword_t)%1 >= (sword_t)%2) ? 1 : 0;"

  define_ir_op :geu, :binary, [:dst, :a, :b],
    "word_t %0 = (%1 >= %2) ? 1 : 0;"

  define_ir_op :load8, :memory_load, [:dst, :addr],
    "word_t %0 = sext<8, sword_t>(mem.load8(%1, cpu.pc));"

  define_ir_op :load8u, :memory_load, [:dst, :addr],
    "word_t %0 = mem.load8(%1, cpu.pc);"

  define_ir_op :load16, :memory_load, [:dst, :addr],
    "word_t %0 = sext<16, sword_t>(mem.load16(%1, cpu.pc));"

  define_ir_op :load16u, :memory_load, [:dst, :addr],
    "word_t %0 = mem.load16(%1, cpu.pc);"

  define_ir_op :load32, :memory_load, [:dst, :addr],
    "word_t %0 = mem.load32(%1, cpu.pc);"

  define_ir_op :store8, :memory_store, [:addr, :val],
    "mem.store8(%0, %1, cpu.pc);"

  define_ir_op :store16, :memory_store, [:addr, :val],
    "mem.store16(%0, %1, cpu.pc);"

  define_ir_op :store32, :memory_store, [:addr, :val],
    "mem.store32(%0, %1, cpu.pc);"

  define_ir_op :read_reg, :reg_read, [:dst, :reg],
    "word_t %0 = cpu.read_reg(%1);"

  define_ir_op :write_reg, :reg_write, [:reg, :val],
    "cpu.write_reg(%0, %1);"

  define_ir_op :get_pc, :special, [:dst],
    "word_t %0 = cpu.pc;"

  define_ir_op :set_pc, :special, [:val],
    "cpu.pc = %0;"

  define_ir_op :set_next_pc, :special, [:val],
    "cpu.next_pc = %0;"

  define_ir_op :branch, :control, [:cond, :target],
    "if (%0) cpu.next_pc = %1;"

  define_ir_op :jump, :control, [:target],
    "cpu.next_pc = %0;"

  define_ir_op :new_var, :internal, [:var], nil
  define_ir_op :new_const, :internal, [:const], nil
end
