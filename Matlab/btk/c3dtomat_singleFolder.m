clc
clear all
close all

%% converts mat-files from c3d-files based on ONE FOLDER filled with c3ds
% prerequisit is installed btk-toolkit


%% User choose location of c3d and defines location for mat-files to be saved 


dataPath = uigetdir([], 'Select folder with c3d-files');
cd(dataPath);

destPath = uigetdir([], 'Select folder to save mat-files');

%addpath('\btk') % adds the btk toolkit!
%%

files = dir('*.c3d');
for i = 1:length(files);
    c3dfiletoLoad = files(i).name;
    acq = btkReadAcquisition(c3dfiletoLoad);
    AnalogCh = btkGetMarkers(acq);
    if btkGetAnalogNumber(acq) ~= 0
        AnalogCh.sync = btkGetAnalog(acq, 1);
    end
%     AnalogCh.sync = 
%     AnalogCh.ratio = btkGetAnalogSampleNumberPerFrame(acq);
%     AnalogCh.analsampfreq = btkGetAnalogFrequency(acq);
%     AnalogCh.analchannelNo = btkGetAnalogNumber(acq);
%     AnalogCh.analogsVals = btkGetAnalogsValues(acq);
%     AnalogCh.analRes = btkGetAnalogResolution(acq);
%     AnalogCh.analFirstFrameId = btkGetFirstFrame(acq);
%     AnalogCh.forcePlateInfo = btkGetForcePlatforms(acq);
%     AnalogCh.forces = btkGetForces(acq);
%     AnalogCh.forceVals = btkGetForcesValues(acq);
%     AnalogCh.analLastFrameId = btkGetLastFrame(acq);
    
    filenametosave = [files(i).name(1:end-4),'.mat'];
    filetosave = fullfile(destPath, filenametosave);
    save(filetosave,'AnalogCh');
end
