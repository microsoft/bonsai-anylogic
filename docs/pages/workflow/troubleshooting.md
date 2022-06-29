---
title: Troubleshooting
permalink: troubleshooting.html
summary: "Context and solutions to various common errors (inside of AnyLogic and the Bonsai UI), primarily listed based on the error message."
---

### "Simulator halted execution before the episode was complete"

#### Problem

This happens in the Bonsai UI and gets reported when an episode ends, containing this message.

<img src="./images/image103.png" style="width:6.14003in;height:1.20969in" />

#### Cause 

When this occurs, it is typically because a terminal or episode-ending
condition was triggered by the simulation, and not the Inkling code.
Currently, Bonsai only supports terminal conditions being set from the
Inkling.

Some common, episode-ending sources in a simulation model may include:

-   A call to the finishSimulation function

-   The RL experiment’s field “Simulation run stop condition” has some
    condition set

-   The RL experiment has the model time stopping at a certain time or
    date

-   A model error occurred

-   The simulation model tried to run past the limitations of the
    edition it was exported from (e.g., a pedestrian model exported from
    AnyLogic PLE tried to run for more than 1 hour)

#### Solution

Ensure that only the Inkling code will terminate the
simulation. The following are some suggestions:

-   Perform a [text search in your
    model](https://anylogic.help/anylogic/ui/searching-text-strings.html)
    for “finishSimulation”; if results are found, ensure that the
    function is only called when not training a brain

-   Check that the “Simulation run stop condition” is set to false and
    that the stop mode is set to “Never” (as shown in the image below)

<img src="./images/image104.png" style="width:2.51042in;height:1.52227in" alt="Graphical user interface, text, application Description automatically generated" />

-   Check that errors did not occur. For locally hosted training, check
    the AnyLogic Console; for uploaded training, check the logs (see
    **Checking Logs of Uploaded Simulation Models**).

### “This block works only with simulation experiments.”

#### Problem

This happens inside AnyLogic when trying to run an AnyLogic experiment
in a headless mode with the Bonsai Connector object enabled. 

#### Cause

At this
time, you can only perform RL training in a Simulation-type (i.e.,
animated) experiment.

#### Solution

If you are trying to execute an experiment with your
traditional model (i.e., without any RL component), ensure the Bonsai
Connector object is disabled before executing.

### “Error in the model during iteration \[#\]”

#### Problem 

This happens inside AnyLogic when trying to execute a *multi-run* AnyLogic experiment with the Bonsai Connector enabled. 

#### Cause

At this time, you can only perform locally-hosted RL training with a Simulation-type (i.e., animated, single-run) experiment.

#### Solution 

If you are trying to execute an experiment with your
traditional model (i.e., without any RL component), ensure the Bonsai
Connector object is disabled before executing.

### “The model should contain Reinforcement Learning Experiment defining Observation, Action, and other data - to be run with pretrained learning agent.”

#### Problem

This happens inside AnyLogic after attempting to start a locally hosted training. 

#### Cause

This happens when your model has the Bonsai Connector object and an
iteration trigger (i.e., a call to \`takeAction\`) but no RL experiment.

#### Solution

Define a new RL experiment. For more information, see the page on the [RL Experiment](components_rlexperiment.html).

### “The model should define the learning agent interface. …”

#### Problem

This happens inside AnyLogic after attempting to start a locally hosted training.

#### Cause

This happens when your model has the RL experiment and an iteration
trigger (i.e., a call to `takeAction`) but no Bonsai Connector object.

#### Solution

Add the Bonsai Connector object to your model (available
as part of the Bonsai Connector Library).

This object is necessary when performing locally hosted training in
order to gain access to the Bonsai platform. For more information, see
the page on the [Bonsai connector](components_connector.html).

### “Connecting to Bonsai” loops indefinitely (locally hosted training)

#### Problem

In a locally hosted training (from within AnyLogic), the Bonsai platform is never
connected to.

#### Cause

There are many reasons why this might occur; typically it’s due to a
problem with AnyLogic not being able to register as a valid client to
the Bonsai platform. Check the AnyLogic console and see if there are any
error messages or reasons for this.

Errors from the Connector will have lines typically starting with some
form of “Exception”. The image below shows the type of exception
highlighted in yellow with the exception message highlighted in blue.

<img src="./images/image105.png" style="width:6.5in;height:1.0916in" />

Errors from Bonsai (in response to what was sent to it) will typically
have some 4xx or 5xx error codes (as shown highlighted in the image
below).

<img src="./images/image106.png"
style="width:5.20833in;height:0.66595in" />

#### Solution

If the errors look like the ones shown above, check that
your workspace ID and access key are correct. The first example was the
result of invalid characters being in the workspace ID – you can see in
the second line that the default “\<YOUR_WORKSPACE_ID\>” was not
changed. The second example was the result of the access key being
incorrect - error 403; you may see error 401 if your workspace ID is
incorrect.

Otherwise, the problem may be a connection problem. You may wish to wait
a few minutes and try again.

### “State value received … is missing a value for var\[#\]”

#### Problem

This error shows up in the Bonsai UI during training. 

#### Cause

It occurs when a variable in your
observation/state contains an array that was not initialized. When this
happens, it gets set to the Java keyword “null” and causes a “null
pointer exception” when Bonsai attempts to index the array.

{% include note.html content="You can tell Bonsai cannot query the first observation by the
“Previous state” being empty." %}

<img src="./images/image107.png" style="width:6.5in;height:1.81944in" />

One scenario where this might happen is if you simultaneously declare
and initialize an array based on some condition. In this example, the
“recent_history” array was only declared and initialized when a dataset
had some variables. At the simulation start, the dataset would have a
size of 0 and thus the array would not be declared, hence the error.

<img src="./images/image108.png" style="width:3.07463in;height:2.9049in" />

#### Solution

In the code for your Observation, ensure all arrays are
declared first, before assigning values based on some condition.

With arrays containing only numerical types, you only need to declare
the array. Java will default all values to 0, thus preventing any values
being set to null. An example of this can be seen below.

<img src="./images/image109.png" style="width:4.77573in;height:1.89552in" />

With arrays containing Java classes, you need to both declare the array
and ensure all values are not set to null. This is important to note, as
Java will default the individual values to null. In other words, if you
only declare the array with its size (e.g., \`my_var = new
MyClass\[5\];\`), the array will no longer be null, but the objects
inside of it will be. This needs to be resolved, otherwise a similar
error will be thrown in Bonsai.

### Uploaded model executing at 0 iterations per second

#### Problem

After uploading a model to Bonsai and initiating a training, instances are created but the iteration rate reports that no iterations are occurring. An example can be seen in the image below.

<img src="./images/image110.png" style="width:1.5623in;height:2.5101in" />

#### Cause 

This problem may have multiple reasons why it’s occurring:

- No iterations are triggered from the simulation model

- The simulation model is encountering errors on model startup or before the first iteration

- The Bonsai brain is performing some internal updates or calculations

#### Solutions

Check that your logic is correctly setup such that the iterations are being triggered. If you are using the “mode” parameter:

- Ensure it gets set to the desired value corresponding to brain training; set the parameter's value in the RL Experiment's Configuration code field (e.g., `root.mode = 1;`). 
- Double-check that the specific value you assign is aligned with the options specified in the parameter's properties and any conditional statements you have to trigger the iterations.

While in most cases, Bonsai should warn you if you're model is terminating early, startup errors or in certain edge cases, they may "slip by" this mechanism. Check the logs to see any model errors. For instructions, refer to [Checking Console Logs of Running Simulation Models](appendix_check-logs.html).

{% include note.html content="When checking the logs, you may see messages related to Chromium missing; this is reported as an error but is insignificant and can be safely ignored." %}

Separate from your model, the "problem" may also be on Bonsai’s side. Try waiting a few minutes to see whether this problem persists. For example, at the start of training and during updates, the rate may show 0 as there is some long-running backend code being executed.

### "X cannot be resolved to a type"

#### Problem

This is a compilation error that shows in AnyLogic when you try to run a model. Here, "X" may refer to some variable name (conventionally lowercased) or a reference to a class (conventionally title-cased; e.g., Observation, RLExperiment, ObjectMapper).

#### Cause

In essence, AnyLogic (i.e., Java) cannot figure out what "X" *is*.

If it's a variable, or a reference to an object in your model, it may be mistyped.

If it's a class, it needs to be imported.

{% include note.html content="For context: In object-oriented languages, like Java, a *class* is used to define the blueprint of an object ('fun' fact: behind the scenes, all AnyLogic agents are classes!). Classes in Java are bundled together into *packages* to organize them; they essentially function similar to folders on your computer.

    To call upon a class from an external package (i.e., one provided from a library), you need to import it. For most common classes, AnyLogic does this for you, but sometimes you need to manually import it." %}
	
#### Solution

If the reference is to a variable, check the spelling or that the named object exists.

{% include tip.html content="You can use the built-in search feature to check for references. More details can be found on the AnyLogic help article, [Searching text strings](https://anylogic.help/anylogic/ui/searching-text-strings.html#searching-text-strings)." %}

If it's a class, you'll need to add it to the agent's **Imports** code field (under its properties > Advanced Java). 

The following is how to fix it, with pictures from an example:

<img src="./images/how2import-import_empty.jpg"/>

<img src="./images/how2import-problem.jpg"/>

1. Find where in your model that "X" is referenced

2. Put your cursor immediately after the last character in the name

    <img src="./images/how2import-cursor.jpg"/>

3. Call the code-completion by pressing Ctrl + Space

4. If the completion windows appears, select the class from the intended package (by double clicking or arrow-down + press enter)

    {% include tip.html content="To identify which options refer to classes, look for the entries with the icon of a green circle and a white 'C'." %}
	
	<img src="./images/how2import-codecompletion.jpg"/>

5. AnyLogic should automatically import the class. Check the imports section or re-build the model to confirm the error message goes away.

    <img src="./images/how2import-import_filled.jpg"/>


### (My problem isn't covered here!)

If encountering a problem that wasn't covered here, you have a few resources:

For Bonsai-specific issues:

- First check the "Troubleshooting" section of [Bonsai's documentation](https://docs.microsoft.com/en-us/bonsai/)
- Try posting on the [Bonsai Community Forum](https://techcommunity.microsoft.com/t5/autonomous-systems/ct-p/ProjectBonsai)

For AnyLogic-specific issues, there are both community and official support options available. Read more at [anylogic.com/resources/support](https://www.anylogic.com/resources/support/).