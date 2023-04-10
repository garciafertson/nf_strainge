process refgenomes{
  cpus '1'
  time '10h'
  module 'conda'
  //publishDir "strainge/ref_genomes/"
  input:
    val(x)
  output:
    path("ref_genomes/human_readable"), emit: refgenomedir
  script:
    """
    source activate ${params.conda_env}

    mkdir ref_genomes
    ncbi-genome-download bacteria \\
      -g \"${x}\" \\
      -H -F all \\
      -o ref_genomes \\
      -l complete

    """
}

process strainge_db{
  cpus '1'
  time '10h'
  module 'conda'
  publishDir "strainge/ref_genomes/"
  input:
    path(refgenomedir)
   output:
    path("references_meta.tsv"), emit: ref_genome_meta
    path("*fa.gz"), emit: ref_genome_fna
  script:
    """
    source activate ${params.conda_env}

    prepare_strainge_db.py $refgenomedir \\
    -s -o . \\
    > references_meta.tsv
    """
}

process kmerize_ref{
  cpus '1'
  time '10h'
  module 'conda'
  input:
    path(fasta)
  output:
    path("*.hdf5"), emit: hdf5_kmer

  script:
    x=fasta.getSimpleName()
    """
    source activate ${params.conda_env}

    straingst kmerize -o ${x}.hdf5 ${fasta}
    """
}

process cluster {
  cpus '4'
  time '10h'
  module 'conda'
  publishDir "strainge/ref_genomes/", mode: "copy"
 input:
    path(hdf5)
  output:
    path("pan-genome-db.hdf5"), emit: pangenome_kmer
    path("similarities.tsv"), emit: sim
  script:
    """
    source activate ${params.conda_env}

    straingst kmersim --all-vs-all \\
      -t 4 -S jaccard \\
      -S subset *.hdf5 \\
      > similarities.tsv

    straingst cluster -i similarities.tsv \\
    -d -C 0.99 -c 0.90 \\
    --clusters-out clusters.tsv \\
    *.hdf5 > references_to_keep.txt

    straingst createdb -f references_to_keep.txt -o pan-genome-db.hdf5

    """
}

    
