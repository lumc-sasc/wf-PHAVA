# wf-PHAVA
Nextflow pipeline for Pacbio Hifi Amplicon Variantcalling Analysis(PHAVA)

# Pipeline
Workflow overview.

# Requirements
Nextflow (>23.04.4) and Singularity are required to run this pipeline. Both can be installed using Conda. To download Conda, follow this [tutorial](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html). Check that Conda is up-to-date:

`conda --version`

```plaintext
conda 23.9.0
```

You can install Nextflow using [Bioconda](https://bioconda.github.io/), after setting up the proper channels: `conda install -c bioconda nextflow`

Or a specific version: `conda install -c bioconda nextflow=23.10.1`

Make sure to install Singularity from conda-forge and not bioconda, as conda-forge has a more recent version:

`conda install -c conda-forge singularity=3.8.6`

Check the version of the programs to confirm you have a decently up-to-date program:

`nextflow -version`

```plaintext
      N E X T F L O W
      version 23.10.1 build 5891
      created 12-01-2024 22:01 UTC (23:01 CEST)
      cite doi:10.1038/nbt.3820
      http://nextflow.io
```

`singularity --version`

```plaintext
singularity version 3.8.6
```

# Usage
To download the repository use: `git clone https://github.com/lumc-sasc/wf-PHAVA.git`

Running the pipeline can be done by using the `nextflow run main.nf` command *after mandatory parameters have been provided.*
TBA: add mandatory parameters.

# Future work
This project is currently ongoing.

# Authors
This pipeline was originally made by Youp Zegers ([@youpze](https://github.com/youpze)) for his BSc internship in Bioinformatics. The pipeline uses modules from [nf-core](https://github.com/nf-core/modules) in addition to local modules.
