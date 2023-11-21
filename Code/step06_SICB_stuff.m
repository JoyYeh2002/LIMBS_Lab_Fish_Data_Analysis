% Cache 02: SICB data loader
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\SICB_2023\Code\data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\AAA_playground\';

master = load([abs_path, 'fishBodeMasterStruct.mat']);
shuttle = load([abs_path, 'shuttle.mat']);
sig_param = load([abs_path, 'sigParams.mat']);
sigfit = load([abs_path, 'sigFitStruct.mat']);

doris_leg = load([abs_path, 'legacy_fish_structs/dorisBigStruct.mat']);

doris_leg2 = load([abs_path, 'legacy_fish_structs/dorisElevenCleanBode.mat']);

