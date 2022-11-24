clear all
clc

% I have 5 states for 5 chargers
%[x_time;x_active;x_RE;x_time_to_depart; x_Urgency_indx]

ObservationInfo = rlNumericSpec([25 1]);
ObservationInfo.Name = 'Smart Charging System States';
ObservationInfo.Description = 'time, active chargers, requested energy, remaining time, urgency index';


% the charging rates are 5 outputs for each EV charger and the options are
% 0, 6, 9, 22 and 32
ActionInfo = rlFiniteSetSpec({[0 0 0 0 0], [6 6 6 6 6], [9 9 9 9 9], [22 22 22 22 22], [32 32 32 32 32]});
ActionInfo.Name = 'Charger Action';

env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction10','myResetFunction5')

% qTable = rlTable(getObservationInfo(env),getActionInfo(env));
% qRepresentation = rlQValueRepresentation(qTable,getObservationInfo(env),getActionInfo(env));
% qRepresentation.Options.LearnRate = 1;
% 
% agentOpts = rlQAgentOptions;
% agentOpts.EpsilonGreedyExploration.Epsilon = .04;
% qAgent = rlQAgent(qRepresentation,agentOpts);
% 
% trainOpts = rlTrainingOptions;
% trainOpts.MaxStepsPerEpisode = 50;
% trainOpts.MaxEpisodes= 200;
% trainOpts.StopTrainingCriteria = "AverageReward";
% trainOpts.StopTrainingValue = 11;
% trainOpts.ScoreAveragingWindowLength = 30;
% 
% doTraining = True;
% 
% if doTraining
%     % Train the agent.
%     trainingStats = train(qAgent,env,trainOpts);
% else
%     % Load the pretrained agent for the example.
%     load('basicGWQAgent.mat','qAgent')
% end


nI = ObservationInfo.Dimension(1);  % number of inputs 
nL = 120;                           % number of neurons
nO = numel(ActionInfo.Elements);    % number of outputs 

dnn = [
    featureInputLayer(nI,'Normalization','none','Name','state')
    fullyConnectedLayer(nL,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(nL,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(nO,'Name','fc3')];

figure
plot(layerGraph(dnn))

criticOptions = rlRepresentationOptions('LearnRate',1e-4,'GradientThreshold',1,'L2RegularizationFactor',1e-4);
critic = rlQValueRepresentation(dnn,ObservationInfo,ActionInfo,'Observation',{'state'},criticOptions);


agentOpts = rlDQNAgentOptions(...
    'SampleTime',1,...
    'UseDoubleDQN',true,...
    'TargetSmoothFactor',1e-3,...
    'DiscountFactor',0.99,...
    'ExperienceBufferLength',1e6,...
    'MiniBatchSize',60);

agentOpts.EpsilonGreedyExploration.EpsilonDecay = 1e-4;

agent = rlDQNAgent(critic,agentOpts);

maxepisodes = 10000;
maxsteps = 1000;
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'Verbose',false,...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue', -1,...
    'SaveAgentCriteria','EpisodeReward',...
    'SaveAgentValue',100);

trainOpts.UseParallel = true;
trainOpts.ParallelizationOptions.Mode = "async";
trainOpts.ParallelizationOptions.DataToSendFromWorkers = "experiences";
trainOpts.ParallelizationOptions.StepsUntilDataIsSent = 32;

doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Load pretrained agent for the example.
    load('SimulinkLKADQNParallel.mat','agent')
end