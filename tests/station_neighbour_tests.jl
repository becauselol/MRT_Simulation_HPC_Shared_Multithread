using Test
include("../classes.jl")
include("../station_functions.jl")

s = Station(1, "test", [])
s.neighbours[1000] = Dict()
s.neighbours[1000][true] = [2, 3]

@testset "Get Neighbour Functions" begin
	@testset "Get ID" begin
		@test get_neighbour_id(s, 1000, true) == 2
		@test get_neighbour_id(s, 1000, false) == nothing
	end;
	@testset "Get Weight" begin
		@test get_neighbour_weight(s, 1000, true) == 3
		@test get_neighbour_weight(s, 1000, false) == nothing
	end;
end;