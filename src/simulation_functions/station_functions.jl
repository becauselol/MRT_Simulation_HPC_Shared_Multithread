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
	commuter_vector = station_commuters[type]

	push!(commuter_vector, commuter)

	return commuter_vector
end

function terminate_commuters_from_station()
	return []
end

function get_target_boarding_lines(current_id, target_id, paths)
	target_id_dict = get(paths, current_id, nothing)
	if target_id_dict == nothing
		return []
	end 

	line_dict = get(target_id_dict, target_id, nothing)
	if line_dict == nothing
		return []
	end

	return keys(line_dict)
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
	@debug "capacity: $(train_capacity)"
	for commuter in station_commuters
		if train_capacity >= train.capacity
			push!(leftover_commuters, commuter)
			continue
		end
		# if it is the train they want to board

		commuter_target_lines = get_target_boarding_lines(station.station_id, commuter.target, paths)

		if line_direction in commuter_target_lines
			@debug "boarding"
			train_capacity += 1
			train.commuters[train_capacity] = commuter

		else
			push!(leftover_commuters, commuter)
		end 
	end
	return leftover_commuters
end

function get_target_alighting_station(current_id, target_id, line_direction, paths)
	target_id_dict = get(paths, current_id, nothing)
	if target_id_dict == nothing
		return nothing
	end 

	line_dict = get(target_id_dict, target_id, nothing)
	if line_dict == nothing
		return nothing
	end

	stations = get(line_dict, line_direction, nothing)
	return stations
end

function alight_commuters!(train, station, paths)
	waiting_commuters = station.commuters["waiting"]
	terminating_commuters = station.commuters["terminating"]

	current_id = station.station_id
	line_direction = train.line * ((-1)^(!train.direction))

	train_slot = 1

	for commuter in train.commuters
		if commuter.is_real == false 
			break 
		end 

		if commuter.target == current_id
			push!(terminating_commuters, commuter)
			continue
		end 

		target_boarding_lines = get_target_boarding_lines(current_id, commuter.target, paths)
		if !(line_direction in target_boarding_lines)
			push!(waiting_commuters, commuter)
			continue
		end

		train.commuters[train_slot] = commuter 
		train_slot += 1
	end 

	for i in (train_slot):train.capacity 
		train.commuters[i] = Commuter()
	end 

	return waiting_commuters, terminating_commuters
end

