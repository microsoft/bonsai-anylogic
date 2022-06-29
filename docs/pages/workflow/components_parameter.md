---
title: The 'mode' parameter
permalink: components_parameter.html
summary: "The 'mode' parameter is an optional but recommended technique to easily toggle between running your model in different contexts without having to refactor it."
---

## About

With an iteration trigger (i.e., call to `takeAction`) and/or an enabled Bonsai Connector object, you lose the ability to run any non-RL experiments - both of these components can only be run in RL-contexts and trying to execute the model outside of that will cause errors. 

Without any mechanisms to optionally disable these components when the model starts, you will need to manually disable/enable them *every time* you want to switch between using your model in RL and non-RL contexts - a needlessly cumbersome exercise.

A more flexible solution is to have a parameter in your top-level agent which serves as a switch or toggle between the different ways to execute the model. Your iteration trigger can then be made to execute conditionally and your Bonsai Connector can be setup to be conditionally enabled.

{% include note.html content="The RL Experiment does not have any inherent behavior or effect on your model, so nothing will need to be changed with it." %}

There are *at least* three "modes" that you will want to execute a model in:

1. *Non-RL/Default mode*: This will disable both the iteration trigger and the Bonsai Connector, allowing you to run the model as a "traditional" one (a non-RL-ready one). In this mode, you can freely run your model, as if it had no RL hooks.

2. *Training mode*: This will trigger iterations and enable the Bonsai Connector. When you run a Simulation experiment, it will serve as a locally hosted simulation model. When it's later uploaded to Azure for scaled training, the iteration trigger will work similarly.

3. *Assessment/Playback mode*: This also triggers iterations and enables the Bonsai Connector. However in addition, it will enable the "Playback" feature in the Bonsai Connector. When you run a Simulation experiment, it will query the brain whenever an iteration happens. In this mode, only you control when a simulation run ends.

The three listed above are the main ones that this document will focus on. However, you may also wish to have additional "modes" for other behaviors in the model (e.g., heuristic vs interactive operation, or different sub-types of training modes).

For the mode parameter's data type, you may wish to use Strings, integers, booleans, or option lists. For simplicity, this workflow document recommends using integers (int). 

{% include note.html content="Using integers allows for many values to be assigned within a single parameter (using an arbitrary sequential system, such as 0, 1, 2, etc.) and the comparison logic is easy to implement. With AnyLogic's support for changing a parameter's Value Editor, you can assign labels to the values you choose -- thus, any need to memorize what values correspond to the behaviors is removed." %}

## Implementation

To implement the mode parameter:

1.  Add a new parameter to your top-level agent:

    a.  Give it an appropriate name (e.g., "mode", "bonsaiMode",
        "exeMethod")

    b.  Set its type to int

    c.  Under Value Editor, give it an appropriate label (e.g., "Execution mode") and change the type to "Radio Button"

    d.  For each execution mode you want (non-RL/default model, brain training, assessment/playback, etc.), assign a name/label to it and some unique value.
	
    {% include image.html file="image24.png" caption="Example setup of the mode parameter" %}

	{% include note.html content="The values used here are arbitrary; use whatever numbering system is most intuitive to yourself. The only (informal) requirements are that the values are unique to one another and used consistently in your logic." %}
	
	{% include tip.html content="You can preview the values by clicking on the Properties of a Simulation-type experiment. If you (temporarily) switch the field type to 'Static Value', you'll see the number underlying your label!" %} 
	
	<img src="./images/image28.png" style="width:6.160655in;height:2.3464458in" />
	
2.  In the Configuration section of the RL Experiment, add a line of
    code that assigns the mode parameter to whatever value corresponds
    to training.

    {% include note.html content="This ensures any logic related to the mode parameter will work as intended when uploaded." %}

    {% include important.html content="If you don't include this step, the parameter will use whatever value is set as the default in its properties - and if blank, numerical types will be set to 0." %}
	
	<img src="./images/image25.png" style="width:5.186852in;height:2.08307in" />

3.  In the event for your iteration trigger, add logic so that its execution is dependent on the value of "mode".

    <img src="./images/image26.png" style="width:4.307858in;height:3.39488in" />
	
	{% include note.html content="The code used in the non-RL part will be specific to whatever model you're working on." %}

4.  When using the Bonsai Connector (locally hosted simulator or using Playback), change the type of parameters for the "Enable" and "Playback" from "Value Editor" to "Static Value" by clicking on the equal symbol next to the field name. Enter boolean expressions that evaluate to `true` when the appropriate condition applies.

    <img src="./images/image27.png" style="width:4.87439in;height:2.187227in" />

5.  You can now choose the desired execution mode from the simulation experiment's properties and run the model. If switching this value is annoying or confusing, you can also choose to have multiple Simulation experiments, one for each mode, and naming them appropriately. This allows you directly execute the experiment, without having to change any options. New experiments can be created as follows:

    a.  In the **Projects** panel, right-click (or Ctrl-click) the model you are working with and choose **New** \> <img src="./images/image13.gif" style="width:0.16666in;height:0.1666" /> **Experiment** from the context menu. The **New Experiment** dialog box is displayed.

    b.  Choose <img src="./images/image29.gif" style="width:0.16666666666666666in;height:0.16666666666666666in" /> **Simulation** in the **Experiment type** list.

    c.  Type the name of the experiment in the **Name** edit box (e.g., TrainingSim, TestbedSim, DefaultSim)

    d.  Select the other options as desired and click **Finish**.

    e.  Click on the newly added simulation experiment and under for the mode parameter entry, select the appropriate setting corresponding to the experiment.
	
{% include tip.html content="For any Simulation experiment intended to be used for locally hosted training, ensure the option for 'Randomness' is set to 'Random Seed' (assuming that is desired), 'Stop time' is set to 'Never' and 'Execution mode' is set to 'Virtual time'." %}

<img src="./images/image30.png" style="width:5.44479in;height:3.506695in" />