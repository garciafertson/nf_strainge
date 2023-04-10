//
// main workflow run stringr in shotgun metagenoic samlpes .
//

nextflow.enable.dsl=2

include {DATABASE}  from './workflows/strainge'
include {STRAINGST} from './workflows/strainge'
//include {STRAINGR} from './workflows/strainge'

//select step for stringe pipeline

workflow NF_STRAINGE {
   if (params.step=="DATABASE") {
        DATABASE()
        }
   else if (params.step=="STRAINGST"){
        STRAINGST()
        }
   else if (params.step=="STRAINGR"){
        STRAINGR()
        }
}


//     WORKFLOW: Execute a single named workflow for the pipeline

workflow {
    NF_STRAINGE ()
}
