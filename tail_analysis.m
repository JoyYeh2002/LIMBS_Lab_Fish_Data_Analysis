% Joy Yeh Eigen Luminance Tail Motion Analysis
% analyzeTail.m
%
% After getting tracked_data_x.csv and tracked_data_y.csv with
% labelAndSaveSkeleton(), we load the 1777 * 15 arrays and reconstruct the 
%
% 1) Load the csv files and maybe the original video??
% 2) Plot tracks over the original image and add gradient colors?
%
% [05/01] Runtime:


close all

tic; 

dir = '..\data\hope_low_trial03_il_1\';
load([dir, 'tracked_data.mat']);
x = x_tracked;
y = y_tracked;

n = size(x, 2);
cmap = winter(n);


% Create a video writer object
vid_filename = ['..\data\', dir, 'tail_snapshots.avi'];
 vOut = VideoWriter(vid_filename);
    vOut.FrameRate = 30;
    open(vOut);

% Set the dimension limits
figure;

% Set the figure size to 640 by 190 pixels
set(gcf, 'Position', [400, 400, 640, 190]);
ylim([1, 190]);
set(gca, 'YDir', 'reverse');
xlim([1, 640]);

seq = 1:20:1776;
num_elem = numel(seq);
cp = jet(num_elem);

hold on
for i = seq
    plot(x(i, :), y(i, :), 'color', cp((i-1)/20 + 1, :), 'linewidth', 3);
    %pause(0.2)

    % Update the title
    title(sprintf('%s: Frame %d', dir, i));
    
    % Write the current frame to the video
    frame = getframe(gcf);
    writeVideo(vOut, frame);
end

close(vOut)
disp(['SUCCESS: ', dir, 'tail_snapshots.avi is saved.']);

toc;

