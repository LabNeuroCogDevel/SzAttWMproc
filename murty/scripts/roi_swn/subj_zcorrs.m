% given a list of subjects
% get zscore matrices for seed regions to each roi for each subject
function zcorrs = subj_zcorrs(subjects,seeds)

  % load from file if we can
  %if exist('zcorrs.mat','file') && ~exist('zcorrs','var')
  % fprintf('loading form zcorrs.mat\n')
  % load('zcorrs')
  % return
  %end

  nroi=264;
  nsubj=length(subjects);

  % for each seed,
  %  go through each subject 
  %   - load subjects seed time series
  %   - get all rois z-correctd corrs to the seed for that subject
  for seed = seeds
    zscorrs.(seed{1}) = zeros(nsubj,nroi);
    for sbji=1:nsubj
       subject=subjects{sbji},
       %about 1.5s per subject
       seed_ts = load(['/Volumes/Phillips/P5/murty/' subject '/swn/' seed{1} '_10mm.txt']);
       zcorrs.(seed{1})(sbji,:)  = arrayfun( @(i) zscore_seed(subject,seed_ts,i ), 1:nroi);
  
    end
  end
end

function z = zscore_seed(subject,seedts,roii)

  fisherz=@(r) .5.*log((1+r)./(1-r));

  roits = load(['/Volumes/Phillips/P5/murty/' subject '/swn/' num2str(roii) '.txt']);
  z = fisherz(corr(roits,seedts));
end


