figure; hold on; grid on;

% shadedErrorBar(min_num_tars:max_num_tars,bf_remain_bestremo(:,min_num_tars:max_num_tars),...
%     {@mean,@std},'lineprops','-r','patchSaturation',0.33)

shadedErrorBar(min_num_tars:max_num_tars,resi_remain_bestremo(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops',':r','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,riskaware_remain_bestremo(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','.-c','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,gre_remain_bestremo(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '-.m','patchSaturation',0.33)

% shadedErrorBar(min_num_tars:max_num_tars,ran_remain_bestremo(:,min_num_tars:max_num_tars),...
%     {@mean,@std}, 'lineprops', '--m','patchSaturation',0.33)

title('comparison of the number of targets tracked after removal','fontsize',12)
legend('resilient','risk-aware','greedy');%,'random');'brute-force',
xlabel('number of targets','fontsize',11)
ylabel('coverage number','fontsize',11)