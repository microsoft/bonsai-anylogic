# Use case: Product Delivery

## Use case problem

### Problem description

The supply chain includes three manufacturing centers (Chicago, Nashville, Pittsburg) and fifteen distribution centers that order random amounts of the product. Each distribution center orders between 500 and 1000, uniformly distributed – each 1 to 2 days (uniformly distributed).
There is a fleet of 3 trucks available at each manufacturing center and when a manufacturing center receives an order from a distribution center, it checks the number of available products in storage.
If the requested amount of product is available, the manufacturing center sends loaded trucks to the distribution center. Otherwise, the order waits until the factory produces the sufficient amount of products. The shortage of product at any specific manufacturing center does not lead to a transfer of the order to another manufacturing center.

Note that orders are queued based on first-in-first-out and they are always processed by the nearest manufacturing center to the distribution center.

### Business problem

How can we deliver the requested amount of products from the manufacturing centers to the distribution centers while minimizing the associated cost. For each manufacturing center, there are costs associated with the manufacturing center's trucks, whether manufacturing center is closed or open, the manufacturing center's production rate, as well a penalty cost for incomplete orders.

### Objective

Meet the distribution center demands while minimizing the cost given a wide range of distribution center demands. The objective of brain training is to learn how to minimize the cost through keeping the manufacturing centers open while minimizing the costs.

* If there are no demands from distribution centers and the manufacturing centers are kept open, that incurs costs.
* If the manufacturing centers are kept closed and then there are demands, that incurs costs due to delay and order loss.

Furthermore, it is expect from the brain to also control the production rate at each manufacturing center, as it’s an impactful factor in minimizing the cost (keeping the inventory level to a minimum but at a level that can match with the demand and a reduction of the delivery time). Finally, the brain should control the number of vehicles assigned to each manufacturing center since that also has a direct impact on the cost and the delivery time.

### Benchmark

Use the AnyLogic Internal Optimizer as the benchmark performance. Details to be determined.

![image info](/Images/benchmark-1.png)
![image info](/Images/benchmark-2.png)

## Problem simulation description

The model simulates product delivery in USA written in AnyLogic. These orders consist of a uniformly distributed random quantity of goods of between 500 and 1000 units, and they occur every 1 to 2 days. Once an order is received, the reinforcement learning agent will determine how to fulfill the order most cost-effectively. Each manufacturing center produces product with a set rate (productionRate parameter inside the ManufacturingCenter agent type). If the manufacturing center that receives the order is open but doesn’t have enough in stock, the order will wait in a queue (ordersQueue block inside the ManufacturingCenter agent type) until enough products are in the inventory to trigger the shipment. Worth reminding that the shortage of product at any specific manufacturing center does not lead to a transfer of the order to another manufacturing center. The cost associated with different sections of a manufacturing center are as follows:

* **Truck costs**: For every hour the manufacturing center is open or has orders inside of it, the total truck cost is accumulated by number of vehicles * hourly truck cost.
* **Open costs**: For every hour the manufacturing center is open, the total open cost is accumulated by the hourly open cost.
* **Production costs**: For every hour the manufacturing center is open or has orders inside of it, the total production cost is accumulated by the production rate * hourly production cost.
* **Incomplete costs**: For every hour that there are orders in queue to be processed at the manufacturing center, the incomplete order cost is accumulated by the number of orders in the queue * the hourly incomplete order penalty.
These costs are recorded in truckCosts,  openCosts, productionCosts, and incompleteOrderPenalty variables in the simulator.

### Problem description

|                        | Definition                                                   | Notes |
| ---------------------- | ------------------------------------------------------------ | ----- |
| Objective              |  Meet the distribution center demands while minimizing the cost given a wide range of distribution center orders throughout the year | |
| Observations           |  Chicago_is_open, Pittsburg_is_open, Nashville_is_open, Chicago_num_trucks, Pittsburg_num_trucks, Nashville_num_trucks, Chicago_production_rate, Pittsburg_production_rate, Nashville_production_rate, Chicago_util_trucks, Pittsburg_util_trucks, Nashville_util_trucks, Chicago_inventory_level, Pittsburg_inventory_level, Nashville_inventory_level, Chicago_orders_queueing, Pittsburg_orders_queueing, Nashville_orders_queueing, Chicago_average_turnaround, Pittsburg_average_turnaround, Nashville_average_turnaround, Pittsburg_cost_per_product, Nashville_cost_per_product, overall_average_turnaround, overall_average_cost_per_product | |
| Actions                | Chicago_is_open, Pittsburg_is_open, Nashville_is_open, Chicago_num_trucks, Pittsburg_num_trucks, Nashville_num_trucks, Chicago_production_rate, Pittsburg_production_rate, Nashville_production_rate | |
| Control Frequency      | Every day | |
| Episode configurations | OpenCost_PerHour, ProductionCost_PerHour, IncompleteOrderPenalty_PerHour, TruckCost_PerHour | |
| Iteration              | Every 24 hours||
| Episode                | 30 days or 720 hours

* **overall_average_turnaround** refers to the average time it takes for any order to go from being received at the manufacturing center to when it is delivered to the distribution center for all the manufacturing centers.
* **overall_average_cost_per_product** refers to the average accumulated cost (Truck costs, Open costs, Production costs, Incomplete costs) for all the manufacturing centers.

## Solution approach

### High level solution architecture

Under consideration

<!-- - None of the manufacturing centers should be closed at the same time
- Is it possible for the distribution center demand to be supplied by two manufacturing centers? No
- Shall the supply be always provided by the nearest manufacturing center? Yes
- Are we able to determine the distance between the manufacturing centers and the distribution centers? No
- If the manufacturing center has enough inventory, use all the trucks to deliver.
- We want to minimize the average time it takes to deliver to the distribution centers.
-  -->
<!-- - < Problem decomposition diagram > -->

<!-- #### Brain experiment card

|                        | Definition                                                   | Notes |
| ---------------------- | ------------------------------------------------------------ | ----- |
| State                  |  |       |
| Terminal               |            |       |
| Action                 |                     |       |
| Reward or Goal         |                              |       |
| Episode configurations |                                        |       |

### Results

- < Brain training graph >
- < Policy vs standard benchmark > -->
