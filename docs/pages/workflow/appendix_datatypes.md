---
title: Allowed data types for the RL Experiment
permalink: appendix_datatypes.html
summary: "The data types you use in the RL Experiment can be anything which is JSON serializable; as many AnyLogic classes (including agents) are not, you can create 'wrapper' classes as a workaround."
---

In general, the variables which comprise the Configuration, Observation,
and Action need to be types that are JSON-serializable (for a list, see
the w3schools article on [JSON Data Types](https://www.w3schools.com/js/js_json_datatypes.asp)).

{% include note.html content="In the RL Experiment's tables, under the 'Type' column, the
dropdown only lists integers (**int**), floating-point numbers
(**double**), and 1-D double arrays (**double[]**). However, you can
simply type in your desired data type." %}

For Bonsai specifically, it must follow Inkling's [supported data
types](https://docs.microsoft.com/en-us/bonsai/inkling/types/). In
essence, this means that variables can be one of three classifications:
numeric (**int**, **double**), fixed-sized arrays (e.g., **int[]**,
**double[][]**), or classes (objects comprised of any combination of
these three classifications).

{% include warning.html content="When using multi-dimensional arrays, be aware that Java is 'row major'
but Inkling is 'column major'. In essence, the way they are declared is
reversed. For example, if you have 3 sets of 2-length arrays -- such as
\[\[0, 1\], \[2, 2\], \[3, 4\]\] -- this would be *declared* as int\[3\]\[2\] in
Java but as number\[2\]\[3\] in Inkling. As of writing, they are
*accessed* in the same way as in Java." %}

To make Java classes JSON-serializable -- specifically with the Jackson
library -- there are two simple requirements:

1.  You must define an empty constructor. Others may be defined as well,
    however Jackson will need the empty option.

2.  Define your desired fields as class variables and set their
    visibility to be **public**.

While AnyLogic agent types are technically Java classes, they are not
JSON-serializable on their own. To resolve this, you can create a
"wrapper" class, taking the agent instance as input. You can then fill
out the class fields based on the agent's properties in the constructor
(shown in the example below).

```java
/**
	JSON-serializable class for the Person agent type
**/
public class PersonWrapper {
	// declare data types and set some default values
	public double age = 0.0;
	public int is_male = 0;
	public int fav_color_composite = 0;

	public PersonWrapper() {}

	public PersonWrapper(Person person) {
		age = person.age;
		is_male = person.isMale ? 1 : 0;
		fav_color_composite = person.favoriteColor.getRGB();

	}
}
```

{% include tip.html content="Java classes can be added by right clicking your model name (in the Projects panel) > New > Java class" %}