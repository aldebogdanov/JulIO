module JulIO

export JO, value, map, flatmap, evaluate

using HTTP: get
using Logging: ConsoleLogger, Debug
using UUIDs

include("evaluator.jl")


logger = ConsoleLogger(Debug; show_limited = false)
Base.global_logger(logger)

function value(val::T) where {T}
    v = deepcopy(val)
    
    JO{T}(expr = Expr(:call, :identity, v))
end

function Base.map(f::Function, jo::JO{T1}) where {T1}
    T2 = first(Base.return_types(f, (T1,)))

    JO{T2}(
        expr = Expr(:call, Func(:mapper), Parent(:input)),
        parents = Dict(:input => jo),
        functions = Dict(:mapper => f))
end

function flatmap(f::Function, jo::JO{T}) where {T}
    FT = first(Base.return_types(f, (T,)))
    !(FT <: JO) && throw(TypeError(:flatmap, "Function passed to flatmap must return JO{T2} instance!", JO, FT))
    T2 = FT.parameters[1]
    
    JO{T2}(expr =
        Expr(
            :., 
            Expr(:call, Func(:mapper), Parent(:input)),
            QuoteNode(:expr)),
        parents = Dict(:input => jo),
        functions = Dict(:mapper => f))
end

function Base.zip(jos::JO...)
    parents = map(x -> Symbol(x[1]) => x[2], enumerate(jos))
    @info Dict(parents)

    JO{Tuple{Any}}(expr = 
        Expr(:tuple, map(x -> Parent(Symbol(x[1])), 1:length(jos))...),
        parents = Dict(parents))
end

end # module JulIO
