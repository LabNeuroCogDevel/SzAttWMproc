#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)


#source("//10.145.64.109/Phillips/P5/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")

#Popout Analysis-Power ROIs
Popout<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Popout_powersROIs_mean.txt",header=T)
Popout.1<<-Popout[-grep("File",Popout$File),]

Popout.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Popout.1$File)
Popout.1$File<-substr(Popout.1$File,1,14)

grepl("Mean",names(Popout.1))
Popout.2<-Popout.1[ , c(1, which( grepl("Mean",names(Popout.1))  ))]
Popout.3<-mutate_each(Popout.2,funs(as.numeric(as.character(.))))
Popout.4<-cbind(Popout.2$File,Popout.3[,2:265])

labels<-read.delim(file="/Volumes/Phillips/P5/scripts/Att/power_roi_labels.txt",header=F)
colnames(Popout.4)<-labels$V1



data_ROIs<-merge(Popout.4,subj,by.x="ID",by.y="MRID")




#DLPFC2 Group
keep = match(c("ID","LDLPFC2_popout","RDLPFC2_popout", "Cohort"), colnames(data_ROIs))
DLPFC2_ROIs<-data_ROIs[,keep]
DLPFC2_ROIs.1 <- melt(DLPFC2_ROIs, id.vars=c("ID","Cohort"))
DLPFC2_ROIs.1$hem<-substr(DLPFC2_ROIs.1$variable,1,1)
DLPFC2_ROIs.1$hem<-as.factor(DLPFC2_ROIs.1$hem)
Att_DLPFC2_aov<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC2_ROIs.1)
summary(Att_DLPFC2_aov)

#DLPFC2 Diagnostic
keep2 = match(c("ID","LDLPFC2_popout","RDLPFC2_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC2_ROIs_dx<-data_ROIs[,keep2]
DLPFC2_ROIs.1 <- melt(DLPFC2_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
DLPFC2_ROIs.1$hem<-substr(DLPFC2_ROIs.1$variable,1,1)
DLPFC2_ROIs.1$hem<-as.factor(DLPFC2_ROIs.1$hem)
Attdx_DLPFC2_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC2_ROIs.1 )
summary(Attdx_DLPFC2_aov)


#IPL Group
keep = match(c("ID","LIPL_popout","RIPL_popout", "Cohort"), colnames(data_ROIs))
IPL_ROIs<-data_ROIs[,keep]
IPL_ROIs.1 <- melt(IPL_ROIs, id.vars=c("ID","Cohort"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Att_IPL_aov<-aov(value~Cohort*hem+Error(ID/hem),data=IPL_ROIs.1)
summary(Att_IPL_aov)

#IPL Diagnostic
keep2 = match(c("ID","LIPL_popout","RIPL_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
IPL_ROIs_dx<-data_ROIs[,keep2]
IPL_ROIs.1 <- melt(IPL_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Attdx_IPL_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=IPL_ROIs.1 )
summary(Attdx_IPL_aov)


#VC Group
keep = match(c("ID","LVC_popout","RVC_popout", "Cohort"), colnames(data_ROIs))
VC_ROIs<-data_ROIs[,keep]
VC_ROIs.1 <- melt(VC_ROIs, id.vars=c("ID","Cohort"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Att_VC_aov<-aov(value~Cohort*hem+Error(ID/hem),data=VC_ROIs.1)
summary(Att_VC_aov)

#VC Diagnostic
keep2 = match(c("ID","LVC_popout","RVC_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
VC_ROIs_dx<-data_ROIs[,keep2]
VC_ROIs.1 <- melt(VC_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Attdx_VC_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=VC_ROIs.1 )
summary(Attdx_VC_aov)


#CING Group
keep = match(c("ID","LCING_popout","RCING_popout", "Cohort"), colnames(data_ROIs))
CING_ROIs<-data_ROIs[,keep]
CING_ROIs.1 <- melt(CING_ROIs, id.vars=c("ID","Cohort"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Att_CING_aov<-aov(value~Cohort*hem+Error(ID/hem),data=CING_ROIs.1)
summary(Att_CING_aov)

#CING Diagnostic
keep2 = match(c("ID","LCING_popout","RCING_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
CING_ROIs_dx<-data_ROIs[,keep2]
CING_ROIs.1 <- melt(CING_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Attdx_CING_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=CING_ROIs.1 )
summary(Attdx_CING_aov)


#DLPFC1 Group
keep = match(c("ID","LDLPFC1_popout","RDLPFC1_popout", "Cohort"), colnames(data_ROIs))
DLPFC1_ROIs<-data_ROIs[,keep]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs, id.vars=c("ID","Cohort"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Att_DLPFC1_aov<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC1_ROIs.1)
summary(Att_DLPFC1_aov)

#DLPFC1 Diagnostic
keep2 = match(c("ID","LDLPFC1_popout","RDLPFC1_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC1_ROIs_dx<-data_ROIs[,keep2]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Attdx_DLPFC1_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC1_ROIs.1 )
summary(Attdx_DLPFC1_aov)


#FEF Group
keep = match(c("ID","LFEF_popout","RFEF_popout", "Cohort"), colnames(data_ROIs))
FEF_ROIs<-data_ROIs[,keep]
FEF_ROIs.1 <- melt(FEF_ROIs, id.vars=c("ID","Cohort"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Att_FEF_aov<-aov(value~Cohort*hem+Error(ID/hem),data=FEF_ROIs.1)
summary(Att_FEF_aov)

#FEF Diagnostic
keep2 = match(c("ID","LFEF_popout","RFEF_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
FEF_ROIs_dx<-data_ROIs[,keep2]
FEF_ROIs.1 <- melt(FEF_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Attdx_FEF_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=FEF_ROIs.1 )
summary(Attdx_FEF_aov)


#INS Group
keep = match(c("ID","LINS_popout","RINS_popout", "Cohort"), colnames(data_ROIs))
INS_ROIs<-data_ROIs[,keep]
INS_ROIs.1 <- melt(INS_ROIs, id.vars=c("ID","Cohort"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Att_INS_aov<-aov(value~Cohort*hem+Error(ID/hem),data=INS_ROIs.1)
summary(Att_INS_aov)

#INS Diagnostic
keep2 = match(c("ID","LINS_popout","RINS_popout", "confirmed_initial_dx1"), colnames(data_ROIs))
INS_ROIs_dx<-data_ROIs[,keep2]
INS_ROIs.1 <- melt(INS_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Attdx_INS_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=INS_ROIs.1 )
summary(Attdx_INS_aov)

#ttest follow-ups
t.test(LDLPFC2_popout~Cohort,data=data_ROIs)
t.test(RDLPFC2_popout~Cohort,data=data_ROIs)

pat_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Clinical",]
con_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Control",]

t.test(pat_data_ROIs$RDLPFC2_popout,pat_data_ROIs$LDLPFC2_popout,paired=TRUE)
t.test(con_data_ROIs$RDLPFC2_popout,con_data_ROIs$LDLPFC2_popout,paired=TRUE)

data_ROIs_sub1<-data_ROIs[data_ROIs$confirmed_initial_dx1=="2" | data_ROIs$confirmed_initial_dx1=="3", ]

t.test(LDLPFC2_popout~confirmed_initial_dx1,data=data_ROIs_sub1)
t.test(RDLPFC2_popout~confirmed_initial_dx1,data=data_ROIs_sub1)


#cohort mean and standard error
keep4 = match(c("ID","LDLPFC2_popout","RDLPFC2_popout","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC_plot<-data_ROIs[,keep4]
d.per_cor<- DLPFC_plot %>% 
  gather(Hem,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)
names(d.per_cor)[4:5]<-c("Hem","value")
d.per_cor$Hem<-gsub("LDLPFC2_popout","L",d.per_cor$Hem)
d.per_cor$Hem<-gsub("RDLPFC2_popout","R",d.per_cor$Hem)
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
  coord_cartesian(ylim=c(0,22))
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
