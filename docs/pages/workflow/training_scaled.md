---
title: Training Scaled
permalink: training_scaled.html
summary: "By uploading your RL-ready model to Azure, Bonsai can scale your model to drastically reduce train times."
---

To start training brains, the simulation model can either be hosted from your local machine or scaled on the Azure platform -- this page focuses on the latter, referred to as *"uploaded"* or *"scaled"* training here; Bonsai refers to the simulation models in this case being *"managed"*.

## About

For efficient brain training, Bonsai has built-in support for using up to hundreds of parallel simulation models. All you need to do is export your <a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.rl_ready_model}}">RL-ready simulation model</a> to a zip file (via the RL Experiment) and upload it to the Bonsai UI. 

{% include note.html content="Behind the scenes, your model will get put inside a Docker image and stored as part of your Azure subscription." %}

![Communication cycle during locally hosted training](./images/model-bonsai-communication-upload.jpg)

After uploading your model, you can configure settings related to the hardware used for training (under the properties of the Simulator in the Bonsai UI). 

## Instructions

{% include warning.html content="The Bonsai documentation on this topic - [Add a training simulator to your Bonsai workspace](https://docs.microsoft.com/en-us/bonsai/guides/add-simulator?tabs=add-cli%2Ctrain-inkling&pivots=sim-platform-anylogic) - is currently outdated, as it refers to an older 'wrapper' workflow that should not be used. Bonsai-specific information is still relevant though." %}

Starting in your AnyLogic environment:

1.  In the Projects panel, under the model you wish to export for, click on the RL Experiment to view its properties.

2.  At the top of the Properties panel, click the link for **Export to Microsoft Bonsai** (if prompted to save your model, select **Yes**)

3.  In the "Export Model" dialog box, ensure the option for **Destination ZIP** is as desired and then click **Next**. The model will then export to the specified file.

    {% include tip.html content="After a successful export, click the 'Locate ZIP file' link to open your system's file explorer to where the file is saved (a small time saver when going to upload the model)." %}
	
	{% include note.html content="This zip file contains your exported model (including all of its assets) and setup to use the RL Experiment." %}
	
	{% include important.html content="A model exported from the RL Experiment has all the limitations of its edition (namely relevant for PLE) and configured to *only* work in a compatible platform, such as Bonsai. You - as the end-user - are unable to run this exported model yourself." %}

4.  Once complete, you will see the "Done" screen. Click **Finish** to close the dialog box.

Now in the Bonsai UI:

1.  From the **Simulators** section, add a new simulator, following the prompts.

2.  After uploading your model, it will need a few minutes to finish setting it up. 

3. Once ready, you can configure its hardware settings and copy the package name (to be used in your Inkling) from the Simulator's properties.

    {% include tip.html content="The settings are per instance. AnyLogic recommends using 1 core (as a single run cannot use more), memory appropriate to the complexity of the model (256MB - 1GB works well in most cases), and a max instance count appropriate to your desired resource usage." %}
