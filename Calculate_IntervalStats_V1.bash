#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

# This script is under developement in order to make it faster

#Script 6 - calculate interval stats 


#####SBATCH -A b2015157
#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 05-00:00:00


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
printf "ID\t" > "hg19_IntervalStats_raw_result.txt"
sampleshheet=SampleSheet.txt


declare -A Aaverage_Array #declaring an empty array
declare -A Aaverage_ArrayCHIP
declare -A Aaverage_ArrayINPUT
declare -A arrayk_of_ID
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
	echo "Reading a row of sample sheet"

  	if [[ ${sampleshheetGEO[3]} != "Chip_Seq_input" ]]
  	then
	    ChipGEO=${sampleshheetGEO[0]}
        InputGEO=${sampleshheetGEO[7]}
        HistoneModification=${sampleshheetGEO[3]}

		#Adding the column header names to the different files 
        printf "${ChipGEO}/${InputGEO}_${HistoneModification} average\t" >> "hg19_IntervalStats_result_v3.txt"
        printf "${ChipGEO}_${HistoneModification} average\t${ChipGEO}_${HistoneModification} standard deviation\t" >> "hg19_IntervalStats_ChIPresult_v3.txt"
        printf "$InputGEO average\t$InputGEO standard deviation\t" >> "hg19_IntervalStats_INPUTresult_v3.txt"
        printf "${ChipGEO}_${HistoneModification}\t$InputGEO\tDivision\t" >> "hg19_IntervalStats_raw_result.txt"
        
        echo "location: $(pwd)"
        
        #Sorting based on ID (repetitive sequence) and keep header as first row (first row is not in the sorting process)
        head -1 $ChipGEO/$ChipGEO-hg19.IntervalStats.txt > $ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        sed 1d $ChipGEO/$ChipGEO-hg19.IntervalStats.txt | sort -f -s -k4,4 -k1,1 $ChipGEO/$ChipGEO-hg19.IntervalStats.txt >> $ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        head -1 $InputGEO/$InputGEO-hg19.IntervalStats.txt > $InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt
        sed 1d $InputGEO/$InputGEO-hg19.IntervalStats.txt | sort -f -s -k4,4 -k1,1 $InputGEO/$InputGEO-hg19.IntervalStats.txt >> $InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt

		#remove the unsorted $ChipGEO/$ChipGEO-hg19.IntervalStats.txt
		rm $ChipGEO/$ChipGEO-hg19.IntervalStats.txt
		rm $InputGEO/$InputGEO-hg19.IntervalStats.txt


        intervalStatsChip=$ChipGEO/$ChipGEO-hg19.IntervalStats-Sorted3.txt
        intervalStatsInput=$InputGEO/$InputGEO-hg19.IntervalStats-Sorted3.txt

        #intervalStatsChip=$GEO-hg19.intervalStatsChip.txt
	    counter2=0
	    counter3=0
	    nr_ID=0
        counter4=0

        #while IFS=$'\t' read -r -a intervalStatsChip
        while IFS=$'\t' read -r -a intervalStatsChip
        do
        	if ! read -u 3 inputfile2
            then
                break
            fi

            if [[ ${intervalStatsChip[6]} == "$ChipGEO-hg19.n1.wig" ]]
            then
                echo "first row (header) ignored"
            else

                #create array of each column in input file
                IFS=$':' intervalStatsInput=(${inputfile2//$'\t'/:})

                Chip_nr_counts=${intervalStatsChip[6]}
                Input_nr_counts=${intervalStatsInput[6]}
                chip_input_Division="Yes"

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
				
				# filling the new extra table file containing: Repetitive sequence, ChIP nr of counts, Input nr of counts, ChIP/Input  
				#Wrong to fill it here! do array instead 
				#printf "${intervalStatsChip[3]}\t$Chip_nr_counts\t$Input_nr_counts\t$chip_input_Division" >> "hg19_IntervalStats_raw_result.txt"
				Raw_data_array[$counter2]="${intervalStatsChip[3]}\t$Chip_nr_counts\t$Input_nr_counts\t$chip_input_Division"
				let counter2=counter2+1


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
                            	let nr_ID=nr_ID+1
				                IDnr=${intervalStatsChip[3]}

				                counter3=1
				                echo "$IDnr   $counter3"
                            	arrayk_of_ID[$id_counter]=$IDnr
                            	let id_counter=id_counter+1
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
        #
        

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

echo "done with the big loop that read the sample sheet"
#echo "${Aaverage_Array[0,3]} \t ${Aaverage_Array[0,7]}"
printf "\n" >> "hg19_IntervalStats_result_v3.txt"
printf "\n" >> "hg19_IntervalStats_ChIPresult_v3.txt"
printf "\n" >> "hg19_IntervalStats_INPUTresult_v3.txt"
printf "\n" >> "hg19_IntervalStats_raw_result.txt"

echo "nr of sequences: $nr_ID" 

#To change language to english - was automated put there, I did not add that LANG. 
#LANG=en_us_8859_1
for ((m=0; m<=$nr_ID; m++)) 
do
	echo "loop1 - Seq nr: $m"
	echo "printing sequence ID names into files"
    printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_result_v3.txt"
    printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_ChIPresult_v3.txt"
    printf "${arrayk_of_ID[$m]}\t" >> "hg19_IntervalStats_INPUTresult_v3.txt"
   	echo "printing result for raw result file"
    printf "${Raw_data_array[$m]}\t" >> "hg19_IntervalStats_raw_result.txt"
    
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
	printf "\n" >> "hg19_IntervalStats_raw_result.txt"
    #echo "$m"
    
done


echo "Ending script calculate intervalstatx. Ending time and date:"
date +"%T" 
$man date

echo "Perhanps also ending Pipeline. Ending time"
date +"%T" 

