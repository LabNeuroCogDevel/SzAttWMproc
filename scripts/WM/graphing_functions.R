library(ggplot2)

# assumes variable to mean and get se is 'val'
meanse <- function(d) {
  summarize(d, 
            avg=mean(value),
            se=sd(value)/sqrt(n()))
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
