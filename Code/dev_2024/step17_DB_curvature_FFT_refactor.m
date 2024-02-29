%% step17_DB_Curvature_FFT_refactor.m
% Interface with DB's code on clean tags only: joy_data3.m, joy_data4.m

%% function joy_data3
%% Re-interpolate the entire fish body to 23 points in a 4-th order curve

clear
close all
clc
format short

%--------------------------------------------------------------------------
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
fig_out_path = [out_dir_figures, 'Curvature\'];
if ~exist(fig_out_path, 'dir')
    mkdir(fig_out_path);
end

struct_filename = [abs_path, 'all_fish_full_length_data.mat'];

%% MY Load the data
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
struct_file = load([abs_path, 'raw_data_full_body.mat']); % All the raw + cleaned data labels for Bode analyis
data2 = struct_file.all_fish;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
num_interp_pts = 23;

data = load(struct_filename);
p2m = 0.0002;
fish_name = cell(1,5);

% Because there are 5 big trials in each of the 14 luminances
% each of these elements might be 1x7, or
% depending on the clean tags, 1x4, 1x5, ...
fish_luminance_data = cell(14,5);

%--------------------------------------------------------------------------
for i = 1:numFish
    % fish_name(i) = cellstr(data.all_fish_data(i).fish_name);
    fish_name(i) = fishNames(i);

    % tmp is 1x14 struct
    tmp_old = data.all_fish_data(i).luminance;
    tmp = data2(i).luminance;

    for j = 1:length(tmp)
        fish_luminance_data{j,i} = tmp(j).data;
    end
end

% return
%--------------------------------------------------------------------------
fish_index = 1; % can vary from 1 to 5 %14, 9, 11, 9, 9 HOpe en Doris Finn Ruby
number_ils = 1;
% il_level  = 14;  % can vary from 1 to 14 but not all fish has 14 levels, some has 9 as well 11
%--------------------------------------------------------------------------

h =  findobj('type','figure');
n_fig = length(h);

discard_index = cell(1,1);
counter = 1;

tic

for il  = 1 : number_ils

    il_level  = il;

    for num_trials_per_il = 1:size(fish_luminance_data{il_level,fish_index},2)

        % v = [1, 1, 0]
        v_field = 'valid_both';
        v = fish_luminance_data{il_level,fish_index}(num_trials_per_il).(v_field);

        for rep = 1:3

            x_fields_tmp_old = strcat('x_rep',num2str(rep)); % create x_rep1, x_rep2,...
            y_fields_tmp_old = strcat('y_rep',num2str(rep)); % create y_rep1, y_rep2,...

            % [NEW]
            x_fields_tmp = strcat('x_rot_rep',num2str(rep)); % create x_rep1, x_rep2,...
            y_fields_tmp = strcat('y_rot_rep',num2str(rep)); % create y_rep1, y_rep2,...

            if isfield(fish_luminance_data{il_level,fish_index}(num_trials_per_il),(x_fields_tmp)) % check if the field exists

                % 500 x 12 double
                X = fish_luminance_data{il_level,fish_index}(num_trials_per_il).(x_fields_tmp);
                Y = fish_luminance_data{il_level,fish_index}(num_trials_per_il).(y_fields_tmp);

                % fixing at second body point
                X = X - X(:,2);
                Y = Y - Y(:,2);

                % fix head point #2 to (0,0), but head point would then be
                % negative.

                if v(rep) == 0
                    X_corrected_tmp = [];
                    Y_corrected_tmp = [];
                
                % Only calculate it when it's valid
                elseif v(rep) == 1
                    X_corrected_tmp = nan(500,12);
                    Y_corrected_tmp = nan(500,12);

                    % All the arc lengths throughout the 500 frames
                    Arc_Len = nan(500,1);

                    % 500 frames total
                    for k = 1:500

                        p = polyfit(X(k,:),Y(k,:),4);
                        px = linspace(X(k,1),X(k,end),num_interp_pts);
                        py = polyval(p,px);

                        % Call the arc length helper function
                        [arclen,~] = arclength(px,py,'spline');

                        Arc_Len(k) = arclen;

                        py2 = interp1(px,py,X(k,:));
                        X_corrected_tmp(k,:) = X(k,:) - X(k,2);
                        Y_corrected_tmp(k,:) = py2(:) - py2(2);

                        %--------------------------------------------------------------------------
                        % uncomment for plot
                        %--------------------------------------------------------------------------
                        %                 figure(n_fig+1)
                        %                 clf
                        %                 set(gcf,'color','white')
                        %                 set(gca,'LineWidth',1.5,'fontsize',14)
                        %                 hold on
                        %                 plot(X(k,:),Y(k,:),'r.-','LineWidth',2,'MarkerSize',20)
                        %                 plot(px,py,'k-','LineWidth',1.5,'MarkerSize',15)
                        %                 axis([-100 400 -250 250])
                        %                 box off
                        %                 time_str = sprintf('%0.2f',round((k-1)/25,2));
                        %                 arc_len_str = sprintf('%0.2f',round(Arc_Len(k),2)*p2m*100);
                        %                 title(['Fish:',fish_name{fish_index},...
                        %                     ', IL Level:',num2str(il_level),...
                        %                     ', Trial:',num2str(fish_luminance_data{il_level,fish_index}(num_trials_per_il).trial_idx),...
                        %                     ', Rep:',num2str(rep),...
                        %                     ', Time = ',time_str, ' s, Length = ',arc_len_str, ' cm'],'FontSize',16,'FontWeight','normal')
                        %                 grid on
                        %                 pause(1e-10)
                        %--------------------------------------------------------------------------

                    end


                    n_fig = n_fig+1;
                    mean_fish_length = mean(Arc_Len(1:20)*p2m*100,'all','omitnan'); % mean of first n=20 frames
                    deviation_in_len = abs(Arc_Len*p2m*100-mean_fish_length)/mean_fish_length*100;

                    % Checks on if there are significant tracking losses
                    % Where fish length changes too umchframes in which change in the fish length > threshold
                    frame_check = find(deviation_in_len>2);

                    % TEST FAILED
                    if length(frame_check)> 4
                        discard_index{counter} = [num_trials_per_il,rep];
                        counter = counter + 1;
                        X_corrected{il,num_trials_per_il,rep} = [];
                        Y_corrected{il,num_trials_per_il,rep} = [];
                        % test was successful
                    else
                        X_corrected{il,num_trials_per_il,rep} = X_corrected_tmp;
                        Y_corrected{il,num_trials_per_il,rep} = Y_corrected_tmp;
                    end

                end
            end
        end


    end
    disp(['IL = ', num2str(il), ' is completed.'])
end

elpased_time = toc;
fprintf('Elapsed time in min = %0.2f\n',round(elpased_time/60,2))

% Save the body curve data
file_name = char(strcat(fish_name(fish_index),'_TEST_HEAT_MAP.mat'));
save(file_name,'X_corrected','Y_corrected')
disp(['SUCCESS: ', fish_name(fish_index), file_name, ' saved.'])
return

%%
num_trials_per_il = 1;
for rep = 1:3
    figure;
    set(gcf,'color','white')
    set(gca,'LineWidth',1.5,'fontsize',14)
    hold on
    colors = jet(size(Y,2));
    for c = 1:size(Y,2)
        plot(Y_corrected{num_trials_per_il,rep}(:,c)*p2m*100,'LineWidth',2,'Color',[colors(c,:), 0.6])
    end
    title(['Fish:',fish_name{fish_index},...
        ', IL Level:',num2str(il_level),...
        ', Trial:',num2str(fish_luminance_data{il_level,fish_index}(num_trials_per_il).trial_idx),...
        ', Rep:',num2str(rep)],'FontSize',16,'FontWeight','normal')
    xlabel('Frames','FontSize',16)
    ylabel('Postion in cm','FontSize',16)
    c = colorbar;
    colormap(colors)
    c.Ticks = linspace(0,1,size(Y,2)+1)+1/(size(Y,2))/2;
    c.TickLabels = num2cell(1:1:(size(Y,2)+1));
    c.Label.String = 'Body Points';
    c.Label.FontSize = 14;
    ylim([-2.5 2.5])
end


