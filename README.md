# L-System Extension for Sketchup

## What is an L-System
A quick introduction of L-Systems: [http://en.wikipedia.org/wiki/Lsystem](http://en.wikipedia.org/wiki/Lsystem)  
The inventor (Lindenmayer) helped write a great book "The Algorithmic Beauty of Plants" available at: [http://algorithmicbotany.org/papers/abop/abop.pdf](http://algorithmicbotany.org/papers/abop/abop.pdf)


## What does this Extension do?
Based on settings in the Sketchup "Extensions"->"Run L-System" popup input box it will execute the user specified L-System. It first makes a new rectangular "beam" component based on Width and Length parameters. This component will get a new instantiation per step of the L-System. It will be translated, rotated, and shrunk appropriately as it is copied. The resulting L-System run will be in a new group.

## What do all the parameters mean?
![Parameters GUI](/screenshots/parameters.png)
```
Circle Angle Splits: angle used by +,- alphabet commands determined by how much a full circle is divided (ie 4 = 90°)
Iters: number of times to iterate through the initial axiom
Length: length of a step
Width: width of rectangle "beam" component
Multiplier: multiplies by how much a line will grow or shrink based on >,< alphabet commands
Alpha Limit: per iter if the alphabet size has grown bigger than this stop iteration
Axiom: the initial axiom (see below for alphabet/rules syntax)
Rules: L-System rules (see below for alphabet/rules syntax)
```

## Alphabet syntax
```
  F	Moves forward one step making component instance
  f	Moves forward one step but does not make component instance
  +	Changes the angle in a counter clockwise direction.
  -	Changes the angle in a clockwise direction.
  |	Turns 180°
  <	Multiplies the current line length by Multiplier
  >	Divide the current line length by Multiplier
  [	Create a branch
  ]	End branch and return to its parent
```

## Rule syntax
```
"F F[+F]F[-F]F" means F->F[+F]F[-F]F, the space implies the "->"

Random rules can also be implemented:
"F F[+F][-F]F F[-F]F F[+F]F 0.5 0.3 0.2" means F with probability 0.5 will become "F[+F][-F]F", with probability 0.3 will become "F[-F]F", and with probability 0.2 become "F[+F]F"
```

## Cool examples
The default startup settings cause just a simple twig like structure to be made.

### Random spiking tree thing
```
16
5
6
1
0.95
30000
F
F F[+F][-F]F F[-F]F F[+F]F 0.5 0.3 0.2
```
![Random Tree in SketchUp](/screenshots/randomTree.png)

### Levy C Curve
```
8
10
6
1
0.95
30000
F
F +F--F+
```
![Levy C Curve in SketchUp](/screenshots/Levy.png)

### Penrose
```
10
6
10
1
0.95
30000
+WF--XF---YF--ZF
W YF++ZF----XF[-YF----WF]++
X +YF--ZF[---WF--XF]+
Y -WF++XF[+++YF++ZF]-
Z --YF++++WF[+ZF++++XF]--XF
F
```
![Penrose Tiling in SketchUp](/screenshots/Penrose.png)

### Doily
```
12
3
6
1
0.95
30000
F--F--F--F--F--F
F -F[--F--F]++F--F+
```
![Doily in SketchUp](/screenshots/Doily.png)
