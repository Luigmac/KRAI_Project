%% Genetic algorithm for load scheduling (Cost minimization)

clc;
clear all;
close all;
global prod corr_consumption_non_wetapp dw_cycle wm_cycle td_cycle wd_cycle;
load data_app.mat;
n_tot=0.2*0.9;      %total efficiency npv=20%, n_inv=90%.

prod=n_tot*irradiancia*20;  % Area = 20m^2
f2=figure;
figure(f2);
plot(prod*0.001);
title('PV generation')
xlabel('Time (min)')
ylabel('Power (kw)')
xlim([0,1440]);
ylim([0,3.5]);


f3 = figure;
figure(f2);
plot(consumption_total);
plot(consumption_non_wetapp);
title('Production and demand');
legend('P(t)','D_H(t)', 'D_H_w_a_p_p(t)');


%Data correction to match consumption_total 
dw_cycle=dw_cycle-100;
wm_cycle=wm_cycle-1;
td_cycle=td_cycle-1;
wd_cycle=wd_cycle-1;

%% Load array with intial start time from data
dw_tot=[zeros(min_dw_inic-1,1);dw_cycle;zeros(1440-min_dw_inic+1-length(dw_cycle),1)];
td_tot=[zeros(min_td_inic-12,1);td_cycle;zeros(1440-min_td_inic+12-length(td_cycle),1)];
wm_tot=[zeros(min_wm_inic-1,1);wm_cycle;zeros(1440-min_wm_inic+1-length(wm_cycle),1)];
wd_tot=[zeros(min_wd_inic-1,1);wd_cycle;zeros(1440-min_wd_inic+1-length(wd_cycle),1)];


hold off;
subplot(2,2,2);
plot(dw_tot);
hold on;
plot(td_tot);
plot(wm_tot);
plot(wd_tot);
title('Appliances load profile');
legend('Dish washer','Tumble dryer','Washing machine','Washer dryer');


%% Comparison of the consumption_total and consumption_non_wet_app + individual appliances
corr_consumption_non_wetapp=consumption_non_wetapp+3*ones(1440,1);
tot_consump_test=corr_consumption_non_wetapp+dw_tot+td_tot+wm_tot+wd_tot;
hold off;
subplot(2,2,3);
plot(consumption_total);
hold on;
plot(tot_consump_test);
title('Comparison of original and made data')
legend('Original','Made')
 
 hold off;
 f1=figure
 figure (f1)

%% Time to optimize :) .... for several times
for i=100:100  %%PLAY WITH THIS FOR THE MAX NUMBER OF GENERATIONS
    % targ_func=@loadDiff;
    targ_func=@pricemin;
    [x,fval,exitflag,output,population,scores]=ga(targ_func,4,[],[],[],[],[1;1;1;1],[1440-length(dw_cycle);1440-length(td_cycle);1440-length(wm_cycle);1440-length(wd_cycle)],[],[1;2;3;4], gaoptimset('Generations',i));
        
    
    %%function to evaluate, number of variables, Inequalities parameters,
    %%ga(fun,nvars,A,b,Aeq,beq,lb,ub,nonlcon,options)
    %%lower bounds, upper bounds, integer condition for which variable
    
    % New load profiles after optimization
    new_dwl=[zeros(x(1),1);dw_cycle;zeros(1440-x(1)-length(dw_cycle),1)];
    new_tdl=[zeros(x(2),1);td_cycle;zeros(1440-x(2)-length(td_cycle),1)];
    new_wml=[zeros(x(3),1);wm_cycle;zeros(1440-x(3)-length(wm_cycle),1)];
    new_wdl=[zeros(x(4),1);wd_cycle;zeros(1440-x(4)-length(wd_cycle),1)];
     
    % Modified total load profile after optimization
    new_total_load=new_dwl+new_tdl+new_wml+new_wdl+corr_consumption_non_wetapp;

    %Calculate index
    LM_af=min(prod,new_total_load);
    sc_af=sum(LM_af)/sum(prod);
    ss_af=sum(LM_af)/sum(new_total_load);
    P_gaf=prod-new_total_load;
    E_gaf=sum(abs(P_gaf));
  
    subplot(3,1,1);
    hold on;
    scatter(i,sc_af,'d',LineWidth=0.6,MarkerEdgeColor='k',MarkerFaceColor='b');
    subplot(3,1,2);
    hold on;
    scatter(i,ss_af,'d',LineWidth=0.6,MarkerEdgeColor='k',MarkerFaceColor='r');
    subplot(3,1,3);
    hold on;
    % scatter(i,E_gaf,'d',LineWidth=0.6,MarkerEdgeColor='k',MarkerFaceColor='g');
    scatter(i,fval,'d',LineWidth=0.6,MarkerEdgeColor='k',MarkerFaceColor='g');
 
end


title('Grid interaction over generation');
xlabel('Generation Number');
ylabel('SC index');

subplot(3,1,1);
title('SC index over generation');
xlabel('Generation Number');
ylabel('SC index');

subplot(3,1,2);
title('SS index over generation');
xlabel('Generation Number');
ylabel('SS index');



%% Plot comparison of profileshold off;
figure(f2)
subplot(2,2,4);
plot(new_dwl);
hold on;
plot(new_tdl);
plot(new_wml);
plot(new_wdl);
title('New profile');
legend('Dish washer','Tumble dryer','Washing machine','Washer dryer');

figure
hold off;
subplot(2,1,1)
plot(prod);
hold on;
plot(consumption_total);
title('Production and original demand');
legend('P(t)','D_H(t)');

hold off;
subplot(2,1,2)
plot(prod);
hold on;
plot(new_total_load);
title('Production and Flexible demand');
legend('P(t)','D_H_m_o_d(t)');

%% Compute after and before indexes:
%Before index
LM_bf=min(prod,consumption_total);
sc_bf=sum(LM_bf)/sum(prod);
ss_bf=sum(LM_bf)/sum(consumption_total);
P_gbf=prod-consumption_total;
E_gbf=sum(abs(P_gbf));

%After index
LM_af=min(prod,new_total_load);
sc_af=sum(LM_af)/sum(prod);
ss_af=sum(LM_af)/sum(new_total_load);
P_gaf=prod-new_total_load;
E_gaf=sum(abs(P_gaf));

fprintf('\nIndex\t\t Before \t\t After\n---------------------------------\n');
fprintf('SC\t\t\t%0.3f\t\t\t%0.3f\n',sc_bf,sc_af);
fprintf('SS\t\t\t%0.3f\t\t\t%0.3f\n',ss_bf,ss_af);
fprintf('E_grid(kW)\t%0.3f\t\t%0.3f\n',E_gbf/1000,E_gaf/1000);
x§