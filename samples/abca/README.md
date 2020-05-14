# Activity Based Costing Analysis Overview
In this simplified factory floor model, cost associated with product processing is calculated and analyzed.

Each incoming product seizes one unit of resource A, then one unit of resource B, then is processed by a machine. Afterwards, A is released, the product is conveyed to the exit, and then B is released just before the exit.

Whenever the product is in the system, the “Existence” cost applies ($ per hour). While a resource unit is being seized by a product, its “Busy” cost is allocated to the product, otherwise the “Idle” cost is applied (which is uniformly distributed to all products). Processing at the machine and conveying have direct fixed costs, which are different for equipment with different performances. 

Cost accumulated by a product is broken down into several categories for analysis and optimization. You can change the factory floor parameters on the fly and see how they affect the product cost.

### Complexity 
-	Production rate, cost of resources A & B are configurable.
-	Capacities of resource A, B, processing time of the machine and conveyor speed can be adjusted dynamically in order to keep the total cost per product at minimum.
-	Regular simulation optimization (SO) is not capable of adaptive change of parameters in order to produce optimum results over time

### Observation space
-	Arrival rate 
-	Number of resource A
-	Number of resource B
-	Utilization of resource A & B 
-	Idle and busy costs for resource A and B
-	process time, conveyor speed 

### Action space
-	Number of resource A and B
-	process time, conveyor speed (these could be continuous values)

### Reward
-	The reward is optimized based on minimizing the total cost per product (this may need modification to maintain a desired production goal in a particular scenario).

# Create a Brain

To start a new brain for this model: 

1. Create an account or sign into Bonsai. 
2. Click **Create brain** button in the top left, then select **Empty brain** in the dialog. 
3. Name your new brain (e.g., “costing-analysis”). 
4. Click **Create Brain**. This will create a new brain for you.

Copy the contents of <a href="abca.ink">abca.ink</a> in to the *Teach* tab for your new brain. 

Do not click Train yet. 

# Understanding the Model

The Activity Based Costing Analysis model is made up of many components. The table below outlines how these components work together:

| Component   |      Description      |
|----------|:-------------|
| Main agent |  The primary agent that sets up the costing scenario. |
| Simulation: Main |    The visual simulation. This does not run training with Bonsai.   |
| CustomExperiment | The custom experiment is used to connect the AnyLogic model with the Bonsai platform using the <a href="../..">AnyLogic SDK for Bonsai</a>. |
| ModelExecuter | Implements the ISimulator interface and handles the episode events from Bonsai. |
| ModelConfig | Implements the base Config class to set variables in the model for use of machine teaching in Bonsai. |
| ModelObservation | The state related information for the model to pass to the Bonsai platform.  |
| ModelAction | The action from the Bonsai platform. For example, set variable *x* to value *v*. |

Open the CustomExperiment and enter your workspace and access keys for connecting to the Bonsai platform. These can be obtained from [link].

Example CustomExperiment:
```java
sim = new ModelExecutor();
sim.exp = this;

// bonsai workspace
String workspace = "<your workspace here>";

// access key, generated from https://beta.bons.ai/brains/accounts/settings
String accessKey = "<your access key here>";
String simulatorName = "AnyLogic - ABCA";

SessionConfig sc = new SessionConfig(accessKey, workspace, simulatorName);                     
SimulatorSession session = new SimulatorSession(sc, sim, ModelAction.class, ModelConfig.class);

session.startSession();
```

Once you have entered your workspace and access keys, you are ready to run the model.

# Running the Model

To run the model, right click on **CustomExperiment** then click the **Run** button. You will see text in the console about registering with the Bonsai platform. Once registration is complete (it will only take a few seconds), go back to the Bonsai UI where you created your brain.

Click the **Train** button. The simulator with the name matching your simulator will appear (in the example above, this is called *AnyLogic - ABCA*). Click the name of your simulator. 

If this is the first start of your brain it may take a few minutes for the brain to generate the appropriate parameters and connect to the simulator. Once the connection is made you will see your first episodeStart event fire in the ModelExecuter handler. 

You may decide to let your training run for a bit, particularly across multiple episode start events, to get an understanding of how the model behaves under various configuration parameters provided by the brain. You will also want to make sure your number of iterations stay below 1000, or the brain will struggle to learn. If needed, you can implement custom logic in the **halted()** method in ModelExecuter to help drive behavior. Halted indicates to the brain that the simulator has reached a state that it cannot progress from.

After you have tested locally, stop your model. Then click **Stop Training** in the Bonsai UI for the brain. 

# Export Your Model

After you have confirmed your model can connect to the platform locally, it's time to scale your model.

AnyLogic Professional users can export their model by going to **File** > **Export...** > **to standalone Java application** in the menu bar. 

Select CustomExperiment in the dialog and the directory where the exported files will reside.

If you need additional assistance with exporting a model, please see the <a href="https://help.anylogic.com/index.jsp?topic=%2Fcom.anylogic.help%2Fhtml%2Fstandalone%2FExport_Java_Application.html">Exporting a model as a standalone Java application</a> topic in the AnyLogic Help topics.

If you are not able to export your model to a standalone Java application you may use the example <a href="exported.zip">exported.zip</a> file to use for scaling.

# Scale Your Model

Once you have exported your model, you can zip the entire contents of the folder that contains the exported application. 

For example, if your folder structure is:

```
Activity Based Costing Analysis Export
└─── lib
|    |── AnyLogic Model End User Agreement.pdf
|    └── ... jar files ...      
|─── Activity Based Costing Analysis_linux.sh
|─── ... jar files ...
└─── readme.txt
```

Then you only need to zip the parent **Activity Based Costing Analysis Export** folder. 

Back in the Bonsai UI, next to **Simulators**, click the **Add sim** button.

This will open a dialog. 

<img src="Images/add_sim.png" alt="Add Sim Prompt" width="500" border="1"/>

Select AnyLogic. 

<img src="Images/add_sim_al_nozip.png" alt="Add Sim Prompt 2" width="500" border="1"/>

Select or drag the zip file containing the exported model. 

<img src="Images/add_sim_al_zip.png" alt="Add Sim Prompt 3" width="500" border="1"/>

Give your simulator a name, then click **Create simulator**. 

After the simulator is created you will see the new simulator appear under the **Simulators** section.

Now click the *Teach* tab. 

In the simulator definition, just after the open brackets, add a <a href="#">package</a> statement using the name of the simulator you gave during the Add Simulator dialog above.

```
simulator Simulator(action: Action, config: SimConfig): SimState {
	package "<simulator_name_from_upload>"
}
```

Now click **Train**. Since you indicated the package name you do not need to select a simulator from the dropdown like you did when you started locally.

In a few minutes time you will see several simulators connect to and train your brain.  

# Sample Results
tbd

# Using Bonsai Assessment with Your Model
Starting an Assessment session is similar to starting a training session. Start your CustomExperiment class and wait for it to register. In the Bonsai UI, using your already-trained brain, click the **Assessment** button. Then select the name of your simulator

