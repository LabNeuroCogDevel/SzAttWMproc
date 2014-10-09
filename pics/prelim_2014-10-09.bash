#!/usr/bin/env bash


sid="11327_20140911"
t1="../subj/$sid/contrasts/WM/template.nii"
wm="../subj/$sid/contrasts/WM/${sid}_WM_DefaultContrasts_stats+tlrc.HEAD"
#../subj/11327_20140911/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK
att="../subj/$sid/contrasts/Att/simpledContrasts_2runs_stats+tlrc.HEAD" 

# FILES?
[ ! -r "$wm" -o ! -r "$att" ] && echo "cannot read '$wm' or '$att'" && exit 1
wmb="$(basename $wm .HEAD)"; 
attb="$(basename $att .HEAD)";

#./start_afni $t1 $wm $att

# START AFNI: should check socket instead of pid
# osx needs a pidof
function pidof {
  ps axc|awk "{if (\$5==\"$1\") print \$1}"|tr ' ' '\n' |sed 1q
}
afnipid=$(pidof afni)
lastpid=$(cat .afnipid)
echo "test $afnipid=$lastpid"
if [[ -z "$afnipid" || "$lastpid" -ne "$afnipid" ]]; then
   afni -YESplugouts -niml  -dset $t1 $wm $att &
   pidof afni > .afnipid
   sleep 10
else 
   echo "using afni@$(cat .afnipid)"
fi

### actually get images
# use plugout_driver: /opt/ni_tools/afni/README.driver
plugout_drive -quit -com "SET_XHAIRS OFF" \
                    -com "SET_ANATOMY $(basename $t1)" \
                    -com "SET_PBAR_NUMBER 12" \
                    -com "OPEN_WINDOW sagittalimage mont=3x2:6" \
                    -com "SET_SPM_XYZ 51 -23 19" 
sleep 2

function takeShot {
 file=$1
 contrast=$2
 savedir=$3
 [ -z "$savedir" -o -z "file" -o -z "$contrast" ] && echo "bad inputs ($@)" && return

 [ ! -d $savedir ] && mkdir -p $savedir
 ./drive_afni_stat $file $contrast 0.05 
 plugout_drive -quit -com "SLEEP 100" -com "SAVE_PNG sagittalimage $savedir/${contrast}_p05.png"
 sleep 1
}

## WM
plugout_drive -quit -com "SWITCH_FUNCTION $wmb" -com "SET_FUNC_RANGE 60"
sleep 5
# cue, dly, target, load4-1: cue, delay, target
for c in cue_mem dly prb cAm_load4M1 dly_load4M1 prb_load4M1; do
 takeShot $wm $c img/wm/$sid
done


## Att
plugout_drive -quit -com "SWITCH_FUNCTION $attb" -com "SET_FUNC_RANGE 60"
sleep 5;
# cue attend target cueflex-pop attendflex-pop targetflex-pop 
for c in cue att prb cue_flxVpop att_flxVpop prb_flxVpop; do
 takeShot $att $c img/att/$sid
done

