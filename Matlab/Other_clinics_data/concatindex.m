clear; clc;
ResultFolder  ='C:\Users\ykuk0\Desktop\C3Ds\results\csv';
addpath('C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Codes\Matlab\');
matList = dir([ResultFolder,'\*.mat']);

for i=1: length(matList)
    name = matList(i).name(1:end-4);
    data_file = load([matList(i).folder '\' name]);
    index_frame = data_file.Frames;
    if (name(1:2) == 'IC')
        if (name(4:5) == 'LT')
            Events.(name(7:end)).Left.IC = index_frame;
        elseif(name(4:5) == 'RT')
            Events.(name(7:end)).Right.IC = index_frame;
        end
    elseif (name(1:2) == 'TO')
        if (name(4:5) == 'LT')
            Events.(name(7:end)).Left.TO = index_frame;
        elseif(name(4:5) == 'RT')
            Events.(name(7:end)).Right.TO = index_frame;
        end
    end
end