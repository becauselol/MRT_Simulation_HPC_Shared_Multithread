# all functions return a new event function
# The new event function adds all the events into the queue


function simulate_timestep!(time, metro, data, timestep=0.1, start_spawn=360, stop_spawn = 1440)
	# for all stations we try spawn event
	@debug "$(time)"
	
	spawn_count = zeros(nthreads())
	term_count = zeros(nthreads())

	@threads for station_id in 1:length(metro.stations)
	    begin
	    	station = metro.stations[station_id] 
	    	if (time <= stop_spawn) && (start_spawn <= time)
				hour = convert(Int64, floor(time/60))
		       
				for target_id in 1:length(metro.stations)
					if (target_id == station_id) 
						continue 
					end 
					if !(haskey(station.spawn_rate, target_id))
						continue 
					end 
					spawn_count[threadid()] += event_spawn_commuters!(time, hour, metro, station_id, target_id, timestep)
				end 
			end
				# we check the event queue for any events to process
				# process them accordingly
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
			# we then just terminate at the statio
			begin
		    	station = metro.stations[station_id] 
				term_count[threadid()] += event_terminate_commuters!(time, metro, station_id)
			end
		end 
	end 

	
	@threads for station_id in 1:length(metro.stations)
		station = metro.stations[station_id]
		station.event_queue = update_event_queue!(station.event_queue, station.event_buffer)
	end 
	
	# count = size(metro.stations[94].commuters["terminating"])[1]
	# push!(data, count)
	



	# @assert term_count == term_station_count
	return sum(spawn_count), sum(term_count)
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


function simulate!(start_time, max_time, metro, data, timestep=0.1)
	time = start_time
	spawn_cum = 0
	term_cum = 0
	while time <= max_time 
		# @info "$(time)"
		spawn, term = simulate_timestep!(time, metro, data, timestep)
		spawn_cum += spawn 
		term_cum += term 

		
		time += timestep 
	end 
	@info "spawned: $(spawn_cum), terminated: $(term_cum) "
end 

# function simulate!(max_time, metro, event_queue, data_store)
# 	@sync @threads for pid in workers()
# 		@async simulate_timestep!()
# 	end

# 	@sync @threads for pid in workers()
# 		@async update_event_queues()
# 	end
# end