%%  pick the best model when we leave n out
%   search space is _very_ small random sample N/n iterations
%   return value is 
function best = pick_svm(labels,data,options,n)

 % leave n out
 % find model that does the best
 N = size(data,1);
 %out_comb=combnk(1:N,n) % way too many :)
 out_idxs=pick_n_out(N,n);
 
 % pseudo-over train
 best.acc = 0;
 for row=1:size(out_idxs,1)
    in_idx = setdiff(1:N,out_idxs(row,:));
    m = svmtrain( labels(in_idx), data(in_idx,:), options );
    [pl,acc,prob] = svmpredict(labels, data, m); 
    if acc(1) > best.acc(1)
      best = struct('m',m,'predict',pl,'acc',acc,'prob',prob);
    end
 end

end

%% outidx -- get indexes to leave out for leave-n out model traning
% from a vector of length N
% pick n indexes (columns), n/N times (rows)
function outidx=pick_n_out(N,n,rows)
  nrows=floor(N/n);
  outidx=zeros(nrows,n);
  for row = 1:nrows;
    outidx(row,:)=randsample(1:N,n);
  end
end
