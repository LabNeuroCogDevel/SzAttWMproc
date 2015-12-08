function r=WMBehav(matfile)
   s=load(matfile);
   
   dr       = [s.events.playCue];
   ld       = [s.events.load];
   RT       = [s.events.RT];
   Crt      = [s.trial.correct];
   islngdly = [s.events.longdelay];
   ischng   = [s.events.changes];
   
   r.matrix=[Crt' RT' ld' dr' islngdly' ischng' ];
   r.header={'Crt','RT','ld','dr','islongdelay','ischange'};
   
   r.subj=[num2str(s.id) '_' num2str(s.rundate)];
   r.task=s.task;
   
end
