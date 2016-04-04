#this is for attention behave data
library(plyr)
library(ggplot2)
library(LNCDR)
#load all the WM behav files (they've already been run through matlab)
#copy them over from skynet
WMfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/WorkingMemory*')

#for just one individual
#filename = ('/Volumes/Phillips/P5/scripts/csv/WorkingMemory_11466_20151125_behave.csv')
prefix= '/Volumes/Phillips/P5/scripts/csv/WorkingMemory_'

#I'm making a function that I can then apply on all my files later on
table_correct<-function(filename){
  subjid <- gsub('_behave.csv','',gsub(prefix,'',filename))
  a<-read.table(filename,sep=',',header=T)
  a<-a[!is.nan(a$Crt),]

  total_cor=length(which(a$Crt==1))
  total_inc=length(which(a$Crt==0))
  total_nors=length(which(a$Crt==-1))
  
  per_cor=total_cor/(total_cor+total_inc)*100
  per_cor_clin=total_cor/(total_cor+total_inc+total_nors)*100
  per_inc=total_inc/(total_cor+total_inc)*100
  per_nors=total_nors/(total_cor+total_inc+total_nors)*100
 
  #average RT for correct trial
  avg_RT<-mean(a$RT[ is.finite(a$RT)])
  avg_RT_ld1<-mean(a$RT[ is.finite(a$RT) & a$ld==1])  
  avg_RT_ld3<-mean(a$RT[ is.finite(a$RT) & a$ld==3])  
  

  #ld1
  ld1_cor<-sum(a$Crt == 1 & a$ld  == 1, na.rm=TRUE)
  ld1_inc<-sum(a$Crt == 0 & a$ld  == 1, na.rm=TRUE)
  ld1_nors<-sum(a$Crt == -1 & a$ld  == 1, na.rm=TRUE)
  ld1_per_cor<-ld1_cor/(ld1_cor+ld1_inc)*100
  ld1_per_inc<-ld1_inc/(ld1_cor+ld1_inc)*100

  
  #ld3
  ld3_cor<-sum(a$Crt == 1 & a$ld  == 3, na.rm=TRUE)
  ld3_inc<-sum(a$Crt == 0 & a$ld  == 3, na.rm=TRUE)
  ld3_nors<-sum(a$Crt == -1 & a$ld  == 3, na.rm=TRUE)
  ld3_per_cor<-ld3_cor/(ld3_cor+ld3_inc)*100
  ld3_per_inc<-ld3_inc/(ld3_cor+ld3_inc)*100
  

  #calcualting % correct based on way that Dean & Brian do it
  per_cor_clin<-total_cor/(total_cor+total_inc+total_nors)*100
  ld1_per_cor_clin<-ld1_cor/(ld1_cor+ld1_inc+ld1_nors)*100
  ld3_per_cor_clin<-ld3_cor/(ld3_cor+ld3_inc+ld3_nors)*100



return(data.frame(subjid, per_cor,ld1_per_cor,ld3_per_cor, avg_RT,avg_RT_ld1,avg_RT_ld3, per_cor_clin, ld1_per_cor_clin, ld3_per_cor_clin))
#return(data.frame(subjid,ld1_same_per_cor,ld1_dif_per_cor,ld3_same_per_cor,ld3_dif_per_cor))
}

#takes elements of a list(all the att files) and applies a function to each of them

data_table<-ldply(WMfiles,table_correct)


setwd=("/Volumes/Phillips/P5/group_analyses/WM/behave")


today<-Sys.Date()
todayf<-format(today,format="%Y%m%d")

#20151208-remove individual w/ load 4 (11327_20140911, 11333_20141017), one individual who could not ocmplete tasks, but hs csv (11364_20`150317)
#20151209- remove individuals w/ less than 50% correct on one of the loads
#11430_20151002- 51% load 3, 48% load 1, row 33
#11402_20150728- 47% load 3, 56% load 1, row 28
data_table<-data_table[c(1:2,5:19,21:27,29:32,34:37),]


  
#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks
onesIwant<-match(data_table$subjid,subj$MRID)
#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_table2<-merge(data_table,subj2,by.x="subjid",by.y="MRID")


#ttest to see if patients & controls are sig different on measures
#can change coefficient to 2,3 for t-vlaue, 2,4 for p-value
pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:7)
  
{
  
  model_beh<-glm(data_table[[i]]~as.factor(subj2$Cohort),data=data_table)
  print((summary(model_beh)$coefficients[2,3]))
}

colnames(data_table2)<-c("subjid","Overall % Correct", "Load 1 % Correct","Load 3 % Correct","Overall Avg Reaction Time (s)","Load 1 Reaction Time (s)","Load 3 Reaction Time (s)")
setwd("/Volumes/Phillips/P5/group_analyses/WM/behave")

#this set of graphs focuses on % correct
pdf(paste(todayf,"WM_behave_percor.pdf",sep="_"))

cols<-c(4:6)
for (i in colnames(data_table)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table[,i])))
  
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " "
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25,size=1) +
          coord_cartesian(ylim=c(60,100))+scale_fill_manual(values=c("blue","red")) +
          xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

pdf(paste(todayf,"WM_behave_wlegend.pdf",sep="_"))

cols<-c(6:9)
for (i in colnames(data_table)[cols])
{
  
  
  textSize <- 16
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table[,i])))
  
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " " 
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,alpha=group,fill=group))
  print(p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25) +
          coord_cartesian(ylim=c(.45,.77))+scale_alpha_discrete(range=c(1, 1)) +
          xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none"))
  
}
dev.off()

data_table2<-data_table*1000

pdf(paste(todayf,"WM_behave_RT.pdf",sep="_"))

cols<-c(7:9)
for (i in colnames(data_table2)[cols])
{

  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table2[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table2[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table2[,i])))
  
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " "
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25) +
    coord_cartesian(ylim=c(700,1300))+scale_fill_manual(values=c("blue","red"))+
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

pdf(paste(todayf,"per_cor_cost.pdf",sep="_"))
cols<-c(23)
for (i in colnames(data_table2)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table2[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table2[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table2[,i])))
  
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " "
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25) +
    scale_fill_manual(values=c("blue","red"))+
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

pdf(paste(todayf,"rt_cost.pdf",sep="_"))
cols<-c(24)
for (i in colnames(data_table2)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table2[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table2[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table2[,i])))
  
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " "
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25) +
    scale_fill_manual(values=c("blue","red"))+
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

setwd("/Volumes/Phillips/P5/group_analyses/WM/behave")
write.table(data_table, file=paste(todayf,"WM_behave.txt",sep="_"))


demo<-read.delim("/Users/mariaj/Desktop/20151111_P5_demo_data.txt")

patients<-demo[demo$identity==1,]

controls<-demo[demo$identity==2,]
t.test(patients$agecnsnt,controls$agecnsnt)
range(patients$agecnsnt)
range(controls$agecnsnt)
mean(patients$agecnsnt)
mean(controls$agecnsnt)
sd(patients$agecnsnt)
sd(controls$agecnsnt)
table(patients$SEX)
table(controls$SEX)
chisq.test(demo$SEX,demo$identity)
chisq.test(demo$DEMOGHANDTXT,demo$identity)
chisq.test(demo$RACE,demo$identity)
table(patients$DEMOGHANDTXT)
table(controls$DEMOGHANDTXT)
table(patients$DEMOGHANDTXT)

table(controls$RACE)
table(patients$RACE)

mean(patients$AvgOfIQSCORE,na.rm = TRUE)
sd(patients$AvgOfIQSCORE,na.rm = TRUE)

mean(controls$AvgOfIQSCORE,na.rm = TRUE)
sd(controls$AvgOfIQSCORE,na.rm = TRUE)

t.test(patients$AvgOfIQSCORE,controls$AvgOfIQSCORE)
patients$AvgOfIQSCORE

#getting means & sd for patients for progress report
data_patients<-data_table2[data_table2$Cohort=="Clinical",]
mean(data_patients$per_cor)
sd(data_patients$per_cor)

mean(data_patients$avg_RT)
sd(data_patients$avg_RT)

mean(data_patients$ld1_per_cor)
sd(data_patients$ld1_per_cor)

mean(data_patients$ld3_per_cor)
sd(data_patients$ld3_per_cor)



#getting means & sd for controls for progress report
data_controls<-data_table2[data_table2$Cohort=="Control",]
mean(data_controls$per_cor)
sd(data_controls$per_cor)

mean(data_controls$avg_RT)
sd(data_controls$avg_RT)

mean(data_controls$ld1_per_cor)
sd(data_controls$ld1_per_cor)

mean(data_controls$ld3_per_cor)
sd(data_controls$ld3_per_cor)

#anova for accuracy w/ laod
WM<-data_table2[,c(1,3:4,15)]
WM2 <- melt(WM, id.vars=c("subjid","Cohort"))
test<-aov(value~Cohort+variable+Error(subjid/variable),data=WM2)
test<-glm(value~Cohort*variable,data=WM2)
summary(test)

#anova for rt w/ laod
WM_acc<-data_table2[,c(1,6:7,15)]
WM_acc2 <- melt(WM_acc, id.vars=c("subjid","Cohort"))
test<-aov(value~Cohort*variable+Error(subjid/variable),data=WM_acc2)
test<-glm(value~Cohort*variable,data=WM_acc2)
summary(test)

data_table2$Cohort<-relevel(data_table2$Cohort,"Control")


pdf(paste(todayf,"Att_speed_accuracy_trade_off.pdf",sep="_"))

ggplot(data_table2,aes(x=ld1_per_cor,y=avg_RT_ld1,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))
ggplot(data_table2,aes(x=ld3_per_cor,y=avg_RT_ld3,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))


ggplot(data_table2,aes(x=habitual_correct,y=habitual_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))

ggplot(data_table2,aes(x=flexible_correct,y=flexible_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))
dev.off()
