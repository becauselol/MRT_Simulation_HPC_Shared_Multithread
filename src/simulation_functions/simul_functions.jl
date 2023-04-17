# all functions return a new event function
# The new event function adds all the events into the queue


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

# function simulate!(max_time, metro, event_queue, data_store)
# 	@sync @threads for pid in workers()
# 		@async simulate_timestep!()
# 	end

# 	@sync @threads for pid in workers()
# 		@async update_event_queues()
# 	end
# end