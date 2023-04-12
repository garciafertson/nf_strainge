/*
General workflow, assembly SRA-NCBI-id_samples included in text list
*/

//import modules
include {fastp}             	from  "../modules/clean"
include {refgenomes}       	from  "../modules/database"
include {strainge_db}  		from  "../modules/database"
include {kmerize_ref} 		from  "../modules/database"
include {cluster} 		from  "../modules/database"
include {kmerize_sample} 	from  "../modules/gst"
include {gstrun} 		from  "../modules/gst"
include {prepare_ref} 		from  "../modules/gr"
include {align} 		from  "../modules/gr"
include {variant_call} 		from  "../modules/gr"


//run metagenomic assembly pipeline using megahit

workflow DATABASE {
  species=Channel.from(params.species)

  refgenomes(species)
  refgenomedir=refgenomes.out.refgenomedir

  strainge_db(refgenomedir)
  refgenomefna=strainge_db.out.ref_genome_fna
  refgenomefna=refgenomefna.flatten()

  kmerize_ref(refgenomefna)
  hdf5_ref=kmerize_ref.out.hdf5_kmer.collect()

  cluster(hdf5_ref)
}


workflow STRAINGST {
  Channel
    .fromFilePairs(params.input, size: params.single_end ? 1 : 2)
    .ifEmpty { exit 1, "Cant find reads matching: ${params.input}\nNB: enclosed Path in quotes!\n If SE --single_end option." }
    .map { row ->
           def meta = [:]
           meta.id           = row[0]
           meta.group        = 0
           meta.single_end   = params.single_end
           return [ meta, row[1] ]
                }
    .set { ch_raw_short_reads }

  fastp(ch_raw_short_reads)
  fastq_trimmed=fastp.out.reads
  fastq_trimmcp=fastp.out.reads

  kmerize_sample(fastq_trimmed)
  hdf5_sample=kmerize_sample.out.hdf5
  pangenome=Channel.fromPath(params.db)
  pangenome=pangenome.collect()

  gstrun(hdf5_sample, pangenome)
  strainstsv=gstrun.out.strains
  strainstsv=strainstsv.collect()
  refgenomedir=Channel.fromPath(params.ref_genomes)
  //refgenomedir=refgenomedir.collect()
  simtsv=Channel.fromPath(params.similarity)
  //simtsv=simtsv.collect()
  stats=gstrun.out.stats
  
  prepare_ref(strainstsv,refgenomedir, simtsv)
  concat_fasta=prepare_ref.out.concat_fasta
  concat_fascp=prepare_ref.out.concat_fasta
  md=prepare_ref.out.md
  md=md.collect()
  concat_fascp=concat_fascp.collect()
  align_input=fastq_trimmcp.combine(concat_fasta)

  align(align_input)
  bam=align.out.bam

  variant_call(bam, concat_fascp, md)

}



workflow STRAINGR {
  Channel
    .fromFilePairs(params.input, size: params.single_end ? 1 : 2)
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.input}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
    .map { row ->
           def meta = [:]
           meta.id           = row[0]
           meta.group        = 0
           meta.single_end   = params.single_end
           return [ meta, row[1] ]
                }
    .set { ch_raw_short_reads }

  fastp(ch_raw_short_reads)
  fastq_trimmed=fastp.out.reads

}
