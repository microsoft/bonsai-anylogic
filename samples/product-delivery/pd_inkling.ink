# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
inkling "2.0"

using Math

# Array index of Chicago
const ICHI = 0

# Array index of Pittsburg
const IPIT = 1

# Array index of Nashville
const INSH = 2

# What the simulator sends
type SimState {
    # Whether each MC was accepting or not in last iteration
    acceptingness: number<0, 1,>[3],
    
    # Number of vehicles in use at each MC in last iteration
    num_vehicles: number<1 .. 3 step 1>[3],

    # The hourly rate of new products added to each MC's inventory in the last iteration
    production_rates: number<50 .. 80>[3],

    # The average utilization percentage of each vehicle at each MC
    # (0 = No vehicles used, 1 = All vehicles in use, 100% of the time)
    vehicle_utilizations: number<0 .. 1>[3],

    # The inventory level at each MC at the time of the iteration
    # It's impacted by the production rate
    inventory_levels: number[3],

    # The number of products (across all orders) waiting to be serviced at each MC
    queue_sizes: number[3],

    # The average time (in hours) within the rolling window that it takes for an order to be serviced
    # (Starting from when it arrives at the MC and ending when it is delivered)
    rolling_turnaround_hours: number[3],

    # The averaged value of `rolling_turnaround_hours` for all MCs currently accepting new orders
    accepting_rolling_turnaround_hours: number,
    
    # The average cost within the rolling window of a single product (across all orders)
    rolling_cost_per_products: number[3],

    # The averaged value of `rolling_cost_per_products` for all MCs currently accepting new orders
	accepting_rolling_cost_per_products: number,
    
    # Current model time, represented in hours
	time_hours: number
}

# What the brain sees during training
type ObservableState {
    acceptingness: number<0, 1,>[3],
    num_vehicles: number<1 .. 3 step 1>[3],
    production_rates: number<50 .. 80>[3],
    vehicle_utilizations: number<0 .. 1>[3],
    inventory_levels: number[3],
    queue_sizes: number[3],
    rolling_turnaround_hours: number[3],
    accepting_rolling_turnaround_hours: number,
    rolling_cost_per_products: number[3],
    accepting_rolling_cost_per_products: number
}

type SimAction {
    # Whether each MC should accept orders
    # Orders that would normally go to an MC are redirect to the nearest open MC
    acceptingness: number<0, 1,>[3],
	
	# Number of vehicles to allocate to each MC
    num_vehicles: number<1 .. 3 step 1>[3],
	
	 # Hourly production rate at each MC
    production_rates: number<50 .. 80>[3]
}

type SimConfig {
    # When the first iteration should happen, in days
    first_action_time_days: number,

    # How many days should pass between iterations (starting after the first iteration)
    action_recurrence_days: number,

    # How many days should encompass the rolling window
    # Larger sizes more accurately capture the statistically "true" values,
    #   but smaller sizes better reflect the impact of the brain's actions
    rolling_window_size_days: number
}

# Converts a given turnaround time (a temporal value, in hours) to a feedback value for the brain
# This is used as part of the larger reward function
function calc_turnaround_reward(turnaround: number) {
    # Return a harsh penalty if it takes longer than 3 weeks to fulfill an order
    if turnaround > 500 {
        return -40
    }
    # Return a somewhat harsh penalty if it takes longer than 3 days to fulfill an order
    if turnaround > 80 {
        return -5
    }
    # Use a scaled, negative, natural exponential function for the reward (values range: [~0.37,1])
    # https://www.desmos.com/calculator/uq0ajpn2bs
    var turnaround_scaled = turnaround / 80
    return Math.E ** (-1 * turnaround_scaled)
}


# Converts a given vehicle utilization (a percentage, in fraction form) to a feedback value for the brain
# This is used as part of the larger reward function
function calc_utilization_reward(utilization: number) {
    # Return a penalty for no usage and otherwise a higher score for more usage
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

# Converts a state to a single numerical reward
function Reward(state: SimState) {
    # Return a harsh penalty if no MCs are accepting (= orders are being lost!)
    if (state.acceptingness[ICHI] + state.acceptingness[IPIT] + state.acceptingness[INSH] == 0) {
        return -40
    }

    # Otherwise, give a reward based on the turnaround time for all accepting MCs and the vehicle utilization of all MCs
    var accepting_turnaround_reward = calc_turnaround_reward(state.accepting_rolling_turnaround_hours)
    var chi_util_reward = calc_utilization_reward(state.vehicle_utilizations[ICHI])
    var pit_util_reward = calc_utilization_reward(state.vehicle_utilizations[IPIT])
    var nsh_util_reward = calc_utilization_reward(state.vehicle_utilizations[INSH])

    return accepting_turnaround_reward + chi_util_reward + pit_util_reward + nsh_util_reward
}

# Checks whether the sim should be reset based on the current state
function Terminal(state: SimState) {
    # Terminates after 30 days or if the mean turnaround time for currently-accepting MCs is over 4 days
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
                    # Lets the model "warmup" for 4 days,
                    #   then takes a new action every 3 days,
                    #   with statistics based on 3 day windows.
					first_action_time_days: 4,
					action_recurrence_days: 3,
					rolling_window_size_days: 3,
                }
            }
        }
    }
    
    output optimize
}