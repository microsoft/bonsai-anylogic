---
title: Usage on AnyLogic Cloud
permalink: testing_cloud.html
summary: "You can upload a model to the AnyLogic Cloud (conditions apply) and expose the URL endpoint to a brain. Doing this enables faster results and opens experimentation to users with access to the model."
---

### Requirements

You will need the following before continuing:

-   You must have have access to AnyLogic Private Cloud or a AnyLogic Public Cloud subscription
	
	{% include note.html content="This is due to the fact the external communication from the Cloud environment is needed (to contact the brain)" %}
	
-   You have a trained brain which has been exported to a web app

    {% include note.html content="For more information, read the exporting section of [Querying exported brains](testing_querying.html#exporting-a-brain)" %}

-   You have added the Bonsai Connector or a function for contacting the brain

    {% include note.html content="The choice of which is dependent on whether you want to run the model in a headless mode. For more information, read [Querying exported brains](testing_querying.html)." %}

### Implementation

To start, decide whether the playback URL (of your exported brain) should be fixed or dynamic. 

To make it modifiable without needing to upload another version of the model, you should add a String parameter to your top-level agent representing the URL and specify the parameter as the value for the "Exported brain address" option in the Bonsai Connector. 

![](./images/image47.png)

Next, open the Cloud's "Run Configurations" for the model desired to upload. Drag over any inputs that should be changed from their default values or that you wish to make configurable by end-users. 

In this example, we'll want to change the defaults for the Bonsai mode and the playback URL.

![](./images/image48.png)

Next, upload the model to the AnyLogic Cloud by clicking the "Export model" option from the **Properties** panel of the **Run Configuration** or by right clicking the **Run Configuration** option in the **Projects** panel \> Export model to AnyLogic Cloud.

After uploading, you may wish to change the default options of the inputs or toggle their visibility. To do this, start by clicking on the experiment. You'll be shown the available inputs. Modify these as you would like the default values in this experiment. 

For this example, the option for "Playback" mode was chosen and the brain address was modified from the generic default.

{% include note.html content="The option for 'Training' is present as a leftover from the values entered in the model. However, you cannot perform training from the AnyLogic Cloud at this time." %}

{% include tip.html content="The field for the exported brain should not have any quotations around it." %}

After you've updated the settings, click the save button, as shown below.

![](./images/image49.png)

As a final step, you may wish to hide these options from the end-user. Doing this will preserve their settings that you chose in the previous step. 

To do this, click on the pencil button to edit the dashboard. Then, click on the open eye icons next to the inputs you wish to hide. Finally, click on one of the options for saving the dashboard.

![](./images/image50.png)

For this example, it was desired to hide the Bonsai mode (so that end-users could not be confused by the "Training" option) but make the brain address visible in case others want to try their own exported brain.