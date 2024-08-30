# process picrust results, to merge OTU to genus level
perl 1-ICb.mouse.step1.pl
perl 1-ICb.human.step1.pl

# match COG to each genus, get the median or mean value of relative abundance in MA group and control group
perl 2-ICb.step2.pl

# get ICb for each genus to each COG table
Rscript 3-ICb.step3.R
