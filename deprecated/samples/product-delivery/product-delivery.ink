# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"
 
using Number
using Math

#what the simulator sends
type SimState {
    Chicago_is_open: Number.Int8<0..1>,
    Pittsburg_is_open: Number.Int8<0..1>,
    Nashville_is_open: Number.Int8<0..1>,
	
    Chicago_util_trucks: number<0..1>,
    Pittsburg_util_trucks: number<0..1>,
    Nashville_util_trucks: number<0..1>,
	
    Chicago_inventory_level: number<0..30000>,
    Pittsburg_inventory_level: number<0..30000>,
    Nashville_inventory_level: number<0..30000>,
	
	Chicago_orders_queueing: number<0 .. 100>,
    Pittsburg_orders_queueing: number<0 .. 100>,
    Nashville_orders_queueing: number<0 .. 100>,
	
    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,
	
	# technically, all of the following can be 'infinity' if no products completed yet
	# we set them to -1, as an indicator. otherwise 0 is the minimum value
    Chicago_average_turnaround: number<-1 .. 500>,
    Pittsburg_average_turnaround: number<-1 .. 500>,
    Nashville_average_turnaround: number<-1 .. 500>,
	
	Chicago_cost_per_product: number<-1 .. 4000000>,
    Pittsburg_cost_per_product: number<-1 .. 4000000>,
    Nashville_cost_per_product: number<-1 .. 4000000>,
	
    overall_average_turnaround: number<-1 .. 500>,
    overall_average_cost_per_product: number<-1 .. 4000000>,
    
    #based on model time
    time: number<0 .. 800>
}

#what the brain sees during training
type ObservationState {
    Chicago_is_open: Number.Int8<0..1>,
    Pittsburg_is_open: Number.Int8<0..1>,
    Nashville_is_open: Number.Int8<0..1>,
	
    Chicago_util_trucks: number<0..1>,
    Pittsburg_util_trucks: number<0..1>,
    Nashville_util_trucks: number<0..1>,
	
    Chicago_inventory_level: number<0..30000>,
    Pittsburg_inventory_level: number<0..30000>,
    Nashville_inventory_level: number<0..30000>,
	
	Chicago_orders_queueing: number<0 .. 100>,
    Pittsburg_orders_queueing: number<0 .. 100>,
    Nashville_orders_queueing: number<0 .. 100>,
	
    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,
	
	# technically, all of the following can be 'infinity' if no products completed yet
	# we set them to -1, as an indicator. otherwise 0 is the minimum value
    Chicago_average_turnaround: number<-1 .. 500>,
    Pittsburg_average_turnaround: number<-1 .. 500>,
    Nashville_average_turnaround: number<-1 .. 500>,
	
	Chicago_cost_per_product: number<-1 .. 4000000>,
    Pittsburg_cost_per_product: number<-1 .. 4000000>,
    Nashville_cost_per_product: number<-1 .. 4000000>,
	
    overall_average_turnaround: number<-1 .. 500>,
    overall_average_cost_per_product: number<-1 .. 4000000>,
}

type Action {
	Chicago_is_open: number<0..1>,
	Pittsburg_is_open: number<0..1>,
	Nashville_is_open: number<0..1>,
	
	Chicago_num_trucks: number<1..3>,
	Pittsburg_num_trucks: number<1..3>,
	Nashville_num_trucks: number<1..3>,
	
	Chicago_production_rate: number<50..80>,
	Pittsburg_production_rate: number<50..80>,
	Nashville_production_rate: number<50..80>,
}

type AnyLogicAction {
	Chicago_is_open: number,
	Pittsburg_is_open: number,
	Nashville_is_open: number,
	
	Chicago_num_trucks: number,
	Pittsburg_num_trucks: number,
	Nashville_num_trucks: number,
	
	Chicago_production_rate: number,
	Pittsburg_production_rate: number,
	Nashville_production_rate: number
}

type Config {
    Chicago_is_open: Number.Int8,
	Pittsburg_is_open: Number.Int8,
	Nashville_is_open: Number.Int8,
}

function Reward(obs: SimState) {
    
	# return a harsh penalty if all sites are closed
    if ( obs.Chicago_is_open + obs.Pittsburg_is_open + obs.Nashville_is_open == 0 )
    {
		return -1
    }
        
	# scale approx range of turnaround times [2 days, 2 weeks] / [48 hours, 336 hours] to [1, -1]
	var turnaround_points = ((obs.overall_average_turnaround - 48) / (336 - 48)) * (-1 - 1) + 1
	
	# scale approx range of cpp [200k, 3.8 mil] to [1, -1]
	# but first scale down cpp to an easier to write value
	var cpp = obs.overall_average_cost_per_product / 100000
	# now scale from [2, 38] to [1, -1]
	var cpp_points = ((cpp - 2) / (38 - 2)) * (-1 - 1) + 1
	
	# weight both points equally
	return (turnaround_points + cpp_points) / 2
	
}

function Terminal(obs: SimState)
{
    return obs.time >= 720
}

function TranslateBonsaiActiontoAnyLogicAction(a: Action) : AnyLogicAction
{
	return 
	{		
		Chicago_is_open: Math.Floor(a.Chicago_is_open+.5),
        Pittsburg_is_open: Math.Floor(a.Pittsburg_is_open+.5),
        Nashville_is_open: Math.Floor(a.Nashville_is_open+.5),
        
        Chicago_num_trucks: Math.Floor(a.Chicago_num_trucks+.5),
        Pittsburg_num_trucks: Math.Floor(a.Pittsburg_num_trucks+.5),
        Nashville_num_trucks: Math.Floor(a.Nashville_num_trucks+.5),
        
        Chicago_production_rate: Math.Floor(a.Chicago_production_rate+.5),
        Pittsburg_production_rate: Math.Floor(a.Pittsburg_production_rate+.5),
        Nashville_production_rate: Math.Floor(a.Nashville_production_rate+.5),
	}
}

simulator Simulator(action: Action, config: Config): SimState {
    #package "<simulator_name>"
}
 
graph (input: ObservationState): Action {
 
    concept optimize(input): Action {
        curriculum {
            source Simulator
            reward Reward
            terminal Terminal
            action TranslateBonsaiActiontoAnyLogicAction


            lesson vary {
                scenario {
                    Chicago_is_open: Number.Int8<0,1,>,
                    Pittsburg_is_open: Number.Int8<0,1,>,
                    Nashville_is_open: Number.Int8<0,1,>,
                }
            }
        }
    }
    
    output optimize
}