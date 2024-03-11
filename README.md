# olivelab-rnaseq
Files pertaining to the single-end Illumina bulk RNA sequencing pipeline used by the Olive Research Group at Michigan State University.

This pipeline utilizes Snakemake v7.32.4 for workflow management. Raw fastq files are assessed for quality using FastQC v0.12.1 and MultiQC v1.17.
Reads are mapped to the reference genome using Bowtie2 v2.5.1. Read counts are produced by the FeatureCounts function in the Subread package v2.0.6.

Components:
- Snakefile: main snakemake workflow
- config.yaml: configuration file (enter sample names, bowtie2 index, and reference genome for annotation here)
- snakemake_env.yml: Conda environment for the associated pipeline (MUST be loaded and activated using Conda prior to running pipeline)
- data directory: where all raw data and processed data subdirectories will be stored
- logs: where all error logs will be stored
- resources: contains a configuration file for SLURM cluster computing configuration
