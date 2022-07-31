clear;clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noisy = 0; %0 for clean and 1 for noisy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The wave files can be in different sub-folders but it will be good if you
% can give a parent folder with the all the folders of the wave files
Fs = 16000;  %sampling rate of TIMIT
curr_dir = pwd;

pioth = '/Users/balaji1312/kaldi/egs/spc/s5/data_ref/train_spc/wav.scp';


fid=fopen(pioth,'r');
count=1;
while ~feof(fid)
    
    tline = fgets(fid);
    temp_in = regexp(tline,'[\r\f\n]','split');
    temp = temp_in{1};
    tfr = regexp(temp,' ','split');
    tg = tfr{2};
    tc = regexp(tg,'/','split');
    newc = [tc{9} '/' tc{10} '/' tc{11}];
    aug_files{count} = newc;
    count=count+1;
    
end
fclose(fid);

if noisy==0
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'clean_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/'; %location of the parent folder to store 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'noisy_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/'; %location of the parent folder to store
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
fid=fopen(scp_file,'r');
count=1;
while ~feof(fid)
    
    tline = fgets(fid);
    temp_in = regexp(tline,'[\r\f\n]','split');
    temp = temp_in{1};
    filenames{count} = temp;
    count=count+1;
    
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ctny = 0;

for cnt = 1:length(filenames)
    

    fileName = filenames{cnt};

    snd_FilePath =  [fileDir fileName];
    fprintf('Processing %s\n', fileName);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Edit this part to extract your custom features %%%%%%%%%%%%%%%%%
    
    [rawdata, fsamp] = audioread(snd_FilePath);

    if ~any(strcmp(aug_files,fileName))

        coeffs = gtcc(rawdata, fsamp ,"LogEnergy","Ignore");

        ftr = QCN_RASTALP(coeffs,0);
        ftr(isnan(ftr)) = 0;
        
        inds = strfind(fileName,'/');
        dirstore = [curr_dir '/' ftr_Dir fileName(1:inds(end)-1)];
    
        if(~exist(dirstore))
            system(['mkdir -p ' dirstore]);
        end

        dlmwrite([curr_dir '/' ftr_Dir fileName(1:end-4) '.txt'],ftr);
    
    else
        
        ctny = ctny+ 1;
%         noi = applyNoise(rawdata,15,15,fsamp);
        noi2 = applyNoise2(rawdata,15,15,fsamp);

%         drcoi  = dynamicRangeCompressor(rawdata);
%         noi3 = applyNoise3(rawdata,15,15,fsamp);
%         hoi = applyHarmonicDistortion(rawdata,10,fsamp);
%         poi_1 = applyPitchShift(rawdata,10,10,fsamp);
%         poi = resample(poi_1,length(rawdata),length(poi_1));
% 
%         fsoi_1 = applySpeedUp(rawdata,10,10,fsamp);
%         fsoi = resample(fsoi_1,length(rawdata),length(fsoi_1));
% 
%         ssoi_1 = applySpeedUp(rawdata,10,10,fsamp);
%         ssoi = resample(ssoi_1,length(rawdata),length(ssoi_1));


        data_list = [rawdata noi2];

        for c = 1:2
            coeffs = gtcc(data_list(:,c), fsamp ,"LogEnergy","Ignore");

            ftr = QCN_RASTALP(coeffs,0);
            ftr(isnan(ftr)) = 0;

            inds = strfind(fileName,'/');
            dirstore = [curr_dir '/' ftr_Dir fileName(1:inds(end)-1)];

            if(~exist(dirstore))
                system(['mkdir -p ' dirstore]);
            end

            dlmwrite([curr_dir '/' ftr_Dir fileName(1:end-4) '_' int2str(c) '.txt'],ftr);
        end
    end

    
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noisy = 1; %0 for clean and 1 for noisy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The wave files can be in different sub-folders but it will be good if you
% can give a parent folder with the all the folders of the wave files
Fs = 16000;  %sampling rate of TIMIT
curr_dir = pwd;

if noisy==0
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'clean_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/'; %location of the parent folder to store 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'noisy_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/'; %location of the parent folder to store
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
fid=fopen(scp_file,'r');
count=1;
while ~feof(fid)
    
    tline = fgets(fid);
    temp_in = regexp(tline,'[\r\f\n]','split');
    temp = temp_in{1};
    filenames{count} = temp;
    count=count+1;
    
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for cnt = 1:length(filenames)
    
    %fileName = ['mbss_' filenames{cnt}];
    fileName = filenames{cnt};
    snd_FilePath =  [fileDir fileName];
    fprintf('Processing %s\n', fileName);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Edit this part to extract your custom features %%%%%%%%%%%%%%%%%
    
    
    [rawdata, fsamp] = audioread(snd_FilePath);
     coeffs = gtcc(rawdata, fsamp ,"LogEnergy","Ignore");
% 
%      ftr_1 = coeffs(:,1:13);
     ftr = QCN_RASTALP(coeffs,0);
     ftr(isnan(ftr)) = 0;
%      M = mean(ftr,1);
%      ftr = (ftr-M);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inds = strfind(fileName,'/');
    dirstore = [curr_dir '/' ftr_Dir fileName(1:inds(end)-1)];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Windows users might need to edit this %%%%
    if(~exist(dirstore))
        system(['mkdir -p ' dirstore]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dlmwrite([curr_dir '/' ftr_Dir fileName(1:end-4) '.txt'],ftr);
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
