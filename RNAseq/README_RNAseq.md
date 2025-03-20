# BINF3630_SP25
Data and analyses for Bioinformatics Spring 2025

**Choose a sample **

| SampleIdentifier | Tissues | Treatment | Genotype |
|-------------|------------|-------------|------------|
| mdg_017 | Root and Leaf| Watered and Drought | Hybrid |
| mdg_018 | Root and Leaf | Watered and Drought | Hybrid |
| mdg_019 | Root and Leaf | Watered and Drought | Hybrid |
| mdg_020 | Root and Leaf | Watered and Drought | Hybrid |
| mdg_021 | Root and Leaf | Watered and Drought | Hybrid |
| mdg_021 | Root | Watered and Drought | Hybrid |
| mdg_023 | Root and Leaf | Watered and Drought | Hybrid |
| mdg_024 | Root and Leaf | Watered and Drought | Hybrid |

**Make a directory that's for your work**
``` bash
# go to the project folder
cd /anvil/projects/x-bio250083/
# make a directory based on your ACCESS user name
mkdir -p YOURUSERNAME
# go into that folder
cd YOURUSERNAME
```

**Editing, copying, and running scripts**
``` bash
# Run an example script
# Copy an example script
cp /anvil/projects/x-bio250083/examples/example.sh /anvil/projects/x-bio250083/YOURUSERNAME
# check to see it's there
ls
# check its contents
less example.sh
# edit it
nano example.sh
# run it
sbatch example.sh
# while it's running, check it's status and the status of any other jobs you're running
squeue -u$USER
```

**Preparing the preprocessing script for your sample**
``` bash
cd /anvil/projects/x-bio250083/YOURUSERNAME
# add the first script - open BINF_1_RNAseq_preprocess.sh and copy its contents
nano BINF_1_RNAseq_preprocess.sh
# paste in the code
# IMPORTANT! - make the necessary changes for your files and directories!!!
```

**Running the preprocessing script**
``` bash
# running the script
sbatch BINF_1_RNAseq_preprocess.sh
```

**Repeat for each BINF_x script**


