import os
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import itertools
from sklearn.metrics import auc
from matplotlib import markers
from pathlib import Path

if __name__ == '__main__':

    fdir = r'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\LSTM\TO\3markers\HLXTOEHEE\v1\models\csv'
    fdir_eb = r'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\Backup\LSTM\Models\IC\2markers\HLXHEE\v1\models\roc'
    files = tuple(Path(fdir).glob("**/*.csv"))
    files_eb = tuple(Path(fdir_eb).glob("**/*.csv"))

    ## Error bar plot
    eb = pd.read_csv(open(files_eb[0], "r"))
    eb_new = eb.drop(["Name",'Unnamed: 0'],axis = 1)
    tpr_error = eb.iloc[:]["TPR"]
    tnr_error = eb.iloc[:]["TNR"]
    fpr_error = eb.iloc[:]["FPR"]
    tpr_std, tnr_std, fpr_std = eb_new.std(axis=0, skipna=True)
    tpr_std = tpr_std
    fpr_std = fpr_std

    tpr_ALL_final = dict()
    tnr_ALL_final = dict()
    fpr_ALL_final = dict()
    roc_auc       = dict()
    fpr_roc_final = dict()
    tpr_roc_final = dict()
    roc_auc_final = dict()
    for i in range(len(files)):

        tpr_ALL = dict()
        tnr_ALL = dict()
        fpr_ALL = dict()

        df = pd.read_csv(open(files[i], "r"))
        filename = os.path.basename((files[i]))
        print(filename)
        tpr_MF = df.iloc[:]["TPR_MF"] / 100
        tnr_MF = df.iloc[:]["TNR_MF"] / 100
        tpr_FF = df.iloc[:]["TPR_FF"] / 100
        tnr_FF = df.iloc[:]["TNR_FF"] / 100
        tpr_HS = df.iloc[:]["TPR_HS"] / 100
        tnr_HS = df.iloc[:]["TNR_HS"] / 100

        for j in range(len(df)):
          tpr_ALL[j] = np.median([tpr_MF[j], tpr_FF[j], tpr_HS[j]])
          tnr_ALL[j] = np.median([tnr_MF[j], tnr_FF[j], tnr_HS[j]])
          fpr_ALL[j] = 1 - tnr_ALL[j]

        tpr_ALL_temp = sorted(tpr_ALL.items())
        fpr_ALL_temp = sorted(fpr_ALL.items())

        x_fprALL, fpr_ALL_temp_final = zip(*fpr_ALL_temp)
        x_trpALL, tpr_ALL_temp_final = zip(*tpr_ALL_temp)

        fpr_ALL_temp_final = sorted(fpr_ALL_temp_final)
        tpr_ALL_temp_final = sorted(tpr_ALL_temp_final)

        fpr_ALL_final[i] = fpr_ALL_temp_final[-1]
        tpr_ALL_final[i] = tpr_ALL_temp_final[-1]
        print(filename)
        roc_auc[i] = 1 - auc(fpr_ALL_temp_final, tpr_ALL_temp_final)

    fig, ax = plt.subplots()
    m_styles = markers.MarkerStyle.markers
    colormap = plt.cm.Dark2.colors  # Qualitative colormap
    x_fprALL, fpr_roc_final = zip(*fpr_ALL_final.items())
    x_tprALL, tpr_roc_final = zip(*tpr_ALL_final.items())
    t_roc_auc, roc_auc_final = zip(*roc_auc.items())

    for i, (marker, color) in zip(range(len(files)), itertools.product(m_styles, colormap)):
        filename_temp = os.path.basename((files[i]))
        plt.scatter(fpr_roc_final[i],tpr_roc_final[i], color=color, marker=marker, label=f"{filename_temp[:-15]} (area = %0.2f)" % roc_auc_final[i])

    plt.show()
    plt.errorbar(fpr_roc_final, tpr_roc_final, xerr=fpr_std,yerr=tpr_std, elinewidth=0.3,ecolor='black',capsize=0.1, linestyle='none',barsabove='False')
    plt.show()
    plt.title(f" Receiver operating characteristic of models - TO - HLXTOEHEE")
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.legend(loc="lower right")
    fig.set_size_inches(11, 9)

    filepath = r"C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\LSTM\TO\3markers\HLXTOEHEE\v1\models\roc"
    isExist_roc = os.path.exists(filepath)
    if isExist_roc == False:
        os.makedirs(filepath)
    plt.savefig(os.path.join(filepath, r'TO-HLXTOEHEE.png'),dpi=1000)

    # lw = 2
    # plt.plot(fpr_ALL, tpr_ALL, lw=2, label=f"{filename[:-15]} (area = %0.2f)" % roc_auc)
    # plt.xlabel('False Positive Rate')
    # plt.ylabel('True Positive Rate')
    # plt.title(f"{filename[0:2]} Receiver operating characteristic of models")
    # plt.legend(loc="lower right")
    # plt.show()
    # pdb.set_trace()
    # plt.savefig(os.path.join(fdir, f"{filename[0:2]}.png"), bbox_inches='tight',dpi=100)