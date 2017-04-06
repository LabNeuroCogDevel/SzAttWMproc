#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)
library(LNCDR)


source("C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")

#Popout Analysis-Neurosynth ROIs
#Popout<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Popout_powersROIs_mean.txt",header=T)
Popout<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/Att/ROIs/Habitual_NSROIs_mean.txt",header=T)
Popout.1<<-Popout[-grep("File",Popout$File),]


Popout.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Popout.1$File)
Popout.1$File<-substr(Popout.1$File,1,14)

grepl("Mean",names(Popout.1))
Popout.2<-Popout.1[ , c(1, which( grepl("Mean",names(Popout.1))  ))]
Popout.3<-mutate_each(Popout.2,funs(as.numeric(as.character(.))))
Popout.4<-cbind(Popout.2$File,Popout.3[,2:13])

#labels<-read.delim(file="/Volumes/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
colnames(Popout.4)<-c("ID","LIPL", "RIPL", "LVis", "RVis", "LFEF", "RFEF", "LIFG", "RIFG", "LIns", "RIns", "LTPJ", "RTPJ")


subj<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/SubjInfoGoogleSheet_att_wdx.txt")
data_ROIs<-merge(Popout.4,subj,by.x="ID",by.y="MRID")




#IPL Group
keep = match(c("ID","LIPL","RIPL", "Cohort"), colnames(data_ROIs))
IPL_ROIs<-data_ROIs[,keep]
IPL_ROIs.1 <- melt(IPL_ROIs, id.vars=c("ID","Cohort"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Att_IPL_aov<-aov(value~Cohort*hem+Error(ID/hem),data=IPL_ROIs.1)
summary(Att_IPL_aov)

#IPL Diagnostic
keep2 = match(c("ID","LIPL","RIPL", "confirmed_initial_dx1"), colnames(data_ROIs))
IPL_ROIs_dx<-data_ROIs[,keep2]
IPL_ROIs.1 <- melt(IPL_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Attdx_IPL_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=IPL_ROIs.1 )
summary(Attdx_IPL_aov)

#Vis Group
keep = match(c("ID","LVis","RVis", "Cohort"), colnames(data_ROIs))
Vis_ROIs<-data_ROIs[,keep]
Vis_ROIs.1 <- melt(Vis_ROIs, id.vars=c("ID","Cohort"))
Vis_ROIs.1$hem<-substr(Vis_ROIs.1$variable,1,1)
Vis_ROIs.1$hem<-as.factor(Vis_ROIs.1$hem)
Att_Vis_aov<-aov(value~Cohort*hem+Error(ID/hem),data=Vis_ROIs.1)
summary(Att_Vis_aov)

#Vis Diagnostic
keep2 = match(c("ID","LVis","RVis", "confirmed_initial_dx1"), colnames(data_ROIs))
Vis_ROIs_dx<-data_ROIs[,keep2]
Vis_ROIs.1 <- melt(Vis_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
Vis_ROIs.1$hem<-substr(Vis_ROIs.1$variable,1,1)
Vis_ROIs.1$hem<-as.factor(Vis_ROIs.1$hem)
Attdx_Vis_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=Vis_ROIs.1 )
summary(Attdx_Vis_aov)

#FEF Group
keep = match(c("ID","LFEF","RFEF", "Cohort"), colnames(data_ROIs))
FEF_ROIs<-data_ROIs[,keep]
FEF_ROIs.1 <- melt(FEF_ROIs, id.vars=c("ID","Cohort"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Att_FEF_aov<-aov(value~Cohort*hem+Error(ID/hem),data=FEF_ROIs.1)
summary(Att_FEF_aov)

#FEF Diagnostic
keep2 = match(c("ID","LFEF","RFEF", "confirmed_initial_dx1"), colnames(data_ROIs))
FEF_ROIs_dx<-data_ROIs[,keep2]
FEF_ROIs.1 <- melt(FEF_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Attdx_FEF_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=FEF_ROIs.1 )
summary(Attdx_FEF_aov)

#IFG Group
keep = match(c("ID","LIFG","RIFG", "Cohort"), colnames(data_ROIs))
IFG_ROIs<-data_ROIs[,keep]
IFG_ROIs.1 <- melt(IFG_ROIs, id.vars=c("ID","Cohort"))
IFG_ROIs.1$hem<-substr(IFG_ROIs.1$variable,1,1)
IFG_ROIs.1$hem<-as.factor(IFG_ROIs.1$hem)
Att_IFG_aov<-aov(value~Cohort*hem+Error(ID/hem),data=IFG_ROIs.1)
summary(Att_IFG_aov)

#IFG Diagnostic
keep2 = match(c("ID","LIFG","RIFG", "confirmed_initial_dx1"), colnames(data_ROIs))
IFG_ROIs_dx<-data_ROIs[,keep2]
IFG_ROIs.1 <- melt(IFG_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
IFG_ROIs.1$hem<-substr(IFG_ROIs.1$variable,1,1)
IFG_ROIs.1$hem<-as.factor(IFG_ROIs.1$hem)
Attdx_IFG_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=IFG_ROIs.1 )
summary(Attdx_IFG_aov)

#Ins Group
keep = match(c("ID","LIns","RIns", "Cohort"), colnames(data_ROIs))
Ins_ROIs<-data_ROIs[,keep]
Ins_ROIs.1 <- melt(Ins_ROIs, id.vars=c("ID","Cohort"))
Ins_ROIs.1$hem<-substr(Ins_ROIs.1$variable,1,1)
Ins_ROIs.1$hem<-as.factor(Ins_ROIs.1$hem)
Att_Ins_aov<-aov(value~Cohort*hem+Error(ID/hem),data=Ins_ROIs.1)
summary(Att_Ins_aov)

#Ins Diagnostic
keep2 = match(c("ID","LIns","RIns", "confirmed_initial_dx1"), colnames(data_ROIs))
Ins_ROIs_dx<-data_ROIs[,keep2]
Ins_ROIs.1 <- melt(Ins_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
Ins_ROIs.1$hem<-substr(Ins_ROIs.1$variable,1,1)
Ins_ROIs.1$hem<-as.factor(Ins_ROIs.1$hem)
Attdx_Ins_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=Ins_ROIs.1 )
summary(Attdx_Ins_aov)

#TPJ Group
keep = match(c("ID","LTPJ","RTPJ", "Cohort"), colnames(data_ROIs))
TPJ_ROIs<-data_ROIs[,keep]
TPJ_ROIs.1 <- melt(TPJ_ROIs, id.vars=c("ID","Cohort"))
TPJ_ROIs.1$hem<-substr(TPJ_ROIs.1$variable,1,1)
TPJ_ROIs.1$hem<-as.factor(TPJ_ROIs.1$hem)
Att_TPJ_aov<-aov(value~Cohort*hem+Error(ID/hem),data=TPJ_ROIs.1)
summary(Att_TPJ_aov)

#TPJ Diagnostic
keep2 = match(c("ID","LTPJ","RTPJ", "confirmed_initial_dx1"), colnames(data_ROIs))
TPJ_ROIs_dx<-data_ROIs[,keep2]
TPJ_ROIs.1 <- melt(TPJ_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
TPJ_ROIs.1$hem<-substr(TPJ_ROIs.1$variable,1,1)
TPJ_ROIs.1$hem<-as.factor(TPJ_ROIs.1$hem)
Attdx_TPJ_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=TPJ_ROIs.1 )
summary(Attdx_TPJ_aov)


#ttest follow-ups
t.test(LTPJ~Cohort,data=data_ROIs)
t.test(RTPJ~Cohort,data=data_ROIs)

pat_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Clinical",]
con_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Control",]

t.test(pat_data_ROIs$RTPJ,pat_data_ROIs$LTPJ,paired=TRUE)
t.test(con_data_ROIs$RTPJ,con_data_ROIs$LTPJ,paired=TRUE)

data_ROIs_sub1<-data_ROIs[data_ROIs$confirmed_initial_dx1=="2" | data_ROIs$confirmed_initial_dx1=="3", ]

t.test(LTPJ~confirmed_initial_dx1,data=data_ROIs_sub1)
t.test(RTPJ~confirmed_initial_dx1,data=data_ROIs_sub1)


#cohort mean and standard error
keep4 = match(c("ID","LTPJ","RTPJ","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
TPJ_plot<-data_ROIs[,keep4]
d.per_cor<- TPJ_plot %>% 
  gather(Hem,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)
names(d.per_cor)[4:5]<-c("Hem","value")
d.per_cor$Hem<-gsub("LTPJ","L",d.per_cor$Hem)
d.per_cor$Hem<-gsub("RTPJ","R",d.per_cor$Hem)
d.per_cor$Hem<-factor(d.per_cor$Hem,levels=list('L','R'),labels=list('L','R'))
d.grp <- d.per_cor %>% 
  group_by(Cohort,Hem) %>%  
  meanse 

#create plot for cohort data
pdf('//10.145.64.109/P5/scripts/Rplots/imgs/DLPFC2_popout_group.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  plot_bar_and_error(d.grp,fill='Cohort',levelname='Hem') + 
  scale_fill_manual(values=c('grey36','white')) +
  labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black')) +
  coord_cartesian(ylim=c(-5,5))
print(p.grp)

dev.off()

#diagnostic mean and standard error
d.dx <- d.per_cor %>% 
  group_by(confirmed_initial_dx1,Hem) %>%  
  meanse
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)


#create plot for diagnostic data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/RDLPFC2_popout_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  plot_bar_and_error(d.dx,fill='confirmed_initial_dx1',levelname='Hem') + 
  scale_fill_manual(values=c('grey13','grey72','white'))   +
  labs(x=(xlab), y=(ylab))+
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black')) +
  coord_cartesian(ylim=c(-3,28))
print(p.grp)

dev.off()
