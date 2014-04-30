#!/bin/bash

# Process BACI program for grading.
#
# Author: Bo Yang, January 2014, version 1
# E-mail: bonny95@gmail.com

#
# Check that if the BACI program could be successfully built.
#
function build_baci_file {
	file=$1
	seq_msg=
	retval=1 # compile failure
	tmplog=".baci_tmp"
	> $tmplog

	# Replace "empty" to avoid a Linux BACI bug
	#perl -i -p -e "s/\bempty\b/empty1/;" $file
	bacc $file > $tmplog 2>&1
	flag=$(perl -i -p -e "print STDOUT \"yes\" if m/^Compilation listing is stored in.*/;" $tmplog)
	if [ "$flag" == "yes" ]
	then 
		flag="no"
		bainterp ${file%%.cm} > $tmplog 2>&1 &
		BAINTPID=$!

		cnt=0
		re='^[0-9]+$'
		while [ "$cnt" -lt 5 ]
		do
			pid=$(ps -eaf|grep bainterp|grep ${file%%.cm}|cut -d' ' -f2)
			if [[ $pid =~ $re ]] && [ "$pid" -eq "$BAINTPID" ]
			then
				sleep 2
			else
				break
			fi
			cnt=$((cnt+1))
		done

		if [ "$cnt" -ge 5 ]
		then
			retval=2 # deadlock
			kill -9 $BAINTPID
		else		
			retval=0 # Success
		fi

		# Check the correctness of output sequence
		seq_msg=$(./check_rw_sequence.pl -i $tmplog)
	fi

	rm -f $tmplog

	case $retval in
		0)	echo "$file: successfully built, $seq_msg";;
		1)	echo "$file: compile failure, $seq_msg";;
		2)	echo "$file: deadlock, $seq_msg";;
	esac
}

##################################
#	MAIN START HERE
##################################
indir=$(pwd)	# input dir
output="$indir/BACI_HW_output.txt"
> $output

while getopts i:o: c
do
	case ${c} in 
	i) indir=${OPTARG};;
	o) output=${OPTARG};;
	?) # Unknown option
		echo "process_baci_prog -i <in_dir> -o <output>"
		exit;;
	esac
done

# process zip files
ls $indir/*.zip | rename 's/ /_/g' > /dev/null 2>&1
ls $indir/*.zip | rename 's/(/_/g' > /dev/null 2>&1
ls $indir/*.zip | rename 's/)/_/g' > /dev/null 2>&1
for file in $(ls $indir/*.zip)
do
	echo $file
	cd $indir

	dir=${file%%.zip}
	mkdir -p $dir
	mv $file $dir
	cd $dir
	unzip ${file##*/}
done

cd $indir

# process baci programs
cd $indir
ls *.cm | rename 's/ /_/g' 
for f in $(ls *.cm)
do
	ret=$(build_baci_file $f)
	echo $ret >> $output
done

# process directories
ls -d */ | rename rename 's/ /_/g' > /dev/null 2>&1
ls -d */*/ | rename rename 's/ /_/g' > /dev/null 2>&1
ls -d */*/*/ | rename rename 's/ /_/g' > /dev/null 2>&1
ls -d */*/*/*/ | rename rename 's/ /_/g' > /dev/null 2>&1
dir1=$(ls -d */)
dir2=$(ls -d */*/) 
dir3=$(ls -d */*/*/) 
dir4=$(ls -d */*/*/*/) 
all_dirs="$dir1 $dir2 $dir3 $dir4"
for dir in $all_dirs
do
	echo "Processing directory $dir ..."

	ls $dir/*.cm | rename 's/ /_/g' > /dev/null 2>&1
	ls $dir/*.cm | rename 's/(/_/g' > /dev/null 2>&1
	ls $dir/*.cm | rename 's/)/_/g' > /dev/null 2>&1
	for f in $(ls $dir/*.cm)
	do
		ret=$(build_baci_file $f)
		echo $ret >> $output
	done
done

echo "Done!"
