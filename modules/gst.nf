process kmerize_sample{
  cpus '8'
  time '10h'
  module 'conda'
  publishDir("strainge/gst")
  input:
    tuple val(x), path(reads)
  output:
    tuple val(x), path("${x.id}.hdf5"), emit: hdf5
  script:
    """
    source activate ${params.conda_env}
    straingst kmerize -k 23 -o ${x.id}.hdf5 ${reads[0]} ${reads[1]}
    """
}

process gstrun{
  cpus '8'
  time '10h'
  module 'conda'
  publishDir 'strainge/gst', mode:"copy"
  input:
    tuple val(x), path(hdf5)
    path(pangenome)
  output:
    path("*strains.tsv"), emit: strains
    path("*stats.tsv"),  emit: stats
  script:
    """
    source activate ${params.conda_env}
    straingst run -O -o ${x.id} ${pangenome} ${hdf5}
    """
}

