no_stations = 5
buffer_size = 4

event_buffer = SharedMatrix{Event}(buffer_size, nprocs())

event_queue = [Event[] for _ in 1:nprocs()]

event = Event(0.0, 1, 1, 1, 1)

@testset "Event Passing" begin
	@testset "Get Buffer Size" begin
		@test get_shared_vector_count(event_buffer[:,2]) == 0
		@test remotecall_fetch(get_shared_vector_count, 2, event_buffer[:,2]) == 0
		@test remotecall_fetch(get_shared_vector_count, 3, event_buffer[:,3]) == 0

		# from main to worker
		add_event_to_buffer!(event_buffer, event, 2, 1)

		# from worker to another worker
		remotecall_fetch(add_event_to_buffer!, 2, event_buffer, event, 3, 1)

		@test get_shared_vector_count(event_buffer[:,2]) == 1
		@test remotecall_fetch(get_shared_vector_count, 2, event_buffer[:,2]) == 1
		@test remotecall_fetch(get_shared_vector_count, 3, event_buffer[:,3]) == 1
	end

	@testset "Consume Event in Buffer" begin
		@sync event_queue[2] = remotecall_fetch(update_event_queue!, 2, event_queue[2], event_buffer, 2)
		@test get_shared_vector_count(event_queue[2]) == 1
		@test get_shared_vector_count(event_buffer[:,2]) == 0
	end 

	@testset "Get New Event" begin
		event_queue[2], new_event = remotecall_fetch(update_after_pop, 2, event_queue[2])

		@test event == new_event
		@test get_shared_vector_count(event_queue[2]) == 0
	end

	@testset "Testing Multiple Workers" begin
		@sync for i in workers()
			@async begin 
				event = Event(i,i,i,i,i)
				idx = i - 2
				from = idx
				to = ((from + 1) % nworkers())
				remotecall_fetch(add_event_to_buffer!, from+2, event_buffer, event, to + 2, 1)
			end
		end

		@sync for i in workers()
			@sync begin 
				@test get_shared_vector_count(event_buffer[:,i]) == 1
				@test get_shared_vector_count(event_queue[i]) == 0

				event_queue[i] = remotecall_fetch(update_event_queue!, i, event_queue[i], event_buffer, i)

				@test get_shared_vector_count(event_buffer[:,i]) == 0
				@test get_shared_vector_count(event_queue[i]) == 1
			end
		end

		@sync for i in workers()
			@sync begin 
				event_queue[i], new_event = remotecall_fetch(update_after_pop, i, event_queue[i])
				idx = i - 2
				from = ((idx + nworkers() - 1) % nworkers()) + 2
				@test Event(from, from, from, from, from) ==  new_event
				@test get_shared_vector_count(event_queue[i]) == 0
			end 
		end 
	end
end






