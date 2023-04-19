include("import_all.jl")

# io = open("log.txt", "w+")
# logger = SimpleLogger(io)
logger = ConsoleLogger(stdout, Logging.Info)
# fileLogger = SimpleLogger(io, Logging.Debug)
# global_logger(fileLogger)
global_logger(logger)

station_dict = construct_station_dict("data/input/station_data.csv")

station_name_id_map = construct_station_name_id_map(station_dict)

# construct the edges
start_stations = construct_edges_from_edges_dict!(station_dict, ["tel", "ccl", "ewl", "nsl", "nel", "cgl", "dtl"])

lines = construct_lines_from_start_stations(station_dict, start_stations)

commuter_graph = construct_commuter_graph(station_dict)

floyd_warshall!(commuter_graph)

get_all_path_pairs!(commuter_graph)

paths = get_interchange_paths(station_dict, lines, commuter_graph)

max_time = 1500
start_time = 360
timestep = 0.5


train_period = 2
train_capacity = 1000

@info "initialization starting at time $(now())"


trains = Dict()
for line_code in keys(lines)
	line_duration = get_line_duration(station_dict, lines, line_code)
	depot_id = lines[line_code][true][1]
	events, line_trains = create_period_train_placement_events(line_code, line_duration, train_period, train_capacity, depot_id, true, start_time)
    
	for (k,v) in line_trains
		trains[k] = v 
	end 

	append!(station_dict[depot_id].event_queue, events)
    build_min_heap!(station_dict[depot_id].event_queue)
end

process_spawn_rate!("data/input/spawn_data.csv", station_dict)

max_buffer_size = assign_buffer_slot!(station_dict)

metro = Metro(station_dict, trains, lines, paths);


# data_store = Data_Store(length(station_dict))
@info "initialization finish at time $(now())"

simulate!(start_time, max_time, metro, data_store, timestep)
@info "simulation finish at time $(now())"