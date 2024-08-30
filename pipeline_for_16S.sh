# import data to qiime one data by one data
qiime tools import --type MultiplexedPairedEndBarcodeInSequence --input-path  Rawdata/mal1-paired --output-path  1-import/mal1-paired.qza
qiime tools import --type MultiplexedPairedEndBarcodeInSequence --input-path  Rawdata/mal2-paired --output-path  1-import/mal2-paired.qza
...
...
qiime tools import --type MultiplexedPairedEndBarcodeInSequence --input-path  Rawdata/mal14-paired --output-path  1-import/mal14-paired.qza

# trim data, split samples and summarize
qiime cutadapt demux-paired --i-seqs 1-import/mal1-paired.qza --m-forward-barcodes-file mal1-metadata.tsv --m-forward-barcodes-column FwdBarcode --p-error-rate 0 --o-per-sample-sequences 2-demux/mal1-demultiplexed-seqs.qza --o-untrimmed-sequences 2-demux/mal1-undemuxed-seqs.qza --verbose
qiime cutadapt demux-paired --i-seqs 1-import/mal2-paired.qza --m-forward-barcodes-file mal2-metadata-filter.tsv --m-forward-barcodes-column FwdBarcode --p-error-rate 0 --o-per-sample-sequences 2-demux/mal2-demultiplexed-seqs.qza --o-untrimmed-sequences 2-demux/mal2-undemuxed-seqs.qza --verbose
...
...
qiime cutadapt demux-paired --i-seqs 1-import/mal14-paired.qza --m-forward-barcodes-file mal14-metadata.tsv --m-forward-barcodes-column FwdBarcode --p-error-rate 0 --o-per-sample-sequences 2-demux/mal14-demultiplexed-seqs.qza --o-untrimmed-sequences 2-demux/mal14-undemuxed-seqs.qza --verbose

qiime demux summarize --i-data 2-demux/mal1-demultiplexed-seqs.qza --o-visualization 2-demux/mal1-demultiplexed-seqs.qzv
qiime demux summarize --i-data 2-demux/mal2-demultiplexed-seqs.qza --o-visualization 2-demux/mal2-demultiplexed-seqs.qzv
...
...
qiime demux summarize --i-data 2-demux/mal14-demultiplexed-seqs.qza --o-visualization 2-demux/mal14-demultiplexed-seqs.qzv

# remove barcode, spacer and primer
qiime cutadapt trim-paired --i-demultiplexed-sequences 2-demux/mal1-demultiplexed-seqs.qza --p-front-f GTGYCAGCMGCCGCGGTAA --p-front-r GGACTACNVGGGTWTCTAAT --o-trimmed-sequences 3-cutad/mal1-trimmed-seqs.qza --verbose
qiime cutadapt trim-paired --i-demultiplexed-sequences 2-demux/mal2-demultiplexed-seqs.qza --p-front-f GTGYCAGCMGCCGCGGTAA --p-front-r GGACTACNVGGGTWTCTAAT --o-trimmed-sequences 3-cutad/mal2-trimmed-seqs.qza --verbose
...
...
qiime cutadapt trim-paired --i-demultiplexed-sequences 2-demux/mal14-demultiplexed-seqs.qza --p-front-f GTGYCAGCMGCCGCGGTAA --p-front-r GGACTACNVGGGTWTCTAAT --o-trimmed-sequences 3-cutad/mal14-trimmed-seqs.qza --verbose

# get clean data and produce feature table
qiime dada2 denoise-paired --i-demultiplexed-seqs 3-cutad/mal1-trimmed-seqs.qza --o-table 4-dada2/mal1-table --o-representative-sequences 4-dada2/mal1-rep-seqs --p-trim-left-f 0 --p-trim-left-r 0 --p-trunc-len-f 200 --p-trunc-len-r 200 --p-n-threads 0 --verbose
qiime feature-table summarize --i-table 4-dada2/mal1-table.qza --o-visualization 4-dada2/mal1-table.qzv --m-sample-metadata-file mal1-metadata.tsv
qiime feature-table tabulate-seqs --i-data 4-dada2/mal1-rep-seqs.qza --o-visualization 4-dada2/mal1-rep-seqs.qzv

# merge table
qiime feature-table merge --i-tables mal1-table.qza --i-tables sample2-table.qza --i-tables sample3-table.qza ... --o-merged-table ma-merged-table.qza --verbose
qiime feature-table merge-seqs --i-data mal1-rep-seqs.qza --i-data sample2-rep-seqs.qza --i-data sample3-rep-seqs.qza ... --o-merged-data ma-merged-rep-seqs.qza --verbose
qiime feature-table summarize --i-table ma-merged-table.qza --o-visualization ma-merged-table.qzv --m-sample-metadata-file ma-merged-metadata-128.tsv

# closed-reference to build OTU matrix
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path 13_5_97_otus.fasta \
  --output-path 13_5_97_otus.qza

qiime vsearch cluster-features-closed-reference \
  --i-table ma-merged-table.qza \
  --i-sequences ma-merged-rep-seqs.qza \
  --i-reference-sequences 13_5_97_otus.qza \
  --p-perc-identity 0.97 \
  --o-clustered-table ma-table-cr-97.qza \
  --o-clustered-sequences ma-rep-seqs-cr-97.qza \
  --o-unmatched-sequences unmatched-cr-97.qza

qiime feature-table summarize --i-table ma-table-cr-97.qza --o-visualization ma-table-cr-97.qzv --m-sample-metadata-file ma-merged-metadata-128.tsv

# build phylogenetic tree to produce diversity results
qiime alignment mafft --i-sequences ma-rep-seqs-cr-97.qza --o-alignment ma-aligned-rep-seqs-cr-97.qza
qiime alignment mask --i-alignment ma-aligned-rep-seqs-cr-97.qza --o-masked-alignment ma-masked-aligned-rep-seqs-cr-97.qza
qiime phylogeny fasttree --i-alignment ma-masked-aligned-rep-seqs-cr-97.qza --o-tree ma-unrooted-tree-cr-97.qza
qiime phylogeny midpoint-root --i-tree ma-unrooted-tree-cr-97.qza --o-rooted-tree ma-rooted-tree-cr-97.qza

# extract diversity results
qiime feature-table summarize \
  --i-table ma-table-cr-97.qza \
  --o-visualization ma-table-cr-97.qzv
  
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny ma-rooted-tree-cr-97.qza \
  --i-table ma-table-cr-97.qza \
  --p-sampling-depth 78038 \
  --m-metadata-file ma-merged-metadata-128.tsv \
  --output-dir core-metrics-results-cr \
  --verbose

qiime diversity alpha \
  --i-table ma-table-cr-97.qza \
  --p-metric simpson \
  --o-alpha-diversity core-metrics-results-cr/simpson_vector.qza

qiime tools export --input-path observed_otus_vector.qza --output-path ./export/otu
qiime tools export --input-path shannon_vector.qza --output-path ./export/shannon
qiime tools export --input-path faith_pd_vector.qza --output-path ./export/faith-pd
qiime tools export --input-path evenness_vector.qza --output-path ./export/evenness
qiime tools export --input-path simpson_vector.qza --output-path ./export/simpson

qiime tools export --input-path bray_curtis_distance_matrix.qza --output-path ./export/bray_curtis
qiime tools export --input-path jaccard_distance_matrix.qza --output-path ./export/jaccard
qiime tools export --input-path weighted_unifrac_distance_matrix.qza --output-path ./export/weighted_unifrac
qiime tools export --input-path unweighted_unifrac_distance_matrix.qza --output-path ./export/unweighted_unifrac

# extract OTU table
qiime tools export --input-path rarefied_table.qza --output-path ./export/rarefied-table
biom convert -i feature-table.biom -o otu_table.txt --table-type="OTU table" --to-tsv
biom convert -i feature-table.biom -o otu_table.tsv --table-type="OTU table" --to-tsv

# OTU annotation
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.2019.7.qza \
  --i-reads ma-rep-seqs-cr-97.qza \
  --o-classification ma-taxonomy-gg13-8.qza

qiime metadata tabulate \
  --m-input-file ma-taxonomy-gg13-8.qza \
  --o-visualization ma-taxonomy-gg13-8.qzv

qiime taxa barplot \
  --i-table ma-table-cr-97.qza \
  --i-taxonomy ma-taxonomy-gg13-8.qza \
  --m-metadata-file ma-merged-metadata-128.tsv \
  --o-visualization ma-taxa-gg13-8-barplots.qzv
