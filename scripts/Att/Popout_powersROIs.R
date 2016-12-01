#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)


source("//10.145.64.109/Phillips/P5/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")

#Popout Analysis-Power ROIs
#Popout<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Popout_powersROIs_mean.txt",header=T)
Popout<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/txt/Popout_powersROIs_mean.txt",header=T)
Popout.1<<-Popout[-grep("File",Popout$File),]

Popout.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Popout.1$File)
Popout.1$File<-substr(Popout.1$File,1,14)

grepl("Mean",names(Popout.1))
Popout.2<-Popout.1[ , c(1, which( grepl("Mean",names(Popout.1))  ))]
Popout.3<-mutate_each(Popout.2,funs(as.numeric(as.character(.))))
Popout.4<-cbind(Popout.2$File,Popout.3[,2:265])

#labels<-read.delim(file="/Volumes/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
labels<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
colnames(Popout.4)<-labels$V1

#subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
subj<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")


#Ventral Attention Network
keepVA<-grepl("Ventralattention",names(Popout.4))
Ventralattention<-Popout.4[,keepVA]
str(Ventralattention)
Ventralattention1<-cbind(Popout.1$File,Ventralattention)
Ventralattention1$VAaverage<-apply(Ventralattention, MARGIN=1, mean)

#Dorsal Attention Network
keepDA<-grepl("Dorsalattention",names(Popout.4))
Dorsalattention<-Popout.4[,keepDA]
str(Dorsalattention)
Dorsalattention1<-cbind(Popout.1$File,Dorsalattention)
Dorsalattention1$DAaverage<-apply(Dorsalattention, MARGIN=1, mean)

#Default Mode Network
keepDF<-grepl("Defaultmode",names(Popout.4))
Defaultmode<-Popout.4[,keepDF]
str(Defaultmode)
Defaultmode1<-cbind(Popout.1$File,Defaultmode)
Defaultmode1$DFaverage<-apply(Defaultmode, MARGIN=1, mean)

#Fronto-parietal
keepFP<-grepl("Frontoparietal",names(Popout.4))
Frontoparietal<-Popout.4[,keepFP]
str(Frontoparietal)
Frontoparietal1<-cbind(Popout.1$File,Frontoparietal)
Frontoparietal1$FPaverage<-apply(Frontoparietal, MARGIN=1, mean)

#Cinguloopercular
keepCO<-grepl("Cinguloopercular",names(Popout.4))
Cinguloopercular<-Popout.4[,keepCO]
str(Cinguloopercular)
Cinguloopercular1<-cbind(Popout.1$File,Cinguloopercular)
Cinguloopercular1$COaverage<-apply(Cinguloopercular, MARGIN=1, mean)

#Visual
keepVis<-grepl("Visual",names(Popout.4))
Visual<-Popout.4[,keepVis]
str(Visual)
Visual1<-cbind(Popout.1$File,Visual)
Visual1$Visaverage<-apply(Visual, MARGIN=1, mean)

#combine the ROIs & add demographic info
TotalAttention <- merge(Ventralattention1,Dorsalattention1,by="Popout.1$File")
TotalAttention <- merge(TotalAttention,Defaultmode1,by="Popout.1$File")
TotalAttention <- merge(TotalAttention,Frontoparietal1,by="Popout.1$File")
TotalAttention <- merge(TotalAttention,Cinguloopercular1,by="Popout.1$File")
TotalAttention <- merge(TotalAttention,Visual1,by="Popout.1$File")
TotalAttention1<-merge(TotalAttention,subj,by.x="Popout.1$File",by.y="MRID")


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


#check for outliers
meanDA<-mean(TotalAttention1$DAaverage)
meanVA<-mean(TotalAttention1$VAaverage)
meanDF<-mean(TotalAttention1$DFaverage)
meanFP<-mean(TotalAttention1$FPaverage)
meanCO<-mean(TotalAttention1$COaverage)
meanVis<-mean(TotalAttention1$Visaverage)

sdDA<-sd(TotalAttention1$DAaverage)
sdVA<-sd(TotalAttention1$VAaverage)
sdDF<-sd(TotalAttention1$DFaverage)
sdFP<-sd(TotalAttention1$FPaverage)
sdCO<-sd(TotalAttention1$COaverage)
sdVis<-sd(TotalAttention1$Visaverage)

minDA<-meanDA-2.698*sdDA
minVA<-meanVA-2.698*sdVA
minDF<-meanDF-2.698*sdDF
minFP<-meanFP-2.698*sdFP
minCO<-meanCO-2.698*sdCO
minVis<-meanVis-2.698*sdVis

maxDA<-meanDA+2.698*sdDA
maxVA<-meanVA+2.698*sdVA
maxDF<-meanDF+2.698*sdDF
maxFP<-meanFP+2.698*sdFP
maxCO<-meanCO+2.698*sdCO
maxVis<-meanVis+2.698*sdVis

for (i in TotalAttention1$DAaverage){
  if(i<=minDA){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxDA){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}

for (i in TotalAttention1$VAaverage){
  if(i<=minVA){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxVA){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}
  
for (i in TotalAttention1$DFaverage){
  if(i<=minDF){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxDF){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}

for (i in TotalAttention1$FPaverage){
  if(i<=minFP){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxFP){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}

for (i in TotalAttention1$COaverage){
  if(i<=minCO){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxCO){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}

for (i in TotalAttention1$Visaverage){
  if(i<=minVis){
    print(TotalAttention1$'Popout.1$File'[i])
  }
  else if(i>=maxVis){
    print(TotalAttention1$'Popout.1$File'[i])
  }
}