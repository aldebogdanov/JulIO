using MacroTools

include("internal.jl")


function evaluate(jo)
    jo.status = InProgress
    solved = Dict{Symbol, Any}()

    @sync for (key, parent) in jo.parents
        @async solved[key] = evaluate(parent)
    end

    function walk(any::Any)
        @debug "Any to evaluate:" any
        return any
    end

    function walk(p::Parent)
        @debug "Parent to evaluate:" p
        out = solved[p.key]
        @debug "Solved as:" out
        
        out.status == Succeed && return out.result
        out.status == Failed  && throw(out.error)
    end

    function walk(f::Func)
        @debug "Func to evaluate:" f
        return jo.functions[f.key]
    end

    function walk(expr::Expr)
        @debug "Subexpression to eval:" expr
        return eval(expr)
    end

    try
        @debug "Expression to postwalk: " jo.expr
        expression = MacroTools.postwalk(walk, jo.expr)
        @debug "Expression to eval:" expression
        jo.result = eval(expression)
        jo.status = Succeed
    catch ex
        @debug "Exception on eval: " ex
        jo.error = ex
        jo.status = Failed
    finally
        return jo
    end
end