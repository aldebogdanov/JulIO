using UUIDs


@enum Status New=1 InProgress=2 Succeed=3 Failed=4

Base.@kwdef mutable struct JO{T}
    uuid::UUID = UUIDs.uuid4()
    expr::Expr
    parents::Dict{Symbol, JO} = Dict()
    functions::Dict{Symbol, Function} = Dict()
    exc_rules::Dict{Symbol, Function} = Dict()
    status::Status = New
    result::Union{T, Nothing} = nothing
    error::Union{Exception, Nothing} = nothing
end
JO{T}(uuid::UUID, expr::Expr, parent::Dict{Symbol, JO} = Dict(), functions::Dict{Symbol, Function} = Dict(), exc_rules::Dict{Symbol, Function} = Dict()) where {T} =
    JO{T}(uuid, expr; parent, functions, exc_rules, status = New, result = nothing, error = nothing)
JO{T}(expr::Expr) where {T} = (UUIDs.uuid4(), expr)

abstract type EvalEntity end

struct Parent <: EvalEntity
    key::Symbol
end

struct Func <: EvalEntity
    key::Symbol
end 