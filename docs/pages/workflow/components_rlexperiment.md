---
title: Reinforcement Learning Experiment
permalink: components_rlexperiment.html
summary: "A component of an RL-ready simulation model used to define your RL spaces."
---

## About

As a prerequisite for training a reinforcement learning algorithms is to supply it with certain information about the simulation environment. The Reinforcement Learning (RL) experiment provides a platform-agnostic framework for declaring these necessary components in any given RL training setup. Each of these are sometimes referred to as "spaces".

The types of spaces include:

- Configuration: the inputs that are assigned at the start of each run to set the initial model state
	- These are functionally similar to traditional model parameters
- Observation: the variables representing the current state of the simulation at any point in model time (static values, results of calculations, model outputs, model time, etc.)
	- The set (or a subset) of these variables are passed to the brain to determine the action; they can also be used as part of your reward or goal functions, or as part of the terminal condition
- Action: the variables that the brain passes back to the simulation, in response to the current observation, for the relevant action the model should perform

{% include important.html content="Unlike other experiments, the RL Experiment cannot be directly executed by end-users within AnyLogic (as AnyLogic itself does not host any embedded RL algorithms)." %}

{% include note.html content="This experiment type is available in all three editions of AnyLogic; for PLE, limitations still apply in the exported model." %}

From your perspective (as a modeler), the significance of the RL
experiment is to generalize, simplify, and centralize all the
simulation-related hooks and behaviors that the RL algorithms need to
properly function. In other words, its purpose is to define the
characteristics of the simulation in relation to RL training. 

## Implementation

{% include important.html content="Only one RL Experiment can be added per model." %}

1.  To create an RL experiment:

    1.  In the **Projects** view, right-click (or Ctrl + click) the model’s name and choose **New** \> <img src="./images/image13.gif" style="width:0.16667in;height:0.16667in" />**Experiment** from the context menu.

    2.  The **New Experiment** dialog box opens up; select the <img src="./images/image14.gif" style="width:0.16667in;height:0.16667in" /> **Reinforcement Learning** option in the **Experiment Type** list.

    3.  Specify the experiment name in the **Name** edit box.

    4.  Choose the top-level agent of the experiment from the **Top-level agent** drop-down list.

    5.  Depending on your preferences, configure the **Copy model time settings from** checkbox and relevant drop-down.
	
    6.  Click **Finish**.
	
2. Fill out the sections in the RL Experiment, as described by each labeled section below.

<img src="./images/image7.png" style="width:4in;height:3.00973in"
alt="RL Experiment sections" />

<ul id="profileTabs" class="nav nav-tabs">
    <li class="active"><a href="#observation" data-toggle="tab">Observation</a></li>
    <li><a href="#action" data-toggle="tab">Action</a></li>
    <li><a href="#configuration" data-toggle="tab">Configuration</a></li>
	<li><a href="#modeltime" data-toggle="tab">Model time</a></li>
	<li><a href="#randomness" data-toggle="tab">Randomness</a></li>
</ul>

<div class="tab-content">
	<div role="tabpanel" class="tab-pane active" id="observation">
		<p>In the table, add the fields and their data type which make up your Observation space. Adding entries can be done by clicking on the next empty row or using the provided controls.
			<ul>
				<li>The names you specify will be what is referenced later on in your Inkling code.</li>
				<li>The types column has some options in the dropdown, but you can type in any data type, as long as it is JSON-serializable. For more information about valid options, refer to the <a href="appendix_datatypes.html">Allowed data types for the RL Experiment</a> page.</li>
			</ul>
		</p>
		<p>In the code field, assign the fields you specified to their relevant value in the model, referring to your top-level agent by the `root` parameter.</p>
		
		{% include warning.html content="There is also a field for 'Stop condition' which is a boolean field indicating whether to end the current simulation run. As Bonsai *only* supports termination criteria from your Inkling code, this field *should not* be used (kept at the default `false`)." %} 
		
		<p>During runtime, when an iteration is triggered, AnyLogic will call the code you write here and send the subsequent data to Bonsai to request an action to take.</p>
		
		<p>Example:</p>
		<img src="./images/rlexp-observation-sample.jpg" />
	</div>

	<div role="tabpanel" class="tab-pane" id="action">
		<p>In the table, add the fields and their data type which make up your Action space. Adding entries can be done by clicking on the next empty row or using the provided controls.
			<ul>
				<li>The names you specify will be what is referenced later on in your Inkling code.</li>
				<li>The types column has some options in the dropdown, but you can type in any data type, as long as it is JSON-serializable. For more information about valid options, refer to the <a href="appendix_datatypes.html">Allowed data types for the RL Experiment</a> page.</li>
			</ul>
		</p>
		<p>The code field here will get executed when Bonsai sends an action for your model to take. You should apply the values to your model, referencing your top-level agent via the `root` parameter.</p>
		
		{% include tip.html content="You can also execute any other arbitrary code in your model here. For example, you may wish to add to or reset certain statistics." %} 
		
		<p>Example:</p>
		<img src="./images/rlexp-action-sample.jpg" />
	</div>
	
	<div role="tabpanel" class="tab-pane" id="configuration">
		<p>In the table, add the fields and their data type which make up your Configuration space. Adding new entries can be done by clicking on the next empty row or using the provided controls.
			<ul>
				<li>The names you specify will be what is referenced later on in your Inkling code.</li>
				<li>The types column has some options in the dropdown, but you can type in any data type, as long as it is JSON-serializable. For more information about valid options, refer to the <a href="appendix_datatypes.html">Allowed data types for the RL Experiment</a> page.</li>
			</ul>
		</p>
		<p>The code field here will get executed when Bonsai sends a configuration for your model to be setup with. You should apply the values to your model, referencing your top-level agent via the `root` parameter.</p>
		
		{% include important.html content="The code field is executed before the model is fully initialized. You should only use this field to assign model parameters - and specifically by direct assignment (i.e., not via the auto-generated `set_` functions). Failing to do this will result in model errors." %} 
		
		<p>Example:</p>
		<img src="./images/rlexp-configuration-sample.jpg" />
	</div>
	
	<div role="tabpanel" class="tab-pane" id="modeltime">
		<p>If desired, configure the model's start time/date.</p>
		<p>Check that the stop time is set to "Never".</p>
		
		{% include warning.html content="Bonsai only supports ending simulation episodes from the Inkling code and so training will be disrupted if your model attempts to stop itself. As a workaround, you can pass the model time as part of the Observation (this can be later filtered out in your Inkling code)." %}
	</div>
	
	<div role="tabpanel" class="tab-pane" id="randomness">
		<p>This section allows you to configure the settings for the random number generator used in each simulation run.</p>
		<p>Using a random seed value results in unique simulation runs (when the model involves stochasticity), providing different experiences to the RL algorithms across its training, even for the same actions.</p>
		
		{% include tip.html content="In most training scenarios, it's suggested to use a random seed." %}
		
		<p>By specifying the fixed seed value, you initialize the model's random number generator with the same value each run. This causes each simulation run to produce the same sequence of "random" values. While useful for testing purposes in simplified scenarios, it lacks the variability that is needed for an approach that considers the real-world examples.</p>
		<p>For advanced users, you can also substitute AnyLogic's default Random class used with your own generator.</p>
	</div>
</div>
