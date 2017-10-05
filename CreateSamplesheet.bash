#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

#Script 2 - creating sample sheet for published data 

#for experimentType in "${histoneTypeArray[@]}"
#do
function createhSamplesheet {
	echo "the experiment type: $experimentType"

  	if [ $experimentType == "input" ]
  	then
         echo "its an input!"
      	first_sampleLink_chipExperimentType="ftp://ftp.ncbi.nlm.nih.gov/pub/geo/DATA/roadmapepigenomics/by_experiment/ChIP-Seq_input/"
      	content_sampleLink_chipExperiment=$(wget "$first_sampleLink_chipExperimentType" -q -O -) #Give you the source code
      	experimentType=Chip_Seq_input
  	else
         echo "its a histone type!"
      	first_sampleLink_chipExperimentType="ftp://ftp.ncbi.nlm.nih.gov/pub/geo/DATA/roadmapepigenomics/by_experiment/$experimentType/"
      	content_sampleLink_chipExperiment=$(wget "$first_sampleLink_chipExperimentType" -q -O -) #Give you the source code
  	fi 



	#FOR histoneType DATA:
	file=testfile$experimentType.txt
	echo "creating file $file"

	if [ ! -e $file ]
	then
    	echo "$content_sampleLink_chipExperiment" > "$file"
	fi

	# links2=$(sed -n 's/.*href="\([^"]*\).*/\1/p' $file2)
	# arrayLinks2=($links2)

	echo "file $file is created"

	while read TheFILEe
	do
		if [[ $TheFILEe == *"Directory"* ]]
      	then
			    #want to extract link
			    Mainlink="${TheFILEe#*\"}" #removes everything til the end on "
			    Mainlink="${Mainlink%%\"*}" #removes from " to the end of the string
			    #echo "Extracted link: $Mainlink"

			    DataType2="${TheFILEe#*>}" 			#remove everything til the end of >
			    DataType2="${DataType2%%/*}" 		# Removes from / to end of the string
			    # echo "Extracted datatype: $DataType2"

			    content_GEO_chipHistone=content_GEO_chip$experimentType
			    content_GEO_chipHistone=$(wget "$Mainlink" -q -O -) #Give you the source code to find what GSM geo accession nr it has

			    IFS=$'\n' read -rd '' -a array2 <<< "$content_GEO_chipHistone"


			    for m in "${array2[@]}"
			    do
				      if [[ $m == *"GSM"* ]]
				      then
					        if [[ $m == *"bed"* ]]
					        then
						    	GEO2="${m#*$DataType2/}" #remove everything til the end of $DataType/
				              	GEO2="${GEO2%%_*}" 		# Remove from _ to end of string

						    	ExtraInfo="${m#*$GEO2\_}" #remove everything til the end of $GEO2_
						
                      			ExtraInfo1="${ExtraInfo%%\.*}" 		# Remove from . to end of string
                      			#ExtraInfo1="${ExtraInfo%%\.bed*}"
						
                      			ExtraInfo2="${ExtraInfo#*\.}"   #remove everything til the end of .
						        ExtraInfo2="${ExtraInfo2#*\.}"  #remove everything til the end of .
					          	ExtraInfo2="${ExtraInfo2#*\.}"  #remove everything til the end of .
					          	ExtraInfo2="${ExtraInfo2%%\.bed*}" 		# Remove from .bed to end of string

                      			DataType3="${m#*$ExtraInfo1\.}" #remove everything til the end of $ExtraInfo1.
                      			DataType3="${DataType3%%\.*}"   # Remove from .bed to end of string
                      			# echo "Extra info: $DataType3"
      
                      			# use $GEO2, get to source code: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=$GEO2 and extract row containing 
                      			ExtrainfoLink=https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=$GEO2
                      			ExtraInfo3=$(wget "$ExtrainfoLink" -q -O -)
                      			IFS=$'\n' read -rd '' -a array3 <<< "$ExtraInfo3"
                      			cheeckVariable=0
                      			SRAfiLle=notExisting
                      			for h in "${array3[@]}"
                      			do
                          			if [[ $cheeckVariable -eq 1 ]]
                          			then 
                              			ExtraInfo4="${h#*\>}"
                              			ExtraInfo4="${ExtraInfo4%%\;*}"
                              			#echo "Etra Info 4 when it's found: $ExtraInfo4"
                              			break 
                          			fi 
                
                          			if [[ $h == *"nowrap>Title"* ]]
                          			then
                              			cheeckVariable=1
                          			fi              
                      			done
            
                      			for m in "${array3[@]}"
                      			do
                          			#echo "$m"
				                  	if [[ $m == *"SRA Experiment"* ]]  
				                  	then
					                	SRAfiLle=exist
                               			break
				                  	fi
                      			done 
            
                      		#echo -e "$GEO2\t$DataType2\t$DataType3\t$experimentType\t$ExtraInfo1\t$ExtraInfo2\t$ExtraInfo4" >> "newSampleSheet.txt"   #the way to add a newline 

                      		if [ $SRAfiLle == "exist" ]
                      		then 
                          		echo "$GEO2 contain sra files online"
                          		echo -e "$GEO2\t$DataType2\t$DataType3\t$experimentType\t$ExtraInfo1\t$ExtraInfo2\t$ExtraInfo4" >> "newSampleSheet.txt"   #the way to add a newline
                      		else 
                          		echo "$GEO2 is missing sra files online"
                      		fi  
					    fi
				      fi
			    done
		  fi
	done <$file
}




#MAIN SCRIPT

histoneType=$1

echo "Starting the script that will create the sample sheet for published data."
echo -e "GEO_accesion\tData_name\tData_name_extra\tExperiment_type\tResearchPlace\tResearchNr\tExtraInfo4\tinputGEO" > "newSampleSheet.txt"   #create text file newSamplesheet.txt


#--Checking if there are more than one histone modification chosen 
#if [[ $histoneType == *" "* ]]
#then
echo "user input contain these experiment types: $histoneType"
histoneTypeArray=($histoneType) #make string to array
for experimentType in "${histoneTypeArray[@]}"
do
        echo "experimentType: $experimentType"
        createhSamplesheet
done
#else
#    experimentType=$histoneType
#    echo "user input contain one experimental type: $experimentType"
#    createhSamplesheet
#fi

#--Creating a new file which will contain a sorted version of the Samplesheet 
echo -e "GEO_accesion\tData_name\tData_name_extra\tExperiment_type\tResearchPlace\tResearchNr\tExtraInfo4\tinputGEO" > "SortednSamplesheet.txt"
sort -f -s -k2,2 -k3,3 -k5,5 -k6,6 -k4,4 newSampleSheet.txt > SortednSamplesheet.txt
rm newSampleSheet.txt


#--Creating a new file which will filter the sorted samplesheet to remove lonely inputs or histone types. 
echo -e "GEO_accesion\tData_name\tData_name_extra\tExperiment_type\tResearchPlace\tResearchNr\tExtraInfo4\tinputGEO" > "SampleSheet.txt" 

while IFS=$'\t' read -r -a sampleGEOArraay 
do
    echo "input? ${sampleGEOArraay[3]}"
    if [[ ${sampleGEOArraay[3]} == "Chip_Seq_input" ]]  
    then 
          echo "the ${sampleGEOArraay[3]} is an input!"     
          GEOinput="${sampleGEOArraay[0]}"
          column2="${sampleGEOArraay[1]}"
          column3="${sampleGEOArraay[2]}"
          column4="${sampleGEOArraay[3]}"
          column5="${sampleGEOArraay[4]}"
          column6="${sampleGEOArraay[5]}"
          column7="${sampleGEOArraay[6]}"
             
    
    elif [[ ${sampleGEOArraay[3]} != "Chip_Seq_input" ]]
    then    
          echo "this ${sampleGEOArraay[1]} is a histone type"
          if [ $column3 == ${sampleGEOArraay[2]} ] && [ $column5 == ${sampleGEOArraay[4]} ] && [ $column6 == ${sampleGEOArraay[5]} ]
          then
                if [[ $lastRow != "Chip_Seq_input" ]]       #PROBLEM H€R! FIXA SÅ OM VI HAR TVÅ OLIKA HISTONES FUNKAR!!! Denna del gör det, men funkar inte rätt
                then
                      echo -e "${sampleGEOArraay[0]}\t${sampleGEOArraay[1]}\t${sampleGEOArraay[2]}\t${sampleGEOArraay[3]}\t${sampleGEOArraay[4]}\t${sampleGEOArraay[5]}\t${sampleGEOArraay[6]}\t$GEOinput" >> "SampleSheet.txt"
                else 
                      #echo "this ${sampleGEOArraay[0]} is NOT an input but match the input"
                      echo -e "$GEOinput\t$column2\t$column3\t$column4\t$column5\t$column6\t$column7\t-" >> "SampleSheet.txt" 
                      echo -e "${sampleGEOArraay[0]}\t${sampleGEOArraay[1]}\t${sampleGEOArraay[2]}\t${sampleGEOArraay[3]}\t${sampleGEOArraay[4]}\t${sampleGEOArraay[5]}\t${sampleGEOArraay[6]}\t$GEOinput" >> "SampleSheet.txt"
                fi  
          fi
    else
          echo "this row will be ignored"
          #continue #continue the loop to next row of textfile 
    fi
	lastRow=${sampleGEOArraay[3]}
done < "SortednSamplesheet.txt"

rm SortednSamplesheet.txt