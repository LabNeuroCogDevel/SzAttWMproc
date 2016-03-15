% from http://www.csie.ntu.edu.tw/~cjlin/libsvm/faq.html#f803
% out best parameter command string and accuracy of that
function [bestcmd,bestcv]=param_select_svm(labels,data,nleftout,varargin)
   bestcv = 0;
   bestcmd='';
   for log2c = -1:3,
      for log2g = -4:1,
         cmd = ['-v ' num2str(nleftout) ' -c ', num2str(2^log2c), ' -g ', num2str(2^log2g) ' ' varargin{:}];
         cv = svmtrain(labels, data, cmd);
         if (cv >= bestcv),
            bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
            % remove -v ####
            nstrlength=size(num2str(nleftout),2);
            bestcmd=cmd((4+nstrlength):end);
         end
         fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
      end
   end
end
