
% Manually input the fish's number, i.e. 1-5 correspondingly;
fishNum = 3;

% Manually input the path to the raw footage, 
% i.e. 'F:\LIMBS_Hard_Drive\Ruby_9\Video';
parentPath = 'F:\LIMBS_Hard_Drive\Doris_11_Il_SOS\Video';

% Manually input the custom folder you want the sorted folders to go, i.e.
% 'F:\LIMBS_Hard_Drive\Ruby_9\Ruby_parsed_videos';
pathToCopy = 'F:\LIMBS_Hard_Drive\Doris_11_Il_SOS\Doris_parsed_videos';

%=========================================================================%
% UNCOMMENT BELOW TO USE:
parseAll(fishNum, parentPath, pathToCopy);
%=========================================================================%

% wrapper function that does all the work, takes the three parameters from
% above
function parseAll(fishNum, parentPath, pathToCopy)
    load("newStruct.mat")
    fishData = group(fishNum).fishData;
    for i = 1:numel(fishData)
        mergedData = fishData(i).merged;
        trial = num2cell(unique(mergedData(1, :)));
        orientation = findOrientation(trial, mergedData)
        trial = cell2mat(trial);
        for j = 1:numel(trial)
            copyTrial(parentPath, pathToCopy, trial(j), orientation(j), i);
            message = ['Copied trial ', num2str(trial(j)), ' successfully'];
            disp(message);
        end
    end
end

% Takes an array of unique trial numbers and the merged data struct,
% returns an array of orientations corresponding to the unique trial
% numbers
function orientationArray = findOrientation(x, merged)
    unique = cell2mat(x);
    orientationArray = [];
    fullTrialArray = merged(1, :);
    fullOrientationArray = merged(3, :);
    for i = 1:numel(unique)
        index = find((fullTrialArray) == unique(i), 1);
        orientationArray(end + 1) = fullOrientationArray(index);
    end
end

% copyTrial() copies the files over to the desired destination w/ corresponding 
% illumination levels and attaching the orientation to the end. 
% IMPORTANT: the variable offset needs to be adjusted based on the 
% non folder files in the path. Set breakpoint at line 52 and read compare
% the variable folderList to the actual folder.
function copyTrial(parentPath, pathToCopy, trialNum, orientation, lvl)
    offset = 2;
    parentFolder = parentPath;
    index = trialNum + offset;
    folderList = dir(parentFolder);

    folderName = strcat(folderList(index).name, '_', num2str(orientation));
    path = strcat(pathToCopy, '\', num2str(lvl));
    
    destinationFolder = fullfile(path, folderName);
    
    entryPath = fullfile(parentFolder, folderList(index).name);
    copyfile(entryPath, destinationFolder);
end


