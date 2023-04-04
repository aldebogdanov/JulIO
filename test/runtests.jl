using Test

include("../src/JulIO.jl");         using .JulIO    


@testset "value(v::T)" begin
    jo = value(42)

    @test jo isa JO{Int64}
    @test eval(jo.expr) == 42
    @test isempty(jo.parents)
    e = evaluate(jo)
    @test e.status == JulIO.Succeed
    @test e.result == 42
end

@testset "map(func::Function, jo::JO{T})" begin
    in = value(1)
    jo1 = map(x -> x / 2, in)

    @test jo1 isa JO{Float64}
    @test length(jo1.parents) == 1
    @test haskey(jo1.parents, :input)
 
    @test evaluate(jo1).result == 0.5

    jo2 = map(abs, map(x -> Complex(x, x + 1), value(3)))
    @test evaluate(jo2).result == 5
end

@testset "flatmap(func::Function, jo::JO{T})" begin
    in = value(1)

    @test_throws TypeError flatmap(x -> x / 2, in)

    jo = flatmap(x -> value(x / 2), in)

    @test jo isa JO{Float64}
    @test evaluate(jo).result == 0.5
end

@testset "errors handling" begin
    in = value(-1)

    jo = map(x -> x * "text", map(sqrt, in))

    e = evaluate(jo)

    @test e.status == JulIO.Failed
    @test e.error isa DomainError # not MethodError
end

@testset "zip(jos::JO{T}...)" begin
    in = [value(1), value("test"), map(sqrt, value(-1))]

    jo = zip(in...)

    @test jo isa JO{Tuple{Any}}

    e = evaluate(jo)

    @info jo.expr
    @info e.result
    @info e.error
    @test length(e.result) == 3
end

# @testset "test task" begin
#     function downloadUrl(url::String)::JO{String}
#         JO{String}(HTTP.get(url).body)
#     end

#     function downloadUrls(urls::Array{String})::Array{JO{String}}
#         map(downloadUrl, urls)
#     end

#     function collectErrors(fs::Array{JO{String}})::JO{Tuple{Array{String}, Array{Exception}}}
#         reduce
#     end
# end