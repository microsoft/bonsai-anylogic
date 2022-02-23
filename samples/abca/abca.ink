# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"

# SimState has the same properties as the Observation fields in the RL experiment.
type SimState {
    arrivalRate: number<0.5 .. 2.0>,
    recentNProducts: number,
    costPerProduct: number,
    utilizationResourceA: number<0 .. 1>,
    utilizationResourceB: number<0 .. 1>,
    ratioFullQueueA: number<0 .. 1>,
    ratioFullQueueB: number<0 .. 1>,
    ratioCostIdleA: number<0 .. 1>,
    ratioCostIdleB: number<0 .. 1>,
    ratioCostWaiting: number<0 .. 1>,
    ratioCostProcessing: number<0 .. 1>,
    ratioCostMoving: number<0 .. 1>,
    
    exceededCapacityFlag: number<0,1,>,
    simTimeMonths: number<0 .. 7>
}

# The ObservableState is what the brain sees from the simulator.
# In this case, it's just the arrival rate.
type ObservableState {
    arrivalRate: number
}

# SimAction has the same properties as the Action fields in the RL experiment.
# The ranges are based on the sliders in the sim (the ones the user typically controls).
type SimAction {
    numResourceA: number<1 .. 20>,
    numResourceB: number<1 .. 20>,
    processTime: number<1.0 .. 12.0>,
    conveyorSpeed: number<0.01 .. 1.0>,
}

# SimConfig has the same properties as the Configuration fields in the RL experiment.
# Each training episode can potentially vary the arrival rate,
#   and the size of the buffer queues in the first part of the process.
type SimConfig {
    arrivalRate: number,
    sizeBufferQueues: number
}

simulator Simulator(action: SimAction, config: SimConfig): SimState {
    # (package statement for managed sims are placed here)
}

# Reset the episode if the buffer queue capacity was exceeded (1 = true),
#	or the simulated time is at/after when the second action is taken (giving the brain one chance)
function Terminal(obs:SimState) {	
	return obs.exceededCapacityFlag == 1 or obs.simTimeMonths >= 6
}

# Large penalty for exceeding the buffer queue's capacity.
# Otherwise, try to maximize the cost per product value.
function Reward(obs: SimState) {
    return -obs.costPerProduct - 1000 * obs.exceededCapacityFlag
}

graph (input: ObservableState): SimAction {
    concept optimize(input): SimAction {
        curriculum {
            source Simulator
            reward Reward
            terminal  Terminal
            lesson `Vary Arrival Rate` {
                # These map to the SimConfig values
                scenario {
                    arrivalRate: number<0.5 .. 2.0 step .05>,
                    sizeBufferQueues: 45
                }
            }
        }
    }
    output optimize
}