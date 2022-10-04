# -*- coding: utf-8 -*-
"""
Created on Mon Feb 28 22:54:26 2022
New Features: Y-Position Plots
@author: Joy

"E:\Summer_2021\LIMBS_Lab\Data\Kun_New\conductivity_1\trial01_il_0"

Main functions of this file:
    1. Read various folders from the current directory and create class objects
    for different experimental conditions
    2. Keep lists of organized raw data
    3. Shift data based on statistical needs
    4. Perform FFT to generate bode gain and phase plots
    5. Generate various plots (time domain, gain, phase, condition avgs, etc.)
"""

import csv
import pandas as pd
import glob
import xlrd

import os
from os import listdir
import re
import numpy as np
import matplotlib.pyplot as plt

import statistics as stat



""" 1. Read folders and create experimental condicion objects"""

# Helper: Put directory search result in a specified dir list.
# sample call:
# rootdir = r"E:\Summer_2021\LIMBS_Lab\Data\Hope_New"
# dir_list = []
# str_target = ("conductivity_1", "conductivity_2", "conductivity_3");
# returns: populates dir_list with folders ending with stiring target(s)
def listFolders(rootdir, dir_list, str_target):
    for file in os.listdir(rootdir):
        d = os.path.join(rootdir, file)
        if ((os.path.isdir(d)) and (str(d).endswith(str_target))):
            dir_list.append(d)

# Note_Sheet class: objects that describes a conductivity folder.
class Note_Sheet:

    def __init__(self, d = "", idx = -1, table = []):
        self.note_dir = d # where the notes folder is
        self.sheet_idx = idx # the sheet # within the excel file
        self.table = table # the 2D array of trial#/il/head info from that trial condition
        
# Helper: reads the note sheet next to the conductivity folders, then create a note_sheet object of the idx th condition.
# Returns a new note sheet object
def create_note_sheet(input_dir, idx):
 
    # Open .xls and get table for this condition
    os.chdir(input_dir)
    for file in glob.glob('*fish_notes.xls'):
        continue
    
    xls = pd.ExcelFile(file)
    note_df_raw = pd.read_excel(xls, sheet_name = (idx))  
    note_df = note_df_raw.iloc[6:27, 1:3].values
  
    return Note_Sheet(input_dir, idx, note_df)

# Conductivty_Condition class: objects that stores date within conductivity folder.
class Conductivity_Condition:

    def __init__(self, cond = -1, num_trials = -1, note_sheet = None, \
                 dir_list = [], dark_trials = [], light_trials = []):
        self.conductivity = cond # conductivity number
        self.num_trials = len(dir_list)
        self.notes = note_sheet # the note_sheet object
        self.dir_list = dir_list # the folder of all trials
      
        self.dark_trials = []
        self.light_trials = []
       
    # print representation
    def __repr__(self):
        return f'Conductivity Condition: cond = {self.conductivity}, num_trials = {self.num_trials}\n'

# Trial_Condition class: stores each trial's raw data
class Trial_Condition:

    # constuctor 
    def __init__(self, d = "", cond = -1, il = -1, test_id = -1, rep_id = -1, \
                 h = 0, bucket = None):
        self.data_dir = d # name of this directory
        self.conductivity = cond
        self.illumination = il
        self.test_id = test_id
        self.rep_id = rep_id # so far, the rep id's are all 1 because we don't split into 3's
        self.head_direction = h # -1 for left, +1 for right
        
        self.data_bucket = bucket # [new] use the data bucket struct
    
# All the data and validity related to one trial folder       
class Data_Bucket:
    
    # constructor: includes x, s, and y info structs
    def __init__(self, x_data = None, y_data = None, s_data = None):
        self.x = x_data;
        self.y = y_data;
        self.s = s_data;
        
    # print representation
    def __repr__(self):
        return f'this bucket has = {vars(self)} \n'
    
# A specific column in the data file. Might be x-pos, y-pos, etc.
class Data_Object:
    # constructor: includes x, s, and y info structs
    def __init__(self, data = [], v = False):
        self.data = data;
        self.validity = v;
        
    # print representation
    def __repr__(self):
        return f'{vars(self)} \n'

# Helper: Read the specified columns from the DLC data .csv file and organize this empty bucket.
def read_and_fill_data_bucket(curr_dir, target, this_bucket, skip_rows_amount, x_col, y_col, s_col):
    os.chdir(curr_dir)
    
    for file in glob.glob(target):
        continue
    
    DLC_file = file;
    df = pd.read_csv(DLC_file, usecols=[x_col, y_col, s_col], skiprows = skip_rows_amount, names = ["x", "y", "s"])
    x_pos = df.x.tolist()
    y_pos = df.y.tolist()
    s_pos = df.s.tolist()
    
    x_adj = adjust_x(s_pos, x_pos);
    s_adj = adjust_s(s_pos);
    
    this_bucket.x = Data_Object(x_adj, False);
    this_bucket.y = Data_Object(y_pos, False);
    this_bucket.s = Data_Object(s_adj, False);
    
    return this_bucket

# Helper: Adjust the x-positions by subtracting x's mean distance from that of the shuttle.
# Returns the adjusted x.
# [!] The actual adjustment method could change.
def adjust_x(shuttle_pos, x_pos):
    s_mean = stat.mean(shuttle_pos) # find mean value of shuttle to match starting point
    x_mean = stat.mean(x_pos) # find mean value of x
    
    # Calculate and subtract differences to bring x_pos and shuttle_pos to the same lv.
    offset = x_mean - s_mean
    x_new = [x - offset - s_mean for x in x_pos]
    x_new = [0.1 * x for x in x_new] # Max amplitude should be +/- 5cm
    return x_new

# Helper: Adjust the s-positions by subtracting x's mean distance from that of the shuttle.
# Returns the adjusted s.
def adjust_s(shuttle_pos):
    s_mean = stat.mean(shuttle_pos) # find mean value of shuttle to match starting point
    s_new = [s - s_mean for s in shuttle_pos]
    s_new = [0.1 * s for s in s_new] # DLC pixel to meter scale is 0.1
    return s_new

# Helper: populate the current conductivity with dark and light trial folder lists
# cond_objects_list: has all conds
# tag: ranges from 1, 2, 3, ... 
# d: dir list
def populate_curr_conductivity(cond_objects_list, cond_tag, d, target, skip_rows_amount, x_col, y_col, s_col): # cond_tag = 2
    counter = 0;
    for j in cond_objects_list[cond_tag].dir_list: # j = [1, 19] folders here.
       
        cond_obj = cond_objects_list[cond_tag]; 
        head = cond_obj.notes.table[counter + 1, 1] # get the current head direction info
        il_tag = int(j[-1]) # the last char of trial folder name is the il tag
        test_id = counter + 1; # one-based
        rep_id = -1; # [!] the rep isn't implemented yet. Now we only look at 60s trials.
        
        # create and append each trial object to the ".trials" list depending on il levels.
        if il_tag == 0:
            this_bucket = Data_Bucket();
            this_bucket = read_and_fill_data_bucket(j, target, this_bucket, \
                                                  skip_rows_amount, x_col, y_col, s_col);

            this_trial = Trial_Condition(j, cond_tag, int(il_tag), test_id, rep_id, head, this_bucket);
            cond_obj.dark_trials.append(this_trial);
        
        else:
            this_bucket = Data_Bucket();
            this_bucket = read_and_fill_data_bucket(j, target, this_bucket, \
                                                  skip_rows_amount, x_col, y_col, s_col);

            this_trial = Trial_Condition(j, cond_tag, int(il_tag), test_id, rep_id, head, this_bucket);
            cond_obj.light_trials.append(this_trial);
            
        counter += 1;
        
    cond_obj.num_trials = len(d);
    
# Helper: check if DLC tracknig of the shuttle is correct
def check_shuttle_validity(trial_object, shuttle_input_csv):
   
    # grab trial info
    c = trial_object.conductivity
    h = trial_object.head_direction;
    il = trial_object.illumination;
    t = trial_object.test_id;
    
    # get the model shuttle_input
    file = shuttle_input_csv
    stle_df = pd.read_csv(file, names=["shuttle_input"])
    shuttle = stle_df.shuttle_input.to_list()
    DLC_to_data_conversion_scale = 250 # DLC pixel to input data has a 2000/10 = 200 scale.
   
    shuttle_input = [a * DLC_to_data_conversion_scale * h for a in shuttle]
    
    # get the DLC-tracked shuttle data
    this_shuttle = trial_object.data_bucket.s.data;
    
    # element-wise subtraction
    arr1 = np.array(shuttle_input) #disregard the last 19 elements to lengths the same
    start = 5 # pick a machine delay starting point from 0 to 19 frames.
    end = len(this_shuttle) + start - 20
    arr2 = np.array(this_shuttle[start: end])
    
    # mean squared error approach
    MSE_int = np.square(np.subtract(arr2, arr1)).mean();
    MSE_str = "{:.3f}".format(MSE_int);
    
    # plotting and compare shutte input and actual tracked shuttle
    # fig = plt.figure()
   
   # plt.plot(shuttle_input, color = 'red', linewidth = 3, alpha = 0.6)
   # plt.plot(this_shuttle, color = 'blue', linewidth = 1.2, alpha = 0.6)
    
    if (MSE_int < 3.2):
        trial_object.s_is_valid = True;
      #  warning = "PASSED"
    else:
        trial_object.s_is_valid = False;
      #  warning = "FAILED"
        
    #plt.title(str(c) + ' ' + str(h) + ' ' + str(il) + ' ' + str(t) + ' ' + MSE_str + ' ' + warning)
    #plt.pause (0.1);
    
    print("Cond = " + str(c) + ". Il = " + str(il) + ". Test id = " + str(t) + ". Diff = " + MSE_str)

# Helper: plot the current trial object
def plot_curr_trial(save_fig, fig_save_dir, cond, il, trial_object, h):

    # get the data from trial_object
    x_pos = trial_object.data_bucket.x.data
    s_pos = trial_object.data_bucket.s.data
    trial_idx = trial_object.test_id
    s_validity = trial_object.s_is_valid
    
    # set axes
    start, step = 0, 0.04
    stop = step * (len(x_pos) - 2)
    time = np.arange(start, stop+step, step)
  
    # plotting the figure
    fig = plt.figure()
  
    #plt.subplots(tight_layout = True); # New Fix for axes disappearance issue
    ax = fig.add_axes([0.15,0.15,0.7,0.7])
    ax.set_xlim(0, 72)
    ax.set_ylim(-15, 15)
    
     # set plot info
    ax.set_xlabel('Time (s)')
    ax.set_ylabel('Position (cm)')
    
    trial_idx_padded = "{:0>2d}".format(trial_idx);
   
    ax.set_title('Cond = ' + cond_str_dict[cond] + ', Il = ' + il_str_dict[il]\
              + ', Trial#' + trial_idx_padded + \
                  ', H_Dir = ' + head_dir_dict[h] + \
                      ", " + validity_dict[s_validity]);
    # flip +/- for shuttle based on h.
    
    s_color_dict = {-1: 'red', 1: 'green'}
    ax.plot(time, s_pos, color = s_color_dict[h] , linewidth=2, alpha = 0.3, label = "shuttle position")
    ax.plot(time, x_pos, label = "x position")
    ax.legend(loc="upper right")
   
    # Save the figure if needed
    if save_fig == True:
        
        # plt_curr_dir = "\hope_new_plot_tests\time_domain"
        plt_title = '\cond_' + str(cond_to_plot) + '_il_' + str(this_il) + '_trial_' + \
            trial_idx_padded + "_h_" + head_dir_dict[h] + "_" + str(s_validity)
        print(plt_title)
        fig_save_dir = root_dir + fig_save_dir + plt_title
         
        plt.xlim(0, 72)
        plt.ylim(-12, 12)
        plt.savefig(fig_save_dir);
                    
    plt.pause(0.1)
   
# Helper: plot the y positions
def plot_curr_y(save_fig, fig_save_dir, cond, il, trial_object, h):

    # get the data from trial_object
    y_pos = trial_object.data_bucket.y.data
    trial_idx = trial_object.test_id
  
    # set axes
    start, step = 0, 0.04
    stop = step * (len(y_pos) - 2)
    time = np.arange(start, stop+step, step)
  
    # plotting the figure
    fig = plt.figure()
  
    #plt.subplots(tight_layout = True); # New Fix for axes disappearance issue
    ax = fig.add_axes([0.15,0.15,0.7,0.7])
    ax.set_xlim(0, 72)
    ax.set_ylim(-15, 15)
    
     # set plot info
    ax.set_xlabel('Time (s)')
    ax.set_ylabel('Y-Position (cm)')
    
    trial_idx_padded = "{:0>2d}".format(trial_idx);
   
    ax.set_title('Cond = ' + cond_str_dict[cond] + ', Il = ' + il_str_dict[il]\
              + ', Trial#' + trial_idx_padded + \
                  ', H_Dir = ' + head_dir_dict[h]);
    # flip +/- for shuttle based on h.
    
    s_color_dict = {-1: 'red', 1: 'green'}
    ax.plot(time, y_pos, color = s_color_dict[h] , linewidth=2, alpha = 0.3, label = "y position")
    ax.legend(loc="upper right")
   
    # Save the figure if needed
    if save_fig == True:
        
        # plt_curr_dir = "\hope_new_plot_tests\time_domain"
        plt_title = '\cond_' + str(cond_to_plot) + '_il_' + str(this_il) + '_trial_' + \
            trial_idx_padded + "_h_" + head_dir_dict[h]
        print(plt_title)
        fig_save_dir = root_dir + fig_save_dir + plt_title
         
        plt.xlim(0, 72)
        plt.ylim(40, 130)
        plt.savefig(fig_save_dir);
                    
    plt.pause(0.1)
    
""" MAIN (Updated 04/04/22) """
fish_name = 'Hope'; # [Input] fish name

# Specify the actual meanings of each tag
cond_str_dict = {1: "40 uS/cm", 2: "200 uS/cm", 3: "1000 uS/cm"}
il_str_dict = {0: "dark", 1: "light"}
head_dir_dict = {-1: "L", 1: "R"}
validity_dict = {True: "PASSED", False: "FAILED"}

data_file_name_target = "*_10000.csv"
skip_rows_amount = 3;
x_col = 1;
y_col = 2;
s_col = 4;

num_conductivity = len(cond_str_dict); # [Input] number of conductivities total
num_illumination = len(il_str_dict); # [Input] number of illuminataion levels
num_trials = 20; # [Input] How many trials are in each folder?
meter_to_pixel_scalar = 2000;

 # fish_col_num = 2; # [Input] which column in the .csv is the x-position?
 # shuttle_col_num = 5; # [Input] which column is the shuttle position?
 
time_offset = 0; # [Input] Edit Later: how many frames is the machine delay offset? 
nan_spline_threshold = 130; # [Input] How many frames of NAN to smooth out with spline?
 
 # rootdir = r"E:\Summer_2021\LIMBS_Lab\Data\Kun_New" # [Input] data directory name. add "r" at the front
root_dir = r"E:\Summer_2021\LIMBS_Lab\Data\Hope_New"
condition_category_name_list = []
exp_conditions_str_target = ("conductivity_1", "conductivity_2", "conductivity_3");
listFolders(root_dir, condition_category_name_list, exp_conditions_str_target)
num_conductivity = len(condition_category_name_list) # calculate the number of conductivities
 
 # create "num_conditions" amount of empty trial dir lists. Conductivity_Condition objects stored in the list.
cond_objects_list = dict();

# Create conductivity condition list
for i in range(num_conductivity):
    curr_note_sheet = create_note_sheet(root_dir, i)
    cond_objects_list[i+1] = Conductivity_Condition(i+1, num_trials, curr_note_sheet, []) # [!] the dictionary is 1-based!! Might create issues.
      
# populate each Conductivity_Condition object with respective trial_dir_lists
for i in condition_category_name_list:
    cond_tag = os.path.basename(i)[-1] # reads 1, 2, or 3
    d = []
    il_str_target = ("_0", "_1")
    listFolders(i, d, il_str_target) # put the matching trial folders in d
    cond_objects_list[int(cond_tag)].dir_list = d
    populate_curr_conductivity(cond_objects_list, int(cond_tag), d, data_file_name_target, skip_rows_amount, x_col, y_col, s_col);
     
trial_object = cond_objects_list[2].light_trials[0];
print(trial_object)

shuttle_input_csv = root_dir + '\sos_joy_R.csv'
# check_shuttle_validity(trial_object, shuttle_input_csv)

loop_all = True; # Go through all trials
plot_all = True; # Plot out all
save_figures = True; # Save the plots
fig_save_dir = "\hope_new_plot_tests/validity";
y_fig_save_dir = "\hope_new_plot_tests/y_plots";

if (loop_all == True):
    for cond_to_plot in range(1, num_conductivity + 1):
        for this_il in range(0, 2):
            #print("Now plotting cond = " + str(cond_to_plot) + ", il = " + str(this_il))
            
            for k in range(1,11): # p is the trial# to plot
            
                c = cond_objects_list[cond_to_plot]
                this_data = Trial_Condition()
                if (this_il == 0):
                    this_data = c.dark_trials[k - 1]; # this is bc light trials is 0-based
                else:
                    this_data = c.light_trials[k - 1]; # this is bc light trials is 0-based
            
                # [NEW]
                check_shuttle_validity(this_data, shuttle_input_csv)

                if (this_il == 0):
                    this_data = c.dark_trials[k - 1]; # light trial array is 0-based
                else:
                    this_data = c.light_trials[k - 1]; 
                
                h = this_data.head_direction
                
                '''
                if (plot_all == True):
                    plot_curr_trial(save_figures, fig_save_dir, cond_to_plot, this_il, this_data, h);
                print("Trial# = ", str(this_data.test_id), ", h = ", str(h)) 
              '''
                if (plot_all == True):
                    plot_curr_y(save_figures, y_fig_save_dir, cond_to_plot, this_il, this_data, h);
                print("Trial# = ", str(this_data.test_id), ", h = ", str(h)) 
              
            print("This Condition Done. ");

'''
if __name__ == "__main__":
    main()
'''

   
   
    
    
   
