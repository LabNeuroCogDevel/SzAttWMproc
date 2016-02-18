% write1Dattt
% options: 
%  correct 
%      sep correct and incorrect (by _c{'Correct','Wrong','TooSlow','Catch'})
%  trialonly
%     only grab from cue times (trial onset) for correct (not wrong,slow, or catch)
%  ctch=crct;slw=wrng 
%     merge catch and correct, merge wrong and too slow
%
%  sepside
%     display side of action cue
%  sepdir
%     left/right direction of button push cue
%
%  longcatch
%     identify/sep long catches (cue+attend)
% ---
% trialonly forces correct and will be useless if run with ctch=crct (b/c how long trial is will be a mystery)


function vals=write1DAtt(mat,varargin)

%% parse options
 % look for 'correct' as optional input
 % - set sepcorrect if found
 % - remove from varargin (so other option can be directory)
 opts.sepcorrect=testoption('correct',varargin{:});
 opts.trialonly=testoption('trialonly',varargin{:});
 opts.mergecormis=testoption('ctch=crct;slw=wrg',varargin{:});

 % sep 1d files for the side of target
 opts.sepside=testoption('sepside',varargin{:});

 % sep what button (direction) should have been pushed
 opts.sepdir=testoption('sepdir',varargin{:});

 % sep the types of catches: we want long catch (cue+attend) different than just cue catch
 opts.longcatch=testoption('longcatch',varargin{:});

 % remove opts from varargin (because varargin is used for file naming too)
 % bool their existence (make them T/F flags)
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

 %% make sure we know what we are doing
 if opts.trialonly && opts.mergecormis
    error('should not merge correct and catch and do trialonly')
 end
 if ~opts.sepcorrect && opts.mergecormis
    error('not sep. correct but merging cor and miss ... why?')
 end
 if opts.mergecormis && opts.longcatch
   warning('you want to merge correct and catch and also sep long catches? hope you know what youre doing')
 end

 %% load file, parse data
 % mat='/mnt/B/bea_res/Data/Tasks/Attention/Clinical/11340/20141031/mat/Attention_11340_fMRI_20141031.mat';
 a=load(mat);
 
 fieldNames = fieldnames(a.trial(1).timing);
 % only want timing objects that are strucutres (have onset and ideal)
 structIdxs= cellfun(@(x) isstruct(a.trial(1).timing.(x)), fieldNames);
 fieldNames=fieldNames(structIdxs);

 % construct filetype
 ttype={'Popout','Flexible','Habitual','Catch'};
 types=cell2mat(cellfun(@(x) strmatch(x,ttype), {a.events.type},'UniformOutput',0));
 side   = ~mod([a.events.trgtpos],2)+1; % 1=left, 2=right
 drct   = [a.events.crtDir];          % 1=left, 2=right
 correct= [a.trial.correct];          % 1=correct, 0=wrong, NaN = miss
 
 
 %% check file is sane
 %how many trials did we grab?
 obsTrials = length(a.trial);
 exptTrials = length(a.events);
 if(obsTrials ~= exptTrials )
    warning('*** EXPECTED %d TRIALS BUT CAN ONLY FIND %d! ****',exptTrials,obsTrials);
 end
  
  %% deal with catch trials
  % We dont want catches to be called that
  % but rather what mini block they are from
  trlmnblk    = ceil(a.trialsPerBlock/3); % trials per mini block
  miniblockno = ceil([1:obsTrials]/trlmnblk); % vector of mb #
  % get a number (type) for each block
  blocktypes  = arrayfun( @(x) mode(types(miniblockno==x)),...
                         1:max(miniblockno));
  % replace catch trials with actual block name
  catchtrl = types(1:obsTrials)==4;
  types(catchtrl) = blocktypes(ceil(find(catchtrl)/trlmnblk));
  % note that catchtrl does not encompass all catch trials
  % there are still catchtrials where there was a probe displayed
  
  % we can get long catches by finding where we have attend and no probe
  longcatch= cellfun(@(x) x.probe.ideal<0 & x.attend.ideal>0, {a.trial.timing});
  
  % where are the long fixations?
  longfix = find(diff(miniblockno))+1;
  % if longfix(1) is 25,
  % a.trial(26).timing.fix.onset - a.trial(25).timing.fix.onset  ~  20sec
  % a.trial(25).timing.cue.onset - a.trial(25).timing.fix.onset  ~  16.35
  %
  % arrayfun(@(i) a.trial(i).timing.cue.onset - a.trial(i).timing.fix.onset, longfix)
  % 16.3500   15.5400    7.9161   16.8519   16.8300
  
  
  %% name things
  % later we seperate by correct. but we dont want catch trials to lumped with no response
  % so we'll call the correct value of catch trials somfthing else (3)
  %  new coding scheme 1      2       3        4       5
  re_corrNames = {'Correct','Wrong','TooSlow','Catch','LongCatch'};
  
  re_corr = repmat(4,1,length(correct)); % everything is a 4=catch trial
  re_corr(correct==1) =1; % unless it's correct
  re_corr(correct==0) =2; % or wrong
  %re_corr(correct==-1)=3; % or too slow (missed)

  % combine types for easier 3dDeconvolve WFMJ 20150429
  if opts.mergecormis
    re_corr(correct==-1)=2; % or too slow (missed) -- record with wrong
    re_corr(re_corr==4) =1; % pull catch into correct
  end
  
  % sep long catches?
  if opts.longcatch
      re_corr(longcatch==1) = 5;
  end


 
 % for each field name, we grab the onset of that time
 % as long as the trial had that feild
 vals=struct();
 for b=1:a.noBlocks
     % trial the block starts and ends on
     startB   = (b-1)*a.trialsPerBlock +1;
     endB     = b*a.trialsPerBlock;

     if(startB > obsTrials || endB > obsTrials)
         warning('*** LOOKING FOR BLOCK %d (TRIALS %d-%d) BUT CAN ONLY FIND %d TRIALS! ****',b,startB,endB,obsTrials);
         break
     end

     initTime = a.starttime(b);
     
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

            %fprintf('%d %s %d: t%d, s%d, d%d, c%d\n',b,fieldNames{i} ,t, ...
            %                  types(t),side(t), drct(t),correct(t));

           % save name is the field name for this condition
           savename=[ ...
                      fieldNames{i} ...
                      '_t'  ttype{types(t)} ...
                      ... % side and dir same?
                      ... '_sd' num2str(side(t) == drct(t)) ...
                      ... % correct?
                      ... '_c'  re_corrNames{re_corr(t)} ...
                      ... %we are collapsing accross side/dir
                      ... '_s'  num2str(side(t)) ...
                      ... '_d'  num2str(drct(t)) ...
                    ];


           if opts.sepcorrect
              savename=[savename '_c' re_corrNames{re_corr(t)} ];
           end

           % WF 20150508 only use trial onset, not events
           %   -- only for full correct trials
           if opts.trialonly
             % only care about the trial type
             savename=ttype{types(t)};

             % only for correct (not catch, miss, or error) trials
             % and only if we are looking at cue
             if ~ (re_corr(t) == 1 && strncmp('cue',fieldNames{i},3 ) )
                 continue
             end
           end

           % WF 20150521 -- want to know if we are on left or right
           %    20150526 -- this is the side the target is displayed, but not the direction to push
           if opts.sepside
             savename=[savename '_sd' num2str(side(t)) ];
           end

           % WF 20150526 -- what button should have been pushed
           if opts.sepdir
             savename=[savename '_d'  num2str(drct(t)) ];
           end
        

           if ~isfield(vals,savename)
              vals.(savename){a.noBlocks} = []; 
           end

           


           % append value
           vals.(savename){b} = [ vals.(savename){b} onsettime ];

        end % trials
    end % fields
end % blocks
 

 %% Save 1D files
 
 %do we want to write 1D file?
 oneDfolder=[];
 if(~isempty(varargin) && ischar(varargin{1}))
     oneDfolder=varargin{1};
     mkdir(oneDfolder);
 end
 
 % for each savename fieldvalue from vals
 for v = fieldnames(vals)'
     name=v{1};
     onedout=[oneDfolder '/' name '.1D'];
     fid=fopen( onedout,'w'  );

     for b=1:a.noBlocks
       bvals=vals.(name){b};

       if isempty(bvals)
        fprintf(fid,'*');
       else
        fprintf(fid,'%.2f ', bvals);
       end

       fprintf(fid,'\n');
     end

     fclose(fid);
 end

end %function

% function to check for option(checkstr) in varargin, stolen from write1DWM_v3.m
% returns 1 if there, 0 if not
function b=testoption(checkstr,varargin)
  b=find(cell2mat(cellfun(@(x) ~isempty(strmatch(x,checkstr)), varargin,'UniformOutput',0)));
end
