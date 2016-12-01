#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(LNCDR)

source("//10.145.64.109/Phillips/P5/scripts/WM/graphing_functions.R")

#read Flexible_ROIs_mean.txt to Flexible
#Flexible<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Flexible_ROIs_mean.txt",header=T)
Flexible<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/txt/Flexible_ROIs_mean.txt",header=T)

#remove rows containing File
Flexible.1<<-Flexible[-grep("File",Flexible$File),]

#leave only the subject number in the file path
Flexible.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Flexible.1$File)
Flexible.1$File<-substr(Flexible.1$File,1,14)

#find columns in Flexible.1 w/ the word "Mean"
grepl("Mean",names(Flexible.1))

#select only the columns in Flexible.1 w/ the word "Mean"
Flexible.2<-Flexible.1[ , c(1, which( grepl("Mean",names(Flexible.1))  ))]

#convert all data into numeric type
Flexible.3<-mutate_each(Flexible.2,funs(as.numeric(as.character(.))))

#add subject ids from Flexible.2
Flexible.4<-cbind(Flexible.2$File,Flexible.3[,2:15])

#add column headers
colnames(Flexible.4)<-c("ID","LCING_flexible","LDLPFC1_flexible","LDLPFC2_flexible","LFEF_flexible","LIPL_flexible","LVC_flexible","LINS_flexible","RCING_flexible","RDLPFC1_flexible","RDLPFC2_flexible","RFEF_flexible","RIPL_flexible","RVC_flexible","RINS_flexible")

#read in file w/ subject information
#subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
subj<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")

#merge data all_data & subj, by ID and MRID
data_ROIs<-merge(Flexible.4,subj,by.x="ID",by.y="MRID")

#make table from the merged data 
#write.table(data_ROIs,file="/Users/Dhruv/Documents/P5_Flexible_Activation.txt")


#select + keep data for only DLPFC
keep = match(c("ID","LDLPFC2_flexible","RDLPFC2_flexible", "Cohort"), colnames(data_ROIs))

#include only DLPFC columns from previous line in DLPFC_ROIs 
DLPFC_ROIs<-data_ROIs[,keep]

#consolidate left and right DLPFC data into single column 
DLPFC_ROIs.1 <- melt(DLPFC_ROIs, id.vars=c("ID","Cohort"))

#take first letter of variable and make new variable hemisphere
DLPFC_ROIs.1$hem<-substr(DLPFC_ROIs.1$variable,1,1)

#convert hemisphere from factor to numeric variable
DLPFC_ROIs.1$hem<-as.factor(DLPFC_ROIs.1$hem)


#run analysis  - look for cohort (patient, control) by hemisphere(L,R) by load (low,high) interaction in data
Att_aov1<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC_ROIs.1)
summary(Att_aov1)

#ttest to follow up on Cohort*hem interaction
t.test(LDLPFC2_flexible~Cohort,data=data_ROIs)

#ttest to follow up on Cohort*hem interaction
t.test(RDLPFC2_flexible~Cohort,data=data_ROIs)

#get mean values
tapply(data_ROIs$RDLPFC2_flexible,data_ROIs$Cohort,mean)
tapply(data_ROIs$LDLPFC2_flexible,data_ROIs$Cohort,mean)

#get range of values
tapply(data_ROIs$RDLPFC2_flexible,data_ROIs$Cohort,range)
tapply(data_ROIs$LDLPFC2_flexible,data_ROIs$Cohort,range)

#
pat_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Clinical",]
con_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Control",]

t.test(pat_data_ROIs$RDLPFC2_flexible,pat_data_ROIs$LDLPFC2_flexible,paired=TRUE)
t.test(con_data_ROIs$RDLPFC2_flexible,con_data_ROIs$LDLPFC2_flexible,paired=TRUE)


#select data for diagnosis (now 3 groups = schitzophrenia spectrum, other psych, disorders, controls)
keep2 = match(c("ID","LDLPFC2_flexible","RDLPFC2_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))

#take the new kept columns and add to DLPFC_ROIs_dx
DLPFC_ROIs_dx<-data_ROIs[,keep2]

#consolidate left and right DLPFC data into single column 
DLPFC_ROIs_dx <- melt(DLPFC_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))

#take first letter of variable and make new variable hemisphere
DLPFC_ROIs_dx$hem<-substr(DLPFC_ROIs.1$variable,1,1)

#convert hemisphere from factor to numeric variable
DLPFC_ROIs_dx$hem<-as.factor(DLPFC_ROIs.1$hem)

#Run ANOVA
Att_aov3<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC_ROIs_dx )
summary(Att_aov3)

#only select schizophrenia spcetrum and controls
data_ROIs_sub1<-data_ROIs[data_ROIs$confirmed_initial_dx1=="1" | data_ROIs$confirmed_initial_dx1=="2", ]

t.test(LDLPFC2_flexible~confirmed_initial_dx1,data=data_ROIs_sub1)
t.test(RDLPFC2_flexible~confirmed_initial_dx1,data=data_ROIs_sub1)

#plotting
#keep DLPFC2 columns for
keep4 = match(c("ID","LDLPFC2_flexible","RDLPFC2_flexible","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC_plot<-data_ROIs[,keep4]

#add activation values for each subject
d.per_cor<- DLPFC_plot %>% 
  gather(Hem,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)

#change column names
names(d.per_cor)[4:5]<-c("Hem","value")

#substitute hemisphere data to L and R
d.per_cor$Hem<-gsub("LDLPFC2_flexible","L",d.per_cor$Hem)
d.per_cor$Hem<-gsub("RDLPFC2_flexible","R",d.per_cor$Hem)

#keep order of hemispheres consistent during analysis
d.per_cor$Hem<-factor(d.per_cor$Hem,levels=list('L','R'),labels=list('L','R'))

#calculate standard error
d.grp <- d.per_cor %>% 
  group_by(Cohort,Hem) %>%  
  meanse


## plot group data
pdf('//10.145.64.109/P5/scripts/Rplots/imgs/DLPFC2_Flexible_group.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.grp,fill='Cohort',levelname='Hem') + 
  # color of the bar plots 
  scale_fill_manual(values=c('grey36','white')) +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c('black','black')) +
  coord_cartesian(ylim=c(0,22))
print(p.grp)

dev.off()

#find activation level and standard error for diagnostic
d.dx <- d.per_cor %>% 
  group_by(confirmed_initial_dx1,Hem) %>%  
  meanse

#use clinical info for plot_dx
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)


## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/RDLPFC2_Flexible_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.dx,fill='confirmed_initial_dx1',levelname='Hem') + 
  # color of the bar plots 
  scale_fill_manual(values=c('grey13','grey72','white'))   +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black')) +
  coord_cartesian(ylim=c(-1,28))
print(p.grp)

dev.off()






#select + keep data for only IPL
keep = match(c("ID","LIPL_flexible","RIPL_flexible", "Cohort"), colnames(data_ROIs))

#select for collumns you just selected for in line 66
IPL_ROIs<-data_ROIs[,keep]

# rearrange data for easy viewing + analyses (four collumns into one variable) 
IPL_ROIs.1 <- melt(IPL_ROIs, id.vars=c("ID","Cohort"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)


#run analysis  - look for cohort (patient, control) by hemisphere(L,R) by load (low,high) interaction in data
Att_IPL_aov<-aov(value~Cohort*hem+Error(ID/hem),data=IPL_ROIs.1)
summary(Att_IPL_aov)


#ttest follow-ups
t.test(LINS_flexible~Cohort,data=data_ROIs)
t.test(RINS_flexible~Cohort,data=data_ROIs)

pat_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Clinical",]
con_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Control",]

t.test(pat_data_ROIs$RINS_flexible,pat_data_ROIs$LINS_flexible,paired=TRUE)
t.test(con_data_ROIs$RINS_flexible,con_data_ROIs$LINS_flexible,paired=TRUE)

data_ROIs_sub1<-data_ROIs[data_ROIs$confirmed_initial_dx1=="2" | data_ROIs$confirmed_initial_dx1=="3", ]

t.test(LINS_flexible~confirmed_initial_dx1,data=data_ROIs_sub1)
t.test(RINS_flexible~confirmed_initial_dx1,data=data_ROIs_sub1)

#select data for diagnosis (now 3 groups = schitzophrenia spectrum, other psych, disorders, controls)
keep2 = match(c("ID","LIPL_flexible","RIPL_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))

IPL_ROIs_dx<-data_ROIs[,keep2]


IPL_ROIs.1 <- melt(IPL_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)


Attdx_IPL_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=IPL_ROIs.1 )
summary(Attdx_IPL_aov)



#VC Group
keep = match(c("ID","LVC_flexible","RVC_flexible", "Cohort"), colnames(data_ROIs))
VC_ROIs<-data_ROIs[,keep]
VC_ROIs.1 <- melt(VC_ROIs, id.vars=c("ID","Cohort"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Att_VC_aov<-aov(value~Cohort*hem+Error(ID/hem),data=VC_ROIs.1)
summary(Att_VC_aov)

#VC Diagnostic
keep2 = match(c("ID","LVC_flexible","RVC_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))
VC_ROIs_dx<-data_ROIs[,keep2]
VC_ROIs.1 <- melt(VC_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Attdx_VC_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=VC_ROIs.1 )
summary(Attdx_VC_aov)


#CING Group
keep = match(c("ID","LCING_flexible","RCING_flexible", "Cohort"), colnames(data_ROIs))
CING_ROIs<-data_ROIs[,keep]
CING_ROIs.1 <- melt(CING_ROIs, id.vars=c("ID","Cohort"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Att_CING_aov<-aov(value~Cohort*hem+Error(ID/hem),data=CING_ROIs.1)
summary(Att_CING_aov)

#CING Diagnostic
keep2 = match(c("ID","LCING_flexible","RCING_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))
CING_ROIs_dx<-data_ROIs[,keep2]
CING_ROIs.1 <- melt(CING_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Attdx_CING_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=CING_ROIs.1 )
summary(Attdx_CING_aov)


#DLPFC1 Group
keep = match(c("ID","LDLPFC1_flexible","RDLPFC1_flexible", "Cohort"), colnames(data_ROIs))
DLPFC1_ROIs<-data_ROIs[,keep]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs, id.vars=c("ID","Cohort"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Att_DLPFC1_aov<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC1_ROIs.1)
summary(Att_DLPFC1_aov)

#DLPFC1 Diagnostic
keep2 = match(c("ID","LDLPFC1_flexible","RDLPFC1_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC1_ROIs_dx<-data_ROIs[,keep2]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Attdx_DLPFC1_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC1_ROIs.1 )
summary(Attdx_DLPFC1_aov)


#FEF Group
keep = match(c("ID","LFEF_flexible","RFEF_flexible", "Cohort"), colnames(data_ROIs))
FEF_ROIs<-data_ROIs[,keep]
FEF_ROIs.1 <- melt(FEF_ROIs, id.vars=c("ID","Cohort"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Att_FEF_aov<-aov(value~Cohort*hem+Error(ID/hem),data=FEF_ROIs.1)
summary(Att_FEF_aov)

#FEF Diagnostic
keep2 = match(c("ID","LFEF_flexible","RFEF_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))
FEF_ROIs_dx<-data_ROIs[,keep2]
FEF_ROIs.1 <- melt(FEF_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Attdx_FEF_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=FEF_ROIs.1 )
summary(Attdx_FEF_aov)


#INS Group
keep = match(c("ID","LINS_flexible","RINS_flexible", "Cohort"), colnames(data_ROIs))
INS_ROIs<-data_ROIs[,keep]
INS_ROIs.1 <- melt(INS_ROIs, id.vars=c("ID","Cohort"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Att_INS_aov<-aov(value~Cohort*hem+Error(ID/hem),data=INS_ROIs.1)
summary(Att_INS_aov)

#INS Diagnostic
keep2 = match(c("ID","LINS_flexible","RINS_flexible", "confirmed_initial_dx1"), colnames(data_ROIs))
INS_ROIs_dx<-data_ROIs[,keep2]
INS_ROIs.1 <- melt(INS_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Attdx_INS_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=INS_ROIs.1 )
summary(Attdx_INS_aov)


#same thing but for IPL 
keep2 = match(c("ID","LIPL_delay_ld1","RIPL_delay_ld1", "LIPL_delay_ld3","RIPL_delay_ld3","Cohort"), colnames(data_ROIs))


IPL_ROIs<-data_ROIs[,keep2]

IPL_ROIs.1 <- melt(IPL_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(IPL_ROIs.1$variable), "_")
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
IPL_ROIs.1$load<-sapply(spl, "[", 3)
IPL_ROIs.1$load<-as.factor(IPL_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=IPL_ROIs.1 )
summary(WM_aov2)



#pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]

keep3 = match(c("ID","LIPL_delay_ld1","RIPL_delay_ld1", "LIPL_delay_ld3","RIPL_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))


IPL_ROIs_dx<-data_ROIs[,keep3]


IPL_ROIs.1 <- melt(IPL_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(IPL_ROIs.1$variable), "_")
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
IPL_ROIs.1$load<-sapply(spl, "[", 3)
IPL_ROIs.1$load<-as.factor(IPL_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=IPL_ROIs.1 )
summary(WM_aov3)



#follow up each dx

IPL_ROIs_dx_sub<-IPL_ROIs_dx[IPL_ROIs_dx$confirmed_initial_dx1=="1" | IPL_ROIs_dx$confirmed_initial_dx1=="3", ]








#same thing but for VC cohort
keep2 = match(c("ID","LVC_delay_ld1","RVC_delay_ld1", "LVC_delay_ld3","RVC_delay_ld3","Cohort"), colnames(data_ROIs))


VC_ROIs<-data_ROIs[,keep2]

VC_ROIs.1 <- melt(VC_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(VC_ROIs.1$variable), "_")
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
VC_ROIs.1$load<-sapply(spl, "[", 3)
VC_ROIs.1$load<-as.factor(VC_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=VC_ROIs.1 )
summary(WM_aov2)

#VC clinical 
keep3 = match(c("ID","LVC_delay_ld1","RVC_delay_ld1", "LVC_delay_ld3","RVC_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))

VC_ROIs_dx<-data_ROIs[,keep3]


VC_ROIs.1 <- melt(VC_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(VC_ROIs.1$variable), "_")
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
VC_ROIs.1$load<-sapply(spl, "[", 3)
VC_ROIs.1$load<-as.factor(VC_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=VC_ROIs.1 )
summary(WM_aov3)



#same thing but for CING region
keep2 = match(c("ID","LCING_delay_ld1","RCING_delay_ld1", "LCING_delay_ld3","RCING_delay_ld3","Cohort"), colnames(data_ROIs))


CING_ROIs<-data_ROIs[,keep2]

CING_ROIs.1 <- melt(CING_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(CING_ROIs.1$variable), "_")
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
CING_ROIs.1$load<-sapply(spl, "[", 3)
CING_ROIs.1$load<-as.factor(CING_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=CING_ROIs.1 )
summary(WM_aov2)

data_ROIs$BCING_ld1<-(data_ROIs$LCING_delay_ld1+data_ROIs$RCING_delay_ld1)/2
tapply(data_ROIs$BCING_ld1,data_ROIs$Cohort,mean)
t.test(BCING_ld1~Cohort,data=data_ROIs)


data_ROIs$BCING_ld3<-(data_ROIs$LCING_delay_ld3+data_ROIs$RCING_delay_ld3)/2
tapply(data_ROIs$BCING_ld3,data_ROIs$Cohort,mean)
t.test(BCING_ld3~Cohort,data=data_ROIs)
#follow up each dx 
keep4 = match(c("ID","BCING_ld1","BCING_ld3", "confirmed_initial_dx1"), colnames(data_ROIs))
VC_ROIs_dx<-data_ROIs[,keep4]

VC_ROIs_dx.2_sub<-VC_ROIs_dx[VC_ROIs_dx.2$confirmed_initial_dx1=="2" | VC_ROIs_dx.2$confirmed_initial_dx1=="3", ]

for (i in 2:3)
  
{
  
  model_beh<-glm(VC_ROIs_dx.2_sub[[i]]~as.factor(VC_ROIs_dx.2_sub$confirmed_initial_dx1),data=VC_ROIs_dx.2_sub)
  print((summary(model_beh)$coefficients[2,4]))
}

#plotting
keep4 = match(c("ID","BCING_ld1","BCING_ld3","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
VC_plot<-data_ROIs[,keep4]


d.per_cor<- VC_plot %>% 
  gather(Load,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)


names(d.per_cor)[4:5]<-c("Load","value")

d.per_cor$Load<-gsub("BCING_ld1","Low",d.per_cor$Load)
d.per_cor$Load<-gsub("BCING_ld3","High",d.per_cor$Load)

d.per_cor$Load<-factor(d.per_cor$Load,levels=list('Low','High'),labels=list('Low','High'))



d.grp <- d.per_cor %>% 
  group_by(Cohort,Load) %>%  
  meanse %>%
  addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')

#d.grp$Load<-gsub("ld","", d.grp$Load)
#d.grp$Load<-gsub("_per_cor","", d.grp$Load)



## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/BCING_maintenance_group.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.grp,fill='Cohort',levelname='Load') + 
  # color of the bar plots 
  scale_fill_manual(values=c(NA,NA,'black','white')) +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c(NA,NA,'black','black')) +
  coord_cartesian(ylim=c(-5,12))
print(p.grp)

dev.off()



d.dx <- d.per_cor %>% 
  group_by(confirmed_initial_dx1,Load) %>%  
  meanse

#use clinical info for dx plot
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.dx.1<-rbind(d.clinical.1,d.dx)


d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))
d.dx.1$Load<-factor(d.dx.1$Load,levels=list('Low','High'),labels=list('Low','High'))

## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/BCING_maintenance_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.dx.1,fill='confirmed_initial_dx1',levelname='Load') + 
  # color of the bar plots 
  scale_fill_manual(values=c('grey45','light grey','black','white'))   +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black','black')) +
  coord_cartesian(ylim=c(-5,12))
print(p.grp)

dev.off()




#CING clinical 
keep3 = match(c("ID","LCING_delay_ld1","RCING_delay_ld1", "LCING_delay_ld3","RCING_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))

CING_ROIs_dx<-data_ROIs[,keep3]


CING_ROIs.1 <- melt(CING_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(CING_ROIs.1$variable), "_")
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
CING_ROIs.1$load<-sapply(spl, "[", 3)
CING_ROIs.1$load<-as.factor(CING_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=CING_ROIs.1 )
summary(WM_aov3)


# DLPFC1 region
keep2 = match(c("ID","LDLPFC1_delay_ld1","RDLPFC1_delay_ld1", "LDLPFC1_delay_ld3","RDLPFC1_delay_ld3","Cohort"), colnames(data_ROIs))


DLPFC1_ROIs<-data_ROIs[,keep2]

DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(DLPFC1_ROIs.1$variable), "_")
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
DLPFC1_ROIs.1$load<-sapply(spl, "[", 3)
DLPFC1_ROIs.1$load<-as.factor(DLPFC1_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=DLPFC1_ROIs.1 )
summary(WM_aov2)

#DLPFC1 clinical 
keep3 = match(c("ID","LDLPFC1_delay_ld1","RDLPFC1_delay_ld1", "LDLPFC1_delay_ld3","RDLPFC1_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))

DLPFC1_ROIs_dx<-data_ROIs[,keep3]


DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(DLPFC1_ROIs.1$variable), "_")
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
DLPFC1_ROIs.1$load<-sapply(spl, "[", 3)
DLPFC1_ROIs.1$load<-as.factor(DLPFC1_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=DLPFC1_ROIs.1 )
summary(WM_aov3)


# FEF region
keep2 = match(c("ID","LFEF_delay_ld1","RFEF_delay_ld1", "LFEF_delay_ld3","RFEF_delay_ld3","Cohort"), colnames(data_ROIs))


FEF_ROIs<-data_ROIs[,keep2]

FEF_ROIs.1 <- melt(FEF_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(FEF_ROIs.1$variable), "_")
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
FEF_ROIs.1$load<-sapply(spl, "[", 3)
FEF_ROIs.1$load<-as.factor(FEF_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=FEF_ROIs.1 )
summary(WM_aov2)

#FEF clinical 
keep3 = match(c("ID","LFEF_delay_ld1","RFEF_delay_ld1", "LFEF_delay_ld3","RFEF_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))

FEF_ROIs_dx<-data_ROIs[,keep3]


FEF_ROIs.1 <- melt(FEF_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(FEF_ROIs.1$variable), "_")
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
FEF_ROIs.1$load<-sapply(spl, "[", 3)
FEF_ROIs.1$load<-as.factor(FEF_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=FEF_ROIs.1 )
summary(WM_aov3)

# INS region
keep2 = match(c("ID","LINS_delay_ld1","RINS_delay_ld1", "LINS_delay_ld3","RINS_delay_ld3","Cohort"), colnames(data_ROIs))


INS_ROIs<-data_ROIs[,keep2]

INS_ROIs.1 <- melt(INS_ROIs, id.vars=c("ID","Cohort"))
spl <-strsplit(as.character(INS_ROIs.1$variable), "_")
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
INS_ROIs.1$load<-sapply(spl, "[", 3)
INS_ROIs.1$load<-as.factor(INS_ROIs.1$load)

WM_aov2<-aov(value~Cohort*hem*load+Error(ID/hem*load),data=INS_ROIs.1 )
summary(WM_aov2)

#INS clinical 
keep3 = match(c("ID","LINS_delay_ld1","RINS_delay_ld1", "LINS_delay_ld3","RINS_delay_ld3","confirmed_initial_dx1"), colnames(data_ROIs))

INS_ROIs_dx<-data_ROIs[,keep3]


INS_ROIs.1 <- melt(INS_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
spl <-strsplit(as.character(INS_ROIs.1$variable), "_")
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
INS_ROIs.1$load<-sapply(spl, "[", 3)
INS_ROIs.1$load<-as.factor(INS_ROIs.1$load)

WM_aov3<-aov(value~confirmed_initial_dx1*hem*load+Error(ID/hem*load),data=INS_ROIs.1 )
summary(WM_aov3)


clinical<-read.delim(file="/Users/mariaj/Desktop/Clinical_Info.txt")


clinical_data_ROIs<-merge(data_ROIs,clinical,by.x="ID",by.y="MRI_ID")

behave<-read.delim(file="/Users/mariaj/Dropbox/P5_WM_behave_data.txt",sep=" ")

all<-merge(clinical_data_ROIs,behave,by.x="ID",by.y="subjid")

#cohort
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$BPRSPOS)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$BPRSNGS)
cor.test(clinical_data_ROIs$BCING_ld1,clinical_data_ROIs$BPRSPOS)
cor.test(clinical_data_ROIs$BCING_ld1,clinical_data_ROIs$BPRSNGS)

cor.test(clinical_data_ROIs$BCING_ld3,clinical_data_ROIs$BPRSPOS)
cor.test(clinical_data_ROIs$BCING_ld3,clinical_data_ROIs$BPRSNGS)

scz_all<-all[all$confirmed_initial_dx1.x==1,]
cor.test(scz_all$RDLPFC_both_loads,scz_all$BPRSPOS)
cor.test(scz_all$RDLPFC_both_loads,scz_all$BPRSNGS)

other_all<-all[all$confirmed_initial_dx1.x==2,]
cor.test(other_all$RDLPFC_both_loads,other_all$BPRSPOS)
cor.test(other_all$RDLPFC_both_loads,other_all$BPRSNGS)

cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$AVSPGBL)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$SAPITM)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$SANITM)

cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$BPRSNGS)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$DURFPSYCEP)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$DURFPSYM1)
cor.test(clinical_data_ROIs$RDLPFC_both_loads,clinical_data_ROIs$BPRSHALL)
cor.test(all$BPRSNGS,all$BPRSPOS)
cor.test(all$DURPRDM,all$BPRSPOS)
cor.test(all$AvgOfIQSCORE,all$BPRSPOS)
cor.test(all$DURPRDM,all$RDLPFC_both_loads)
cor.test(all$DURFPSYCEP,all$RDLPFC_both_loads)
cor.test(all$DURFPSYM1,all$BPRSPOS)


cor.test(all$per_cor,all$BCING_ld3)
cor.test(all$ld3_avg_RT,all$BCING_ld3)
con<-all[all$Cohort.x=="Control",]
cor.test(con$RDLPFC_both_loads,con$per_cor)
cor.test(con$RDLPFC_both_loads,con$avg_RT)
cor.test(con$BCING_ld3,con$per_cor)
cor.test(con$BCING_ld3,con$ld3_avg_RT)

clinical<-all[all$Cohort.x=="Clinical",]
cor.test(clinical$RDLPFC_both_loads,clinical$per_cor)
cor.test(clinical$RDLPFC_both_loads,clinical$avg_RT)
cor.test(clinical$BCING_ld3,clinical$ld3_per_cor)
cor.test(clinical$BCING_ld3,clinical$ld3_avg_RT)
cor.test(clinical$BCING_ld3,clinical$RDLPFC2_delay_ld3)




cor.test(clinical$BCING_ld3,clinical$ld3_per_cor)


cor.test(all$per_cor,all$SANITM)
cor.test(all$per_cor,all$SAPITM)
cor.test(all$ld3_per_cor,all$BPRSPOS)
cor.test(all$ld1_per_cor,all$BPRSPOS)
cor.test(all$ld1_per_cor,all$BPRSNGS)
cor.test(all$ld3_per_cor,all$BPRSNGS)

xlab<-"BL CING Activation LD 3 \n"
ylab<-"% Correct Load 3\n"
all$confirmed_initial_dx1.x<-as.factor(all$confirmed_initial_dx1.x)

p<-ggplot(all,aes(x=BCING_ld3,y=ld3_per_cor,color=Cohort.x)) +geom_point(aes(fill=Cohort.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('black','white',"white")) +scale_colour_manual(values=c('black','gray','white'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p



p2<-ggplot(all,aes(x=RDLPFC_both_loads,y=BPRSPOS,color=confirmed_initial_dx1.x)) +geom_point(aes(fill=confirmed_initial_dx1.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('red','blue',"white")) +scale_colour_manual(values=c('red','blue','white'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p2

#good graphs -20160819


# assumes variable to mean and get se is 'val'
meanse <- function(d) {
  summarize(d, 
            avg=mean(value),
            se=sd(value)/sqrt(n()))
}

##
# add an empty group to data
# empties/expects columns 'avg' and 'se'
addemptygrp <- function(d,grpname,emptyname="emtpy") {
  ## grab a group subset
  # get the first group name 
  examplegroup <- as.character(unlist(d[1,grpname]))
  # get all the rows that have this name
  i <- d[,grpname]== examplegroup
  # get a subset
  d.sub <- d[i,]
  
  ## zero and empty subset
  d.sub[,c('avg','se')] <- 0
  d.sub[,grpname] <- emptyname 
  
  ## add emptied subset to rest of data
  d <- rbind(d,d.sub)
  # put empty first
  d[,grpname] <- relevel(unlist(d[,grpname]), ref=emptyname)
  return(d)
}

# we use this plot twice, so make it a function
# specify data and fill column like 'dx' or 'grp'
# expects columns 'lvl','avg','se' 
plot_bar_and_error <- function(d,fill="dx",levelname='lvl') {
  ggplot(d) +
    aes_string(x=levelname,fill=fill,y="avg") +
    
    geom_bar(stat='identity',position='dodge') +
    geom_errorbar(
      aes(ymin=avg-se,ymax=avg+se),
      position=position_dodge(0.9),
      width=.25) +
    theme_bw() + 
    # change the legend
    theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")
}




keep4 = match(c("ID","BLVC_ld1","BLVC_ld3","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
VC_plot<-data_ROIs[,keep4]


d.per_cor<- VC_plot %>% 
  gather(Load,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)


names(d.per_cor)[4:5]<-c("Load","value")

d.per_cor$Load<-gsub("BLVC_ld1","Low",d.per_cor$Load)
d.per_cor$Load<-gsub("BLVC_ld3","High",d.per_cor$Load)

d.per_cor$Load<-factor(d.per_cor$Load,levels=list('Low','High'),labels=list('Low','High'))



d.grp <- d.per_cor %>% 
  group_by(Cohort,Load) %>%  
  meanse %>%
  addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')

#d.grp$Load<-gsub("ld","", d.grp$Load)
#d.grp$Load<-gsub("_per_cor","", d.grp$Load)



## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/BLVC_Maintenance_group.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.grp,fill='Cohort',levelname='Load') + 
  # color of the bar plots 
  scale_fill_manual(values=c(NA,NA,'black','white')) +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c(NA,NA,'black','black')) +
  coord_cartesian(ylim=c(0,18))
print(p.grp)

dev.off()



d.dx <- d.per_cor %>% 
  group_by(confirmed_initial_dx1,Load) %>%  
  meanse

#use clinical info for dx plot
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.dx.1<-rbind(d.clinical.1,d.dx)


d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))
d.dx.1$Load<-factor(d.dx.1$Load,levels=list('Low','High'),labels=list('Low','High'))

## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/BLVC_Maintenance_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  # our handy bar plot and error function
  plot_bar_and_error(d.dx.1,fill='confirmed_initial_dx1',levelname='Load') + 
  # color of the bar plots 
  scale_fill_manual(values=c('grey45','light grey','black','white'))   +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black','black')) +
  coord_cartesian(ylim=c(0,18))
print(p.grp)

dev.off()



VC_ROI_graph<-VC_ROIs.1%>% 
  group_by(Cohort,load) %>%  
  meanse

textSize=26

ggplot(VC_ROI_graph) +
  aes_string(x="load",fill="Cohort",y="avg") +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=avg,ymax=avg+se),
    position=position_dodge(0.9),
    width=.25) +
  # bottom
  geom_errorbar(
    aes(ymin=avg-se,ymax=avg),
    position=position_dodge(0.9),
    width=.25) 





behave<-read.delim(file="/Users/mariaj/Dropbox/P5_WM_behave_data.txt",sep=" ")
combo<-merge(data_ROIs,behave,by.x="ID",by.y="subjid")





combo_pat<-combo[combo$Cohort.x=="Clinical",]
combo_con<-combo[combo$Cohort.x=="Control",]

cor.test(combo$RDLPFC_both_loads,combo$per_cor)
cor.test(combo_pat$RDLPFC_both_loads,combo_pat$per_cor)
cor.test(combo_pat$RDLPFC2_delay_ld3,combo_pat$ld3_per_cor)
cor.test(combo_con$RDLPFC2_delay_ld3,combo_con$ld3_per_cor)
cor.test(combo_con$RDLPFC_both_loads,combo_con$per_cor)
cor.test(combo_pat$RDLPFC2_delay_ld3,combo_pat$BLVC_ld3)
cor.test(combo_pat$ld3_per_cor,combo_pat$BLVC_ld3)

xlab<-"\nLD 3 % correct"
ylab<-"R DLPFC Activation LD 3\n"

p<-ggplot(combo,aes(x=ld3_per_cor,y=RDLPFC2_delay_ld3,color=Cohort.x)) +geom_point(aes(fill=Cohort.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('black','white')) +scale_colour_manual(values=c('black','dark grey'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p


xlab<-"\nLD 1 % correct"
ylab<-"R DLPFC Activation LD 1\n"

p<-ggplot(combo,aes(x=ld1_per_cor,y=RDLPFC2_delay_ld1,color=Cohort.x)) +geom_point(aes(fill=Cohort.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('black','white')) +scale_colour_manual(values=c('black','dark grey'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p


xlab<-"ld 3 % correct"
ylab<-"BLVC Load 3 Activation\n"


p<-ggplot(combo,aes(x=ld3_per_cor,y=BLVC_ld3,color=Cohort.x)) +geom_point(aes(fill=Cohort.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('black','white')) +scale_colour_manual(values=c('black','dark grey'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p



cor.test(together$BLVC_ld3,together$ld3_per_cor)
cor.test(together$RDLPFC_both_loads,together$per_cor)
cor.test(together$RDLPFC2_delay_ld3,together$ld3_per_cor)

pdf(paste("ld3_LBA9_brain_behave.pdf",sep="_"),width=7,height=5)
xlab<-"\nLoad 3 % correct"
ylab<-"L DLPFC Activation\n"

p<-ggplot(together,aes(x=ld1_per_cor,y=BLVC_ld1,color=Cohort.x)) +geom_point(aes(fill=Cohort.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)

p
together_pat<-together[together$Cohort.x=="Clinical",]
cor.test(together_pat$RDLPFC2_delay_ld1,together_pat$ld3_per_cor)
cor.test(together_pat$RDLPFC2_delay_ld3,together_pat$ld3_per_cor_clin)
cor.test(together_pat$RDLPFC_both_loads,together_pat$per_cor)
cor.test(together_pat$BLVC_ld3,together_pat$ld3_per_cor)
cor.test(together_pat$BLVC_ld1,together_pat$ld1_per_cor)
cor.test(together_pat$RDLPFC_both_loads,together_pat$RIPL_both_loads)

lm<-
  
theme_classic()+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_colour_manual(values = c("light grey","gray8"))+ theme_bw()+labs(x=(xlab), y=(ylab))+scale_fill_manual(values = c("light grey","gray8"))+theme(text = element_text(size=26))+theme(legend.position="none") +theme(axis.line = element_line(colour = "black"), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(), panel.background = element_blank())
p1<-p+ geom_point(data=data_ROIs_scz,aes(x=ld3_per_cor,y=LBA9_delay_ld3),colour="red",size=6,pch=16) 
p2<-p1+ geom_point(data=data_ROIs_other,aes(x=ld3_per_cor,y=LBA9_delay_ld3),colour="black",size=6,pch=1) 
p2<-p1+ geom_point(data=data_ROIs_unc,aes(x=ld3_per_cor,y=LBA9_delay_ld3),colour="grey40",size=6,pch=16) 

print(p2)
dev.off()

#behavior relationships
behave<-read.delim(file="/Users/mariaj/Dropbox/P5_WM_behave_data.txt",sep=" ")

combo<-merge(data_ROIs,behave,by.x="ID",by.y="subjid")


cor.test(combo$avg_RT,combo$RDLPFC_both_loads)
cor.test(combo$per_cor,combo$RDLPFC_both_loads
cor.test(combo$ld3_per_cor,combo$RDLPFC2_delay_ld3)
                  
cor.test(combo$ld1_per_cor,combo$RDLPFC2_delay_ld1)


combo_pat<-combo[combo$Cohort.x=="Clinical",]
cor.test(combo_pat$avg_RT,combo_pat$RDLPFC_both_loads)
cor.test(combo_pat$per_cor,combo_pat$RDLPFC_both_loads)
cor.test(combo_pat$ld3_avg_RT,combo_pat$RDLPFC2_delay_ld3)
cor.test(combo_pat$ld3_per_cor,combo_pat$RDLPFC2_delay_ld3)
cor.test(combo_pat$ld1_avg_RT,combo_pat$RDLPFC2_delay_ld1)
cor.test(combo_pat$ld1_per_cor,combo_pat$RDLPFC2_delay_ld1)



combo_con<-combo[combo$Cohort.x=="Control",]
cor.test(combo_con$avg_RT,combo_con$RDLPFC_both_loads)
cor.test(combo_con$per_cor,combo_con$RDLPFC_both_loads)
cor.test(combo_con$ld3_avg_RT,combo_con$RDLPFC2_delay_ld3)
cor.test(combo_con$ld3_per_cor,combo_con$RDLPFC2_delay_ld3)
cor.test(combo_con$ld1_avg_RT,combo_con$RDLPFC2_delay_ld1)
cor.test(combo_con$ld1_per_cor,combo_con$RDLPFC2_delay_ld1)




combo_sz<-combo[combo$confirmed_initial_dx1.x==1,]
cor.test(combo_sz$per_cor,combo_sz$RDLPFC_both_loads)
cor.test(combo_sz$avg_RT,combo_sz$RDLPFC_both_loads)
cor.test(combo_sz$ld3_per_cor,combo_sz$RDLPFC2_delay_ld3)
cor.test(combo_sz$ld1_per_cor,combo_sz$RDLPFC2_delay_ld1)


combo_oth<-combo[combo$confirmed_initial_dx1.x==2,]
cor.test(combo_oth$per_cor,combo_oth$RDLPFC_both_loads)
cor.test(combo_oth$avg_RT,combo_oth$RDLPFC_both_loads)
cor.test(combo_oth$ld3_per_cor,combo_oth$RDLPFC2_delay_ld3)
cor.test(combo_oth$ld1_per_cor,combo_oth$RDLPFC2_delay_ld1)



xlab<-"ld 3 % correct"
ylab<-"R DLPFC Load 3 Activation\n"

combo$confirmed_initial_dx1.x<-as.factor(combo$confirmed_initial_dx1.x)
p<-ggplot(combo,aes(x=ld3_per_cor,y=RDLPFC2_delay_ld3,color=confirmed_initial_dx1.x)) +geom_point(aes(fill=confirmed_initial_dx1.x),size=6,colour="black",pch=21)+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ scale_fill_manual(values=c('red','blue','white')) +scale_colour_manual(values=c('red','blue','dark grey'))+ labs(x=(xlab), y=(ylab))+theme_bw() +theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
p




#Extra not using right now
tapply(data_ROIs$LDLPFC2_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LDLPFC2_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RDLPFC2_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RDLPFC2_delay_ld3,data_ROIs$Cohort,mean)

tapply(data_ROIs$LDLPFC1_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LDLPFC1_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RDLPFC1_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RDLPFC1_delay_ld3,data_ROIs$Cohort,mean)

tapply(data_ROIs$LIPL_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LIPL_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RIPL_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RIPL_delay_ld3,data_ROIs$Cohort,mean)



tapply(data_ROIs$LVC_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LVC_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RVC_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RVC_delay_ld3,data_ROIs$Cohort,mean)

tapply(data_ROIs$LCING_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LCING_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RCING_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RCING_delay_ld3,data_ROIs$Cohort,mean)

tapply(data_ROIs$LINS_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$LINS_delay_ld3,data_ROIs$Cohort,mean)
tapply(data_ROIs$RINS_delay_ld1,data_ROIs$Cohort,mean)
tapply(data_ROIs$RINS_delay_ld3,data_ROIs$Cohort,mean)


combo$BLVC_change<-combo$BLVC_ld1-combo$BLVC_ld3
combo$behave_change<-combo$ld3_per_cor-combo$ld1_per_cor
combo$RT_change<-combo$ld3_avg_RT-combo$ld1_avg_RT


data_ROIs$RIPL_both_loads<-(data_ROIs$RIPL_delay_ld1+data_ROIs$RIPL_delay_ld3)/2
tapply(data_ROIs$RIPL_both_loads,data_ROIs$Cohort,mean)
t.test(RIPL_both_loads~Cohort,data=data_ROIs)

data_ROIs$LIPL_both_loads<-(data_ROIs$LIPL_delay_ld1+data_ROIs$LIPL_delay_ld3)/2
tapply(data_ROIs$LIPL_both_loads,data_ROIs$Cohort,mean)
t.test(LIPL_both_loads~Cohort,data=data_ROIs)



pat<- data_ROIs[data_ROIs$Cohort=="Clinical",]
t.test(pat$RIPL_both_loads,pat$LIPL_both_loads)
con<- data_ROIs[data_ROIs$Cohort=="Control",]
t.test(con$RIPL_both_loads,con$LIPL_both_loads)

for (i in 44:44)
  
  
  
  model_beh<-glm(data_ROIs$BLVC_ld3~as.factor(data_ROIs$Cohort),data=data_ROIs)
summary(model_beh)


#compare other scz to other psychotic dx
data_table_dx<-data_ROIs[data_ROIs$confirmed_initial_dx1=="2" | data_ROIs$confirmed_initial_dx1=="3", ]

for (i in 44:44)
  
{
  
  model_beh<-glm(data_table_dx[[i]]~as.factor(data_table_dx$confirmed_initial_dx1),data=data_table_dx)
  print((summary(model_beh)$coefficients[2,4]))
}





write.table(data_ROIs,file="/Users/mariaj/Dropbox/P5_WM_ROI.txt")