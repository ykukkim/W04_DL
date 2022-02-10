ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0  
        TestPath1= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results/excel/Sailency';
        
        pathCompSep = '/';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\excel';
        pathCompSep = '\';
end

%% Taking Max from all values
% [IC_num,IC_str]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],11);
% [TO_num,TO_str]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],13);

%% Taking max from each row
[IC_num,IC_str]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],10);
[TO_num,TO_str]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],12);

%% TO
IC.FF.HLXHEE.position = [IC_num(1,1:3) IC_num(1,7:9)];
IC.MF.HLXHEE.position = [IC_num(2,1:3) IC_num(2,7:9)];
IC.HS.HLXHEE.position = [IC_num(3,1:3) IC_num(3,7:9)];
IC.FF.HLXHEE.velocity = [IC_num(1,4:6) IC_num(1,10:12)];
IC.MF.HLXHEE.velocity = [IC_num(2,4:6) IC_num(2,10:12)];
IC.HS.HLXHEE.velocity = [IC_num(3,4:6) IC_num(3,10:12)];

IC.FF.HLXPMT5HEE.position = [IC_num(11,1:3) IC_num(11,13:15) IC_num(11,7:9)];
IC.MF.HLXPMT5HEE.position = [IC_num(12,1:3) IC_num(12,13:15) IC_num(12,7:9)];
IC.HS.HLXPMT5HEE.position = [IC_num(13,1:3) IC_num(13,13:15) IC_num(13,7:9)];
IC.FF.HLXPMT5HEE.velocity = [IC_num(11,4:6) IC_num(11,16:18) IC_num(11,10:12)];
IC.MF.HLXPMT5HEE.velocity = [IC_num(12,4:6) IC_num(12,16:18) IC_num(12,10:12)];
IC.HS.HLXPMT5HEE.velocity = [IC_num(13,4:6) IC_num(13,16:18) IC_num(13,10:12)];

IC.FF.TOEHEE.position = [IC_num(6,1:3) IC_num(6,7:9)];
IC.MF.TOEHEE.position = [IC_num(7,1:3) IC_num(7,7:9)];
IC.HS.TOEHEE.position = [IC_num(8,1:3) IC_num(8,7:9)];
IC.FF.TOEHEE.velocity = [IC_num(6,4:6) IC_num(6,10:12)];
IC.MF.TOEHEE.velocity = [IC_num(7,4:6) IC_num(7,10:12)];
IC.HS.TOEHEE.velocity = [IC_num(8,4:6) IC_num(8,10:12)];

IC.FF.TOEPMT5HEE.position = [IC_num(16,1:3) IC_num(16,13:15) IC_num(16,7:9)];
IC.MF.TOEPMT5HEE.position = [IC_num(17,1:3) IC_num(17,13:15) IC_num(17,7:9)];
IC.HS.TOEPMT5HEE.position = [IC_num(18,1:3) IC_num(18,13:15) IC_num(18,7:9)];
IC.FF.TOEPMT5HEE.velocity = [IC_num(16,4:6) IC_num(16,16:18) IC_num(16,10:12)];
IC.MF.TOEPMT5HEE.velocity = [IC_num(17,4:6) IC_num(17,16:18) IC_num(17,10:12)];
IC.HS.TOEPMT5HEE.velocity = [IC_num(18,4:6) IC_num(18,16:18) IC_num(18,10:12)];

IC.FF.HLXTOEHEE.position = [IC_num(21,7:9) IC_num(21,1:3) IC_num(21,13:15)];
IC.MF.HLXTOEHEE.position = [IC_num(22,7:9) IC_num(22,1:3) IC_num(22,13:15)];
IC.HS.HLXTOEHEE.position = [IC_num(23,7:9) IC_num(23,1:3) IC_num(23,13:15)];
IC.FF.HLXTOEHEE.velocity = [IC_num(21,10:12) IC_num(21,4:6) IC_num(21,16:18)];
IC.MF.HLXTOEHEE.velocity = [IC_num(22,10:12) IC_num(22,4:6) IC_num(22,16:18)];
IC.HS.HLXTOEHEE.velocity = [IC_num(23,10:12) IC_num(23,4:6) IC_num(23,16:18)];

%% TO
TO.FF.HLXHEE.position = [TO_num(1,1:3) TO_num(1,7:9)];
TO.MF.HLXHEE.position = [TO_num(2,1:3) TO_num(2,7:9)];
TO.HS.HLXHEE.position = [TO_num(3,1:3) TO_num(3,7:9)];
TO.FF.HLXHEE.velocity = [TO_num(1,4:6) TO_num(1,10:12)];
TO.MF.HLXHEE.velocity = [TO_num(2,4:6) TO_num(2,10:12)];
TO.HS.HLXHEE.velocity = [TO_num(3,4:6) TO_num(3,10:12)];

TO.FF.HLXPMT5HEE.position = [TO_num(11,1:3) TO_num(11,13:15) TO_num(11,7:9)];
TO.MF.HLXPMT5HEE.position = [TO_num(12,1:3) TO_num(12,13:15) TO_num(12,7:9)];
TO.HS.HLXPMT5HEE.position = [TO_num(13,1:3) TO_num(13,13:15) TO_num(13,7:9)];
TO.FF.HLXPMT5HEE.velocity = [TO_num(11,4:6) TO_num(11,16:18) TO_num(11,10:12)];
TO.MF.HLXPMT5HEE.velocity = [TO_num(12,4:6) TO_num(12,16:18) TO_num(12,10:12)];
TO.HS.HLXPMT5HEE.velocity = [TO_num(13,4:6) TO_num(13,16:18) TO_num(13,10:12)];

TO.FF.TOEHEE.position = [TO_num(6,1:3) TO_num(6,7:9)];
TO.MF.TOEHEE.position = [TO_num(7,1:3) TO_num(7,7:9)];
TO.HS.TOEHEE.position = [TO_num(8,1:3) TO_num(8,7:9)];
TO.FF.TOEHEE.velocity = [TO_num(6,4:6) TO_num(6,10:12)];
TO.MF.TOEHEE.velocity = [TO_num(7,4:6) TO_num(7,10:12)];
TO.HS.TOEHEE.velocity = [TO_num(8,4:6) TO_num(8,10:12)];

TO.FF.TOEPMT5HEE.position = [TO_num(16,1:3) TO_num(16,13:15) TO_num(16,7:9)];
TO.MF.TOEPMT5HEE.position = [TO_num(17,1:3) TO_num(17,13:15) TO_num(17,7:9)];
TO.HS.TOEPMT5HEE.position = [TO_num(18,1:3) TO_num(18,13:15) TO_num(18,7:9)];
TO.FF.TOEPMT5HEE.velocity = [TO_num(16,4:6) TO_num(16,16:18) TO_num(16,10:12)];
TO.MF.TOEPMT5HEE.velocity = [TO_num(17,4:6) TO_num(17,16:18) TO_num(17,10:12)];
TO.HS.TOEPMT5HEE.velocity = [TO_num(18,4:6) TO_num(18,16:18) TO_num(18,10:12)];

TO.FF.HLXTOEHEE.position = [TO_num(21,7:9) TO_num(21,1:3) TO_num(21,13:15)];
TO.MF.HLXTOEHEE.position = [TO_num(22,7:9) TO_num(22,1:3) TO_num(22,13:15)];
TO.HS.HLXTOEHEE.position = [TO_num(23,7:9) TO_num(23,1:3) TO_num(23,13:15)];
TO.FF.HLXTOEHEE.velocity = [TO_num(21,10:12) TO_num(21,4:6) TO_num(21,16:18)];
TO.MF.HLXTOEHEE.velocity = [TO_num(22,10:12) TO_num(22,4:6) TO_num(22,16:18)];
TO.HS.HLXTOEHEE.velocity = [TO_num(23,10:12) TO_num(23,4:6) TO_num(23,16:18)];

clearvars -except IC TO

