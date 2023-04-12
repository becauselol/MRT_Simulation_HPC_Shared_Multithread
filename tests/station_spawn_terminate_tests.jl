@testset "Add Commuter" begin
	station = Station(1, "hi", String[])

	SPANW_EVENT = 20000
	TERMINATE_EVENT = 20001

	commuter = Commuter(1, 2, 0.0, 0.0, 0.0)
	commuter_2 = Commuter(1, 3, 0.0, 0.0, 0.0)
	station.commuters["waiting"] = add_commuter_to_station(station.commuters, "waiting", commuter)
	@test size(station.commuters["waiting"])[1] == 1

	station.commuters["waiting"] = remotecall_fetch(add_commuter_to_station, 2, station.commuters, "waiting", commuter_2)

	@test station.commuters["waiting"][2].target == 3
	@test size(station.commuters["waiting"])[1] == 2

	key = "terminating"
	station.commuters[key] = add_commuter_to_station(station.commuters, key, commuter)
	@test size(station.commuters[key])[1] == 1

	station.commuters[key] = remotecall_fetch(add_commuter_to_station, 2, station.commuters, key, commuter_2)
	
	@test station.commuters[key][2].target == 3
	@test size(station.commuters[key])[1] == 2
	@test "waiting" in keys(station.commuters) && "terminating" in keys(station.commuters)

	@testset "MultiThread Addition" begin
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


@testset "Remove Commuter" begin
	station = Station(1, "hi", String[])

	SPANW_EVENT = 20000
	TERMINATE_EVENT = 20001

	commuter = Commuter(1, 2, 0.0, 0.0, 0.0)
	commuter_2 = Commuter(1, 3, 0.0, 0.0, 0.0)
	station.commuters["terminating"] = [commuter, commuter_2]

	station.commuters["terminating"] = remotecall_fetch(terminate_commuters_from_station, 2)
	@test size(station.commuters["terminating"])[1] == 0

	@testset "MultiThread Removal" begin
		station_dict = Dict()
		@sync for i in workers()
			@async station_dict[i] = remotecall_fetch(Station, i, i, "station_$i")
		end

		key = "terminating"

		@sync for i in workers()
			@async begin 
				commuter = Commuter(i,i, 0.0, 0.0, 0.0)
				for j in 1:i
					station_dict[i].commuters[key] = remotecall_fetch(add_commuter_to_station, i, station_dict[i].commuters, key, commuter)
				end  
				if i == 3
					return
				end 
				station_dict[i].commuters[key] = remotecall_fetch(terminate_commuters_from_station, i)
			end
		end 

		for i in workers()
			if i == 3
				@test size(station_dict[i].commuters[key])[1] == i
			else
				@test size(station_dict[i].commuters[key])[1] == 0
			end 
		end 
	end

end