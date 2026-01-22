require_relative "scope"

module SimInfra
    def assert(condition, msg = nil)
        raise msg if !condition
    end

    @@instructions = []

    InstructionInfo = Struct.new(:name, :fields, :format, :code, :args, :asm)

    class InstructionInfoBuilder
        include SimInfra

        def initialize(name, *args)
            @info = InstructionInfo.new(name)
            @info.args = args
            @info.asm = nil
            args.each do |arg|
                define_singleton_method(arg.name) { arg }
            end
        end

        def encoding(format, fields)
            @info.fields = fields
            @info.format = format
        end

        def asm(&block)
            @info.asm = instance_eval(&block)
        end

        def code(&block)
            @info.code = scope = Scope.new(nil) # root scope

            # Add variables for each argument
            @info.args.each do |arg|
                scope.add_var(arg.name, :i32)
            end

            # Execute user code
            scope.instance_eval(&block)            
        end

        attr_reader :info
    end

    def Instruction(name, *args, &block)
        bldr = InstructionInfoBuilder.new(name, *args)
        bldr.instance_eval(&block)
        @@instructions << bldr.info
        nil
    end
end
