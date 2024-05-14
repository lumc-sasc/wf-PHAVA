# Nextflow pipeline for Pacbio Hifi Amplicon Variant calling Analysis (PHAVA)
PHAVA is designed to call variants in "dark" parts of the genome using PacBio Hifi amplicon data. 
For PHAVA, nf-core models are used to incorporate tools into the pipeline. The used modules of nf-core are part of the repository, but can also be found here: [nf-core modelules](https://nf-co.re/modules).

## Pipeline Overview
![Pipeline Overview](https://github.com/lumc-sasc/wf-PHAVA/blob/main/docs/Opzet_pipeline_algemeen.drawio.png)

# Requirements
Nextflow (23.10.1) and Singularity (3.8.6) are required to run this pipeline. Both can be installed using Conda. To download Conda, follow this [tutorial](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html). Check that Conda is up-to-date.

`conda --version`

```plaintext
conda 24.1.2
```

You can install Nextflow using [Bioconda](https://bioconda.github.io/), after setting up the proper channels: 

`conda install -c bioconda nextflow`

Or a specific version:

`conda install -c bioconda nextflow=23.10.1`

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

# Downloading the repository
To download the repository, use: 
```plaintext
git clone https://github.com/lumc-sasc/wf-PHAVA.git
```

# Mandatory parameters
The [parameters.config](https://github.com/lumc-sasc/wf-PHAVA/blob/main/config/parameters.config) contains all mandatory parameters.

Linked adapters are required to run the pipeline. The Python tool [make_linked_adapters.py](https://github.com/lumc-sasc/wf-PHAVA/blob/main/bin/make_linked_adapter.py) can be used to make the linked adapters. In the main, the forward primer (f_p) and reverse primer (r_p) can be specified. Running the main function will print two linked adapters, which can be used for the linked_adapter_1 and linked_adapter_2 mandatory inputs. The order doesn't matter.

The CSV file contains three columns: gene name, sample ID, and path to the file. Per gene, multiple samples can be specified, as presented below:

```plaintext
GENE_NAME,SAMPLE_ID,PATH
GENE,SAMPLE_1,PATH_TO_SAMPLE_1
GENE,SAMPLE_2,PATH_TO_SAMPLE_2
```

The rest of the mandatory parameters consist of only a path:

```plaintext
outdir = "outdir"
referenceFasta = "genome.fasta"
referenceFastaFai = "genome.fasta.fai"
```
Additionally, extra settings per process can be added in the [task.config](https://github.com/lumc-sasc/wf-PHAVA/blob/main/config/task.config) file. The extra settings can be added to the `ext.args` variable per process. Furthermore, standard settings like memory or CPUs can be added per process. 


# Executing tool
To execute the Nextflow pipeline, the following command is used:

`nextflow run main.nf`

To resume the pipeline, the following command is used:

`nextflow run main.nf -resume`


# Authors
This pipeline was originally made by Youp Zegers ([@youpze](https://github.com/youpze)) for his BSc internship in bioinformatics.
