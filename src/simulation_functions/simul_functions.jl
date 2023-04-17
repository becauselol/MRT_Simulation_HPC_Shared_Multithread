# all functions return a new event function
# The new event function adds all the events into the queue


function simulate_timestep!(time, metro, timestep=0.1)
	# for all stations we try spawn event
	@debug "$(time)"
	@threads for (station_id, station) in metro.stations 
		for (target_id, target) in metro.stations 
			if (target_id == station_id) 
				continue 
			end 
			if !(haskey(station.spawn_rate, target_id))
				continue 
			end 
			event_spawn_commuters!(time, metro, station_id, target_id, timestep)
		end 
	end 
	@debug "done spawning"

	# we check the event queue for any events to process
	@threads for (station_id, station) in metro.stations 

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
	@debug "trains"

	# process them accordingly

	@threads for (station_id, station) in metro.stations 
		station.event_queue = update_event_queue!(station.event_queue, station.event_buffer)
	end 

	@debug "updated queue"

	# we then just terminate at the station

	@threads for (station_id, station) in metro.stations 
		event_terminate_commuters!(time, metro, station_id)
	end 

	@debug "terminate people"
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
	while time <= max_time 
		simulate_timestep!(time, metro, timestep)
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