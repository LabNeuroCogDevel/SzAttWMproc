#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)


source("//10.145.64.109/Phillips/P5/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")

#Flexible Analysis-Power ROIs
#Flexible<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Flexible_powersROIs_mean.txt",header=T)
Flexible<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/txt/Flexible_powersROIs_mean.txt",header=T)
Flexible.1<<-Flexible[-grep("File",Flexible$File),]

Flexible.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Flexible.1$File)
Flexible.1$File<-substr(Flexible.1$File,1,14)

grepl("Mean",names(Flexible.1))
Flexible.2<-Flexible.1[ , c(1, which( grepl("Mean",names(Flexible.1))  ))]
Flexible.3<-mutate_each(Flexible.2,funs(as.numeric(as.character(.))))
Flexible.4<-cbind(Flexible.2$File,Flexible.3[,2:265])

#labels<-read.delim(file="/Volumes/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
labels<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
colnames(Flexible.4)<-labels$V1

#subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
subj<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")


#Ventral Attention Network
keepVA<-grepl("Ventralattention",names(Flexible.4))
Ventralattention<-Flexible.4[,keepVA]
str(Ventralattention)
Ventralattention1<-cbind(Flexible.1$File,Ventralattention)
Ventralattention1$VAaverage<-apply(Ventralattention, MARGIN=1, mean)

#Dorsal Attention Network
keepDA<-grepl("Dorsalattention",names(Flexible.4))
Dorsalattention<-Flexible.4[,keepDA]
str(Dorsalattention)
Dorsalattention1<-cbind(Flexible.1$File,Dorsalattention)
Dorsalattention1$DAaverage<-apply(Dorsalattention, MARGIN=1, mean)

#Default Mode Network
keepDF<-grepl("Defaultmode",names(Flexible.4))
Defaultmode<-Flexible.4[,keepDF]
str(Defaultmode)
Defaultmode1<-cbind(Flexible.1$File,Defaultmode)
Defaultmode1$DFaverage<-apply(Defaultmode, MARGIN=1, mean)

#Fronto-parietal
keepFP<-grepl("Frontoparietal",names(Flexible.4))
Frontoparietal<-Flexible.4[,keepFP]
str(Frontoparietal)
Frontoparietal1<-cbind(Flexible.1$File,Frontoparietal)
Frontoparietal1$FPaverage<-apply(Frontoparietal, MARGIN=1, mean)

#Cinguloopercular
keepCO<-grepl("Cinguloopercular",names(Flexible.4))
Cinguloopercular<-Flexible.4[,keepCO]
str(Cinguloopercular)
Cinguloopercular1<-cbind(Flexible.1$File,Cinguloopercular)
Cinguloopercular1$COaverage<-apply(Cinguloopercular, MARGIN=1, mean)

#Visual
keepVis<-grepl("Visual",names(Flexible.4))
Visual<-Flexible.4[,keepVis]
str(Visual)
Visual1<-cbind(Flexible.1$File,Visual)
Visual1$Visaverage<-apply(Visual, MARGIN=1, mean)

#combine the ROIs & add demographic info
TotalAttention <- merge(Ventralattention1,Dorsalattention1,by="Flexible.1$File")
TotalAttention <- merge(TotalAttention,Defaultmode1,by="Flexible.1$File")
TotalAttention <- merge(TotalAttention,Frontoparietal1,by="Flexible.1$File")
TotalAttention <- merge(TotalAttention,Cinguloopercular1,by="Flexible.1$File")
TotalAttention <- merge(TotalAttention,Visual1,by="Flexible.1$File")
TotalAttention1<-merge(TotalAttention,subj,by.x="Flexible.1$File",by.y="MRID")


#t-tests
t.test(Ventralattention1~Cohort,data=TotalAttention1)
t.test(Ventralattention2~Cohort,data=TotalAttention1)
t.test(Ventralattention3~Cohort,data=TotalAttention1)
t.test(Ventralattention4~Cohort,data=TotalAttention1)
t.test(Ventralattention5~Cohort,data=TotalAttention1)
t.test(Ventralattention6~Cohort,data=TotalAttention1)
t.test(Ventralattention7~Cohort,data=TotalAttention1)
t.test(Ventralattention8~Cohort,data=TotalAttention1)
t.test(Ventralattention9~Cohort,data=TotalAttention1)

t.test(Dorsalattention1~Cohort,data=TotalAttention1)
t.test(Dorsalattention2~Cohort,data=TotalAttention1)
t.test(Dorsalattention3~Cohort,data=TotalAttention1)
t.test(Dorsalattention4~Cohort,data=TotalAttention1)
t.test(Dorsalattention5~Cohort,data=TotalAttention1)
t.test(Dorsalattention6~Cohort,data=TotalAttention1)
t.test(Dorsalattention7~Cohort,data=TotalAttention1)
t.test(Dorsalattention8~Cohort,data=TotalAttention1)
t.test(Dorsalattention9~Cohort,data=TotalAttention1)


t.test(VAaverage~Cohort,data=TotalAttention1)
t.test(DAaverage~Cohort,data=TotalAttention1)
t.test(DFaverage~Cohort,data=TotalAttention1)
t.test(FPaverage~Cohort,data=TotalAttention1)
t.test(COaverage~Cohort,data=TotalAttention1)
t.test(Visaverage~Cohort,data=TotalAttention1)


Pat_Attention<-TotalAttention1[TotalAttention1$Cohort=="Clinical",]
cor.test(Pat_Attention$age,Pat_Attention$DAaverage)
cor.test(Pat_Attention$age,Pat_Attention$VAaverage)
cor.test(Pat_Attention$age,Pat_Attention$DFaverage)
cor.test(Pat_Attention$age,Pat_Attention$FPaverage)
cor.test(Pat_Attention$age,Pat_Attention$COaverage)
cor.test(Pat_Attention$age,Pat_Attention$Visaverage)

Con_Attention<-TotalAttention1[TotalAttention1$Cohort=="Control",]
cor.test(Con_Attention$age,Con_Attention$DAaverage)
cor.test(Con_Attention$age,Con_Attention$VAaverage)
cor.test(Con_Attention$age,Con_Attention$DFaverage)
cor.test(Con_Attention$age,Con_Attention$FPaverage)
cor.test(Con_Attention$age,Con_Attention$COaverage)
cor.test(Con_Attention$age,Con_Attention$Visaverage)

test<-aov(DAaverage~Cohort*age,data=TotalAttention1)
summary(test)
test<-aov(VAaverage~Cohort*age,data=TotalAttention1)
summary(test)
test<-aov(DFaverage~Cohort*age,data=TotalAttention1)
summary(test)
test<-aov(FPaverage~Cohort*age,data=TotalAttention1)
summary(test)
test<-aov(COaverage~Cohort*age,data=TotalAttention1)
summary(test)
test<-aov(Visaverage~Cohort*age,data=TotalAttention1)
summary(test)

ggplot(TotalAttention1,aes(x=age,y=VAaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
ggplot(TotalAttention1,aes(x=age,y=DAaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
ggplot(TotalAttention1,aes(x=age,y=DFaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
ggplot(TotalAttention1,aes(x=age,y=FPaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
ggplot(TotalAttention1,aes(x=age,y=COaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
ggplot(TotalAttention1,aes(x=age,y=Visaverage,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)
