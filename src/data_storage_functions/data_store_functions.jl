mutable struct Data_Store
	wait_times::Dict{String, Vector{Float64}}
	percentage_wait_time::Dict{String, Dict{String, Vector{Float64}}}
	travel_times::Dict{String, Dict{String, Vector{Float64}}}
	station_commuter_count::Dict{String, DataFrame}
	station_train_commuter_count::Dict{String, DataFrame}
end