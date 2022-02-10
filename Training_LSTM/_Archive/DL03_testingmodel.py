"""# Libararies"""

import torch
import torch.nn as nn
from torch.utils.data import DataLoader, IterableDataset

# calculate train time, writing train data to files etc.
import os
import logging
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from random import randint
from pathlib import Path
from scipy import signal
from scipy.signal import find_peaks
from scipy.interpolate import interp1d
from sklearn.preprocessing import MinMaxScaler

"""# Dataset"""

class CoolDataset(IterableDataset):

    def __init__(self, dir_path: str, seq_length: str, input_size: str, samples_per_events: str, convolution=True):

        # Opens .csv file and read headers
        # Needs to decide what inputs to have and work on HS or FO

        super().__init__()

        self.files = tuple(Path(dir_path).glob("**/*.csv"))
        self.seq_length = seq_length
        self.input_size = input_size
        self.SAMPLES_PER_EVENT = samples_per_events
        self.window = signal.gaussian(8, std=3)
        self.convolution = convolution
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
        df, fname = self.read_file(self.files[self.file_nr])  # could be cached so you dont read it anew every iteration
        events = df[df['FO'] == 1]  # true where an event occurs, false everywhere else, use as mask

        if events.shape[0] > 0:
            if self._sample_nr < self.SAMPLES_PER_EVENT:
                # just give back the current event again, with different sampling, until we have generated
                # SAMPLES_PER_EVENT such samples

                event_frame = events.iloc[self.event_in_file].name
                indx_data, input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                self._sample_nr += 1
            else:
                self.event_in_file += 1  # work on the next event in this file
                self._sample_nr = 0  # reset for the next event

                # check whether we are done with this file
                # otherwise we return the next event on the beginning of the next iteration
                if self.event_in_file >= len(events):
                    self.file_nr += 1
                    # If there still are files to run, it resets the variables
                    if self.file_nr < len(self.files):
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
                    indx_data, input_data, output_data = self.sample_seq_around_event_frame(df, event_frame)
                    self._sample_nr += 1
        else:
            logging.info("No events detected")
            self.file_nr += 1
            self.event_in_file = 0
            self._sample_nr = 0
            return next(self)

        return indx_data, input_data, output_data, fname

    def sample_seq_around_event_frame(self, df, event_idx):

        if event_idx >= 4:
            start_idx = event_idx - randint(4, self.seq_length / 7.5)
            if start_idx > 0:
                end_idx = start_idx + self.seq_length
                if end_idx <= len(df):
                    indx = df.iloc[start_idx:end_idx]['ID']
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    indx = df.iloc[start_idx:end_idx]['ID']
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
            elif start_idx <= 4:
                start_idx = event_idx
                end_idx = start_idx + self.seq_length
                indx = df.iloc[start_idx:end_idx]['ID']
                input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                output = df.iloc[start_idx:end_idx]['FO']
                if end_idx <= len(df):
                    indx = df.iloc[start_idx:end_idx]['ID']
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']
                elif end_idx > len(df):
                    end_idx = len(df)
                    start_idx = end_idx - self.seq_length
                    indx = df.iloc[start_idx:end_idx]['ID']
                    input = df.iloc[start_idx:end_idx, 1:self.input_size + 1]
                    output = df.iloc[start_idx:end_idx]['FO']

        if self.convolution:
            output = signal.convolve(output, self.window, mode='same')
        input = self.scaler.fit_transform(input)
        indx = indx.to_numpy()

        assert input.shape[0] == output.shape[0] == self.seq_length
        return torch.tensor(indx),torch.tensor(input), torch.tensor(output)

    def read_file(self, f):
        df = pd.read_csv(open(f, "r"))
        fname = os.path.basename(f)
        if fname[0:2] == 'RT':
            df = df.drop([#'ID',
                          'class',
                          #'RTOE_X', 'RTOE_Y', 'RTOE_Z', 'V_RTOE_X', 'V_RTOE_Y', 'V_RTOE_Z',
                          #'RHLX_X', 'RHLX_Y', 'RHLX_Z', 'V_RHLX_X', 'V_RHLX_Y', 'V_RHLX_Z',
                          #'RHEE_X', 'RHEE_Y', 'RHEE_Z', 'V_RHEE_X', 'V_RHEE_Y', 'V_RHEE_Z',
                          'RPMT5_X', 'RPMT5_Y', 'RPMT5_Z', 'V_RPMT5_X', 'V_RPMT5_Y', 'V_RPMT5_Z'
                          ], axis=1)
        elif fname[0:2] == 'LT':
            df = df.drop([#'ID',
                          'class',
                          #'LTOE_X', 'LTOE_Y', 'LTOE_Z', 'V_LTOE_X', 'V_LTOE_Y', 'V_LTOE_Z',
                          #'LHLX_X', 'LHLX_Y', 'LHLX_Z', 'V_LHLX_X', 'V_LHLX_Y', 'V_LHLX_Z',
                          #'LHEE_X', 'LHEE_Y', 'LHEE_Z', 'V_LHEE_X', 'V_LHEE_Y', 'V_LHEE_Z',
                          'LPMT5_X', 'LPMT5_Y', 'LPMT5_Z', 'V_LPMT5_X', 'V_LPMT5_Y', 'V_LPMT5_Z',
                          ], axis=1)
        return df, fname

"""# Model"""

class Network(nn.Module):
    # TO DO
    def __init__(self, config):
        super(Network, self).__init__()

        # Model construct Configuration
        self.batch_size  = config.batch_size
        self.num_layers  = config.num_layers
        self.hidden_size = config.hidden_size
        self.device      = config.device

        self.lstm = nn.LSTM(config.input_size, self.hidden_size, self.num_layers, dropout=config.drop_out, batch_first=True,
                            bidirectional=True)
        self.linear = nn.Linear(self.hidden_size * 2, config.output_size, bias=True)
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

"""# Peak Detection"""

class peak_detection:

    def peak_comp(self, annotated, predicted, filename):
        true_detect = np.abs(annotated -predicted) < 2.4
        temp_idx = np.where(true_detect)
        pred_peaks_close_to_true = true_detect.sum()
        pred_peaks_not_close_to_true = len(true_detect) - true_detect.sum()
        dist = np.abs(annotated-predicted)
        # if (len(temp_idx) != 0):
        #    dist = [np.abs(annotated - np.array(predicted)[i.astype(int)]) for i in temp_idx]
        # elif (len(temp_idx) == 0):
        #     print(f"{filename}_Events Outside of 16ms")
        #     dist = np.abs(annotated - predicted)
        #     return dist, 0, len(predicted)

        return dist,pred_peaks_close_to_true,pred_peaks_not_close_to_true

    def eval_prediction(self, y_pred, y_true, filename, i, plot=False, shift=0):

        # sdist = []
        # Interpolating the predicted signal
        y_pred_interp1d = interp1d(self.x, y_pred)
        y_pred_final = y_pred_interp1d(self.xnew)

        try:

            # peak_detection of true
            peakind_true,_ = find_peaks(y_true.numpy(), height=0.5)
            if peakind_true.size == 0:
                y_temp = np.where(y_true.numpy()>0.9)
                    # ((y_true.numpy() > 0.9).nonzero(as_tuple=True)[0])
                peakind_true = np.array([y_temp[0][0]])

            # peak_detection of predicted
            peakind,_ = find_peaks(y_pred_final, height=0.5)
            peakind_pred = [x for x in peakind]
            peakind_pred = self.xnew[peakind_pred]

            if peakind_pred.size == 0:
                y_temp_pred = np.where(y_pred_final > 0.9)
                peakind_pred = np.array([y_temp_pred[0][0]])


            # if any(peakind_pred) and any(peakind_true):
            #     for k in peakind_pred:
            #         if plot:
            #             plt.axvline(x=k)

            sdist, freq_tpr, freq_fpr = self.peak_comp(self, peakind_true, peakind_pred, filename[:-4])

            # sdist.append(self.peak_comp(self, peakind_true, [k + shift for k in peakind_pred], filename[:-4]))

            # if plot:
            #     plt.plot(y_pred)
            #     plt.plot(y_true)
            #     plt.title(f"True vs Predicted {filename[:-4]} - {i}")
            #     axes = plt.gca()
            #     axes.set_xlim([0, y_true.shape[0]])
            #     my_file = f"{filename[:-4]} - {i}"
            #     plt.savefig(os.path.join(self.png_dir, my_file))
            #     plt.close()

        except:
            print(f"{filename} - No Events")
            sdist = [np.abs(peakind_true-peakind_true)-1]
            freq_tpr = -1
            freq_fpr = -1

        return sdist,freq_tpr,freq_fpr, filename

    def plot_stats(self, sdist):
        plt.title("Distance Error Histogram")
        plt.hist(sdist, 100, [0, 100])
        filtered = [k for k in sdist if k >= 0]

        def off_by(threshold, filtered):
            ob = [k for k in filtered if k <= threshold]
            nel = float(len(filtered))
            print("<= %d: %f" % (threshold, len(ob) / float(nel)))

        print("Error distribution:")
        off_by(1, filtered)
        off_by(3, filtered)
        off_by(5, filtered)
        off_by(10, filtered)
        off_by(60, filtered)
        print("Mean distance: %f" % (np.mean(filtered)))
        mean_distance = [np.mean(filtered)]
        plt.legend(mean_distance)
        plt.savefig(os.path.join(self.png_dir, f"{self.globaliter}_distance_error.png"))
        plt.close()
        return np.mean(filtered)

"""# Trainer"""

class Trainer:

    def __init__(self, model, config, name):

        # System configuration
        self.device = config.device

        # Model Construction
        self.model = Network(config).float()
        self.model.load_state_dict(model)
        self.model.to(self.device)
        print(self.model)

        # Peak detection and Evaluation
        self.eval_prediction = peak_detection.eval_prediction
        self.peak_comp = peak_detection.peak_comp
        self.plot_stats = peak_detection.plot_stats
        self.x = np.linspace(0, 150, num=150, endpoint=True)
        self.xnew = np.linspace(0, 150, num=512, endpoint=True)
        self.weight = np.ones(150) * 12
        self.output_dir = config.output_dir
        self.png_dir = config.png_dir
        self.roc_dir = config.roc_dir
        self.globaliter = 0

        # DataLoader
        self.test_loader = DataLoader(
            CoolDataset(r'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Data\iteration3\Test'f"/{name}",
                        config.seq_length, config.input_size, config.samples_per_event, convolution=True),
            batch_size=config.batch_size, drop_last=True,
            shuffle=False)

    def test(self):
        self.model.eval()
        with torch.no_grad():
            for indx, data, target, filename in self.test_loader:

                error_dist = []
                error_tpr =  []
                error_fpr =  []
                error_filename = []
                filename_end = []

                data, target = data.to(self.device), target.to(self.device)
                predictions = self.model(data.float())
                pred = torch.sigmoid(predictions)
                correct_indx_positive = pred[target > 0.5]  # Should have batch_size * 1's
                correct_indx_negative = pred[target <= 0.5]  # Should have (batch_size*seq_length-batch_size) * 0'
                TPR_temp = len(correct_indx_positive[correct_indx_positive > 0.5]) / len(correct_indx_positive)
                TNR_temp = len(correct_indx_negative[correct_indx_negative <= 0.5]) / len(correct_indx_negative)
                TPR_temp = TPR_temp * 100
                TNR_temp = TNR_temp * 100


                for i in range(0, pred.shape[0]):

                    dist,tpr,fpr,filename_temp = (self.eval_prediction(self, pred[i], target[i], filename[i], i))
                    error_fpr.append(fpr)
                    error_tpr.append(tpr)
                    error_filename.append(filename_temp)

                    for j in range(0, len(dist)):
                        error_dist.append(dist[j])
                        filename_end.append(filename[i])

                dist_file = np.column_stack((error_dist, filename_end))
                fpr_tpr_file = np.column_stack((error_fpr, error_tpr, error_filename))

                mean_dist = self.plot_stats(self, error_dist)

                mean_name_dist = "mean_dist"

                mean_dist_file = np.column_stack((mean_dist, mean_name_dist))
                dist_file = np.row_stack((dist_file, mean_dist_file))

                df_dist = pd.DataFrame(data=dist_file, )
                df_fpr_tpr = pd.DataFrame(data=fpr_tpr_file, )
                df_dist.columns = ["Error in distance", "FileName"]
                df_fpr_tpr.columns = ["FPR","TPR", "FileName"]

                df_dist.to_csv(os.path.join(self.output_dir, f"{self.globaliter}_error_file.csv"))
                df_fpr_tpr.to_csv(os.path.join(self.output_dir, f"{self.globaliter}_fpr_tpr_file.csv"))


                self.globaliter += 1
            return TPR_temp, TNR_temp
"""# Main"""

class Config:

    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

def main(loaded_model, model_config, name):

    trainer = Trainer(loaded_model, model_config, name)
    TPR_temp, TNR_temp = trainer.test()
    return TPR_temp, TNR_temp

if __name__ == '__main__':

    # if torch.cuda.is_available():
    #     device = torch.device("cuda")
    #     print("Running on the GPU")
    # else:
    device = torch.device("cpu")
    print("Running on the CPU")

    # Calling Models
    names    = ["MidFoot","ForeFoot","Heel"]

    model_dir = r'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\LSTM\TO\3markers\HLXTOEHEE\v1\models'
    model_files = tuple(Path(f"{model_dir}/CheckPoint_DS").glob("**/*pt"))

    for name in names:
      ROC_Final = []
      TPR_Final = []
      TNR_Final = []
      roc_dir       = f"{model_dir}/roc_TS/{name}/"
      if not os.path.exists(roc_dir):
          os.makedirs(roc_dir)

      for i in range(len(model_files)):
          model_name = os.path.basename((model_files[i]))
          loaded_model = torch.load(f"{model_dir}/CheckPoint_DS/" + model_name,map_location=torch.device(device))

          output_dir    = f"{model_dir}/evaluation/{name}/Results_final{i}/csv"
          png_dir       = f"{model_dir}/evaluation/{name}/Results_final{i}/png"
          print(model_name)

          # Directory Settings
          if not os.path.exists(output_dir):
              os.makedirs(output_dir)
              os.makedirs(png_dir)

          model_config = Config(

              # General Configuration
              device=device,
              batch_size=32,
              seq_length=150,
              samples_per_event=1,
              output_size=1,

              # LSTM
              input_size=18,
              hidden_size=512,
              num_layers=10,
              lr=0.001,
              drop_out=0.3,

              output_dir=output_dir,
              png_dir=png_dir,
              roc_dir=roc_dir
          )

          # ROC =
          TPR, TNR = main(loaded_model, model_config, name)
          TPR_Final.append(TPR)
          TNR_Final.append(TNR)
      ROC = pd.DataFrame({f"TPR_{name}": TPR_Final, f"TNR_{name}": TNR_Final})
      ROC.to_csv(os.path.join(roc_dir, f"{name}_ROC.csv"), index=False)

