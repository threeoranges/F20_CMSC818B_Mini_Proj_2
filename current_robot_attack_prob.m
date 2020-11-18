% probability of being attacked for each robot 
% two versions

function prob_attack = current_robot_attack_prob(Nr, Nt, N_direction, pt, pr, epsilon)
    % % 1. using numbers of tracked robots at current positions

    % current_tar_cover = cell(Nr, 1); % targets that can be tracked with robots' current positions
    % N_current_tarcover = zeros(Nr, 1); % number of tracked targets by each robot at current positions
    % prob_attack = zeros(Nr, 1); % probability of being attacked for each robot

    % for i = 1:Nr             
    %     for k = 1:Nt % check all the targets
    %         if abs(pr(1,i)-pt(1,k)) <= epsilon && abs(pr(2,i)-pt(2,k)) <= epsilon % ||x_r-x_t||
    %             current_tar_cover{i} = [current_tar_cover{i}, k]; % store the targets can be tracked if the distance is within tolerance
    %         end
    %     end    

    %     N_current_tarcover(i) = length(current_tar_cover{i});    
    % end

    % prob_attack = N_current_tarcover / sum(N_current_tarcover);


% 2. using numbers of tracked robots with best trajectories
% this can be combined with robot_tra_cover_fun
    
N_r_maxtra = zeros(Nr,1); % select the maximum coverage of its trajectories for each robot
% tra_r_index = zeros(Nr,1); % the max tra index
tar_cover = cell(Nr, N_direction); % The targets can be covered for a specific robot with a choosing trajecotry
N_tarcover = zeros(Nr, N_direction); % The number of targets covered for a specific robot with a choosing trajectory
prob_attack = zeros(Nr, 1); % probability of being attacked for each robot

for i = 1:Nr
    for j = 1:N_direction

        if j == 1 % up_trajectory
            for k = 1:Nt % check all the targets
                if pt(2,k) >= pr(2,i) && abs(pr(1,i)-pt(1,k)) <= epsilon % the targets are above the robot, just use ||x_r-x_t||
                    tar_cover{i,j} = [tar_cover{i,j}, k]; % store the targets can be tracked if the distance is within tolerance
                end
            end

        elseif j == 2 % down_trajectory 
            for k = 1:Nt 
                if pt(2,k) <= pr(2,i) && abs(pr(1,i)-pt(1,k)) <= epsilon % targets are below, ||x_r-x_t||
                    tar_cover{i,j} = [tar_cover{i,j}, k];
                end
            end

        elseif j == 3 % left_trajectory
            for k = 1:Nt 
                if pt(1,k) <= pr(1,i) && abs(pr(2,i)-pt(2,k)) <= epsilon % targets are at left, ||y_r-y_t||
                    tar_cover{i,j} = [tar_cover{i,j}, k];
                end
            end

        else % right_trajectory
            for k = 1:Nt 
                if pt(1,k) >= pr(1,i) && abs(pr(2,i)-pt(2,k)) <= epsilon % targets are at right, ||y_r-y_t||
                    tar_cover{i,j} = [tar_cover{i,j}, k];
                end
            end

        end

        N_tarcover(i,j) = length(tar_cover{i,j});
    end % j indicates the direction
    % pick the maximum trajectory (Num_tarcover) and its corresponding targets for each robot 
    N_r_maxtra(i) = max(N_tarcover(i,:)); % maximum number of coverage targets for each robot
                                                            
    % tra_r_index(i) = find(N_tarcover(i,:) == N_r_maxtra(i),1); % direction for maximum coverage 

    %r_max_tracover{i}= tar_cover{i, maxtra_index_j}; % store the maximum coverage for each robot

    prob_attack = N_r_maxtra / sum(N_r_maxtra);

end
    
end