#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.


#Script 1 - connecting all scripts into a pipeline and is the "user interface" script.  
#This pipeline is connecting all the scripts to personalize the pipeline based on the users wish (example published data/own data, histone modifications etc). 


#The user need to prepare a few things: 
#A folder in the backup and no-backup directory with a name you wish to call this project and cd into this folder (in the backup directory). PS the name of the folder has to be the same for the backup and no-backup directory. 
#files and script in the folder name of the backup directory
#


echo "Pipeline start. Starting time"
echo +"%T" 

#--To automatic see what job number the user has on his/hers UPPMAX for this project as well as finidng the directories for the backup directory and no-backup directory

#IMPORTANT: The directory adress (pwd) to your project folder can be different depending what you type to get there. The directory adress MUST be proj/proj_nr/yourname/ when you start the pipeline. Else this pipeline won't work

proj_adress_backup=$(echo $(pwd))
proj_nr="${proj_adress_backup#*/}"
proj_nr="${proj_nr#*/}" #removes til+and "/"
proj_nr="${proj_nr%%/*}" #removes from "/" to the end of the string
proj_nr_NObackup=${proj_nr}/nobackup
proj_adress_NObackup="${proj_adress_backup/$proj_nr/$proj_nr_NObackup}" #declare proj_adress_backup but replaces proj_nr with proj_nr_NObackup 

echo "Your information:"
echo "project number: $proj_nr"
echo "project adress backup: $proj_adress_backup"
echo "project adress NO backup: $proj_adress_NObackup" 


#--Download the java-genomic-toolkit and unzip it - the final name of the folder: java-genomics-toolkit-master.  
if [ ! -d java-genomics-toolkit-master ]
then 
	echo "downloading java genomic toolkit master"
	wget -O java-genomics-toolkit.zip https://github.com/timpalpant/java-genomics-toolkit/archive/master.zip
	unzip java-genomics-toolkit.zip
fi

echo "java genomic toolkit is downloaded. Info:"
echo "echo $(ls -l java-genomics-toolkit-master/)"
echo ""

#--ask user if the pipeline will analyze published data or users own data:
echo "Chose type of data"
echo -n "If the data that will be analyzed is: 
- Your own data, type 1 and press [ENTER] 
- Published data from NIH epigenetic, type 2 and press [ENTER]
"  
read userChosenData

echo "you choosed alternative $userChosenData"

if [ $userChosenData -eq 2 ]
then 
    echo "You have chosen to analyze published data"
    DataType=0
    echo -n "Enter what histone experimental type(s) you are interested in 
    - If one histone modification, example TYPE: H3K9me3 - and press [ENTER]
    - If many histone modifications, use SPACE to separate different types, ex TYPE: H3K9me3 H3K4me3 - and press [ENTER] 
    "
    read histoneType
    histoneType="${histoneType} input"
    #--Call the downloading script. Creates the samplesheet in sbatch?
    dos2unix V3_CreateSamplesheet.bash
    bash V3_CreateSamplesheet.bash "$histoneType"
    
    #--Call the downloading script. Downloading files by sbatch with dependency that V3_CreateSamplesheet.bash is done?
    #uncomment, just used for the debuggin dos2unix V2_DownloadFiles.bash
    #uncomment, just used for the debuggin bash V2_DownloadFiles.bash "$proj_nr" "$proj_adress_backup" "$proj_adress_NObackup" "$DataType"
    
elif [ $userChosenData -eq 1 ]
then
    echo "You have chosen to analyze your own data"
    echo "For this part of the pipeline to work, a MySamplesheet.txt text file has to exist containing list of samples that will be analyzed."
    echo "This MySamplesheet.txt need to have the pattern shown in the instructions written in README.txt file"
    echo -n "Is this MySamplesheet.txt created as described? If yes type 0, if no type 1
"
    read Answer
    
    if [ $Answer -eq 0 ]
    then
         DataType=1
         MySample=MySamplesheet.txt
         echo "What folder am I in? $(pwd)"
         echo "$(ls -la)"
    
          #--Loop through users own samplesheet to call the mapping script for each experiment
         while IFS=$'\t' read -r -a GEO_array
         do
               GEOs_folder=${GEO_array[0]}
               Experiment_type=${GEO_array[3]}
               
               if [ $Experiment_type == "Chip_Seq_input"]
               then
                   Experiment_type=input
               fi
               GEOs_file_name=${GEOs_folder}_${Experiment_type}
               
               echo "Sending GEO experiment $GEOs_folder in SBATCH queue for mapping"
               cd $proj_adress_NObackup
               echo "im first currently in the folder: $(pwd)"
               echo "Data type: $DataType"
             
              $proj_adress_backup/V2_MapBowtie2.bash 
     	        jobid=$(sbatch -A $proj_nr $proj_adress_backup/V2_MapBowtie2.bash "$GEOs_folder" "$proj_adress_backup" "$DataType" "$GEOs_file_name")
     	        
              echo "the jobid before: $jobid"
    	        jobid=$(echo $jobid | sed 's/[^0-9]*//g')
     	        echo "the jobid after: $jobid"
         done < <(tail -n +2 "$MySample") 
    elif [ $Answer -eq 1 ]
     then
         echo "Your MySamplesheet.txt is not created/incomplete/wrong." 
         echo "Therefore this pipeline can't analyze your data. Please follow the instructions on how to create MySamplesheet.txt before running the pipeline."
    else
        echo "Error: you neither types 0 or 1 - test running again"
    
    
    fi 
    #dos2unix $proj_adress_backup/V1_CreateSamplesheetUsersData.bash 
   	#jobid=$(sbatch -A $proj_nr $proj_adress_backup/V2_MapBowtie2.bash "$GEOs_folder" "$proj_adress_backup" "$DataType")
else
      echo "Error: you neither types 1 or 2 - test running again"
fi





