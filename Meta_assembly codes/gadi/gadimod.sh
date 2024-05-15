
source ~/.bashrc

export TMPDIR=${PBS_JOBFS:-/tmp}
conda activate snakemake

export PATH=$PATH:/scratch/rh35/hg9845/Softwares_I/MEGAHIT-1.2.9-Linux-x86_64-static/bin

export PATH=$PATH:/scratch/rh35/hg9845/Softwares_I/SPAdes-3.15.5-Linux/bin

