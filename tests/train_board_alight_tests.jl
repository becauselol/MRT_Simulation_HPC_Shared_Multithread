# Define a few variables
a_neighbour = Dict(1 => Dict(true => [2, 1]))
station_a = Station(1, "Station A")


b_neighbour = Dict(1 => Dict(true => [3, 2], false => [1, 1]))
station_b = Station(2, "Station B")

c_neighbour = Dict(1 => Dict(false => [2, 2]))
station_c = Station(3, "Station C")

train1 = Train(1, 1, 5)
train2 = Train(2, 1, 5)
train3 = Train(3, 1, false, 5)
train4 = Train(4, 2, 5)


station_dict = Dict(
		1 => station_a,
		2 => station_b,
		3 => station_c
	)

train_dict = Dict(
		1 => train1,
		2 => train2,
		3 => train3,
		4 => train4
	)
lines = Dict(
		1 => [1, 2, 3],
		-1 => [3, 2, 1]
	)

paths = Dict(
		1 => Dict(
			2 => Dict(1 => 2),
			3 => Dict(1 => 3) # modified to test people getting off the station into waiting
			),
		2 => Dict(
			1 => Dict(-1 => 1),
			3 => Dict(1 => 3)
			),
		3 => Dict(
			1 => Dict(-1 => 1),
			2 => Dict(-1 => 2, 2 => 2),
			)
	)

@testset "Utility Get Board targets" begin
	@test all(get_target_boarding_lines(1,2, paths) .== [1])
	@test get_target_boarding_lines(3,4,paths) == []
	@test all(get_target_boarding_lines(3,2,paths) .== [-1,2])
	@test all(get_target_boarding_lines(4,2,paths) .== [])
end


@testset "Board Train" begin
	key = "waiting"
	target_dict = Dict()
	for i in 1:5
		commuter = Commuter(1,2, 0.0, 0.0, 0.0)
		station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		commuter = Commuter(1,4, 0.0, 0.0, 0.0)
		station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		commuter = Commuter(1,3, 0.0, 0.0, 0.0)
		station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
	end 


	@testset "Worker Board" begin
		station_dict[1].commuters["waiting"] = remotecall_fetch(board_commuters!, 2, train1, station_dict[1], paths)

		@test size(station_dict[1].commuters["waiting"])[1] == 10
		@test get_shared_vector_count(train1.commuters) == 5
	end

	@testset "Wrong Direction" begin
		trainwrong = Train(2, 1, false, 5)
		station_dict[1].commuters["waiting"] = remotecall_fetch(board_commuters!, 2, trainwrong, station_dict[1], paths)
		@test size(station_dict[1].commuters["waiting"])[1] == 10
		@test get_shared_vector_count(train2.commuters) == 0
	end

	for i in 1:size(train1.commuters)[1]
		train1.commuters[i] = Commuter()
	end 
	station_dict[1].commuters["waiting"] = terminate_commuters_from_station()
	@testset "Multi Board" begin
		for i in 1:3
			commuter = Commuter(1,2, 0.0, 0.0, 0.0)
			station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
			commuter = Commuter(2,3, 0.0, 0.0, 0.0)
			station_dict[2].commuters["waiting"] = add_commuter_to_station(station_dict[2].commuters, "waiting", commuter)
			commuter = Commuter(3,1, 0.0, 0.0, 0.0)
			station_dict[3].commuters["waiting"] = add_commuter_to_station(station_dict[3].commuters, "waiting", commuter)
		end

		@sync @threads for i in 2:4
			@async station_dict[i-1].commuters["waiting"] = remotecall_fetch(board_commuters!, i, train_dict[i-1], station_dict[i-1], paths)
		end

		for i in 1:3 
			@test size(station_dict[i].commuters["waiting"])[1] == 0
			@test get_shared_vector_count(train_dict[i].commuters) == 3
		end 
	end
end

# redefine
# Define a few variables
a_neighbour = Dict(1 => Dict(true => [2, 1]))
station_a = Station(1, "Station A")


b_neighbour = Dict(1 => Dict(true => [3, 2], false => [1, 1]))
station_b = Station(2, "Station B")

c_neighbour = Dict(1 => Dict(false => [2, 2]))
station_c = Station(3, "Station C")

train1 = Train(1, 1, 5)
train2 = Train(2, 1, 5)
train3 = Train(3, 1, false, 5)
train4 = Train(4, 2, 5)


station_dict = Dict(
		1 => station_a,
		2 => station_b,
		3 => station_c
	)

train_dict = Dict(
		1 => train1,
		2 => train2,
		3 => train3,
		4 => train4
	)

# modified to test people getting off the station into waiting
test_terminate_paths = Dict(
		1 => Dict(
			2 => Dict(1 => 2),
			3 => Dict(1 => 3),
			4 => Dict(1 => 2),
			),
		2 => Dict(
			1 => Dict(-1 => 1),
			3 => Dict(1 => 3),
			4 => Dict(2 => 4)
			),
		3 => Dict(
			1 => Dict(-1 => 1),
			2 => Dict(-1 => 2, 2 => 2),
			)
	)

@testset "Alight Commuters" begin
	@testset "Worker Alight" begin
		for i in 1:3
			commuter = Commuter(1,2, 0.0, 0.0, 0.0)
			station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		end 
		for i in 1:2
			commuter = Commuter(1,3, 0.0, 0.0, 0.0)
			station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		end 

		station_dict[1].commuters["waiting"] = remotecall_fetch(board_commuters!, 2, train1, station_dict[1], paths)
		@test size(station_dict[1].commuters["waiting"])[1] == 0
		@test get_shared_vector_count(train1.commuters) == 5

		wait, terminate = remotecall_fetch(alight_commuters!, 2, train1, station_dict[2], paths)
		station_dict[2].commuters["waiting"] = wait
		station_dict[2].commuters["terminating"] = terminate 
		@test size(station_dict[2].commuters["waiting"])[1] == 0
		@test size(station_dict[2].commuters["terminating"])[1] == 3
		@test get_shared_vector_count(train1.commuters) == 2
	end

	for i in 1:size(train1.commuters)[1]
		train1.commuters[i] = Commuter()
	end 
	station_dict[2].commuters["terminating"] = terminate_commuters_from_station()

	@testset "Worker Alight Interchange" begin 
		for i in 1:3
			commuter = Commuter(1,2, 0.0, 0.0, 0.0)
			station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		end 
		for i in 1:2
			commuter = Commuter(1,4, 0.0, 0.0, 0.0)
			station_dict[1].commuters["waiting"] = add_commuter_to_station(station_dict[1].commuters, "waiting", commuter)
		end 

		station_dict[1].commuters["waiting"] = remotecall_fetch(board_commuters!, 2, train1, station_dict[1], test_terminate_paths)
		@test size(station_dict[1].commuters["waiting"])[1] == 0
		@test get_shared_vector_count(train1.commuters) == 5

		wait, terminate = remotecall_fetch(alight_commuters!, 2, train1, station_dict[2], test_terminate_paths)
		station_dict[2].commuters["waiting"] = wait
		station_dict[2].commuters["terminating"] = terminate 
		@test size(station_dict[2].commuters["waiting"])[1] == 2
		@test size(station_dict[2].commuters["terminating"])[1] == 3
		@test get_shared_vector_count(train1.commuters) == 0
	end

	for i in 1:size(train1.commuters)[1]
		train1.commuters[i] = Commuter()
	end 
	station_dict[2].commuters["terminating"] = terminate_commuters_from_station()
end