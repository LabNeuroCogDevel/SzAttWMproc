#!/usr/bin/env perl
#
# input is seq (e.g hpf) and log file
#
use strict;use warnings;
use List::MoreUtils 'uniq';
use Data::Dumper;

## HOW MANY TRIALS TOTAL?
# currently set at 72, 24 trials per block
my $nt=72;


my $seq=shift;
my $logfile=shift;
die "run like: $0 seq logfile" if !$seq || ! $logfile;
open my $LF, '<', $logfile or die "cannot open $logfile";

my @seq=split //,$seq;

my $trial=0;
my @tlist=();
# ~/rcn/bea_res/Data/Tasks/Attention/*/{11349,11357}*/*/mat/attention_*[0-9]
while(<$LF>) {
   chomp;
   if( m/^TRIAL: (\d+)/) {
     # print "Trial: $1\n";
     $trial=$1;
     $tlist[$trial]->{trial}=$trial;

   } elsif( m/^(col|dir): (.*)/) {
     # print "$1: $2\n";
     $tlist[$trial]->{$1}=[split /\s+/,$2];

   } elsif (m/iscorrect: (-?\d+).*want: (\d+);/) {
     #print "correct: $1 ($2)\n" ;
     $tlist[$trial]->{correct}="$1";
     $tlist[$trial]->{key}    =$2;
     
   } elsif(m/^\s+(fix|cue|attend|probe|clear|fixAfterRT)/) {
     # onsest is the 5th value (not counting first empty whitespace)
     my $onset = (split(/\s+/))[5];
     # skip catch trial
     next if $onset<0;
     #print "$1: ", $onset,"\n";
     $tlist[$trial]->{$1}=$onset;

   } else {
     # junk
   }


}
close $LF;

#sub findOddball {
#  my @seq = @_;
#  #print "input seq:", join(',',@seq),"\n";
#  my @oddball=();
#  for my $i (0..$#seq) {
#    my @found=grep{$_==$seq[$i]} @seq;
#    #print "$i ($seq[$i] vs @seq) found: ", join(',',@found)," $#found\n";
#    push @oddball, $seq[$i] if $#found==0;
#  }
#  #print "oddball: ", join(',',@oddball),"\n";
#  return if $#oddball==-1;
#  return 0 if($#oddball>0);
#  return $oddball[0];
#
#}

## correct transfor
my %ct= (-1=>'TooSlow', 0=>'Wrong', 1=>'Correct',2=>'Catch');
my %st= ('h'=>'Habitual',p=>'Popout',f=>'Flexible');
## hab pop or flex?
# there are 72 trials per run, 24 (=72/3) trials in a mini block
# count the colors that are presented to get at trial type
# easier to just look at block number and resported file used (grep .txt)
#for my $e (24,48,72) {
for my $e ($nt/3,2/3*$nt,72) {
   #my $s = $e-23;
   my $s = $e-($nt/3 -1);

   my $ttype=$st{ shift @seq };
   #my @subarray = @tlist[$s..$e];
   ##print Dumper(@subarray);
   ##print Dumper( map {  $_->{col}  }  @subarray);
   #my @colors = uniq(map { findOddball(@{ $_->{col} }) }  @subarray);
   #@colors = grep {$_!=0} @colors;
   #my $ttype='pop';
   #if($#colors==-1){
   #        $ttype='Flexible';
   #}elsif($#colors==0){
   #        $ttype='Habitual';
   #}else{
   #        $ttype='Popout';
   #}


   #print "@colors $ttype\n";
   for ($s..$e) {
           $tlist[$_]->{type} = $ttype;
	   #$tlist[$_]->{colors} = [@colors];

	   # while we're in here, set correct type
           $tlist[$_]->{correct} = !exists($tlist[$_]->{correct}) ?  2 : $tlist[$_]->{correct} ;
           $tlist[$_]->{correctType} = $ct{$tlist[$_]->{correct}};
   }

}

#print Dumper(@tlist);
#print join("\t",@{$_}{qw/trial correct correctType type fix cue attend/},"\n") for @tlist[1..72];

# want to write out files like
# probe_tPopout_cTooSlow.1D
my %FH=();
for my $t (@tlist[1..$nt]) {
 for my $e (qw/fix cue attend probe clear/){
   next unless $t->{$e}; 
   my $fname="${e}_t$t->{type}_c$t->{correctType}.1D";
   open $FH{$fname}, '>', $fname unless $FH{$fname};
   print {$FH{$fname}} "$t->{$e} ";
 }
}

close $_ for (keys %FH);
