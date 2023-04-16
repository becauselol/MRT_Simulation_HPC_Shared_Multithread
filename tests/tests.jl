using Distributed

if nprocs() == 1
	addprocs(3)
end 

@everywhere using Test, SharedArrays, DataFrames, .Threads
@everywhere include("../src/classes.jl")
@everywhere include("../src/station_functions.jl")
@everywhere include("../src/classes.jl")
@everywhere include("../src/simul_functions.jl")
@everywhere include("../src/heap_functions.jl")

include("station_neighbour_tests.jl")
include("create_classes_test.jl")
include("event_buffer_tests.jl")
include("station_spawn_terminate_tests.jl")
include("train_board_alight_tests.jl")

println("Tests Done");