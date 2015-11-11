function vals=write1DWM_v3(mat,varargin)

%"mat" is the .mat file of the current subject (full pathname)
%"Varargin" contains an output directory (required) plus the following optional inputs:
% - (0) "[]" {no additional input} = create 1d files for each task condition, regardless of subject performance
% - (1) "correct" = create separate 1d files for correct trials 
% - (2) "ctch=crct;slw=wrg" = create 1d files that merge catch+correct and slow+wrong trials together 
%       (**must be used in conjunction with sepcorrect**)
% - (3) "sepside" = create separate 1d files for whether stimulus appeared in left or right visual hemifield
% - (4) "sepdir" = create separate 1d files for whether subject pushed left or right button
% - (5) "trialonly" = create 1d files for onset of each trial type (don't try to model different phases--cue, fix, delay, probe)

opts.sepcorrect   =testoption('correct'          ,varargin{:});
opts.mergecormis  =testoption('ctch=crct;slw=wrg',varargin{:});
opts.sepside      =testoption('sepside'          ,varargin{:}); 
opts.sepdir       =testoption('sepdir'           ,varargin{:}); %GM 071315 - not currently enabled; can't find necessary info for this option in mat file
opts.sepchange    =testoption('sepchange'        ,varargin{:}); %WF20151109 - merge more
opts.trialonly    =testoption('trialonly'        ,varargin{:}); %GM071315 - not currently enabled
opts.wrongtogether=testoption('wrongtogether'    ,varargin{:}); %GM071315 - not currently enabled
opts.isimodulation=testoption('isimodulation'    ,varargin{:}); %GM071315 - not currently enabled

opts,


%opts.sepcorrect=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,'correct')), varargin,'UniformOutput',0)));
%opts.mergecormis=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,'ctch=crct;slw=wrg')), varargin,'UniformOutput',0)));
%opts.sepside=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,'sepside')),varargin,'UniformOutput',0))); 
%opts.sepdir=find(cell2mat(cellfun(@(x)  ~isempty(strmatch(x,'sepdir')),varargin,'UniformOutput',0))); %GM 071315 - not currently enabled; can't find necessary info for this option in mat file
%opts.trialonly=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,'trialonly')), varargin,'UniformOutput',0))); %GM071315 - not currently enabled

%After reading option(s),remove them from varargin (because varargin is used for file naming too)
%Bool their existence for later
 for o=fieldnames(opts)'
   o=o{1};
   if isempty(opts.(o))
     opts.(o)=0;
   else 
     keep=setdiff(1:length(varargin),opts.(o));
     varargin = varargin( keep );
     opts.(o)=1;
   end
 end
 
%After bool, check to ensure contradictory options not given
 if opts.trialonly && opts.mergecormis
    error('should not merge correct and catch and do trialonly')
 end
 if ~opts.sepcorrect && opts.mergecormis
    error('not sep. correct but merging cor and miss ... why?')
 end

%-------------------------------------------%
%Load the mat file of the current subject
%-------------------------------------------%

a=load(mat);

fieldNames = fieldnames(a.trial(1).timing);

%Only want timing objects that are strucutres (have onset and ideal)
structIdxs= cellfun(@(x) isstruct(a.trial(1).timing.(x)), fieldNames);
fieldNames=fieldNames(structIdxs);
 %   'fix'
 %   'cue'
 %   'mem'
 %   'delay'
 %   'probe'
 %   'finish'
 
% ***Currently (7/30/15) we are only interested in modeling fix, cue+mem (using one
%long block whose length varies with the ISI between them and which we
%will call "cue"), delay, and probe.  
 
 fieldNames={'fix','cue','delay','probe'};
 
 %Construct filetype
  %changes   = [a.trial.hemi]+1;     
  changes  = [a.events.changes];        % 0=no, 1=yes
  correct  = [a.trial.correct];         % 1=correct, 0=wrong, (-1)=miss, NaN=catch 
  loadn    = [a.trial.load];            % 1=1dot, 3=3dots
  side     = [a.trial.playCue];         % 1=left, 2=right
  delayType= [a.events.longdelay];      % 0=short, 1=long
  %drct     = [a.events.crtDir]; GM071315 - can't find this field in WM mat files

  %Create alternate coding scheme for possible use later, depending on varargin 
  %If we wish to separate correct trials (or merge correct-catch), we need different vals than those in .mat file.
  %New coding scheme: 1      2       3        4
  re_corrNames = {'Correct','Wrong','TooSlow','Catch'};
  %Create matrix of "4"s and then replace with appropriate values:
  re_corr = repmat(4,1,length(correct)); % everything is a 4 (catch) trial...
  re_corr(correct==1) =1; % unless it's correct...
  re_corr(correct==0) =2; % or wrong...
  re_corr(correct==-1)=3; % or too slow (missed)  
  
  %If "mergecormiss" is enabled, then we will merge catch with correct and miss with wrong
  %You can specify "sepcorrect" without "mergecormiss," but not vice-versa (i.e. to run 
  %"mergecormiss" you must specify "sepcorrect." Then, later in the script, "sepcorrect" 
  %will identify whether trials were correct, incorrect, etc. The code immediately below 
  %will then lead to the merger of the desired files (but only if "sepcorrect" is enabled).  
  if opts.mergecormis
    re_corr(correct==-1)=2; % or too slow (missed) -- record with wrong
    re_corr(re_corr==4) =1; % pull catch into correct
  end
  
  
  %-----------------------------------------%
  %Obtain stim times for 1D files
  %-----------------------------------------%
  
 %For each field name, grab the onset time as long as the trial had that field
 vals=struct();
 for b=1:a.noBlocks
     % trial the block starts and ends on
     startB   = (b-1)*a.trialsPerBlock +1;
     endB     = b*a.trialsPerBlock;
for i=1:length(fieldNames)
        for t=startB:endB 
           % skip guys without onsets
           if ~isfield(a.trial(t).timing,fieldNames{i}) 
                continue
            end
            if  ~isfield(a.trial(t).timing.(fieldNames{i}),'onset')
                continue
            end

            % what is the onset given the start time of the block?
            onsettime= a.trial(t).timing.(fieldNames{i}).onset ...
                       - a.starttime(b);    

            % skip values that dont make sense
            if  onsettime < 0 || isinf(onsettime) || isnan(onsettime)
                continue
            end
            
            onsettime= sprintf('%.2f',onsettime); %for AFNI formatting purposes (see "cue" below)
            
            % For the cue condition, calculate the length of the ISI between cue and mem
            if 0 && any(strmatch('cue',fieldNames{i})) && ~isempty(opts.isimodulation)
                fprintf('isi modulation\n')
                isi_dur= a.trial(t).timing.mem.onset - a.trial(t).timing.isi.onset;
                block_dur= isi_dur + 0.40; %(cue = 0.2s and mem= 0.2s)
                block_dur= sprintf('%.2f',block_dur);
                onsettime= [onsettime ':' block_dur]; %format for use with AFNI's -stim_times_AM1 option
            end 
            
            
            
           savename= fieldNames{i};

           % clear savename if wrong and we want all the wrongs together
           wrongtogether = all(opts.wrongtogether & re_corr(t) == 2);
           if wrongtogether 
             savename='';
           end
            
           % If it's anything BUT fix (i.e. cue, delay, or probe) 
           % then "load" will be relevant and must be recorded
           % -- we dont care what load if we are lumping all wrongtogether and it is wrong
           if isempty(strmatch(fieldNames{i},'fix')) & ~wrongtogether
                savename = [savename '_ld' num2str(loadn(t))];
                                     %'_sd' num2str( side(t)) ]; %GM 071315-- make separation by side optional (specify in varargin)
           end

           %Do we want to sep change/nochange?
           % also tied to delay length, maybe?
           if opts.sepchange & ~wrongtogether
                %If it's probe, then additionally, "change" will be relevant and must be recorded
                if strmatch('probe',fieldNames{i})  
                    savename = [savename '_chg' num2str(changes(t)) ]; 
               %If it's delay, then additionally, "delay" will be relevant and must be recorded
                elseif  strmatch('delay',fieldNames{i}) 
                    savename = [savename '_dly' num2str(delayType(t)) ]; 
                end
           end

           % Do we want to seperate correct?
           if opts.sepcorrect 
              % if wrong and all of them are together
              % would start with _, and that's a matlab no-no
              sep = '_';
              if wrongtogether, sep=''; end

              savename = [savename sep re_corrNames{re_corr(t)} ];
           end
           
            %Do we want to separate by side? 
           if opts.sepside & ~wrongtogether
             savename=[savename '_sd' num2str(side(t)) ];
           end

           if ~isfield(vals,savename)
              vals.(savename){a.noBlocks} = []; 
           end

           % append value
           vals.(savename){b} = [vals.(savename){b} onsettime ' '];
     
        end % trials
    
    end % fields
      
    
     %Find trials on this block where there is a response
      bidx=find([a.events.block]==b);
      RTidx=arrayfun(@(x)  isfield(a.trial(x).timing,'Response')...
                           && isfinite(a.trial(x).timing.Response),...
                     bidx);
      
      vals.Response{b} = arrayfun(@(x)  a.trial(x).timing.Response, bidx(RTidx))...
                         - a.starttime(b);
 end % blocks
 

%-----------------%     
% Save 1D files
%-----------------% 

%Do we want to write 1D file?
oneDfolder=[];
if(~isempty(varargin) && ischar(varargin{1}))
     oneDfolder=varargin{1};
     mkdir(oneDfolder);
end

%%% %Write dummy 1D files in case some conditions have no events (these get
%%% %overwritten in next step if data exists)
%%% 
%%% cue_files= {'cue_ld1_Correct.1D','cue_ld1_Wrong.1D','cue_ld3_Correct.1D','cue_ld3_Wrong.1D'};
%%% for i=1:length(cue_files)
%%%     cue_output=[oneDfolder '/' cue_files{i}];
%%%     fid=fopen(cue_output,'w');
%%%     fprintf(fid,'*');
%%%     fprintf(fid,'\n');
%%%     fprintf(fid,'-1:0');
%%%     fclose(fid);
%%% end 
%%% 
%%% other_files= {'delay_ld1_dly0_Correct.1D','delay_ld1_dly0_Wrong.1D','delay_ld1_dly1_Correct.1D','delay_ld1_dly1_Wrong.1D',...
%%%               'delay_ld3_dly0_Correct.1D','delay_ld3_dly0_Wrong.1D','delay_ld3_dly1_Correct.1D','delay_ld3_dly1_Wrong.1D',...
%%%               'probe_ld1_chg0_Correct.1D','probe_ld1_chg0_Wrong.1D','probe_ld1_chg1_Correct.1D','probe_ld1_chg1_Wrong.1D',...
%%%               'probe_ld3_chg0_Correct.1D','probe_ld3_chg0_Wrong.1D','probe_ld3_chg1_Correct.1D','probe_ld3_chg1_Wrong.1D'};
%%% for j=1:length(other_files)
%%%     other_output=[oneDfolder '/' other_files{j}];
%%%     fid=fopen(other_output,'w');
%%%     fprintf(fid,'*');
%%%     fprintf(fid,'\n');
%%%     fprintf(fid,'*');
%%%     fclose(fid);
%%% 

%For each savename fieldvalue from vals
 for v = fieldnames(vals)'
     name=v{1};
     %fid=fopen( [oneDfolder '/' name '.1D'],'w'  );
     onedout=[oneDfolder '/' name '.1D'];
     fid=fopen(onedout,'w');
     
     for b=1:a.noBlocks
       bvals=vals.(name){b};
       if isempty(bvals)
           if name(1:3)=='cue'
               fprintf(fid,'-1:0')
           else
            fprintf(fid,'*');
           end 
       else
        bvals=deblank(bvals);
        fprintf(fid,'%s', bvals);
       end

       fprintf(fid,'\n');
     end

     fclose(fid);
 end

end %function

% WF20151109 -- function to check for option(checkstr) in varargin
% returns 1 if there, 0 if not
function b=testoption(checkstr,varargin)
  b=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,checkstr)), varargin,'UniformOutput',0)));
end
