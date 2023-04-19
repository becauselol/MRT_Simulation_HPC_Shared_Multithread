mutable struct Data_Store
	wait_times::Vector{Vector{Float64}}
	percentage_wait_time::Matrix{Vector{Float64}}
	travel_times::Matrix{Vector{Float64}}
	station_commuter_count::Vector{Vector{Int64}}
	station_train_commuter_count::Vector{Vector{Int64}}
	function Data_Store(n)
		x = new(
			Vector{Vector{Float64}}(undef, n),
			Matrix{Vector{Float64}}(undef, n, n),
			Matrix{Vector{Float64}}(undef, n, n),
			Vector{Vector{Float64}}(undef, n),
			Vector{Vector{Float64}}(undef, n)
			)

		fill!(x.wait_times, Float64[])
		fill!(x.station_commuter_count, Float64[])
		fill!(x.station_train_commuter_count, Float64[])
		fill!(x.travel_times, Float64[])
		fill!(x.percentage_wait_time, Float64[])
		
		return x
	end 
end