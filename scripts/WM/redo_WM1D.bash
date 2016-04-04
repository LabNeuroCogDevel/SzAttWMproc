#!/usr/bin/env bash
#
# WF20151109
#
# write new 1d files for working memory task
# wraps each subjects into write1DWM_v3.m
# -- generates matlabcode in redoWM/$savdir.m and runs it
# see e.g.: cut -f3 -d, redoWM/correct_load.m | sed -n "s/'//gp"|xargs ls


####### customize me ########
#
# where to save output (inside subject dir, also name of matlab script to be gen.)
# opts are parsed by write1DWM_v3.m
#savdir=correct_load_wrongtogether_sepdly
#opts="'ctch=crct;slw=wrg','correct','wrongtogether','sepdly'"

savdir=correct_load_wrongtogether_dlymod
opts="'ctch=crct;slw=wrg','correct','wrongtogether','dlymod'"

savdir2=correct_load_wrongtogether
opts2="'ctch=crct;slw=wrg','correct','wrongtogether'"
#
#############################


# dir our matlab script is saved to, not import for it to hang around
# but nice to have
tmpdir=$(pwd)/redoWM/

# make dir, clear file
[ ! -d $tmpdir ] && mkdir -p $tmpdir
outfile=$tmpdir/$savdir.m
echo -n > $outfile

# for each mat
# add a matlab command to run
for matfile in ../../subj/*/1d/WM/WorkingMemory_[0-9]*_fMRI_[0-9]*.mat; do
 # outdir is within same dir as mat file
 outdir="$(dirname $matfile)/$savdir";
 outdir2="$(dirname $matfile)/$savdir2"
 # wrap in try catch so error doesn't force interactive-matlab to hijack script
 # use write1DWM_v3 with our customized options to gernerate a 1d file
 echo "try,write1DWM_v3('$matfile','$outdir',$opts), catch e; disp(e); end;" >> $outfile 

 [ -n "$opts2" ] && echo "try,write1DWM_v3('$matfile','$outdir2',$opts2), catch e; disp(e); end;" >> $outfile 

done

# make sure we quit matlab
echo quit >>$outfile


# matlab hates newlines on commandline, use tr to remove
matlab -nodisplay -nojvm -r "$(cat $outfile|tr -d '\n' )"
# could "run('$outfile')" but write1DWM_v3.m would need to be in the same dir?

# remove aux time points for cue in savdir2=correct_load_wrongtogether
./removeAuxFromCueTimingWM.bash
