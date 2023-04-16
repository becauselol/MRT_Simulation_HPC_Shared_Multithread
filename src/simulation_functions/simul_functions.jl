# all functions return a new event function
# The new event function adds all the events into the queue
include("station_functions.jl")
include("utility_functions.jl")
include("data_store_functions.jl")


function simulate_timestep!()
	# for all stations we try spawn event

	# we check the train buffer for any events to process
	# process them accordingly

	# we then just terminate at the station
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

function add_event_to_buffer!(event_buffer, event, station_id, slot)
	event_buffer[slot, station_id] = event
end

function update_event_queue!(queue, buffer, station_id)
	# check what the buffer has

	# if there are events in the buffer
	if get_shared_vector_count(buffer[:,station_id]) > 0
		# update the event queue
		for (idx, event) in enumerate(buffer[:,station_id])
			if event.is_real
				heappush!(queue, event)
				buffer[idx, station_id] = Event()
			end
		end
	end

	return queue
end

function update_after_pop(queue)
	event = heappop!(queue)
	return queue, event
end

# function simulate!(max_time, metro, event_queue, data_store)
# 	@sync @threads for pid in workers()
# 		@async simulate_timestep!()
# 	end

# 	@sync @threads for pid in workers()
# 		@async update_event_queues()
# 	end
# end