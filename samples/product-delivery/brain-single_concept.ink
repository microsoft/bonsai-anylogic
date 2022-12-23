inkling "2.0"

using Math
using Goal

# [[[ Constants to modify for altering the execution ]]]
# (placed here to unify the multiple references to it)
# how long to run each episode for
const SIM_LEN_DAYS = 7*12
# hours between actions
const ACTION_RECURRENCE_HRS = 24
# total hours to get the 'recent' values for
const WINDOW_DURATION = 24*7
# how many hours to bin or aggregate the 'recent' values into
const WINDOW_AGGREGATE = 24

# [[[ Constants that should not (typically) be touched ]]]
# number of manufacturing centers; increase if you add more in the sim
const NUM_MCS = 3
# formulation of the number of samples in each MC's 'recent' list
const WINDOW_SAMPLES = WINDOW_DURATION / WINDOW_AGGREGATE

# Indicator for which MC to be controlled.
type CtrlIndex number<Chi=0, Pit=1, Nsh=2, All=-1>

# What the sim transmits to Bonsai
type SimState {
    # Day of the week; sunday starts
    day: number<1 .. 7 step 1>,
    # Hour of the day
    hour: number<0 .. 23 step 1>,
    # Sim time, in years
    time_years: number,
    # Indicator for which location(s) are being controlled
    control_index: CtrlIndex,
    # Current rates, set from the last action
    production_rates: number[NUM_MCS],
    # Current number of products on hand
    products: number[NUM_MCS],
    # Cumulative costs accrued since start of sim
    costs: number[NUM_MCS],
    # Costs accrued since last action
    costs_delta: number[NUM_MCS],
    # How many orders are waiting to be serviced
    queueing_count: number[NUM_MCS],
    # The total amount of product requested by queueing orders
    queueing_amount: number[NUM_MCS],
    # Max time (hours) that it took to fulfill an order since start of sim
    max_fulfillment_times: number[NUM_MCS],
    # History of max time it took to fulfill orders 
    recent_queueing_times_max: number[WINDOW_SAMPLES][NUM_MCS],
    # History of how many orders received in each window sample
    recent_orders_count: number[WINDOW_SAMPLES][NUM_MCS],
    # History of how much product was requested in each window sample
    recent_orders_amount: number[WINDOW_SAMPLES][NUM_MCS],
    # History of the costs at the start of each window sample
    recent_costs: number[WINDOW_SAMPLES][NUM_MCS]
}

# What Bonsai transmits to the brain
type ObservableState {
    day: number<1 .. 7 step 1>,
    products: number[NUM_MCS],
    queueing_amount: number[NUM_MCS]
}

# What the brain controls in the sim
type SimAction {
    # What speed (in units per hour) to set each center to
    production_rates: number<0 .. 200>[NUM_MCS]
}

# Per-episode configuration that can be sent to the simulator.
# All iterations within an episode will use the same configuration.
type SimConfig {
    # Which location is being controlled;
    #   uncontrolled locations will be deactivated but still exist (so array indices won't change)
    control_index: CtrlIndex,
    # How much time, in hours, between taking an action
    action_recurrence_hrs: number<2,4,6,8,12,24>,
    # The seed for distributor ordering; set to -1 for random
    rng_seed: number<-1 .. 16777216 step 1>,
    # How far back (in hours) the "recent_" state variables should sample from
    recent_window_duration: number,
    # How many hours to group the samples into, within in the allotted window
    recent_window_aggregate: number,
    # How many weeks the macro-level order cycle should last; set to 0 for no fluctuating demand
    cycle_duration_wk: number<0 .. 52 step 1>,
    # A container for modifying the core logic of the model.
    # If omitted, the default will be used (applies to entire object or individual values).
    logic_overrides: LogicConfig
}

# Grouped object containing variables that drastically effect the underlying model logic.
# They are intended to be fixed/unchanged, but provided for experimenting with different scenarios
#   (e.g., linear instead of quadradic costs).
type LogicConfig {
    # NOTE: Holding cost formula, accumulated per hour = (products*costPerUnit)^costExponent
    # holding cost multiplier (default 0.001)
    holdCostPerUnit: number,
    # holding cost exponent (default 2)
    holdCostExponent: number,
    # distance to target rate multiplier cost (default 1)
    mtncCostMultiplier: number,
    # how fast trucks can drive (default 90)
    truckSpeedKPH: number
}

# The built in Max function only supports two values,
# so this is a helper function to find the max of the entire array.
# NOTE: if more MCs are ever added, this function will need to be expanded.
function ArrayMax(a: number[NUM_MCS]): number {
    return Math.Max(Math.Max(a[0], a[1]),a[2])
}

simulator Simulator(action: SimAction, config: SimConfig): SimState {
    # package "Product_Delivery"
}

# Define a concept graph
graph (input: ObservableState): SimAction {

    output concept ControlRate(input): SimAction {
        curriculum {
            # The source of training for this concept is a simulator
            # that takes an action as an input and outputs a state.
            source Simulator

            training {
                EpisodeIterationLimit: Math.Floor(SIM_LEN_DAYS * (24/ACTION_RECURRENCE_HRS))
            }

            goal (state: SimState) {
                avoid QueueTimeout: ArrayMax(state.max_fulfillment_times) in Goal.RangeAbove(48)
                minimize QueueTime: ArrayMax(state.max_fulfillment_times) in Goal.RangeBelow(24)
                minimize DeltaCosts0: state.costs_delta[0] in Goal.RangeBelow(200)
                minimize DeltaCosts1: state.costs_delta[1] in Goal.RangeBelow(200)
                minimize DeltaCosts2: state.costs_delta[2] in Goal.RangeBelow(200)
            }

            lesson fixed_scenarios {
                scenario {
                    control_index: CtrlIndex.All,
                    rng_seed: number<0 .. 2 step 1>,
                    action_recurrence_hrs: ACTION_RECURRENCE_HRS,
                    recent_window_duration: WINDOW_DURATION,
                    recent_window_aggregate: WINDOW_AGGREGATE,
                    cycle_duration_wk: 13
                }
            }

            lesson random_scenarios {
                scenario {
                    control_index: CtrlIndex.All,
                    rng_seed: number<0 .. 16777216 step 1>,
                    action_recurrence_hrs: ACTION_RECURRENCE_HRS,
                    recent_window_duration: WINDOW_DURATION,
                    recent_window_aggregate: WINDOW_AGGREGATE,
                    cycle_duration_wk: 13
                }
            }
        }
    }
}
