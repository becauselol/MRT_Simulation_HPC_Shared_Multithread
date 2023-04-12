# HPC_Project
 01.118 Project that is MRT Simulation but Julia and FAST
 
### Possible way to parallelize?
At scale, it is unlikely for extended periods of time to have nothing to occur
Instead, we can maintain multiple threads (Event queues) representing trains and stations.

In this manner, our simulation runs in a more [[Agent Based Simulation]] manner, where we will progress the timestep in each queue and if an event occurs, we run it

But in the event, our event requires threads to communicate with each other, it will only be some threads at a time. so we can process those sets of events at the same time

#### How to use Shared Arrays to parallelize
Components
- Shared Metro
- Station Event Queue
- Station New Event Queue
- Data Writing Array

##### Shared Metro
Concept works because stations should not be writing over the same object at any point in time
They can either work with the station that they are
or trains that are at that station
Since location is unique, no overwriting occurs of the commuter data

##### Station Event Queue
is just a series of events for station to process in that time step

##### Station New Event Queue
We need to ensure no [[Race Conditions]] occur, and no overwriting occur

Hence, each neighboring station is allocated some space to write to 
they are typically allocated 1 space since we should only be processing time between train arrivals. this is to just slot the train event there

Because number of neighboring stations is usually low < 10
When we process new stations, the new event queue look up is not costly

##### Data Writing Array
This is local to each process, they only write to their data array
We then collate it later

#### What to do to parallelize?

##### Shared Metro
Metro now has shared event queue