#!/bin/bash

# Xinhai Ye, yexinhai@zju.edu.cn

input_table_list=./input_table/input.list

for i in `cat $input_table_list`
do
	mkdir $i
	cd $i
	ln -s ../branch_length_raxml.pl .
	ln -s ../input_table/$i .
	bsub -n 1 -oo branch.log -eo branch perl branch_length_raxml.pl ../all.pep.fasta $i
	cd ..
done
