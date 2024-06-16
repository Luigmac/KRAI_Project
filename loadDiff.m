function f=loadDiff(x)

global prod corr_consumption_non_wetapp dw_cycle wm_cycle td_cycle wd_cycle;

dw_test=[zeros(x(1),1);dw_cycle;zeros(1440-x(1)-length(dw_cycle),1)];
td_test=[zeros(x(2),1);td_cycle;zeros(1440-x(2)-length(td_cycle),1)];
wm_test=[zeros(x(3),1);wm_cycle;zeros(1440-x(3)-length(wm_cycle),1)];
wd_test=[zeros(x(4),1);wd_cycle;zeros(1440-x(4)-length(wd_cycle),1)];

new_tot_load=corr_consumption_non_wetapp+dw_test+td_test+wm_test+wd_test;

aux_sum=0;

% for i=1:1440
%     aux_sum=aux_sum+(prod(i)-new_tot_load(i))^2;
% end

 f=sum(abs(prod-new_tot_load));
% 
% f=aux_sum;
end