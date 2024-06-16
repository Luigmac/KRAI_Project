function f=pricemin(x)

global prod corr_consumption_non_wetapp dw_cycle wm_cycle td_cycle wd_cycle;

dw_test=[zeros(x(1),1);dw_cycle;zeros(1440-x(1)-length(dw_cycle),1)];
td_test=[zeros(x(2),1);td_cycle;zeros(1440-x(2)-length(td_cycle),1)];
wm_test=[zeros(x(3),1);wm_cycle;zeros(1440-x(3)-length(wm_cycle),1)];
wd_test=[zeros(x(4),1);wd_cycle;zeros(1440-x(4)-length(wd_cycle),1)];

new_tot_load=corr_consumption_non_wetapp+dw_test+td_test+wm_test+wd_test;

pgrid = prod-new_tot_load;
sc=60;
result = 0.0;
for i=1:1:1440
    
    if (pgrid(i)<0) %purchase
        if ((0<i && i<=6*sc) || (13*sc<i && i<=15*sc) || (22*sc<i))%cheap hours
            result=result+(-0.45*pgrid(i)); %rresult is positive

        elseif ((6*sc<i && i<=13*sc) || (15*sc<i && i<=22*sc)) %expensive hours 
            result=result+(-0.89*pgrid(i));%result is positive

        end

    elseif (pgrid(i)>0)
        result=result+(-0.6*pgrid(i)); 

    else
        %Pgrid=0
    end

end
f=result;