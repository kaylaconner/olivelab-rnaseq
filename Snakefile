configfile: "config.yaml"
fastqc_input=expand("data/{filename}.fastq.gz", filename=config["samples"])
fastqc_output=expand("data/fastqc/{filename}_fastqc.html", filename=config["samples"])
fastqc_output2=expand("data/fastqc/{filename}_fastqc.zip", filename=config["samples"])
multiqc_output="multiqc_report.html"
bowtie2_output=expand("data/mapped/{filename}.sam", filename=config["samples"])
sample=config["samples"]
#featurecounts_output=expand("data/counts/{filename}_counts.txt", filename=config["samples"])
mapping_index=config["bowtie2_index"]
refgen=config["reference_genome"]
featurecounts_output="data/counts/rawcounts.txt"

rule all:
    input:
        fastqc_output,
        fastqc_output2,
        multiqc_output,
        featurecounts_output,
        bowtie2_output
        
rule fastqc:
    input:
        fastqc_input
    output:
        fastqc_output,
        fastqc_output2
    resources:
        runtime=60,
        mem_mb=8000,
        nodes=2,
        slurm_extra="-e ./logs/fastqc/%j.err -o ./logs/fastqc/%j.out"
    shell:
        "fastqc {input} -o data/fastqc"
    
rule multiqc:
    input:
        fastqc_output
    output:
        "multiqc_report.html"
    resources:
        runtime=60,
        mem_mb=8000,
        nodes=2,
        slurm_extra="-e ./logs/multiqc/%j.err -o ./logs/multiqc/%j.out"
    shell:
        "multiqc data"
        
rule bowtie2:
    input:
        r1="data/{sample}.fastq.gz"
    output:
        out="data/mapped/{sample}.sam"
    threads: 16
    resources:
        runtime=300,
        mem_mb=16000,
        nodes=6,
        slurm_extra="-e ./logs/bowtie2/%j.err -o ./logs/bowtie2/%j.out"
    shell:
        "bowtie2 -q -p {threads} --local -x {mapping_index} -U {input.r1} -S {output.out}"

rule counts:
    input:
        sam=expand("data/mapped/{sample}.sam", sample=sample)
    output:
        countout="data/counts/rawcounts.txt"
    log:
        "logs/counts/featurecounts.log"
    threads: 8
    resources:
        runtime=60,
        mem_mb=8000,
        nodes=2,
        slurm_extra="-e ./logs/counts/%j.err -o ./logs/counts/%j.out"
    params:
        extra = "-F 'GTF' -t 'exon' -g 'gene_id' -s 0 -T 8"
    shell:
        "featureCounts -a {refgen} -o {output.countout} {input.sam} > {log}"
