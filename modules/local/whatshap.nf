process WHATSHAP {

    input:
    tuple val(meta), path(reads), path(read_index)
    tuple val(meta3), path(reference)
    tuple val(meta4), path(reference_index)
    tuple val(meta5), path(vcf)
    
    output:
    tuple val(meta), path("*.vcf"), emit: phased_vcf
    
    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}" 
    
    """
    whatshap phase $args -o ${prefix}.phased.vcf --reference=$reference $vcf $reads
    """

}
