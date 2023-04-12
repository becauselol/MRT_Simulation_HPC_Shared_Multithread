FW = true 
BW = false

s = Station(1, "1", String[])
s.neighbours[1000] = Dict()
s.neighbours[1000][FW] = [2, 3]

@testset "Get Neighbour Functions" begin
	@testset "Get ID" begin
		@test get_neighbour_id(s, 1000, FW) == 2
		@test get_neighbour_id(s, 1000, BW) == nothing
	end;
	@testset "Get Weight" begin
		@test get_neighbour_weight(s, 1000, FW) == 3
		@test get_neighbour_weight(s, 1000, BW) == nothing
	end;
end;