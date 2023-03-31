using Test

include("../src/JulIO.jl");         using .JulIO
include("../src/Evaluator.jl");     using .Evaluator


@testset "value(v::T)" begin
    jo = value(42)

    @test jo isa JO{Int64}
    @test eval(jo.expr) == 42
    @test isempty(jo.parents)
end

@testset "map(func::Function, jo::JO{T})" begin
    in = value(1)
    jo1 = map(x -> x / 2, in)

    @test jo1 isa JO{Float64}
    @test length(jo1.parents) == 1
    @test haskey(jo1.parents, :input)
 
    @test evaluate(jo1) == 0.5

    jo2 = map(abs, map(x -> Complex(x, x + 1), value(3)))
    @test evaluate(jo2) == 5
end
