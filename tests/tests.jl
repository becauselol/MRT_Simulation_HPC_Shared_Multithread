using Distributed

if nprocs() == 1
	addprocs(3)
end 

@everywhere using Test, SharedArrays, DataFrames
@everywhere include("../classes.jl")
@everywhere include("../station_functions.jl")
@everywhere include("../classes.jl")
@everywhere include("../simul_functions.jl")
@everywhere include("../heap_functions.jl")

include("station_neighbour_tests.jl")
include("create_classes_test.jl")
include("event_buffer_tests.jl")
include("station_spawn_terminate_tests.jl")
include("train_board_alight_tests.jl")

println("Tests Done");