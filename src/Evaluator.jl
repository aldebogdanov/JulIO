using MacroTools
using Distributed

include("internal.jl")


function evaluate!(jo; distributed = true)
    @debug ">>> EVALUATING" jo

    jo.status = InProgress

    solved = Dict{String, Any}()

    if distributed
        @sync @distributed for key = collect(keys(jo.parents))
            solved[key] = evaluate!(jo.parents[key]; distributed)
        end
    else
        for (key, parent) in jo.parents
            solved[key] = evaluate!(parent)
        end
    end

    for key in keys(jo.parents)
        jo.expr = MacroTools.replace(jo.expr, Expr(:call, :Parent, key), solved[key])
    end

    for (key, func) in jo.functions
        jo.expr = MacroTools.replace(jo.expr, Expr(:call, :Func, key), func)
    end

    try
        @debug "Expression to eval:" jo.expr
        eval_out = eval(jo.expr)
        if eval_out isa Exception
            jo.error = eval_out
            jo.status = Failed
        else
            jo.result = eval(jo.expr)
            jo.status = Succeed
        end
    catch ex
        @debug "Exception on eval:" ex
        jo.error = ex
        jo.status = Failed
    finally
        @debug "<<< EVALUATED" jo
        return jo
    end
end