module JulIO

export JO, value, failed, map, flatmap, evaluate!

using HTTP: get
using Logging: ConsoleLogger, Info, Debug

include("evaluator.jl")


logger = ConsoleLogger(Info; show_limited = false)
Base.global_logger(logger)

function value(val::T) where {T}
    v = deepcopy(val)
    JO{T}(expr = Expr(:call, :identity, v))
end

function failed(T::Type, exc::Exception)
    JO{T}(status = Failed, error = exc)
end

function Base.map(T2::Type, f::Function, jo::JO{T1}) where {T1}
    JO{T2}(
        expr = :(if Parent("input").status == Succeed Func("mapper")(Parent("input").result) else Parent("input").error end),
        parents = Dict("input" => jo),
        functions = Dict("mapper" => f))
end

function Base.map(f::Function, jo::JO{T1}) where {T1}
    T2 = first(Base.return_types(f, (T1,)))
    Base.map(T2, f, jo)
end

function flatmap(T2::Type, f::Function, jo::JO{T1}) where {T1}
    JO{T2}(
        expr = :(if Parent("input").status == Succeed eval(Func("mapper")(Parent("input").result).expr) else Parent("input").error end),
        parents = Dict("input" => jo),
        functions = Dict("mapper" => f))
end

function flatmap(f::Function, jo::JO{T1}) where {T1}
    FT = first(Base.return_types(f, (T1,)))
    !(FT <: JO) && throw(TypeError(:flatmap, "Function passed to flatmap must return JO{T2} instance!", JO, FT))
    T2 = FT.parameters[1]

    flatmap(T2, f, jo)
end

function Base.zip(jos::JO...)
    parents = map(x -> string(x[1]) => x[2], enumerate(jos))

    JO{Tuple}(
        expr = Expr(:tuple, map(x -> :(Parent($(string(x))).status == Succeed ? Parent($(string(x))).result : Parent($(string(x))).error), 1:length(jos))...),
        parents = Dict(parents))
end

end # module JulIO
