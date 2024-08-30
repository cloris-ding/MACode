#################################### mouse ###############################
data <- read.table("cog_group_genus_mouse.txt", header=T, sep="\t", quo="")

aggdata_median <- aggregate(Median ~ COG+Group, data, FUN=sum)
aggdata_mean <- aggregate(Mean ~ COG+Group, data, FUN=sum)
aggdata <- merge(aggdata_median, aggdata_mean)
colnames(aggdata)[3:4] <- c("SumMedian", "SumMean")
data_merge <- merge(data, aggdata)

genus_list <- unique(data_merge$Genus)
abbr_list <- paste("T", seq(1:length(genus_list)), sep="")
datgenus <- data.frame(Genus=genus_list, Abbr=abbr_list)
newdata <- merge(data_merge, datgenus, by="Genus")
head(newdata, 20)

# SM = total abundance of COG in all genera in MA group,
# SS = total abundance of COG in all genera in control group
# get SM-SS
group_list <- c("Sal.-1d", "MA.-1d", "Sal.7d", "MA.7d", "Sal.14d", "MA.14d", "Sal.21d", "MA.21d")
time_list <- c("D1", "D7", "D14", "D21")
cog_list<- unique(newdata$COG)

datadeno <- data.frame(COG="", Time="", denoMedian=0, denoMean=0)
for (i in 1:length(cog_list)) {
  cog <- cog_list[i];
  for (j in c(1,3,5,7)) {
    group_ma <- group_list[j+1];
    group_ctrl <- group_list[j];
    median_ma <- unique(subset(newdata, COG==cog & Group==group_ma)$SumMedian);
    median_ctrl <- unique(subset(newdata, COG==cog & Group==group_ctrl)$SumMedian);
    mean_ma <- unique(subset(newdata, COG==cog & Group==group_ma)$SumMean);
    mean_ctrl <- unique(subset(newdata, COG==cog & Group==group_ctrl)$SumMean);
    cha_median <- median_ma - median_ctrl;
    cha_mean <- mean_ma - mean_ctrl;
    dx <- data.frame(COG=cog, Time=time_list[(j+1)/2], denoMedian=cha_median, denoMean=cha_mean);
    datadeno <- rbind(datadeno, dx);
  }
}
datadeno <- datadeno[-1,]
head(datadeno, 20)
write.table(datadeno, file="denodata_mouse.txt", sep="\t", quo=F, row.names=F)

# get Mi-Si
datanumer <- data.frame(Abbr="", COG="", Time="", numerMedian=0, numerMean=0)
for (i in 1:length(cog_list)) {
  cog <- cog_list[i];
  for (j in 1:length(genus_list)) {
    abbr <- abbr_list[j];
    for (k in c(1,3,5,7)) {
      group_ma <- group_list[k+1];
      group_ctrl <- group_list[k];
      median_ma <- subset(newdata, COG==cog & Abbr==abbr & Group==group_ma)$Median;
      median_ctrl <- subset(newdata, COG==cog & Abbr==abbr & Group==group_ctrl)$Median;
      mean_ma <- subset(newdata, COG==cog & Abbr==abbr & Group==group_ma)$Mean;
      mean_ctrl <- subset(newdata, COG==cog & Abbr==abbr & Group==group_ctrl)$Mean;
      cha_median <- median_ma - median_ctrl;
      cha_mean <- mean_ma - mean_ctrl;
      if (length(cha_median) < 1) { cha_median <- 0; }
      if (length(cha_mean) < 1) { cha_mean <- 0; }
      dx <- data.frame(Abbr=abbr, COG=cog, Time=time_list[(k+1)/2], numerMedian=cha_median, numerMean=cha_mean);
      datanumer <- rbind(datanumer, dx);
    }
  }
}
datanumer <- datanumer[-1,]
head(datanumer, 20)
write.table(datanumer, file="numerdata_mouse.txt", sep="\t", quo=F, row.names=F)

length(abbr_list)
length(cog_list)
dim(datanumer)

# ICb = (Mi-Si)/(SM-SS)
datamerge <- merge(datanumer, datadeno, by=c("COG", "Time"))
datamerge <- merge(datamerge, datgenus)
datamerge$ratioMedian <- round(datamerge$numerMedian/datamerge$denoMedian, 2)
datamerge$ratioMean <- round(datamerge$numerMean/datamerge$denoMean, 2)
write.table(datamerge, file="genus_to_COG_donation_mouse.txt", sep="\t", quo=F, row.names=F)

#################################### human ###############################
data <- read.table("cog_group_genus_human.txt", header=T, sep="\t", quo="")

aggdata_median <- aggregate(Median ~ COG+Group, data, FUN=sum)
aggdata_mean <- aggregate(Mean ~ COG+Group, data, FUN=sum)
aggdata <- merge(aggdata_median, aggdata_mean)
colnames(aggdata)[3:4] <- c("SumMedian", "SumMean")
data_merge <- merge(data, aggdata)

genus_list <- unique(data_merge$Genus)
abbr_list <- paste("T", seq(1:length(genus_list)), sep="")
datgenus <- data.frame(Genus=genus_list, Abbr=abbr_list)
newdata <- merge(data_merge, datgenus, by="Genus")
head(newdata, 20)

# SM = total abundance of COG in all genera in MA group,
# SS = total abundance of COG in all genera in control group
# get SM-SS
cog_list <- unique(newdata$COG)

datadeno <- data.frame(COG="", Time="", denoMedian=0, denoMean=0)
for (i in 1:length(cog_list)) {
  cog <- cog_list[i];
  median_ma <- unique(subset(newdata, COG==cog & Group=="hgMA")$SumMedian);
  median_ctrl <- unique(subset(newdata, COG==cog & Group=="hgHC")$SumMedian);
  mean_ma <- unique(subset(newdata, COG==cog & Group=="hgMA")$SumMean);
  mean_ctrl <- unique(subset(newdata, COG==cog & Group=="hgHC")$SumMean);
  if (length(median_ma) < 1) { median_ma <- 0;}
  if (length(median_ctrl) < 1) { median_ctrl <- 0;}
  if (length(mean_ma) < 1) { mean_ma <- 0;}
  if (length(mean_ctrl) < 1) { mean_ctrl <- 0;}
  cha_median <- median_ma - median_ctrl;
  cha_mean <- mean_ma - mean_ctrl;
  dx <- data.frame(COG=cog, Time="hg", denoMedian=cha_median, denoMean=cha_mean);
  datadeno <- rbind(datadeno, dx);
}
datadeno <- datadeno[-1,]
head(datadeno, 20)
length(unique(datadeno$COG))
length(cog_list)
write.table(datadeno, file="denodata_human.txt", sep="\t", quo=F, row.names=F)

# get Mi-Si
datanumer <- data.frame(Abbr="", COG="", Time="", numerMedian=0, numerMean=0)
for (i in 1:length(cog_list)) {
  cog <- cog_list[i];
  for (j in 1:length(genus_list)) {
    abbr <- abbr_list[j];
    median_ma <- subset(newdata, COG==cog & Abbr==abbr & Group=="hgMA")$Median;
    median_ctrl <- subset(newdata, COG==cog & Abbr==abbr & Group=="hgHC")$Median;
    mean_ma <- subset(newdata, COG==cog & Abbr==abbr & Group=="hgMA")$Mean;
    mean_ctrl <- subset(newdata, COG==cog & Abbr==abbr & Group=="hgHC")$Mean;
    cha_median <- median_ma - median_ctrl;
    cha_mean <- mean_ma - mean_ctrl;
    if (length(cha_median) < 1) { cha_median <- 0; }
    if (length(cha_mean) < 1) { cha_mean <- 0; }
    dx <- data.frame(Abbr=abbr, COG=cog, Time="hg", numerMedian=cha_median, numerMean=cha_mean);
    datanumer <- rbind(datanumer, dx);
  }
}
datanumer <- datanumer[-1,]
head(datanumer, 20)
length(unique(datanumer$COG))
write.table(datanumer, file="numerdata_human.txt", sep="\t", quo=F, row.names=F) #################

length(abbr_list)
length(cog_list)
dim(datanumer)

# ICb = (Mi-Si)/(SM-SS)
datamerge <- merge(datanumer, datadeno, by=c("COG", "Time"))
datamerge <- merge(datamerge, datgenus)
datamerge$ratioMedian <- round(datamerge$numerMedian/datamerge$denoMedian, 2)
datamerge$ratioMean <- round(datamerge$numerMean/datamerge$denoMean, 2)
write.table(datamerge, file="genus_to_COG_donation_human.txt", sep="\t", quo=F, row.names=F)

