#!/usr/bin/perl -w
use strict;

my %hash_group=();
open D, "<design.human.txt" or die $!;
readline D;
while (<D>) {
	chomp;
	my @a=split /\t/;
	my $sample=$a[0];
	my $group=$a[3];
	$hash_group{$sample}=$group;
}
close D;

my %hash_taxa=();
open IN, "<level6_match_otu_human.txt" or die $!;
readline IN;
while (<IN>) {
	chomp;
	my @a=split /\t/;
	my $otu=$a[0];
	my $taxa=$a[2];
	$hash_taxa{$otu}=$taxa;
}
close IN;

my %hash=();
open FILE, "<cog_metagenome_contributions_human.tab" or die $!;
readline FILE;
while (<FILE>) {
	chomp;
	my @a=split /\t/;
	my $cog=$a[0];
	my $sample=$a[1];
	my $otu=$a[2];
	my $ab=$a[5];
	my $group=$hash_group{$sample};
	my $taxa=$hash_taxa{$otu};

	my $key=join("\t",$cog,$sample,$group,$taxa);
	$hash{$key}+=$ab;
}
close FILE;

open OUT, ">cog_metagenome_contributions_human_genus.tab" or die $!;
print OUT "COG\tSample\tGroup\tTaxa\tAbundance\n";
foreach my $key (sort {$a cmp $b} keys %hash) {
	print OUT "$key\t$hash{$key}\n";
}
close OUT;
