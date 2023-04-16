example

# limit by worker the assigned subset
@sync for i in workers()
	@async begin
		for station in assigned_stations[i]
			sim_step_station
		end
	end
end 

# assigned by whoever finishes first
@sync @threads for i in stations 
	@async sim_step_station
end 

