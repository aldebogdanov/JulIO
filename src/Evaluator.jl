module Evaluator

export evaluate

using MacroTools



function evaluate(jo)
    solved = Dict{Symbol, Any}()

    @sync for (key, parent) in jo.parents
        @async solved[key] = evaluate(parent)
    end

    function walk(any::Any)
        return any
    end

    function walk(p::Main.JulIO.Internal.Parent)
        return solved[p.key]
    end

    function walk(f::Main.JulIO.Internal.Func)
        return jo.functions[f.key]
    end

    expression = MacroTools.postwalk(walk, jo.expr)
    @debug "Expression to eval:" expression
    return eval(expression)
end

end # module Evaluator