require_relative "base"

module SimInfra
    IrStmt = Struct.new(:name, :oprnds, :attrs)

    class Var
        attr_reader :scope, :name, :type

        def initialize(scope, name, type)
            @scope = scope
            @name = name
            @type = type
        end

        def []=(other)
            @scope.stmt(:let, [self, @scope.resolve_const(other)])
        end

        def +(other); @scope.add(self, other); end
        def -(other); @scope.sub(self, other); end
        def *(other); @scope.mul(self, other); end
        def /(other); @scope.div(self, other); end
        def %(other); @scope.rem(self, other); end

        def &(other); @scope.and_op(self, other); end
        def |(other); @scope.or_op(self, other); end
        def ^(other); @scope.xor_op(self, other); end
        def <<(other); @scope.sll(self, other); end
        def >>(other); @scope.srl(self, other); end

        def <(other); @scope.lt(self, other); end
        def <=(other)
            lt = @scope.lt(self, other)
            eq = @scope.eq(self, other)
            @scope.or_op(lt, eq)
        end
        def >(other)
            @scope.lt(other, self)
        end
        def >=(other)
            lt = @scope.lt(other, self)
            eq = @scope.eq(self, other)
            @scope.or_op(lt, eq)
        end

        def inspect
            "#{@name}:#{@type} (#{@scope.object_id})"
        end
    end
end

module SimInfra
    # constant resolution (type check, initialization of constant type/value)
    class Constant
        attr_reader :scope, :name, :type, :value

        def initialize(scope, name, value)
            @const = value
            @scope = scope
            @type = :iconst
            @value = value
            @name = name
            @scope.stmt(:new_const, [@const])
        end

        def let(other)
            raise "Assign to constant"
        end

        def inspect
            "#{@name}:#{@type} (#{@scope.object_id}) {=#{@const}}"
        end
    end
end
