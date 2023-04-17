no_stations = 5
buffer_size = 4

# event_buffer = SharedMatrix{Event}(buffer_size, nprocs())
station_dict = Dict()
for i in workers()
	station_dict[i] = Station(i,string(i))
	station_dict[i].event_buffer = SharedVector{Event}(6)
end 

# event_buffers[SharedMatrix{Event}(buffer_size) for _ in 1:nprocs()]

# event_queue = [Event[] for _ in 1:nprocs()]

event = Event(0.0, true, 1, 1)

@testset "Event Passing" begin
	@testset "Get Buffer Size" begin
		@test get_shared_vector_count(station_dict[2].event_buffer) == 0
		@test remotecall_fetch(get_shared_vector_count, 2, station_dict[2].event_buffer) == 0
		@test remotecall_fetch(get_shared_vector_count, 3, station_dict[3].event_buffer) == 0

		# from main to worker
		add_event_to_buffer!(station_dict[2].event_buffer, event, 1)

		# from worker to another worker
		remotecall_fetch(add_event_to_buffer!, 2, station_dict[3].event_buffer, event, 1)

		@test get_shared_vector_count(station_dict[2].event_buffer) == 1
		@test remotecall_fetch(get_shared_vector_count, 2, station_dict[2].event_buffer) == 1
		@test remotecall_fetch(get_shared_vector_count, 3, station_dict[3].event_buffer) == 1
	end

	@testset "Consume Event in Buffer" begin
		@sync station_dict[2].event_queue = remotecall_fetch(update_event_queue!, 2, station_dict[2].event_queue, station_dict[2].event_buffer)
		@test get_shared_vector_count(station_dict[2].event_queue) == 1
		@test get_shared_vector_count(station_dict[2].event_buffer) == 0
	end 

	@testset "Get New Event" begin
		station_dict[2].event_queue, new_event = remotecall_fetch(update_after_pop, 2, station_dict[2].event_queue)

		@test event == new_event
		@test get_shared_vector_count(station_dict[2].event_queue) == 0
	end

	@testset "Testing Multiple Workers" begin
		@sync for i in workers()
			@async begin 
				event = Event(i,true, i,i)
				idx = i - 2
				from = idx
				to = ((from + 1) % nworkers())
				remotecall_fetch(add_event_to_buffer!, from+2, station_dict[to + 2].event_buffer, event, 1)
			end
		end

		@sync for i in workers()
			@sync begin 
				@test get_shared_vector_count(station_dict[i].event_buffer) == 1
				@test get_shared_vector_count(station_dict[i].event_queue) == 0

				station_dict[i].event_queue = remotecall_fetch(update_event_queue!, i, station_dict[i].event_queue, station_dict[i].event_buffer)

				@test get_shared_vector_count(station_dict[i].event_buffer) == 0
				@test get_shared_vector_count(station_dict[i].event_queue) == 1
			end
		end

		@sync for i in workers()
			@sync begin 
				station_dict[i].event_queue, new_event = remotecall_fetch(update_after_pop, i, station_dict[i].event_queue)
				idx = i - 2
				from = ((idx + nworkers() - 1) % nworkers()) + 2
				@test Event(from, true, from, from) ==  new_event
				@test get_shared_vector_count(station_dict[i].event_queue) == 0
			end 
		end 
	end
end






