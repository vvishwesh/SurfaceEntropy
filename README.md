# SurfaceEntropy

The software presented here is a **SH**ape-based **A**ccurate **P**redictor of **E**ntropy (SHAPE). The calculation takes place in two steps (1) Calculation of the molecular surface and the curvature properties (shape index and curvedness) at each vertex in the triangulation (2) Computation of entropy by binning the curvatures. 

## Usage
The `Software`directory contains the **LINUX** executable `GENSURF` and an **R** (https://www.r-project.org/) script `calculate_surface_shape_entropy.R` to help with the (i) creation of the molecular surface and (ii) the entropy computation. The starting point for the computation is the preparation of the 3D structure of the small molecule in `pqr` format. The user can use `OpenBabel` (http://openbabel.org/wiki/Main_Page) for generation of the 3D structure and format interconversion.  

```
Usage:GENSURF [options]

Options:
  -h[elp]          display this helpful message
  -v[ersion]       display the program's version number
  -lig file        input molecule pqr file
  -x3d             output surface in X3D format
  -off             output surface in OFF format
  -addh            add hydrogens to the surface definition [default: false]
  -sigma value     surface smoothness [default: 0.3]
  -prop value      SI/CURV/ALL
  -iso value       isosurface value [default: 1.0]
  -n value         number of grid points [default: 60]
  -reduce          reduce surface triangulation
  -grid value      extend Cartesian grid [default: 2.0]
  -ofile           outputfile [default: inherit name from ligand]
```

### R installation
For the Ubuntu 18.04 server
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
sudo apt update
sudo apt install r-base
```

### Molecular Surface Property Calculation
`GENSURF` accepts `pqr` files as input and generates an output file (`.srf` extension) containing the surface triangulation and shape properties calculated at the vertices.  
Surface generation and shape property calculations can be carried out as follows: 

`./GENSURF -lig Examples/paracetamol.pqr -sigma 0.1 -prop ALL -n 90 -reduce -iso 1.0`

The above command generates a `paracetamol.srf` file which acts as input for the entropy computation script. `GENSURF` does not include hydrogens in the surface definition. To add hydrogens to the surface, run the following command:

`./GENSURF -lig Examples/paracetamol.pqr -sigma 0.1 -prop ALL -n 90 -reduce -iso 1.0 -addh`

If the user is interested in visualizing the color-coded molecular surface, `GENSURF` outputs files for visualization in 2 formats: X3D and OFF and can be visualized using 3D mesh software such as `MeshLab` (https://www.meshlab.net/).

`./GENSURF -lig Examples/paracetamol.pqr -x3d -sigma 0.1 -prop CURV -n 60`

`./GENSURF -lig Examples/paracetamol.pqr -x3d -sigma 0.1 -prop SI -n 60`

`./GENSURF -lig Examples/paracetamol.pqr -off -sigma 0.1 -prop CURV -n 60`

`./GENSURF -lig Examples/paracetamol.pqr -off -sigma 0.1 -prop SI -n 60`



### Entropy Computation
The entropy computation script `calculate_surface_shape_entropy.R` takes 2 arguments (i) the `.srf` file produced the surface generation step (ii) the number of bins in the histogram. In our experiments we have found that `64` is an optimal number. 

`/usr/bin/Rscript calculate_surface_shape_entropy.R paracetamol.srf 64`

The script writes out the entropies based on the <ins>shape index</ins> and the <ins>curvedness</ins> to the console.




