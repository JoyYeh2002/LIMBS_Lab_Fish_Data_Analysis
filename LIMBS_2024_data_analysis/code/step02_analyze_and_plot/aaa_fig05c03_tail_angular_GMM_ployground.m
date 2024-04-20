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
load(fullfile(abs_path, 'result_GMM_symm_2_components.mat'));

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;

%% Create all-data collectors
%% 2. Gather data

all_lux = [];
for i = 1:num_fish
    fish_name = fishNames{i};

    if i == 1 % Get rid of Hope lux 1, 3, 9
        lux = [0.4, 2, 3.5, 5.5, 7, 9.5, 15, 30, 60, 150, 210];     
    else
        lux = [res(i).luminances.lux];
    end

    all_lux = [all_lux, lux];
end

all_mu01 = [];
all_mu02 = [];

all_sigma01 = [];
all_sigma02 = [];

all_ratio01 = [];
all_ratio02 = [];

%% 3. Loop through data structure to assemble data
for i = 1 : num_fish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminances);

    for il = 1 : num_il_levels
        num_trials = numel(res(i).luminances(il).x_tail);
        if ~isempty(GMM_mu{i, il})
            mu01 = GMM_mu{i, il}(1)';
            sigma01 = GMM_sigma{i, il}(1)';
            ratio01 = GMM_component_ratio{i, il}(1);

            mu02 = GMM_mu{i, il}(2)';
            sigma02 = GMM_sigma{i, il}(2)';
            ratio02 = GMM_component_ratio{i, il}(2);

            % populate into all_data
            all_mu01 = [all_mu01, mu01];
            all_mu02 = [all_mu02, mu02];

            all_sigma01 = [all_sigma01, sigma01];
            all_sigma02 = [all_sigma02, sigma02];

            all_ratio01 = [all_ratio01, ratio01];
            all_ratio02 = [all_ratio02, ratio02];

        else
            continue;
        end
    end
end


%% 4. Start plotting


scatter(all_lux, all_sigma01, 'magenta');
hold on
scatter(all_lux, all_sigma02, 'green');
legend()


