require_relative "base"
require_relative "var"

module SimInfra
    class Scope

        include GlobalCounter # used for temp variables IDs
        attr_reader :tree, :vars, :parent

        def initialize(parent)
            @tree = []
            @vars = {}
            @parent = parent
        end

        def var(name, type)
            @vars[name] = SimInfra::Var.new(self, name, type)
            instance_eval "def #{name.to_s}(); return @vars[:#{name.to_s}]; end"
            stmt :new_var, [@vars[name]]
        end

        def add_var(name, type)
            var(name, type)
            self
        end

        def resolve_const(what)
            return what if (what.class == Var) or (what.class == Constant)
            return Constant.new(self, "const_#{next_counter}", what) if (what.class == Integer)
            what
        end

        IR_OPS.each do |name, op|
            case op.kind
            when :binary
                method_name = case name
                              when :and then :and_op
                              when :or then :or_op
                              when :xor then :xor_op
                              else name
                              end
                define_method(method_name) do |a, b|
                    a = resolve_const(a)
                    b = resolve_const(b)
                    stmt name, [tmpvar(:i32), a, b]
                end
            when :memory_load
                define_method(name) do |addr|
                    stmt name, [tmpvar(:i32), resolve_const(addr)]
                end
            when :memory_store
                define_method(name) do |addr, val|
                    stmt name, [resolve_const(addr), resolve_const(val)]
                end
            when :reg_read
                define_method(name) do |reg|
                    stmt name, [tmpvar(:i32), resolve_const(reg)]
                end
            when :reg_write
                define_method(name) do |reg, val|
                    stmt name, [resolve_const(reg), resolve_const(val)]
                end
            when :control
                if op.operands.size == 2
                    define_method(name) do |a, b|
                        stmt name, [resolve_const(a), resolve_const(b)]
                    end
                else
                    define_method(name) do |a|
                        stmt name, [resolve_const(a)]
                    end
                end
            when :special
                if op.operands.size == 1 && op.operands[0] == :dst
                    define_method(name) do
                        stmt name, [tmpvar(:i32)]
                    end
                elsif op.operands.size == 1
                    define_method(name) do |val|
                        stmt name, [resolve_const(val)]
                    end
                end
            end
        end

        private

        def tmpvar(type)
            var("_tmp#{next_counter}".to_sym, type)
        end

        public

        # stmt adds statement into tree and returns operand[0]
        # which is the result in nearly all cases
        def stmt(name, operands, attrs = nil)
            @tree << IrStmt.new(name, operands, attrs)
            operands[0]
        end
    end
end
