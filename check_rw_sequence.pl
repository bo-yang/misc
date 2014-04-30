#!/usr/bin/perl

#######################################################
# Check the output sequence of Readers/writers problem.
#######################################################

use strict;
use Getopt::Long;
use FindBin qw($Bin);
use Cwd 'abs_path';

my $READER_NUM=6;	# Number of readers
my $WRITER_NUM=4;
my $READER_CS_TIMES=6;	# Times of entering critical
my $WRITER_CS_TIMES=3;

my $input;

GetOptions(
	'input|i=s'	=>	\$input
);

open IN, "<$input" or die("ERROR: failed to open file $input");

# The standard to judge if sequence conflict happens:
# 	no writer can enter the critical section when readers in, and
# 	no readers can enter the critical section when writers in.
my $wrong_reader_seq=0;
my $wrong_writer_seq=0;

my $reader_stack=0;
my $writer_stack=0;
my $readers={};
my $writers={};
my $conflict_num;

while(my $line=<IN>) {
	chomp $line;
	$line =~ m/(\d+)/;
	my $num=$1;
	if($line =~ /^[Rr]eader.*/) {
		# Count readers in critical section
		if($line =~ /enter.*/){
			# Check writers in critical section
			if($writer_stack !=0 ) {
				$wrong_reader_seq=1;
				$conflict_num=$num;
			}

			$reader_stack++;

			# Count reader numbers
			if(not $readers->{$num}) {
				$readers->{$num}=1;
			} else {
				$readers->{$num}++;
			}
		} elsif($line =~ /leave.*/){
			$reader_stack--;
		}
	} elsif($line =~ /^[Ww]riter.*/) {
		# Count writers in critical section
		if($line =~ /enter.*/){
			# Check readers in critical section
			if($reader_stack !=0 ) {
				$wrong_writer_seq=1;
				$conflict_num=$num;
			}

			$writer_stack++;

			# Count writer numbers
			if(not $writers->{$num}) {
				$writers->{$num}=1;
			} else {
				$writers->{$num}++;
			}
		} elsif($line =~ /leave.*/){
			$writer_stack--;
		}
	}
}

close IN;

my $num_readers=keys %{$readers};
my $num_writers=keys %{$writers};
my $msg="$num_readers readers enters cs $readers->{1} times, $num_writers writers enters cs $writers->{1} times";
if($wrong_reader_seq != 0) {
	$msg="$msg, reader $conflict_num conflicts writer!";
} elsif($wrong_writer_seq != 0) {
	$msg="$msg, writer $conflict_num conflicts reader!";
} else {
	$msg="$msg, R/W sequence correct.";
}

print STDOUT "$msg\n";
