% main_target_cover for comparing 30 trials for different number of targets
clear all;
min_num_tars = 30;
max_num_tars = 60;
N_trials = 30;

Nr = 6; % the number of robots
en_range = 10; % the range of the environment.

N_failure = 3;
N_resilience = Nr - N_failure;

N_direction = 4; % each robot has four directions, up, down, left, right
epsilon = 0.15 * en_range; % convering distance -2<-->+2 

r_set = zeros(1, Nr); % robot set
for i = 1:Nr
    r_set(i) = i;
end
  
parfor Nt = min_num_tars : max_num_tars
    for i = 1 : N_trials
        cla;
        pt = rand(2,Nt)*en_range;
        pr = rand(2,Nr)*en_range;
        
        [tar_cover, N_tarcover, N_r_maxtra, tra_r_index] =...
            robot_tra_cover_fun(Nr, Nt, N_direction, pt, pr, epsilon);

        % probability of being attacked for each robot 
        prob_attack = current_robot_attack_prob(Nr, Nt, N_direction, pt, pr, epsilon);

        % risk-aware
        [riskaware(i,Nt), riskaware_remain_greremo(i,Nt), greremo_rate_riskaware(i,Nt)] = riskaware_gre_remo_fun(Nr, N_direction,...
            N_failure, tar_cover, r_set, prob_attack);

        % our algorithm, resilient_target_tracking
        [resi(i,Nt), resi_remain_greremo(i,Nt), greremo_rate_resi(i,Nt)] = resilient_gre_remo_fun(Nr, N_direction,...
            N_failure, N_resilience, r_set, tar_cover, N_r_maxtra, tra_r_index);       
        
        % brute_force
        [bf(i,Nt), bf_remain_greremo(i,Nt), greremo_rate_bf(i,Nt)] = bf_gre_remo_fun(Nr, N_direction,...
            N_failure, tar_cover); 
        
        % non-resilience greedy optimal removal 
        [gre(i,Nt), gre_remain_greremo(i,Nt), greremo_rate_gre(i,Nt)] = greedy_gre_remo_fun(Nr, N_direction,...
            N_failure, tar_cover, r_set); 
        
        % random optimal removal
        [ran(i,Nt), ran_remain_greremo(i,Nt), greremo_rate_ran(i,Nt)] = random_gre_remo_fun(Nr, N_direction,...
            N_failure, tar_cover); 
        
    end
end
  
  

figure; hold on; grid on;

shadedErrorBar(min_num_tars:max_num_tars,bf(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','-r','patchSaturation',0.33)

shadedErrorBar(min_num_tars:max_num_tars,resi(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops',':b','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,riskaware(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','.-c','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,gre(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '-.g','patchSaturation',0.33)

shadedErrorBar(min_num_tars:max_num_tars,ran(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '--m','patchSaturation',0.33)

title('comparison of the number of targets tracked before removal','fontsize',12)
legend('brute-force','resilient','risk-aware','greedy','random');
xlabel('number of targets','fontsize',11)
ylabel('coverage number','fontsize',11)


figure; hold on; grid on;

shadedErrorBar(min_num_tars:max_num_tars,bf_remain_greremo(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','-r','patchSaturation',0.2)

shadedErrorBar(min_num_tars:max_num_tars,resi_remain_greremo(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops',':b','patchSaturation',0.2);

shadedErrorBar(min_num_tars:max_num_tars,riskaware_remain_greremo(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','.-c','patchSaturation',0.5);

shadedErrorBar(min_num_tars:max_num_tars,gre_remain_greremo(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '-.k','patchSaturation',0.2)

shadedErrorBar(min_num_tars:max_num_tars,ran_remain_greremo(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '--m','patchSaturation',0.2)

title('numbers of tracked targets after greedy removal','fontsize',12)
legend('brute-force','resilient','risk-aware','greedy','random');
xlabel('number of targets','fontsize',11)
ylabel('coverage number','fontsize',11)


figure; hold on; grid on;

shadedErrorBar(min_num_tars:max_num_tars,greremo_rate_bf(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','-r', 'patchSaturation',0.33)

shadedErrorBar(min_num_tars:max_num_tars,greremo_rate_resi(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops',':b','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,greremo_rate_riskaware(:,min_num_tars:max_num_tars),...
    {@mean,@std},'lineprops','.-c','patchSaturation',0.33);

shadedErrorBar(min_num_tars:max_num_tars,greremo_rate_gre(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '-.g','patchSaturation',0.33)

shadedErrorBar(min_num_tars:max_num_tars,greremo_rate_ran(:,min_num_tars:max_num_tars),...
    {@mean,@std}, 'lineprops', '--m','patchSaturation',0.33)

title('comparison of removal rate','fontsize',12)
legend('brute-force','resilient','risk-aware','greedy','random');
xlabel('number of targets','fontsize',11)
ylabel('coverage number','fontsize',11)          
          
