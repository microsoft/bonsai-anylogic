---
title: Three use cases for RL in AnyLogic models
permalink: intro_usecases.html
summary: "There are generally three use cases for how you can use AnyLogic simulation models with the Bonsai platform. They are NOT mutually exclusive from one another within the scope of a single model or RL project."
---

## Case 1: Locally Hosted Training

The simulation model is started locally (on your machine) and used as a training environment for the AI algorithms to learn from; Bonsai refers to this as an “unmanaged simulator”. 

Once you initiate the simulation, it will connect itself to the Bonsai platform, where the machine teaching aspects of the training (e.g., Inkling code, underlying RL algorithm) live. The Bonsai platform will then step through your model and restart a new simulation run when necessary.

In this case, training is executed using the (animated) Simulation experiment. As such, you are limited to only *one* simulation run at a time (i.e., no parallel training episodes); trying to execute a parallel experiment will cause the model to throw errors. 

This setup is most suitable for being able to quickly test the overall setup and verifying the training can execute without errors. Since a practical RL training may need hundreds or thousands of simulation runs to learn from, it is recommended to use Case 2 after local debugging is finished.

## Case 2: Uploaded Training (Azure)

The simulation model is used as a training environment for the AI algoritm, with the model uploaded to, and automatically scaled on, the MS Azure platform.

In this case, the model is exported from AnyLogic (using a specialized experiment type for Reinforcement Learning) and uploaded to Azure via the Bonsai UI. Behind-the-scenes, Bonsai will wrap the model in a Docker image. This allows the Bonsai platform to spawn multiple instances, enabling the AI algorithms to learn from multiple parallel simulations and drastically shortening the training time. 

Uploading the simulation model consumes some storage on your Azure account and running parallel simulations consumes computation resources. Because of this, it’s recommended to first go through Case 1. In reserving initial tests and debugging for the first case, it reduces the likelihood of additional time and costs being used on small mistakes.

## Case 3: Brain Assessment

The simulation model is used as a testbed for a trained brain, allowing you to observe the brain's performance.

To do this requires a partially or fully trained brain. Bonsai has built-in assessment capabilities, allowing you to configure custom scenarios (similar to ones setup during training) and see analytically how the brain performed. You can also export the brain, putting it in a "frozen" state - where it won't continue to learn/change - and request actions from any application (e.g., in AnyLogic). 

From the reference of the simulation model, the brain is called the same way as it was during training.

Bonsai’s built-in assessment feature is ideal for cases when you want to quickly evaluate the trained brain before you decide to export it. For the purposes of this guide, the assumption will be assessments are desired to be performed via an exported brain, as more rigorous testing is possible, and you will need to do this anyway to use the brain externally.

## Other remarks

It makes sense to go through all of the use cases sequentially: initially verifying a working setup through hosting your simulation model locally (“locally hosted training”) before uploading to scale on Azure (“uploaded training”), and then finally exporting a brain to test its performance on a wide range of scenarios (“assessment”). 

However, similar to building simulation models, performing RL can be an iterative process and you may wish to go between cases, including the scenario of running the model without any RL interaction! 

{% include image.html file="workflow-example.png" url="./images/workflow-example.png" alt="Example workflow" caption="Example workflow that incorporates all 3 'use cases'" %}

Because there are some components and code required to use specific cases, what you *need* in the model is different depending on your desired setup. 

{% include note.html content="There's a simple way to easily switch between using the model in different cases - an idea discussed further in the Components section." %}

As a quick reference, the table below is an overview of what components are required to exist (O), should not exist (X), or is optional (~), depending on your desired case.

| Case name | RL Experiment | Code to trigger iterations | Bonsai Connector object |
|--|---------------|----------------------------|-------------------------|
| Case 0, No RL setup (default model) | ~ | X | X |
| Case 1, Locally hosted training | O | O | O |
| Case 2, Uploaded training | O | O | ~ |
| Case 3, Brain assessment | O | O | O |

For more, consult the [Components](components_overview.html) section.
