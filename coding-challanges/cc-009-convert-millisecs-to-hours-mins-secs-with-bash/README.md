# Coding Challenge - 09 : Convert Milliseconds into Hours, Minutes, and Seconds with Bash Scripting

Purpose of the this coding challenge is to write program that converts the given milliseconds into hours, minutes, and secondsin bash scripting.

## Learning Outcomes

At the end of the this coding challenge, students will be able to;

- analyze a problem, identify and apply programming knowledge for appropriate solution.

- apply arithmetic operations on basic data types in Bash Scripting.

- demonstrate their knowledge of string manipulations and formatting in Bash Scripting.

- demonstrate their knowledge of algorithmic design principles by using function effectively.

   
## Problem Statement

- Write program that converts the given milliseconds into hours, minutes, and seconds in bash scripting. The program should convert only from milliseconds to hours/minutes/seconds, not vice versa and during the conversion following notes should be taken into consideration.


```
- Program accepts one parameter, the positive integer number that represents the seconds count we want to convert.

- It will print on screen the converted values only if they are not 0. 

- If the resulting days is 0, it will not print the text for days at all.

- Example for user inputs and respective outputs
```

$ source ./convertTime.sh

$ convertAndPrintSeconds ```10```

```10 seconds```

$ convertAndPrintSeconds ```100```

```1 minutes and 40 seconds```

$ convertAndPrintSeconds ```1000```

```16 minutes and 40 seconds```

$ convertAndPrintSeconds ```1000000```

```11 days 13 hours 46 minutes and 40 seconds```

```