using Test
using HTTP
using BenchmarkTools

include("../src/JulIO.jl");         using .JulIO    


@testset "value(v::T)" begin
    jo = value(42)

    @test jo isa JO{Int64}
    @test eval(jo.expr) == 42
    @test isempty(jo.parents)
    e = evaluate!(jo)
    @test e.status == JulIO.Succeed
    @test e.result == 42
end

@testset "map(func::Function, jo::JO{T})" begin
    in = value(1)
    jo1 = map(x -> x / 2, in)

    @test jo1 isa JO{Float64}
    @test length(jo1.parents) == 1
    @test haskey(jo1.parents, "input")
 
    @test evaluate!(jo1).result == 0.5

    jo2 = map(abs, map(x -> Complex(x, x + 1), value(3)))
    @test evaluate!(jo2).result == 5
end

@testset "flatmap(func::Function, jo::JO{T})" begin
    in = value(1)

    @test_throws TypeError flatmap(x -> x / 2, in)

    jo = flatmap(x -> value(x / 2), in)

    @test jo isa JO{Float64}
    @test evaluate!(jo).result == 0.5
end

@testset "errors handling" begin
    in = value(-1)

    jo = map(x -> x * "text", map(sqrt, in))

    e = evaluate!(jo)

    @test e.status == JulIO.Failed
    @test e.error isa DomainError # not MethodError
end

@testset "zip(jos::JO{T}...)" begin
    in = [value(1), value("test"), map(sqrt, value(-1))]

    jo = zip(in...)

    @test jo isa JO{Tuple}

    e = evaluate!(jo)

    @test length(e.result) == 3
    @test e.result isa Tuple{Int64, String, DomainError}
    @test e.result[1] == 1
    @test e.result[2] == "test"
    @test e.result[3] isa DomainError
end

@testset "Test task" begin
    function downloadUrl(url::String)::JO{String}
        map(String, url -> String(HTTP.get(url).body), value(url))
    end

    function downloadUrls(urls::Array{String})::Array{JO{String}}
        map(downloadUrl, urls)
    end

    function collectErrors(jos::Array{JO{String}})::JO{Tuple{Array{String}, Array{Exception}}}
        map(Tuple{Array{String},Array{Exception}}, rs -> ([filter(r -> !(r isa Exception), rs)...], [filter(r -> r isa Exception, rs)...]), zip(jos...))
    end

    urls = ["http://ifconfig.me", "https://api.sampleapis.com/futurama/info", "http://wrong.url"]
    jo = (collectErrors ∘ downloadUrls)(urls)

    evaluate!(jo)

    @test jo.result isa Tuple{Array{String}, Array{Exception}}
    @test length(jo.result[1]) == 2
    @test length(jo.result[2]) == 1
end

const nums = [rand(-10:10) for _ in 1:10]

function sqrt_it(num::Int64)::JO{Float64}
    map(Float64, sqrt, value(num))
end

function sqrt_them(nums::Array{Int64})::Array{JO{Float64}}
    map(sqrt_it, nums)
end

function collectErrors(jos::Array{JO{Float64}})::JO{Tuple{Array{Float64}, Array{Exception}}}
    map(Tuple{Array{Float64},Array{Exception}}, rs -> ([filter(r -> !(r isa Exception), rs)...], [filter(r -> r isa Exception, rs)...]), zip(jos...))
end

@testset "Random test with timings" begin
    pos_count = length(filter(x -> x >= 0, nums))
    neg_count = length(filter(x -> x < 0, nums))

    it = @btime begin
        results = Array{Float64}(undef, 0)
        errors = Array{Exception}(undef, 0)

        for num in nums
            try
                push!(results, sqrt(num))
            catch ex
                push!(errors, ex)
            end
        end

        (results, errors)
    end

    @test it isa Tuple{Array{Float64}, Array{Exception}}
    @test length(it[1]) == pos_count
    @test length(it[2]) == neg_count

    # :(((

    # on 10     nums JulIO took ~13.5 times more time and ~546      times more memory
    # on 100    nums JulIO took ~29   times more time and ~3211     times more memory
    # on 1000   nums JulIO took ~178  times more time and ~38732    times more memory

    ev = @btime begin
        jo = (collectErrors ∘ sqrt_them)(nums)
        evaluate!(jo; distributed=false)
    end

    @test ev.result isa Tuple{Array{Float64}, Array{Exception}}
    @test length(ev.result[1]) == pos_count
    @test length(ev.result[2]) == neg_count

    # TODO: Why distributed does not lowering calculation time? Maybe too simple case...

    ev = @btime begin
        jo = (collectErrors ∘ sqrt_them)(nums)
        evaluate!(jo)
    end

    @test ev.result isa Tuple{Array{Float64}, Array{Exception}}
    @test length(ev.result[1]) == pos_count
    @test length(ev.result[2]) == neg_count
end