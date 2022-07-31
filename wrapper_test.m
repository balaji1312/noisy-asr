clear;clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noisy = 0; %0 for clean and 1 for noisy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The wave files can be in different sub-folders but it will be good if you
% can give a parent folder with the all the folders of the wave files
Fs = 16000;  %sampling rate of TIMIT
curr_dir = pwd;

if noisy==0
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'clean_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/clean/'; %location of the parent folder to store 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'noisy_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/noisy/'; %location of the parent folder to store
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
%     processed_audio = transpose(NSSP(rawdata,fsamp));
%     coeffs = PNCC(rawdata,fsamp);
%     [cep2, spec2] = rastaplp(rawdata, fsamp, 1, 12);
%     VAD  = voiceActivityDetector;
%     [p, noiseEstimate] = VAD(rawdata);
%     ftr = VFR(rawdata,fsamp,2.5,transpose(noiseEstimate));
%     windowLength = round(0.03*fsamp);
%     overlapLength = round(0.015*fsamp);
%     S = stft(rawdata,"Window",hann(windowLength,"periodic"),"OverlapLength",overlapLength,"FrequencyRange","onesided");
%     S = abs(S);
%     cep = cepstralCoefficients(S);
%      cepFeatures = cepstralFeatureExtractor('FilterBank','Gammatone');
%      [coeffs,delta,deltaDelta] = cepFeatures(rawdata);
     [coeffs,delta,deltaDelta, loc] = mfcc(rawdata, fsamp ,"LogEnergy","Ignore");
% 
%      ftr_1 = coeffs(:,1:13);
     ftr = QCN_RASTALP(coeffs,10);
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
    ftr_Dir = 'my_features/clean/'; %location of the parent folder to store 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%the extracted features
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    fileDir = [curr_dir '/']; %PARENT FOLDER
    scp_file =  'noisy_file_list'; %list of all the files for feature extraction
    %%%%%%%%% EDIT THIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ftr_Dir = 'my_features/noisy/'; %location of the parent folder to store
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
    
    fileName = filenames{cnt};
    snd_FilePath =  [fileDir fileName];
    fprintf('Processing %s\n', fileName);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Edit this part to extract your custom features %%%%%%%%%%%%%%%%%
    
    
    [rawdata, fsamp] = audioread(snd_FilePath);
    coeffs = gtcc(rawdata, fsamp ,"LogEnergy","Ignore");
    ftr = QCN_RASTALP(coeffs,0);
    ftr(isnan(ftr)) = 0;


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
