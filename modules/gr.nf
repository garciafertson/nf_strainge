
process prepare_ref{
  cpus '1'
  time '10h'
  module 'conda'
  input:
     path(gsttsv)
     path(refgenome)
     path(simtsv)
  output:
    path("refs_concat.fasta"), emit: concat_fasta
    path("refs_concat.meta.json"), emit: md
  script:
    """
    source activate ${params.conda_env}
    echo ${gsttsv}
    straingr prepare-ref \\
     -s *.strains.tsv \\
     -p \"${refgenome}/{ref}.fa.gz\" \\
     -S ${simtsv} \\
     -o refs_concat.fasta
    """
}

process align{
  cpus '4'
  time '10h'
  module 'conda'
  input:
    tuple val(x), path(reads), path(fasta)
  output:
    tuple val(x), path("${x.id}.bam*"), emit: bam
  script:
    """
    source activate ${params.conda_env}
    bwa index ${fasta}
    bwa mem -I 300 -t 4 \\
    ${fasta} \\
    ${reads[0]} ${reads[1]} \\
    | samtools sort -@ 4 -O BAM -o ${x.id}.bam 

    # Also create BAM index
    samtools index ${x.id}.bam
    """
}
 
process variant_call{
  cpus '1'
  time '10h'
  module 'conda'
  publishDir "strainge/variants", mode:"copy"
  input:
    tuple val(x), path(bam)
    path(fasta)
    path(meta)
  output:
    tuple val(x), path("${x.id}.hdf5"), emit: sample_hdf5
    path ("${x.id}.tsv"), emit: variant_tsv 

  script:
    """
    source activate ${params.conda_env}
    straingr call ${fasta} ${x.id}.bam \\
    --hdf5-out ${x.id}.hdf5 \\
    --summary ${x.id}.tsv \\
    --tracks all
    """
}





