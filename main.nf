nextflow.enable.dsl=2    
    
    //include all processes and scripts
    include {FASTQC as FastQC} from "./modules/nf-core/fastqc/main.nf"
    include {MULTIQC as MultiQc} from "./modules/nf-core/multiqc/main.nf"
    include {CUTADAPT as Cutadapt_1} from "./modules/nf-core/cutadapt/main.nf"
    include {CUTADAPT as Cutadapt_2} from "./modules/nf-core/cutadapt/main.nf"
    include {MINIMAP2_ALIGN as MiniMap2} from "./modules/nf-core/minimap2/align/main.nf"
    include {DEEPVARIANT as DeepVariant} from "./modules/nf-core/deepvariant/main.nf"
    include {WHATSHAP as WhatsHap} from "./modules/local/whatshap.nf"
    include {SAMTOOLS_INDEX as Samtools_Index} from "./modules/nf-core/samtools/index/main.nf"
    include {BEDTOOLS_BAMTOBED as Bedtools_minimap2} from "./modules/nf-core/bedtools/bamtobed/main.nf"
    include {CSV_READ as Csv_Read} from "./lib/csv_reader.nf"
    include {COMBINE_CUTADAPT as Cutadapt} from "./modules/local/combine_cutadapt.nf"
  

//"input output defining"------------------------------------------------------------------------------------------ 


    //---------------------------------CSV

    //CSV_package
    @Grab( 'com.xlson.groovycsv:groovycsv:1.0' )
    import com.xlson.groovycsv.CsvParser

    //load CSV
    read_list = Csv_Read(CsvParser.parseCsv(file("${params.csv_file}", checkIfExists: true).text))


    //---------------------------------REFERENCE
    referenceFasta = [[id:"fasta"],file("${params.referenceFasta}", checkIfExists: true)]
    referenceFastaFai = [[id:"fastafai"],file("${params.referenceFastaFai}", checkIfExists: true)]


workflow {

    //trimming adapters first run
    Cutadapt_1(Channel.fromList(read_list))

    //trimming adapters seconnd run
    Cutadapt_2(Channel.fromList(read_list))

    //combining cutadapt output
    Cutadapt(Cutadapt_1.out.reads.join(Cutadapt_2.out.reads))

    //quality control with trimmed reads
    FastQC(Cutadapt.out.combined_fastq)

    //run the alignment of the reads with minimap2
    MiniMap2(Cutadapt.out.combined_fastq, referenceFasta, true, false, false)

    //index the aligned reads output from minimap2 for deepvariant
    Samtools_Index(MiniMap2.out.bam)

    //making a bed file to run deepvariant
    Bedtools_minimap2(MiniMap2.out.bam)

    //run the variantcalling with deepvariant
    DeepVariant(MiniMap2.out.bam.join(Samtools_Index.out.bai).join(Bedtools_minimap2.out.bed), referenceFasta, referenceFastaFai, [[],[]])

    //phase the ouput of deepvariant with self written program
    WhatsHap(MiniMap2.out.bam.join(Samtools_Index.out.bai) ,referenceFasta, referenceFastaFai, DeepVariant.out.vcf)

    //run multiqc with the output of fastqc to get a total report of all the different samples
    MultiQc(FastQC.out.zip.map{it[1]}.collect(), [], [], [])

}
