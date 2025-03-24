# BINF3630_SP25
Data and analyses for Bioinformatics Spring 2025

**Choose a sample **

| SampleIdentifier | Tissues | Treatment | Genotype |
|-------------|------------|-------------|------------|
| mdg_017 | Root and Leaf| Watered | Hybrid |
| mdg_018 | Root and Leaf | Watered | Hybrid |
| mdg_019 | Root and Leaf | Watered | Hybrid |
| mdg_020 | Root and Leaf | Watered | Hybrid |
| mdg_021 | Root and Leaf | Drought | Hybrid |
| mdg_022 | Root | Drought | Hybrid |
| mdg_023 | Root and Leaf | Drought | Hybrid |
| mdg_024 | Root and Leaf | Drought | Hybrid |

**Go to your scratch directory**
``` bash
# go to scratch
cd $SCRATCH
# make the RNAseq directory
mkdir RNAseq
# go into that directory
cd RNAseq
# copy the .sh files in to that directory
cp /anvil/projects/x-bio250083/RNAseq_sh_files/*.sh ./
```

**Editing for your sample name**
``` bash
nano BINF_1_RNAseq_preprocessing.sh
## Change your sample name - everything else should stay the same
## SAMPLE_NAME="mdg_017_L_S17_L004"  # <<< EDIT THIS FOR OTHER SAMPLES
# Save the nano file close it
```

**Run the script**
``` bash
sbatch BINF_1_RNAseq_preprocessing.sh
squeue -u$USER
```

**Once the **
``` bash

```

**Repeat for each BINF_x script**


