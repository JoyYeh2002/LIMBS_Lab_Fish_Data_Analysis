% Joy Yeh Eigen Luminance Tail Motion Analysis
% tali snap shots but save three videos side by side
% modified from "generateTailSnapshotsVideo.m"
%
% With the saved .mat file of all tracked data, create snapshots in a jet()
% color map in a video
% [05/18]
function generateTailSnapshotsVideoParallel(dir, frame_gaps)

output_title_start = regexp(dir, 'trial.*', 'match', 'once');
output_title_start = strrep(output_title_start, '\', '');

% frame_gaps = 1;

    close all;

    tic;

    dataDir = [dir, '\']; % [NEW] Use this for population analysis
    
    load([dataDir, 'tracked_data.mat']);
    x = x_tracked;
    y = y_tracked;
    
    x1 = x_tracked(251 : 251+499, :);
    x2 = x_tracked(251+500 : 251+999, :);
    x3 = x_tracked(251+1000 : 251+1499, :);

    y1 = y_tracked(251 : 251+499, :);
    y2 = y_tracked(251+500 : 251+999, :);
    y3 = y_tracked(251+1000 : 251+1499, :);

    n = size(x, 2);

    % Create a video writer object
    vidFilename = ['../outputs/', output_title_start, '_tail_snapshots_parallel.avi'];
    vOut = VideoWriter(vidFilename);
    vOut.FrameRate = 60;
    open(vOut);

    % Set the dimension limits
    figure;

    % Set the figure size to 640 by 570 pixels for three vertically stacked panels
    set(gcf, 'Position', [400, 0, 640, 570]);

    seq = 1:frame_gaps:500;
    numElem = numel(seq);
    cp = jet(numElem);
    axis off

     subtractString = '..\data\hope_population_analysis\';
        
        % Subtract the string from the directory name
        remainingText = strrep(dir, subtractString, ''); 
        fixed_str = strrep(strrep(remainingText, '\', ' '), '_', ' ');
       

        % Write the current frame to the video
        frame = getframe(gcf);
        writeVideo(vOut, frame);


    % Loop through frames and generate snapshots for all three panels simultaneously
    for i = seq
        % Plot the first panel
        subplot(3, 1, 1);
        ylim([1, 190]);
        set(gca, 'YDir', 'reverse');
        xlim([1, 640]);
        hold on;
        plot(x1(i, :), y1(i, :), 'color', cp((i-1)/frame_gaps + 1, :), 'linewidth', 3);
        title(sprintf('%s REP 1: Frame %d', fixed_str, i));

        % Plot the second panel
        subplot(3, 1, 2);
        ylim([1, 190]);
        set(gca, 'YDir', 'reverse');
        xlim([1, 640]);
        hold on;
        plot(x2(i, :), y2(i, :), 'color', cp((i-1)/frame_gaps + 1, :), 'linewidth', 3);
        title(sprintf('REP 2: Frame %d', i));

        % Plot the third panel
        subplot(3, 1, 3);
        ylim([1, 190]);
        set(gca, 'YDir', 'reverse');
        xlim([1, 640]);
        hold on;
        plot(x3(i, :), y3(i, :), 'color', cp((i-1)/frame_gaps + 1, :), 'linewidth', 3);
        title(sprintf('REP 3: Frame %d', i));

        % Write the current frame to the video
        frame = getframe(gcf);
        writeVideo(vOut, frame);
    end

    close(vOut);
    disp(['SUCCESS: ', dir, '_tail_snapshots_parallel.avi is saved.']);

    toc;
end
