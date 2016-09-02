#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)
library(tidyr)




ste <- function(x) sd(x)/sqrt(length(x))

# BA to name
renameROI <- function(roi) {
   ifelse(roi=='BA17', 'V1',
    ifelse(roi=='BA40','PPC',
    ifelse(roi=='BA9','DLPFC',
    roi)))
}


#  how to read in a load file
#  - define row names (ROIs)
#  - get column names (subj IDs)
#  - make %, set load and ID, set row names
ROIs <- c("LBA17","LBA40","LBA9","LBA46","RBA17","RBA40","RBA46","RBA9")
IDs <-read.delim(file="/Volumes/Phillips/P5/scripts/txt/subj_list_site_final.txt",header=F)
readLoadFile <- function(ld) {
      setNames(cbind(IDs,ld,read.delim(file=sprintf("/Users/mariaj/Dropbox/delay_ld%d_BA_spheres_t25.txt",ld),header=F)), c('ID','Load',ROIs))
}

#######


# read in both loads, sep. side from ROI name
d <- rbind(readLoadFile(1), readLoadFile(3)) %>% 
 gather(ROI,val,-Load,-ID) %>%
 separate(ROI,c('Side','ROI'),1) 

# name and subset some of the ROIs
d.renamed <- d %>%
 mutate(ROI=renameROI(ROI)) %>% 
 filter(ROI %in% c('V1','PPC','DLPFC')) 
d.renamed$ROI=factor(d.renamed$ROI,levels=list('V1', 'PPC','DLPFC'),labels=list('V1', 'PPC','DLPFC'))
      

# get cohort info into ROIs
cohortinfo <- read.table('/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt',sep="\t",header=T) %>% select(MRID,Cohort,confirmed_initial_dx1)
d.cohort <- merge(d.renamed,cohortinfo,by.x='ID',by.y='MRID')
d.cohort$Load<-as.factor(d.cohort$Load)
d.cohort$confirmed_initial_dx1<-as.factor(d.cohort$confirmed_initial_dx1)
# get mean and std error
d.sum <- d.cohort %>% 
  group_by(ROI,Load,Side,Cohort) %>% 
  summarize_each(funs(mean,ste),val)


# TODO:
#   change lvl to load
#          grp to whatever group should be
#   careful to quote when giving to our local functions
#      



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
textSize=26
plot_bar_and_error <- function(d,fill="dx",levelname='lvl') {
  ggplot(d) +
    aes_string(x=levelname,fill=fill,y="avg") +
    geom_bar(stat='identity',position='dodge') +

    ## draw symetric error bars by drawing the upper and lower sep.
    ## so when errorbar goes below end of graph, both aren't removed
    # top
    geom_errorbar(
      aes(ymin=avg,ymax=avg+se),
      position=position_dodge(0.9),
      width=.25) +
    # bottom
    geom_errorbar(
      aes(ymin=avg-se,ymax=avg),
      position=position_dodge(0.9),
      width=.25) +

    ## THEMEING
    theme_bw(base_size=textSize)+
    theme(
          # change the legend
          #legend.position="top",
          legend.position="none",
          # remove legend
          panel.border = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.line = element_line(colour = "black")
         )
}
##########################################



##########################################
########## plotting    ###################
##########################################

#####  summarise group data
# N.B. for every additional bar in the dx plot that
#      we want to offset in the group plot
#      we add an "empty" group with 'addemptygrp'
#      -- we need leading NA's in scale_'s for each empty group
d.grp <- d.cohort %>% 
  group_by(Cohort,Load,Side,ROI) %>%  
  meanse %>%
  addemptygrp(grpname='Cohort',emptyname='empty1') %>%
  addemptygrp(grpname='Cohort',emptyname='empty2')


## plot group data
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/ROIMeans_idv_load_side.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
#textSize=26 # defined above function
for (LD in c(1,3)) { 
  for (SD in c('L','R')) {
p.grp <- subset(d.grp, Load==LD&Side==SD) %>%
  # our handy bar plot and error function
  plot_bar_and_error(fill='Cohort',levelname='ROI') + 
  # color of the bar plots 
  scale_fill_manual(values=c(NA,NA,'black','white')) +
  #title of plot
  ggtitle(sprintf("Load %d %s Side",LD,SD)) +
  #labels
  labs(x=(xlab), y=(ylab))+
  # remove se bars for empty, draws border everywhere
  aes(color=Cohort) + scale_color_manual(values=c(NA,NA,'black','black')) +
  coord_cartesian(expand=c(0,0),ylim=c(0,0.5))
ggsave(p.grp,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_ld%dsd%s.pdf",LD,SD))
print(p.grp)
  }
}
dev.off()



#### create dx grouped data


# sumarise data with diagnosis
d.dx <- d.cohort %>% 
  group_by(confirmed_initial_dx1,Load,Side,ROI) %>%  
  meanse

#use clinical info for dx plot
d.clinical<-d.grp
d.clinical.1<-d.clinical[d.clinical$Cohort=="Clinical",]
colnames(d.clinical.1)[1]<-colnames(d.dx)[1]

d.dx$confirmed_initial_dx1

d.dx.1<-rbind(d.clinical.1,d.dx)

d.dx.1$confirmed_initial_dx1=factor(d.dx.1$confirmed_initial_dx1,levels=list('1','2','Clinical','3'),labels=list('1','2','Clinical','3'))

# plot
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/ROIMeans_idv_load_side_dx.pdf')
xlab<-" "
ylab<-"Parameter Estimate"
textSize=26
for (LD in c(1,3)) { 
  for (SD in c('L','R')) {
p.dx <- subset(d.dx.1, Load==LD&Side==SD) %>%
  # our handy bar plot and error function
  plot_bar_and_error(fill='confirmed_initial_dx1',levelname='ROI') + 
  # color of the bar plots
  scale_fill_manual(values=c('grey45','light grey','black','white'))   +
  #title of plot
  ggtitle(sprintf("Load %d %s Side",LD,SD)) +
  #labels
  labs(x=(xlab), y=(ylab))+
  # add borders to be conistant
  aes(color=confirmed_initial_dx1) + scale_color_manual(values=c("black","black","black","black")) +
  coord_cartesian(expand=c(0,0),ylim=c(0,0.5))
  #scale_y_continuous(limits = c(0, 0.5))
ggsave(p.dx,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_ld%dsd%s_dx.pdf",LD,SD))
print(p.dx)
}
}
dev.off()


#now we want to do something similar with behavior data





























## FACET
p<- ggplot(d.sum) + 
 aes(x=ROI,y=mean,color=Cohort,fill=Cohort,group=Cohort) +
 geom_bar(stat='identity',position='dodge') +
 geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
 facet_grid(Load~Side) + 
 theme_bw()

ggsave(p,file='/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_facet_sideByLoad.pdf')

### INDIVIDUAL LOAD+SIDE
#  save a pdf for each and a merged pdf

# for testting
LD=1; SD='L'

pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/ROIMeans_idv_load_side.pdf')

xlab<-"Brain Region"
ylab<-"Parameter Estimate"
textSize=24
for (LD in c(1,3)) { 
 for (SD in c('L','R')) {
  p<-subset(d.sum, Load==LD&Side==SD) %>%
    ggplot() + 
    aes(x=ROI,y=mean,fill=Cohort,group=Cohort) +
    geom_bar(stat='identity',position='dodge',colour="black") +
    geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
    ggtitle(sprintf("Load %d %s Side",LD,SD)) +scale_fill_manual(values = c("light grey","gray40"))+labs(x=(xlab), y=(ylab))+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+coord_cartesian(ylim=c(0.0,0.5))
  ggsave(p,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_ld%dsd%s.pdf",LD,SD))
  print(p)
 }
}

dev.off()

#add in circles for individual subjects
pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/ROIMeans_idv_load_side_circles.pdf')

xlab<-"Brain Region"
ylab<-"Parameter Estimate"
textSize=24
for (LD in c(1,3)) { 
  for (SD in c('L','R')) {
    p<-subset(d.sum, Load==LD&Side==SD) %>%
      ggplot() + 
      aes(x=ROI,y=mean,fill=Cohort,group=Cohort) +
      geom_bar(stat='identity',position='dodge',colour="black") +
      geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
      ggtitle(sprintf("Load %d %s Side",LD,SD)) +scale_fill_manual(values = c("light grey","gray40"))+labs(x=(xlab), y=(ylab))+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+coord_cartesian(ylim=c(-0.1,1.2))
    #subset out circles for each load so that points are plotted in respective graph
    circles<-subset(d.cohort, Load==LD&Side==SD)
    #we are being tricky and making a separate, fake group for "other" so that we can plot filled circles
   p2<- p + geom_point(data=circles,
    position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
    aes(color=as.factor(confirmed_initial_dx1),group=Cohort,y=val,shape=as.factor(confirmed_initial_dx1)),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8"))+scale_shape_manual(values=c(16,1,16))
    ggsave(p,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_ld%dsd%s.pdf",LD,SD))
    print(p)
  }
}

dev.off()



#for more refined dx
cohortinfo <- read.table('/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt',sep="\t",header=T) %>% select(MRID,confirmed_initial_dx1)
d.dx <- merge(d.renamed,cohortinfo,by.x='ID',by.y='MRID')

# get mean and std error
d.sum.dx <- d.dx %>% 
  group_by(Side,ROI,confirmed_initial_dx1) %>% 
  summarize_each(funs(mean,ste),val)

d.sum.dx$confirmed_initial_dx1<-as.factor(d.sum.dx$confirmed_initial_dx1)
#reorder
d.sum.dx$confirmed_initial_dx1=factor(d.sum.dx$confirmed_initial_dx1,levels=list('1', '2','3'),labels=list('1', '2','3'))


# for testting
SD='L'

pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Means_idv_load_side_dx.pdf')

xlab<-""
ylab<-"Parameter Estimate"
textSize=24
for (LD in c(1,3)) { 
  for (SD in c('L','R')) {
    p<-subset(d.sum.dx,Side==SD) %>%
      ggplot() + 
      aes(x=ROI,y=mean,fill=confirmed_initial_dx1,group=confirmed_initial_dx1) +
      geom_bar(stat='identity',position='dodge',colour="black") +
      geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
      ggtitle(sprintf("Load %d %s Side",LD,SD)) +scale_fill_manual(values = c("red","white","gray40"))+labs(x=(xlab), y=(ylab))+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+coord_cartesian(ylim=c(0.0,0.8))
    ggsave(p,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/task_Means_%d%s_dx.pdf",LD,SD))
    print(p)
  }
}

dev.off()
