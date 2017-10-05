#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

# This script is under developement in order to make it faster - This script has an added function it to it which still has to be properly tested.


#Script 6 - calculate interval stats 


#####SBATCH -A b2015157
#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 07-00:00:00



function StandardDeviation (){
      #to save the array that was passed to this function
      harray=$1[@]
      averageel_nr_of_counts=$2
      specID_array=("${!harray}")

      #echo "in the function StandardDeviation. Sent an array: ${specID_array[@]} and variable $averageel_nr_of_counts"
      
      declare -A singlee_deviation3_array
      counter5=0
      for k in "${specID_array[@]}"
      do
            if [[ $k == "0" ]]
            then
                  single_deviatioN2=0
                  singlee_deviation3_array[$counter5]=$single_deviatioN2
                  #echo "from array nr $counter5: ${singlee_deviation3_array[$counter5]}"
                  let counter5=counter5+1
            else
                  #echo "calc 0: $k - $averageel_nr_of_counts = calc 1"
                  single_deviaation1=$( echo "$k - $averageel_nr_of_counts" | bc -l )
                  #echo "calc 1: $single_deviaation1"
                  #echo "$single_deviaation1 * $single_deviaation1 = calc 2"
                  single_deviatioN2=$( echo "$single_deviaation1 * $single_deviaation1" | bc -l )
                  #echo "calc 2: $single_deviatioN2"
                  singlee_deviation3_array[$counter5]=$single_deviatioN2
                  echo "from array nr $counter5: ${singlee_deviation3_array[$counter5]}"
                  let counter5=counter5+1
            fi
      done

      sum=$( IFS="+"; bc <<< "${singlee_deviation3_array[*]}" ) #to sum together all the elements in the array
      echo "sum $sum, counter $counter5"
      final_deviatIon_a=$( echo "$sum / $counter5" | bc -l )
      echo "final_deviatIon_a: $final_deviatIon_a"
      final_deviations_b=$( echo "sqrt ( $final_deviatIon_a )" | bc -l )
      echo "final_deviations_b: $final_deviations_b"
}


#MAIN PART!!

#Passed variables: "$proj_adress_backup" "$proj_nr" "$proj_adress_NObackup"
proj_adress_backup=$1
proj_adress_NObackup=$2

echo "Starting the calculation intervalstats script. Starting time and date"
date +"%T" 
$man date


#cd $proj_adress_NObackup
echo "location (expected nobackup): $(pwd)"
cd Sample_folder
printf "ID\t" > "hg19_IntervalStats_result_v3.txt"    #creating the new text file containing the calculated intervalstat result
printf "ID\t" > "hg19_IntervalStats_ChIPresult_v3.txt"    #creating the new text file containing the calculated idxstat result
printf "ID\t" > "hg19_IntervalStats_INPUTresult_v3.txt"    #creating the new text file containing the calculated idxstat result
printf "ID\t" > "hg19_IntervalStats_raw_result3.txt"
echo "start: ID" > "test1.txt"
sampleshheet=SampleSheet.txt


declare -A Aaverage_Array #declaring an empty array
declare -A Aaverage_ArrayCHIP
declare -A Aaverage_ArrayINPUT
declare -A arrayk_of_ID
declare -A raw_IDnr
#declare -A StandardDeviation_Array
declare -A StandardDeviationCHIP_Array
declare -A StandardDeviationINPUT_Array
declare -A Chip_specID_array
declare -A Input_specID_array
declare -A Raw_data_array
nr_GEO=0
id_counter=0


while IFS=$'\t' read -r -a sampleshheetGEO
do
	echo "Reading a row of sample sheet" >> "test1.txt"
    echo "Will check if ${sampleshheetGEO[3]} is equal to Chip_Seq_input" >> "test1.txt"

  	if [[ ${sampleshheetGEO[3]} != "Chip_Seq_input" ]]
  	then
        	echo "row: chip seq"
			ChipGEO=${sampleshheetGEO[0]}
        	InputGEO=${sampleshheetGEO[7]}
        	HistoneModification=${sampleshheetGEO[3]}

		    #Adding the column header names to the different files 
        	printf "${ChipGEO}/${InputGEO}_${HistoneModification} average\t" >> "hg19_IntervalStats_result_v3.txt"
        	printf "${ChipGEO}_${HistoneModification} average\t${ChipGEO}_${HistoneModification} standard deviation\t" >> "hg19_IntervalStats_ChIPresult_v3.txt"
        	printf "$InputGEO average\t$InputGEO standard deviation\t" >> "hg19_IntervalStats_INPUTresult_v3.txt"
        	printf "${ChipGEO}_${HistoneModification}\t$InputGEO\tDivision\t" >> "hg19_IntervalStats_raw_result3.txt"
        	echo "header samples: Chip: ${ChipGEO}, histone: ${HistoneModification} and input: $InputGEO" >> "test1.txt"
        
        
        
        	echo "location: $(pwd)"
        	echo "location: $(pwd)" >> "test1.txt"
        
        	#REMOVE AFTER DEBUGGING FROM HERE ------
        	#echo "creating the lost intervalstats file now"
       
        	#repeats="$proj_adress_backup/bed/hg19_repeats.bed"
        	#$proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh ngs.IntervalStats -s mean -l $repeats -o $ChipGEO/$ChipGEO-hg19.IntervalStats.txt $proj_adress_backup/Sample_folder/$ChipGEO/$ChipGEO-hg19.n1.wig > $ChipGEO/jgt2.log
        
        	#repeats2="$proj_adress_backup/bed/hg19_repeats.bed"
        	#$proj_adress_backup/java-genomics-toolkit-master/toolRunner.sh ngs.IntervalStats -s mean -l $repeats2 -o $InputGEO/$InputGEO-hg19.IntervalStats.txt $proj_adress_backup/Sample_folder/$InputGEO/$InputGEO-hg19.n1.wig > $InputGEO/jgt2.log
        	#-----TO HERE 

        
        
        	#Sorting based on ID (repetitive sequence) and keep header as first row (first row is not in the sorting process)
        	#uncomment, just used for the debuggin
        	echo "sorting the intervalstats file based on ID (repetitive sequence)"
        	head -1 $ChipGEO/$ChipGEO-hg19.IntervalStats.txt > $ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        	sed 1d $ChipGEO/$ChipGEO-hg19.IntervalStats.txt | sort -f -s -k4,4 -k1,1 $ChipGEO/$ChipGEO-hg19.IntervalStats.txt >> $ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        	head -1 $InputGEO/$InputGEO-hg19.IntervalStats.txt > $InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt
        	sed 1d $InputGEO/$InputGEO-hg19.IntervalStats.txt | sort -f -s -k4,4 -k1,1 $InputGEO/$InputGEO-hg19.IntervalStats.txt >> $InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt

		    #remove the unsorted $ChipGEO/$ChipGEO-hg19.IntervalStats.txt
		    rm $ChipGEO/$ChipGEO-hg19.IntervalStats.txt
        	rm $InputGEO/$InputGEO-hg19.IntervalStats.txt
 

        	intervalStatsChip=$ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        	intervalStatsInput=$InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt
        

        	echo "intervalStatsChip: $intervalStatsChip
        	intervalStatsInput: $intervalStatsInput" 
        
        	echo "intervalStatsChip: $intervalStatsChip
        	intervalStatsInput: $intervalStatsInput" >> "test1.txt"

        	#intervalStatsChip=$GEO-hg19.intervalStatsChip.txt
	      	counter2=0
	      	counter3=0
	      	nr_ID=0
        	counter4=0
        	counter6=0
        
        	echo "counter back to 0 for new samples: nr_GEO = $nr_GEO, and counter2= $counter2" >> "test1.txt"

        	while IFS=$'\t' read -r -a intervalStatsChip
        	do
        	  	if ! read -u 3 inputfile2   #Reading lines from two files in one while loop
            	then
                		echo "Reading lines from two files in one while loop- this means that second file doesnt exist"
                		break
            	fi

				echo "array 1: ${intervalStatsChip[@]}" >> "test1.txt"
				echo "array 2: ${intervalStatsChip[0]}, ${intervalStatsChip[1]}, ${intervalStatsChip[2]}, ${intervalStatsChip[3]}, ${intervalStatsChip[4]}, ${intervalStatsChip[5]}, ${intervalStatsChip[6]}, ${intervalStatsChip[7]}" >> "test1.txt"

            	if [[ ${intervalStatsChip[6]} == "$ChipGEO-hg19.n1.wig" ]]
            	then
                		echo "first row (header) ignored"
            	else
                		echo "reading row of both files"
                		#create array of each column in input file
                		IFS=$':' intervalStatsInput=(${inputfile2//$'\t'/:})

                		Chip_nr_counts=${intervalStatsChip[6]}
                		Input_nr_counts=${intervalStatsInput[6]}
                		chip_input_Division="Yes"
                		
                		echo "1 Chip nr of counts: ${intervalStatsChip[6]}" >> "test1.txt"
				        echo "1 Input nr of counts: ${intervalStatsInput[6]}" >> "test1.txt"
				        echo "1 Division result chip/input nr or counts: $chip_input_Division" >> "test1.txt"

                		if [[ $Chip_nr_counts == "NaN" ]]
                		then
                				Chip_nr_counts=0
                				chip_input_Division="NaN"
                		fi
                		if [[ $Input_nr_counts == "NaN" ]]
                		then
                				Input_nr_counts=0
                				chip_input_Division="NaN"
                		fi

				        if [[ $chip_input_Division != "NaN" ]]
				        then
  						        chip_input_Division=$( echo "$Chip_nr_counts / $Input_nr_counts" | bc -l ) 
				        fi
			        
				        echo "2 Chip nr of counts: $Chip_nr_counts" >> "test1.txt"
				        echo "2 Input nr of counts: $Input_nr_counts" >> "test1.txt"
				        echo "2 Division result chip/input nr or counts: $chip_input_Division" >> "test1.txt"
				
				        Raw_data_array[$counter2]="${Chip_nr_counts}\t${Input_nr_counts}\t${chip_input_Division}"
                		echo "printing result for raw data array:" >> "test1.txt"
                		echo "1: ${Chip_nr_counts}\t${Input_nr_counts}\t${chip_input_Division}" >> "test1.txt"
                		echo "2: ${Raw_data_array[$counter2]}" >> "test1.txt"
				        echo "counter2: $counter2" 
                		let counter2=counter2+1
                		echo "added one to counter: $counter2" 
            
                		raw_IDnr[$counter6]=${intervalStatsChip[3]}
                		let counter6=counter6+1

               			echo "Added 1 to the counters: nr_GEO = $nr_GEO, and counter2= $counter2" >> "test1.txt"
                
		            	if [[ $counter3 -eq 0 ]]
		            	then
                		    	unset Chip_specID_array[@] #to clear the array for each new chip&input sample
                      			unset Input_specID_array[@] #to clear the array for each new chip&input sample
                      			Chip_specID_array[$counter4]=$Chip_nr_counts
                      			Input_specID_array[$counter4]=$Input_nr_counts
                      			let counter4=counter4+1

			    		        IDnr=${intervalStatsChip[3]}
			                  	echo "$IDnr"
                      			arrayk_of_ID[$id_counter]=$IDnr
                      			let id_counter=id_counter+1
                      			let counter3=counter3+1
                       
		            	else
			            		if [[ ${intervalStatsChip[3]} == $IDnr ]]
			            		then
				        				#sum_nr_of_counts_chip=$( echo "$sum_nr_of_counts_chip + $Chip_nr_counts" | bc -l )
                            			#sum_nr_of_counts_input=$( echo "$sum_nr_of_counts_input + $Input_nr_counts" | bc -l )
                            			Chip_specID_array[$counter4]=$Chip_nr_counts
                            			Input_specID_array[$counter4]=$Input_nr_counts
                            			let counter4=counter4+1
                            			let counter3=counter3+1
			                  	else
                              			sum_nr_of_counts_chip=$( IFS="+"; bc <<< "${Chip_specID_array[*]}" ) #to sum together all the elements in the array
                            			sum_nr_of_counts_input=$( IFS="+"; bc <<< "${Input_specID_array[*]}" ) #to sum together all the elements in the array
                            			#gives the average nr which is declared in the array
				                		averageel_nr_of_counts_chip=$( echo "$sum_nr_of_counts_chip / $counter3" | bc -l )
                            			averageel_nr_of_counts_input=$( echo "$sum_nr_of_counts_input / $counter3" | bc -l )
                            			#----->>>>Divide the chip average by input average! chip/input
                              			total_averageel_nr_of_counts=$( echo "$averageel_nr_of_counts_chip / $averageel_nr_of_counts_input" | bc -l )
                            			Aaverage_Array[$nr_GEO,$nr_ID]=$total_averageel_nr_of_counts
                            			Aaverage_ArrayCHIP[$nr_GEO,$nr_ID]=$averageel_nr_of_counts_chip
								    	Aaverage_ArrayINPUT[$nr_GEO,$nr_ID]=$averageel_nr_of_counts_input
                            	
                            			echo "Total_averageel_nr_of_counts: ${Aaverage_Array[$nr_GEO,$nr_ID]}"

                            			#echo "in the main script, calling function StandardDeviation for chip. passing array: ${Chip_specID_array[@]} and variable $averageel_nr_of_counts"
                            			StandardDeviation Chip_specID_array $averageel_nr_of_counts_chip
                            			stdev_Chip=$final_deviations_b
                            			echo "final_deviations_b in main script: $final_deviations_b"
	
                            			#echo "in the main script, calling function StandardDeviation for input. passing array: ${Input_specID_array[@]} and variable $averageel_nr_of_counts"
                            			StandardDeviation Input_specID_array "$averageel_nr_of_counts_input"
                            			stdev_Input=$final_deviations_b

                              			echo "Chip stdev: $stdev_Chip, Input stdev: $stdev_Input"
                            			#total_stdev_nr_of_counts=$( echo "$stdev_Chip / $stdev_Input" | bc -l )
                            			#StandardDeviation_Array[$nr_GEO,$nr_ID]=$total_stdev_nr_of_counts
                            			StandardDeviationCHIP_Array[$nr_GEO,$nr_ID]=$stdev_Chip
                            			StandardDeviationINPUT_Array[$nr_GEO,$nr_ID]=$stdev_Input

                            			unset Chip_specID_array[@] #to clear the array
                            			unset Input_specID_array[@]
                            			counter4=0
                            			Chip_specID_array[$counter4]=$Chip_nr_counts
                            			Input_specID_array[$counter4]=$Input_nr_counts
                            			let counter4=counter4+1
                              			echo "nr_ID: $nr_ID"
                            			let nr_ID=nr_ID+1
                              			echo "added 1 to nr_ID: $nr_ID"
				                      	IDnr=${intervalStatsChip[3]}

				                      	counter3=1
				                      	echo "$IDnr   $counter3"
                            			arrayk_of_ID[$id_counter]=$IDnr
                              			echo "id_counter: $id_counter"
                            			let id_counter=id_counter+1
                              			echo "added 1 to id_counter: $id_counter"
                      			fi
		    			fi
		    			#Adding an extra file table containing the raw data (nr of counts) for each sample and their division nr
		    			#nrCounts_ChIP[$nr_GEO,$nr_ID]=$Chip_nr_counts
				        #nrCounts_Input[$nr_GEO,$nr_ID]=$Input_nr_counts
				        #nrCounts_Division[$nr_GEO,$nr_ID]=$chip_input_Division
        		fi
    		done < $intervalStatsChip 3< $intervalStatsInput

 

			#for last ID sequence:
			sum_nr_of_counts_chip=$( IFS="+"; bc <<< "${Chip_specID_array[*]}" ) #to sum together all the elements in the array
			sum_nr_of_counts_input=$( IFS="+"; bc <<< "${Input_specID_array[*]}" ) #to sum together all the elements in the array
			#gives the average nr which is declared in the array
			averageel_nr_of_counts_chip=$( echo "$sum_nr_of_counts_chip / $counter3" | bc -l )
        	averageel_nr_of_counts_input=$( echo "$sum_nr_of_counts_input / $counter3" | bc -l )
        	#Divide the chip average by input average! chip/input
        	total_averageel_nr_of_counts=$( echo "$averageel_nr_of_counts_chip / $averageel_nr_of_counts_input" | bc -l )
        	Aaverage_Array[$nr_GEO,$nr_ID]=$total_averageel_nr_of_counts
        	echo "Total_averageel_nr_of_counts: ${Aaverage_Array[$nr_GEO,$nr_ID]}"
        	Aaverage_ArrayCHIP[$nr_GEO,$nr_ID]=$averageel_nr_of_counts_chip
			Aaverage_ArrayINPUT[$nr_GEO,$nr_ID]=$averageel_nr_of_counts_input
        	
        

        	#for last ID sequence:
        	StandardDeviation Chip_specID_array $averageel_nr_of_counts_chip
       		stdev_Chip=$final_deviations_b
        	echo "final_deviations_b in main script: $final_deviations_b"

        	StandardDeviation Input_specID_array "$averageel_nr_of_counts_input"
        	stdev_Input=$final_deviations_b

        	echo "Chip stdev: $stdev_Chip, Input stdev: $stdev_Input"
        	#total_stdev_nr_of_counts=$( echo "$stdev_Chip / $stdev_Input" | bc -l )
        	#StandardDeviation_Array[$nr_GEO,$nr_ID]=$total_stdev_nr_of_counts
        	StandardDeviationCHIP_Array[$nr_GEO,$nr_ID]=$stdev_Chip
        	StandardDeviationINPUT_Array[$nr_GEO,$nr_ID]=$stdev_Input
        	let nr_GEO=nr_GEO+1

	fi
done < <(tail -n +2 "$sampleshheet")


echo "done with the big loop that read the sample sheet" >> "test1.txt"
#echo "${Aaverage_Array[0,3]} \t ${Aaverage_Array[0,7]}"
printf "\n" >> "hg19_IntervalStats_result_v3.txt"
printf "\n" >> "hg19_IntervalStats_ChIPresult_v3.txt"
printf "\n" >> "hg19_IntervalStats_INPUTresult_v3.txt"
printf "\n" >> "hg19_IntervalStats_raw_result3.txt"

echo "nr_GEO = $nr_GEO, and counter2= $counter2" >> "test1.txt"
echo "outer loop contain this many iterations: $counter2 and inner loop contain this many interations: $nr_GEO " >> "test1.txt"
echo "nr of sequences: $nr_ID"  >> "test1.txt"

#To change language to english - was automated put there, I did not add that LANG. 
#LANG=en_us_8859_1
for ((m=0; m<=$nr_ID; m++)) 
do
		echo "loop1 - Seq nr: $m"
		echo "printing sequence ID names into files"
		printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_result_v3.txt"
		printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_ChIPresult_v3.txt"
		printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_INPUTresult_v3.txt"
    
		for ((h=0; h<=$nr_GEO+1; h++)) 
		do
				average=${Aaverage_Array[$h,$m]}
				average_chip=${Aaverage_ArrayCHIP[$h,$m]}
				average_input=${Aaverage_ArrayINPUT[$h,$m]}
				stdevChip=${StandardDeviationCHIP_Array[$h,$m]}
				stdevInput=${StandardDeviationINPUT_Array[$h,$m]}


				echo "loop2 - going through each GEO accession numbers"
				echo "empty? average: $average, stdev: $stdevChip and $stdevInput"

			if [ -z $average ] || [ -z $stdevChip ] || [ -z $stdevInput ] #-z is used to determine if a variable is empty
			then
					echo "something went wrong"
			else
					#echo "loop2"
					#echo "location when printing result into file: $(pwd)"
					#echo "before log: $average, $stdev"
					average_log=$(echo "l($average)/l(2)" | bc -l) #-l bc makes the script accept and handle decimal numbers 
					averageCHIP_log=$(echo "l($average_chip)/l(2)" | bc -l)
					averageINPUT_log=$(echo "l($average_input)/l(2)" | bc -l)
					stdevChip_log=$(echo "l($stdevChip)/l(2)" | bc -l)
					stdevInput_log=$(echo "l($stdevInput)/l(2)" | bc -l)
					#Average_log=$(bc -l <<< "l($average) / l(2)")
					#StandardDeviation_log=$(bc -l <<< "l($stdev) / l(2)")
					#echo "after log: $Average_log, $StandardDeviation_log\t"
					#printf "${Aaverage_Array[$h,$m]}\t${StandardDeviationCHIP_Array[$h,$m]}\t${StandardDeviationINPUT_Array[$h,$m]}\t" >> "hg19_IntervalStats_result_v3.txt"
					#echo "testar i loop"
					printf -- "${average_log}\t" >> "hg19_IntervalStats_result_v3.txt"
       				printf -- "${averageCHIP_log}\t${stdevChip_log}\t" >> "hg19_IntervalStats_ChIPresult_v3.txt"
       				printf -- "${averageINPUT_log}\t${stdevInput_log}\t" >> "hg19_IntervalStats_INPUTresult_v3.txt"
					echo "log: ${average_log}\t ${stdevChip_log}\t ${stdevInput_log}\t"
       				#echo "testar i loop"
					echo "${Aaverage_Array[$h,$m]}h\t ${StandardDeviationCHIP_Array[$h,$m]}h\t ${StandardDeviationINPUT_Array[$h,$m]}h\t"
       				#echo "${tableArray[$h,$m]}"
					echo "$h $m"
			fi
		done
    
		printf "\n" >> "hg19_IntervalStats_result_v3.txt"
		printf "\n" >> "hg19_IntervalStats_ChIPresult_v3.txt"
		printf "\n" >> "hg19_IntervalStats_INPUTresult_v3.txt"
		#echo "$m"
    
done

 
  
 
 
echo "printing result for raw result file:"
for ((t=0; t<=$counter2; t++)) 
do
		echo "printing sequence ID names into files"
		printf -- "${raw_IDnr[$t]}\t" >> "hg19_IntervalStats_raw_result3.txt"
		echo "Sequence ID name: ${raw_IDnr[$t]}" >> "test1.txt"
		#test:
		printf -- "${Raw_data_array[$t]}\t" >> "hg19_IntervalStats_raw_result3.txt"
		#test end
 		 printf "\n" >> "hg19_IntervalStats_raw_result3.txt" 
done

echo "done" >> "test1.txt"

echo "Ending script calculate intervalstatx. Ending time and date:"
date +"%T" 
$man date

echo "Perhanps also ending Pipeline. Ending time"
date +"%T" 

