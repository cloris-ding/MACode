#!/usr/bin/perl -w
use strict;

my %hashmouse=();
open FILE, "<cog_metagenome_contributions_mouse_genus.tab" or die $!;
readline FILE;
while (<FILE>) {
	chomp;
	my @a=split /\t/;
	my $cog=$a[0];
	my $group=$a[2];
	my $taxa=$a[3];
	my $ab=$a[4];
	my $key=join("\t",$cog,$group,$taxa);
	if (not exists $hashmouse{$key}) {
		$hashmouse{$key}=$ab;
	}
	elsif (exists $hashmouse{$key}) {
		my $tmp=$hashmouse{$key};
		$hashmouse{$key}=join(",",$tmp,$ab);
	}
}
close FILE;

open OUT, ">cog_group_genus_mouse.txt" or die $!;
print OUT "COG\tGroup\tGenus\tMedian\tMean\n";
foreach my $key (sort {$a cmp $b} keys %hashmouse) {
	my $value=$hashmouse{$key};
	my @v=split(",",$value);
	my $median_value=fun_median(@v);
	my $mean_value=fun_mean(@v);
	print OUT "$key\t$median_value\t$mean_value\n";
}
close OUT;


my %hashhuman=();
open FILE, "<cog_metagenome_contributions_human_genus.tab" or die $!;
readline FILE;
while (<FILE>) {
	chomp;
	my @a=split /\t/;
	my $cog=$a[0];
	my $group=$a[2];
	my $taxa=$a[3];
	my $ab=$a[4];
	my $key=join("\t",$cog,$group,$taxa);
	if (not exists $hashhuman{$key}) {
		$hashhuman{$key}=$ab;
	}
	elsif (exists $hashhuman{$key}) {
		my $tmp=$hashhuman{$key};
		$hashhuman{$key}=join(",",$tmp,$ab);
	}
}
close FILE;

open OUT, ">cog_group_genus_human.txt" or die $!;
print OUT "COG\tGroup\tGenus\tMedian\tMean\n";
foreach my $key (sort {$a cmp $b} keys %hashhuman) {
	my $value=$hashhuman{$key};
	my @v=split(",",$value);
	my $median_value=fun_median(@v);
	my $mean_value=fun_mean(@v);
	print OUT "$key\t$median_value\t$mean_value\n";
}
close OUT;

# get median
sub fun_median {
	my @array_numeric=@_;
	my $len=@array_numeric;
	my @array_sort=sort {$a <=> $b} @array_numeric;
	my $median_value=0;
	if ($len%2==1) {
		my $arrow=($len-1)/2;
		$median_value=$array_sort[$arrow];
	}
	elsif ($len%2==0) {
		my $arrow2=$len/2;
		my $arrow1=($len/2)-1;
		$median_value=sprintf "%0.2f", ($array_sort[$arrow1]+$array_sort[$arrow2])/2;
	}
	return $median_value;
}

# get mean
sub fun_mean {
	my @array_numeric=@_;
	my $count=@array_numeric;
	my $sum=0;
	foreach my $value ( @array_numeric) {
		$sum+=$value;
	}
	my $mean_value=sprintf "%0.2f", $sum/$count;
	return $mean_value;
}
