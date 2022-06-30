---
title: Locally Hosted Training
permalink: training_local.html
summary: "By using the Bonsai Connector object, you can train Bonsai brains from a single animated run that is hosted from your local machine; this is optimal for verifying everything is setup correctly."
---

To start training brains, the simulation model can either be hosted from your local machine or scaled on the Azure platform -- this page focuses on the former, referred to as *"locally hosted"* here; Bonsai refers to the simulation models in this case being *"unmanaged"*.

## About

With an <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.rl_ready_model}}">RL-ready simulation model</a>, and possibly some pre-written Inkling code, you have the option to start the training process and run through iterations on your local machine before uploading your model for scaled training.

![Communication cycle during locally hosted training](./images/model-bonsai-communication-local.jpg)

As the diagram shows, your model runs from your machine and sends/receives information from the Bonsai platform - a process automated from the end-users via the <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.bonsai_connector}}">Bonsai Connector</a> object.

When the model is setup for locally hosted training, the general execution goes as follows:

1. You launch a Simulation experiment

2. The model window appears; once run, the enabled Bonsai Connector starts to take control over your model and it does the following (automatically):

    1. Register the simulator with the Bonsai platform (waiting until it passes or stopping if it fails)
  
    2. Run your model until the <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.iteration_trigger}}">iteration trigger</a> occurs
  
    3. Pause your model and send an <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.observation}}">observation</a> to Bonsai
  
    4. Waits for a reply from Bonsai with an <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.action}}">action</a> or a <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.terminal_condition}}">terminal condition</a> 
  
    5. If an action, executes it and continues to the next iteration trigger; if a terminal indicator, stops and restarts the run

{% include important.html content="As the communication is automatically handled for you, much unlike traditional simulation runs, you should not attempt to make any meaningful interaction with the model after launching the run. Modifying the playback speed or closing the experiment (to halt it) is OK." %}

## Instructions 

{% include warning.html content="The Bonsai documentation on this topic - [Link an unmanaged simulator to Bonsai](https://docs.microsoft.com/en-us/bonsai/guides/run-a-local-sim?tabs=windows%2Ctest-with-ui&pivots=sim-lang-anylogic) - is currently outdated, as it refers to an older 'wrapper' workflow that should not be used.  Bonsai-specific information is still relevant though." %}

Start in your AnyLogic environment:

1.  In your top-level agent, verify you have a Bonsai Connector object, that it will be enabled, and is filled out with your Bonsai Workspace ID and Access Key
	
	{% include tip.html content="For details on this, see the [Bonsai Connector implementation](components_connector.html#implementation)." %}

    ![](./images/image31.png)

2.  Verify you have a Simulation experiment with the following properties:

    a.  The mode parameter (if present) is set to perform training

    b.  Under the "Model time" section, "Execution mode" is set to
        "Virtual time" & the stop time is set to "Never" (this is
        controlled by the platform)

    c.  The seed option in the "Randomness" section is assigned to your
        preferences

    ![](./images/image32.png)

    ![](./images/image33.png)

    {% include tip.html content="For instructions on creating a new Simulation experiment, see the AnyLogic Help article on the [Simulation Experiment](https://anylogic.help/anylogic/experiments/simulation-experiment.html)." %}

3.  Start the experiment. 

    {% include tip.html content="For instructions, see the AnyLogic Help article, [Running the model](https://anylogic.help/anylogic/running/run-simulation.html)" %}

    {% include note.html content="The Bonsai Connector will take over your model and display a 'Connecting...' message. When it has established a connection to the platform ('registered'), it will display a 'Connected!' message along with the name of your sim." %}

    ![Graphical user interface, text, application, chat or text message
Description automatically
generated](./images/image34.png)

    {% include warning.html content="At this point, do not make any meaningful interactions with the model." %}

4.  Switch to the Bonsai portal. You should see your locally hosted model listed under the "Simulators" section (possibly at the end). Clicking on it will show information about it. 

    ![Example](./images/image35.png)

    ![Example](./images/image36.png)

7.  Prepare a new brain or configure an existing one to your preferences. For help, consult the [Inkling Basics](https://docs.microsoft.com/en-us/bonsai/inkling/). 

8. Once your training regimen is ready, click the green "Train" button. In the pop-up, select your simulator under the "Unmanaged Simulators" section that matches both in name and appropriate timestamp for when it connected.

    ![](./images/smg_image32.png)

9.  After some time (typically under a minute) training will commence. On the simulation side, you'll see the simulation animation starting, ending, and restarting automatically. After a while you'll be able to see the results of the training under the "Train" tab in Bonsai.

{% include note.html content="When training a new brain or a new version of a brain, the first few simulation runs may be shorter than you dictated (only lasting 1-5 iterations). This is normal. Bonsai is taking samples of your observation to determine the algorithm to use." %}

{% include note.html content="Occasional pauses should be expected. During this time, the algorithms are updating themselves in the backend." %}

As previously stated, this method of training is only capable of running one simulation at a time (i.e., sequential episodes) and should be primarily used for debugging purposes or to be able to visually monitor the training process. For scaling the training process, it's advised to upload your model to Azure -- a process described in the next section.