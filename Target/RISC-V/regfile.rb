module SimInfra
    class XReg
        attr_reader :name

        def initialize(name)
            @name = name
        end

        # String representation for asm output
        def to_s
            @name.to_s
        end
    end

    class Imm
        attr_reader :name, :bits, :signed

        def initialize(name, bits = 12, signed = true)
            @name = name
            @bits = bits
            @signed = signed
        end

        def to_s
            @name.to_s
        end
    end

    def XReg(name)
        XReg.new(name)
    end

    def Imm(name, bits = 12, signed = true)
        Imm.new(name, bits, signed)
    end
end
