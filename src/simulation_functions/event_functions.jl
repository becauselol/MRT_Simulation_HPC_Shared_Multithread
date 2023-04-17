function event_spawn_commuters!(time, metro, station, target, timestep=0.1)
	s = metro.stations[station]

	hour = convert(Int32, floor(time/60))

	rate = s.spawn_rate[target][hour]

	if rate == 0 
		return 
	end 

	number_spawn = rand(Exponential(rate*timestep), 1)[1]

	@debug "time $(round(time; digits=2)): spawning commuter at Station $station that wants to go to $target"

	for i in 1:number_spawn
		new_commuter = Commuter(
			station,
			target,
			time,
			time,
			0
		)
		station.commuters["waiting"] = add_commuter_to_station(s.commuters, "waiting", new_commuter)
	end
end 

function event_terminate_commuters!(time, metro, station)
	s = metro.stations[station]
	station.commuters["waiting"] = terminate_commuters_from_station()
end

function event_train_reach_station!(time, metro, train, station)
	t = metro.trains[train]
	s = metro.stations[station]

	line = t.line
	direction = t.direction

	neighbour_id = get_neighbour_id(s, line, direction)

	if neighbour_id == nothing
		if direction == "FW"
			direction = "BW"
		else 
			direction = "FW"
		end

		t.direction = direction
	end

	# alight and board passengers
	@debug "time $(round(time; digits=2)): Train $train reaching Station $station"

	wait, terminate = alight_commuters!(t, s, metro.paths)
	s.commuters["waiting"] = wait
	s.commuters["terminating"] = terminate 

	# add the train leave event into the event_queue
	event = Event(time + t.train_transit_time, false, station, train)
	heappush!(s.event_queue, event)
end 

function event_train_leave_station(time, metro, train, station)
	t = metro.trains[train]
	s = metro.stations[station]

	line = t.line
	direction = t.direction

	neighbour_id = get_neighbour_id(s, line, direction)

	if neighbour_id == nothing
		if direction == "FW"
			direction = "BW"
		else 
			direction = "FW"
		end

		t.direction = direction
		neighbour_id = get_neighbour_id(s, line, direction)
	end

	@debug "time $time: Train $train leaving  Station $station"

	s.commuters["waiting"] = board_commuters!(t, s, metro.paths)

	# send the event of train reach to another stations buffer
	neighbour = metro.stations[neighbour_id]

	travel_time = get_neighbour_weight(station, line, direction)
	event = Event(time + travel_time, true, neighbour_id, train)

	slot = s.neighbour_buffer_address[neighbour_id]
	add_event_to_buffer!(neighbour, event, slot)
end