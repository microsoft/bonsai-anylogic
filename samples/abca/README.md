# Activity Based Costing Analysis Overview
In this simplified factory floor model, cost associated with product processing is calculated and analyzed.

Each incoming product seizes one unit of resource A, then one unit of resource B, then is processed by a machine. Afterwards, resource A is released, the product is conveyed to the exit, and then resource B is released just before the exit.

Whenever the product is in the system, the “Existence” cost applies ($ per hour). While a resource unit is being seized by a product, its “Busy” cost is allocated to the product, otherwise the “Idle” cost is applied (which is uniformly distributed to all products). Processing at the machine and conveying have direct fixed costs, which are different for equipment with different performances. 

Cost accumulated by a product is broken down into several categories for analysis and optimization.

### Complexity 
-	Rate of product arrivals can be thought as exogenous and are made configurable.
-	Capacities of resource A and B, processing time of the machine and conveyor speed can be adjusted dynamically in order to keep the total cost per product at minimum.
-	Regular simulation optimization (SO) is not capable of adaptively changing of parameters in order to produce optimum results for unpredictable arrival rates.

### Observation space
- 	Arrival rate

Although there are many aspects of the simulator, the frequency which products arrive into the factory was found to be the most influential. 

### Action space
-	Number of "A" and "B" resources
-	Process time
- 	Conveyor speed

### Reward
-	The reward is optimized based on minimizing the total cost per product (this may need modification to maintain a desired production goal in a particular scenario). A penalty is given if the chosen actions cause the system to overload.

# Create a Brain

To start a new brain for this model: 

1. Create an account or sign into Bonsai. 
2. Click **Create brain** button in the top left, then select **Empty brain** in the dialog. 
3. Name your new brain (e.g., “costing-analysis”). 
4. Click **Create Brain**. This will create a new brain for you.

Copy the contents of <a href="abca.ink">abca.ink</a> in to the *Teach* tab for your new brain. 

Do not click Train yet. 

# Running the Model

Open the provided model inside of AnyLogic. From the **Projects** panel, double click on the "Main" agent to navigate inside of it. Locate the "bonsaiConnector" object within the dotted red box above the initial view; click on its icon to view its properties. In the **Properties** panel, replace the placeholders for the "Workspace ID" and "Access key" fields with your own credentials (they should be placed inside quotation marks).

From the **Projects** panel, right click on the **TrainingSimulation** experiment, then click the **Run** button. You will see text in the console about registering with the Bonsai platform. Once registration is complete (it will only take a few seconds), go back to the Bonsai UI where you created your brain.

Click the **Train** button. The simulator with the name matching your simulator will appear (default: "ABCA sim"). Click the name of your simulator. 

If this is the first time starting your brain, it may take a few minutes for the brain to generate the appropriate parameters and connect to the simulator. Once the connection is made, you will see the model beginning to run on its own and occasionally reset itself. 

During preparation and training, do not attempt to make any meaningful interactions with the running model, as it may disrupt the training process.

You may decide to let your training run for a bit, particularly across multiple episode start events, to get an understanding of how the model behaves under various configuration parameters provided by the brain. 

In general, you will also want to make sure the number of iterations per episode stays below 1000, or the brain will struggle to learn. The default implementation of this model only has 2 iterations: one at the start for the brain to choose the action (based on the arrival rate) and a second, 6 months into the simulation, where it will evaluate its performance and restart the episode to try again.

After you have tested locally, stop your model. Then click **Stop Training** in the Bonsai UI for the brain. 

# Export Your Model

After you have confirmed your model can connect to the platform locally, it's time to scale your model. This will be done by exporting the model as a zip file and uploading it in the Bonsai UI. This feature is available to _all_ editions of AnyLogic, including Personal Learning Edition (PLE).

Inside of AnyLogic, under the **Projects** panel, click on the "RLExperiment" experiment. At the top of the **Properties** panel, select "Export to Microsoft Bonsai".

In the prompt, choose a destination for the zip file, then click **Next** to begin the export. When it's finished, you may follow the steps shown and then click the **Finish** button.

If you are not able to export your model in this way, you may use the example <a href="exported.zip">exported.zip</a> file.

Note that, unlike the export feature available in AnyLogic Professional, this exported model will _only_ function on the Microsoft Bonsai platform.

# Scale Your Model

Once you have exported your model, return to the Bonsai UI and next to **Simulators**, click the **Add sim** button.

This will open a dialog. 

<img src="images/add_sim.png" alt="Add Sim Prompt" width="500" border="1"/>

Select AnyLogic. 

<img src="images/add_sim_al_nozip.png" alt="Add Sim Prompt 2" width="500" border="1"/>

Select or drag the zip file containing the exported model. 

<img src="images/add_sim_al_zip.png" alt="Add Sim Prompt 3" width="500" border="1"/>

Give your simulator a name, then click **Create simulator**. 

After the simulator is created you will see the new simulator appear under the **Simulators** section.

Now click the *Teach* tab. 

In the simulator definition, just after the open brackets, add a <a href="#">package</a> statement using the name of the simulator you gave during the Add Simulator dialog above.

```
simulator Simulator(action: SimAction, config: SimConfig): SimState {
	package "<simulator_name_from_upload>"
}
```

Now click **Train**. Since you indicated the package name, you do not need to select a simulator from the dropdown like you did when you started locally.

In a few minutes time you will see several simulators connect to and train your brain.  

# Sample Results
You can read about how the Bonsai brain performed against the default AnyLogic optimizer in the `ABCA-Optimization-Writeup.docx` file.

# Using Bonsai Assessment with Your Model
You can perform Bonsai Assessments either with the unmanaged (locally hosted) or managed (uploaded) sim. Instructions for each can be found in the following two Bonsai documentation articles:

- Unmanaged: https://docs.microsoft.com/en-us/bonsai/guides/assess-with-local-sim
- Managed: https://docs.microsoft.com/en-us/bonsai/guides/assess-brain

Additionally, you can export a partially or fully trained brain and add it back into the simulation model through the use of the Bonsai Connector's "Playback" functionality. To do this, start by clicking the _Train_ tab in the Bonsai UI and then the **Export brain** button. Enter a desired export name and preserve the default processor architecture, then click **Export**.

After a few minutes, you should see a pop-up with instructions for deployment via Docker. 

If you have Docker on your system, you may follow the instructions in the pop-up to host your brain on your local machine. In this case, skip the following paragraph; otherwise, read on.

If you don't have Docker on your system or wish to have a publicly available deployment, you can create an Azure Web App that hosts your exported brain (done from the Azure Portal). For a detailed visual walkthrough, see the "Exporting the model" section of a previous AnyLogic-Bonsai webinar (<a href="https://youtu.be/-iTSZaG3lg8?t=3968">timestamped link</a>) - **important:** the core focus of the linked webinar is for a now-deprecated workflow; however, the web app deployment process is mostly the same.

Once you have a brain running locally via Docker or hosted on a web app, return to the model in AnyLogic and, once again, view the properties of the "bonsaiConnector" object. In the **Exported brain address** field, enter  the prediction endpoint as a quoted string. The specific format of the endpoint will be slightly different depending on your chosen deployment strategy:

- Docker: http://localhost:5000/v1/prediction
- Web App: https://MYWEBAPP.azurewebsites.net/v1/prediction
    - (where "MYWEBAPP" is the name of your Web App)
	
Next, right click the model's "PlaybackSimulation" experiment (in the **Projects** panel) and click **Run**. When the model starts, it is setup such that it will query your exported brain whenever you change the slider for "Arrival rate".

