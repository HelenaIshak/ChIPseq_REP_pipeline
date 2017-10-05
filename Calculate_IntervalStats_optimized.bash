#!/bin/bash


# Made by Helena Ishak, 2016-2017
# Created in the context of my master thesis project in bioinformatics, regarding the development of a chip-seq analyzing pipeline.
# Any use of this script, or part of it, should include proper reference to this work and its author.

# This script is under developement - an optimised version of Calculate_intervalStats.bash script. 



#SBATCH -p core
#SBATCH -n 5
#SBATCH -t 02:00:00

proj_adress_backup=$1
proj_adress_NObackup=$2

echo "Starting the calculation intervalstats script. Starting time and date"
date +"%T" 
$man date


echo "location (expected nobackup): $(pwd)"
cd Sample_folder

#######
#echo "before removal of files: $(ls -la)"
#rm hg19_IntervalStats_RAW_NEW.txt
#rm temp.txt
rm hg19_IntervalStats_SUM_NEW.txt
rm temp2.txt 
#
#
#
#echo "after removal of files: $(ls -la)"
#
#
#
GEOsampleNames=$(awk '{ printf $1 " " }' <(tail -n +2 SampleSheet.txt)) #why not splitting directly into an array?
IFS=', ' read -r -a GEOsamples <<< "$GEOsampleNames" #create array of variable
#echo "first and second GEO accession nr: ${GEOsamples[0]} ${GEOsamples[1]}"
#touch hg19_IntervalStats_RAW_NEW.txt #to createe an empty file 
touch hg19_IntervalStats_SUM_NEW.txt
#
#Rep_header=0
#
##To fix in this loop: a first empty column exist, do so that this empty column is removed. 
##Loop that create an intervalstat file containing all the raw data of all experiments in one file
#for i in "${GEOsamples[@]}"
#do
#  fileX=$i/$i-hg19.IntervalStats-Sorted3.txt
#  echo "$fileX"
#  
#  if [[ $Rep_header -eq 0 ]]; then
#      echo "header and $i"
#      #fileX=$i/$i-hg19.IntervalStats-Sorted3.txt
#      #echo "$fileX"
#      paste hg19_IntervalStats_RAW_NEW.txt <(awk '{print $4, "\t", $7}' $fileX ) > temp.txt
#      #cat temp.txt > hg19_IntervalStats_RAW_NEW.txt
#      Rep_header=1
#  else
#      echo "$i"
#      #fileX=$i/$i-hg19.IntervalStats-Sorted3.txt
#      #echo "$fileX"
#      paste hg19_IntervalStats_RAW_NEW.txt <(awk '{print $7}' $fileX ) > temp.txt
#      #cat temp.txt > hg19_IntervalStats_RAW_NEW.txt
#  fi
#  cat temp.txt > hg19_IntervalStats_RAW_NEW.txt
#done


#Loop that calculate the average of all repetitive sequences for all experiments and prints them into one file
Rep_header=0
numberGEO=${#GEOsamples[@]}
#m=2 because of starting with column 2. 
for (( m=2; m<=$numberGEO; m++ ))
do  
    	#SENASTE: if [[ $((m % 2)) == 0 ]]; then 	#Egentligen ska vi inte ha två experiment i taget, vi borde snarare ha 1 input + X ChIP
    		echo "m: $m" 
    		
       #If it's the first file we want the first column (rep header) and "second" column (result numbers)
    		if [[ $Rep_header -eq 0 ]]; then
      			echo "header and ChIP number (column): $m"
      			h=$(($m+1))
      			paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR==1 {print } NR>1{sumChIP[$1]+=$'$m'; n[$1]++}END{for (i in sumChIP){print i, sumChIP[i] / n[i] "hej"; {sumChIP[$1] = 0 }}}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt 
            #paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR==1 {print }' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt
            #SENASTE: paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR==1 {print } NR>1{sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print i, sumChIP[i] / n[i] "hej", sumInput[i] / n[i] "hej"; {sumChIP[$1] = 0; sumInput[$1] = 0 }}}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt 
      			#paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR==1 {print } NR>1{sumChIP[$1]+=$'$m'; n[$1]++}END{for (i in sumChIP){print i, sumChIP[i] / n[i] }}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt 
      			Rep_header=1
      		
         #If it's the NOT first file we don't want the first column (rep header), we only want the "second" column (result numbers)
      		else
       	 		h=$(($m+1))
       	 		echo "ChIP number (column): $m"
       	 		#echo "uneven number (ChIP): $m"
        		#echo "even number (Input): $h"
        		#echo "Welcome $h times"
        		#awk '{a[$1]+=$'$c'}END{for (i in a){print i,a[i]}}' hg19_IntervalStats_RAW_NEW.txt | sort -k2 > hg19_IntervalStats_SUM_NEW.txt
        		#Calculate the average (sum rep1 / number rows rep1) for each row of same repetitive sequence. NR=1 is header (to keep it as it is) 
        		paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR>1 {sumChIP[$1]+=$'$m'; n[$1]++}END{for (i in sumChIP){print sumChIP[i] / n[i]; {sumChIP[$1] = 0 }}}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt
            #SENASTE: paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR>1 {sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print sumChIP[i] / n[i]; sumInput[i] / n[i]; {sumChIP[$1] = 0; sumInput[$1] = 0 }}}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt
        		#echo "" > temp2.txt
        		#paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR>1 {sumChIP[$1]+=$'$m'; n[$1]++}END{for (i in sumChIP){print sumChIP[i] / n[i] }}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt
        		#paste hg19_IntervalStats_SUM_NEW.txt <(awk 'NR==1 {print } NR>1 {sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print i, sumChIP[i] / n[i], sumInput[i] / n[i] }}' hg19_IntervalStats_RAW_NEW.txt ) > temp2.txt
        		#awk 'NR==1 {print } NR>1 {sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print i, sumChIP[i] / n[i], sumInput[i] / n[i] }}' hg19_IntervalStats_RAW_NEW.txt > temp2.txt
        		#awk '{sumChIP[$1]+=$'$h'; sumInput[$1]+=$'$m'; n[$1]++}END{for (i in sumChIP){print i, sumChIP[i]  / n[i], sumInput[i] / n[i]}}' hg19_IntervalStats_RAW_NEW.txt | sort -k2 > temp2.txt
        
    		fi
    	#SENASTE: fi
    cat temp2.txt > hg19_IntervalStats_SUM_NEW.txt
done


head -1 hg19_IntervalStats_SUM_NEW.txt > hg19_IntervalStats_SUM_NEW_sorted.txt
sed 1d hg19_IntervalStats_SUM_NEW.txt | sort -k1 hg19_IntervalStats_SUM_NEW.txt >> hg19_IntervalStats_SUM_NEW_sorted.txt



# To test on the control panel: cd /proj/b2015157/nobackup/helena
#a=4
#b=0
#for (( m=1; m<=$a; m++ ))
#do
#	if [[ $((m % 2)) == 0 ]]; then
#		echo "m: $m"
#		if [[ $b -eq 0 ]]; then
#			echo "first row"
#			h=$(($m+1))
#			awk 'NR==1 {print } NR>1{sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print i, sumChIP[i] / n[i], sumInput[i] / n[i] }}' testCalc1.txt
#			b=1
#		else
#			h=$(($m+1))
#			awk 'NR>1 {sumChIP[$1]+=$'$m'; sumInput[$1]+=$'$h'; n[$1]++}END{for (i in sumInput){print sumChIP[i] / n[i], sumInput[i] / n[i] }}' testCalc1.txt
#		fi
#	fi
#done 


#Pseudo code for normalization (ChIP/Input) with multiple ChIPs:
#loop column x, x<=$numberGEO, x++
# if x[header]=input; then
#		t=(awk ....x)
# else
#		awk x / $t	> print to paper 
# fi




#Header chip input
#da 3.5 1.5 2
#ki 5.75 1.75 4
#hej 1.33333 2.33333 3




echo "done location (expected nobackup): $(pwd)"
echo "ending the calculation intervalstats script. ending time and date"
date +"%T"  
$man date