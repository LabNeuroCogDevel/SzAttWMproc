#ROI analyses for P5-delay period
library(plyr)
library(ggplot2)
library(dplyr)
library(reshape)
library(car)
library(tidyr)
library(LNCDR)


#source("C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/WM/graphing_functions.R")
source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")


#Flexible Analysis
Flexible<-read.delim(file="/Volumes/Phillips/P5/group_analyses/Att/mvm/NS_gm_Flexible_mean.txt",header=T)
#Flexible<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/group_analyses/Att/mvm/NS_gm_Flexible_mean.txt",header=T)
Flexible.1<<-Flexible[-grep("File",Flexible$File),]


Flexible.1$File<-gsub("/Volumes/Phillips/P5/subj/","",Flexible.1$File)
Flexible.1$File<-substr(Flexible.1$File,1,14)

grepl("Mean",names(Flexible.1))
Flexible.2<-Flexible.1[ , c(1, which( grepl("Mean",names(Flexible.1))  ))]
Flexible.3<-mutate_each(Flexible.2,funs(as.numeric(as.character(.))))
Flexible.4<-cbind(Flexible.2$File,Flexible.3[,2:7])

colnames(Flexible.4)<-c("ID","GxC1","GxC2","GxC3","GxCxA1","GxCxA2","GxCxA3")

#subj<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/Att/SubjInfoGoogleSheet_att_wdx.txt")
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_att_wdx.txt")
data_ROIs<-merge(Flexible.4,subj,by.x="ID",by.y="MRID")

control <- data_ROIs[ which(data_ROIs$Cohort=='Control'),]
clinical <- data_ROIs[ which(data_ROIs$Cohort=='Clinical'),]

#GroupxCondition

t.test(GxC1~Cohort,data=data_ROIs)
t.test(GxC2~Cohort,data=data_ROIs)
t.test(GxC3~Cohort,data=data_ROIs)

#GroupxConditionxAge
keep = match(c("ID","GxCxA1", "Cohort","age"), colnames(data_ROIs))
GxCxA1_ROIs<-data_ROIs[,keep]
Att_aov<-aov(GxCxA1~Cohort*age+Error(ID),data=GxCxA1_ROIs)
summary(Att_aov)
cor <- cor.test(control$age,control$GxCxA1)
cor <- cor.test(clinical$age,clinical$GxCxA1)
print(cor$estimate)
print(cor$p.value)

keep = match(c("ID","GxCxA2", "Cohort","age"), colnames(data_ROIs))
GxCxA2_ROIs<-data_ROIs[,keep]
Att_aov<-aov(GxCxA2~Cohort*age+Error(ID),data=GxCxA2_ROIs)
summary(Att_aov)
cor <- cor.test(control$age,control$GxCxA2)
cor <- cor.test(clinical$age,clinical$GxCxA2)
print(cor$estimate)
print(cor$p.value)

keep = match(c("ID","GxCxA3", "Cohort","age"), colnames(data_ROIs))
GxCxA3_ROIs<-data_ROIs[,keep]
Att_aov<-aov(GxCxA3~Cohort*age+Error(ID),data=GxCxA3_ROIs)
summary(Att_aov)
cor <- cor.test(control$age,control$GxCxA3)
cor <- cor.test(clinical$age,clinical$GxCxA3)
print(cor$estimate)
print(cor$p.value)



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
  coord_cartesian(ylim=c(-7,4))
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

# create age plot
ggplot(data_ROIs,aes(x=age,y=Ins,group=Cohort,color=Cohort))+geom_point()+stat_smooth(method="lm")+facet_wrap(~Cohort)+labs(x="Age",y="Parameter Estimate")
ggplot(data_ROIs,aes(x=age,y=Ins))+geom_point()+stat_smooth(method="lm")+labs(x="Age",y="Parameter Estimate")
ggplot(data_ROIs,aes(x=age,y=Ins,color=Cohort))+geom_point()+stat_smooth(method="lm", se=FALSE)+labs(x="Age",y="Parameter Estimate")+theme_bw()+theme(axis.title=element_text(size=27),legend.position="bottom")+scale_color_grey(start=0.7,end=0,name="")


