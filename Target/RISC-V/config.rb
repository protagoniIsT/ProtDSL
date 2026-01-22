require_relative "../../Generic/regfile_config"

module SimInfra
  def self.define_rv32_config
    config = CpuConfig.new(:RV32IM)
    
    config.word(32)
    config.instruction_size(4)
    
    config.memory do
      base 0x80000000
      size 128 * 1024 * 1024  # 128 MB
    end
    
    config.reset do
      pc 0x80000000
    end
    
    config.regfile(:x) do
      count 32
      width 32
      zero_register 0
      
      alias_reg :zero, 0
      alias_reg :ra, 1
      alias_reg :sp, 2
      alias_reg :gp, 3
      alias_reg :tp, 4
      alias_reg :t0, 5
      alias_reg :t1, 6
      alias_reg :t2, 7
      alias_reg :s0, 8
      alias_reg :fp, 8
      alias_reg :s1, 9
      alias_reg :a0, 10
      alias_reg :a1, 11
      alias_reg :a2, 12
      alias_reg :a3, 13
      alias_reg :a4, 14
      alias_reg :a5, 15
      alias_reg :a6, 16
      alias_reg :a7, 17
      alias_reg :s2, 18
      alias_reg :s3, 19
      alias_reg :s4, 20
      alias_reg :s5, 21
      alias_reg :s6, 22
      alias_reg :s7, 23
      alias_reg :s8, 24
      alias_reg :s9, 25
      alias_reg :s10, 26
      alias_reg :s11, 27
      alias_reg :t3, 28
      alias_reg :t4, 29
      alias_reg :t5, 30
      alias_reg :t6, 31
    end
    
    SimInfra.cpu_config = config
    config
  end
end

SimInfra.define_rv32_config
