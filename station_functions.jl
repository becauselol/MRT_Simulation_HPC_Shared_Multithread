function get_neighbour_id(station, line_code, direction)
	values = get(station.neighbours[line_code], direction, nothing)
	if values == nothing
		return nothing
	end 
	return values[1]
end

function get_neighbour_weight(station, line_code, direction)
	values = get(station.neighbours[line_code], direction, nothing)
	if values == nothing
		return nothing
	end 
	return values[2]
end


function add_commuter_to_station(station_commuters, type, commuter)
	commuter_vector = Commuter[]
	if haskey(station_commuters, type)
		commuter_vector = station_commuters[type]
	end

	push!(commuter_vector, commuter)

	return commuter_vector
end

function terminate_commuters_from_station()
	return []
end

function get_target_lines(current_id, target_id, paths)
	if !haskey(paths, current_id)
		return []
	end 

	if !haskey(paths[current_id], target_id)
		return []
	end 

	return keys(paths[current_id][target_id])
end

function board_commuters!(train, station, paths)

	station_commuters = station.commuters["waiting"]

	leftover_commuters = Commuter[]
	if size(station_commuters) == 0
		return station_commuters
	end 

	# check for each commuter do they board
	# the line_direction > 0 if FW direction and < 0 if opposite direction
	line_direction = train.line * ((-1)^(!train.direction))

	train_capacity = get_shared_vector_count(train.commuters)

	for commuter in station_commuters
		if train_capacity >= train.capacity
			push!(leftover_commuters, commuter)
			continue
		end
		# if it is the train they want to board

		commuter_target_lines = get_target_lines(station.station_id, commuter.target, paths)

		if line_direction in commuter_target_lines
			train_capacity += 1
			train.commuters[train_capacity] = commuter

		else
			push!(leftover_commuters, commuter)

		end 
	end
	return leftover_commuters
end

function alight_commuters!(time, metro, train, station)
	train_count = Train_Commuter_Count(station.station_id, time, "pre_alight", get_number_commuters(train))

	alight_count = 0

	if !haskey(train.commuters, station.station_id)
		train.commuters[station.station_id] = []
	end

	if !haskey(station.commuters, "terminating")
		station.commuters["terminating"] = []
	end

	while size(train.commuters[station.station_id])[1] > 0
		commuter = popfirst!(train.commuters[station.station_id])
		commuter.wait_start = time

		if commuter.target == station.station_id
			push!(station.commuters["terminating"], commuter)
 		else 
 			if !haskey(station.commuters, "waiting")
 				station.commuters["waiting"] = []
 			end
 			push!(station.commuters["waiting"], commuter)
		end

		alight_count += 1
	end

	@debug "time $(round(time; digits=2)): $alight_count Commuters alighting Train $(train.train_id) at Station $(station.station_id)"
	
	station_count = Station_Commuter_Count(station.station_id, time, "post_alight", get_number_commuters(station))

	return Dict(
			"train_count" => train_count,
			"station_count" => station_count
		)
end

