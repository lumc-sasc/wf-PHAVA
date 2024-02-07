process LINKED_ADAPERS {

    input:
    tuple val(meta), path(fwd_primer)
    tuple val(meta), path(rev_primer)

    
    
    output:
    tuple val(string), path("linked_adapter") :emit, linked_adapter
    
    script:
    """
    #!/usr/bin/env python
    from Bio.Seq import Seq

    def fwd_rev_to_linked_adapter(fwd_primer, rev_primer):
        
        fwd_primer_clean = fwd_primer.strip()
        rev_primer_clean = rev_primer.strip()
        fwd_primer_seq = Seq(fwd_primer_clean)
        fwd_primer_revcomp = fwd_primer_seq.reverse_complement()

        linked_adapter = "^{}...{}$".format(rev_primer, fwd_primer_revcomp )

        return linked_adapter

    if __name__ == '__main__':
        linked_adapter = fwd_rev_to_linked_adapter(${fwd_primer}, ${rev_primer})
        adapter_file = open ("linked_adapter", "w")
        adapter_file.write(linked_adapter)
        adapter_file.close()
        print(linked_adapter)
    """

}