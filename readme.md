# Overview of the AnyLogic SDK for Bonsai
The AnyLogic SDK for Bonsai is an add-in to AnyLogic that allows users to connect their AnyLogic models to the Microsoft Bonsai platform.<url>  

# Including the SDK in Your Model
The AnyLogic SDK for Bonsai is an external JAR library that can be included. To add to an existing model, add the **com.anylogic.sdk3.connector-0.0.4.jar** file to your model project, as well as its dependencies:


- activation-1.1.1.jar
- aopalliance-repackaged-2.5.0-b32.jar
- com.anylogic.sdk3.connector-0.0.4.jar
- hk2-api-2.5.0-b32.jar
- hk2-locator-2.5.0-b32.jar
- hk2-utils-2.5.0-b32.jar
- jackson-annotations-2.8.4.jar
- jackson-core-2.10.1.jar
- jackson-databind-2.8.4.jar
- jackson-jaxrs-base-2.8.4.jar
- jackson-jaxrs-json-provider-2.8.4.jar
- jackson-jr-objects-2.10.1.jar
- jackson-module-jaxb-annotations-2.8.4.jar
- javassist-3.20.0-GA.jar
- javax.annotation-api-1.2.jar
- javax.inject-2.5.0-b32.jar
- javax.ws.rs-api-2.0.1.jar
- jaxb-api-2.3.0.jar
- jaxb-core-2.3.0.jar
- jaxb-impl-2.3.0.jar
- jersey-client-2.25.1.jar
- jersey-common-2.25.1.jar
- jersey-entity-filtering-2.25.1.jar
- jersey-guava-2.25.1.jar
- jersey-media-json-jackson-2.25.1.jar
- json-20190722.jar
- osgi-resource-locator-1.0.1.jar

Each of these files are located in the <a href="./connector">connector</a> directory.

If you need help for how to add external classes to your model, please visit the <a href="https://help.anylogic.com/index.jsp?topic=%2Fcom.anylogic.help%2Fhtml%2Flibraries%2FAdding+External+Jar+Files+and+Java+Classes.html">Adding External Java Classes</a> section on the AnyLogic help page.


# Connecting Your Model to Bonsai
The AnyLogic SDK for Bonsai includes base functionality for communicating to the Micorsoft Bonsai service, and does not require the user to implement any special logic to do so. The core

The SDK has four core base classes that are used to implement connection to the Bonsai platform. 

- ISimulator<Action,Config> interface
- Config class
- Observation class
- Action class

When your simulator connects to the Bonsai platform, it does so by:

1. Using the **ISimulator** interface to register your simulator with the Bonsai platform and receiving a session ID. After starting your simulator, click on the Train button in the Bonsai dashboard and select the name of your simulator to begin training. 
2. Upon an *episode start* event, the SDK acquires an initial configuration from the Bonsai brain. This is used by a class derived from **Config** to set initial conditions for your model and map to the values in your Config type in inkling. You can learn more about configuring lessons in inkling [HERE].
3. At each *episode step* in your model the SDK sends the values derived from the **Observation** class. The values in your derived Observation class should match the name and types of variables found in the State type in your inkling for your Bonsai brain.  When the brain receives the observation, it also evaluates the reward or terminal conditions associated with your inkling and determines the next best action. 
4. During the *episode step* event, the SDK provides the values from a derived **Action** class. These values map to the Action type in your inkling for your Bonsai brain and represent the next step, or action, the brain would like your model to run. 
5. If a terminal condition is hit in inkling, or your simulator reaches a halted state, the SDK will fire an *episode finish* event. This is a great place to stop your model and get it ready for a new run. 

## The ISimulator<Action,Config> Interface
The ISimulator<Action,Config> interface is used to define the class that will be using to communicate between AnyLogic and the Bonsai platform. The interface requires the following methods to be implemented:

```java
	// sends an observation to Bonsai as State
    public Observation getObservable();

    // fired when a new episode starts.  
    // Takes a class derived from the base Config class
	public void episodeStart(Y config);

    // fired when an episode step, or iteration, occurs
    // Takes a class derived from the base Action class
	public void episodeStep(T action);

    // fired when an episode finish event occurs
	public void episodeFinish();

    // signals the brain that the simulator cannot proceed
	public boolean halted();
```

The following is an example of a ModelExecuter class that derives from ISimulator using ModelAction action and ModelConfig config types:
```java
/**
 * ModelExecutor
 */	

import com.anylogic.sdk3.connector.*;
public class ModelExecutor implements ISimulator<ModelAction, ModelConfig> {

	CustomExperiment exp;
    /**
     * Default constructor
     */
    public ModelExecutor() {
    }

	@Override
	public String toString() {
		return super.toString();
	}
	
	@Override
	public Observation getObservable() {
		if (exp !=null && exp.root !=null)
			return exp.root.getObservation();
		else 
			return new ModelObservation();
	}
	
	public void episodeStart(ModelConfig config) {
		
		steps = 0;
        traceln("EPISODE START");

		exp.engine = exp.createEngine();
	
        // other start up info, like timings

        // Create new root object:
		exp.root = new Main( exp.engine, null, null );
		// TODO Setup parameters of root object here
		exp.root.setParametersToDefaultValues();
		if(config != null) {
			exp.root.set_maxGreenEW((int)config.Max_time_EW);
			exp.root.set_maxGreenNS((int)config.Max_time_NS);
		}
		// ...
		// Prepare Engine for simulation:
		exp.engine.start( exp.root );
		// Start simulation in fast mode:
		exp.engine.runFast();
	}

	int steps = 0;
	
	public void episodeStep(ModelAction action) {
		
		steps += 1;
		
		traceln("STEP NUMBER " + steps);
		
		exp.root.doAction(action.switch_action);
		exp.engine.runFast();

	}
	
	public boolean halted() {
		if (exp !=null && exp.root !=null)
			return exp.root.halted;
		else
			return false;
	}
	
	
	public void episodeFinish() {
		
		traceln("EPISODE FINISH");
		
		exp.engine.stop();		
	}
}
```
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

<b><i>Note</i></b>
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

<b><i>Note</i></b>
> It is a recommended best practice to indicate the ranges of your actions in inkling. This will increase the speed of your brain training.


# Configuring a Custom Experiment

Now that you have configured your ModelExecuter, ModelConfig, ModelObservation and ModelAction, it is time to connect them together in a <a href="https://help.anylogic.com/index.jsp?topic=%2Fcom.anylogic.help%2Fhtml%2Fexperiments%2FCustom_Experiment.html">custom experiment</a>.

In this case, our custom experiment will set up the configuration and session information to communicate to the Bonsai platform. 

A sample CustomExperiment class:

```java

// our sim object that implements ISimulator is the ModelExecuter class
sim = new ModelExecutor();
sim.exp = this;

// the workspace ID obtained from the Bonsai platform
String workspace = "<BONSAI_WORKSPACE_ID>";

// the access key obtained from the Bonsai platform
String accessKey = "<BONSAI_ACCESS_KEY>";

// this will show as the simulator name in the Bonsai dashboard
String simulatorName = "AnyLogic Pro 8";

// create a SessionConfig class (from the SDK) with your connection information
SessionConfig sc = new SessionConfig(accessKey, workspace, simulatorName);                     

// create a SimulatorSession class (from the SDK) to communicate with the Bonsai platform
// note the additional ModelAction.class and ModelConfig.class parameters. 
// These indicate the derived types of the classes you defined above
SimulatorSession session = new SimulatorSession(sc, sim, ModelAction.class, ModelConfig.class);

// start the session. This registers your simulator with the Bonsai platform
session.startSession();
```

After starting your simulator locally, go to your brain in the Bonsai dashboard. Click the Train button, then select the name of your simulator ("AnyLogic Pro 8" above). It may take several seconds for the brain to connect to your simulator and fire the first episode start event.

## Disposing of local connections to Bonsai
Each session with Bonsai is given a unique ID that is used during communication. If the custom experiment is stopped using the red stop button in AnyLogic, there is not a chance to unregister the simulator from Bonsai. This will result in multiple simulators named "AnyLogic Pro 8" showing up in your dashboard and may cause confusion. If this happens, you can retrieve the session ID from the Bonsai platform by clicking on the simulator and then getting the ID from the URL. For example:

https://preview.bons.ai/workspaces/123456789012345a/simulator/807951236_10.244.48.40/connect

The session ID in the above URL is:

807951236_10.244.48.40

You can manually unregister this simulator by calling:

```java
SessionConfig sc = new SessionConfig(accessKey, workspace, simulatorName);                     

SimulatorSession session = new SimulatorSession(sc, sim, ModelAction.class, ModelConfig.class);

// unregister a previous session
session.unregister("807951236_10.244.48.40");

// start new session here
```