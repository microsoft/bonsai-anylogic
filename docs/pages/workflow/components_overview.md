---
title: Components Overview
permalink: components_overview.html
summary: "A brief, high-level overview of what's needed in an RL-ready simulation model."
---

This section discusses the components or "ingredients" that transform a traditional
simulation model to an RL-ready one: 

- the Reinforcement Learning experiment
- an iteration trigger
- the Bonsai Connector object
- optionally, what will be referred to as the "mode" parameter -- useful in the workflow of your model

The goal is for you to gain an understanding of what these ingredients are and why they are needed. Each subsection also goes over implementation details.

As a quick reference, the table below is an overview of what components are required to exist (O), should not exist (X), or is optional (~), depending on your desired case.

| Case name | RL Experiment | Code to trigger iterations | Bonsai Connector object |
|--|---------------|----------------------------|-------------------------|
| Case 0, No RL setup (default model) | ~ | X | X |
| Case 1, Locally hosted training | O | O | O |
| Case 2, Uploaded training | O | O | ~ |
| Case 3, Brain assessment | O | O | O |