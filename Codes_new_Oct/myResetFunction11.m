function [InitialObservation,LoggedSignals] = myResetFunction11();
 
%solar hour 51121 2 7th -Jun- 2018 max GHI = 1055
%dat 153 to 182 of the year *jun)







rows=5;
events=1;
count=1;
voltage=208;
max_chrate=32;
laxity_ratio=1/2;
delivered_energy(:,1)=[0;0;0;0;0];

for jj=1:rows
    for k=1:events

        % call arrival time
n=rand();
[arrival_min,arrival_hr]=look_up_arrival(n);

% call parking duration
n=rand();
[parking_duration]=look_up_parking_duration(arrival_hr,n);
EV_arrival(count,1)=arrival_min; %arrival
% call padeparture time
departure_min(count,1)=arrival_min+parking_duration;          


% Requested energy
%Req_E(count,1)=((parking_duration+1)*32*208*rand())/(60*1000*(2));
n=rand();
[RE,SOC]=look_up_RE(n);
Req_E(count,1)=RE;

count=count+1;
    end
end
ADR=[EV_arrival departure_min Req_E];
mat=sortrows(ADR);


count=1;
for k=1:events
    for jj=1:rows
        if k==1
                     
            Table(jj,k,1)=mat(count,1);
            Table(jj,k,2)=mat(count,2);
             parking_duration=Table(jj,k,2)-Table(jj,k,1)+1;

             n=rand();
             [RE,SOC]=look_up_RE(n);
           Table(jj,k,3)=RE;
            end


        if k~=1
          
            
            if mat(count,1)>Table(jj,k-1,2) 
                Table(jj,k,1)=mat(count,1);
                Table(jj,k,2)=mat(count,2);
                [RE,SOC]=look_up_RE(n);
                Table(jj,k,3)=RE;
       
       
        else if mat(count,1)<=Table(jj,k-1,2) 
              Table(jj,k,1)=Table(jj,k-1,2)+5;
             arrival_hr=Table(jj,k,1)/60;
             n=rand();
             [parking_duration]=look_up_parking_duration(arrival_hr,n);
             Table(jj,k,2)=parking_duration+Table(jj,k,1);


              n=rand();
             [RE,SOC]=look_up_RE(n);
                Table(jj,k,3)=RE;


        end
            end

            if Table(jj,k,1)==0  % fixed bug
            Table(jj,k,1)=Table(jj,k-1,2)+10;

            arrival_hr=Table(jj,k,1)/60;
             n=rand();
             [parking_duration]=look_up_parking_duration(arrival_hr,n);
             Table(jj,k,2)=parking_duration+Table(jj,k,1);
           %  parking_duration=Table(jj,k,2)-Table(jj,k,1)+1;
          % Table(jj,k,3)=((parking_duration+1)*32*208*rand())/(60*1000*(2))
             end
        end
            
          
     parking_duration=Table(jj,k,2)-Table(jj,k,1)+1;

      n=rand();
             [RE,SOC]=look_up_RE(n);

           Table(jj,k,3)=RE;
      
    count=count+1;
    end
end

%Table(:,events)=[]
%events=5;

start_0=360;
time_table=max(max(Table(:,:,2)))-start_0+1;

time_t_max=max(max(Table(:,:,2)));
time_t_min=min(min(Table(:,:,1)));
start_0=time_t_min;

time_table=time_t_max-time_t_min+1;


%time=randi([1 time_table]);
time1=1;
time_all=[1 start_0  time_t_max time_table];




event_Table=zeros(rows,time_table);
  delivered_energy=zeros(rows,time_table);
  DE=[0;0;0;0;0];
 
  
for jj=1:rows
    for k=1:events
        start_t=Table(jj,k,1);
        end_t=Table(jj,k,2);
        
        start_t1=start_t-start_0+1;
        end_t1=end_t-start_0+1;

                event_Table(jj,start_t1:end_t1,1)=1; %Active EVs

            event_Table(jj,start_t1:end_t1,2)=Table(jj,k,3); %REQ Energy
            event_Table(jj,start_t1:end_t1,3)=Table(jj,k,1);  %arrival
            event_Table(jj,start_t1:end_t1,4)=Table(jj,k,2);  %Departure
            event_Table(jj,start_t1:end_t1,5)=Table(jj,k,2)-(time_all(1)+start_0-1)+1;  %time to Departure


             if event_Table(jj,k,2)~=0
            Urgency_indx(jj)= (( event_Table(jj,k,5)*max_chrate*voltage/(60*1000))/ event_Table(jj,k,2))*laxity_ratio;
            else
              Urgency_indx(jj)=0;
             end

            event_Table(jj,start_t1:end_t1,6)= Urgency_indx(jj); %Urgency index


       
    end
end

for jj=1:rows
   
end


t=time1+start_0-1;

x_time=(zeros(rows,1)+time1+start_0-1)';    % time
x_active=(event_Table(:,time1,1))' ;% active EVCS
x_RE=(event_Table(:,time1,2))'; % RE
x_time_to_depart=(event_Table(:,time1,5))'; % time to depart

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


x_Urgency_indx=Urgency_indx;
% getting Building Power factor
x_PF=(zeros(rows,1)+PF)';

o_arrival=event_Table(:,time1,3)'; % arrivals
o_departure=event_Table(:,time1,4)'; % departures

% Return initial environment state variables as logged signals.
LoggedSignals.State = [x_time;x_active;x_RE;x_time_to_depart; x_Urgency_indx];
LoggedSignals.State2=[x_solar; x_solar_Q; x_P_load; x_Q_load; x_PF] % kept for later stage
InitialObservation = LoggedSignals.State;
LoggedSignals.Observation=[o_arrival; o_departure];

LoggedSignals.event_Table=event_Table; % initial states for 1 full event 
LoggedSignals.time_all=time_all;
LoggedSignals.Table=Table;
LoggedSignals.delivered_energy=delivered_energy;
LoggedSignals.DE=DE;
LoggedSignals.Rates=[];



end




