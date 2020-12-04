# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"
using Math
# SimState has the same properties as the Observation fields in the RLExperiment
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

type Action {
    numResourceA: number<1 .. 20>,
    numResourceB: number<1 .. 20>,
    processTime: number<1.0 .. 12.0>,
    conveyorSpeed: number<0.01 .. 1.0>,
}
type SimConfig {
    arrivalRate: number,
    sizeBufferQueues: number
}
simulator Simulator(action: Action, config: SimConfig): SimState {
    #package "ABCA_Sim_v2"
}
# SimAction is the values translated for the sim.
# We do not need ranges here.
# These are the same as the ModelAction class.
type SimAction {
    numResourceA: number,
    numResourceB: number,
    processTime: number,
    conveyorSpeed: number,
}

function Terminal(obs:SimState)
{
    if(obs.exceededCapacityFlag == 1)
    {
        return true
    }
    
    # The brain gets one chance at the answer
    return obs.simTimeMonths >= 6
}
function Reward(obs: SimState) {
    # Large penalty for exceeding the buffer queue's capacity.
    # Otherwise, try to maximize the cost per product value.
    return -obs.costPerProduct - 1000 * obs.exceededCapacityFlag
    
}
graph (input: ObservableState): Action {
 
    concept optimize(input): Action {
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