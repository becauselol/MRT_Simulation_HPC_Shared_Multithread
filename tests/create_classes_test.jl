@testset "Create Class Test" begin
	@testset "Create Event Test" begin
		@test Event(1, true, 1, 1) == Event(1.0, true, 1, 1, true)
		@test Event(1.0, true, 1, 1) == Event(1.0, true, 1, 1, true)
		@test Event() == Event(0.0,false,0,0,false)
	end

	@testset "Create Station" begin
		station_dict = Dict()
		@sync for i in workers()
			@async station_dict[i] = remotecall_fetch(Station, i, i, "station_$i")
		end

		for i in workers()
			@test station_dict[i].name == "station_$i"
		end 
	end

	@testset "Create Train" begin
		train_dict = Dict()
		capacity = 100
		@sync for i in workers()
			@async begin
				train_dict[i] = remotecall_fetch(Train, i, i, i, capacity)
				train_dict[i + nworkers()] = remotecall_fetch(Train, i, i, i, false, capacity)
			end
		end

		for i in workers()
			@test train_dict[i].train_id == i
			@test train_dict[i + nworkers()].direction == false
			@test train_dict[i + nworkers()].train_id == i
		end 
	end

end
