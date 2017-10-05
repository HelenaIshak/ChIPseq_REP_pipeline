#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

#Script 3 - downloading published data 


# ------------------- Checking if file is sucessfully downloaded FUNCTION -------------------
function ChechkFileExistensAndSize {

shopt -s nullglob 
Eexisting_SRR=(*.sra) 				# To get all the existing SRR that are downloaded in the folder:

printf "\nChecking if the folder ${WanltedGEO_Array[0]} sra contain files..."				

if [ ${#Eexisting_SRR[@]} -eq 0 ]		# Checking if folder is empty 
then
	echo "The folder is empty and is missing the sra file(s)."
	echo "Downloading the missing files.. "
	cd .. 
	rm -rf ${WanltedGEO_Array[0]}
	# Call downloading files for this one 
	DownloadFilees

else 
	fileAgain="testfile.txt"                                       #repeated from earlier - can i make the repeats to one common?
	linksAgain=$(sed -n 's/.*href="\([^"]*\).*/\1/p' $fileAgain)   #repeated from earlier - can i make the repeats to one common?
	arrayLinksAgain=($linksAgain)                                  #repeated from earlier - can i make the repeats to one common?

	for j in "${arrayLinksAgain[@]}"
	do  
		if [[ $j == *"ftp-trace"* ]]
		then 
			secondLink="${j#*/}" 						# Remove through first /  	to remove first ftp:/
			secondLink="${secondLink#*/}" 				# Remove through second /	to remove / so that in the end all the ftp:// is removed.
			content2=$(wget "$secondLink" -q -O -) 		# To get the sourcecode into the variable content2
			wanntedFile_array=($content2) 				# Split string into array on each space. 

			for row in "${wanntedFile_array[@]}"
			do
				if [[ $row == *"SRR"* ]]
				then
					waanted_SRR="${row#*\"}" 			# Remove through first "   
					waanted_SRR="${waanted_SRR%%/*}" 		# Remove from / to end of string
					echo "Looking if file $waanted_SRR exist"
					
					uncompleteFile=no
					fileExist=false
					
					for i in "${Eexisting_SRR[@]}" 
					do   
						i="${i%%\.*}"  					# retain the part before .sra - Remove from next . to end of string (have to put \. to specify its a .)
						# i=${i%.sra*}                  # another way to retain the part before .sra as i
						if [[ $i == $waanted_SRR ]]
						then
							echo "file $waanted_SRR exist!"
							fileExist=true
							echo "checking if file size is complete.. "   	

							#!!NEW FILE CHECK - for uppmax
							
							existing_fileCode_md5=$(md5sum "$waanted_SRR.sra" | awk '{print $1}')
							thirdlink=ftp://$secondLink/$waanted_SRR/$waanted_SRR.sra
							
							wanted_fileCode_md5=$(curl -s "$thirdlink" | md5sum | awk '{print $1}')
							
							
							if [[ "$existing_fileCode_md5" == "$wanted_fileCode_md5" ]]  
							then
								echo "File was successfully downloaded!"
								# check_nr=true
								uncompleteFile=no
								break
							else	
								echo "File(s) downloaded for this folder failed"
								uncompleteFile=yes
							fi
								
							
							#!! OLD FILE CHECK - When working of home computer (dvs not uppmax), use this 
							# thirdlink=$secondLink/$waanted_SRR
							# existing_FILESIZE=$(ls -lah $i.sra | awk '{ print $5}')  #gives the file size in M 
							# # echo "existing file size: $existing_FILESIZE"
							# # now compare sizes
							# content3=$(wget $thirdlink -q -O -)
							# wanntedFile_array3=($content3) 
						
							# for row3 in "${wanntedFile_array3[@]}"
							# do
								# if [[ $row3 == *"M" ]]
								# then
									# # echo "wanted file size: $row3"  			#row3 (wanted_FILESIZE) in M as well 
									# # # some existing files can be 3.5M instead or 3 (as in wanted file). correct this, else it will show wrong.. 
									# existing_FILESIZE=${existing_FILESIZE%M*}   #To first remove the M in the end to have an integer and not a string
									# int=$(echo "($existing_FILESIZE+0.5)/1" | bc)M   #to make decimal numbers to whole numbers (avrundar decimal till heltal). Add M back to the end again 
									# echo "checking if existing file size $int is equal to wanted file size $row3 "
									# if [[ "$int" == "$row3" ]]  
									# then
										# echo "File size is correct. File was successfully downloaded!"
										# # check_nr=true
										# break
									# else	
										# echo "file size was not complete. File(s) was unsuccessfully downloaded"
										# uncompleteFile=yes
									# fi
								# fi
							# done
							# ##!!!!! OLD FILE CHECK 
							
							# if [[ $check_nr == "false" ]]
							# then
								# echo "file $waanted_SRR is missing"
								# uncompleteFile=yes
							# fi
						fi 
					done
				
					if [ $uncompleteFile == "yes" ] || [ $fileExist == "false" ]
					then
						echo "deleting the file(s)"
						cd .. 
						rm -rf ${WanltedGEO_Array[0]}
						DownloadFilees
					fi  
				fi 
			done 
		fi 
	done
fi
}
# ---------- Checking if file is sucessfully downloaded FUNCTION END -----------


# ------------------- DOWNLOADING FUNCTION -------------------
function DownloadFilees {

        half_firstLiInk="http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc="
        firstLiInk=$half_firstLiInk${WanltedGEO_Array[0]}
        content=$(wget "$firstLiInk" -q -O -) #Give you the source code 
        
        printf "\nDownloading file(s) for GEO: ${WanltedGEO_Array[0]}\n"
        #echo "Attempting to create ${WanltedGEO_Array[0]} inside $(pwd) - 1"
        #files1=${WanltedGEO_Array[0]
        #if [ ! -d $files1 ]   #if no X folder
        #then 
            mkdir ${WanltedGEO_Array[0]}
        #fi
        
        #files2=$proj_adress_backup/Sample_folder/${WanltedGEO_Array[0]}
        #if [ ! -d $files2 ]   #if no X folder
        #then
            mkdir $proj_adress_backup/Sample_folder/${WanltedGEO_Array[0]}
        #fi 
        
        cd ${WanltedGEO_Array[0]}
        echo "Currently in the folder (expected ${WanltedGEO_Array[0]}): $(pwd)"
               
        file="testfile.txt"
        if [ ! -e $file ]      #[ -e FILE ]	True if FILE exists.
        then
            echo "$content" > "$file"
        fi
        
        links=$(sed -n 's/.*href="\([^"]*\).*/\1/p' $file)
        arrayLinks=($links)

        for i in "${arrayLinks[@]}"
        do  
            if [[ $i == *"ftp-trace"* ]]
            then
                #sraLinks=$(echo $i | grep "ftp://ftp") 
				wget -r -nd -A.sra $i # downloading this file (link is in element $i) 	#!!!
                #  echo "$sraLinks"
                echo "${WanltedGEO_Array[0]}", \t, "$i", \t "file(s) are complete and downloaded" >> "newfile.txt"
                printf "Files in folder ${WanltedGEO_Array[0]} is downloaded \n" 
				  
            fi
        done
        # wget -r -nd -A.sra ${WanltedGEO_Array[7]}
        # printf "File ${WanltedGEO_Array[0]} is downloaded \n"  
        # cd ..	
}

# ----------------- DOWNLOADING FUNCTION END -----------------




# ---------------------- MAIN WINDOW -------------------------



#Passed variables: "$proj_adress_backup" "$proj_nr" "$proj_adress_NObackup"
proj_nr=$1
proj_adress_backup=$2
proj_adress_NObackup=$3
DataType=$4

echo "Started Downloading script. Starting time"
date +"%T" 
echo "The passed variables are:" 
echo "proj adress backup: $proj_adress_backup"
echo "proj nr: $proj_nr"
echo "proj adress no backup: $proj_adress_NObackup"

printf "expected location: backup directory. Actual location: $(pwd) \n"
mv SampleSheetTEST.txt $proj_adress_NObackup 
cd $proj_adress_NObackup
printf "expected location: NO backup directory. Actual location: $(pwd) \n" 


#declare an empty jobid variable 
#JOBID_string=

printf "\nChecking if Sample_folder exist \n"
if [ ! -d Sample_folder ]   #if no Sample_folder
then 
	printf "No Sample_folder exist! \nCreating Sample_folder and downloading all experimental data \n"
	#Is this variable needed??: amount_experiment=1      
	test=SampleSheetTEST.txt
    mkdir Sample_folder
    mkdir $proj_adress_backup/Sample_folder
    cp SampleSheetTEST.txt Sample_folder/.
    cd Sample_folder

    #Download THE FILES 
    while IFS=$'\t' read -r -a WanltedGEO_Array 
    do
		#calling Function DownloadFilees and then function ChechkFileExistensAndSize
		DownloadFilees
		ChechkFileExistensAndSize	
		cd ../..
    	GEOs_folder=${WanltedGEO_Array[0]}
      Experiment_type=${WanltedGEO_Array[3]}
      if [ $Experiment_type == "Chip_Seq_input"]
      then
          Experiment_type=input
      fi
      GEOs_file_name=${GEOs_folder}_${Experiment_type}
               
    	echo "GEOs_folder name: $GEOs_folder"
    	echo "Sending GEO experiment $GEOs_folder in SBATCH queue for mapping" 
    	echo "im currently in the folder: $(pwd)"
    	
    	dos2unix $proj_adress_backup/V2_MapBowtie2.bash 
    	jobid=$(sbatch -A $proj_nr $proj_adress_backup/V2_MapBowtie2.bash "$GEOs_folder" "$proj_adress_backup" "$DataType" "$GEOs_file_name")
      	echo "the jobid before: $jobid"
    	jobid=$(echo $jobid | sed 's/[^0-9]*//g')
      	echo "the jobid after: $jobid"
    	#JOBID_array[$amount_experiment]=$jobid
      	JOBID_string=$JOBID_string:$jobid
    	#cd $proj_adress_NObackup
    	
    	cd Sample_folder
    	#Is this variable needed??: let amount_experiment=amount_experiment+1
    done < <(tail -n +2 "$test")

else 
    printf "Sample_folder exist! \nChecking what experimental data already exist in Sample_folder and downloading only missing experimental data \n"
    cd Sample_folder 	
    echo "where am I? (expect sample_folder): $(pwd)"
    SampleShheeet=SampleSheetTEST.txt  #CHANGE BACK ALL OF THESE TO SampleSheet.txt when done debugging
    #Is this variable needed??: amount_experiment=1 
    
    shopt -s nullglob 	#The nullglob option causes the array to be empty if there are no matches.
    ExistingGEO_Aarray=(*) 	#contains folder names existing in this directory
    #counterEA=${#ExistingGEO_Aarray[@]}
    yes=0

    #Checking IF THE FILES EXIST
    while IFS=$'\t' read -r -a WanltedGEO_Array 	
    #IFS='' (or IFS=) prevents leading/trailing whitespace from being trimmed.. -r prevents backslash escapes from being interpreted.
    do            
        printf "\nChecking if GEO: ${WanltedGEO_Array[0]} exist... \n"
        echo "where am I? (expect no backup sample_folder): $(pwd)"
        yes=0 
    
        for ekement in ${ExistingGEO_Aarray[*]} 
        do 
            # printf "HELLO 1\n"
            # echo "Checking if wanted ${WanltedGEO_Array[0]} is equal to $ekement"
            if [[ $ekement == ${WanltedGEO_Array[0]} ]] 
            then 
                printf "Folder ${WanltedGEO_Array[0]} exist! \n" #GEO accession nr is ekement on position 2
                #ExistingGEO_Aarray=("${ExistingGEO_Aarray[@]:1}")
                #let counterEA=$counterEA-1Â´
				
				# check files by function ChechkFileExistensAndSize
				cd ${WanltedGEO_Array[0]} 	#!!!
				echo "where am I? (expect in geo folder): $(pwd)"
          
          
				#HÄÄÄÄR: check if Mapping.log finns. Ja - läs och kolla om sista filerna blev klara. Nej - fortsätt med det som är under här
				if [ ! -f Mapping.log ]   #if no Mapping.log  
				then 
						echo "File Mapping.log does not exist - this experiment is running for the first time with this pipeline"
				else
						echo "File Mapping.log does exist - this experiment has been run before with this pipeline"
						echo "Checking if the experiment was successfully mapped before"
						t=0
		  
						#read Mapping.log row by row. 
						while read map
						do 
							if [ "$map" == "Mapping script run is finished" ]
							then
									echo "Mapping.log contain Mapping script run is finished"
                  echo "experiment has been successfully mapped before"
									let t=1 
									continue 2 # Continue causes a jump to the next iteration of the loop, skipping all the remaining commands in that particular loop cycle..                                  # Continue at loop on 2nd level, that is the "outer loop".
							#else
									#echo "experiment was not successfully mapped and will therefore be remapped"
									#echo "deleting all files since they are not complete"
									#echo "starting the mapping for this experiment"
							fi
          
						done <Mapping.log
						
						if [ $t -eq 0 ]
						then
							echo "Mapping.log miss Mapping script run is finished"
              echo "experiment was not successfully mapped and will therefore be remapped"
							echo "deleting all files since they are not complete"
							echo "starting the mapping for this experiment"
						fi	
				fi
          
				#HÄÄÄR slut 
          
          
				ChechkFileExistensAndSize	
				cd ../..					#!!!
        		echo "where am I? (expect pipeline4): $(pwd)"
        
        		#call second script - REMEMBER TO change script name to whatever script2 have for name:  
        		GEOs_folder=${WanltedGEO_Array[0]}
        		echo "GEOs_folder name: $GEOs_folder"
        		echo "Sending GEO experiment $GEOs_folder in SBATCH queue for mapping"
           Experiment_type=${WanltedGEO_Array[3]}
            if [ $Experiment_type == "Chip_Seq_input"]
            then
                Experiment_type=input
            fi
        		echo "im first currently in the folder: $(pwd)"
      			#cd $proj_adress_backup
      			echo "im second currently in the folder: $(pwd)"
        		
        		dos2unix $proj_adress_backup/V2_MapBowtie2.bash 
        		jobid=$(sbatch -A $proj_nr $proj_adress_backup/V2_MapBowtie2.bash "$GEOs_folder" "$proj_adress_backup" "$DataType" "$GEOs_file_name")
        		echo "the jobid before: $jobid"  #printar ut "jobid: Submitted batch job 10176110". Klipp ut sÃ¥ att endast numret Ã¤r sparat och anvÃ¤nd dessa nummer i "dependency"
        		jobid=$(echo $jobid | sed 's/[^0-9]*//g')
        		echo "the jobid after: $jobid"
        		#JOBID_array[$amount_experiment]=$jobid
        		JOBID_string=$JOBID_string:$jobid
        		#cd $proj_adress_NObackup
        
        		cd Sample_folder
                
                yes=1
                # echo "break from inner loop"
                break
            fi
        done
        
        # printf "Out of inner loop\n\n"		

        if [ $yes -eq 0 ]
        then
            printf "Folder ${WanltedGEO_Array[0]} is missing. Downloading the file...\n"
            	
			#call Function DownloadFilees 
			DownloadFilees
			ChechkFileExistensAndSize	            
			cd ../..
      
      		#call second script - REMEMBER TO change script name to whatever script2 have for name: 
      		echo "Sending file in queue to be mapped"
      		#GEOs_folder=${WanltedGEO_Array[0]}
      		#echo "GEOs_folder name: $GEOs_folder"
         #Experiment_type=${WanltedGEO_Array[3]}
      #if [ $Experiment_type == "Chip_Seq_input"]
      #then
          #Experiment_type=input
      #fi
      		echo "im first currently in the folder: $(pwd)"
      		#cd $proj_adress_backup
      		echo "im second currently in the folder: $(pwd)"
      		
      		dos2unix $proj_adress_backup/V2_MapBowtie2.bash
      		jobid=$(sbatch -A $proj_nr $proj_adress_backup/V2_MapBowtie2.bash "${WanltedGEO_Array[0]}" "$proj_adress_backup" "$DataType" "$GEOs_file_name") 
      		echo "the jobid before: $jobid" #printar ut "jobid: Submitted batch job 10176110". Klipp ut sÃ¥ att endast numret Ã¤r sparat och anvÃ¤nd dessa nummer i "dependency"
      		jobid=$(echo $jobid | sed 's/[^0-9]*//g') 
      		echo "the jobid after: $jobid"
      		#JOBID_array[$amount_experiment]=$jobid
      		JOBID_string=$JOBID_string:$jobid
    		#cd $proj_adress_NObackup
      
      		cd Sample_folder
        fi
        
        #Is this variable needed??: let amount_experiment=amount_experiment+1
    done < <(tail -n +2 "$SampleShheeet")
fi

cd ..
echo "im first in the folder (nobackup?): $(pwd)"
#cd $proj_adress_backup
echo "im then in the folder (backup?): $(pwd)"

echo "Ending script Download files. Ending time"
date +"%T" 

#Dependency is used to make script 4 and 5 start once all of the multiple script3 are done running. 
echo "starting script 4 and 5 now which are waiting for these jobs to be done: $JOBID_string" 
#uncomment, just used for the debuggin dos2unix $proj_adress_backup/V3_Calculate_idxstat.bash
#uncomment, just used for the debuggin sbatch --dependency=afterok$JOBID_string -A $proj_nr $proj_adress_backup/V3_Calculate_idxstat.bash "$proj_adress_backup" "$proj_adress_NObackup"

#uncomment, just used for the debuggin dos2unix $proj_adress_backup/V4_Calculate_IntervalStats.bash
#uncomment, just used for the debuggin sbatch --dependency=afterok$JOBID_string -A $proj_nr $proj_adress_backup/V4_Calculate_IntervalStats.bash "$proj_adress_backup" "$proj_adress_NObackup"

echo "jobid4: $jobid4 and jobid5: $jobid5"  



# --------------------- MAIN WINDOW END -------------------------
