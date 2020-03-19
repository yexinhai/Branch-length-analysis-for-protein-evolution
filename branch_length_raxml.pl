#!/usr/bin/perl -w
use strict;

#用法：perl 程序.pl all.pep.fasta 1_1_1_group_sorted.txt
#读所有物种的序列；

sub Usage(){
	print STDERR "
	branch_length_raxml.pl <all.pep.fasta> <1_1_1_group_sorted.txt>
	\n";
	exit(1);
}
&Usage() unless $#ARGV==1;


my $genename;
my %hash_1;

open my $fasta1, "<", $ARGV[0] or die "Can't open file!";
while (<$fasta1>) {
	chomp();
	if (/^>(\S+)/){
		$genename = $1;
	} else {
		$hash_1{$genename} .= $_;
	}
}
close $fasta1;

`mkdir branch_result`;

open my $Group, "<", $ARGV[1] or die "Cant't open group file!";
while (<$Group>) {
	chomp();
	my @array1 = split /\s/, $_;
	my $group_nogood = shift @array1;
	my @array2 = split /:/, $group_nogood;
	my $group = $array2[0];
	`mkdir $group`;
	open OUT1, ">","$group\.pep.fasta";
	foreach (@array1) {
		print OUT1 ">".$_."\n".$hash_1{$_}."\n";
	}
	close OUT1;
	
	`mv $group\.pep.fasta $group`;
	`mafft --auto $group/$group\.pep.fasta >$group\/$group\.pep.mafft.fasta`;
	`trimal -in $group\/$group\.pep.mafft.fasta -out $group\/$group\.pep.mafft.trimal.fasta -automated1`;
	open my $seq, "<", "$group\/$group\.pep.mafft.trimal.fasta" or die "can't open mafft.trimal.fasta in $group !\n";
	open OUT2, ">", "$group\/$group\.pep.mafft.trimal.changename.fasta";
	while (<$seq>) {
		chomp();
		if (/^>(\w\w\w\w)\S+/) {
			print OUT2 ">".$1."\n";
		} else {
			print OUT2 $_."\n";
		}
	}
	close $seq;
	close OUT2;
	chdir "./$group";
	print "Start: $group\n";
	`raxmlHPC-PTHREADS-AVX2 -T 1 -p 12345 -m PROTGAMMAIJTT -s $group\.pep.mafft.trimal.changename.fasta -f e -o Pvin -n $group -t ../../fixed_tree.txt`;
	print "Done: $group\n";
	`cp RAxML_result.$group ../branch_result`;
	print "where is next!?\n";
	chdir "..\/";
}
close $Group;




