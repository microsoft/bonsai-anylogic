# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"

using Number
using Math


type SimState {
    arrivalRate: number<0.5 .. 2.0>,
	
	nResA: number<1 .. 20>,
	nResB: number<1 .. 20>,
	processTime: number<1.0 .. 12.0>,
	conveyorSpeed: number<0.01 .. 1.0>,
	
	utilResA: number<0 .. 1>,
	utilResB: number<0 .. 1>,
	
	ratioFullQueueA: number<0 .. 1>,
	ratioFullQueueB: number<0 .. 1>,
	
	recentNProducts: number,
	
	ratioCostIdleA: number<0 .. 1>,
	ratioCostIdleB: number<0 .. 1>,
	ratioCostWaiting: number<0 .. 1>,
	ratioCostProcessing: number<0 .. 1>,
	ratioCostMoving: number<0 .. 1>,
	
	costPerProduct: number,
	exceededCapacity: number<0,1,>,
	time: number<0 .. 36500>
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
	#uncomment the line below and put the name of the simulator
	#after you have uploaded your model

	#package "al-uploaded-model"
}

#SimAction is the values translated for the sim
#we do not need ranges here
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
	
	if(obs.time >= 365 * 100)
	{
	 	return true
	}

	return false
}

function Reward(obs: SimState) {
	# give harsh penalty if exceeded capacity
	if (obs.exceededCapacity == 1) {
		return -1
	}
	
	# give between [0 .. -0.5] penalty for having a fuller queue
	var fullnessPenalty = -0.5 * (obs.ratioFullQueueA ** 3)
	
	# give between [0 .. 1] reward for having a smaller cost per product
	# (not sure if Bonsai has 'e' in the Math lib)
	var e = 2.7182818284
	var cppReward = (-1 / (1 + e**(-0.12*obs.costPerProduct + 8))) + 1
	# equation reference: https://www.desmos.com/calculator/lmh2fmb2le
	
	return fullnessPenalty + cppReward
	
}

graph (input: SimState): Action {
 
    concept optimize(input): Action {
        curriculum {
            source Simulator
			action TranslateBonsaiActiontoSimAction
			reward Reward
			terminal  Terminal

			lesson `Vary Arrival Rate` {
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