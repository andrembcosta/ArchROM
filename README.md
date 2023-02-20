# ArchROM
Reduced-Order model for dynamics of slender archs subject to cyclic loads.

## Table of Contents

- [Installation](#installation)
- [Theory](#theory)
- [Usage](#usage)
  - [Extracting POD basis from high-fidelity simulations.](#extracting-basis)
  - [Using POD basis](#using-pod-basis)
- [Highlights](#highlights)
- [Examples](#examples)
- [Acknoledgments](#acknoledgments)

# Installation
<sup>[(Back to top)](#table-of-contents)</sup>

It just requires MATLAB, version 2015 or newer is recommended.

# Theory
<sup>[(Back to top)](#table-of-contents)</sup>

Reduced-order models are carefully designed simplifications of a high-fidelity model for a phenomena, which are made to reduce the complexity and computational cost of the solution process. They can be extremely useful when a large amount of analysis need to be performed, such as in probabilitic or parametric studies.

In this program, we implement a reduced-order model for structural dynamics of slender arches, based on the Pricipal orthogonal decomposition (POD) method. 
The process consists of selecting a few high-fidelity examples of the structural dynamics, which are likely to represent all major characteristics of the response. For example, in our application of interest, we included stable, small amplitude, periodic responses, as well as unstable (snap-through buckling), periodic and chaotic cases, with large amplitudes. These examples form the training set of the learning procedure. 

The training of the model consists of extracting the modes of deformation with higher singular values of these high-fidelity simulations. They are then combined and redundant modes are removed. These modes are then passed to a smoothing function, resposible for creating piecewise polynomial approximations, which are fed to a Galerkin-type solver as basis functions. The polynomial approximations are particular useful to simplify the integration procedure needed in the Galerkin solver. 

This solver is then capable of performing the same type of simulations as the high-fidelity model, using this special basis functions. For the time discretization, the HHT-alpha method is used, to suppress numerical oscillations. Compared to the high-fidelity model the speed-up achieve is of the order of 20 times, and that is comparing an optimized C++ solver in the high-fidelity case with this prototype MATLAB code. If proper optimization and parallelization of the MATLAB code is performed, we may be able to achieve 100x speed-ups. 

<p align="middle">

<!-- ![Snap](probability%20of%20snap.png) -->
<img src="img/periodic_response.PNG" width="450" height="350"/>

<!-- ![Snap](probability%20of%20snap.png) -->
<img src="img/chaotic_response.PNG" width="450" height="350"/>

</p>

Accuracy comparison: The reduced order model, in red, achieves great accuracy for periodic solutions and reasonable qualitative accuracy for chaotic cases compared to the high-fidelity simulation in blue.

# Usage
<sup>[(Back to top)](#table-of-contents)</sup>

The function Lowrankapproximation takes the name of the datafile containing the results of the high-fidelity simulation. Some examples of datafiles for reference are located in the "FE_results" folder. This function will parse the data, generate the matrices with the times series of each degree-of-freedom and perform the singular value decoposition, from which the POD modes are extracted. The modes are output to the parameter V1.

To obtain good accuracy, modes of different response must be combined in a matrix. Don't forget to remove redundant modes after this step. With this matrix, all that is needed is to launch the ROMsolverHHT function, passing the matrix of modes as a parameter, as well as the element size used in the high-fidelity examples, and the loading conditions (initial velocity, amplitude and frequency). This function then calls the other subfunctions to perform the numerical tasks and returns the simulated time series in the paramter Du_mid. (this is the displacement of the midpoint of the arch, other output parameters can be computed if necessary)


## Extracting basis
<sup>[(Back to top)](#table-of-contents)</sup>

Show example

## Using POD basis
<sup>[(Back to top)](#table-of-contents)</sup>

Show example

# Highlights

add highlights

# Applications

Probabilistic snap-through boundary of a circular arch. The x axis represents the frequencies and the y axis the amplitudes of the applied loads. The colors show the likelyhood of stability loss (snap-through buckling). This type of study can be very expensive with a high-fidelity model. The ROM allows one to perform this analysis quickly in a laptop.

<!-- ![Snap](probability%20of%20snap.png) -->
<img src="probability%20of%20snap.png" width="500" height="380"/>

# Acknoledgments

I am extremely grateful to professor Ilinca Stanciulescu, who supervised this work during the Summer of 2016 and introduced me to the world of Computational Mechanics. She was also responsible for writing the recommendation letters that got me a chance to attend Graduate School at Duke, for which I am even more grateful. 

She passed away in 2021 and I hope this repository serve to remember how important she was for my journey in this field and my career as a whole.

https://www.dignitymemorial.com/obituaries/tumwater-wa/ilinca-stanciulescu-panea-10081541

<!-- ![Trapz Image](img/trapezoidIntegration.gif) -->
<img src="img/trapezoidIntegration.gif" width="400" height="300"/>

<!-- ![Monte-Carlo Image](img/monteCarloIntegration.gif) -->
<img src="img/monteCarloIntegration.gif" width="400" height="300"/>

<!-- ![Gradient Image](img/gradientDescent.gif) -->
<img src="img/gradientDescent.gif" width="400" height="300"/>
