%% Concatenates Saliency
clear; close;
%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results/excel';
        pathCompSep = '/';
    case 1
        TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\';
        pathCompSep = '\';
end

TestPath1= dir(TestPath1);
TestPath1 = TestPath1([TestPath1(:).isdir]);
TestPath1(strncmp({TestPath1.name}, '.', 1)) = [];    % removes the . and .. entries
TestPath1(strncmp({TestPath1.name}, 'logs', 1)) = []; % removes the . and .. entries
TestPath1(strncmp({TestPath1.name}, 'logs_TS', 1)) = []; % removes the . and .. entries

for i=2
    TestPath1_type = dir([TestPath1(i).folder,pathCompSep,TestPath1(i).name]);
    TestPath1_type = TestPath1_type([TestPath1_type(:).isdir]);
    TestPath1_type(strncmp({TestPath1_type.name}, '.', 1)) = [];    % removes the . and .. entries
    TestPath1_type(strncmp({TestPath1_type.name}, 'logs', 1)) = []; % removes the . and .. entries
    TestPath1_type(strncmp({TestPath1_type.name}, 'logs_TS', 1)) = []; % removes the . and .. entries
    
    for j = 1:size(TestPath1_type,1)
        TestPath1_markers = dir([TestPath1_type(j).folder,pathCompSep,TestPath1_type(j).name]);
        TestPath1_markers = TestPath1_markers([TestPath1_markers(:).isdir]);
        TestPath1_markers(strncmp({TestPath1_markers.name}, '.', 1)) = []; % removes the . and .. entries
        TestPath1_markers(strncmp({TestPath1_markers.name}, 'Icon', 1)) = []; % removes the . and .. entries
        
        for k = 1:size(TestPath1_markers,1)
            TestPath1_total = dir([TestPath1_markers(k).folder,pathCompSep,TestPath1_markers(k).name]);
            TestPath1_total = TestPath1_total([TestPath1_total(:).isdir]);
            TestPath1_total(strncmp({TestPath1_total.name}, '.', 1)) = []; % removes the . and .. entries
            
            for t = 1:size(TestPath1_total,1)
                TestPath1_Final = dir([TestPath1_total(t).folder,pathCompSep,TestPath1_total(t).name,pathCompSep,'v1',pathCompSep,'models']);
                TestPath1_Final(strncmp({TestPath1_Final.name}, '.', 1)) = []; % removes the . and .. entries
                xlsxList = dir([TestPath1_Final(k).folder,pathCompSep,'roc',pathCompSep,'*.csv']);
                FS = [];
                for v = 1:size(xlsxList,1)
                    [FSnum,FSstr]            = xlsread([xlsxList(v).folder,pathCompSep,xlsxList(v).name],1);
                    FS = [FS; FSnum];
                    
                end
                table_path = fullfile([TestPath1_Final(k).folder,pathCompSep,'roc',pathCompSep,'RoC_Total.csv']);
                writetable(array2table(FS, 'VariableNames', FSstr), table_path)
            end
        end
        clear FSnum FSstr Nr
    end
end

