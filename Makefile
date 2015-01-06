## MAKEFILE
# call like: 
#   make mprage # to send parse and send mprage to ME/EG people
#
# where call is of the form 
#   make "label"
#   
# labels are defined below like:
#
#   label: depends
#        command
#
# `make` by itself defaults to label 'all'


all: glm

glm: preproc behave
	scripts/03_GLM.bash

preproc: fetchData mprage
	scripts/02_preproc.bash

behave: fetchData
	scripts/01_getBehave.bash

mprage: fetchData
	scripts/01_cpMprage.bash

fetchData:
	scripts/00_fetchData.bash
	# writes SubjInfoGoogleSheet.txt by grabbing google sheet
	# copies over new subjects from wallace


dsi: fetchData
	scripts/01_cpDSI.bash


check: 
	# check subjects match whats in the google doc 
	# this should be put in cron too
	scripts/99_checkSubjAndFiles.bash
