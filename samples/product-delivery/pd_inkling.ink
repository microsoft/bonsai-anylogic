# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"

using Number
using Math


#what the simulator sends
type SimState {
    # Whether MC was open or not in last iteration
    Chicago_is_open: number<0, 1, >,
    Pittsburg_is_open: number<0, 1, >,
    Nashville_is_open: number<0, 1, >,

    # The truck utilization percentage at each MC
    # Out of trucks allocated to each MC, how much the trucks were used?
    Chicago_util_trucks: number<0 .. 1>,
    Pittsburg_util_trucks: number<0 .. 1>,
    Nashville_util_trucks: number<0 .. 1>,

    # Number of trucks offered to each MC in last iteration- it can use the truck or not
    Chicago_num_trucks: number<1 .. 3>,
    Pittsburg_num_trucks: number<1 .. 3>,
    Nashville_num_trucks: number<1 .. 3>,

    # The inventory level at each MC impacted by the production rate
    # The goal is to accumulate enough, but not to accumulate too much
    # If you have too much in stock and not enough trucks, you have to wait until trucks are available
    Chicago_inventory_level: number,
    Pittsburg_inventory_level: number,
    Nashville_inventory_level: number,

    # Orders queueing at each MC
    Chicago_products_queueing: number,
    Pittsburg_products_queueing: number,
    Nashville_products_queueing: number,

    # Production rate at each MC in last iteration
    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,

    # Turnaround time is the average time from when the order is requested until it is delivered
    # Return 720 if no order is delivered
    Chicago_average_turnaround: number,
    Pittsburg_average_turnaround: number,
    Nashville_average_turnaround: number,
    overall_average_turnaround: number,

    # Average cost per product
    Chicago_cost_per_product: number,
    Pittsburg_cost_per_product: number,
    Nashville_cost_per_product: number,
    overall_average_cost_per_product: number,

    # Based on model time
    time: number
}

#what the brain sees during training
type ObservableState {
    Chicago_is_open: number<0, 1, >,
    Pittsburg_is_open: number<0, 1, >,
    Nashville_is_open: number<0, 1, >,

    Chicago_util_trucks: number<0 .. 1>,
    Pittsburg_util_trucks: number<0 .. 1>,
    Nashville_util_trucks: number<0 .. 1>,

    Chicago_num_trucks: number<1 .. 3>,
    Pittsburg_num_trucks: number<1 .. 3>,
    Nashville_num_trucks: number<1 .. 3>,

    Chicago_inventory_level: number,
    Pittsburg_inventory_level: number,
    Nashville_inventory_level: number,

    Chicago_products_queueing: number,
    Pittsburg_products_queueing: number,
    Nashville_products_queueing: number,

    Chicago_production_rate: number<50 .. 80>,
    Pittsburg_production_rate: number<50 .. 80>,
    Nashville_production_rate: number<50 .. 80>,

    Chicago_average_turnaround: number,
    Pittsburg_average_turnaround: number,
    Nashville_average_turnaround: number,
    overall_average_turnaround: number,

    Chicago_cost_per_product: number,
    Pittsburg_cost_per_product: number,
    Nashville_cost_per_product: number,
    overall_average_cost_per_product: number,
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
	FirstActionTime_Days: number,
	RecurrenceActionTime_Days: number,
	RollingWindowSize_Days: number,
}

function calc_turnaround_reward(turnaround: number) {
	# Return a harsh penalty if turnaround time is larger than 500
    if turnaround > 500 {
        return -40
    }
    if turnaround > 80 {
        return -5
    }
    var turnaround_scaled = turnaround / 80
    return Math.E ** (-1 * turnaround_scaled)
}

function calc_utilization_reward(utilization: number) {
    if utilization <= 0 {
        return -1
    } else if utilization <= 0.25 {
        return 0.2
    } else if utilization <= 0.5 {
        return 0.4
    } else if utilization <= 0.75 {
        return 0.6
    } else { # utilization > 0.75
        return 1
    }
}

function Reward(state: SimState) {
    # Return a harsh penalty if all MCs are closed at the same time
    if (state.Chicago_is_open + state.Pittsburg_is_open + state.Nashville_is_open == 0) {
        return -40
    }

    var OpenMCs_average_turnaround = calc_turnaround_reward(state.overall_average_turnaround)
    var Chicago_truck = calc_utilization_reward(state.Chicago_util_trucks)
    var Pittsburg_truck = calc_utilization_reward(state.Pittsburg_util_trucks)
    var Nashville_truck = calc_utilization_reward(state.Nashville_util_trucks)
    
    return OpenMCs_average_turnaround + Chicago_truck + Pittsburg_truck + Nashville_truck
}

function Terminal(state: SimState) {
    if state.time >= 720 {
        return true
    } else if state.overall_average_cost_per_product > 100 {
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
					FirstActionTime_Days: 4,
					RecurrenceActionTime_Days: 3,
					RollingWindowSize_Days: 3,
                }
            }
        }
    }
    
    output optimize
}