using Distributed

if nprocs() == 1
	addprocs(3)
end 

@everywhere using Test, SharedArrays, DataFrames, .Threads
@everywhere include("../src/data_storage_functions/data_store_functions.jl")
@everywhere include("../src/data_storage_functions/hdf5_functions.jl")
@everywhere include("../src/initialization_functions/commuter_functions.jl")
@everywhere include("../src/initialization_functions/construction_functions.jl")
@everywhere include("../src/initialization_functions/pathfinding_functions.jl")
@everywhere include("../src/initialization_functions/train_functions.jl")
@everywhere include("../src/simulation_functions/event_functions.jl")
@everywhere include("../src/simulation_functions/metro_functions.jl")
@everywhere include("../src/simulation_functions/simul_functions.jl")
@everywhere include("../src/simulation_functions/station_functions.jl")
@everywhere include("../src/utility_functions/heap_functions.jl")
@everywhere include("../src/utility_functions/utility_functions.jl")
@everywhere include("../src/classes.jl")

include("create_classes_test.jl")
include("station_neighbour_tests.jl")
include("event_buffer_tests.jl")
include("station_spawn_terminate_tests.jl")
include("train_board_alight_tests.jl")

println("Tests Done");