# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"

using Number
using Math

# Array index of Chicago
const ICHI = 0

# Array index of Pittsburg
const IPIT = 1

# Array index of Nashville
const INSH = 2

#what the simulator sends
type SimState {
	acceptingness: number<0, 1,>[3],
    num_vehicles: number<1 .. 3 step 1>[3],
    production_rates: number<50 .. 80>[3],
    vehicle_utilizations: number<0 .. 1>[3],
    inventory_levels: number[3],
    queue_sizes: number[3],
	rolling_turnaround_hours: number[3],
    rolling_cost_per_products: number[3],
	accepting_rolling_turnaround_hours: number,
	accepting_rolling_cost_per_products: number,
	time_hours: number
}

#what the brain sees during training
type ObservableState {
    acceptingness: number<0, 1,>[3],
    num_vehicles: number<1 .. 3 step 1>[3],
    production_rates: number<50 .. 80>[3],
    vehicle_utilizations: number<0 .. 1>[3],
    inventory_levels: number[3],
    queue_sizes: number[3],
    rolling_turnaround_hours: number[3],
    rolling_cost_per_products: number[3],
    accepting_rolling_turnaround_hours: number,
    accepting_rolling_cost_per_products: number
}

type SimAction {
	# Whether each MC should accept orders
    acceptingness: number<0, 1,>[3],
	
	# Number of vehicles to allocate to each MC at each iteration
    num_vehicles: number<1 .. 3 step 1>[3],
	
	 # Production rate at each MC at each iteration
    production_rates: number<50 .. 80>[3]
}

type SimConfig {
    first_action_time_days: number,
    action_recurrence_days: number,
    rolling_window_size_days: number
}

# Temporal reward
function calc_turnaround_reward(turnaround: number) {
    # MC-level
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


# Vehicle utilization
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
    if (state.acceptingness[ICHI] + state.acceptingness[IPIT] + state.acceptingness[INSH] == 0) {
        return -40
    }

    var accepting_turnaround_reward = calc_turnaround_reward(state.accepting_rolling_turnaround_hours)
    var chi_util_reward = calc_utilization_reward(state.vehicle_utilizations[ICHI])
    var pit_util_reward = calc_utilization_reward(state.vehicle_utilizations[IPIT])
    var nsh_util_reward = calc_utilization_reward(state.vehicle_utilizations[INSH])

    return accepting_turnaround_reward + chi_util_reward + pit_util_reward + nsh_util_reward
}

function Terminal(state: SimState) {
    if state.time_hours >= 720 {
        return true
    } else if state.accepting_rolling_turnaround_hours > 100 {
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
					first_action_time_days: 4,
					action_recurrence_days: 3,
					rolling_window_size_days: 3,
                }
            }
        }
    }
    
    output optimize
}