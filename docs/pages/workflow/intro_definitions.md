---
title: Definitions
permalink: intro_definitions.html
summary: "A brief definition of terms used throughout this guide, phrased in such that a way that caters to a simulation-oriented audience."
---

| Term | Definition |
| ---- | ---------- |
| Reinforcement Learning (“RL”) | A type of machine learning where an AI algorithm can interact with some virtual environment, by performing some actions and receiving feedback (both about the environment and the actions); it tries to learn an optimal control policy to choose optimal actions in a given circumstance. |
| Brain | The eventual output of RL; a trained AI policy that can be queried for a (theoretically optimal) output based on a provided input. |
| Inkling | The programming language used on the Bonsai platform for training brains. It is used to define what the AI should learn and its training regimen. |
| Traditional or Default model | A simulation model without any RL components. |
| RL-ready model | A simulation model that has the components necessary to be used as the training environment for an AI algorithm. |
| Episode | A single simulation run, from start to finish; used in the context of training. |
| Configuration | A set of variables that define a scenario or starting condition for each episode. |
| Observation | A set of variables that describe the environment at a given point in time. This is the input to the AI algorithm. |
| State | For the purpose of this guide, synonymous with Observation. |
| Action | A set of variables that the AI algorithm has control over in the environment. This is the output of the AI algorithm. |
| Terminal [condition] | A (boolean) flag or indicator for when to end an episode, allowing another to begin.  |
| Iteration | The process of taking an observation from the simulation, using it to query the AI algorithm (the brain) for an action and applying the action. |
| Iteration trigger | An event inside the simulation model that pauses the simulation model and initiates an iteration, after which the simulation model resumes.  |
| Bonsai Library | An AnyLogic plugin/add-on library giving access to the Bonsai Connector object. |
| Bonsai Connector | An object necessary to be added to your top-level agent for communicating with the Bonsai platform for locally hosted training. |
| Locally hosted training | Performing RL training with the simulation model hosted on your local machine. |
| Uploaded training | Performing RL training with the simulation model uploaded to Microsoft Azure, allowing training to be scaled. |
| Assessment | The act of evaluating a brain’s performance across a number of episodes. |
| Playback | A feature in the Bonsai Connector, allowing connection to an exported brain for assessment purposes. |