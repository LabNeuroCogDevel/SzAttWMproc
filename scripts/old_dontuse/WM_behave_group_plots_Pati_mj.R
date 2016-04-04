#this is for Working Memory behave data
library(plyr)
library(ggplot2)
#library(LNCDR)
#load all the WM behav files (they've already been run through matlab)
#copy them over from skynet
#WMfiles <- Sys.glob('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory*')
WMfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/WorkingMemory*')

#for just one individual
#filename = ('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory_11466_20151125_behave.csv')
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
  avg_RT<-mean(a$RT[ is.finite(a$RT) & a$Crt==1])
  avg_RT_ld1<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$Crt==1])  
  avg_RT_ld3<-mean(a$RT[ is.finite(a$RT) & (a$ld==3|a$ld==4) & a$Crt==1])  
  avg_RT_delay1<-mean(a$RT[ is.finite(a$RT) & a$islongdelay==0 & a$Crt==1])  
  avg_RT_delay3<-mean(a$RT[ is.finite(a$RT) & a$islongdelay==1 & a$Crt==1])
  avg_RT_ld1_delay1<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$islongdelay==0 & a$Crt==1])  
  avg_RT_ld1_delay3<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$islongdelay==1 & a$Crt==1])  
  avg_RT_ld3_delay1<-mean(a$RT[ is.finite(a$RT) & a$ld==3|a$ld==4 & a$islongdelay==0 & a$Crt==1])  
  avg_RT_ld3_delay3<-mean(a$RT[ is.finite(a$RT) & a$ld==3|a$ld==4 & a$islongdelay==1 & a$Crt==1])  

  #ld1
  ld1_cor<-sum(a$Crt == 1 & a$ld  == 1, na.rm=TRUE)
  ld1_inc<-sum(a$Crt == 0 & a$ld  == 1, na.rm=TRUE)
  ld1_nors<-sum(a$Crt == -1 & a$ld  == 1, na.rm=TRUE)
  ld1_per_cor<-ld1_cor/(ld1_cor+ld1_inc)*100
  ld1_per_inc<-ld1_inc/(ld1_cor+ld1_inc)*100

  
  #ld3
  ld3_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_per_cor<-ld3_cor/(ld3_cor+ld3_inc)*100
  ld3_per_inc<-ld3_inc/(ld3_cor+ld3_inc)*100
  
  #separate out delay
  #delay1
  delay1_cor<-sum(a$Crt == 1 & a$islongdelay==0, na.rm=TRUE)
  delay1_inc<-sum(a$Crt == 0 & a$islongdelay==0, na.rm=TRUE)
  delay1_nors<-sum(a$Crt == -1 & a$islongdelay==0, na.rm=TRUE)
  delay1_per_cor<-delay1_cor/(delay1_cor+delay1_inc)*100
  delay1_per_inc<-delay1_inc/(delay1_cor+delay1_inc)*100
  
  #delay3
  delay3_cor<-sum(a$Crt == 1 & a$islongdelay==1, na.rm=TRUE)
  delay3_inc<-sum(a$Crt == 0 & a$islongdelay==1, na.rm=TRUE)
  delay3_nors<-sum(a$Crt == -1 & a$islongdelay==1, na.rm=TRUE)
  delay3_per_cor<-delay3_cor/(delay3_cor+delay3_inc)*100
  delay3_per_inc<-delay3_inc/(delay3_cor+delay3_inc)*100
  
  #separate out ld & delay 
  #ld 1, delay1
  ld1_delay1_cor<-sum(a$Crt == 1 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_inc<-sum(a$Crt == 0 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_nors<-sum(a$Crt == -1 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_per_cor<-ld1_delay1_cor/(ld1_delay1_cor+ld1_delay1_inc)*100
  ld1_delay1_per_inc<-ld1_delay1_inc/(ld1_delay1_cor+ld1_delay1_inc)*100

  #ld 1, delay3
  ld1_delay3_cor<-sum(a$Crt == 1 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_inc<-sum(a$Crt == 0 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_nors<-sum(a$Crt == -1 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_per_cor<-ld1_delay3_cor/(ld1_delay3_cor+ld1_delay3_inc)*100
  ld1_delay3_per_inc<-ld1_delay3_inc/(ld1_delay3_cor+ld1_delay3_inc)*100
  
  
  #ld 3, delay1
  ld3_delay1_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_per_cor<-ld3_delay1_cor/(ld3_delay1_cor+ld3_delay1_inc)*100
  ld3_delay1_per_inc<-ld3_delay1_inc/(ld3_delay1_cor+ld3_delay1_inc)*100
  
  #ld 3, delay3
  ld3_delay3_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_per_cor<-ld3_delay3_cor/(ld3_delay3_cor+ld3_delay3_inc)*100
  ld3_delay3_per_inc<-ld3_delay3_inc/(ld3_delay3_cor+ld3_delay3_inc)*100
  
  
  #calcualting % correct based on way that Dean & Brian do it (include no response)
  per_cor_clin<-total_cor/(total_cor+total_inc+total_nors)*100
  ld1_per_cor_clin<-ld1_cor/(ld1_cor+ld1_inc+ld1_nors)*100
  ld3_per_cor_clin<-ld3_cor/(ld3_cor+ld3_inc+ld3_nors)*100
  delay1_per_cor_clin<-delay1_cor/(delay1_cor+delay1_inc+delay1_nors)*100
  delay3_per_cor_clin<-delay3_cor/(delay3_cor+delay3_inc+delay3_nors)*100
  ld1_delay1_per_cor_clin<-ld1_delay1_cor/(ld1_delay1_cor+ld1_delay1_inc+ld1_delay1_nors)*100
  ld1_delay3_per_cor_clin<-ld1_delay3_cor/(ld1_delay3_cor+ld1_delay3_inc+ld1_delay3_nors)*100
  ld3_delay1_per_cor_clin<-ld3_delay1_cor/(ld3_delay1_cor+ld3_delay1_inc+ld3_delay1_nors)*100
  ld3_delay3_per_cor_clin<-ld3_delay3_cor/(ld3_delay3_cor+ld3_delay3_inc+ld3_delay3_nors)*100


return(data.frame(subjid, per_cor,ld1_per_cor,ld3_per_cor,delay1_per_cor,delay3_per_cor,ld1_delay1_per_cor, ld1_delay3_per_cor,ld3_delay1_per_cor, ld3_delay3_per_cor,
                  per_cor_clin,ld1_per_cor_clin,ld3_per_cor_clin,delay1_per_cor_clin,delay3_per_cor_clin,ld1_delay1_per_cor_clin,ld1_delay3_per_cor_clin,ld3_delay1_per_cor_clin,ld3_delay3_per_cor_clin,
                  avg_RT,avg_RT_ld1,avg_RT_ld3,avg_RT_delay1,avg_RT_delay3,avg_RT_ld1_delay1,avg_RT_ld1_delay3,avg_RT_ld3_delay1,avg_RT_ld3_delay3))
#return(data.frame(subjid,ld1_same_per_cor,ld1_dif_per_cor,ld3_same_per_cor,ld3_dif_per_cor))
}

#takes elements of a list(all the att files) and applies a function to each of them

data_table<-ldply(WMfiles,table_correct)


#setwd=("//10.145.64.109/Phillips/P5/group_analyses/WM/behave")
setwd=("/Volumes/Phillips/P5/group_analyses/WM/behave")


today<-Sys.Date()
todayf<-format(today,format="%Y%m%d")

#20151208-remove individual w/ load 4 (11327_20140911, 11333_20141017), one individual who could not ocmplete tasks, but hs csv (11364_20`150317)
#20151209- remove individuals w/ less than 50% correct on one of the loads
#11430_20151002- 51% load 3, 48% load 1, row 33
#11402_20150728- 47% load 3, 56% load 1, row 28
data_table1<-subset(data_table, !(ld1_per_cor<50 | ld3_per_cor <50)) #exclude individuals that have <50% correct on one of the loads
#data_table<-data_table[c(1:2,5:19,21:27,29:32,34:37),]

  
#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks
onesIwant<-match(data_table1$subjid,subj$MRID)
#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_table2<-merge(data_table1,subj2,by.x="subjid",by.y="MRID")

data_table3<-data_table2[,c(1,3:4,21:22,36,38)]
#for 20160226 want to get rid of 11327, 11500, 11505
data_table4<-data_table3[c(1:2,4:42),]

#check to make sure I have 27 patients, 14 controls-20160225
table(data_table4$Cohort)

#check diagnosis
table(data_table4$confirmed_initial_dx1)

#ttest to see if patients & controls are sig different on measures
#can change coefficient to 2,3 for t-vlaue, 2,4 for p-value
pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:5)
  
{
  
  model_beh<-glm(data_table4[[i]]~as.factor(data_table4$Cohort),data=data_table4)
  print((summary(model_beh)$coefficients[2,4]))
}


colnames(data_table4)<-c("subjid","Load 1 % Correct","Load 3 % Correct","Load 1 Reaction Time (s)","Load 3 Reaction Time (s)","Cohort","Dx")


#setwd("//10.145.64.109/Phillips/P5/group_analyses/WM/behave")
setwd("/Volumes/Phillips/P5/group_analyses/WM/behave")


#this set of graphs focuses on % correct
data_table4$avg_RT_ld3<-data_table4$avg_RT_ld3*1000

pdf(paste(todayf,"WM_behave_RT_LD3.pdf",sep="_"))

std <- function(x) sd(x)/sqrt(length(x))
cols<-c(5:5)
for (i in colnames(data_table4)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table4[,i], data_table4$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_table4[data_table4$Cohort=="Clinical",]
  con<-data_table4[data_table4$Cohort=="Control",]
  sem1<-std(pat[,i])
  sem2<-std(con[,i])
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  scz<-data_table4[data_table4$Dx==2,]
  scz<-as.data.frame(scz)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= i
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25,size=1) + 
    coord_cartesian(ylim=c(70,1300))+scale_fill_manual(values=c("light grey","gray34")) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()
geom_point(data=scz,aes(x=group,y=ld1_per_cor,colour="red")) +

#anova for accuracy w/ laod
#20160222-main effect of cohort & load, no interaction
WM<-data_table2[,c(1,3:4,29)]
WM2 <- melt(WM, id.vars=c("subjid","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)

WM_pat<-WM[WM$Cohort=="Clinical",]
t.test(WM_pat$`Load 1 % Correct`,WM_pat$`Load 3 % Correct`,paired=TRUE)

WM_pat<-WM[WM$Cohort=="Control",]
t.test(WM_pat$`Load 1 % Correct`,WM_pat$`Load 3 % Correct`,paired=TRUE)

#what if you include no response in % correct
WM<-data_table2[,c(1,12:13,29)]
WM2 <- melt(WM, id.vars=c("subjid","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)


#anova for rt w/ laod
#20160222-main effect of cohort & load, no interaction
WM_rt<-data_table2[,c(1,21:23,29)]
WM_rt2 <- melt(WM_rt, id.vars=c("subjid","Cohort"))
WM_aov2<-aov(value~Cohort*variable+Error(subjid/variable),data=WM_rt2)
summary(WM_aov2)


WM_rt_pat<-WM_rt[WM_rt$Cohort=="Clinical",]
t.test(WM_rt_pat$`Load 1 Reaction Time (s)`,WM_rt_pat$`Load 3 Reaction Time (s)`,paired=TRUE)

WM_rt_con<-WM_rt[WM_rt$Cohort=="Control",]
t.test(WM_rt_con$`Load 1 Reaction Time (s)`,WM_rt_con$`Load 3 Reaction Time (s)`,paired=TRUE)


#anova for accuracy w/ delay 
#20160222-main effect of cohort & load, no interaction,no main effect of delay
WM_del<-data_table2[,c(1,5:6,29)]
WM2_del <- melt(WM_del, id.vars=c("subjid","Cohort"))
WM_aov3<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2_del)
summary(WM_aov3)


WM_del_pat<-WM_del[WM_del$Cohort=="Clinical",]
t.test(WM_del_pat$`Delay 1 % Correct`,WM_del_pat$`Delay 3 % Correct`,paired=TRUE)

WM_del_con<-WM_del[WM_del$Cohort=="Control",]
t.test(WM_del_con$`Delay 1 % Correct`,WM_del_con$`Delay 3 % Correct`,paired=TRUE)


WM_del<-data_table2[,c(1,5:6,29)]
WM2_del <- melt(WM_del, id.vars=c("subjid","Cohort"))
WM_aov3<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2_del)
summary(WM_aov3)

WM_del<-data_table2[,c(1,14:15,29)]
WM2_del <- melt(WM_del, id.vars=c("subjid","Cohort"))
WM_aov3<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2_del)
summary(WM_aov3)

#anova for accuracy w/ delay rt
#20160222-main effect of cohort, no interaction, no main effect of delay
WM_del_rt<-data_table2[,c(1,23:24,29)]
WM2_del_rt <- melt(WM_del_rt, id.vars=c("subjid","Cohort"))
WM_aov4<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2_del_rt)
summary(WM_aov4)


WM_del_rt_pat<-WM_del_rt[WM_del_rt$Cohort=="Clinical",]
t.test(WM_del_rt_pat$`Delay 1 Reaction Time (s)`,WM_del_rt_pat$`Delay 3 Reaction Time (s)`,paired=TRUE)

WM_del_rt_con<-WM_del_rt[WM_del_rt$Cohort=="Control",]
t.test(WM_del_rt_con$`Delay 1 Reaction Time (s)`,WM_del_rt_con$`Delay 3 Reaction Time (s)`,paired=TRUE)



pdf(paste(todayf,"WM_behave_wlegend.pdf",sep="_"))

cols<-c(6:9)
for (i in colnames(data_table2)[cols])
{
  
  
  textSize <- 16
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table[,i], subj2$Cohort, mean,na.rm=TRUE))
  
  sem<-tapply(data_table2[,i], subj2$Cohort, sd,na.rm=TRUE)/sqrt(sqrt(length(data_table2[,i])))
  
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

setwd("//10.145.64.109/Phillips/P5/group_analyses/WM/behave")
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



data_table2$Cohort<-relevel(data_table2$Cohort,"Control")


pdf(paste(todayf,"Att_speed_accuracy_trade_off.pdf",sep="_"))

ggplot(data_table2,aes(x=ld1_per_cor,y=avg_RT_ld1,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))
ggplot(data_table2,aes(x=ld3_per_cor,y=avg_RT_ld3,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))


ggplot(data_table2,aes(x=habitual_correct,y=habitual_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))

ggplot(data_table2,aes(x=flexible_correct,y=flexible_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))
dev.off()
