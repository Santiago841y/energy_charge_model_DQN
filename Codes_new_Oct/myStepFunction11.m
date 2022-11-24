function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunction11(Action,LoggedSignals)
% Custom step function to construct cart-pole environment for the function
% name case.
%
% This function applies the given action to the environment and evaluates
% the system dynamics for one simulation step.
r1t=0;
r2t=0;
r3t=0;
r4t=0;
r5t=0;
r6t=0;
r7t=0;
r1=0;
r2=0;
r3=0;
r4=0;
r5=0;
r6=0;
r7=0;
r0=0;
Penalty=0;

% Define the environment constants.
Break=0;
% Maximum sum of all charging rates (max sum  of actions)
Agg_max = 71;

% Transformer size
Transformer =15;

% Number of chargers
col = 5;
rows=5;

% Number of events per charger per day
events=1;

% voltage level
%HalfPoleLength =
voltage=208;

% counters
count1=0;
count2=0;

% Max force the input can apply
%MaxForce = 10;
% Sample time
%Ts = 0.02;
% Pole angle at which to fail the episode
%AngleThreshold = 12 * pi/180;
% Cart distance at which to fail the episode
%DisplacementThreshold = 2.4;
% Reward each time step the cart-pole is balanced
%RewardForNotFalling = 1;
% Penalty when the cart-pole fails to balance
%PenaltyForFalling = -10;







% Unpack the state vector from the logged signals.
State = LoggedSignals.State;
Observation = LoggedSignals.Observation;
other_state=LoggedSignals.State2;
time_all=LoggedSignals.time_all;
time_all=LoggedSignals.time_all;
time_tabel=time_all(4);

start_0=time_all(2);

DE=LoggedSignals.DE;
delivered_energy=LoggedSignals.delivered_energy;


Table=LoggedSignals.Table;
event_Table=LoggedSignals.event_Table;


time = State(1);
active_ev = State(2,:);
RE = State(3,:);
time_to_depart= State(4,:);
Urgency_indx=State(5,:);

arrival=Observation(1,:);
departure=Observation(2,:);

%other_state for later
P_solar=other_state(1,:);
Q_solar=other_state(2,:);
P_load=other_state(3,:);
Q_load=other_state(4,:);
PF=other_state(5,:);

% Cache to avoid recomputation.

clock=time_all(1);
t1=clock;
t=clock+time_all(2)-1;
time=t;






% Check if the given action is valid.
if ~ismember(Action,[0 6 9 22 32])
    error('Action must be one of the following %g, %g, %g, %g, %g.',...
        0, 6, 9, 22, 32)
end

chrate = Action;

Rates(:,t1)=chrate';


% take the values from the table for the next minute to update the
% delivered energies time, requested, time to delay

time_table=time_all(4);
action_all=chrate';
clock=time_all(1);

 

[event_Table, aggregated_current, DE,delivered_energy]=observation_update(rows, time_table,Table, event_Table,delivered_energy, action_all, clock,DE );



LoggedSignals.event_Table=event_Table; % initial states for 1 full event 
LoggedSignals.time_all=time_all;
LoggedSignals.Table=Table;
LoggedSignals.delivered_energy=delivered_energy;
LoggedSignals.DE=DE;


%-------------------------- Rewards---------

%---------
count1=0;
count2=0;
count3=0;
Reward=0;
Reward1=0;
Reward2=0;
Reward3=0;
Reward4=0;
r0=[];
r6=[];
    for event=1:events;
        for jj=1:rows
           % if Break==0

                % How correct the service is
                if chrate(jj)>0 && active_ev(jj)~=0  % reward chrate correct
                    count1=count1+1;
                     r0(jj)=1;
                elseif chrate(jj)==0 && active_ev(jj)==0 %reward no chrate correct
                    count1=count1+1;
                     r0(jj)=1;
                elseif chrate(jj)==0 && active_ev(jj)~=0 &&  delivered_energy(jj,event)==0 
                    count2=count2+1;
                    elseif chrate(jj)==0 && active_ev(jj)~=0 &&  delivered_energy(jj,event)>0 && (Table(jj,event,3)/delivered_energy(jj,event))<0.5
                    count2=count2+1;
                elseif chrate(jj)==0 && active_ev(jj)~=0 && delivered_energy(jj,event)>0 && (Table(jj,event,3)/delivered_energy(jj,event))>=0.5
                       count1=count1+1;
                       r0(jj)=1;
                elseif chrate(jj)>0  && active_ev(jj)==0 % not correct
                    count2=count2+1;
                    %r5(jj)=-1*(time_table-t1+1);
                    r0(jj)=-1;

                    %Reward=Reward+(sum(r5)-r5(jj))/jj+r5(jj);
                   % Reward1=sum(r0)+r5(jj))/jj;
                   % n_jj=jj;
                    Break=1;

                    % else
                    %if chrate(jj)==00  && active_ev(jj)~=0 % not considered because
                    %I want flexibility
                    %count2=count2+1
                end

                %check service is applied
                %r2(jj)=chrate(jj)*active_ev(jj)/Agg_max ; %%check service is applied makes the service attractive to be available



                departure_time=Table(jj,event,2);

                if t1==departure_time-start_0+1;  %check only at the end

                    if delivered_energy(jj,departure_time-start_0+1)~=0 && Table(jj,event,3)~=0
                        
                        r6(jj)=(1-Table(jj,event,3)/delivered_energy(jj,departure_time-start_0+1));

                        %if r6(jj)>1
                         %   r6(jj)=1-r6(jj)
                       % end
                        
                    elseif delivered_energy(jj,departure_time-start_0+1)==0 && Table(jj,event,3)==0
                        r6(jj)=+1;
                    elseif delivered_energy(jj,departure_time-start_0+1)==0 && Table(jj,event,3)~=0  %no charging during the full event
                        %r7(jj)=-1
                        %r7(jj)=(-1*(time_table-t1+1)+sum(r5)+sum(r6)-r6(jj))/rows;
                        %Reward=Reward+(sum(r7)-r7(jj))/jj+r7(jj);
                        %Reward=-1*(time_table-t1+1+sum(r6))/rows;
                        % Reward2=(-1+sum(r6))/jj;
                        r6(jj)=(-1);

                        n_jj=jj;
                        Break=2;

                    end
                end

            end
      %  end
    end

    Reward1=(0.5*sum(r0)+0.5*sum(r6))/rows
    if t1>1
Reward2=(sum(Rates(:,t1))-sum(Rates(:,t1-1))/Agg_max)
    end

    if sum(active_ev)~=0
        Reward3=count1/rows-1;

        if sum(chrate)>32*sum(active_ev) && sum(chrate)<aggregated_current
            Reward4= (32*sum(active_ev)-sum(chrate))/(32*sum(active_ev)) % not to give more than required
        else if sum(chrate)>aggregated_current
                %r2t=-1*rows*(event_table-t1+1)
                %Reward=Reward+r2t/5
               % Reward=(-1*time_table+sum(r5)+sum(r6))/rows;
                Reward4=-1/rows

                Break=3;

        end

        end

    end
   

    % r1t ok r4t
    r5t=sum(r5);
    r6t=sum(r6)/rows;
    r7t=sum(r7);
    r0t=sum(r0)/rows;


    %r2t=0.5*sum(r2);
    %check service is applied

    %r3t  out
    %Penalty=(1/3)*r2t+(1/3)*r5t+(1/3)*r7t;
    %Reward=(0.2*(0.5*r1t++0.25*r4t+0.25*r6t)+0.8*Penalty)/rows;
   
           % Reward=0.2*(0.25*r0t+0.25*r1t+0.25*r4t+0.25*r6t)+0.8*Penalty/3;
          % Reward=Reward/time_table % I normalized the reward by the number of steps in an episode
            % I tried dividing by t1 but it is a wrong approach
Reward=Reward1+Reward2+Reward3+Reward4;

%index_action=[1:rows];
% index , action, Urgency_indx
 

%Here I Wil TRy to add a REWARD soon
%for counter=1:rows
%for jj=1:rows
%if active_ev(jj)==1
 %   mat_UI(counter,:)=[index(jj) chrate(jj) Urgency_indx(jj)]
%end
%end
%end


%new States


%--------------------------------time step----------------------------

t1=clock+1;
time1=t1;

t=t1+time_all(2)-1;
time=t;

x_time=(zeros(rows,1)+t)';    % time
x_active=(event_Table(:,time1,1))' ;% active EVCS
x_RE=(event_Table(:,time1,2))'; % RE
x_time_to_depart=(event_Table(:,time1,5))'; % time to depart
x_Urgency_indx=(event_Table(:,t1,6))';

% getting GHI
load('GHI_min.mat');
GHI_1=GHI_min(:,1);
time_1=fix(t/5);
time_1=time_1*5;
indx_1=find(GHI_1==time_1);
GHI_ok=GHI_min(indx_1,2);
x_solar=(zeros(rows,1)+GHI_ok)';

x_solar_Q=(zeros(rows,1))';


% getting Building load P_load
hour=fix(t/60);
load('P_load.mat')
P_load_1=P_load(:,1);
indx_1=find(P_load_1==hour);
P_load_ok=P_load(indx_1,2);

x_P_load=(zeros(rows,1)+P_load_ok)';


% getting Building load Q_load
hour=fix(t/60);
load('Q_load.mat')
Q_load_1=Q_load(:,1);
indx_1=find(Q_load_1==hour);
Q_load_ok=Q_load(indx_1,2);

x_Q_load=(zeros(rows,1)+Q_load_ok)';

S=sqrt(P_load_ok^2 + +Q_load_ok^2);
PF=P_load_ok/S;



% giving an urgency index that shows which charger needs to be with the
% highest charging rate available
%lowest yrgency has the priority


% getting Building Power factor
x_PF=(zeros(rows,1)+PF)';

o_arrival=event_Table(:,time1,3)'; % arrivals
o_departure=event_Table(:,time1,4)'; % departures

%------------------------------------------

% these change at every step

LoggedSignals.State = [x_time;x_active;x_RE;x_time_to_depart; x_Urgency_indx];
LoggedSignals.State2=[x_solar; x_solar_Q; x_P_load; x_Q_load; x_PF] % kept for later stage
LoggedSignals.Observation=[o_arrival; o_departure];
LoggedSignals.event_Table=event_Table; % initial states for 1 full event 
LoggedSignals.delivered_energy=delivered_energy;
LoggedSignals.DE=DE;
LoggedSignals.Rates=Rates;


%these are un changed during a full event but do change at resest
LoggedSignals.time_all=time_all;
LoggedSignals.Table=Table;

% Transform state to observation.
NextObs = LoggedSignals.State;


% to finish the table if last minute of the time is done

% Check terminal condition.
time_Threshold=time_all(3)
IsDone = NextObs(1,1)+1 > time_all(3) || Break==1; % reached end of table no more steps can be processed
% Get reward.

start_episode=time_all(2);


Reward_total=sum(event_Table(:,1,2))/sum(event_Table(:,time_table,2));

%if ~IsDone % I will put a reward on the overall episode performance delivered energy/requested energy
 %   Reward = (1-Reward_total)+Reward
%end

end