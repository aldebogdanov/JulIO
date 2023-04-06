using MacroTools

include("internal.jl")


function evaluate(jo)
    @info ">>> EVALUATING" jo

    jo.status = InProgress

    solved = Dict{Symbol, Any}()

    @sync for (key, parent) in jo.parents
        @async solved[key] = evaluate(parent)
    end

    for key in keys(jo.parents)
        jo.expr = MacroTools.replace(jo.expr, Expr(:call, :Parent, QuoteNode(key)), solved[key])
    end

    for (key, func) in jo.functions
        jo.expr = MacroTools.replace(jo.expr, Expr(:call, :Func, QuoteNode(key)), func)
    end

    try
        @debug "Expression to eval:" jo.expr
        jo.result = eval(jo.expr)
        jo.status = Succeed
    catch ex
        @debug "Exception on eval:" ex
        jo.error = ex
        jo.status = Failed
    finally
        @info "<<< EVALUATED" jo
        return jo
    end
end