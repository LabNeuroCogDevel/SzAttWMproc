#this is for Working Memory behave data

library(tidyr)
library(plyr)
library(dplyr)
library(ggplot2)
library(reshape)

#library(LNCDR)
#load all the WM behav files (they've already been run through matlab)
#copy them over from skynet
#WMfiles <- Sys.glob('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory*')
WMfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/WorkingMemory*')

#for just one individual
#filename = ('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory_11466_20151125_behave.csv')
prefix= '/Volumes/Phillips/P5/scripts/csv/WorkingMemory_'
#prefix= '//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory_'

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
  ld1_avg_RT<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$Crt==1])  
  ld3_avg_RT<-mean(a$RT[ is.finite(a$RT) & (a$ld==3|a$ld==4) & a$Crt==1])  
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
                  avg_RT,ld1_avg_RT,ld3_avg_RT,avg_RT_delay1,avg_RT_delay3,avg_RT_ld1_delay1,avg_RT_ld1_delay3,avg_RT_ld3_delay1,avg_RT_ld3_delay3))
#return(data.frame(subjid,ld1_same_per_cor,ld1_dif_per_cor,ld3_same_per_cor,ld3_dif_per_cor))
}

#takes elements of a list(all the att files) and applies a function to each of them

data_table<-ldply(WMfiles,table_correct)



setwd("/Volumes/Phillips/P5/group_analyses/WM/behave")


today<-Sys.Date()
todayf<-format(today,format="%Y%m%d")

#20151208-remove individual w/ load 4 (11327_20140911), one individual who could not ocmplete tasks, but hs csv (11364_20`150317)
#20151209- remove individuals w/ less than 50% correct on one of the loads
#11430_20151002- 51% load 3, 48% load 1, row 33
#11402_20150728- 47% load 3, 56% load 1, row 28
data_table1<-subset(data_table, !(ld1_per_cor<50 | ld3_per_cor <50)) #exclude individuals that have <50% correct on one of the loads
#check to make sure who it removed
setdiff(data_table$subjid,data_table1$subjid)
bad_subs<-match(c("11327_20140911","11333_20141017","11369_20150519","11553_20160620"),data_table1$subjid)
data_table1b<-data_table1[-bad_subs,]
#check to make sure who it removed
setdiff(data_table1$subjid,data_table1b$subjid)

#20160823-some subjs not preprocessed yet (no MB scan)
not_preproc<-match(c("11569_20160812"),data_table1b$subjid)
data_table1c<-data_table1b[-not_preproc,]

#check to make sure who it removed
setdiff(data_table1b$subjid,data_table1c$subjid)
  
#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt",header=T)



data_table2<-merge(data_table1c,subj,by.x="subjid",by.y="MRID")
#check to make sure it got rid of bad peeps and not processed peoples
setdiff(data_table$subjid,data_table2$subjid)

write.table(data_table2,file="/Users/mariaj/Dropbox/P5_WM_behave_data.txt")
#column 30 contains RECID
#column 36 and 37 contain age and sex
data_table3<-data_table2[,c(1,3:4,21:22,32:37)]
#column 36 and 37 contain age and sex
data_table3b<-data_table2[,c(1,3:4,20:22,32:37)]

#check to make sure I have 34 patients, 24 controls-20160823
table(data_table3$Cohort)
#chi-square to make sure there are no differences in sex
chisq.test(data_table3$Cohort,data_table3$sex)
#get gender distribution
table(data_table3$Cohort,data_table3$sex)
#ttest to make sure there are no differences in age
t.test(age~Cohort,data_table3)

#look at age range
tapply(data_table3$age,data_table3$Cohort,range)

#look at mean age
tapply(data_table3$age,data_table3$Cohort,mean)

#look at mean sd of age
tapply(data_table3$age,data_table3$Cohort,sd)





data_table4<-data_table3
write.table(data_table2b,file="/Users/mariaj/Dropbox/P5_behave_data.txt")
#ttest to see if patients & controls are sig different on measures
#can change coefficient to 2,3 for t-vlaue, 2,4 for p-value

#are there significant differences between patients & controls?
#20160719-
pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:5)
  
{
  
  model_beh<-glm(data_table4[[i]]~as.factor(data_table4$Cohort),data=data_table4)
  print((summary(model_beh)$coefficients[2,4]))
}

#201607
#are the differences still significant when we covary for age & gender?
#main effect of age for % correct for Load 1, slightly significant for Load 3 [3,4]
#no main effects of gender [4,4]
pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:5)
  
{
  
  model_beh<-glm(data_table4[[i]]~as.factor(data_table4$Cohort)+data_table4$age+data_table4$sex,data=data_table4)
  print((summary(model_beh)$coefficients[2,4]))
}

controls<-data_table4[data_table4$Cohort=="Control",]

#are there any age*group interactions
#no age*group interactions in the behavior
pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:5)
  
{
  
  model_beh<-glm(data_table4[[i]]~as.factor(data_table4$Cohort)*data_table4$age+data_table4$sex,data=data_table4)
  print((summary(model_beh)$coefficients[4,4]))
}


# theme(legend.position = "none"): add theme to delete legend 
ggplot(data_table4,aes(x=age,y=ld3_per_cor,color=Cohort))+geom_point(aes(group=Cohort),shape=21)+stat_smooth(method="loess",span=5)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(text=element_text(size=20,color='black'),panel.background = element_blank())+theme(legend.position = "none")


ggplot(data_table4,aes(x=age,y=ld1_per_cor,color=Cohort))+geom_point(aes(group=Cohort),shape=21)+stat_smooth(method="loess",span=5)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(text=element_text(size=20,color='black'),panel.background = element_blank())+theme(legend.position = "none")


#compare only scz to controls
data_table_dx<-data_table4[data_table4$confirmed_initial_dx1=="1" | data_table4$confirmed_initial_dx1=="2", ]

data_table_dx3b<-data_table3b[data_table3b$confirmed_initial_dx1=="2" | data_table3b$confirmed_initial_dx1=="3", ]

for (i in 4:4)
  
{
  
  model_beh<-glm(data_table_dx3b[[i]]~as.factor(data_table_dx3b$confirmed_initial_dx1),data=data_table_dx3b)
  print((summary(model_beh)$coefficients[2,4]))
}


#compare other psychotic dx to controls
data_table_dx<-data_table4[data_table4$confirmed_initial_dx1=="1" | data_table4$confirmed_initial_dx1=="3", ]

for (i in 4:5)
  
{
  
  model_beh<-glm(data_table_dx[[i]]~as.factor(data_table_dx$confirmed_initial_dx1),data=data_table_dx)
  print((summary(model_beh)$coefficients[2,4]))
}

#compare other scz to other psychotic dx
data_table_dx<-data_table4[data_table4$confirmed_initial_dx1=="1" | data_table4$confirmed_initial_dx1=="2", ]

for (i in 2:5)
  
{
  
  model_beh<-glm(data_table_dx[[i]]~as.factor(data_table_dx$confirmed_initial_dx1),data=data_table_dx)
  print((summary(model_beh)$coefficients[2,4]))
}






#anova for accuracy w/ laod by cohort
#20160823-main effect of cohort & load, no interaction
WM<-data_table4[,c(1,2:3,6)]
WM2 <- melt(WM, id.vars=c("subjid","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)


#anova for accuracy w/ load by dx
WM<-data_table4[,c(1,2:3,8)]
WM2 <- melt(WM, id.vars=c("subjid","confirmed_initial_dx1"))
WM_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)

#anova for accuracy w/ load by dx w/in patients only 
data_table5<-data_table4[data_table4$Cohort=="Clinical",]
WM<-data_table5[,c(1,2:3,8)]
WM2 <- melt(WM,id.vars=c("subjid","confirmed_initial_dx1"))
WM_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)




#anova for rt w/ laod
#20160408-main effect of cohort & load, 
WM_rt<-data_table4[,c(1,4:5,6)]
WM_rt2 <- melt(WM_rt, id.vars=c("subjid","Cohort"))
WM_aov2<-aov(value~Cohort*variable+Error(subjid/variable),data=WM_rt2)
summary(WM_aov2)

#anova for accuracy w/ laod by dx
#20160408-main effect of dx & load, no interaction
WM<-data_table4[,c(1,4:5,8)]
WM2 <- melt(WM, id.vars=c("subjid","confirmed_initial_dx1"))
WM_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)


#anova for accuracy w/ load by dx w/in patients only 
data_table5<-data_table4[data_table4$Cohort=="Clinical",]
WM<-data_table5[,c(1,4:5,8)]
WM2 <- melt(WM,id.vars=c("subjid","confirmed_initial_dx1"))
WM_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)


#anova for rt w/ laod
#20160408-main effect of dx & load, no significant interaction
WM_rt_dx<-data_table4[,c(1,4:5,8)]
WM_rt_dx2 <- melt(WM_rt_dx, id.vars=c("subjid","confirmed_initial_dx1"))
WM_rt_dx_aov2<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=WM_rt_dx2)
summary(WM_rt_dx_aov2)







WM_pat<-WM[WM$Cohort=="Clinical",]
t.test(WM_pat$`Load 1 % Correct`,WM_pat$`Load 3 % Correct`,paired=TRUE)

WM_pat<-WM[WM$Cohort=="Control",]
t.test(WM_pat$`Load 1 % Correct`,WM_pat$`Load 3 % Correct`,paired=TRUE)

#what if you include no response in % correct
WM<-data_table2[,c(1,12:13,29)]
WM2 <- melt(WM, id.vars=c("subjid","Cohort"))
WM_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=WM2)
summary(WM_aov1)





WM_rt_pat<-WM_rt[WM_rt$Cohort=="Clinical",]
t.test(WM_rt_pat$`Load 1 Reaction Time (s)`,WM_rt_pat$`Load 3 Reaction Time (s)`,paired=TRUE)

WM_rt_con<-WM_rt[WM_rt$Cohort=="Control",]
t.test(WM_rt_con$`Load 1 Reaction Time (s)`,WM_rt_con$`Load 3 Reaction Time (s)`,paired=TRUE)









# assumes variable to mean and get se is 'val'
meanse <- function(d) {
  summarize(d, 
            avg=mean(val),
            se=sd(val)/sqrt(n()))
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


plot_bar_and_error_no_load <- function(d,fill="dx",levelname="lvl") {
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
data
d.per_cor<-data_table4 %>% 
  select(-ld1_avg_RT,-ld3_avg_RT,-RECID.1,-meds)%>%
  gather(Load,val,-subjid,-Cohort,-confirmed_initial_dx1)

names(d.per_cor)[4:5]<-c("Load","val")

d.per_cor$Load<-gsub("ld1_per_cor","Low",d.per_cor$Load)
d.per_cor$Load<-gsub("ld3_per_cor","High",d.per_cor$Load)

d.per_cor$Load<-factor(d.per_cor$Load,levels=list('Low','High'),labels=list('Low','High'))



d.grp <- d.per_cor %>% 
  group_by(Cohort,Load) %>%  
  meanse %>%
  addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')

#d.grp$Load<-gsub("ld","", d.grp$Load)
#d.grp$Load<-gsub("_per_cor","", d.grp$Load)



## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
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
      coord_cartesian(ylim=c(60,100))
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
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
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
  coord_cartesian(ylim=c(60,100))
print(p.grp)

dev.off()

#general overall impairment
keep_overall<-match(c("subjid","per_cor","Cohort","confirmed_initial_dx1"), colnames(data_table2))


data_table2b<-data_table2[,keep_overall]
names(data_table2b)[2]<-c("val")  


d.grp <- data_table2b %>% 
  group_by(Cohort) %>%  
  meanse %>%addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')


pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Overall_per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
    ggplot(d.grp) +aes_string(x="Cohort",y="avg",fill="Cohort") +
      
      geom_bar(stat='identity',position='dodge') +
      geom_errorbar(
        aes(ymin=avg-se,ymax=avg+se),
        position=position_dodge(0.9),
        width=.25) +
      theme_bw() + 
      # change the legend
  scale_fill_manual(values=c(NA,NA,'black','white'))+
      theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+
  # color of the bar plots 
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c(NA,NA,'black','black')) +
  coord_cartesian(ylim=c(60,100))
print(p.grp)

dev.off()  


d.dx <- data_table2b %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.dx.1<-rbind(d.clinical.1,d.dx)


d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))



pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Overall_per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.dx.1) +aes_string(x="confirmed_initial_dx1",y="avg",fill="confirmed_initial_dx1") +
  
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=avg-se,ymax=avg+se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+
  scale_fill_manual(values=c('grey45','light grey','black','white'))   +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black','black')) +
  coord_cartesian(ylim=c(60,100))
print(p.grp)

dev.off()  









  

#now graphing RT
data_table4$ld1_avg_RT<-data_table4$ld1_avg_RT*1000
data_table4$ld3_avg_RT<-data_table4$ld3_avg_RT*1000

d.RT<-data_table4 %>% 
  select(-ld1_per_cor,-ld3_per_cor,-RECID.1,-meds)%>%
  gather(Load,val,-subjid,-Cohort, -confirmed_initial_dx1)

d.RT$Load<-gsub("ld1_avg_RT","Low",d.RT$Load)
d.RT$Load<-gsub("ld3_avg_RT","High",d.RT$Load)

d.RT$Load<-factor(d.RT$Load,levels=list('Low','High'),labels=list('Low','High'))

d.grp <- d.RT %>% 
  group_by(Cohort,Load) %>%  
  meanse %>%
  addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')

#d.grp$Load<-gsub("ld","", d.grp$Load)
#d.grp$Load<-gsub("_avg_RT","", d.grp$Load)



## plot RT group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/RT_group.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
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
  coord_cartesian(ylim=c(700,1250))
print(p.grp)

dev.off()

d.dx <- d.RT%>% 
  group_by(confirmed_initial_dx1,Load) %>%  
  meanse


#use clinical info for dx plot
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.dx.1<-rbind(d.clinical.1,d.dx)
d.dx.1$Load<-gsub("ld","", d.dx.1$Load)
d.dx.1$Load<-gsub("_avg_RT","", d.dx.1$Load)

d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))
d.dx.1$Load<-factor(d.dx.1$Load,levels=list('Low','High'),labels=list('Low','High'))


## plot RT dx data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/RT_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
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
  coord_cartesian(ylim=c(700,1250))
print(p.grp)

dev.off()



data_table2$avg_RT<-data_table2$avg_RT*1000
#general overall impairment
keep_overall<-match(c("subjid","avg_RT","Cohort","confirmed_initial_dx1"), colnames(data_table2))


data_table2b<-data_table2[,keep_overall]
names(data_table2b)[2]<-c("val")  


d.grp <- data_table2b %>% 
  group_by(Cohort) %>%  
  meanse %>%addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')

pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Overall_RT_group.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) +aes_string(x="Cohort",y="avg",fill="Cohort") +
  
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=avg-se,ymax=avg+se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  scale_fill_manual(values=c(NA,NA,'black','white'))+
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+
  # color of the bar plots 
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c(NA,NA,'black','black')) +
  coord_cartesian(ylim=c(700,1250))
print(p.grp)

dev.off()  


d.dx <- data_table2b %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]
d.dx$confirmed_initial_dx1<-as.factor(d.dx$confirmed_initial_dx1)
d.dx.1<-rbind(d.clinical.1,d.dx)


d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))



pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Overall_RT_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.dx.1) +aes_string(x="confirmed_initial_dx1",y="avg",fill="confirmed_initial_dx1") +
  
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=avg-se,ymax=avg+se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+
  scale_fill_manual(values=c('grey45','light grey','black','white'))   +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black','black')) +
  coord_cartesian(ylim=c(700,1250))
print(p.grp)

dev.off()  













demos<-read.delim(file="/Users/mariaj/Dropbox/20160407_behavior_data_demos.txt")







#separate patients & controls
pat_demo<-demos[demos$Cohort=="Clinical",]
cont_demo<-demos[demos$Cohort=="Control",]

t.test(pat_demo$age,cont_demo$age)
range(pat_demo$age)
range(cont_demo$age)
mean(pat_demo$age)
sd(pat_demo$age)

mean(cont_demo$age)
sd(cont_demo$age)



table(demos$hand,demos$Cohort)
table(demos$sex,demos$Cohort)
table(demos$race,demos$Cohort)

table(pat_demo$meds)
table(pat_demo$confirmed_initial_dx)


t.test(pat_demo$IQ,cont_demo$IQ,na.rm=TRUE)
mean(pat_demo$IQ,na.rm=TRUE)
sd(pat_demo$IQ,na.rm=TRUE)

mean(cont_demo$IQ)
sd(cont_demo$IQ)

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
data_patients<-data_table4[data_table4$Cohort=="Clinical",]
mean(data_patients$per_cor)
sd(data_patients$per_cor)

mean(data_patients$avg_RT)
sd(data_patients$avg_RT)

mean(data_patients$ld1_per_cor)
sd(data_patients$ld1_per_cor)

mean(data_patients$ld3_per_cor)
sd(data_patients$ld3_per_cor)
mean(data_patients$avg_RT_ld1)
sd(data_patients$avg_RT_ld1)

mean(data_patients$avg_RT_ld3)
sd(data_patients$avg_RT_ld3)



#getting means & sd for controls for progress report
data_controls<-data_table4[data_table4$Cohort=="Control",]
mean(data_controls$per_cor)
sd(data_controls$per_cor)

mean(data_controls$avg_RT)
sd(data_controls$avg_RT)

mean(data_controls$ld1_per_cor)
sd(data_controls$ld1_per_cor)

mean(data_controls$ld3_per_cor)
sd(data_controls$ld3_per_cor)

mean(data_controls$avg_RT_ld1)
sd(data_controls$avg_RT_ld1)

mean(data_controls$avg_RT_ld3)
sd(data_controls$avg_RT_ld3)

data_table2$Cohort<-relevel(data_table2$Cohort,"Control")






%>% select(subjid,IQ)

data_IQ<-merge(data_table4,IQ,by.x="subjid",by.y="subjid")

cor.test(data_IQ$ld1_per_cor,data_IQ$IQ)
cor.test(data_IQ$ld3_per_cor,data_IQ$IQ)

cor.test(data_IQ$avg_RT_ld1,data_IQ$IQ)
cor.test(data_IQ$avg_RT_ld3,data_IQ$IQ)

symp<-read.delim(file="/Users/mariaj/Dropbox/20160310_symptom_measures.txt")

data_symp<-merge(data_table4,symp,by.x="subjid",by.y="ID")

mean(data_symp$BPRSNGS)
sd(data_symp$BPRSNGS)
mean(data_symp$BPRSPOS)
sd(data_symp$BPRSPOS)


cor.test(data_symp$ld1_per_cor,data_symp$BPRSNGS)
cor.test(data_symp$ld3_per_cor,data_symp$BPRSNGS)

cor.test(data_symp$avg_RT_ld1,data_symp$BPRSNGS)
cor.test(data_symp$avg_RT_ld3,data_symp$BPRSNGS)


cor.test(data_symp$ld1_per_cor,data_symp$SANITM)
cor.test(data_symp$ld3_per_cor,data_symp$SANITM)

cor.test(data_symp$avg_RT_ld1,data_symp$SANITM)
cor.test(data_symp$avg_RT_ld3,data_symp$SANITM)

cor.test(data_symp$avg_RT_ld1,data_symp$)
cor.test(data_symp$avg_RT_ld3,data_symp$SANITM)


cor.test(data_symp$ld1_per_cor,data_symp$BPRSPOS)
cor.test(data_symp$ld3_per_cor,data_symp$BPRSPOS)

cor.test(data_symp$avg_RT_ld1,data_symp$BPRSPOS)
cor.test(data_symp$avg_RT_ld3,data_symp$BPRSPOS)


cor.test(data_symp$ld1_per_cor,data_symp$SAPITM)
cor.test(data_symp$ld3_per_cor,data_symp$SAPITM)

cor.test(data_symp$avg_RT_ld1,data_symp$SAPITM)
cor.test(data_symp$avg_RT_ld3,data_symp$SAPITM)


colnames(data_table4)<-c("subjid","Load 1 % Correct","Load 3 % Correct","Load 1 Reaction Time (s)","Load 3 Reaction Time (s)","Cohort","Dx")


#setwd("//10.145.64.109/Phillips/P5/group_analyses/WM/behave")
setwd("/Volumes/Phillips/P5/group_analyses/WM/behave")

#this set of graphs focuses on % correct
pdf(paste(todayf,"WM_behave_percor.pdf",sep="_"))

std <- function(x) sd(x)/sqrt(length(x))
cols<-c(2:2)
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
  scz$Dx<-gsub("2","First Episode",scz$Dx)
  group<-"First Episode, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= i
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25,size=1) + 
    coord_cartesian(ylim=c(60,100))+scale_fill_manual(values=c("light grey","gray34","red")) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
  p3<-p2+geom_point(data=scz,aes(x=Dx,y=ld1_per_cor))
  print(p3)
}
dev.off()

  p3<-p2+geom_point(data=scz, aes(x=Dx,y=ld1_per_cor,color="red"))

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



patients<-data_table4[data_table4$Cohort=="Clinical",]
controls<-data_table4[data_table4$Cohort=="Control",]


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
data_patients<-data_table4[data_table4$Cohort=="Clinical",]
mean(data_patients$per_cor)
sd(data_patients$per_cor)

mean(data_patients$avg_RT)
sd(data_patients$avg_RT)

mean(data_patients$ld1_per_cor)
sd(data_patients$ld1_per_cor)

mean(data_patients$ld3_per_cor)
sd(data_patients$ld3_per_cor)
mean(data_patients$avg_RT_ld1)
sd(data_patients$avg_RT_ld1)

mean(data_patients$avg_RT_ld3)
sd(data_patients$avg_RT_ld3)



#getting means & sd for controls for progress report
data_controls<-data_table4[data_table4$Cohort=="Control",]
mean(data_controls$per_cor)
sd(data_controls$per_cor)

mean(data_controls$avg_RT)
sd(data_controls$avg_RT)

mean(data_controls$ld1_per_cor)
sd(data_controls$ld1_per_cor)

mean(data_controls$ld3_per_cor)
sd(data_controls$ld3_per_cor)

mean(data_controls$avg_RT_ld1)
sd(data_controls$avg_RT_ld1)

mean(data_controls$avg_RT_ld3)
sd(data_controls$avg_RT_ld3)

data_table2$Cohort<-relevel(data_table2$Cohort,"Control")


pdf(paste(todayf,"Att_speed_accuracy_trade_off.pdf",sep="_"))

ggplot(data_table2,aes(x=ld1_per_cor,y=avg_RT_ld1,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))
ggplot(data_table2,aes(x=ld3_per_cor,y=avg_RT_ld3,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.6,1.5))+coord_cartesian(xlim=c(55,105))+scale_colour_manual(values=c("blue","red"))


ggplot(data_table2,aes(x=habitual_correct,y=habitual_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))

ggplot(data_table2,aes(x=flexible_correct,y=flexible_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))
dev.off()
