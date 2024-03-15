%% step17_DB_Curvature_FFT_refactor.m
% Interface with DB's code on clean tags only: joy_data3.m, joy_data4.m

%% function joy_data3
%% Re-interpolate the entire fish body to 23 points in a 4-th order curve
%% Updated 03/12/2024

clear
close all
clc
format short

%% 1. Define paths
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
fig_out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\Curvature_Joy\';

if ~exist(fig_out_path, 'dir')
    mkdir(fig_out_path);
end

%% 2. Load Structs
head_file = load([abs_path, 'clean_data_head_point.mat']);
h = head_file.h;
body_file = load([abs_path, 'raw_data_full_body.mat']); % All the raw + cleaned data labels for Bode analyis
b = body_file.all_fish;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;
num_body_pts = 12;
num_interp_pts = 23;
p2m = 0.0002;
num_frames = 500;

num_ils = zeros(1, num_fish);
fish_lux = cell(num_fish, 14);
fish_data = cell(num_fish, 14);

%% 3. Loop through all fish to populate new data structure
for i = 1:num_fish

    % Get lux 
    lux = [];
    for il = 1 : numel(h(i).data)
        lux(il) = h(i).data(il).luxMeasured;
    end

    % Get data
    data = b(i).luminance;
    num_ils(i) = length(data);
    for j = 1:length(data)
        fish_data{i,j} = data(j).data;
        fish_lux{i, j} = lux(j);
    end
end

%% 4. Create curvature struct
for i = 1 % : 5
    
    h =  findobj('type','figure');
    n_fig = length(h);
    discard_index = cell(1,1);
    counter = 1;

    tic

    for il  = 1 : num_ils(i)

        for trial_idx = 1:size(fish_data{i, il}, 2)

            v = fish_data{i, il}(trial_idx).valid_both;

            for rep = 1:3
                x_field = strcat('x_rot_rep',num2str(rep)); % create x_rep1, x_rep2,...
                y_field = strcat('y_rot_rep',num2str(rep)); % create y_rep1, y_rep2,...

                if isfield(fish_data{i, il}(trial_idx),(x_field)) % check if the field exists

                    % 500 x 12 double
                    X = fish_data{i, il}(trial_idx).(x_field);
                    Y = fish_data{i, il}(trial_idx).(y_field);

                    % fixing at second body point
                    X = X - X(:,2);
                    Y = Y - Y(:,2);

                    % fix body point #2 to (0,0), but head point would be
                    % negative
                    if v(rep) == 0
                        X_corrected_tmp = [];
                        Y_corrected_tmp = [];

                    % Only calculate it when it's valid
                    elseif v(rep) == 1
                        X_corrected_tmp = nan(num_frames,12);
                        Y_corrected_tmp = nan(num_frames,12);

                        % All the arc lengths throughout the 500 frames
                        Arc_Len = nan(num_frames,1);

                        % 500 frames total
                        for k = 1:num_frames
                            
                            % Fit to 4th order
                            p = polyfit(X(k,:),Y(k,:),4);
                            px = linspace(X(k,1), X(k,end), num_interp_pts);
                            py = polyval(p,px);

                            % Call the arc length helper function
                            [arclen, ~] = arclength(px,py,'spline');
                            Arc_Len(k) = arclen;

                            py2 = interp1(px,py,X(k,:));
                            X_corrected_tmp(k,:) = X(k,:) - X(k,2);
                            Y_corrected_tmp(k,:) = py2(:) - py2(2);

                            plot_animation = 1;
                            if plot_animation == 1
                                figure(n_fig+1)
                                clf
                                set(gcf,'color','white')
                                set(gca,'LineWidth',1.5,'fontsize',14)

                                hold on
                                % plot(X(k,:),Y(k,:),'r.-','LineWidth',2,'MarkerSize',20)
                                plot(X_corrected_tmp(k,:),Y_corrected_tmp(k,:),'g.-','LineWidth',2,'MarkerSize',20)

                                plot(px,py,'k-','LineWidth',1.5,'MarkerSize',15)
                                axis([-100 400 -250 250])
                                box off
                                time_str = sprintf('%0.2f',round((k-1)/25,2));
                                arc_len_str = sprintf('%0.2f',round(Arc_Len(k),2)*p2m*100);
                                title(['Fish:',fishNames{i},...
                                    ', IL Level:',num2str(il),...
                                    ', Trial:',num2str(fish_data{i, il}(trial_idx).trial_idx),...
                                    ', Rep:',num2str(rep),...
                                    ', Time = ',time_str, ' s, Length = ',arc_len_str, ' cm'],'FontSize',16,'FontWeight','normal')
                                
                                grid on
                                pause(1e-10)
                            end
                        end


                        n_fig = n_fig+1;
                        mean_fish_length = mean(Arc_Len(1:20)*p2m*100,'all','omitnan'); % mean of first n=20 frames
                        deviation_in_len = abs(Arc_Len*p2m*100-mean_fish_length)/mean_fish_length*100;

                        % Checks on if there are significant tracking losses
                        % Where fish length changes too umchframes in which change in the fish length > threshold
                        frame_check = find(deviation_in_len>2);

                        % TEST FAILED
                        if length(frame_check)> 4
                            discard_index{counter} = [trial_idx,rep];
                            counter = counter + 1;
                            X_corrected{il,trial_idx,rep} = [];
                            Y_corrected{il,trial_idx,rep} = [];
                            % test was successful
                        else
                            X_corrected{il,trial_idx,rep} = X_corrected_tmp;
                            Y_corrected{il,trial_idx,rep} = Y_corrected_tmp;
                        end

                    end
                end
            end


        end
        disp(['IL = ', num2str(il), ' is completed.'])
    end
end

elpased_time = toc;
fprintf('Elapsed time in min = %0.2f\n',round(elpased_time/60,2))

% Save the body curve data
file_name = char(strcat(fishNames(i),'_TEST_HEAT_MAP.mat'));
save(file_name,'X_corrected','Y_corrected')
disp(['SUCCESS: ', fishNames(i), file_name, ' saved.'])
return

%%
trial_idx = 1;
for rep = 1:3
    figure;
    set(gcf,'color','white')
    set(gca,'LineWidth',1.5,'fontsize',14)
    hold on
    colors = jet(size(Y,2));
    for c = 1:size(Y,2)
        plot(Y_corrected{trial_idx,rep}(:,c)*p2m*100,'LineWidth',2,'Color',[colors(c,:), 0.6])
    end
    title(['Fish:',fishNames{i},...
        ', IL Level:',num2str(il),...
        ', Trial:',num2str(fish_data{i, il}(trial_idx).trial_idx),...
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


