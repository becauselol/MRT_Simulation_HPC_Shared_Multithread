function construct_station_dict(station_csv_location)
	station_count = 1

	station_data = Dict()

	station_csv = CSV.File(station_csv_location, header=false)

	# for each station in station_string
	for row in station_csv
    	station_name = String(row[1])

    	stationCodes = String[]
        for c in eachsplit(row[2], "/")
            push!(stationCodes, String(c))
        end

    	station_data[station_count] = Station(
    			station_count,
				station_name,
				stationCodes
    		)
    	station_data[station_count].commuters["waiting"] = Commuter[]
    	station_data[station_count].commuters["terminating"] = Commuter[]
    	station_count += 1
	end

	return station_data
end

function construct_station_name_id_map(station_dict)
	name_id_map = Dict()
	for (station_id, station) in station_dict 
		name_id_map[station.name] = station_id 
	end 
	return name_id_map
end

function create_station_code_map(station_dict)
	code_map = Dict()
	for (station_id, station) in station_dict 
		for code in station.stationCodes
			code_map[code] = station_id
		end
	end
	return code_map
end

function construct_edges_from_edges_dict!(station_dict, line_names, filepath = "data/input")
	# create code mapping for stations
	code_map = create_station_code_map(station_dict)
	start_station_dict = Dict()
	line_index_map = Dict()
	line_count = 1
	for line_code in line_names
		start_station_id = construct_edges_for_line!(line_code, station_dict, code_map, line_count, filepath)
		start_station_dict[line_count] = start_station_id
		line_count += 1
	end

	return start_station_dict
end

function add_station_neighbour!(from_station, to_station_id, line, direction, weight)
    if !(line in keys(from_station.neighbours))
        from_station.neighbours[line] = Dict()
    end
	from_station.neighbours[line][direction] = [to_station_id, weight]
end

function construct_edges_for_line!(line_code, station_dict, code_map, line_idx, filepath = "data/input")

	edges_csv = CSV.File("$(filepath)/$(line_code)_data.csv", header=false)

	# for each station in station_string
	first_edge = edges_csv[1]
	first_station_code = String(first_edge[1])

	first_station_id = code_map[first_station_code]
	first_station = station_dict[first_station_id]
	push!(first_station.codes, line_idx)

	for edge_details in edges_csv
    	from_station_code = String(edge_details[1])
    	to_station_code = String(edge_details[2])
    	time_taken = convert(Float64, edge_details[3])

    	from_station_id = code_map[from_station_code]
    	to_station_id = code_map[to_station_code]

    	from_station = station_dict[from_station_id]
    	to_station = station_dict[to_station_id]

    	push!(to_station.codes, line_idx)
    	add_station_neighbour!(from_station, to_station_id, line_idx, true, time_taken)
    	add_station_neighbour!(to_station, from_station_id, line_idx, false, time_taken)
	end

	

	return first_station_id
end

function construct_lines_from_start_stations(station_dict, start_stations)
	lines = Dict()

	for (line_code, start_station_id) in start_stations 
		lines[line_code] = Dict()

		lines[line_code][true] = [start_station_id]

		curr_id = start_station_id
		curr = station_dict[curr_id]

		next_id = get_neighbour_id(curr, line_code, true)

		while next_id != nothing
			next = station_dict[next_id]
			push!(lines[line_code][true], next_id)
			curr = next
			next_id = get_neighbour_id(curr, line_code, true)
		end

		lines[line_code][false] = reverse(lines[line_code][true])
	end

	return lines
end


function construct_commuter_graph(station_dict)
	commuter_edge_dict = Dict()
	commuter_node_list = []

	for (station_id, station) in station_dict 
		# @debug "$(station.name), id: $(station_id), codes:$(station.codes)"
		for code in station.codes
			push!(commuter_node_list, "$(station_id).$(code)")
			commuter_edge_dict["$(station_id).$(code)"] = Dict()
		end 

		for iCode in station.codes
			for jCode in station.codes
				if iCode == jCode
					continue
				end 

				commuter_edge_dict["$(station_id).$(iCode)"]["$(station_id).$(jCode)"] = 0.1
			end 
		end 

		for (line, line_dict) in station.neighbours
			for (direction, values) in line_dict 
				commuter_edge_dict["$(station_id).$(line)"]["$(convert(Int64, values[1])).$(line)"] = values[2] + station.train_transit_time
			end 	
		end 
	end 

	return CommuterGraph(commuter_node_list, commuter_edge_dict)
end 

function assign_buffer_slot!(station_dict)
	max_buffer_size = 0

	for (station_id, station) in station_dict 
		slot = 1

		for (line_code, direction_dict) in station.neighbours
			for (direction, values) in direction_dict
				neighbour_id = values[1]
				n = station_dict[neighbour_id]

				if !(haskey(n.neighbour_buffer_address, line_code))
					n.neighbour_buffer_address[line_code] = Dict{Bool, Int64}()
				end 

				n.neighbour_buffer_address[line_code][!direction] = slot
				slot += 1
			end 
		end 
		max_buffer_size = max(max_buffer_size, slot - 1)
	end 

	for (station_id, station) in station_dict 
		station.event_buffer = SharedVector{Event}(max_buffer_size)
	end 

	return max_buffer_size
end 