@enum Status New=1 InProgress=2 Succeed=3 Failed=4

Base.@kwdef mutable struct JO{T}
    expr::Union{Expr, Nothing} = nothing
    parents::Dict{String, JO} = Dict()
    functions::Dict{String, Function} = Dict()
    status::Status = New
    result::Union{T, Nothing} = nothing
    error::Union{Exception, Nothing} = nothing
end
JO{T}(expr::Expr, parent::Dict{Symbol, JO} = Dict(), functions::Dict{Symbol, Function} = Dict()) where {T} =
    JO{T}(expr; parent, functions, throw_exc, status = New, result = nothing, error = nothing)
JO{T}(expr::Expr) where {T} = (expr)

abstract type EvalEntity end

struct Parent <: EvalEntity
    key::String
end

struct Func <: EvalEntity
    key::String
end 