%%%
%

%% DEFINE STUFF
% get subject info (only for useful subjects)
[subjects,clinical,age,head_motion] = getSubjData();

% svm 2 class, -1 or 1
clinical(clinical==0)=-1;
% probably not needed

% define our seeds: 
%       dlpfc   vc      ppc
seeds={'RBA46','RBA17','RBA40'};

%% GET CORR
% load from file if we can
if exist('zcorrs.mat','file') && ~exist('zcorrs','var'), load('zcorrs'), end
% create zcoors if it doesn't exist arleady
if ~exist('zcorrs','var') 
  % get struct like zscores.(seed) = [nsubj x nroi ]
  zcorrs = subj_zcorrs(subjects, seeds);
  % save these, used by ../WF_svm/testsvms.m
  save('zcorrs')
end

%% these are different data right?
mean(mean(zcorrs.RBA46 - zcorrs.RBA40)) 
mean(mean(zcorrs.RBA17 - zcorrs.RBA40))


%% SVM

 %
 % -s svm type
 % -t kernel 0 is lineark
 % -b prob esitamtes (0=SVC 1=SVR)
 % -c cost (default 1)
 % -g gama (def 1/nfeats)
 % -v  n-fold xvalidate
 % see https://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more
 %options='-s 0 -b 0 -c 1 -g 0.1'; % Xvalidate leave 4 out (1/10th) with  -v 4';

%% pick -c and -g best for all data concatinated
% -- explicte
% data = [ zcorrs.RBA46; zcorrs.RBA40; zcorrs.RBA17 ];
% labels = repmat(clinical,1,3)';

% -- with variable seeds
data=cell2mat(cellfun(@(x) zcorrs.(x), seeds,'UniformOutput',0)');
labels=repmat(clinical,1,length(seeds))';
[opts_all,xvalacc_all] = param_select_svm(labels,data,12,'-b 0 -s 0');

% -- best params are
% -c 8 -g 0.5 -b 0 -s 0


%% make a model for each of the seed regions
% label is clinical(1,n=16) or not (-1,n=22)
labels=clinical';
% how many to leave out in each cross validation
nleftout=8;
for s=seeds;
 sn=s{1};
 data=zcorrs.(sn);

 models.(sn) = pick_svm( labels, data, opts_all, nleftout );


 % -- if we wanted to pick the best paramters for each seed model:
 %  
 % % choose best -c and -g for this seed
 % [svmopts,xvalacc] = param_select_svm(labels,data,nleftout,'-b 0 -s 0');

 % % pick best model from Xval. -- probably overtraining :-/
 % models.(sn) = pick_svm( labels, data, svmopts, nleftout );

 % % add generating params to struct
 % models.(sn).svmopts = svmopts;
 % models.(sn).xvalacc = xvalacc;
 
 % --
 

 % for binary: w=SVs'*sv_coef
 % sign(w'z-rho) == prediction!? doesn't work
 models.(sn).w=models.(sn).m.SVs' * models.(sn).m.sv_coef;
end



%% do stuff with models

% most accurate
models.RBA46.acc,

% all accuracies
disp(seeds);
disp(cellfun(@(x) models.(x).acc(1), seeds));

w=models.RBA46.m.SVs' * models.RBA46.m.sv_coef;
