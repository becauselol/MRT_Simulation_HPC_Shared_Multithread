include("../import_all.jl")
@everywhere using Test
include("create_classes_test.jl")
include("station_neighbour_tests.jl")
include("event_buffer_tests.jl")
include("station_spawn_terminate_tests.jl")
include("train_board_alight_tests.jl")

println("Tests Done");