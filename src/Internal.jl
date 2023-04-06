using UUIDs


@enum Status New=1 InProgress=2 Succeed=3 Failed=4

Base.@kwdef mutable struct JO{T}
    # uuid::UUID = UUIDs.uuid4()
    expr::Union{Expr, Nothing} = nothing
    parents::Dict{Symbol, JO} = Dict()
    functions::Dict{Symbol, Function} = Dict()
    # throw_exc::Dict{Symbol, Bool} = Dict()
    status::Status = New
    result::Union{T, Nothing} = nothing
    error::Union{Exception, Nothing} = nothing
end
JO{T}(expr::Expr, parent::Dict{Symbol, JO} = Dict(), functions::Dict{Symbol, Function} = Dict()) where {T} =
    JO{T}(expr; parent, functions, throw_exc, status = New, result = nothing, error = nothing)
JO{T}(expr::Expr) where {T} = (expr)

abstract type EvalEntity end

struct Parent <: EvalEntity
    key::Symbol
end

struct Func <: EvalEntity
    key::Symbol
end 