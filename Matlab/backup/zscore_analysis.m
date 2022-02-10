%% Standardise the values (zscore) of input data

clear; close;
%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results';
        pathCompSep = '/';
    case 1
        %for testing reasons, path is hard-coded
        %         TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\LSTM\Models\IC\2markers\HLXHEE\v1\models\saliency';
        TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\';
        pathCompSep = '\';
end

TestPath1= dir(TestPath1);
TestPath1(strncmp({TestPath1.name}, '.', 1)) = []; % removes the . and .. entries

TestPath1_type = dir([TestPath1(1).folder,pathCompSep,'Data',pathCompSep,'iteration2',pathCompSep,'train']);
TestPath1_type(strncmp({TestPath1_type.name}, '.', 1)) = []; % removes the . and .. entries
csvList = dir([TestPath1_type(1).folder,pathCompSep,'*.csv']);
csv_data = [];
for t = 1:size(csvList,1)
    [csv_data_temp, csv_column]     = xlsread([csvList(t).folder,pathCompSep,csvList(t).name],1);
    csv_data           = [csv_data; csv_data_temp(:,3:50)];
end

Z = zscore(csv_data,0,'all');
mean_csv = mean(abs(csv_data));
std_csv  = std(abs(csv_data));
var_csv  = var(abs(csv_data));
file_name = [TestPath1(4).folder,pathCompSep,TestPath1(4).name,pathCompSep,'excel',pathCompSep,'Zscore.xls'];
mean_T = array2table(mean_csv, 'VariableNames', csv_column(3:50));
var_T = array2table(var_csv, 'VariableNames', csv_column(3:50));
std_T = array2table(std_csv, 'VariableNames', csv_column(3:50));
writetable(mean_T,file_name,'Sheet',1);
writetable(var_T,file_name,'Sheet',2);
writetable(std_T,file_name,'Sheet',3);




