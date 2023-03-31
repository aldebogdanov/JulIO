module JulIO

export JO, value, map

using HTTP: get
using Logging: ConsoleLogger, Debug
using UUIDs

include("Internal.jl"); import .Internal: JO, Func, Parent


logger = ConsoleLogger(Debug; show_limited = false)
Base.global_logger(logger)

function value(val::T) where {T}
    v = deepcopy(val)
    
    JO{T}(
        uuid = UUIDs.uuid4(),
        expr = Expr(:call, :identity, v),
        parents = Dict(),
        functions = Dict())
end

function Base.map(f::Function, jo::JO{T1}) where {T1}
    T2 = first(Base.return_types(f, (T1,)))

    JO{T2}(
        uuid = UUIDs.uuid4(),
        expr = Expr(:call, Func(:mapper), Parent(:input)),
        parents = Dict(:input => jo),
        functions = Dict(:mapper => f))
end

# function flatmap(func::Function, fut::Future{T}) where {T}
#     maintype = first(Base.return_types(func, (T,)))
#     @assert maintype <: Future "Function passed to flatmap violates the law!"
#     type = maintype.parameters[1]
    
#     Future{type}(
#         Expr(:., [Expr(:call, [Symbol(func), fut.expr]), QuoteNode(:expr)])
#     )
# end

# function attempt(fut::Future{T})::Future{Union{T, Exception}} where {T}
#     @future Union{T, Exception} Expr(
#         :try,
#         [fut.expr, :ex, :ex]
#     )
# end

# function downloadUrl(url::String)::Future{String}
#     fut = @future String quote
#         HTTP.get(url).body
#     end
#     @info "one" fut
#     return fut
# end

# function downloadUrls(urls::Array{String})::Array{Future{String}}
#     map(downloadUrl, urls)
#  end

# function collectErrors(fs::Array{Future{String}})::Future{Tuple{Array{String}, Array{Exception}}}
#     map(attempt, fs)
# end

# @match response begin
#     Const(Thrown(exception::HTTP.Exceptions.StatusError, _)) => error(HTTP.statustext(exception.status))
#     Const(Thrown(exception::HTTP.ConnectError, _)) => error("Unable to connect to simulation service")
#     Const(Thrown(exception::HTTP.RequestError, _)) => error("Unable to connect to simulation service")
#     Const(Thrown(exp, _)) => throw(exp)
#     Identity(BaseResponseModel(true)) => begin
#         @info "The task was started"
#         saved_data.models[m.name]["status"] = IN_PROGRESS
#     end
#     Identity(ErrorResponseModel(false, errorString::String)) => error(errorString)
#     Identity(ErrorResponseModel(false, _)) => throw(log_exception(InvalidModelResponseException("Undocumented error in the context of simulation service.")))
#     _ => throw(log_exceptions(UnhandledCaseException("Unhandled use-case")))
# end


end # module future
