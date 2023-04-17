function event_spawn_commuters!(time, metro, station, target, timestep=0.1)
	s = metro.stations[station]

	hour = convert(Int32, floor(time/60))

	rate = s.spawn_rate[target][hour]

	if rate == 0 
		return 0
	end 

	number_spawn = rand(Poisson(rate*timestep), 1)[1]

	# @debug "time $(round(time; digits=2)): spawning commuter at Station $station that wants to go to $target"
	# @debug number_spawn
	for i in 1:number_spawn
		new_commuter = Commuter(
			station,
			target,
			time,
			time,
			0
		)
		s.commuters["waiting"] = add_commuter_to_station(s.commuters, "waiting", new_commuter)
	end
	return number_spawn
end 

function event_terminate_commuters!(time, metro, station)
	s = metro.stations[station]
	count = size(s.commuters["terminating"])[1]
	s.commuters["terminating"] = terminate_commuters_from_station()
	return count
end

function event_train_reach_station!(time, metro, train, station)
	t = metro.trains[train]
	s = metro.stations[station]

	line = t.line
	direction = t.direction

	neighbour_id = get_neighbour_id(s, line, direction)

	if neighbour_id == nothing
		if direction == true
			direction = false
		else 
			direction = true
		end

		t.direction = direction
	end

	# alight and board passengers
	# @debug "time $(round(time; digits=2)): Train $train reaching Station $station"

	wait, terminate = alight_commuters!(t, s, metro.paths)
	s.commuters["waiting"] = wait
	s.commuters["terminating"] = terminate 

	# add the train leave event into the event_queue
	event = Event(time + t.train_transit_time, false, station, train)
	s.event_queue = update_after_push(s.event_queue, event)

	return size(s.commuters["terminating"])[1]
end 

function event_train_leave_station!(time, metro, train, station)
	t = metro.trains[train]
	s = metro.stations[station]

	line = t.line
	direction = t.direction

	neighbour_id = get_neighbour_id(s, line, direction)

	if neighbour_id == nothing
		if direction == true
			direction = false
		else 
			direction = true
		end

		t.direction = direction
		neighbour_id = get_neighbour_id(s, line, direction)
	end

	# @debug "time $time: Train $train leaving  Station $station"

	s.commuters["waiting"] = board_commuters!(t, s, metro.paths)

	# send the event of train reach to another stations buffer
	neighbour = metro.stations[neighbour_id]

	travel_time = get_neighbour_weight(s, line, direction)
	event = Event(time + travel_time, true, convert(Int64, neighbour_id), convert(Int64, train))

	slot = s.neighbour_buffer_address[line][direction]
	add_event_to_buffer!(neighbour.event_buffer, event, slot)
end