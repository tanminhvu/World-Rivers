clear
close all
try delete(findall(0))
catch
end

%% Reconstruct h 

load('fill_small_gaps_target.mat')
[htarget,C,S] = normalize(ht);

figure; hold on
plot(htarget)


% Data
hall = [];

load('read_mean_Theia.mat')
hall = cat(2,hall,ham);

% load('fill_small_gaps_data.mat')
% hall = cat(2,hall,normalize(ha(:,[6])));

% load('D:\DL France\Discharge world next\96b_Tapajos\Reconstruction\fill_small_gaps_data.mat')
% hall = cat(2,hall,normalize(ha(:,[9 13])));

% load('D:\DL France\Discharge world next\96_Amazon_next\Reconstruction\result_target_2.mat')
% hall = cat(2,hall,normalize(h));

plot(hall)

%% Compute

istart = 991; 
itrain = istart+85;
ivalid = 1082;
iend   = 1200;

xtrain = hall(istart:itrain,:)'  ; ytrain = htarget(istart:itrain,:)';
xvalid = hall(itrain+1:ivalid,:)'; yvalid = htarget(itrain+1:ivalid,:)';
xtest = hall(ivalid+1:iend,:)'; 

xall   = hall(istart:iend,:)'; yall   = htarget(istart:iend,:)';
%% Define LSTM Network Architecture

numFeatures = size(xtrain,1);
numResponses = 1;
numHiddenUnits = 5;

layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    MaxEpochs=250, ...
    ValidationData={xvalid,yvalid}, ...
    ValidationFrequency=25, ...
    Verbose=true, ...
    Plots="training-progress");

net = trainNetwork(xtrain,ytrain,layers,options);

YPred = predict(net,xtest);

% Take values

htarget(ivalid+1:iend,1) = YPred';


plot(htarget)

htarget = htarget*S+C;

[R2,rmse_out] = R2_RMSE_NaN(ht(ivalid:end,1),htarget(ivalid:end,1))

save('test_00a','htarget','R2','rmse_out')