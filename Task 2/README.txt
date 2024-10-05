Task 2

There are two main files; DC_main.m and AC_main.m

AC_main.m refers to the Task2.1, the Newton-Raphson method implementations.

To start, run the AC_main.m. Next, you must choose between 14 and 118 IEEE bus test case data. Input 14 or 188.
If you enter other number (not 14 or 118) then the program will ask you to re-enter the input.
An additional script is used to perform calculation of line flow and line loss as well as display of an output. The script is called loadflow.m. Two additional functions are used to transform from polar to rectangular form and vice versa.

The output of the program has the following format:
| Bus |    V   |  Angle  |     Injection      |     Generation     |          Load      |
| No  |   pu   |  Degree |    MW   |   MVar   |    MW   |  Mvar    |     MW     |  MVar |

and line flow:

|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |
|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |

Number of iteration is stored in variable Iter. The accuracy limit can be set in code line 59 "while (Tol > 1e-10)"




Dc_main.m refers to the Task2.2, the DC power flow method implementations.
To start, run the DC_main.m. Next, you must choose between 14 and 118 IEEE bus test case data. Input 14 or 188.
If you enter other number (not 14 or 118) then the program will ask you to re-enter the input.
No additional scripts are used for this code.

The output format :
| Bus |    V   |  Angle  |     Generation     |          Load      |
| No  |   pu   |  Degree |     MW   |  Mvar    |     MW     |  MVar |

and line flow:

|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |
|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |


