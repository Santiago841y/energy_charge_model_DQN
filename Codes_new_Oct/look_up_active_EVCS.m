
function [active_EVCS]=look_up_active_EVCS(time);



rows=5;
events=10;
count=1;

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
Req_E(count,1)=((parking_duration+1)*32*208*rand())/(60*1000*(2));
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


time=randi([1 time_table]);




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

            event_Table(jj,start_t1:end_t1,5)=Table(jj,k,2)-time+1;  %time to Departure


       
    end
end


x_time=(zeros(rows,1)+time)';    % time
x_active=(event_Table(:,time,1))' % active EVCS
x_RE=(event_Table(:,time,2))' % RE
x_time_to_depart=event_Table(:,time,5); % time to depart
event_Table(:,time,3) % arrivals
event_Table(:,time,4) % departures
