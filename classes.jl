using SharedArrays

struct Event
	time::Float64
	event_type::Int64 # effectively decides the type of function we will use
	station::Int64 # set of parameters any function will use
	target::Int64
	train::Int64
	is_real::Bool
	function Event(time::Float64, event_type::Int64, station::Int64, target::Int64, train::Int64, is_real::Bool)
		return new(
			time,
			event_type,
			station,
			target,
			train,
			is_real
			)
	end
	function Event(time::Int64, event_type::Int64, station::Int64, target::Int64, train::Int64)
		return new(
			convert(Float64, time),
			event_type,
			station,
			target,
			train,
			true
			)
	end
	function Event(time::Float64, event_type::Int64, station::Int64, target::Int64, train::Int64)
		return new(
			time,
			event_type,
			station,
			target,
			train,
			true
			)
	end
	function Event()
		return new(0.0,0,0,0,0,false)
	end
end

struct Commuter
	origin::Int64 # origin station id
	target::Int64 # path to take
	spawn_time::Float64 # time it was spawned at
	wait_start::Float64 # time it started waiting for the next train
	total_wait_time::Float64 # total time the commuter spent waiting
	is_real::Bool # just check if it is placeholder

	function Commuter()
		return new(0, 0, false, 0.0, 0.0, 0.0, false)
	end 

	function Commuter(origin::Int64, target::Int64, spawn_time::Float64, wait_start::Float64, total_wait_time::Float64 )
		return new(origin, target, spawn_time, wait_start, total_wait_time, true)
	end 
end

mutable struct Train
	train_id::Int64
	line::Int64
	direction::Bool
	movement::Bool # whether it is moving
	capacity::Int64 # kinda unnecessary, since commuters is fixed size
	commuters::SharedVector{Commuter}
	function Train(train_id::Int64, line::Int64, direction::Bool, movement::Bool, capacity::Int64)
		return new(
			train_id,
			line,
			direction,
			movement,
			capacity,
			SharedVector{Commuter}(capacity)
			)
	end
	function Train(train_id::Int64, line::Int64, capacity::Int64)
		return new(
			train_id,
			line,
			true,
			false,
			capacity,
			SharedVector{Commuter}(capacity)
			)
	end
end

mutable struct Station
	station_id::Int64
	codes::Vector
	name::String
	stationCodes::Vector{String}
	spawn_rate::Dict{String, Dict{Int64, Float64}}
	time_to_next_spawn::Dict{String, Int64}
	neighbours::Dict{Int64, Dict{Bool, Vector}}
	train_transit_time::Int64
	commuters::Dict{String, Vector{Any}} # Dictionary, key: train to board, valu: List of commuters
	event_queue::Vector{Event}
	event_buffer::SharedVector{Event}

	function Station(station_id::Int64, name::String, stationCodes::Vector{String})
		return new(
				station_id,
				[],
				name,
				stationCodes,
				Dict(),
				Dict(),
				Dict(),
				1,
				Dict(),
				Event[],
				SharedVector{Event}(1)
			)
	end
	function Station(station_id::Int64, name::String)
		return new(
				station_id,
				[],
				name,
				String[],
				Dict(),
				Dict(),
				Dict(),
				1,
				Dict(),
				Event[],
				SharedVector{Event}(1)
			)
	end
end


mutable struct Metro
	stations::Dict{Any, Any}
	trains::Dict{Any, Any}
	lines::Dict{Any, Any}
	paths::Dict{Any, Any}
end


mutable struct CommuterGraph
	nodes::Vector{Any}
	edges::Dict{Any, Any}
	dist::Dict{String, Dict{String, Float64}}
	next::Dict{String, Dict{String, Vector}}
	commuter_paths::Dict{String, Dict{String, Vector}}
	function CommuterGraph(nodes::Vector{Any}, edges::Dict{Any, Any})
		return new(
			nodes,
			edges,
			Dict(),
			Dict(),
			Dict()
			)
    end
end



