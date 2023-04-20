function process_spawn_rate!(spawn_data_file_path, station_dict)
	code_map = create_station_code_map(station_dict)
	spawn_data_csv = CSV.File(spawn_data_file_path, header=false)

	# let us try matrix instead and also just max it out...
	for (station_id, station) in station_dict 
		station.spawn_rate = Matrix{Float64}(undef, length(station_dict), 24)
		fill!(station.spawn_rate, -1)
	end 

	for row in spawn_data_csv
		hour = convert(Int64, row[1])

		from_codes = String(row[2])
		from_code_arr = String.(split(from_codes, "/"))
		from_id = nothing
		for code in from_code_arr
			if haskey(code_map, code)
				from_id = code_map[code]
				break
			end
		end


		to_codes = String(row[3])
		to_code_arr = String.(split(to_codes, "/"))
		to_id = nothing
		for code in to_code_arr
			if haskey(code_map, code)
				to_id = code_map[code]
				break
			end
		end

		rate = convert(Float64, (row[4]/60))

		if (from_id == nothing || to_id == nothing)
			continue
		end

		from_station = station_dict[from_id]

		if hour == 0
			from_station.spawn_rate[to_id, 24] = rate
		else
			from_station.spawn_rate[to_id, hour] = rate
		end
	end
end