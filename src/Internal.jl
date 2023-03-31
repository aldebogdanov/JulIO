module Internal

export JO, Parent, Func

using UUIDs


# @enum Status New=1 InProgress=2 Succeed=3 Failed=4

Base.@kwdef struct JO{T}
    uuid::UUID
    expr::Expr
    parents::Dict{Symbol, JO}
    functions::Dict{Symbol, Function}
    # status::Status
    # result::Union{T, Nothing}
    # error::Union{Exception, Nothing}
end

abstract type EvalEntity end

struct Parent <: EvalEntity
    key::Symbol
end

struct Func <: EvalEntity
    key::Symbol
end 

end # module Internal