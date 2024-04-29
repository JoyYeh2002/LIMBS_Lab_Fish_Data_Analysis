% Playground for plotting the GMM parameters
% Fitting seems ok on the log scale
% Load in data structures as 5 x 14 x 2 arrays for GMM_mu and GMM_sigma
% These are for tail point angular velocities across all trials / all
% frames within a specitic illuminance level of the fish

% Objective: see if the mu and sigma has a trend


close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05c03_tail_GMM_params\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end


%% 2. Load the full body struct and tail FFT struct
res = load(fullfile(abs_path, 'result_GMM_kurtosis.mat'), 'res').res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;

%% Create all-data collectors
%% 2. Gather lux data for fitting distributions
all_lux = [];

% Fish lux cell array 5 x 14
fish_lux = cell(5, 1);

mu01 = cell(5, 1);
mu02 = cell(5, 1);

sigma01 = cell(5, 1);
sigma02 = cell(5, 1);

kurtosis = cell(5, 1);
std_ratio = cell(5, 1);

% all_ratio01 = [];
% all_ratio02 = [];

%% 3. Loop through data structure to assemble data
for i = 1 : num_fish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminances);

    count = 1;
    for il = 1 : num_il_levels
        num_trials = numel(res(i).luminances(il).x_tail);
        if ~isempty(res(i).luminances(il).mu)
           
            fish_lux{i, count} = res(i).luminances(il).lux;

            % populate into all_data
            this_data = res(i).luminances(il);
            mu01{i, count} = this_data.mu(1);
            mu02{i, count} = this_data.mu(2);
            sigma01{i, count} = this_data.sigma(1);
            sigma02{i, count} = this_data.sigma(2);

            kurtosis{i, count} = this_data.kurtosis;
            std_ratio{i, count} = this_data.std_ratio;

           
            count = count + 1;
            
            % all_ratio01 = [all_ratio01, ratio01];
            % all_ratio02 = [all_ratio02, ratio02];

        else
            continue;
        end
    end
end



%% 4. Start plotting
% Convert cell arrays to numeric arrays and remove empty elements

% Define colors for each row
colorMap = lines(5); % Using the 'lines' colormap

% Scatter plot with different colors for each row
figure;
hold on;
field_name = 'kurtosis'; % [INPUT] Change these between 'kurtosis', 'sigma_01', 'sigma_02'
y_axis_lim = [0, 8]; % [INPUT] change the y-axis limite here (kurtotis has [0, 8], sigmas have [0, 400])

for i = 1:5

    lux_arr = [fish_lux{i, :}];
    data_arr = eval(['[' field_name '{i, :}]']);
    data_arr = movmean(data_arr, 3);
    plot(lux_arr, data_arr, '-', 'Color', colorMap(i, :), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'MarkerFaceColor', colorMap(i, :));
end

title(sprintf('Tail Velocity GMM %s vs. Illuminance', field_name));
legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5', 'Location', 'best');

hold off;

% Set labels and title
grid on; 
xlabel('lux');
ylabel(field_name);

%%  --------- lux ticks in log scale ----------------
lux_ticks = [0.4, 2, 3.5, 7, 9.5, 15, 30, 60, 210];
xticks(lux_ticks);
xticklabels(lux_ticks);
xlim([0, 220]);
ylim(y_axis_lim);
set(gca, 'XScale', 'log'); 
% ---------------------------------------------------



