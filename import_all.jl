using Distributed
# if nworkers() == 1
# 	addprocs(11)
# end 
@everywhere using Distributions
@everywhere using HDF5
@everywhere using CSV
@everywhere using DataFrames
@everywhere using Logging
@everywhere using Dates
@everywhere using SharedArrays
@everywhere using .Threads
@everywhere include("src/classes.jl")
@everywhere include("src/data_storage_functions/data_store_functions.jl")
@everywhere include("src/data_storage_functions/hdf5_functions.jl")
@everywhere include("src/initialization_functions/commuter_functions.jl")
@everywhere include("src/initialization_functions/construction_functions.jl")
@everywhere include("src/initialization_functions/pathfinding_functions.jl")
@everywhere include("src/initialization_functions/train_functions.jl")
@everywhere include("src/simulation_functions/event_functions.jl")
@everywhere include("src/simulation_functions/metro_functions.jl")
@everywhere include("src/simulation_functions/simul_functions.jl")
@everywhere include("src/simulation_functions/station_functions.jl")
@everywhere include("src/utility_functions/heap_functions.jl")
@everywhere include("src/utility_functions/utility_functions.jl")
