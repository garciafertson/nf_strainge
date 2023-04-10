#Nextflow Pipeline For building Gene catalog from Shotgun metagenomic sequences
The pipelines performs the following steps:
 1) Reads cleaning and quality filtering
 2) Sequence assembly from paired end or single end shotgun sequencing samples
 2) gene prediction on assembled seqences using Prodigal
 3) Filtering predicted gene  sequences shorter than 100 bp
 4) Sequence clustering using cd-hit with the following parameters  -n 5 -g 1 -c 0.95 -G 0 -M 0 -d 0 -aS 0.9 

The output folder "gene_catalogue" stores the cd-hit ouput with the representative sequences and the cluster file
The representative output sequences conserve the name from the prodigal output, which in turn comes from the contig names
assigned during the assembly step and reflect the sample of origin, 

options for running the pipeline
--input		Path to shotgun sequencing samples
--single_end	(Optional) Use if the shotgun sequencing samples are single end
--iontorrent	(Optional) Use if the Shotgun sequencing samples were produced with ion torrent sequencing technology

#Example for running from the command line

~/bin/nextflow run ~/repositories/nf_genecatalogue/ \
    -with-tower  \
    -c ~/repositories/nf_genecatalogue/configs/uppmax.config \
    --project project_id \
    --input "test_samples/*gz" \
    --single_end true \
    --iontorrent true 


