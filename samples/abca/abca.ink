# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"
using Number
using Math

#SimState has the same properties as the ModelObservation class in the model
type SimState {
    arrivalRate: number,
    
    nResA: number,
    nResB: number,
    processTime: number,
    conveyorSpeed: number,
    
    utilResA: number,
    utilResB: number,
    
    ratioFullQueueA: number,
    ratioFullQueueB: number,
    
    recentNProducts: number,
    
    ratioCostIdleA: number,
    ratioCostIdleB: number,
    ratioCostWaiting: number,
    ratioCostProcessing: number,
    ratioCostMoving: number,
    
    costPerProduct: number,
    exceededCapacity: number,
    time: number
}

#the ObservableState is what the brain sees from the simulator
#inthis case, just the arrivalRate
type ObservableState {
    arrivalRate: number
}


type Action {
    nResA: number<1 .. 20>,
    nResB: number<1 .. 20>,
    processTime: number<1.0 .. 12.0>,
    conveyorSpeed: number<0.01 .. 1.0>,
}

type SimConfig {
    arrivalRate: number,
    initNResA: number,
    initNResB: number,
    initProcessTime: number,
    initConveyorSpeed: number,
    sizeBufferQueues: number
}

simulator Simulator(action: Action, config: SimConfig): SimState {
    
}

#SimAction is the values translated for the sim
#we do not need ranges here
#these are the same as the ModelAction class
type SimAction {
    nResA: number,
    nResB: number,
    processTime: number,
    conveyorSpeed: number,
}
#rounds the value
function RoundToNearest(rValue: number, nPlaces: number)
{
    var baseInteger = Math.Floor(rValue)
    var decimalValue = rValue - baseInteger
    var tenthsValue = decimalValue * (10 ** nPlaces)
    var iTenthsPosition = Math.Floor(tenthsValue)
    var hundrethsPos = tenthsValue - iTenthsPosition
    var newTenthsValue = 0
    if (hundrethsPos >= .5)
    {
        newTenthsValue = iTenthsPosition + 1
    }
    else
    {
        newTenthsValue = iTenthsPosition
    }
    var finalValue = baseInteger + (newTenthsValue * (10**(-nPlaces)))
    return finalValue
}

#translates the Action from the brain to the SimAction that is sent to the simulator
function TranslateBonsaiActiontoSimAction(a: Action) : SimAction
{
    return 
    {       
        nResA: Math.Floor(a.nResA+0.5),
        nResB: Math.Floor(a.nResB+0.5),
        processTime: RoundToNearest(a.processTime, 1),
        conveyorSpeed: RoundToNearest(a.conveyorSpeed, 2)
    }
}
function Terminal(obs:SimState)
{
    if(obs.exceededCapacity == 1)
    {
        return true
    }
    
    #the brain gets one chance at the answer
    if(obs.time >= 1)
    {
        return true
    }
    return false
}
function Reward(obs: SimState) {
    
    return -obs.costPerProduct - 1000 * obs.exceededCapacity
    
}
graph (input: ObservableState): Action {
 
    concept optimize(input): Action {
        curriculum {
            source Simulator
            action TranslateBonsaiActiontoSimAction
            reward Reward
            terminal  Terminal
            lesson `Vary Arrival Rate` {
                #these mape to the SimConfig values
                scenario {
                    arrivalRate: number<0.5 .. 2.0 step .1>,
                    initNResA: 20,
                    initNResB: 20,
                    initProcessTime: 1.0,
                    initConveyorSpeed: 0.1,
                    sizeBufferQueues: 45
                }
            }
        }
    }
    
    output optimize
}
