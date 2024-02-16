nextflow.enable.dsl=2    
    
    //include all processes and scripts
    include {FASTQC as FastQC} from "modules/nf-core/fastqc/main.nf"
    include {MULTIQC as MultiQc} from "modules/nf-core/multiqc/main.nf"
    include {CUTADAPT as Cutadapt_1} from "modules/nf-core/cutadapt/main.nf"
    include {CUTADAPT as Cutadapt_2} from "modules/nf-core/cutadapt/main.nf"
    include {MINIMAP2_ALIGN as MiniMap2} from "modules/nf-core/minimap2/align/main.nf"
    include {DEEPVARIANT as DeepVariant} from "modules/nf-core/deepvariant/main.nf"
    include {WHATSHAP as WhatsHap} from "modules/local/whatshap.nf"
    include {SAMTOOLS_INDEX as Samtools_Index} from "modules/nf-core/samtools/index/main.nf"
    include {GUNZIP as Gunzip_cutadapt_1} from "modules/nf-core/gunzip/main.nf" 
    include {GUNZIP as Gunzip_cutadapt_2} from "modules/nf-core/gunzip/main.nf"
    include {GUNZIP as Gunzip_deepvariant} from "modules/nf-core/gunzip/main.nf"
    include {BEDTOOLS_BAMTOBED as Bedtools_minimap2} from "modules/nf-core/bedtools/bamtobed/main.nf"
    include {CSV_READ as Csv_Read} from "modules/local/csv_reader.nf"
    include {COMBINE_CUTADAPT as Cutadapt} from "modules/local/combine_cutadapt.nf"
    //include {LINKED_ADAPERS as Linked_Adapters} from "/exports/sascstudent/yezegers/src/LGTC/PMS2/PMS2_nextflow/tasks/linked_adapters.nf"
    //include {YAML_READ as Yaml_Read} from "/exports/sascstudent/yezegers/src/LGTC/PMS2/PMS2_nextflow/backup/yaml_file_read.nf"


//"input output defining"------------------------------------------------------------------------------------------ 


    //---------------------------------YAML
    
    //YAML package is imported. This is needed to load in yml files.
    import org.yaml.snakeyaml.Yaml
    //The samples param will be loaded. These need to be queue channels
    def yaml = new Yaml()
    samples = yaml.load(new FileInputStream(new File("${params.samples}"))).samples

    //yaml to parse yaml samplesheet file.
    //read_list_yaml = Yaml_Read(file("${params.samples}", checkIfExists: true))

    //---------------------------------CSV
    //CSV_package
    @Grab( 'com.xlson.groovycsv:groovycsv:1.0' )
    import com.xlson.groovycsv.CsvParser
    //load CSV
    read_list = Csv_Read(CsvParser.parseCsv(file("${params.csv_file}", checkIfExists: true).text))


    //---------------------------------REFERENCE
    referenceFasta = [[id:"fasta"],file("${params.referenceFasta}", checkIfExists: true)]
    referenceFastaFai = [[id:"fastafai"],file("${params.referenceFastaFai}", checkIfExists: true)]


read_list_yaml = []

//each sample will be read
samples.each {sample -> sample.libraries.each {

    //each readpair will be read
    library -> library.readgroups.reads.each {
        readgroup -> 

            //reads will be stored in a variable. Read1 just gets read1 and read2 will only contain data if it is present.
            //If not it is an empty string
            read1 = readgroup.R1
            read2 = readgroup.R2 ? readgroup.R2: ""

            /* It will check if it is single_end. If read2 is not an empty string it will be added as a pair with
            read1. Otherwise only read1 will be added to the nested list.*/
            single_end = read2 != "" ? false : true
            if (read2 != "") {
            read_list_yaml << [[id: "${sample.id}_${library.id}", single_end: false, sample: "${sample.id}"],[file(read1, checkIfExists: true), file(read2, checkIfExists: true)]]
            }
            else {
                read_list_yaml << [[id: "${sample.id}_${library.id}", single_end: true,  sample: "${sample.id}"],[file(read1, checkIfExists: true)]]
            }


        }
    }
}


workflow {

    //code than generates the linked_adapter --> task.config 

    //trimming adapters first run
    Cutadapt_1(Channel.fromList(read_list))

    //trimming adapters seconnd run
    Cutadapt_2(Channel.fromList(read_list))

    //unzipping first trimming
    Gunzip_cutadapt_1(Cutadapt_1.out.reads)

    //unzipping first trimming
    Gunzip_cutadapt_2(Cutadapt_2.out.reads)

    //combining cutadapt output
    Cutadapt(Gunzip_cutadapt_1.out.gunzip.join(Gunzip_cutadapt_2.out.gunzip))

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
    
    //decompress the output vcf file of deepvariant
    Gunzip_deepvariant(DeepVariant.out.vcf)

    //phase the ouput of deepvariant with self written program
    WhatsHap(MiniMap2.out.bam.join(Samtools_Index.out.bai) ,referenceFasta, referenceFastaFai, Gunzip_deepvariant.out.gunzip)

    //run multiqc with the output of fastqc to get a total report of all the different samples
    MultiQc(FastQC.out.zip.map{it[1]}.collect(), [], [], [])

}
