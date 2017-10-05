#!/bin/bash

# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

#Script 5 - calculate idxstat

####SBATCH -A b2015157
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 01:00:00

function sumColumn {
  echo "in the function sumColumn now"
  idxStathChip=$ChipGEO/$ChipGEO-REP.idxstats.txt
  idxStatInput=$InputGEO/$InputGEO-REP.idxstats.txt

  Sum_Chip_column=0
  Sum_Input_column=0
  counteer2=0

  #reading two different files line by line at same time to fix sum of input and chip
  while IFS=$'\t' read -r -a idxStatColumnCHIP
  do
      if ! read -u 3 inputfille
      then
          break
      fi
      IFS=$':' idxStatColumnINPUT=(${inputfille//$'\t'/:})
      echo "Chip: ${idxStatColumnCHIP[2]}, Input: ${idxStatColumnINPUT[2]}"

      if [[ ${idxStatColumnINPUT[2]} -lt 10 ]]
      then
         inputnr=0
         chipnr=0
      else
         inputnr=${idxStatColumnINPUT[2]}
         chipnr=${idxStatColumnCHIP[2]}
      fi
      let Sum_Chip_column=Sum_Chip_column+chipnr
      let Sum_Input_column=Sum_Input_column+inputnr

      #To save all the repetetive sequence names in right order as column 1
      if [[ $number -eq 0 ]]
           then
               tableeArray[$counnter1,$counteer2]=${idxStatColumnCHIP[0]}
               let counteer2=counteer2+1
      fi

  done < $idxStathChip 3< $idxStatInput
}





#Passed variables: "$proj_adress_backup" "$proj_nr" "$proj_adress_NObackup"
proj_adress_backup=$1
proj_adress_NObackup=$2

echo "Starting the calculate idxstat script. Start time:"
date +"%T" 

#Checking samplesheet.txt to find GSM for chip and its attached input and for both
#calling this script when all files are done mapped. I also need to be placed in Sample_fo�der.
echo "location (expected nobackup): $(pwd)"
cd Sample_folder
#creating the new text file containing the calculated idxstat result
printf "Rep-seq\t" > "Rep_IdxSthaat_result.txt"

samplesheet=SampleSheet.txt
number=0
counnter1=0
declare -A tableeArray

#The -r tells read that \ isnt special in the input data; the -a myArray tells it to split the input-line into words and store the results in myArray; and the IFS=$\t tells it to use only tabs to split words, instead of the regular Bash default of also allowing spaces to split words as well.
while IFS=$'\t' read -r -a sAmplesheetGEO
do
	echo "in loop"
	echo "test: ${sAmplesheetGEO[3]}"

  if [[ ${sAmplesheetGEO[3]} != "Chip_Seq_input" ]] #&& [ ${sAmplesheetGEO[3]} != "Experiment_type" ]
  then
       ChipGEO=${sAmplesheetGEO[0]}
       InputGEO=${sAmplesheetGEO[7]}
       HistoneModification=${sAmplesheetGEO[3]}
       echo "this experiment for header: ${ChipGEO}/${InputGEO}_${HistoneModification}"
       #echo -n "$ChipGEO/$InputGEO  " >> "Rep_IdxSthaat_result.txt"
       printf "${ChipGEO}/${InputGEO}_${HistoneModification}\t" >> "Rep_IdxSthaat_result.txt"

       #Calculating the sum of all the # of reads in the idxstat for this CHIP
       echo "calling function sumColumn now"
       sumColumn

       echo "NEW sum of chip column: $Sum_Chip_column"
       echo "NEW sum of input column: $Sum_Input_column"

       if [[ $counnter1 -eq 0 ]]
       then
             counnter1=1
       fi

       counteer2=0
       while IFS=$'\t' read -r -a idxStatColumnCHIP
       do
           if ! read -u 3 inputfille
           then
               break
           fi
           IFS=$':' idxStatColumnINPUT=(${inputfille//$'\t'/:})

           #echo -e "" >> "Rep_IdxSthaat_result.txt"                            #-e means new line on next echo, continue on next row next time
           #echo -n "$idxStatColumnCHIP[0]\t" >> "Rep_IdxSthaat_result.txt"      #-n means no new lines on next echo, continue on same row next time


           if [[ ${idxStatColumnINPUT[2]} -lt 10 ]]
           then
                   Input_nr_of_reads=0
                   Chip_nr_of_reads=0
           else
                   Input_nr_of_reads=${idxStatColumnINPUT[2]}
                   Chip_nr_of_reads=${idxStatColumnCHIP[2]}
           fi

           
           if [[ $Sum_Chip_column -eq 0 ]]
           then
                 idxstat_partly_resultCHIP=0
           else
                 idxstat_partly_resultCHIP=$( echo "$Chip_nr_of_reads / $Sum_Chip_column" | bc -l )
           fi

           #if [ $Sum_Input_column -eq 0 ] || [$Input_nr_of_reads -eq 0 ]
           if [ $(echo "$Sum_Input_column == 0" | bc) -ne 0 ] || [ $(echo "$Input_nr_of_reads == 0" | bc) -ne 0 ] #bc is used to handle float numbers, else error
           then
                 idxstat_partly_resultINPUT=0
           else
                 idxstat_partly_resultINPUT=$( echo "$Input_nr_of_reads / $Sum_Input_column" | bc -l )
           fi

	   #bc makes it possible to handle float numbers. 
	   if [ $(echo "$idxstat_partly_resultINPUT == 0" | bc) -ne 0 ]
           then
                 IdxSthaat_result=NaN
           else
                 IdxSthaat_result=$( echo "$idxstat_partly_resultCHIP / $idxstat_partly_resultINPUT" | bc -l ) #This gives the percentage of reads that fall into this Rep-seq: $idxStatColumnCHIP[0]
           fi


           tableeArray[$counnter1,$counteer2]=$IdxSthaat_result
           echo "Result # reads for $ChipGEO/$InputGEO = $IdxSthaat_result"
           echo "array - same value: ${tableeArray[$counnter1,$counteer2]}"

           let counteer2=counteer2+1
       done < $idxStathChip 3< $idxStatInput

       let number=number+1
       let counnter1=counnter1+1
       #cd ..
       #echo -n "$IdxSthaat_result\t" >> "Rep_IdxSthaat_result.txt"
       #for i in "${arrayLinks[@]}"
       #do
       #    echo -e "$idxStatColumnCHIP[0]\t$IdxSthaat_result " >> "Rep_IdxSthaat_result.txt"
       #done
   fi
   echo "first row done on samplesheet"
done < <(tail -n +2 "$samplesheet")   #OBS! make sure the samplesheet has an empty row as the last row, else the full last row will not be read!!!

let counnter1=counnter1-1


#echo -e " " >> "Rep_IdxSthaat_result.txt"                            #-e means new line on next echo, continue on next row next time
printf "\n" >> "Rep_IdxSthaat_result.txt"

echo "counnter1 = $counnter1"
echo "counteer2 = $counteer2"


for ((m=0; m<=$counteer2; m++)) do
    echo "loop1"
    for ((h=0; h<=$counnter1; h++)) do
    #    echo "loop2"
         echo "location when printing result into file: $(pwd)"
         if [ ${tableeArray[$h,$m]} == "NaN" ] || [ $h -eq 0 ]
         then
               value_kIdxstat=${tableeArray[$h,$m]}
         else
               value_kIdxstat=$(echo "l(${tableeArray[$h,$m]})/l(2)" | bc -l)
         fi
         #echo -n "${tableeArray[$h,$m]}  " >> "Rep_IdxSthaat_result.txt"
         #printf "${tableeArray[$h,$m]}\t" >> "Rep_IdxSthaat_result.txt"
         printf -- "$value_kIdxstat\t" >> "Rep_IdxSthaat_result.txt" #-- is being interpreted as an option (in this case, to signify that there are no more options).
         echo "$value_kIdxstat"
         echo "h: $h"

    done
    #echo -e " " >> "Rep_IdxSthaat_result.txt"
    printf "\n" >> "Rep_IdxSthaat_result.txt"
    echo "m: $m"
done

echo "Ending script calculate idxstat. Ending time"
date +"%T" 



