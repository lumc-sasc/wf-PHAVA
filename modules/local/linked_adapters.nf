#!/usr/bin/env nextflow

process LINKED_ADAPERS {

    input:
    val(fwd_primer)
    val(rev_primer)

    
    """
    #!/usr/bin/env python3
    from Bio.Seq import Seq

    def fwd_rev_to_linked_adapter(fwd_primer, rev_primer):
        
        fwd_primer_clean = fwd_primer.strip()
        rev_primer_clean = rev_primer.strip()
        fwd_primer_seq = Seq(fwd_primer_clean)
        fwd_primer_revcomp = fwd_primer_seq.reverse_complement()
        rev_primer_seq = Seq(rev_primer_clean)
        rev_primer_revcomp = rev_primer_seq.reverse_complement()

        linked_adapter_1 = "^{}...{}\$".format(rev_primer_clean, fwd_primer_revcomp)
        linked_adapter_2 = "^{}...{}\$".format(fwd_primer_clean, rev_primer_revcomp)

        return linked_adapter_1, linked_adapter_2 

    if __name__ == '__main__':
        ${params.linked_adapter_1}, ${params.linked_adapter_2} = fwd_rev_to_linked_adapter("${fwd_primer}", "${rev_primer}")
    """
    
}