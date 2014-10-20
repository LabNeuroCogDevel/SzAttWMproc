library(plyr)
library(ggplot2)
library(xtable)
#set your file name
filename = "/Volumes/Phillips/P5/csv/Attention_11333_20141017_behave.csv"
#give a prefix, need for function
prefix= 'csv/Attention_'
#these are the variables you want
want = .(trltp, iscong)
#this is a function Will made- here is me breaking it down
#first he says find the prefix in filename, replace it with nothing
#gsub(prefix,'',filename)
mkTable <- function(filename,prefix=prefix,want=want) {
  #then take that result, find "_behav.csv" and replace it with nothing
  #so you are left with a subjid of "/Volumes/Phillips/P5/11333_20141017"
  subjid <- gsub('_behave.csv','',gsub(prefix,'',filename))
  #then identify variable a, which is basically the file with the data
  a<-read.table(filename,sep=',',header=T)
  #want a subset of this, get rid of all the NaNs (those are catch trials)
  a<-a[!is.nan(a$Crt),]
  #take the variable a, focusing on trial type and whether or not it is congruent
  #for each trial type and cong/incong, get the mean RT of all finite (existing) reaction times, times it by 1000, to get it in ms
  #get percent correct for each trial type and cong/incong
  #ddply- this is an R command that does this (from package plyr): for each subset of a data frame, apply function then combine results into a data frame. 
  r<-ddply(a,
           want,
           function(x) {
             data.frame(
               RT=round(mean(x$RT[is.finite(x$RT)])*1000),
               prctCrt=length(which(x$Crt==1))/length(x$RT)*100,
               n=length(x$RT)
             )
           }
  )
  r$id <- subjid;
  return(r);
}
## WM
#find all the working memory behavioral data files
WMfiles <- Sys.glob('/Volumes/Phillips/P5/csv/WorkingMemory*')
#make a table for load (1,4) and also whether the memory probe changed/not changed
#ldply is an R command that means For each element of a list, apply function then combine results into a data frame. 
wm<-ldply(WMfiles,mkTable, prefix='csv/WorkingMemory_',want=.(ld,ischange))
# ld -> load
# id -> pat/control
#replace header "ld" with "load"
names(wm)[grep(names(wm),'ld')] <- 'load'
wm$id[wm$id=="11333_20141021"] <- 'patient'
#wm$id[wm$id=="11327_20140911"] <- 'patient'
wmPlot <- ggplot(wm,aes(x=as.factor(ischange),shape=as.factor(load),color=id))+ theme_bw()
wmRT <- wmPlot +geom_point(aes(y=RT))
wmPC <- wmPlot +geom_point(aes(y=prctCrt))
ggsave(wmRT,file="/Volumes/Phillips/P5/graphs/wmRT.png")
ggsave(wmPC,file="/Volumes/Phillips/P5/graphs/wmPC.png")
## Att
Attfiles <- Sys.glob('/Volumes/Phillips/P5/csv/Att*')
att<-ldply(Attfiles,mkTable, prefix='csv/Attention_',want=.(trltp,iscong))
#att$id[att$id=="sm_20140829_20140829"] <- 'control'
att$id[att$id=="11333_20141021"] <- 'patient'
attPlot <- ggplot(att,aes(x=as.factor(trltp),shape=as.factor(iscong),color=id,size=n))+ theme_bw()
attRT <- attPlot +geom_point(aes(y=RT))
attPC <- attPlot +geom_point(aes(y=prctCrt))
# + geom_line(aes(y=prctCrt,group=id))
ggsave(attRT,file="/Volumes/Phillips/P5/graphs/attRT.png")
ggsave(attPC,file="/Volumes/Phillips/P5/graphs/attPC.png")
#sink is an r command that diverts R output to a connection
sink('/Volumes/Phillips/P5/att_table.tex'); xtable(att); sink()
sink('/Volumes/Phillips/P5/wm_table.tex'); xtable(wm); sink() 