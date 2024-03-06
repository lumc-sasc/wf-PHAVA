process COMBINE_CUTADAPT {

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("${prefix}_combined_trimmed.fq"), emit: combined_fastq
    
    script:
    prefix = task.ext.prefix ?: "${meta.id}" 
    
    """
    cat ${fastq_1} ${fastq_2}  > ${prefix}_combined_trimmed.fq 
    """

}
