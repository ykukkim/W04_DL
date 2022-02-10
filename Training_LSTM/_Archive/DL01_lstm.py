"""# Libraries"""

#Importing Libraries and Packages
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, IterableDataset
from torch.utils.tensorboard import SummaryWriter

# calculate train time, writing train data to files etc.
import os
import logging
import pandas as pd
import numpy as np
import time
from collections import defaultdict
from sklearn.preprocessing import MinMaxScaler
from pathlib import Path
from random import randint
from scipy import signal
import matplotlib.pyplot as plt

import pdb

"""# Dataset"""

# Data split
class Split_data:

    def __init__(self, dir_path: str, frequency: str, random_seed: str):

        self.directory = dir_path
        self.random_seed = random_seed
        self.frequency = frequency

    def splitset(self, split_ratio, shuffle_dataset=True):
        train_idx = defaultdict(list)
        val_idx = defaultdict(list)
        indices_idx = 0
        ratio_idx = 0
        for root, subdir, files in os.walk(self.directory):
            if "desktop.ini" in files: files.remove('desktop.ini')
            dataset_size = len(files)
            if dataset_size > 0:
                indices = list(range(dataset_size - 1))
                split = int(np.floor(split_ratio[ratio_idx] * len(files)))
                for i in range(self.frequency):
                    if shuffle_dataset:
                        np.random.shuffle(indices)
                    train_idx[indices_idx].append(indices[split:])
                    val_idx[indices_idx].append(indices[:split])
                ratio_idx += 1
                indices_idx += 1

        return train_idx, val_idx

class CoolDataset(IterableDataset):

    def __init__(self, dir_path: str, input_size: str, seq_length: str, samples_per_events: str, indices, trainorval: str,
                 convolution=True):

        super().__init__()
        self.files = tuple(Path(dir_path).glob("**/*.csv"))
        self.indices = indices
        self.seq_length = seq_length
        self.input_size = input_size
        self.SAMPLES_PER_EVENT = samples_per_events
        self.window = signal.gaussian(8, std=3)
        self.convolution = convolution
        self.trainorval  = trainorval
        self.scaler = MinMaxScaler(feature_range=(0,1))

        assert seq_length % 2 == 0, "Please pass an even seq length"

    def __iter__(self):

        # Initialise Counter for events and files
        self.file_nr = 0
        self.event_in_file = 0
        self._sample_nr = 0

        return self

    def __next__(self):
        # Reads the current file and looks for event
        df, fname = self.read_file(self.files[self.indices[self.file_nr]])  # could be cached so you dont read it anew every iteration
        if len(df) >= self.seq_length:
            events = df[df["FO"] == 1]
            if df['class'][0] == 3 and self.trainorval == 'train':
                self.SAMPLES_PER_EVENT = 4

            if events.shape[0] > 0:

                if self._sample_nr < self.SAMPLES_PER_EVENT:
                    # just give back the current event again, with different sampling, until we have generated
                    # SAMPLES_PER_EVENT such samples
                    event_frame = events.iloc[self.event_in_file].name
                    input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                    self._sample_nr += 1

                elif self._sample_nr == self.SAMPLES_PER_EVENT:

                    self.event_in_file += 1  # work on the next event in this file
                    self._sample_nr = 0  # reset for the next event

                    # check whether we are done with this file
                    # otherwise we return the next event on the beginning of the next iteration
                    if self.event_in_file >= len(events):
                        self.file_nr += 1
                        # If there still are files to run, it resets the variables
                        if self.file_nr < len(self.indices):
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
                        input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                        self._sample_nr += 1

            else:
                logging.info("No events detected")
                self.file_nr += 1
                self.event_in_file = 0
                self._sample_nr = 0
                return next(self)

        else:
            logging.info("data length is too short")
            self.file_nr += 1
            self.event_in_file = 0
            self._sample_nr = 0
            return next(self)
        return input_data, output_data

    def sample_seq_around_event_frame(self, df, event_idx):
        if event_idx >= 4:
            start_idx = event_idx - randint(4, self.seq_length / 7.5)
            if start_idx > 0:
                end_idx = start_idx + self.seq_length
                if end_idx <= len(df):
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
            elif start_idx <= 4:
                start_idx = event_idx
                end_idx = start_idx + self.seq_length
                input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                output = df.iloc[start_idx:end_idx]['FO']
                if end_idx <= len(df):
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']

        if self.convolution:
            output = signal.convolve(output, self.window, mode='same')
        #  Standardising the input
        input = self.scaler.fit_transform(input)
        
        assert input.shape[0] == output.shape[0] == self.seq_length
        return torch.tensor(input), torch.tensor(output)

    def read_file(self, f):
        df = pd.read_csv(open(f, "r"))
        fname = os.path.basename(f)
        if fname[0:2] == 'RT':
            df = df.drop(['ID',
                          # 'class',
                           'RTOE_X', 'RTOE_Y', 'RTOE_Z', 'V_RTOE_X', 'V_RTOE_Y', 'V_RTOE_Z',
                          # 'RHLX_X', 'RHLX_Y', 'RHLX_Z', 'V_RHLX_X', 'V_RHLX_Y', 'V_RHLX_Z',
                          # 'RHEE_X', 'RHEE_Y', 'RHEE_Z', 'V_RHEE_X', 'V_RHEE_Y', 'V_RHEE_Z',
                          'RPMT5_X', 'RPMT5_Y', 'RPMT5_Z', 'V_RPMT5_X', 'V_RPMT5_Y', 'V_RPMT5_Z'
                          ], axis=1)
        elif fname[0:2] == 'LT':
            df = df.drop(['ID',
                          # 'class',
                           'LTOE_X', 'LTOE_Y', 'LTOE_Z', 'V_LTOE_X', 'V_LTOE_Y', 'V_LTOE_Z',
                          #'LHLX_X', 'LHLX_Y', 'LHLX_Z', 'V_LHLX_X', 'V_LHLX_Y', 'V_LHLX_Z',
                          #'LHEE_X', 'LHEE_Y', 'LHEE_Z', 'V_LHEE_X', 'V_LHEE_Y', 'V_LHEE_Z',
                          'LPMT5_X', 'LPMT5_Y', 'LPMT5_Z', 'V_LPMT5_X', 'V_LPMT5_Y', 'V_LPMT5_Z',
                          ], axis=1)
        return df, fname

"""# Model"""

class Network(nn.Module):
    # TO DO
    def __init__(self, config,hidden_size,num_layers,drop_out):
        super(Network, self).__init__()

        # Model construct Configuration
        self.batch_size  = config.batch_size
        self.num_layers  = num_layers
        self.hidden_size = hidden_size
        self.device      = config.device

        self.lstm = nn.LSTM(config.input_size, hidden_size, num_layers, dropout=drop_out, batch_first=True,
                            bidirectional=True)
        self.linear = nn.Linear(hidden_size * 2, config.output_size, bias=True)
        torch.nn.init.xavier_uniform_(self.linear.weight)

    def forward(self, x):
        hidden, cell = self.init_hidden()
        out, _ = self.lstm(x, (hidden, cell))
        logits = self.linear(out)

        return logits[:, :, -1]

    def init_hidden(self):
        weight = next((self.parameters())).data
        hidden, cell = (weight.new(self.num_layers * 2, self.batch_size, self.hidden_size).zero_().to(self.device),
                        weight.new(self.num_layers * 2, self.batch_size, self.hidden_size).zero_().to(self.device))
        return hidden, cell

"""# Early Stop"""

class EarlyStopping:
    """Early stops the training if validation loss doesn't improve after a given patience."""

    # def __init__(self, patience: str,, delta: str, Name: str, verbose=False):
    def __init__(self, config, patience: str, delta: str, Name: str, verbose=False, ):
        """
        Args:
            patience (int): How long to wait after last time validation loss improved.
                            Default: 7
            verbose (bool): If True, prints a message for each validation loss improvement. 
                            Default: False
            delta (float): Minimum change in the monitored quantity to qualify as an improvement.
                            Default: 0
        """
        self.patience = patience
        self.verbose = verbose
        self.counter = 0
        self.best_score = None
        self.early_stop = False
        self.val_loss_min = np.Inf
        self.delta = delta
        self.path_dir = config.isdirectory_result
        self.type_ICTO = config.type_ICTO
        self.noofmarkers = config.noofmarkers
        self.combination = config.combination
        self.name = Name

    def __call__(self, val_loss, TPR_CP, TNR_CP, model, config,name):

        score = -val_loss

        if self.best_score is None:
            self.best_score = score
            self.save_checkpoint(val_loss, model)

            ROC = pd.DataFrame({'TPR_MF': pd.Series(TPR_CP[0]), 'TNR_MF': pd.Series(TNR_CP[0]),
                                'TPR_FF': pd.Series(TPR_CP[1]), 'TNR_FF': pd.Series(TNR_CP[1]),
                                'TPR_HS': pd.Series(TPR_CP[2]), 'TNR_HS': pd.Series(TNR_CP[2])})
            isExist_csv = os.path.exists(f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/models/csv/")
            if not isExist_csv:
              os.makedirs(f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/models/csv/")
            # csv file save
            ROC.to_csv(f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/models/csv/{name}-ROC.csv",index=False)

        elif score < self.best_score + self.delta:
            self.counter += 1
            print(f'EarlyStopping counter: {self.counter} out of {self.patience}\n')
            if self.counter >= self.patience:
                self.early_stop = True
        else:
            self.best_score = score
            self.save_checkpoint(val_loss, model)
            self.counter = 0
            ROC = pd.DataFrame({'TPR_MF': pd.Series(TPR_CP[0]), 'TNR_MF': pd.Series(TNR_CP[0]),
                                'TPR_FF': pd.Series(TPR_CP[1]), 'TNR_FF': pd.Series(TNR_CP[1]),
                                'TPR_HS': pd.Series(TPR_CP[2]), 'TNR_HS': pd.Series(TNR_CP[2])})

            ROC.to_csv(f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/models/csv/{name}-ROC.csv", mode='a', header=False, index=False)

    def save_checkpoint(self, val_loss, model):
        '''Saves model when validation loss decrease.'''
        filepath = f"{self.path_dir}/{self.type_ICTO}/{self.noofmarkers}/{self.combination}/v1/models/CheckPoint/"
        isExist = os.path.exists(filepath)
        if not isExist:
            os.makedirs(filepath)
        if self.verbose:
            print(f'Validation loss decreased ({self.val_loss_min:.6f} --> {val_loss:.6f}).  Saving model\n')
            torch.save(model.state_dict(), os.path.join(filepath, f"{self.name}-FScheckpoint.pt"), _use_new_zipfile_serialization=False)

        self.val_loss_min = val_loss

"""# Training and Validation"""

class Trainer:

    def __init__(self, hidden_size, num_layers, drop_out, lr, epochs, config):

        # System configuration
        self.validation_split = config.validation_split
        self.log_interval = config.log_interval
        self.isdirectory = config.isdirectory
        self.device = config.device
        self.seed = config.seed

        # Model Construction
        self.input_size = config.input_size
        self.batch_size = config.batch_size
        self.seq_length = config.seq_length
        self.samples_per_event = config.samples_per_event
        self.lr = lr

        self.model = Network(config, hidden_size, num_layers, drop_out).to(self.device)
        self.model = self.model.to(self.device)
        print(self.model)

        # Optimizer and Loss
        self.optimizer = optim.Adam(self.model.parameters(), lr=lr)
        self.criterion = nn.BCEWithLogitsLoss(pos_weight=config.weight_factor).to(self.device)

        # Initialise the early_stopping object
        self.name = f"TO-{hidden_size}-HS-{num_layers}-NL-{lr}-LR-{drop_out}-DO"
        self.early_stopping = EarlyStopping(config, patience=model_config.patience, verbose=True,
                                            delta=model_config.delta, Name=self.name)
        print(self.name)

        # DataLoader
        dataset = Split_data(self.isdirectory, epochs, torch.manual_seed(self.seed))
        self.train_idx, self.val_idx = dataset.splitset(self.validation_split)
        self.train_loader = defaultdict(list)
        self.val_loader = defaultdict(list)

        # Tensorboard
        self.globaliter = 0
        train_log_dir = f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/logs/train/{self.name}"
        val_log_dir = f"{config.isdirectory_result}/{config.type_ICTO}/{config.noofmarkers}/{config.combination}/v1/logs/val/{self.name}"
        self.train_summary_writer = SummaryWriter(train_log_dir)
        self.val_summary_writer = SummaryWriter(val_log_dir)

    def train(self, epoch):
    
        self.model.train()
        TPR_internal_final = defaultdict(list)
        TNR_internal_final = defaultdict(list)
        loss_final = defaultdict(list)
        start_train = time.time()
        subdir_idx  = 0
        with self.train_summary_writer:
            for root, subdir, files in os.walk(self.isdirectory):
                if "desktop.ini" in files: files.remove('desktop.ini')
                if len(files) >0:
                    train_loader = DataLoader(
                        CoolDataset(root, self.input_size, self.seq_length, self.samples_per_event,
                                    self.train_idx[subdir_idx][epoch], 'train'), batch_size=self.batch_size,
                        drop_last=True, shuffle=False)
                    for batch_idx, (data, target) in enumerate(train_loader):
                        self.optimizer.zero_grad()
                    data, target = data.to(self.device), target.to(self.device)
                    predictions = self.model(data.float()).to(self.device)
                    loss = self.criterion(predictions.float(), target.float())
                    loss.backward()

                    self.optimizer.step()
                    pred = torch.sigmoid(predictions.detach())
                    correct_indx_positive = pred[target > 0.5]  # Should have batch_size * 1's
                    correct_indx_negative = pred[target <= 0.5]  # Should have (batch_size*seq_length-batch_size) * 0'

                    TPR_internal = len(correct_indx_positive[correct_indx_positive > 0.5]) / len(correct_indx_positive)
                    TNR_internal = len(correct_indx_negative[correct_indx_negative <= 0.5]) / len(correct_indx_negative)
                    TPR_internal = TPR_internal * 100
                    TNR_internal = TNR_internal * 100

                    TPR_internal_final[subdir_idx].append(TPR_internal)
                    TNR_internal_final[subdir_idx].append(TNR_internal)
                    loss_final[subdir_idx].append(loss.item())
                    self.globaliter += 1

                    if batch_idx % self.log_interval == 0:
                        self.train_summary_writer.add_scalar('Loss', loss.item(), self.globaliter)

                    subdir_idx += 1

            return loss_final, TPR_internal_final, TNR_internal_final, (time.time() - start_train)
    
    def val(self, epoch):
        self.model.eval()
        TPR_internal_final_val = defaultdict(list)
        TNR_internal_final_val = defaultdict(list)
        val_loss_final = defaultdict(list)
        subdir_idx_val = 0
        start_time_val = time.time()
        with self.val_summary_writer:
            with torch.no_grad():
                for root, subdir, files in os.walk(self.isdirectory):
                    if "desktop.ini" in files: files.remove('desktop.ini')
                    if len(files) > 0:
                        val_loader = DataLoader(
                            CoolDataset(root, self.input_size, self.seq_length, self.samples_per_event,
                                        self.val_idx[subdir_idx_val][epoch], 'val'), batch_size=self.batch_size,
                            drop_last=True, shuffle=False)
                        for batch_idx, (data, target) in enumerate(val_loader):
                            self.optimizer.zero_grad()

                            data, target = data.to(self.device), target.to(self.device)
                            predictions = self.model(data.float())

                            val_loss = self.criterion(predictions.float(), target.float())
                            pred = torch.sigmoid(predictions.detach())
                            correct_indx_positive = pred[target > 0.5]  # Should have batch_size * 1's
                            correct_indx_negative = pred[
                                target <= 0.5]  # Should have (batch_size*seq_length-batch_size) * 0'
                            TPR_internal_val = len(correct_indx_positive[correct_indx_positive > 0.5]) / len(
                                correct_indx_positive)
                            TNR_internal_val = len(correct_indx_negative[correct_indx_negative <= 0.5]) / len(
                                correct_indx_negative)
                            TPR_internal_val = TPR_internal_val * 100
                            TNR_internal_val = TNR_internal_val * 100

                            TPR_internal_final_val[subdir_idx_val].append(TPR_internal_val)
                            TNR_internal_final_val[subdir_idx_val].append(TNR_internal_val)
                            val_loss_final[subdir_idx_val].append(val_loss.item())

                            self.val_summary_writer.add_scalar('val_loss', val_loss.item(), self.globaliter)
                        subdir_idx_val += 1
            return val_loss_final, TPR_internal_final_val, TNR_internal_final_val, (
                        time.time() - start_time_val), self.name

"""# Hyperparmeter Setting"""

def main(hparam, model_config):
    for lr in hparam['lr']:
        for hidden_size in hparam['hidden_size']:
            for num_layers in hparam['num_layers']:
                for drop_out in hparam['drop_out']:
                    for epochs in hparam['epochs']:
                        trainer = Trainer(hidden_size, num_layers, drop_out, lr, epochs, model_config)
                        TPR = dict()
                        TNR = dict()
                        for epoch in range(epochs):
                            loss_train, TPR_train, TNR_train, train_time = trainer.train(epoch)
                            print('\nEpoch: {}\n'
                                  'Loss_MF: {:.6f}\tTPR_MF: {:.2f}\tTNR_MF: {:.2f}\n'
                                  'Loss_FF: {:.6f}\tTPR_FF: {:.2f}\tTNR_FF: {:.2f}\n'
                                  'Loss_HS: {:.6f}\tTPR_HS: {:.2f}\tTNR_HS: {:.2f}\n'
                                  'LossALL: {:.6f}\tTPRALL: {:.2f}\tTNRALL: {:.2f}\n''Time: {:.2f} '.format(epoch, np.mean(loss_train[0]), np.median(TPR_train[0]),np.median(TNR_train[0]),
                                                                                                           np.mean(loss_train[1]), np.median(TPR_train[1]), np.median(TNR_train[1]),
                                                                                                           np.mean(loss_train[2]), np.median(TPR_train[2]),np.median(TNR_train[2]),
                                                                                                           np.mean(loss_train[0]+loss_train[1]+loss_train[2]),np.median(TPR_train[0]+TPR_train[1]+TPR_train[2]),np.median(TNR_train[0]+TNR_train[1]+TNR_train[2]),
                                                                                                           train_time))

                            val_loss, TPR[epoch], TNR[epoch], val_time, name = trainer.val(epoch)
                            print('\nEpoch:{}\n'
                                  'ValLoss_MF: {:.6f}\tTPR_MF: {:.2f}\tTNR_MF: {:.2f}\n'
                                  'ValLoss_FF: {:.6f}\tTPR_FF: {:.2f}\tTNR_FF: {:.2f}\n'
                                  'ValLoss_HS: {:.6f}\tTPR_HS: {:.2f}\tTNR_HS: {:.2f}\n'
                                  'ValLossALL: {:.6f}\tTPRALL: {:.2f}\tTNRALL: {:.2f}\n''Time: {:.2f} '.format(epoch, np.mean(val_loss[0]), np.median(TPR[epoch][0]),np.median(TNR[epoch][0]),
                                                                                                           np.mean(val_loss[1]), np.median(TPR[epoch][1]), np.median(TNR[epoch][1]),
                                                                                                           np.mean(val_loss[2]), np.median(TPR[epoch][2]),np.median(TNR[epoch][2]),
                                                                                                           np.mean(val_loss[0]+val_loss[1]+val_loss[2]), np.median(TPR[epoch][0]+TPR[epoch][1]+TPR[epoch][2]),np.median(TNR[epoch][0]+TNR[epoch][1]+TNR[epoch][2]),
                                                                                                           val_time))
                            trainer.early_stopping(np.mean(val_loss[0]+val_loss[1]+val_loss[2]), TPR[epoch], TNR[epoch], trainer.model, model_config,name)
                            if trainer.early_stopping.early_stop:
                                print("Early stopping")
                                break

"""# Main"""

class Config:

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

if __name__ == '__main__':

    if torch.cuda.is_available():
        device = torch.device("cuda")
        print("Running on the GPU")
    else:
        device = torch.device("cpu")
        print("Running on the CPU")

    model_config = Config(
        device=device,
        # Early Stop
        patience=20,
        delta=0.01,
        log_interval=100,
        # Dataset Configuration
        validation_split=[0.075, 0.25, 0.065],
        seed=253,
        samples_per_event=1,
        output_size=1,
        # Weight factor
        weight_factor=torch.tensor(11),
        # Directory
        isdirectory       = r"C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Data\iteration4\Train",
        isdirectory_result= r"C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\LSTM",
        type_ICTO   = r"TO",
        noofmarkers = r"2markers",
        combination = r"HLXHEE",
        # Model Consturction
        input_size=12,
        batch_size=1,
        seq_length=150,
    )

    hparam = {
        'hidden_size': [256,512,1024],
        'num_layers': [2,5,10],
        'drop_out': [0.3],
        'lr': [0.001,0.0001],
        'epochs': [150],
    }

    main(hparam, model_config)

