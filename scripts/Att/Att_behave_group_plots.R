#this is for attention behave data
library(plyr)
library(ggplot2)
library(LNCDR)
library(reshape)
library(dplyr)
library(tidyr)

today<-Sys.Date()
todayf<-format(today,format="%Y%m%d")
#load all the Attention behav files (they've already been run through matlab)
#copy them over from skynet
Attfiles <- Sys.glob('C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/csv/Attention*')
#Attfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/Attention*')


source("C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/WM/graphing_functions.R")
#source("/Volumes/Phillips/P5/scripts/WM/graphing_functions.R")


#for just one individual
#filename = ('/Volumes/Phillips/P5/scripts/csv/Attention_10843')
prefix= 'C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/csv/Attention_'
#filename = ('//10.145.64.109/Phillips/P5/scripts/csv/Attention_10843')
#prefix= '//10.145.64.109/Phillips/P5/scripts/csv/Attention_'

#I'm making a function that I can then apply on all my files later on
table_correct<-function(filename){
  subjid <- gsub('_behave.csv','',gsub(prefix,'',filename))
  a<-read.table(filename,sep=',',header=T)
  a<-a[!is.nan(a$Crt),]
  
  
  
  total_cor=length(which(a$Crt==1))
  total_inc=length(which(a$Crt==0))
  total_nors=length(which(a$Crt==-1))
  
  
  c=length(which(a$Crt==-1))
  per_cor=total_cor/(total_cor+total_inc)*100
  per_cor_clin=total_cor/(total_cor+total_inc+total_nors)*100
  per_inc=total_inc/(total_cor+total_inc)*100
  per_nors=total_nors/(length(a$Crt))*100
  
  #average RT for correct trial
  avg_RT<-mean(a$RT[ is.finite(a$RT)])
  avg_RT_pop<-mean(a$RT[ is.finite(a$RT) & a$trltp==1])  
  avg_RT_hab<-mean(a$RT[ is.finite(a$RT) & a$trltp==2])  
  avg_RT_flex<-mean(a$RT[ is.finite(a$RT) & a$trltp==3])  
  #pop
  pop_cor<-sum(a$Crt == 1 & a$trltp  == 1, na.rm=TRUE)
  pop_inc<-sum(a$Crt == 0 & a$trltp  == 1, na.rm=TRUE)
  pop_nors<-sum(a$Crt == -1 & a$trltp  == 1, na.rm=TRUE)
  pop_per_cor<-pop_cor/(pop_cor+pop_inc)*100
  pop_per_inc<-pop_inc/(pop_cor+pop_inc)*100
  #pop_per_nors<-pop_nors/(32)*100
  
  #pop
  hab_cor<-sum(a$Crt == 1 & a$trltp  == 2, na.rm=TRUE)
  hab_inc<-sum(a$Crt == 0 & a$trltp  == 2, na.rm=TRUE)
  hab_nors<-sum(a$Crt == -1 & a$trltp  == 2, na.rm=TRUE)
  hab_per_cor<-hab_cor/(hab_cor+hab_inc)*100
  hab_per_inc<-hab_inc/(hab_cor+hab_inc)*100
  #pop_per_nors<-pop_nors/(32)*100
  
  #pop
  flex_cor<-sum(a$Crt == 1 & a$trltp  == 3, na.rm=TRUE)
  flex_inc<-sum(a$Crt == 0 & a$trltp  == 3, na.rm=TRUE)
  flex_nors<-sum(a$Crt == -1 & a$trltp  == 3, na.rm=TRUE)
  flex_per_cor<-flex_cor/(flex_cor+flex_inc)*100
  flex_per_inc<-flex_inc/(flex_cor+flex_inc)*100
  #pop_per_nors<-pop_nors/(32)*100
  
  #calcualting % correct based on way that Dean & Brian do it
  per_cor_clin<-total_cor/(total_cor+total_inc+total_nors)*100
  pop_per_cor_clin<-pop_cor/(pop_cor+pop_inc+pop_nors)*100
  hab_per_cor_clin<-hab_cor/(hab_cor+hab_inc+hab_nors)*100
  flex_per_cor_clin<-flex_cor/(flex_cor+flex_inc+flex_nors)*100
  
  
  #return(data.frame(subjid, per_cor, per_cor_clin, total_nors, pop_per_cor, pop_per_cor_clin, pop_nors, hab_per_cor, hab_per_cor_clin, hab_nors, flex_per_cor, flex_per_cor_clin, flex_nors))
  return(data.frame(subjid, per_cor, pop_per_cor,hab_per_cor, flex_per_cor,avg_RT,avg_RT_pop,avg_RT_hab, avg_RT_flex, per_cor_clin, pop_per_cor_clin, hab_per_cor_clin,flex_per_cor_clin))
  #return(data.frame(subjid,ld1_same_per_cor,ld1_dif_per_cor,ld3_same_per_cor,ld3_dif_per_cor))
}

#takes elements of a list(all the att files) and applies a function to each of them

data_table<-ldply(Attfiles,table_correct)
setwd("//10.145.64.109/Phillips/P5/group_analyses/Att/behave")
#setwd("/Volumes/Phillips/P5/group_analyses/Att/behave")

#data_table<-data_table[c(2:3,5:20,22:27,29:32),]
#20161010-take out subjects that did not complete all of task runs: 11330_20141002, 11364_20150317, 11553_20160620
#201 take out subjects that did not complete task runs and sub that did not respond to a bunch of stim: 11454_20151019 

bad_subj<-match(c("11330_20141002","11364_20150317","11454_20151019","11553_20160620","11583_20161209"),data_table$subjid)


data_table1<-data_table[-bad_subj, ]


#read in google doc
subj<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/SubjInfoGoogleSheet_att_wdx.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks


data_table2<-merge(data_table1,subj,by.x="subjid",by.y="MRID")
table(data_table2$Cohort)
table(data_table2$confirmed_initial_dx1)

#only select the rows I want
#data_table2<-data_table2[,c(1:13,17)]

#ttest to see if patients & controls are sig different on measures
#can change coefficient to 2,3 for t-vlaue, 2,4 for p-value
control <- data_table2[ which(data_table2$Cohort=='Control'),]
clinical <- data_table2[ which(data_table2$Cohort=='Clinical'),]

pval<- matrix(NA,ncol=1,nrow=9)
for (i in 2:9)
  
{
  i=9
  t.test(data_table2[,c(i)]~Cohort,data=data_table2)
  sd<-sd(clinical[,c(i)])
  print(sd)
  sd<-sd(control[,c(i)])
  print(sd)
  #model_beh<-glm(data_table2[[i]]~as.factor(data_table2$Cohort),data=data_table2)
  #print((summary(model_beh)$coefficients[2,4]))
}

#anova for accuracy w/ condition by cohort
#10/09/2016- no main effect of group, no group*condition interaction
#1/13/17: main effect of condition, p=4.13E-5
Att<-data_table2[ ,c(1,3:5,17)]
Att2 <- melt(Att, id.vars=c("subjid","Cohort"))
Att_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=Att2)
summary(Att_aov1)


#10/09/2016- no main effect of group, no group*condition interaction
Att<-data_table2[,c(1,3:5,19)]
Att2 <- melt(Att, id.vars=c("subjid","confirmed_initial_dx1"))
Att_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=Att2)
summary(Att_aov1)


#anova for RTw/ condition by cohort
#1/13/17: no main effects, no interactions
Att<-data_table2[,c(1,7:9,17)]
Att2 <- melt(Att, id.vars=c("subjid","Cohort"))
Att_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=Att2)
summary(Att_aov1)


#anova for RTw/ condition by diagnosis
#20161006-
Att<-data_table2[,c(1,7:9,19)]
Att2 <- melt(Att, id.vars=c("subjid","confirmed_initial_dx1"))
Att_aov1<-aov(value~confirmed_initial_dx1*variable+Error(subjid/variable),data=Att2)
summary(Att_aov1)

#age correlations whole group
for(i in 2:9)
{
  cor <- cor.test(data_table2$age,data_table2[,c(i)])
  print(cor$estimate)
}

#age correlations within clinical
for(i in 2:9)
{
  cor <- cor.test(clinical$age,clinical[,c(i)])
  print(cor$p.value)
}

#age correlations within controls
for(i in 2:9)
{
  cor <- cor.test(control$age,control[,c(i)])
  print(cor$p.value)
}


#keep %corr group
#keep = match(c("subjid","per_cor","Cohort","confirmed_initial_dx1"), colnames(data_table2))
keep = match(c("subjid","per_cor","Cohort"), colnames(data_table2))
percor_plot<-data_table2[,keep]

colnames(percor_plot)[colnames(percor_plot)=="per_cor"]<-"value"

d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 

# plot %corr group data
pdf('/Users/mariaj/Desktop/Per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()

#keep %corr dx
keepdx = match(c("subjid","per_cor","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]

colnames(percor_plot)[colnames(percor_plot)=="per_cor"]<-"value"

d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)

# plot %corr dx data
pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()

#keep RT

#keep = match(c("subjid","avg_RT","Cohort","confirmed_initial_dx1"), colnames(data_table2))
keep = match(c("subjid","avg_RT","Cohort"), colnames(data_table2))
percor_plot<-data_table2[,keep]

colnames(percor_plot)[colnames(percor_plot)=="avg_RT"]<-"value"

d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000

## plot group data
pdf('/Users/mariaj/Desktop/RT.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)

dev.off()

#keep RT_dx
keepdx = match(c("subjid","avg_RT","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]

colnames(percor_plot)[colnames(percor_plot)=="avg_RT"]<-"value"

d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)


## plot RT_dx data
pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)


##Flexible
#%corr Flexible group
keep = match(c("subjid","flex_per_cor","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="flex_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
#pdf('/Users/mariaj/Desktop/Per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#%corr Flexible dx
keepdx = match(c("subjid","flex_per_cor","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="flex_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#RT Flexible group
keep = match(c("subjid","avg_RT_flex","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_flex"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
#pdf('/Users/mariaj/Desktop/RT.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)

dev.off()

#RT Flexible dx
keepdx = match(c("subjid","avg_RT_flex","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_flex"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)


##Habitual
#%corr Habitual group
keep = match(c("subjid","hab_per_cor","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="hab_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
#pdf('/Users/mariaj/Desktop/Per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#%corr Habitual dx
keepdx = match(c("subjid","hab_per_cor","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="hab_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#RT Habitual group
keep = match(c("subjid","avg_RT_hab","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_hab"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
#pdf('/Users/mariaj/Desktop/RT.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)

dev.off()

#RT Habitual dx
keepdx = match(c("subjid","avg_RT_hab","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_hab"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)


##Popout
#%corr Popout group
keep = match(c("subjid","pop_per_cor","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="pop_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
#pdf('/Users/mariaj/Desktop/Per_cor_group.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#%corr Popout dx
keepdx = match(c("subjid","pop_per_cor","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="pop_per_cor"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"% Correct"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  # change the legend
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(80,100))
print(p.grp)

dev.off()


#RT Popout group
keep = match(c("subjid","avg_RT_pop","Cohort","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keep]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_pop"]<-"value"
d.grp <- percor_plot %>% 
  group_by(Cohort) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
#pdf('/Users/mariaj/Desktop/RT.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=Cohort,y=avg,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey36','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=Cohort) + scale_color_manual(values=c('black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)

dev.off()

#RT Popout dx
keepdx = match(c("subjid","avg_RT_pop","confirmed_initial_dx1"), colnames(data_table2))
percor_plot<-data_table2[,keepdx]
colnames(percor_plot)[colnames(percor_plot)=="avg_RT_pop"]<-"value"
d.grp <- percor_plot %>% 
  group_by(confirmed_initial_dx1) %>%  
  meanse 
d.grp$avg<-d.grp$avg*1000
d.grp$se<-d.grp$se*1000
d.grp$confirmed_initial_dx1<-as.factor(d.grp$confirmed_initial_dx1)
#pdf('/Users/mariaj/Desktop/Per_cor_dx.pdf')
xlab<-" "
ylab<-"Reaction Time (ms)"
textSize=26
p.grp <- 
  ggplot(d.grp) + aes(x=confirmed_initial_dx1,y=avg,fill=confirmed_initial_dx1) +
  geom_bar(stat='identity',position='dodge') +
  geom_errorbar(
    aes(ymin=d.grp$avg-d.grp$se,ymax=d.grp$avg+d.grp$se),
    position=position_dodge(0.9),
    width=.25) +
  theme_bw() + 
  theme(legend.position="top")+theme_bw(base_size=textSize)+theme(panel.border = element_rect(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+scale_fill_manual(values=c('grey13','grey72','white'))+labs(x=(xlab), y=(ylab))+
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c('black','black','black'))+
  coord_cartesian(ylim=c(400,700))
print(p.grp)





std <- function(x) sd(x)/sqrt(length(x))



#this set of graphs focuses on % correct
pdf(paste(todayf,"Att_behave_percor_noresp.pdf",sep="_"))

cols<-c(3:5)
for (i in colnames(data_table2)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table2[,i], data_table2$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_table2[data_table2$Cohort=="Clinical",]
  con<-data_table2[data_table2$Cohort=="Control",]
  sem1<-std(pat[,i])
  sem2<-std(con[,i])
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Patient","Control")), mean=c(means))
  xlab <- "Group"
  ylab= i
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,alpha=group,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25) +
          coord_cartesian(ylim=c(92,100.5))+scale_alpha_discrete(range=c(1, 1)) +scale_fill_manual(values=c("grey36","white"))+
          xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

pdf(paste(todayf,"Att_behave_wlegne.pdf",sep="_"))

cols<-c(6:9)
for (i in colnames(data_table)[cols])
{
  
  
  textSize <- 16
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table[,i], subj2$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_table2[data_table2$Cohort=="Clinical",]
  con<-data_table2[data_table2$Cohort=="Control",]
  sem1<-std(pat[,i])
  sem2<-std(con[,i])
  sem<-cbind(sem1,sem2)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= " " 
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,alpha=group,fill=group))
  print(p+geom_bar(stat="identity",position=dodge)+
          geom_errorbar(limits, position=dodge, width=0.25) +
          coord_cartesian(ylim=c(.45,.77))+scale_alpha_discrete(range=c(1, 1)) +scale_fill_manual(values=c("light grey","gray34"))+
          xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none"))
  
}
dev.off()

data_table3<-data_table2[,c(6:9)]
data_table4<-data_table3*1000
subjid<-data_table2$subjid
Cohort<-data_table2$Cohort
data_table5<-cbind(subjid,data_table4,Cohort)
colnames(data_table5)<-c("subjid","Overall Average RT (ms)", "Popout Average RT (ms)", "Habitual Average RT (ms)", "Flexible Average RT (ms)","Cohort")

pdf(paste(todayf,"Att_behave_RT.pdf",sep="_"))

cols<-c(2:5)
for (i in colnames(data_table5)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_table5[,i], data_table5$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_table5[data_table5$Cohort=="Clinical",]
  con<-data_table5[data_table5$Cohort=="Control",]
  sem1<-std(pat[,i])
  sem2<-std(con[,i])
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= i
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,alpha=group,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25) +
    coord_cartesian(ylim=c(400,757))+scale_alpha_discrete(range=c(1, 1)) +scale_fill_manual(values=c("light grey","gray34"))+
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()

#getting means & sd for patients for progress report
data_patients<-data_table2[data_table2$Cohort=="Clinical",]
mean(data_patients$per_cor)
sd(data_patients$per_cor)

mean(data_patients$avg_RT)
sd(data_patients$avg_RT)

#getting means & sd for controls for progress report
data_controls<-data_table2[data_table2$Cohort=="Control",]
mean(data_controls$per_cor)
sd(data_controls$per_cor)

mean(data_controls$avg_RT)
sd(data_controls$avg_RT)

#getting overall means
mean(data_table2$pop_per_cor)
sd(data_table2$pop_per_cor)

mean(data_table2$hab_per_cor)
sd(data_table2$hab_per_cor)

mean(data_table2$flex_per_cor)
sd(data_table2$flex_per_cor)

# ANOVA for % correct, not including no resp
attn_percor<-data_table2[,c(1,3:5,14)]
attn_percor2 <- melt(attn_percor, id.vars=c("subjid","Cohort"))
attn_aov1<-aov(value~Cohort*variable+Error(subjid/variable),data=attn_percor2)
summary(attn_aov1)

# ANOVA for % correct, including no resp
attn_percor_nr<-data_table2[,c(1,11:13,14)]
attn_percor_nr2 <- melt(attn_percor_nr, id.vars=c("subjid","Cohort"))
attn_aov2<-aov(value~Cohort*variable+Error(subjid/variable),data=attn_percor_nr2)
summary(attn_aov2)

# ANOVA for RT, including no resp
attn_rt<-data_table2[,c(1,6:9,14)]
attn_rt2 <- melt(attn_rt, id.vars=c("subjid","Cohort"))
attn_aov3<-aov(value~Cohort*variable+Error(subjid/variable),data=attn_rt2)
summary(attn_aov3)

attn2$variable<-relevel(attn2$variable,ref="hab_per_cor")
test<-glm(value~Cohort*variable,data=attn2)
summary(test)
setwd("/Volumes/Phillips/P5/group_analyses/Att/behave")
write.table(data_table2, file=paste(todayf,"Att_behave.txt",sep="_"))
write.table(data_table3, file=paste(todayf,"Att_behave.txt",sep="_"))

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

#make accruacy RT trade off plots
Cohort<-subj2$Cohort
data_table3<-cbind(Cohort,data_table)
colnames(data_table3)<-c("Cohort","subjid", "overall_correct","popout_correct","habitual_correct","flexible_correct","overall_rt","popout_rt", "habitual_rt","flexible_rt")

#change order of factors
data_table3$Cohort<-relevel(data_table3$Cohort,"Control")

pdf(paste(todayf,"Att_speed_accuracy_trade_off.pdf",sep="_"))

ggplot(data_table3,aes(x=popout_correct,y=popout_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))

ggplot(data_table3,aes(x=habitual_correct,y=habitual_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))

ggplot(data_table3,aes(x=flexible_correct,y=flexible_rt,color=factor(Cohort)))+geom_point(size=8)+stat_smooth(method="lm",formula=y~x, se=FALSE,size=2)+ylab(" ")+xlab(" ")+theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + theme(legend.title=element_blank())+theme_bw(base_size=textSize)+theme(legend.position="none")+scale_y_continuous(limits=c(.40,1.25))+coord_cartesian(xlim=c(88,101))
dev.off()


write.table(data_table3, file=paste(todayf,"Att_behave.txt",sep="_"))



