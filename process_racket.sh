#!/bin/bash

#
# process_racket_prog - Automatically run Racket program for grading.
#
# This script assumes that:
#	1. all defined Racket functions are stored in a single file;
#	2. there is a file names test_commands which contains the test
#		commands for the defined functions and expected outputs, 
#		such as:
#			;list-length
#			;Expected: 12
#			(list-length (list 1 2 3 4 5 "a" "b" "c" "d" "e" (cons "a" 1) "a bridge too far"))
#		
#		The test commands will be inseted into each submitted Racket 
#		file and executed one-by-one.
#	3. racket is installed in your PATH so that it can be called directly.
#
#
# Author: Bo Yang, 03/22/2014, version 1 
# E-mail: bonny95@gmail.com
#

##################################
#	MAIN STARTS HERE
##################################
indir=$(pwd)	# input dir
output="LISP_prog_result.out"
test_cmds=./test_cmds.rkt

while getopts i:o:t: c
do
	case ${c} in 
	i) indir=${OPTARG};;
	o) output=${OPTARG};;
	?) # Unknown option
		echo "process_racket_prog -i <in_dir> -o <output>"
		exit;;
	esac
done

> $output

# process racket files
ls $indir/*.rkt | rename 's/ /_/g' > /dev/null 2>&1
ls $indir/*.lsp | rename 's/(/_/g' > /dev/null 2>&1
ls $indir/*.txt | rename 's/)/_/g' > /dev/null 2>&1
for file in $(ls $indir/*.rkt $indir/*.lsp $indir/*.txt)
do
	fname=${file##*/}
	echo "===================== $fname =======================" >> $output
	# Read test commands and test each function
	while read line
	do
		if [[ "$line" == \;* ]]
		then
			#comments
			echo ${line#;} >> $output
		else
			tmpfile=.${file##*/}
			cp $file $tmpfile

			# Replace the specified lang by #lang racket.
			# Insert #lang in case it is not specified.
			perl -i -p -e 's/^\#lang.*//g;' $tmpfile
			echo "#lang racket"|cat - $tmpfile > .temp && mv .temp $tmpfile

			# 
			echo $line >> $tmpfile
			racket $tmpfile >> $output 2>&1 & # Assume racket is in your PATH
			RACKETPID=$!

			# Check for infinite loop
			cnt=0
			re='^[0-9]+$'
			while [ "$cnt" -lt 10 ]
			do
				pid=$(ps -eaf|grep racket|grep ${tmpfile}|awk '{print $2}')
				if [[ $pid =~ $re ]] && [ "$pid" -eq "$RACKETPID" ]
				then
					sleep 1
				else
					break
				fi
				cnt=$((cnt+1))
			done
	
			if [ "$cnt" -ge 10 ]
			then
				echo "ERROR: Infinite loop detected!" >> $output
				kill -9 $RACKETPID
			fi

			echo "" >> $output

			rm -f $tmpfile
		fi
		
	done < $test_cmds

	echo "" >> $output
done


echo "Done!"
