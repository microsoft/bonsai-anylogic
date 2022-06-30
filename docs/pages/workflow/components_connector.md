---
title: Bonsai Connector Object/Library
permalink: components_connector.html
summary: "The Bonsai Connector Object allows you to easily setup locally hosted training and to test exported brains."
---

## About

The Bonsai Connector (or simply "connector") is part of the custom
Bonsai Library add-on for AnyLogic which allows you to perform locally
hosted RL training; it also has a built-in way of calling an exported
brain for assessment purposes (for post-training analysis) - an option
called "Playback". 

As AnyLogic does not have RL algorithms built into it, executing the RL
Experiment is not possible through the development environment (unlike
any of the other experiment types). Thus, the Bonsai Connector provides
a way to bridge the connection between your locally executing simulation
model and the Bonsai platform, where the training algorithms and regimen
resides.

{% include warning.html content="Locally hosted training can only be done with the Simulation experiment, where one simulation run is executed at a time; attempting to perform any type of headless experiment (e.g., Monte Carlo) will result in a runtime error." %}

By launching a Simulation experiment with the connector added to your
top-level agent and set to be enabled, it will take control over of your
model. It executes the simulation runs based on the commands it receives
from the Bonsai platform (e.g., starting a new run, stepping through
iterations, terminating the current run).

{% include tip.html content="Even though the connector's purpose is only applicable to locally hosted training, it's safe to include if/when the model is uploaded to the Bonsai platform for scaled training. The connector is setup to detect this and will automatically disable itself, allowing Bonsai's native backend code to directly control the model." %}

## Implementation

The Bonsai Connector is part of the custom Bonsai Library, allowing you
to preform locally hosted training and to call exported brains.

### Prerequisites

- You have the Bonsai Library added to your AnyLogic environment.

	- You can download the jar from the bonsai-anylogic GitHub ([direct link](https://github.com/microsoft/bonsai-anylogic/blob/master/connector/BonsaiLibrary.jar)) and install it using the instructions from the AnyLogic Help article, [Managing Libraries](https://anylogic.help/advanced/libraries/managing-libraries.html).
	
- You have a Bonsai workspace provisioned, and have the workspace ID and an access key

	- For provisioning a workspace, see [Microsoft account setup for Bonsai](https://docs.microsoft.com/en-us/bonsai/guides/account-setup)
	- For generating an access key (and seeing your workspace ID), see [Get your workspace access key](https://docs.microsoft.com/en-us/bonsai/cookbook/get-access-key)

### Steps

1.  In the top-level agent (e.g., Main), drag in an instance of the
    Bonsai Connector from the Bonsai Library

    <img src="./images/image21.png" style="width:5in;height:3.56601in"
alt="Graphical user interface, application Description automatically generated" />

2.  In the properties of the added object, there are the following sections to fill out:

    <img src="./images/image23.png" style="width:6in;height:2.64997in" />

    a.  **Enable connector**: If enabled, the connector will take control over your model on startup.

    b.  **Enable logging**: If enabled, logging will be printed to the AnyLogic console about the communication to Bonsai.

    c.  **Playback**: If enabled, the connector will attempt to query an exported brain for an action, rather than Bonsai platform; keep disabled during training. Enabling it exposes the field **Exported brain address**, allowing you to input the prediction endpoint to the exported brain.

    d.  **Workspace ID** and **Access key**: Your Bonsai credentials, inputted as Java strings (in double quotes). See the references in the prerequisites section above for how to obtain these.

    e.  **Simulator name**: A name (does not need to be unique) for how to identify your locally hosted simulation model when you connect to it from the Bonsai UI.

    f.  **Timeout**: The number of seconds Bonsai should try to keep a connection to your locally hosted model before dropping it. The default -- 60 seconds -- is adequate in most cases.
	
{% include tip.html content="You can switch the checkbox fields to code fields by clicking on the equal sign ('=') and selecting 'Static value'. Any code field can be used to reference model parameters or setup to be conditional statements. This technique is utilized as part of the workflow with the [Mode parameter](components_parameter.html)." %}