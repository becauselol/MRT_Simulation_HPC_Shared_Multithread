@testset "Board Train" begin
	station_dict = Dict()
	@sync for i in workers()
		@async station_dict[i] = remotecall_fetch(Station, i, i, "station_$i")
	end

	train_dict = Dict()
	@sync for i in workers()
		@async begin
			train_dict[i] = remotecall_fetch(Train, i, i, 1, capacity)
			train_dict[i + nworkers()] = remotecall_fetch(Train, i, i + nworkers(), 1, false, false, capacity)
		end
	end

	@testset "MultiThread Boarding" begin
		station_dict = Dict()
		@sync for i in workers()
			@async station_dict[i] = remotecall_fetch(Station, i, i, "station_$i")
		end

		key = "waiting"
		@sync for i in workers()
			@async begin 
				commuter = Commuter(i,i, 0.0, 0.0, 0.0)
				for j in 1:i
					station_dict[i].commuters[key] = remotecall_fetch(add_commuter_to_station, i, station_dict[i].commuters, key, commuter)
				end  
			end
		end 

		for i in workers()
			@test size(station_dict[i].commuters[key])[1] == i
		end 

		@test haskey(station_dict, 1) == false
	end
end