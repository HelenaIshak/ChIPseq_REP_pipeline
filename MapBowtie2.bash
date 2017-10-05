#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

#Script 4 - mapping data to reference genome. Uses sbatch job 

#MAIN SCRIPT
#####SBATCH -A b2015157
#SBATCH -p core
#SBATCH -n 6
#SBATCH -t 6:00:00


function creatheFASTQ {

    #Check how many sra files are there, if more than two, put nr=2 and change both to FASTQ files which then will be concatenated.
    shopt -s nullglob
    sra_filees_array=(*.sra)                                #all files ending with .sra
    Nr_sra_filLes=${#sra_filees_array[*]}                    #amount variables existing in that array
    echo "in function - will create fastq files: im currently in the folder: $(pwd)" >> Mapping.log
    echo "Nr files: $Nr_sra_filLes" >> Mapping.log

    for i in "${sra_filees_array[@]}"
    do
        echo "SRA FILE: $i" >> Mapping.log
        #Convert SRA files to FASTQ files
        fastq-dump $i
    done

    FASTQ_nr=${i%.sra*}                                    #retain the part before .sra as FASTQ_nr

    #concatenate all the fastq files in that folder into one file.
    if [ $Nr_sra_filLes -gt 1 ]                             #if amount sra files are greater than 1
    then
        echo "There is more than one sra file, concatenate the files" >> Mapping.log
        cat *.fastq > $GEO_folder.fastq
        echo "The concatenated FASTQ file before: $i.fastq" >> Mapping.log
        FASTQ_nr=$GEO_folder
        echo "The concatenated FASTQ file after: $FASTQ_nr" >> Mapping.log
    else
        echo "There is only one SRA file" >> Mapping.log
        mv $FASTQ_nr.fastq $GEO_folder.fastq
        FASTQ_nr=$GEO_folder
    fi
    echo "The FASTQ file final name: $FASTQ_nr" >> Mapping.log
	echo "in function - fastq file(s) were created" >> Mapping.log
}
 

function fileeCHECK {
	
	filenType=$1
  echo "in function fileeCHECK, sent variable: $filenType" >> Mapping.log
	#Check if given file is created
	if [ ! -f $filenType ]
	then
    	createdFiIle="unsucessfully downloaded"
      echo "File $filenType was unsucessfully created" >> Mapping.log
    	#re-convert file to fastq file
    	#creatheFASTQ
	else
	  	FILEaSIZE=$(ls -lah $filenType | awk '{ print $5}')  #gives the file size in M (will give example 3.4G)
	  	FILEaSIZE="${FILEaSIZE%?}" #removes the last character from the string such as G or M (will give ex 3.4)
	  	#FILEaSIZE="${FILEaSIZE%%G*}" #removes the G (will give ex 3.4)
	  	echo "file size for $filenType is in size: $FILEaSIZE. Now checking if it's greater than 1" >> Mapping.log
    	if [ $(echo "$FILEaSIZE > 1" | bc) -eq 1 ]   
    	then
    		createdFiIle="sucessfully downloaded"
    		echo "file $filenType was sucessfully created" >> Mapping.log
    	else
    		createdFiIle="unsucessfully downloaded"
    		echo "file $filenType was not sucessfully created" >> Mapping.log
    	fi
	fi
}


#### MAIN SCRIPT!! ####
#proj_nr=$1
GEO_folder=$1
proj_adress_backup=$2
#proj_adress_NObackup=$4
DataType=$3
GEOs_file_name=$4

echo "proj nr: $proj_nr" > $GEO_folder/Mapping.log


#cd $proj_adress_NObackup

echo "in main window - just started script Map data. Start time:" >> Sample_folder/$GEO_folder/Mapping.log
date +"%T" >> Sample_folder/$GEO_folder/Mapping.log
echo "I'm in the folder (expected nobackup): $(pwd)" >> Sample_folder/$GEO_folder/Mapping.log
echo "will now get to Sample_folder" >> Sample_folder/$GEO_folder/Mapping.log
cd Sample_folder
echo "I'm now in the folder: $(pwd)" >> $GEO_folder/Mapping.log

echo "Folder name from script1 in script2: $GEO_folder" >> $GEO_folder/Mapping.log
cd "$GEO_folder" 
#cp ../../hg19/hg19 .  #!!!! Changed from ../../hg38.genome to hg19!!!! #copying a file from the starting folder and paste it into corrent folder (from pipeline4 to folder $GEO_folder
 
#Load programs in Uppmax
module load bioinfo-tools
module load bowtie2
module load sratools
module load samtools
module load IGVtools
module load ngsplot
module load FastQC
module load java/sun_jdk1.7.0_25


#First look if it already exist a Mapping.log and check what have been done on it, then start from there 
#Make this lastly when I'm done editing the file Mapping.log 

#reading the mapping.log file


#file_array('fastq' 'fastqc.html' 'hg19.bam' 'REP.bam' 'hg19.bam.bai' 'REP.bam.bai' 'hg19.flagstat.txt' 'REP.flagstat.txt' 'hg19.idxstats.txt' 'REP.idxstats.txt' 'hg19.wig' 'hg19.tdf' 'hg19.n1.wig' 'hg19.IntervalStats.txt' 'ngsplot_hg19' 'ngsplot_repeat')

#logFile = Mapping.log 
#while read mapping 
#do
#    if [ $mapping == "" ] 
#done < "$logFile"

echo "checking if the pipeline will map published data or user's own data" >> Mapping.log
if [ $DataType -eq 0 ]
then
    echo "pipeline is mapping published data" >> Mapping.log
    echo "SRA files will now be converted to FASTQ file" >> Mapping.log
    creatheFASTQ
    echo "calling fileeCHECK, sending variable: ${FASTQ_nr}.fastq" >> Mapping.log
    fileeCHECK ${FASTQ_nr}.fastq
    if [ $createdFiIle == "unsucessfully downloaded" ]
    then
	      echo "delete the file and re-convert file to fastq file" >> Mapping.log
        rm $filenType
        creatheFASTQ
    fi

    echo "FASTQ file is now created" >> Mapping.log
    echo "Info: $(ls -l $FASTQ_nr.fastq)" >> Mapping.log
    echo "$FASTQ_nr.fastq is done" >> Mapping.log
    echo "" >> Mapping.log

else 
    echo "pipeline is mapping user's own data" >> Mapping.log
    FASTQ_nr=$GEO_folder
    #change name from the current fastq file name to $FASTQ_nr.fastq
    old_file_name=(*.fastq)
    mv $old_file_name $FASTQ_nr.fastq  
fi



#Quality control on fastq files using FastQC
echo "Making a quality control using fastqc" >> Mapping.log
fastqc $FASTQ_nr.fastq

echo "calling fileeCHECK, sending variable: ${FASTQ_nr}_fastqc.html" >> Mapping.log
fileeCHECK ${FASTQ_nr}_fastqc.html
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "delete the file and re-convert file to fastq file" >> Mapping.log
    rm $FASTQ_nr_fastqc.html
    fastqc $FASTQ_nr.fastq
fi

echo "FASTQC file is now created." >> Mapping.log
echo "Info: $(ls -l ${FASTQ_nr}_fastqc.html)" >> Mapping.log
echo "${FASTQ_nr}_fastqc.html is done" >> Mapping.log
echo "" >> Mapping.log


# No inbetween files are created; creates only ending result sorted bam file
echo "Starting aligning $FASTQ_nr.fastq with the human reference genome:" >> Mapping.log
date +"%T" >> Mapping.log

#Aligning FASTQ files over human reference genome (hg19) using Bowtie2
bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-human-index/hg19 -U $FASTQ_nr.fastq 2> botwie2-hg19.log | samtools view -b -S - | samtools sort -o $FASTQ_nr-hg19.bam -
#first version when calling bowtie, but samtools did an update making this not work anymore and had to change to what u see above this: 
#bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-human-index/hg19 -U $FASTQ_nr.fastq 2> botwie2-hg19.log | samtools view -b -S - | samtools sort - $FASTQ_nr-hg19

#Check if bam files are created
echo "calling fileeCHECK, sending variable: ${FASTQ_nr}-hg19.bam" >> Mapping.log
fileeCHECK ${FASTQ_nr}-hg19.bam
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "file $FASTQ_nr-hg19.bam was unsucessfully created. Re-mapping it" >> Mapping.log
	rm $FASTQ_nr-hg19.bam
	bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-human-index/hg19 -U $FASTQ_nr.fastq 2> botwie2-hg19.log | samtools view -b -S - | samtools sort -o $FASTQ_nr-hg19.bam -
fi

echo "first alignment done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.bam)" >> Mapping.log
echo "$FASTQ_nr-hg19.bam is done" >> Mapping.log
echo "" >> Mapping.log


echo "Starting aligning $FASTQ_nr.fastq with the repetetive human reference genome:" >> Mapping.log
date +"%T" >> Mapping.log

#Aligning FASTQ files over repetitive human metagenome (REP) using Bowtie2
bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-repHuman-index/hsrep -U $FASTQ_nr.fastq 2> botwie2-REP.log | samtools view -b -S - | samtools sort -o $FASTQ_nr-REP.bam -
#bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-repHuman-index/hsrep -U $FASTQ_nr.fastq 2> botwie2-REP.log | samtools view -b -S - | samtools sort - $FASTQ_nr-REP

#Check if bam files are created
echo "calling fileeCHECK, sending variable: $FASTQ_nr-REP.bam" >> Mapping.log
fileeCHECK $FASTQ_nr-REP.bam
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-REP.bam file. Re-mapping it" >> Mapping.log
	rm $FASTQ_nr-REP.bam
    bowtie2 --fast-local -p 16 -x $proj_adress_backup/Bowtie2-repHuman-index/hsrep -U $FASTQ_nr.fastq 2> botwie2-REP.log | samtools view -b -S - | samtools sort -o $FASTQ_nr-REP.bam -
fi

echo "second alignment done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-REP.bam)" >> Mapping.log
echo "$FASTQ_nr-REP.bam is done"
date +"%T" >> Mapping.log
echo "" >> Mapping.log


#sra and fastq file are no longer needed, remove it
#echo "sra file and FASTQ files are no longer needed. They will therefore be removed to maximize space" >> Mapping.log
#rm *.sra
#rm *.fastq
echo "" >> Mapping.log


#Create indexed bam files (bam.bai files):
echo "will now index the bam files" >> Mapping.log
samtools index $FASTQ_nr-hg19.bam
samtools index $FASTQ_nr-REP.bam


#Check if bam.bai files are created
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.bam.bai" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.bam.bai
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.bam.bai file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.bam.bai
    samtools index $FASTQ_nr-hg19.bam
fi

echo "calling fileeCHECK, sending variable: $FASTQ_nr-REP.bam.bai" >> Mapping.log
fileeCHECK $FASTQ_nr-REP.bam.bai
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.bam.bai file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-REP.bam.bai
    samtools index $FASTQ_nr-REP.bam
fi

echo "Indexed bam files are done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.bam.bai)" >> Mapping.log
echo "$FASTQ_nr-hg19.bam.bai is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-REP.bam.bai)" >> Mapping.log
echo "$FASTQ_nr-REP.bam.bai is done" >> Mapping.log
echo "" >> Mapping.log


#This gives a simple statistics on a BAM file. Count the number of mapped/aligned reads
echo "Creating flagstat using the bam files" >> Mapping.log
samtools flagstat $FASTQ_nr-hg19.bam > $FASTQ_nr-hg19.flagstat.txt
samtools flagstat $FASTQ_nr-REP.bam > $FASTQ_nr-REP.flagstat.txt

#Check if flagstats are created 
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.flagstat.txt" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.flagstat.txt
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.flagstat.txt file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.flagstat.txt
    samtools flagstat $FASTQ_nr-hg19.bam > $FASTQ_nr-hg19.flagstat.txt
fi

echo "calling fileeCHECK, sending variable: $FASTQ_nr-REP.flagstat.txt" >> Mapping.log
fileeCHECK $FASTQ_nr-REP.flagstat.txt
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-REP.flagstat.txt file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-REP.flagstat.txt
    samtools flagstat $FASTQ_nr-REP.bam > $FASTQ_nr-REP.flagstat.txt
fi

echo "Flagstat files are done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.flagstat.txt)" >> Mapping.log
echo "$FASTQ_nr-hg19.flagstat.txt is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-REP.flagstat.txt)" >> Mapping.log
echo "$FASTQ_nr-REP.flagstat.txt is done" >> Mapping.log
echo "" >> Mapping.log


#nr of reads per chromosomes/repetitive family. Count the number of mapped/aligned reads by chromosome/repetitive family
echo "Creating idxstats using the bam files" >> Mapping.log
samtools idxstats $FASTQ_nr-hg19.bam > $FASTQ_nr-hg19.idxstats.txt
samtools idxstats $FASTQ_nr-REP.bam > $FASTQ_nr-REP.idxstats.txt

#check if idxstats are created 
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.idxstats.txt" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.idxstats.txt
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.idxstats.txt file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.idxstats.txt
    samtools idxstats $FASTQ_nr-hg19.bam > $FASTQ_nr-hg19.idxstats.txt
fi

echo "calling fileeCHECK, sending variable: $FASTQ_nr-REP.idxstats.txt" >> Mapping.log
fileeCHECK $FASTQ_nr-REP.idxstats.txt
if [ $createdFiIle == "unsucessfully downloaded" ]
then
echo "Failed creating $FASTQ_nr-REP.idxstats.txt file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-REP.idxstats.txt
    samtools idxstats $FASTQ_nr-REP.bam > $FASTQ_nr-REP.idxstats.txt
fi

echo "Flagstat files are done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.idxstats.txt)" >> Mapping.log
echo "$FASTQ_nr-hg19.idxstats.txt is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-REP.idxstats.txt)" >> Mapping.log
echo "$FASTQ_nr-REP.idxstats.txt is done" >> Mapping.log
echo "" >> Mapping.log


#bam -> tdf and wig using IGVtools. This step is only done on the sorted bam file that was aligned with whole human referens genome
echo "Will now create tdf and wig file from bam files on human reference genome:" >> Mapping.log
date +"%T" >> Mapping.log
igvtools count -z 5 -w 25 -e 250 $FASTQ_nr-hg19.bam $FASTQ_nr-hg19.tdf,$FASTQ_nr-hg19.wig hg19 > igv.log
echo "first sample is done" >> Mapping.log
date +"%T" >> Mapping.log

#Check if wig and tdf files are created
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.wig" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.wig
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.wig file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.wig
	echo "" >> igv.log
	echo "second try" >> igv.log
    igvtools count -z 5 -w 25 -e 250 $FASTQ_nr-hg19.bam $FASTQ_nr-hg19.wig hg19 >> igv.log
fi

echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.tdf" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.tdf
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.tdf file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.tdf
	echo "" >> igv.log
	echo "third try" >> igv.log
    igvtools count -z 5 -w 25 -e 250 $FASTQ_nr-hg19.bam $FASTQ_nr-hg19.tdf hg19 >> igv.log
fi

echo "TDF and WIG files are done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.wig)" >> Mapping.log
echo "$FASTQ_nr-hg19.wig is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.tdf)" >> Mapping.log
echo "$FASTQ_nr-hg19.tdf is done" >> Mapping.log
echo "" >> Mapping.log


#java-genomic-toolkit doesn't exist in uppmax. Downloaded it in Vt_ChIPseq_Pipeline. This toolkit requires Java 7 
#normalize wiggle using java-genomic-toolkit wigmath.Scale
echo "Will now normalize wig file" >> Mapping.log
$proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh wigmath.Scale -i $FASTQ_nr-hg19.wig -o $FASTQ_nr-hg19.n1.wig  > jgt.log

#CHECK normalized WIG and file 
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.n1.wig" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.n1.wig 
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.n1.wig file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.n1.wig
    $proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh wigmath.Scale -i $FASTQ_nr-hg19.wig -o $FASTQ_nr-hg19.n1.wig  > jgt.log
fi

echo "Normalized WIG file is done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.n1.wig)" >> Mapping.log
echo "$FASTQ_nr-hg19.n1.wig is done" >> Mapping.log
echo "" >> Mapping.log


#count reads in intervalls from bed files using java-genomic-toolkit
echo "Will now count reads in intervals from bed files" >> Mapping.log
repeats="$proj_adress_backup/bed/hg19_repeats.bed"
$proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh ngs.IntervalStats -s mean -l $repeats -o $FASTQ_nr-hg19.IntervalStats.txt $FASTQ_nr-hg19.n1.wig > jgt2.log

#CHECK IntervalStats file
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.IntervalStats.txt" >> Mapping.log
fileeCHECK $FASTQ_nr-hg19.IntervalStats.txt
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.IntervalStats.txt file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.IntervalStats.txt
    $proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh ngs.IntervalStats -s mean -l $repeats -o $FASTQ_nr-hg19.IntervalStats.txt $FASTQ_nr-hg19.n1.wig > jgt2.log
fi

echo "IntervalStats file is done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.IntervalStats.txt)" >> Mapping.log
echo "$FASTQ_nr-hg19.IntervalStats.txt is done" >> Mapping.log
echo "" >> Mapping.log


#ngsplot: create average gene profiles http://jura.wi.mit.edu/bio/education/hot_topics/ngsplot/ngsplot_Apr2014.pdf
#G=Genome name (hg19,mm9,...), R=Genomic regions to plot (tss, tes,genebody, exon,...), C=Bam file, O=Name of output
echo "Will now use ngsplot to create $FASTQ_nr-hg19.ngsplot" >> Mapping.log
ngs.plot.r -G hg19 -R genebody -C $FASTQ_nr-hg19.bam -O $FASTQ_nr-hg19.ngsplot

#Check if hg19.ngsplots were created
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.ngsplot.heatmap.pdf" >> Mapping.log
fileCHECK $FASTQ_nr-hg19.ngsplot.heatmap.pdf
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.ngsplot.heatmap.pdf and $FASTQ_nr-hg19.ngsplot.avgprof.pdf file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.ngsplot.heatmap.pdf
	rm $FASTQ_nr-hg19.ngsplot.avgprof.pdf
	rm $FASTQ_nr-hg19.ngsplot.zip
    ngs.plot.r -G hg19 -R genebody -C $FASTQ_nr-hg19.bam -O $FASTQ_nr-hg19.ngsplot
fi

echo "ngsplot.heatmap and ngsplot.avgprof file is done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.ngsplot.heatmap.pdf)" >> Mapping.log
echo "$FASTQ_nr-hg19.ngsplot.heatmap.pdf is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.ngsplot.avgprof.pdf)" >> Mapping.log
echo "$FASTQ_nr-hg19.ngsplot.avgprof.pdf is done" >> Mapping.log
echo "" >> Mapping.log


# create an ngsplot config containing a list of all the bed files that will be used when doing ngsplot for repetitive sequences
echo "Will now create ngsplot_config.txt file containing list of all the bed files" >> Mapping.log
rm -f ngsplot_config.txt
for b in $proj_adress_backup/bed_ngs/*.bed
do
  c="${b#*\/}" 			# Remove through first / 
  c="${c#*\/}" 			# Remove through second / 
  c="${c#*\/}" 			# Remove through third / 
  echo -e "$FASTQ_nr-hg19.bam\t$b\t$c" >> ngsplot_config.txt
done
#b=../../bed/hg19_repeats.bed
#echo -e "$FASTQ_nr-hg19.bam\t$b\thg19_repeats.bed" >> ngsplot_config.txt


#will now create ngsplots
echo "Will now use ngsplot on the hg19 bam file together with the list of all the bed files " >> Mapping.log
ngs.plot.r -G hg19 -R bed -C ngsplot_config.txt -O $FASTQ_nr-hg19.ngsplot_repeats -P 2 -SC global -I 0 -L 2500 -MQ 10 -IN 0

#check so that the hg19.ngsplot_repeats were created
echo "calling fileeCHECK, sending variable: $FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf" >> Mapping.log
fileCHECK $FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf
if [ $createdFiIle == "unsucessfully downloaded" ]
then
	echo "Failed creating $FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf and $FASTQ_nr-hg19.ngsplot_repeats.avgprof.pdf file. Re-creating it" >> Mapping.log
	rm $FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf
	rm $FASTQ_nr-hg19.ngsplot_repeats.avgprof.pdf
	rm $FASTQ_nr-hg19.ngsplot_repeats.zip
    ngs.plot.r -G hg19 -R bed -C ngsplot_config.txt -O $FASTQ_nr-hg19.ngsplot_repeats -P 2 -SC global -I 0 -L 2500 -MQ 10 -IN 0
fi

echo "ngsplot_repeats.heatmap and ngsplot_repeats.avgprof file is done." >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf)" >> Mapping.log
echo "$FASTQ_nr-hg19.ngsplot_repeats.heatmap.pdf is done" >> Mapping.log
echo "Info: $(ls -l $FASTQ_nr-hg19.ngsplot_repeats.avgprof.pdf)" >> Mapping.log
echo "$FASTQ_nr-hg19.ngsplot_repeats.avgprof.pdf is done" >> Mapping.log
echo "" >> Mapping.log


#Removing files that are no longer useful
echo "now removing the unnormalized wig file and wig.idx file" >> Mapping.log
rm $FASTQ_nr-hg19.wig
rm $FASTQ_nr-hg19.wig.idx #this seem to also remove the n1.wig.idx (what is this file and is it important?)
rm testfile.txt
echo "" >> Mapping.log


#Moving files to different directories to optimize space limit 
echo "Will now move files to backup directory" >> Mapping.log
mv $FASTQ_nr-hg19.bam ${proj_adress_backup}/Sample_folder/$GEO_folder
mv $FASTQ_nr-REP.bam ${proj_adress_backup}/Sample_folder/$GEO_folder
mv $FASTQ_nr-hg19.bam.bai ${proj_adress_backup}/Sample_folder/$GEO_folder
mv $FASTQ_nr-REP.bam.bai ${proj_adress_backup}/Sample_folder/$GEO_folder
mv $FASTQ_nr-hg19.tdf ${proj_adress_backup}/Sample_folder/$GEO_folder
mv $FASTQ_nr-hg19.n1.wig ${proj_adress_backup}/Sample_folder/$GEO_folder 
echo ""


echo "ending script  Map data: im currently in the folder: $(pwd)" >> Mapping.log
echo "Mapping script run is finished" >> Mapping.log

echo "Ending time" >> Mapping.log 
date +"%T" >> Mapping.log


cd ..
#!!!!done


#delete FASTQ files and other files that are no longer needed (apart from sra files)
#put rep and whole ref seq into separate folders..






