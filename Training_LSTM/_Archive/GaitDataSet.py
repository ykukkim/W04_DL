## Taking data from csv Files
# 1587(training/val) + 145(test) = 1732 trials in total
# Training/Val is randomly splitted into ratio of 9:1, test-set is fixed. Unseen pateient, with both legs being in the
# following group: Forefoot, Midfoot, and Heel
# Training/Val has folder seperately for each group.
# Validation set is to have the same number of dataset from each group.
# Forefoot has the smallest data-set, thus it is oversampled.

import torch
from torch.utils.data import IterableDataset, DataLoader
import os
import logging
import numpy as np
import pandas as pd
from collections import defaultdict
from pathlib import Path
from random import randint
from scipy import signal

class Split_data:

    def __init__(self, dir_path: str, random_seed: str):

        self.directory = dir_path
        self.random_seed = random_seed

    def __len__(self):
        return len(self.files)

    def splitset(self, split_ratio, shuffle_dataset=True):
        train_indices = defaultdict(list)
        val_indices = defaultdict(list)
        indices_idx = 0
        ratio_idx = 0
        for root, subdir, files in os.walk(self.directory):
            if "desktop.ini" in files: files.remove('desktop.ini')

            dataset_size = len(files)
            if dataset_size > 0:
                indices = list(range(dataset_size))
                split = int(np.floor(split_ratio[ratio_idx] * len(files)))
                if shuffle_dataset:
                    np.random.shuffle(indices)
                train, val = indices[split:], indices[:split]
                train_indices[indices_idx].append(train)
                val_indices[indices_idx].append(val)
                ratio_idx += 1
                indices_idx += 1
        return train_indices, val_indices

class CoolDataset(IterableDataset):

    def __init__(self, dir_path: str, seq_length: str, input_size: str, samples_per_events: str, indices,
                 convolution=False):

        super().__init__()
        self.files = tuple(Path(dir_path).glob("**/*.csv"))
        self.indices = indices
        self.seq_length = seq_length
        self.input_size = input_size
        self.SAMPLES_PER_EVENT = samples_per_events
        self.window = signal.gaussian(8, std=3)
        self.convolution = convolution

        assert seq_length % 2 == 0, "Please pass an even seq length"

    def __iter__(self):

        # Initialise Counter for events and files
        self.file_nr = 0
        self.event_in_file = 0
        self._sample_nr = 0

        return self

    def __next__(self):
        # Reads the current file and looks for event
        df, fname = self.read_file(
            self.files[self.indices[0][self.file_nr]])  # could be cached so you dont read it anew every iteration
        events = df[df["FS"] == 1]
        if df['class'][0] == 3:
            self.SAMPLES_PER_EVENT = 4

        if events.shape[0] > 0:

            if self._sample_nr < self.SAMPLES_PER_EVENT:
                # just give back the current event again, with different sampling, until we have generated
                # SAMPLES_PER_EVENT such samples
                event_frame = events.iloc[self.event_in_file].name
                class_not, input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                self._sample_nr += 1

            elif self._sample_nr == self.SAMPLES_PER_EVENT:

                self.event_in_file += 1  # work on the next event in this file
                self._sample_nr = 0  # reset for the next event

                # check whether we are done with this file
                # otherwise we return the next event on the beginning of the next iteration
                if self.event_in_file >= len(events):
                    self.file_nr += 1
                    # If there still are files to run, it resets the variables
                    if self.file_nr < len(self.indices[0]):
                        logging.info("File is complete. Going to new file...")
                        self.event_in_file = 0
                        self._sample_nr = 0
                        return next(self)
                    else:
                        # processed the last file, we are done
                        logging.info("File is complete. All files done. Stopping...")
                        raise StopIteration
                elif self.event_in_file < len(events):
                    event_frame = events.iloc[self.event_in_file].name
                    class_not, input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                    self._sample_nr += 1

        else:
            logging.info("No events detected")
            self.file_nr += 1
            self.event_in_file = 0
            self._sample_nr = 0
            return next(self)

        return class_not, input_data, output_data

    def sample_seq_around_event_frame(self, df, event_idx):
        if event_idx >= 4:
            start_idx = event_idx - randint(4, self.seq_length / 4)
            if start_idx > 0:
                end_idx = start_idx + self.seq_length
                if end_idx <= len(df):
                    class_not = torch.tensor(df.iloc[start_idx:end_idx]['class'].values)
                    input = torch.tensor(df.iloc[start_idx:end_idx, 1:self.input_size + 1].values)
                    output = torch.tensor(df.iloc[start_idx:end_idx]['FS'].values)
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    class_not = torch.tensor(df.iloc[start_idx:end_idx]['class'].values)
                    input = torch.tensor(df.iloc[start_idx:end_idx, 1:self.input_size + 1].values)
                    output = torch.tensor(df.iloc[start_idx:end_idx]['FS'].values)
            elif start_idx <= 4:
                start_idx = event_idx
                end_idx = start_idx + self.seq_length
                class_not = torch.tensor(df.iloc[start_idx:end_idx]['class'].values)
                input = torch.tensor(df.iloc[start_idx:end_idx, 1:self.input_size + 1].values)
                output = torch.tensor(df.iloc[start_idx:end_idx]['FS'].values)
                if end_idx <= len(df):
                    class_not = torch.tensor(df.iloc[start_idx:end_idx]['class'].values)
                    input = torch.tensor(df.iloc[start_idx:end_idx, 1:self.input_size + 1].values)
                    output = torch.tensor(df.iloc[start_idx:end_idx]['FS'].values)
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    class_not = torch.tensor(df.iloc[start_idx:end_idx]['class'].values)
                    input = torch.tensor(df.iloc[start_idx:end_idx, 1:self.input_size + 1].values)
                    output = torch.tensor(df.iloc[start_idx:end_idx]['FS'].values)

        if self.convolution:
            output = signal.convolve(output, self.window, mode='same')

        assert input.shape[0] == output.shape[0] == self.seq_length
        return class_not, input, output

    def read_file(self, f):
        df = pd.read_csv(open(f, "r"))
        fname = os.path.basename(f)

        if fname[0:2] == 'RT':
            df = df.drop(['ID',
                          # 'class',
                          # 'RTOE_X', 'RTOE_Y', 'RTOE_Z', 'V_RTOE_X', 'V_RTOE_Y', 'V_RTOE_Z',
                          # 'RHLX_X', 'RHLX_Y', 'RHLX_Z', 'V_RHLX_X', 'V_RHLX_Y', 'V_RHLX_Z',
                          # 'RHEE_X', 'RHEE_Y', 'RHEE_Z', 'V_RHEE_X', 'V_RHEE_Y', 'V_RHEE_Z',
                          # 'RPMT5_X', 'RPMT5_Y', 'RPMT5_Z', 'V_RPMT5_X', 'V_RPMT5_Y', 'V_RPMT5_Z'
                          ], axis=1)
        elif fname[0:2] == 'LT':
            df = df.drop(['ID',
                          # 'class',
                          # 'LTOE_X', 'LTOE_Y', 'LTOE_Z', 'V_LTOE_X', 'V_LTOE_Y', 'V_LTOE_Z',
                          # 'LHLX_X', 'LHLX_Y', 'LHLX_Z', 'V_LHLX_X', 'V_LHLX_Y', 'V_LHLX_Z',
                          # 'LHEE_X', 'LHEE_Y', 'LHEE_Z', 'V_LHEE_X', 'V_LHEE_Y', 'V_LHEE_Z',
                          # 'LPMT5_X', 'LPMT5_Y', 'LPMT5_Z', 'V_LPMT5_X', 'V_LPMT5_Y', 'V_LPMT5_Z',
                          ], axis=1)
        return df, fname

def main():
    is_directory = r"C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Data\iteration3\Train"
    dataset = Split_data(is_directory, 253)
    train_idx, val_idx = dataset.splitset([0.27, 0.07, 0.08])
    loader = defaultdict(list)
    for root, subdir, files in os.walk(is_directory):
        if "desktop.ini" in files: files.remove('desktop.ini')
        for subdir_idx in range(len(subdir)):
            filepath = os.path.join(root, subdir[subdir_idx])
            loader_indices = DataLoader(
                CoolDataset(filepath, 64, 24, 1, train_idx[subdir_idx], convolution=False), batch_size=8,
                drop_last=True, shuffle=False)
            loader[subdir_idx].append(loader_indices)

    num_Heel = 0
    num_Midfoot = 0
    num_Forefoot = 0
    # dataset = Split_data(is_directory, 253)
    # train_idx, val_idx = dataset.splitset([0.27, 0.07, 0.08])

    for epoch in range(10):
        # loader = defaultdict(list)
        # for root, subdir, files in os.walk(is_directory):
        #     if "desktop.ini" in files: files.remove('desktop.ini')
        #     for subdir_idx in range(len(subdir)):
        #         filepath = os.path.join(root, subdir[subdir_idx])
        #         loader_indices = DataLoader(CoolDataset(filepath, 64, 24, 1, train_idx[subdir_idx], convolution=False),
        #                                     batch_size=8, drop_last=True)
        #         loader[subdir_idx].append(loader_indices)

        for class_idx in range(len(loader)):
            print(class_idx)
            for labels, output in enumerate(loader[class_idx][0]):
                num_Heel += torch.sum(output[0][0][0] == 1)
                num_Midfoot += torch.sum(output[0][0][0] == 2)
                num_Forefoot += torch.sum(output[0][0][0] == 3)

    print(num_Heel)
    print(num_Midfoot)
    print(num_Forefoot)

if __name__ == "__main__":
    main()
