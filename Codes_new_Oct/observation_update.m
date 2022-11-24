function [event_Table, aggregated_current, DE,delivered_energy]=observation_update(rows, time_table,Table, event_Table,delivered_energy, action_all, clock,DE );

action=action_all;
t1=clock;



%t=(clock+360-1);

%there is a two different counters be careful

%reduce requested energy
for x=1:rows

    if t1<time_table
        if event_Table(x,t1,2)~=0 && event_Table(x,t1+1,1)==1
            event_Table(x,t1+1,2)=event_Table(x,t1,2)-(action(x))*208/(60*1000);
            if  event_Table(x,t1+1,2)<0
                event_Table(x,t1+1,2)=0;
            end

        else if event_Table(x,t1+1,1)~=1 % very important to make sure not keep zeros all the time
                event_Table(x,t1+1,2)=0;

        else if event_Table(x,t1,2)==0 && event_Table(x,t1+1,1)==1 && event_Table(x,t1,1)==1
                event_Table(x,t1+1,2)=0;
        end
        end
        end
    end

    %event_Table(:,t,2)



    %if (t)==event_Table(x,t1,3)+1 %arrival
    %delivered_energy(x,t1)=event_Table(x,t1-1,2)-event_Table(x,t1,2)
    %else
    delivered_energy(x,t1)=DE(x) + (action(x))*208/(60*1000);
    if t1==1
        delivered_energy(x,t1)=(action(x)*208/(60*1000));
    else
        delivered_energy(x,t1)=delivered_energy(x,t1-1) + (action(x))*208/(60*1000);

    end

    if event_Table(x,t1,1)==0
        delivered_energy(x,t1)=0;
    end


    if t1<time_table 
        if event_Table(x,t1+1,2)~=0
        event_Table(x,t1+1,5)=event_Table(x,t1,5)-1;
        end

        %-----------------
        if event_Table(x,t1+1,2)~=0
            Urgency_indx(x)= ((event_Table(x,t1+1,5))*32*208/(60*1000))/event_Table(x,t1+1,2)*0.5; %voltage 0.5 laxity ratio
        else
            Urgency_indx(x)=0;
        end


    end
DE(x)=delivered_energy(x,t1);

if Urgency_indx(x)>0
event_Table(x,t1,6)=Urgency_indx(x);
else
    event_Table(x,t1,6)=0;
end

end


aggregated_current=sum(action);
%delivered_energy=(action(x)*208/(60*1000)+ (event_Table(x,t-2,2)-(event_Table(x,t-1,2))))