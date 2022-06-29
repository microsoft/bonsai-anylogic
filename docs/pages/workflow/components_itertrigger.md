---
title: Iteration trigger
permalink: components_itertrigger.html
summary: "The iteration trigger is used to request actions from the RL algorithms."
---

## About

As an RL-ready simulation model delegates some of its decisions to a
learning algorithm, it requires interaction to happen between the
simulation model and the RL platform during the run. The interaction
occurs on a recurring basis within a single simulation run.

These interactions are referred to as "iterations". They are initiated by the simulation via a specific function (called `takeAction`) at certain moments in its execution. During an iteration, the model sends information about its current state to the RL platform, waits for an action to take, then executes it before continuing under its predefined rules.

{% include important.html content="The name for this concept - 'iteration' - is entirely distinct from AnyLogic's use of the word. Everytime you see it referenced here, it's being used strictly in the context of RL training." %}

Generally, there are two types of events that can be associated with iterations:

1)  Events that happen in pre-defined time intervals (e.g., every 6
    hours)

2)  Specific events in the model (e.g., call-back fields of process
    blocks, condition-based events, transitions of statechart)

### Example

The picture below depicts 7 iterations taking place. 

Each consist of passing an observation to the platform (orange arrows) and receiving some response (green or red arrows). 

In the first 6 iterations, an action is sent back (green); the last one has a terminal flag sent back (red). 

The definition of what constitutes the observation and action, and what the model should do based on the action it's sent from the platform, are set in the "Observation" and "Action" sections of the RL Experiment.

<img src="./images/image8.png" />

## Implementation

To provoke an iteration at the desired moment for the RL algorithms to take an action, you will need to call a specific function of the RL Experiment, called `takeAction`.

1.  If you haven't already, add a Reinforcement Learning Experiment to your model (it can be empty for now). This is done exactly like any other experiment and described in detail on step 1 of implementing the [RL Experiment](components_rlexperiment.html#implementation) page.
2.  In the code field where you want to trigger the iteration, call the `takeAction` function of the RL experiment's class and pass the current agent (via the Java keyword `this`) as the sole argument.
	- For example, if you called the RL experiment "MyRLExp", you would have `MyRLExp.takeAction(this)`
	- Another example, using the default RL experiment name, can be seen in the image below.

<img src="./images/image20.png" />

During runtime, when `takeAction` is called, AnyLogic will schedule the model to pause and request an action after the active code field that triggered the iteration.

{% include tip.html content="Due to the internal mechanism of how events work, to avoid any conflict, it's recommended to have a dedicated event for this function and to perform any event-sensitive actions separately. More information can be found on the page [Order of Events with the \`takeAction\` function](appendix_iteration-events.html)." %}

{% include tip.html content="For more information about creating events, see the AnyLogic help article titled ['Events'](https://anylogic.help/anylogic/statecharts/events.html#event)." %}