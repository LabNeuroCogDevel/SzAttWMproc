#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)
library(LNCDR)

source("//10.145.64.109/Phillips/P5/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")

#Habitual Analysis

#Prepare data_ROIs sheet
Habitual<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/txt/Habitual_ROIs_mean.txt",header=T)
#Habitual<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/Habitual_ROIs_mean.txt",header=T)
Habitual.1<<-Habitual[-grep("File",Habitual$File),]
Habitual.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Habitual.1$File)
Habitual.1$File<-substr(Habitual.1$File,1,14)
grepl("Mean",names(Habitual.1))
Habitual.2<-Habitual.1[ , c(1, which( grepl("Mean",names(Habitual.1))  ))]
Habitual.3<-mutate_each(Habitual.2,funs(as.numeric(as.character(.))))
Habitual.4<-cbind(Habitual.2$File,Habitual.3[,2:15])
colnames(Habitual.4)<-c("ID","LCING_habitual","LDLPFC1_habitual","LDLPFC2_habitual","LFEF_habitual","LIPL_habitual","LVC_habitual","LINS_habitual","RCING_habitual","RDLPFC1_habitual","RDLPFC2_habitual","RFEF_habitual","RIPL_habitual","RVC_habitual","RINS_habitual")
subj<-read.delim(file="//10.145.64.109/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
data_ROIs<-merge(Habitual.4,subj,by.x="ID",by.y="MRID")

#Make table from the merged data 
write.table(data_ROIs,file="/Users/Dhruv/Documents/P5_Habitual_Activation.txt")


#DLPFC2 Group
keep = match(c("ID","LDLPFC2_habitual","RDLPFC2_habitual", "Cohort"), colnames(data_ROIs))
DLPFC2_ROIs<-data_ROIs[,keep]
DLPFC2_ROIs.1 <- melt(DLPFC2_ROIs, id.vars=c("ID","Cohort"))
DLPFC2_ROIs.1$hem<-substr(DLPFC2_ROIs.1$variable,1,1)
DLPFC2_ROIs.1$hem<-as.factor(DLPFC2_ROIs.1$hem)
Att_DLPFC2_aov<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC2_ROIs.1)
summary(Att_DLPFC2_aov)

#DLPFC2 Diagnostic
keep2 = match(c("ID","LDLPFC2_habitual","RDLPFC2_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC2_ROIs_dx<-data_ROIs[,keep2]
DLPFC2_ROIs.1 <- melt(DLPFC2_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
DLPFC2_ROIs.1$hem<-substr(DLPFC2_ROIs.1$variable,1,1)
DLPFC2_ROIs.1$hem<-as.factor(DLPFC2_ROIs.1$hem)
Attdx_DLPFC2_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC2_ROIs.1 )
summary(Attdx_DLPFC2_aov)


#IPL Group
keep = match(c("ID","LIPL_habitual","RIPL_habitual", "Cohort"), colnames(data_ROIs))
IPL_ROIs<-data_ROIs[,keep]
IPL_ROIs.1 <- melt(IPL_ROIs, id.vars=c("ID","Cohort"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Att_IPL_aov<-aov(value~Cohort*hem+Error(ID/hem),data=IPL_ROIs.1)
summary(Att_IPL_aov)

#IPL Diagnostic
keep2 = match(c("ID","LIPL_habitual","RIPL_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
IPL_ROIs_dx<-data_ROIs[,keep2]
IPL_ROIs.1 <- melt(IPL_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
IPL_ROIs.1$hem<-substr(IPL_ROIs.1$variable,1,1)
IPL_ROIs.1$hem<-as.factor(IPL_ROIs.1$hem)
Attdx_IPL_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=IPL_ROIs.1 )
summary(Attdx_IPL_aov)


#VC Group
keep = match(c("ID","LVC_habitual","RVC_habitual", "Cohort"), colnames(data_ROIs))
VC_ROIs<-data_ROIs[,keep]
VC_ROIs.1 <- melt(VC_ROIs, id.vars=c("ID","Cohort"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Att_VC_aov<-aov(value~Cohort*hem+Error(ID/hem),data=VC_ROIs.1)
summary(Att_VC_aov)

#VC Diagnostic
keep2 = match(c("ID","LVC_habitual","RVC_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
VC_ROIs_dx<-data_ROIs[,keep2]
VC_ROIs.1 <- melt(VC_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
VC_ROIs.1$hem<-substr(VC_ROIs.1$variable,1,1)
VC_ROIs.1$hem<-as.factor(VC_ROIs.1$hem)
Attdx_VC_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=VC_ROIs.1 )
summary(Attdx_VC_aov)


#CING Group
keep = match(c("ID","LCING_habitual","RCING_habitual", "Cohort"), colnames(data_ROIs))
CING_ROIs<-data_ROIs[,keep]
CING_ROIs.1 <- melt(CING_ROIs, id.vars=c("ID","Cohort"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Att_CING_aov<-aov(value~Cohort*hem+Error(ID/hem),data=CING_ROIs.1)
summary(Att_CING_aov)

#CING Diagnostic
keep2 = match(c("ID","LCING_habitual","RCING_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
CING_ROIs_dx<-data_ROIs[,keep2]
CING_ROIs.1 <- melt(CING_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
CING_ROIs.1$hem<-substr(CING_ROIs.1$variable,1,1)
CING_ROIs.1$hem<-as.factor(CING_ROIs.1$hem)
Attdx_CING_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=CING_ROIs.1 )
summary(Attdx_CING_aov)


#DLPFC1 Group
keep = match(c("ID","LDLPFC1_habitual","RDLPFC1_habitual", "Cohort"), colnames(data_ROIs))
DLPFC1_ROIs<-data_ROIs[,keep]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs, id.vars=c("ID","Cohort"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Att_DLPFC1_aov<-aov(value~Cohort*hem+Error(ID/hem),data=DLPFC1_ROIs.1)
summary(Att_DLPFC1_aov)

#DLPFC1 Diagnostic
keep2 = match(c("ID","LDLPFC1_habitual","RDLPFC1_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC1_ROIs_dx<-data_ROIs[,keep2]
DLPFC1_ROIs.1 <- melt(DLPFC1_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
DLPFC1_ROIs.1$hem<-substr(DLPFC1_ROIs.1$variable,1,1)
DLPFC1_ROIs.1$hem<-as.factor(DLPFC1_ROIs.1$hem)
Attdx_DLPFC1_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=DLPFC1_ROIs.1 )
summary(Attdx_DLPFC1_aov)


#FEF Group
keep = match(c("ID","LFEF_habitual","RFEF_habitual", "Cohort"), colnames(data_ROIs))
FEF_ROIs<-data_ROIs[,keep]
FEF_ROIs.1 <- melt(FEF_ROIs, id.vars=c("ID","Cohort"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Att_FEF_aov<-aov(value~Cohort*hem+Error(ID/hem),data=FEF_ROIs.1)
summary(Att_FEF_aov)

#FEF Diagnostic
keep2 = match(c("ID","LFEF_habitual","RFEF_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
FEF_ROIs_dx<-data_ROIs[,keep2]
FEF_ROIs.1 <- melt(FEF_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
FEF_ROIs.1$hem<-substr(FEF_ROIs.1$variable,1,1)
FEF_ROIs.1$hem<-as.factor(FEF_ROIs.1$hem)
Attdx_FEF_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=FEF_ROIs.1 )
summary(Attdx_FEF_aov)


#INS Group
keep = match(c("ID","LINS_habitual","RINS_habitual", "Cohort"), colnames(data_ROIs))
INS_ROIs<-data_ROIs[,keep]
INS_ROIs.1 <- melt(INS_ROIs, id.vars=c("ID","Cohort"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Att_INS_aov<-aov(value~Cohort*hem+Error(ID/hem),data=INS_ROIs.1)
summary(Att_INS_aov)

#INS Diagnostic
keep2 = match(c("ID","LINS_habitual","RINS_habitual", "confirmed_initial_dx1"), colnames(data_ROIs))
INS_ROIs_dx<-data_ROIs[,keep2]
INS_ROIs.1 <- melt(INS_ROIs_dx, id.vars=c("ID","confirmed_initial_dx1"))
INS_ROIs.1$hem<-substr(INS_ROIs.1$variable,1,1)
INS_ROIs.1$hem<-as.factor(INS_ROIs.1$hem)
Attdx_INS_aov<-aov(value~confirmed_initial_dx1*hem+Error(ID/hem),data=INS_ROIs.1 )
summary(Attdx_INS_aov)


#ttest follow-ups

#cohort independent samples t-test
t.test(LDLPFC2_habitual~Cohort,data=data_ROIs)
t.test(RDLPFC2_habitual~Cohort,data=data_ROIs)

#cohort paired samples t-test
pat_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Clinical",]
con_data_ROIs<-data_ROIs[data_ROIs$Cohort=="Control",]
t.test(pat_data_ROIs$RDLPFC2_habitual,pat_data_ROIs$LDLPFC2_habitual,paired=TRUE)
t.test(con_data_ROIs$RDLPFC2_habitual,con_data_ROIs$LDLPFC2_habitual,paired=TRUE)

#diagnostic independent samples t-test
data_ROIs_sub1<-data_ROIs[data_ROIs$confirmed_initial_dx1=="1" | data_ROIs$confirmed_initial_dx1=="2", ]
t.test(LDLPFC2_habitual~confirmed_initial_dx1,data=data_ROIs_sub1)
t.test(RDLPFC2_habitual~confirmed_initial_dx1,data=data_ROIs_sub1)


#cohort mean and standard error
keep4 = match(c("ID","LDLPFC2_habitual","RDLPFC2_habitual","Cohort","confirmed_initial_dx1"), colnames(data_ROIs))
DLPFC_plot<-data_ROIs[,keep4]
d.per_cor<- DLPFC_plot %>% 
  gather(Hem,val,-ID,-Cohort,-confirmed_initial_dx1)%>%
  group_by(Cohort)
names(d.per_cor)[4:5]<-c("Hem","value")
d.per_cor$Hem<-gsub("LDLPFC2_habitual","L",d.per_cor$Hem)
d.per_cor$Hem<-gsub("RDLPFC2_habitual","R",d.per_cor$Hem)
d.per_cor$Hem<-factor(d.per_cor$Hem,levels=list('L','R'),labels=list('L','R'))
d.grp <- d.per_cor %>% 
  group_by(Cohort,Hem) %>%  
  meanse

# redo plot bar and error func
plot_bar_and_error2 <- function(d,fill="dx",levelname='lvl') {
  ggplot(d) +
    aes_string(x=levelname,fill=fill,y="avg") +
    
    geom_bar(stat='identity',position='dodge') +
    geom_errorbar(
      aes(ymin=avg-se,ymax=avg+se),
      position=position_dodge(0.9),
      width=.25) +
    # change the legend
    theme_bw(base_size=textSize)+
    theme(
      legend.position="none",
      panel.border = element_rect(), 
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
      #axis.line = element_line(colour = "black")
    )
}

#create plot for cohort data
pdf('//10.145.64.109/P5/scripts/Rplots/imgs/DLPFC2_habitual_group.pdf')
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
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/RDLPFC2_habitual_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
p.grp <- 
  plot_bar_and_error2(d.dx,fill='confirmed_initial_dx1',levelname='Hem') + 
  scale_fill_manual(values=c('grey13','grey72','white'))   +
  labs(x=(xlab), y=(ylab))+
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black')) +
  coord_cartesian(ylim=c(-1,28))
print(p.grp)

dev.off()

