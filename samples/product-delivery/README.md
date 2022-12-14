# Product Delivery

A single-echelon supply chain for a single product produced by manufacturing centers who fulfill orders sent by distributors. 

The manufacturing process is continuous and is controlled by a set production rate, measured in units per hour. Two sources of cost are modeled for each center:

1. Holding cost - for expenses related to having to store the product on-site; accumulated at a rate relative to the number of products currently on-hand.

2. Maintenance cost - for expenses related to up-keep of the machine used to create the product; accumulated at a fixed rate plus additional costs whenever the machine is changing its speed.

Note: Any other sources of costs are considered irrelevant or negligible and are thus not modeled.

Each distributor has a different chance to order for each day of the week in addition to individualized distributions for the order sizes. Additionally, there is an order cycle (default duration of 13 weeks) that affects all distributors' chance to order.

When distributors place an order, they send it to the nearest manufacturing center. On receiving it, if there is enough product on hand to fulfill it, the product is immediately loaded onto an available vehicle for transportation. Otherwise, the order (and any subsequently arriving orders) must wait for the product to be manufactured.


## Objective

Train a brain to control each manufacturer's production rate such that the order fulfillment time and accumulated costs are minimized.

## Action

| Action          | Type                | Description      | 
| -----           | -----               | ---------------- | 
| production_rates | number<0..200>[3]   | New production rate to set, per center | 

Notes:
- When controlling single locations, the sim still expects an array. However, the values for the non-controlled locations are ignored
- Taking an action will set a target rate; the machines take time to get to speed (implemented as a two hour exponential delay)

## States

| State           | Type                | Description      | 
| -----           | -----               | ---------------- | 
| day             | number<1..7 step 1> | Day of the week, starting with sunday | 
| hour            | number<0..23 step 1> | Hour of the day |
| time_years       | number              | Model time of the simulation, in years |
| control_index   | number<All=-1, Chi=0, Pit=1, Nsh=2> | Which location are the rates being controlled for |
| production_rates | number<0 .. 200>[3] | The currently set rates, from the last action |
| products        | number[3]           | On-hand amount, per center  | 
| costs           | number[3]           | The total accumulated costs since the beginning of the run |
| costs_delta     | number[3]           | The accumulated costs since the last action |
| queueing_count  | number[3]           | The number of orders current queueing for fulfillment |
| queueing_amount | number[3]           | Cumulative amount in all the orders queueing for fulfillment |
| max_fulfillment_hrs | number[3]     | Maximum time (in hours) to fulfill an order since the start of the run |
| recent_queueing_hrs_max | number[SAMPLES][3] | Maximum time (in hours) to fulfill an order within the rolling window |
| recent_orders_count | number[SAMPLES][3] | How many orders were received within the rolling window |
| recent_orders_amount | number[SAMPLES][3] | Cumulative amount of all orders requested within the rolling window |
| recent_costs | number[SAMPLES][3] | History of the cumulative costs (since the run's start) within the rolling window |

Notes:
- The maximum magnitude of the "delta" costs will depend on how frequently actions are being taken (i.e., more frequent actions => lower maximum delta)
- Time to fulfill an order is defined starting when the center received it until it was ready for delivery, which is omitted as it's known to not be a bottleneck and will vary depending on travel distance
- The number of elements in the "recent_" values will depend on the configuration; specifically the window duration divided by the aggregate (see its notes for more information)

## Configuration

| Configuration         | Type                          | Description                                  |
|-----------------------|-------------------------------|----------------------------------------------|
| control_index	        | number<All=-1, Chi=0, Pit=1, Nsh=2> | Which location to control the rates for |
| action_recurrence_hrs | number<2 .. 24 step 2> | How many hours between actions |
| rng_seed              | number<-1 .. 16777216 step 1> | Seed for the order generation (for outputting reproducible runs); -1 for random |
| cycle_duration_wk     | number<0 .. 52 step 1> | Global ordering cycle length (weeks); 0 for no cycle |
| recent_window_duration_hrs | number | How far back (in hours) the "recent_" have data for |
| recent_window_aggregate_hrs | number | The amount of time (in hours) to bin the "recent_" data points into |

Notes:
- Higher values can be technically used for the action recurrence, but this is not recommended
- As the order cycle is based on a sine wave, it's recommended to use values >= 4 (or just disable it). To get a feel for why, you can find an interactive demo here: https://www.desmos.com/calculator/f7zy9qplqw 
- The number of samples in each "recent_" array equal the duration divided by the aggregate (e.g., requesting 1 week - 168 hours - of data, aggregated into 24 hour bins results in 7-length arrays (168/24)

### Concept

* Minimize fulfillment time below 24 hours
* Minimize delta costs below $200/day

## Terminal conditions

* Avoid fulfillment time above 48 hours

## Evaluation

The model is setup to compare brains versus three baselines:

1. Static rates (i.e., set once on startup and not changed afterwards)

2. Linear inventory policy: sets production rate based on the number of products it has

3. Custom heuristic: finds initial production rate based on the average expected amount of products that will be requested the next day (as it takes time to produce enough); it also checks if it has enough products for the current day and, if not, attempts to reach the average expected amount by midnight of that day.

To compare brains against these, a custom dashboard was setup in AnyLogic to directly compare these. It can dynamically run any number of instances of the model in parallel to one another, including any/all of the baselines and any number of brains.

## Running the Simulator Locally

When running the simulation locally, it has two experiments you can run. After running either, you are presented with an input screen to choose your run configurations. 

1. SingleSimulation - intended for a single run, for running the default sim (no brain; only baselines), local training, or playback (brain controlling).

2. PolicyComparator - intended when wanting to compare two or more policies (whether the baselines and/or any number of brains).
