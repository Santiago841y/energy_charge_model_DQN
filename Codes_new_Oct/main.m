

% I have 5 states for 5 chargers
%[x_time;x_active;x_RE;x_time_to_depart; x_Urgency_indx]

ObservationInfo = rlNumericSpec([5 5]);
ObservationInfo.Name = 'Smart Charging System States';
ObservationInfo.Description = 'time, active chargers, requested energy, remaining time, urgency index';


% the charging rates are 5 outputs for each EV charger and the options are
% 0, 6, 9, 22 and 32
ActionInfo = rlFiniteSetSpec({[0 0 0 0 0], [6 6 6 6 6], [9 9 9 9 9], [22 22 22 22 22], [32 32 32 32 32]});
ActionInfo.Name = 'Charger Action';

%env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction10','myResetFunction5')
env = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction12','myResetFunction11')
