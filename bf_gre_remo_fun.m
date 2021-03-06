%brute-force greedy remo

function [N_bf_max_cover,bf_remain_ran_remo,ran_remo_rate_bf] = bf_gre_remo_fun(Nr,N_direction,...
    N_failure,tar_cover)

    
    % here, we pick one trajectory for each robot, and enumerate all the
    % possible cases, 4^6. And index the four trajectories for robot 1 ,2 ...,
    % 6 as (1 2 3 4) (5 6 7 8) (9 10 11 12)...  and find its corresponding
    % (1,1) (1,2) (1,3), (1,4). (2,1) (2,2) (2,3) (2,4) .... 

    r_tra_index = zeros(Nr, N_direction);

    for i =1 :Nr
        r_tra_index(i,:)=[(i-1)*N_direction+1, (i-1)*N_direction+2, (i-1)*N_direction+3, (i-1)*N_direction+4];
    end
    % find four trajectory index for each robot
    % find all the combinations by pick one trajectory from four trajecotries
    % of each robot
    all_combina = r_tra_index(1,:);
    for i = 2:Nr
        all_combina = combvec(all_combina, r_tra_index(i,:));
    end

    %inside all_combina, the number of column indicates all possible cases and
    %each column indicates one combination
    [row_allcomb, col_allcomb] = size(all_combina);
    
    % target_cover for all combinations
    tar_cover_allcomb = zeros(1,col_allcomb);

    % for each combination (column), choose N_failure best failures, it means
    % the remaining is the minimum (best removal)

    % define all possible cases for choosing N_failure failures
     %num_nrchoosefail= nchoosek(row_allcomn,N_failure);
    nchoose_kfail_index = cell(1,col_allcomb); 
    remain_after_kfail_index = cell(1,col_allcomb);
    num_remain_after_kfail = cell(1, col_allcomb); 
    % remaining target set
    %remain_after_kfail = cell(1,col_allcomb); 
    mini_remain_eachcomb = zeros(1, col_allcomb); 

    for i = 1:col_allcomb
       %we also want to get the number of targets tracked before the best
       %removal % calculate the targets tracked by each column combination
       % r_tra_set for each combination
       r_tra_index_eachcomb = cell(1, row_allcomb);

        
       nchoose_kfail_index{i} = nchoosek(all_combina(:,i),N_failure); 

       for j = 1: row_allcomb
           %we also want to get the number of targets tracked before the best
           %removal % calculate the targets tracked by each column combination

           r_inx_eachcomb = fix((all_combina(j,i)-1)/N_direction)+1; 
           tra_inx_eachcomb = mod(all_combina(j,i)-1, N_direction)+1;
           r_tra_index_eachcomb{j} = [r_inx_eachcomb, tra_inx_eachcomb]; 
           
           
           remain_after_kfail_index{i}(j,:)= setdiff(all_combina(:,i)', nchoose_kfail_index{i}(j,:)); 
           % for each remaining, evaluate which one is minimum
           % calculate the number of tracking for the reamining
           [~, col_remian] = size( remain_after_kfail_index{i}(j,:)); 

           temp_remain_after_kfail = cell(1, col_remian+1);
            for k =1:col_remian % union remaining set by index
                 % corresping to whcih robot and which traj
                   r_remain_index =fix((remain_after_kfail_index{i}(j,k)-1)/N_direction)+1; 
                   tra_remain_index =mod(remain_after_kfail_index{i}(j,k)-1, N_direction)+1;
                   temp_remain_after_kfail{k+1} = union(tar_cover{r_remain_index,tra_remain_index},...
                       temp_remain_after_kfail{k});
            end
             num_remain_after_kfail{i}(j,:) = length(temp_remain_after_kfail{col_remian+1}); 
       end
       % calculate the number of targets tracked by each combination
       [tar_cover_allcomb(i)] = select_tra_cover(Nr,tar_cover, r_tra_index_eachcomb); 
       
       mini_remain_eachcomb(i) = min(num_remain_after_kfail{i}); 
    end
    bf_remain_best_remo = max(mini_remain_eachcomb); 
    maxi_index = find(bf_remain_best_remo== mini_remain_eachcomb,1);

    % there are several equal ones... this has some problems, 
    % the best_removal_rate making sense in this scenario
    
    % Here, we need to calculate the r_tra_inx 
    r_tra_inx = cell(1, Nr); 
    for i = 1 : Nr
        robot_inx= fix((all_combina(i,maxi_index)-1)/N_direction)+1;
        tra_inx =mod(all_combina(i,maxi_index)-1, N_direction)+1; 
        r_tra_inx{i} = [robot_inx, tra_inx];
    end

    %r_tra_inx gives the robot and its assigned trajectory. 
    %we need to select N_failure rounds for the greedy attack
    
    %keep a robot_trajectory copy for greedy attack use.
    gre_r_tra_inx = r_tra_inx;    
    %define gre_attack
    gre_attack_set = cell(1,N_failure + 1);
    %define robot attacked. 
    gre_r_attack = zeros(1,N_failure); 
   
    for r = 1 : N_failure % greedy needs N_failure rounds
        %define marginal_gain at each round
        marginal_gain = zeros(1,Nr-r+1);
        %search for all the possible cases. 
        for i = 1 : Nr-r+1
            marginal_gain(i) =  length(union(tar_cover{gre_r_tra_inx{i}(1), gre_r_tra_inx{i}(2)}, ...
                gre_attack_set{r})) - length(gre_attack_set{r});             
        end
        %find the maximum marginal gain
        [~, max_inx] = max(marginal_gain); 
        gre_attack_set{r+1} = tar_cover{gre_r_tra_inx{max_inx}(1), gre_r_tra_inx{max_inx}(2)};
        gre_r_attack(r) = gre_r_tra_inx{max_inx}(1); 
        gre_r_tra_inx(max_inx) = []; 
                        
    end
    
    s_tra_cover_bf=cell(1,Nr+1); %the target covered by this strategy
    s_tra_cover_gre_remain=cell(1,Nr+1); %the target remaining by random revm strategy 
    
    for i = 1:Nr
        s_tra_cover_bf{i+1} = union(s_tra_cover_bf{i}, tar_cover{r_tra_inx{i}(1),r_tra_inx{i}(2)});
        if ismember(robot_inx, gre_r_attack) > 0
           s_tra_cover_gre_remain{i+1} = s_tra_cover_gre_remain{i}; 
        else
           s_tra_cover_gre_remain{i+1} = union(s_tra_cover_gre_remain{i}, tar_cover{r_tra_inx{i}(1),...
               r_tra_inx{i}(2)});
        end
    end
    N_bf_maxmin_cover = length(s_tra_cover_bf{Nr+1}); %max min cover 
    bf_remain_ran_remo = length(s_tra_cover_gre_remain{Nr+1});
    %best_remo_rate_bf =(N_bf_maxmin_cover-bf_remain_best_remo)/N_bf_maxmin_cover; 
    
    ran_remo_rate_bf = (N_bf_maxmin_cover - bf_remain_ran_remo)/N_bf_maxmin_cover; 
    
    N_bf_max_cover = max(tar_cover_allcomb); % max cover, target cover without any remo
end