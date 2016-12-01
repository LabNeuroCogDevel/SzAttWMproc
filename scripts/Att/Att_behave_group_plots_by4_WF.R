#this is for attention behave data
library(plyr)
library(dplyr)
library(ggplot2)
library(LNCDR)
#load all the Attention behav files (they've already been run through matlab)
#copy them over from skynet

### FUNCTIONS 

# count number of trues (like num-non-zero in matlab)
nnz <- function(x) { length(which(x)) }

### parse the csv files:
# RT -Inf == no response
# Crt: (NaN, -1)  0 1
# trltp (trial type): 0=catch,1=pop,2=hab,3=flex
# ctrdir is nan on other catches (see cue but not probe)
readtabsubj <- function(f){
 d <- read.table(f,sep=",",header=T)
 # add subj info
 d$id <- gsub('_','',regmatches(f,regexpr('_[0-9]{5}_',f,perl=T)))
 d$vd <- gsub('_','',regmatches(f,regexpr('_[0-9]{8}_',f,perl=T)))

 # remove catch
 d<-d[d$trltp>0&!is.nan(d$crtdir),]

 # number trials
 trlperblock <- 3*16
 d$trialno <- 0:(nrow(d)-1)%%trlperblock + 1
 d$runno   <- cumsum(d$trialno==1)

 d$blktrlno <- 0
 # count trials per miniblock
 for(rn in unique(d$runno) ){
    for(tt in unique(d$trltp) ){
     idx <- d$trltp==tt&d$runno==rn
     d$blktrlno[idx] <- 1:nnz(idx)
    }
 }

 return(d)
}

# read in all subjects, merge with cohort
Attfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/Attention*')
df.att<- do.call(rbind,lapply(Attfiles,readtabsubj)) %>% 
  mutate(mbpart=cut(blktrlno,breaks=c(0,4,8,12,20))) %>%
  mutate(trltp=cut(trltp,breaks=0:3,labels=c('pop','hab','flex'))) 
patcong<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet.txt",header=T) %>% select(MRID,Cohort)
df.att$MRID<-paste(df.att$id,df.att$vd,sep="_")
df.attpc <- merge(df.att,patcong,by='MRID',all.x=T)

# func for repeat filter+summary
summyrt <- function(d) {
  d%>%dplyr::filter(blktrlno<5|blktrlno>12) %>%
  summarise(mCorRT=mean(RT[Crt==1],na.rm=T),
            acc=sum(Crt==1)/n(),
            se=sd(RT[Crt==1],na.rm=T)/sqrt(length(RT[Crt==1])) ) %>%
  mutate(trials = plyr::revalue(mbpart, c("(0,4]"='first4',"(12,20]"='last4') ))
}

# NOT USED!
# mean RT and se for correct trials for each cohort
summy <- df.attpc %>% 
  group_by(trltp,mbpart,Cohort) %>%
  summyrt()

# mean RT and se (per subj)
subjsummy <-  df.attpc %>%
    group_by(id,trltp,mbpart,Cohort) %>%
    summyrt()

# redo summy to be the mean of means instead
summy2 <- subjsummy %>% 
 # rename RT back and make dummy vars for summyrt
 mutate(RT=mCorRT,Crt=1,blktrlno=0) %>% 
 group_by(trltp,mbpart,Cohort) %>%
 summyrt()

write.table(subjsummy,row.names=F,sep=",",quote=F,file="beh_stat/RT_subj_sum.csv")

#### PLOT
# consistant dodging
dg <- position_dodge(height=0,width=.25)
# function for consistant scales across plots
scale_rt <- function(...){
  scale_y_continuous(limits=c(.37,1),...)
}

p<- ggplot(summy2) + 
 # 
 aes(x=trials,y=mCorRT,color=Cohort,group=Cohort) +

 # add subject average with horz jitter
 geom_point(data=subjsummy,aes(group=id),alpha=.2,position=dg ) +
 geom_errorbar(data=subjsummy,aes(ymax=mCorRT+se,ymin=mCorRT-se,group=id),width=1.15,alpha=.2,position=dg) +

 # back to ploting total averages
 geom_point() + geom_line() + 
 geom_errorbar(aes(ymax=mCorRT+se,ymin=mCorRT-se),width=.25) +
 facet_wrap(~trltp) +theme_bw() +scale_rt() #+ scale_color_discrete(guide=F)
print(lunaize(p))
ggsave(p,file='beh_stat/RT_correct_mean_mean.png')

# box plot of same thing, 
# NB color and x are swapped
g <- ggplot(df.attpc%>%dplyr::filter(blktrlno<5|blktrlno>12,Crt==1))+
 aes(x=Cohort,y=RT,color=trials) +
 geom_boxplot() +theme_bw() +
 facet_wrap(~trltp)  +
 scale_rt()
print(g)

#####################################
###### response time and omissions
## look at responses (accuracy, omition rate)
responseSummary <- df.attpc %>% 
   mutate(Crtf = cut( ifelse(is.nan(Crt)|Crt==-1,2,Crt),breaks=c(-1,0,1,2), labels=c("err","cor","omit"))) %>%
   group_by(id,Cohort,trltp,Crtf) %>% 
   summarise(mRT=mean(RT),
              se=sd(RT)/n(),
               n=n() )
#write.table(responseSummary,sep=",",row.names=F,file=)

# put counts into columns for cor omit and err
cnt <- responseSummary %>%
        select(id,Cohort,trltp,Crtf,n) %>%
        spread(Crtf,n) 

# save file
write.table(cnt,file="beh_stat/response_cnt.csv",sep=",",row.names=F,quote=F)
# not everyon has 32 of each trial type, normalize on how many they have
cnt$n <- apply(cnt[,c('cor','omit','err')],MARGIN=1,FUN=sum,na.rm=T)

# 11364 has less than 10 per trial!, remove and get percent per subj
zerona <- function(x){ ifelse(is.na(x),0,x) }
cntgood <- cnt %>% dplyr::filter(n>10) %>% mutate_each(funs(zerona(./n)),cor,omit,err)

cntsum <- cntgood %>% 
   group_by(Cohort,trltp) %>% 
   summarise_each(funs(
                    m=mean(.),
                   se=sd(.)/nnz(!is.na(.)),
                  nnz=nnz(!is.na(.))  ) ,
               err,cor,omit)

write.table(cntsum,sep=",",row.names=F,file="beh_stat/response_cohort_trltype_summary.csv")



