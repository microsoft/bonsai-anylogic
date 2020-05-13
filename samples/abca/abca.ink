inkling "2.0"

using Number
using Math

# the state from the AnyLogic model
type SimState {
    arrivalRate: number<0.5 .. 2.0>,
	nResA: Number.Int32<1 .. 20>,
	nResB: Number.Int32<1 .. 20>,
	utilResA: number,
	utilResB: number,
	idleCostResA: number<0.1 .. 20>,
	idleCostResB: number<0.1 .. 20>,
	busyCostResA: number<0.1 .. 20>,
	busyCostResB: number<0.1 .. 20>,
	processTime: number<1.0 .. 12.0>,
	conveyorSpeed: Number.Int32<0 .. 15>,
	costPerProduct: number<1.0 .. 15.0>,
}

# action from the brain
type Action {
    nResA: number<1 .. 20>,
	nResB: number<1 .. 20>,
	processTime: number<1.0 .. 12.0>,
	conveyorSpeed: number<1.0 .. 15.0>,
}


function Reward(obs: SimState) {

    #our goal is to target the reward of 1 
	#the minimum price in the model is $6.93

    var min_price = 6.93
    
	if(obs.costPerProduct != 0)
	{
		return (min_price/obs.costPerProduct)
	}

	return 0
}

#configuration values for initializing the simulator
type SimConfig {
	arrivalRate: number,
	existenceCostPH: number,
	resABusyCostPH: number,
	resAIdleCostPH: number,
	resBBusyCostPH: number,
	resBIdleCostPH: number,
	relativeProcessCost: number,
	relativeMoveCost: number,
}

simulator Simulator(action: Action, config: SimConfig): SimState {

}

#SimAction is the values translated for the sim
#we do not need ranges here
type SimAction {
	nResA: Number.Int32,
	nResB: number,
	processTime: number,
	conveyorSpeed: number,
}

#rounds the value to the nearest first decimal
function RoundToNearestTenth(rValue: number)
{
	var baseInteger = Math.Floor(rValue)
	var decimalValue = rValue - baseInteger
	var tenthsValue = decimalValue * 10
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

	var finalValue = baseInteger + (newTenthsValue * .1)

	return finalValue

}

#performs rounding for the simulator
function TranslateBonsaiActiontoSimAction(a: Action) : SimAction
{
	return 
	{		
		nResA: Math.Floor(a.nResA+0.5), #if the value is <.5, will go to lower integer number. If >=.5, will resolve to higher integer number
		nResB: Math.Floor(a.nResB+0.5),
		processTime: RoundToNearestTenth(a.processTime),
		conveyorSpeed: RoundToNearestTenth(a.conveyorSpeed)
	}
}

graph (input: SimState): Action {
 
    concept optimize(input): Action {
        curriculum {
            source Simulator
			reward Reward
			action TranslateBonsaiActiontoSimAction

			lesson `Vary Arrival Rate` {
				scenario {
					arrivalRate: number<0.5 .. 2.0 step .1>,
					existenceCostPH: 1.0,
					resABusyCostPH: 3.0,
					resAIdleCostPH: 2.0,
					resBBusyCostPH: 5.0,
					resBIdleCostPH: 2.0,
					relativeProcessCost: 100.0,
					relativeMoveCost: 0.3,
				}
			}
		}
    }
    
    output optimize
}