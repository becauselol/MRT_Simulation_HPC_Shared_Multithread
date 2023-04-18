# all functions return a new event function
# The new event function adds all the events into the queue


function simulate_timestep!(time, metro, timestep=0.1, stop_spawn = 1440)
	# for all stations we try spawn event
	@debug "$(time)"
	spawn_count = 0
	if (time <= stop_spawn)
		hour = convert(Int32, floor(time/60))
		for (station_id, station) in metro.stations 
			for (target_id, target) in metro.stations 
				if (target_id == station_id) 
					continue 
				end 
				if !(haskey(station.spawn_rate, target_id))
					continue 
				end 
				spawn = event_spawn_commuters!(time, hour, metro, station_id, target_id, timestep)
				spawn_count = spawn_count + spawn
			end 
		end 
	end 
	@debug "done spawning $(spawn_count)"

	# we check the event queue for any events to process
	term_station_count = 0
	for (station_id, station) in metro.stations 

		while size(station.event_queue)[1] > 0 && station.event_queue[1].time <= time 
			station.event_queue, new_event = update_after_pop(station.event_queue)

			if new_event.event_type
				@assert new_event.station == station_id 
 
				event_train_reach_station!(time, metro, new_event.train, new_event.station)
			else 
				@assert new_event.station == station_id

				event_train_leave_station!(time, metro, new_event.train, new_event.station)
			end 

		end 
	end 
	@debug "trains term count: $(term_station_count)"

	train_count = 0
	for (train_id, train) in metro.trains 
		train_count += get_shared_vector_count(train.commuters) 
	end 
	@debug "train commuters : $(train_count)"

	station_count = 0
	for (station_id, station) in metro.stations 
		station_count += get_shared_vector_count(station.commuters["waiting"]) 
		station_count += get_shared_vector_count(station.commuters["terminating"]) 
	end 
	@debug "station commuters : $(station_count)"

	# process them accordingly

	for (station_id, station) in metro.stations 
		station.event_queue = update_event_queue!(station.event_queue, station.event_buffer)
	end 

	@debug "updated queue"

	# we then just terminate at the station
	term_count = 0
	for (station_id, station) in metro.stations 
		term_count += event_terminate_commuters!(time, metro, station_id)
	end 

	@debug "terminate people $(term_count)"

	# @assert term_count == term_station_count
	return spawn_count, term_count
end

function get_shared_vector_count(shared_vector)
	count = 0
	for item in shared_vector
		if item.is_real
			count += 1
		end 
	end 

	return count
end

function add_event_to_buffer!(buffer, event, slot)
	@assert buffer[slot].is_real == false
	buffer[slot] = event
end

function update_event_queue!(queue, buffer)
	# check what the buffer has

	# if there are events in the buffer
	if get_shared_vector_count(buffer) > 0
		# update the event queue
		for (idx, event) in enumerate(buffer)
			if event.is_real
				heappush!(queue, event)
				buffer[idx] = Event()
			end
		end
	end

	return queue
end

function update_after_pop(queue)
	event = heappop!(queue)
	return queue, event
end

function update_after_push(queue, event)
	heappush!(queue, event)
	return queue 
end 


function simulate!(start_time, max_time, metro, timestep=0.1)
	time = start_time
	spawn_cum = 0
	term_cum = 0
	while time <= max_time 
		# @info "$(time)"
		spawn, term = simulate_timestep!(time, metro, timestep)
		spawn_cum += spawn 
		term_cum += term 

		# @info "spawned: $(spawn_cum), terminated: $(term_cum) "
		time += timestep 
	end 
end 

# function simulate!(max_time, metro, event_queue, data_store)
# 	@sync @threads for pid in workers()
# 		@async simulate_timestep!()
# 	end

# 	@sync @threads for pid in workers()
# 		@async update_event_queues()
# 	end
# end