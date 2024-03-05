def CSV_READ(samples) {
    read_list = []
    samples.each{ instance ->
        println "Processing instance: $instance"
        id = "${instance.GENE_NAME}_${instance.SAMPLE_ID}"
        sample = "${instance.SAMPLE_ID}"
        read1 = instance.PATH

        read_list << [[id : id, single_end: true, sample: sample], [file("${read1}", checkIfExists: true)]]
            
    }

    return read_list
}