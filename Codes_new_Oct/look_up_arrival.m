function [arrival_min,arrival_hr]=look_up_arrival(n);


load('pdf_arrival.mat')
A=pdf_arrival;

A3=A(:,3);
[val,idx]=min(abs(A3-n));
minVal=A3(idx);
a=minVal;

size_A=size(A);
size_A(2)=[];

for i=1:size_A
    if (a==A(i,3))
        arrival_min=A(i,1);
    end
end

arrival_hr=arrival_min/60;
arrival_hr=fix(arrival_hr);

end