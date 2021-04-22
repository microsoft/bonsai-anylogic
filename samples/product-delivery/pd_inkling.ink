# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"

using Number
using Math


#what the simulator sends
type SimState {
    # Whether MC was open or not in last iteration
    Chicago_is_open: number<0,1,>,
    Pittsburg_is_open: number<0,1,>,
    Nashville_is_open: number<0,1,>,
    
    # The truck utilization percentage at each MC
    # Out of trucks allocated to each MC, how much the trucks were used?
    Chicago_util_trucks: number<0..1>,
    Pittsburg_util_trucks: number<0..1>,
    Nashville_util_trucks: number<0..1>,

    # Number of trucks offered to each MC in last iteration- it can use the truck or not
    Chicago_num_trucks: number<1..3>,
	Pittsburg_num_trucks: number<1..3>,
    Nashville_num_trucks: number<1..3>,
    
    # The inventory level at each MC impacted by the production rate
    # The goal is to accumulate enough, but not to accumulate too much
    # If you have too much in stock and not enough trucks, you have to wait until trucks are available
    Chicago_inventory_level: number<0..30000>,
    Pittsburg_inventory_level: number<0..30000>,
    Nashville_inventory_level: number<0..30000>,
	
    # Orders queueing at each MC
	Chicago_products_queueing: number<0 .. 200000>,
    Pittsburg_products_queueing: number<0 .. 200000>,
    Nashville_products_queueing: number<0 .. 200000>,
    
    # Production rate at each MC in last iteration
    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,
    
    # Turnaround time is the average time from when the order is requested until it is delivered
    # Return 720 if no order is delivered
    Chicago_average_turnaround: number<0 .. 720>,
    Pittsburg_average_turnaround: number<0 .. 720>,
    Nashville_average_turnaround: number<0 .. 720>,
    overall_average_turnaround: number<0 .. 720>,

    # Average cost per product
	Chicago_cost_per_product: number,
    Pittsburg_cost_per_product: number,
    Nashville_cost_per_product: number,
    overall_average_cost_per_product: number,
    
    # Based on model time
    time: number<0 .. 800>
}

#what the brain sees during training
type ObservableState {
    Chicago_is_open: number<0,1,>,
    Pittsburg_is_open: number<0,1,>,
    Nashville_is_open: number<0,1,>,
	
    Chicago_util_trucks: number<0..1>,
    Pittsburg_util_trucks: number<0..1>,
    Nashville_util_trucks: number<0..1>,

    Chicago_num_trucks: number<1..3>,
	Pittsburg_num_trucks: number<1..3>,
    Nashville_num_trucks: number<1..3>,
	
    Chicago_inventory_level: number<0..30000>,
    Pittsburg_inventory_level: number<0..30000>,
    Nashville_inventory_level: number<0..30000>,
	
	Chicago_products_queueing: number<0 .. 200000>,
    Pittsburg_products_queueing: number<0 .. 200000>,
    Nashville_products_queueing: number<0 .. 200000>,
	
    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,
	
	Chicago_average_turnaround: number<0 .. 720>,
    Pittsburg_average_turnaround: number<0 .. 720>,
    Nashville_average_turnaround: number<0 .. 720>,
    overall_average_turnaround: number<0 .. 720>,
    
	Chicago_cost_per_product: number,
    Pittsburg_cost_per_product: number,
    Nashville_cost_per_product: number,
    overall_average_cost_per_product: number,

    time: number<0 .. 800>
}

type SimAction {
    # Whether to keep each MC closed or open
	Chicago_is_open: number<0..1 step 1>,
	Pittsburg_is_open: number<0..1 step 1>,
	Nashville_is_open: number<0..1 step 1>,
    
    # Number of trucks to allocate to each MC at each iteration
	Chicago_num_trucks: number<1..3 step 1>,
	Pittsburg_num_trucks: number<1..3 step 1>,
	Nashville_num_trucks: number<1..3 step 1>,
    
    # Production rate at each MC at each iteration
	Chicago_production_rate: number<50..80 step 1>,
	Pittsburg_production_rate: number<50..80 step 1>,
	Nashville_production_rate: number<50..80 step 1>,
}

type SimConfig {
    OpenCost_PerHour: number,
	ProductionCost_PerHour: number,
    IncompleteOrderPenalty_PerHour: number,
    TruckCost_PerHour: number,
    
	FirstActionTime_Days: number,
	RecurrenceActionTime_Days: number,
	RollingWindowSize_Days: number,

}

# Temporal reward for all MCs 
function overall_reward_time(state: SimState) {
    # Overall-level
    # Return a harsh penalty if turnaround time is larger than 500
    if state.overall_average_turnaround > 500 {
        return -40
    }
    if state.overall_average_turnaround > 80 {
        return -5
    }
    var overall_average_turnaround_scaled = state.overall_average_turnaround / 80
    return Math.E ** (-1 * overall_average_turnaround_scaled)
}
# Temporal reward for Chicago 
function Chicago_reward_time(state: SimState) {
    # MC-level
    # Return a harsh penalty if turnaround time is larger than 500
    if state.Chicago_average_turnaround > 500 {
        return -40
    }
    if state.Chicago_average_turnaround > 80 {
        return -5
    }
    var Chicago_average_turnaround_scaled = state.Chicago_average_turnaround / 80
    return Math.E ** (-1 * Chicago_average_turnaround_scaled)
}
# Temporal reward for Pittsburg
function Pittsburg_reward_time(state: SimState) {
    # MC-level
    if state.Pittsburg_average_turnaround > 500 {
        return -40
    }
    if state.Pittsburg_average_turnaround > 80 {
        return -5
    }
    var Pittsburg_average_turnaround_scaled = state.Pittsburg_average_turnaround / 80
    return Math.E ** (-1 * Pittsburg_average_turnaround_scaled)
}
# Temporal reward for Nashville
function Nashville_reward_time(state: SimState) {
    # MC-level
    if state.Nashville_average_turnaround > 500 {
        return -40
    }
    if state.Nashville_average_turnaround > 80 {
        return -5
    }    
    var Nashville_average_turnaround_scaled = state.Nashville_average_turnaround / 80
    return Math.E ** (-1 * Nashville_average_turnaround_scaled)
}

# Truck utilization for Chicago
function Chicago_reward_trUti(state: SimState) {
    # MC-level 
    if state.Chicago_util_trucks > 0 and state.Chicago_util_trucks <= 0.25 {
        return 0.2
    }
    if state.Chicago_util_trucks > 0.25 and state.Chicago_util_trucks <= 0.5 {
        return 0.4
    }
    if state.Chicago_util_trucks > 0.5 and state.Chicago_util_trucks <= 0.75 {
        return 0.6
    }
    if state.Chicago_util_trucks > 0.75 {
        return 1
    }
    return -1 # This corresponds to utilization of 0
}
# Truck utilization for Pittsburg
function Pittsburg_reward_trUti(state: SimState) {
    # MC-level
    if state.Pittsburg_util_trucks > 0 and state.Pittsburg_util_trucks <= 0.25 {
        return 0.2
    }
    if state.Pittsburg_util_trucks > 0.25 and state.Pittsburg_util_trucks <= 0.5 {
        return 0.4
    }
    if state.Pittsburg_util_trucks > 0.5 and state.Pittsburg_util_trucks <= 0.75 {
        return 0.6
    }
    if state.Pittsburg_util_trucks > 0.75 {
        return 1
    }
    return -1 # This corresponds to utilization of 0
}
# Truck utilization for Nashville
function Nashville_reward_trUti(state: SimState) {
    # MC-level
    if state.Nashville_util_trucks > 0 and state.Nashville_util_trucks <= 0.25 {
        return 0.2
    }
    if state.Nashville_util_trucks > 0.25 and state.Nashville_util_trucks <= 0.5 {
        return 0.4
    }
    if state.Nashville_util_trucks > 0.5 and state.Nashville_util_trucks <= 0.75 {
        return 0.6
    }
    if state.Nashville_util_trucks > 0.75 {
        return 1
    }
    return -1 # This corresponds to utilization of 0
}

function Reward(state: SimState) {

    var Nashville_temporal = Nashville_reward_time(state)
    var Chicago_temporal = Chicago_reward_time(state)
    var Pittsburg_temporal = Pittsburg_reward_time(state)
    var all_temporal = overall_reward_time(state)
    var Chicago_truck = Chicago_reward_trUti(state)
    var Pittsburg_truck = Pittsburg_reward_trUti(state)
    var Nashville_truck = Nashville_reward_trUti(state)
    
	# Return a harsh penalty if all MCs are closed at the same time
    if ( state.Chicago_is_open + state.Pittsburg_is_open + state.Nashville_is_open == 0 ) {
		return -40
    }
    else {
        var overall_temporal = all_temporal
        var overall_truck = Chicago_truck + Pittsburg_truck + Nashville_truck
        var overall_reward = overall_temporal + overall_truck
        return overall_reward
    }
}

function Terminal(state: SimState) {
    if state.time >= 720 {
        return true
    }
    else if state.overall_average_cost_per_product > 100 {
        return true
    }
    return false
}

simulator Simulator(action: SimAction, config: SimConfig): SimState {
   
}
 
graph (input: ObservableState): SimAction {
 
    concept optimize(input): SimAction {
        curriculum {
            source Simulator
            reward Reward
            terminal Terminal
            training {
                NoProgressIterationLimit: 1000000
            }            

            lesson default {
                scenario {
                    OpenCost_PerHour: 200,
                    ProductionCost_PerHour: 65,
                    IncompleteOrderPenalty_PerHour: 5,
                    TruckCost_PerHour: 15,
					FirstActionTime_Days: 4,
					RecurrenceActionTime_Days: 3,
					RollingWindowSize_Days: 3,
                }
            }
        }
    }
    
    output optimize
}