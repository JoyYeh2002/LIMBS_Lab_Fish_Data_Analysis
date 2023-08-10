import os
import shutil

fish_folder_path = 'F:\LIMBS_Hard_Drive\Doris_Stuff'
fish_name = 'Doris'

def rename(input):
    parts = input.split('_')
    new_string = f"{parts[1]}_{parts[2]}_{parts[0]}_{parts[3]}"
    return new_string

def copy_file(source_path, destination_folder, new_filename):
    os.makedirs(destination_folder, exist_ok=True)
    destination_path = os.path.join(destination_folder, new_filename)
    shutil.copy(source_path, destination_path)

def get_trial_name(input):
    return input.split('\\')[-1]

def get_subfolders(path):
    subfolders = [f.path for f in os.scandir(path) if f.is_dir()]
    return subfolders

def get_filenames(path):
    filenames = [f.name for f in os.scandir(path) if f.is_file()]
    return filenames

def main():
    trial_folder_list = get_subfolders(fish_folder_path)
    complete_path_list = []
    trial_folders = []

    for path in trial_folder_list:
        complete_path_list.append(get_subfolders(path + '\\plot-poses')[0])

    for folder in trial_folder_list:
        trial_folders.append(get_trial_name(folder))


    for index, element in enumerate(complete_path_list):
        plot_one = 'plot-likelihood.png'
        plot_two = 'trajectory.png'
        temp_list = get_filenames(element)
        likelihood_destination = fish_folder_path + '\\' + 'plots\\' + 'likelihood'
        trajectory_destination = fish_folder_path + '\\' + 'plots\\' + 'trajectory'
        name = f"{fish_name}_{rename(trial_folders[index])}.png"

        if plot_one in temp_list:
            source = element + '/' + plot_one
            copy_file(source, likelihood_destination, name)
            print(f"Copied {name} to {likelihood_destination}, {index + 1} of {len(trial_folders)}")

        if plot_two in temp_list:
            source = element + '/' + plot_two
            copy_file(source, trajectory_destination, name)
            print(f"Copied {name} to {trajectory_destination}, {index + 1} of {len(trial_folders)}")

    print('\nFile movement completed')


if __name__ == "__main__":
    main()