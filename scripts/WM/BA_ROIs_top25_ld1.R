#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)

delay_ld1<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay_ld1_final_BA_spheres_max.txt",header=F)
fornames<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/20160801_subj_list.txt",header=F)
delay_ld1.1<-cbind(fornames$V1,delay_ld1)
colnames(delay_ld1.1)<-c("ID","LCING_delay_ld1","LDLPFC_BA46_delay_ld1","LDLPFC_BA9_delay_ld1","LFEF_delay_ld1","LIPL_delay_ld1","LVC_delay_ld1","LINS_delay_ld1","RCING_delay_ld1","RDLPFC_BA46_delay_ld1","RDLPFC_BA9_delay_ld1","RFEF_delay_ld1","RIPL_delay_ld1","RVC_delay_ld1","RINS_delay_ld1")

#dont need these right now -20160801
#bad_subs<-match(c("11333_20141017","11369_20150519"),delay_ld1.1$ID)
#delay_ld1.2<-delay_ld1.1[-bad_subs,]
#write this table to Dropbox for ROI_mean_side_load.R)
#write.table(delay_ld1.2,file="/Users/mariaj/Dropbox/delay_ld1_BA_spheres_top25.txt")


#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")


data_ROIs<-merge(delay_ld1.1,subj,by.x="ID",by.y="MRID")

#right now lets just do our DLPFC, PPC, and VC subset
keep = match(c("ID","LDLPFC_BA9_delay_ld1","LIPL_delay_ld1","LVC_delay_ld1","RDLPFC_BA9_delay_ld1","RIPL_delay_ld1","RVC_delay_ld1","Cohort","confirmed_initial_dx1","meds","age","sex"), colnames(data_ROIs))


data_ROIs.1<-data_ROIs[,keep]


#create bilateral ROIs
#data_ROIs$BBA17_delay_ld1<-(data_ROIs$LBA17_delay_ld1+data_ROIs$RBA17_delay_ld1)/2
#data_ROIs$BBA40_delay_ld1<-(data_ROIs$LBA40_delay_ld1+data_ROIs$RBA40_delay_ld1)/2
#data_ROIs$BBA46_delay_ld1<-(data_ROIs$LBA46_delay_ld1+data_ROIs$RBA46_delay_ld1)/2
#data_ROIs$BBA9_delay_ld1<-(data_ROIs$LBA9_delay_ld1+data_ROIs$RBA9_delay_ld1)/2

#write.table(data_ROIs[,c(1,22:24)],file="/Volumes/Phillips/P5/scripts/20160307_BLROIS_ld1.txt")

table(data_ROIs$Cohort)

for (i in 2:7)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,3]))
}

#compare only scz to controls
data_ROIs_dx<-data_ROIs[data_ROIs$confirmed_initial_dx1=="1" | data_ROIs$confirmed_initial_dx1=="3", ]

for (i in 2:7)
  
{
  
  model_beh<-glm(data_ROIs_dx[[i]]~as.factor(data_ROIs_dx$confirmed_initial_dx1),data=data_ROIs_dx)
  print((summary(model_beh)$coefficients[2,4]))
}


#Left ROI by group interaction
#NS
WM<-data_ROIs.1[,c(1:4,8)]
WM2 <- melt(WM, id.vars=c("ID","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(ID/variable),data=WM2)
summary(WM_aov1)

#Right ROI by group interaction
#NS
WM<-data_ROIs.1[,c(1,5:8)]
WM2 <- melt(WM, id.vars=c("ID","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(ID/variable),data=WM2)
summary(WM_aov1)



data_ROIs_cont<-data_ROIs[data_ROIs$Cohort=="Control",]
cor.test(data_ROIs_cont$age,data_ROIs_cont$RBA46_delay_ld1)
cor.test(data_ROIs_cont$age,data_ROIs_cont$RBA9_delay_ld1)
#cor.test(data_ROIs_cont$age,data_ROIs_cont$ld1_per_cor)

data_ROIs_pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
cor.test(data_ROIs_pat$age,data_ROIs_pat$RBA46_delay_ld1)
cor.test(data_ROIs_pat$age,data_ROIs_pat$RBA9_delay_ld1)
#cor.test(data_ROIs_pat$age,data_ROIs_pat$ld1_per_cor)

#remove the 35 year old w/ really low activation
data_ROIs_pat.2<-data_ROIs_pat[c(1:17,19:25),]

cor.test(data_ROIs_pat.2$age,data_ROIs_pat.2$RBA46_delay_ld1)
cor.test(data_ROIs_pat.2$age,data_ROIs_pat.2$RBA9_delay_ld1)
#cor.test(data_ROIs_pat.2$age,data_ROIs_pat.2$ld1_per_cor)


pdf(paste("Ld1_percor_age_relationships.pdf"))
textSize <- 24
xlab<-"Age(years)"
ylab<-"Load 1 % correct"
BA_plot<- ggplot(data_ROIs) + geom_point(data=data_ROIs,aes(x=age, y=,colour=Cohort),alpha=.8,size=4,pch=16)+aes(x=age, y=ld1_per_cor,colour=Cohort,group=Cohort)+scale_color_manual(values=c("light grey","grey8"))+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+labs(x=(xlab),y=(ylab))
print(BA_plot)
dev.off()

data_ROIs$avg_RT_ld1<-data_ROIs$avg_RT_ld1*1000
pdf(paste("Ld1_RT_age_relationships.pdf"))
textSize <- 24
xlab<-"Age(years)"
ylab<-"Load 1 RT (ms)"
BA_plot<- ggplot(data_ROIs) + geom_point(data=data_ROIs,aes(x=age, y=,colour=Cohort),alpha=.8,size=4,pch=16)+aes(x=age, y=avg_RT_ld1,colour=Cohort,group=Cohort)+scale_color_manual(values=c("light grey","grey8"))+stat_smooth(method="lm",formula=y~x,size=2,se=FALSE)+ theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+labs(x=(xlab),y=(ylab))
print(BA_plot)
dev.off()



std <- function(x) sd(x)/sqrt(length(x))

#new data table name
# put all % correct into one column (and load into another)
dt_RTAccLong <- data_ROIs 
dt_RTAccLong.1<-dt_RTAccLong %>%
  mutate( Dx = factor(confirmed_initial_dx,labels=list('SCZ','Other','Control','Unconfirmed')) )
dt_RTAccLong.2<-dt_RTAccLong.1 %>%
  mutate( Cohort = factor(Cohort,labels=list("First Episode","Control")) )

# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA17_delay_ld1)

pdf(paste("LBA17_delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA17_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA17_delay_ld1)

pdf(paste("RBA17_delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA17_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()



# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA40_delay_ld1)

pdf(paste("LBA40_delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA40_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA40_delay_ld1)

pdf(paste("RBA40_delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA40_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()

# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA9_delay_ld1)

pdf(paste("LBA9_delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA9_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA9_delay_ld1)

pdf(paste("RBA9delay_ld1.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA9_delay_ld1,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()






