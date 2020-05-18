# Bonsai Connector Library
The library will need to be included with your <a href="https://www.anylogic.com/features/artificial-intelligence/microsoft-bonsai/">wrapper</a>. While the <a href="wrapper_model_workflow.pdf">wrapper model workflow</a> outlines what needs to be included in your AnyLogic model,  this document describes the classes that are used in the connector library and how they map to your inkling code code for Bonsai.

The Bonsai Connector includes base functionality for communicating to the Microsoft Bonsai service, and does not require the user to implement any special logic to do so. The connector includes three base classes that are used to implement connection to the Bonsai platform. 

- Config class
- Observation class
- Action class

When your simulator connects to the Bonsai platform, it does so by:

1. Registering your simulator with the Bonsai platform using the Simulator Name specified in the connector. After starting your simulator, click on the Train button in the Bonsai dashboard and select the name of your simulator to begin training. 
2. Upon an *episode start* event, the connector acquires an initial configuration from the Bonsai brain. This is used by a class derived from **Config** to set initial conditions for your model and map to the values in your Config type in inkling. You can learn more about configuring lessons in inkling <a href=
https://docs.microsoft.com/en-us/bonsai/inkling/">here</a>.
3. At each *episode step* in your model the connector sends the values derived from the **Observation** class. The values in your derived Observation class should match the name and types of variables found in the State type in your inkling for your Bonsai brain.  When the brain receives the observation, it also evaluates the reward or terminal conditions associated with your inkling and determines the next best action. 
4. During the *episode step* event, the connector provides the values from a derived **Action** class. These values map to the Action type in your inkling for your Bonsai brain and represent the next step, or action, the brain would like your model to run. 
5. If a terminal condition is hit in inkling, or your simulator reaches a halted state, the connector will fire an *episode finish* event. This is a great place to stop your model and get it ready for a new run. 


## The Config class
The Config class is used to define the values that the Bonsai brain will use during an episode start event. These allow you to create a machine teaching curriculum for your brain. For more on curriculums, see [here].

 An example of a derived Config class is:

```java
import com.anylogic.sdk3.connector.Config;

public class ModelConfig extends Config {
	public double arrivalRate;
	public double existenceCostPH;
	public double resABusyCostPH;
	public double resAIdleCostPH;
	public double resBBusyCostPH;
	public double resBIdleCostPH;
	public double relativeProcessCost;
	public double relativeMoveCost;
}
```
The values in your Config class should map to the config type values in inkling. For example, using the values above, you would also have:

```
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
```

defined in your inkling for your brain in Bonsai.


## The Observation class
The Observation class is used to define the class that will be using to communicate the state of the AnyLogic model to the Bonsai brain. As outlined above, these values are used by the brain to evaluate reward and terminal conditions as well as what action the model should take next. An example of a derived Observation class is:

```java
import com.anylogic.sdk3.connector.Observation;

public class ModelObservation extends Observation {
	public double arrivalRate;
	public int nResA;
	public int nResB;
	public double utilResA;
	public double utilResB;
	public double idleCostResA;
	public double idleCostResB;
	public double busyCostResA;
	public double busyCostResB;
	public double processTime;
	public double conveyorSpeed;
	public double costPerProduct;
}
```
The values in your Observation class should map to the state type values in inkling. For example, using the values above, you would also have:

```
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
```

defined in your inkling for your brain in Bonsai. 

> It is a recommended best practice to indicate the ranges of your states in inkling. This will increase the speed of your brain training.

## The Action class
The Action class is used to define the class that will be using to parse the action from the Bonsai brain to be performed in the AnyLogic model. This may include As outlined above, these values are used by the brain to evaluate reward and terminal conditions as well as what action the model should take next. An example of a derived Observation class is:

```java
import com.anylogic.sdk3.connector.Action;

public class ModelAction extends Action {
	public int nResA;
	public int nResB;
	public double processTime;
	public double conveyorSpeed;
}
```
The values in your Action class should map to the action type values in inkling. For example, using the values above, you would also have:

```
type Action {
    nResA: number<1 .. 20>,
	nResB: number<1 .. 20>,
	processTime: number<1.0 .. 12.0>,
	conveyorSpeed: number<1.0 .. 15.0>,
}
```

defined in your inkling for your brain in Bonsai.

> It is a recommended best practice to indicate the ranges of your actions in inkling. This will increase the speed of your brain training. 
