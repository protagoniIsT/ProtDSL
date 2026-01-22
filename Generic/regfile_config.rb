module SimInfra
  class RegFileConfig
    attr_reader :name, :num_regs, :reg_width, :zero_reg, :aliases

    def initialize(name)
      @name = name
      @num_regs = 32
      @reg_width = 32
      @zero_reg = nil
      @aliases = {}
    end

    def count(n)
      @num_regs = n
      self
    end

    def width(bits)
      @reg_width = bits
      self
    end

    def zero_register(index)
      @zero_reg = index
      self
    end

    def alias_reg(name, index)
      @aliases[name] = index
      self
    end

    def to_h
      {
        name: @name,
        num_regs: @num_regs,
        reg_width: @reg_width,
        zero_reg: @zero_reg,
        aliases: @aliases
      }
    end
  end

  class MemoryConfig
    attr_reader :base_addr, :mem_size

    def initialize
      @base_addr = 0x80000000
      @mem_size = 128 * 1024 * 1024  # 128 MB default
    end

    def base(addr)
      @base_addr = addr
      self
    end

    def size(bytes)
      @mem_size = bytes
      self
    end

    def to_h
      {
        base_addr: @base_addr,
        mem_size: @mem_size
      }
    end
  end

  class ResetConfig
    attr_reader :pc_value

    def initialize
      @pc_value = 0x80000000
    end

    def pc(value)
      @pc_value = value
      self
    end

    def to_h
      {
        pc: @pc_value
      }
    end
  end

  class CpuConfig
    attr_reader :name, :reg_files, :word_size, :insn_size, :memory_config, :reset_config

    def initialize(name)
      @name = name
      @reg_files = {}
      @word_size = 32
      @insn_size = 4
      @memory_config = MemoryConfig.new
      @reset_config = ResetConfig.new
    end

    def word(bits)
      @word_size = bits
      self
    end

    def instruction_size(bytes)
      @insn_size = bytes
      self
    end

    def regfile(name, &block)
      rf = RegFileConfig.new(name)
      rf.instance_eval(&block) if block_given?
      @reg_files[name] = rf
      self
    end

    def memory(&block)
      @memory_config.instance_eval(&block) if block_given?
      self
    end

    def reset(&block)
      @reset_config.instance_eval(&block) if block_given?
      self
    end

    def to_h
      {
        name: @name,
        word_size: @word_size,
        insn_size: @insn_size,
        memory: @memory_config.to_h,
        reset: @reset_config.to_h,
        reg_files: @reg_files.transform_values(&:to_h)
      }
    end
  end


  def CpuConfig(name, &block)
    config = CpuConfig.new(name)
    config.instance_eval(&block) if block_given?
    SimInfra.cpu_config = config
    config
  end
end
