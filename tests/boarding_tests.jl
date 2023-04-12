using Distributed, Test
addprocs(4)
@everywhere using SharedArrays

number_trains = 10
train_capacity = 10

train_commuters = SharedArray{Commuter}((number_trains, train_capacity))

