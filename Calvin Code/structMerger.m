load("newStruct.mat")
trial = cell2mat(group(3).fishData(11).xClean02Tr)
rep = cell2mat(group(3).fishData(11).xClean02Rep);
orientation = [-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1];

c = [trial; rep; orientation]
group(3).fishData(11).merged = c;
save('newStruct.mat', 'group', '-mat')

