function create_trains(line_code, line_duration, period, capacity, direction=true)
	max_no = trunc(Int, line_duration / period)
	trains = Dict()

	for i in 1:max_no
		trains[line_code*1000 + i] = Train(line_code*1000 + i, line_code, direction, capacity)
	end

	return trains
end

function create_period_train_placement_events(line_code, line_duration, period, capacity, depot_id, direction=true, start_time=0)
	events = []

	trains = create_trains(line_code, line_duration, period, capacity, direction)
	period = line_duration / length(trains)
	time = start_time
	for train_id in keys(trains)
		new_event = Event(
			time,
			true,
			depot_id,
			train_id
			)
		time += period

		push!(events, new_event)
	end 

	return events, trains
end