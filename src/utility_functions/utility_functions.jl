function get_number_commuters(obj)
	# REQUIRE obj to have attribute commuters
	count = 0
	for (key, value) in obj.commuters
	    count += size(value)[1]
	end
	return count
end

function get_line_duration(station_dict, lines, line_code)
	duration = 0

	start_station_id = lines[line_code][true][1]
	curr = station_dict[start_station_id]

	next_id = get_neighbour_id(curr, line_code, true)
	
	while next_id != nothing
		next = station_dict[next_id]
		duration += curr.train_transit_time
		duration += get_neighbour_weight(curr, line_code, true)

		curr = next
		next_id = get_neighbour_id(curr, line_code, true)
	end 	

	return duration * 2
end 

function get_direction(fw_path, i_id, j_id)
	if findfirst(==(i_id), fw_path) < findfirst(==(j_id), fw_path)
		return true
	else 
		return false
	end
end