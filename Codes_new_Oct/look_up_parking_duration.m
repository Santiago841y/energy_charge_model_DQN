function [parking_duration]=look_up_parking_duration(arrival_hr, n);

% call parking duration

load('pdf_6.mat');
load('pdf_7.mat');
load('pdf_8.mat');
load('pdf_9.mat');
load('pdf_10.mat');
load('pdf_11.mat');
load('pdf_12.mat');
load('pdf_13.mat');
load('pdf_14.mat');

if arrival_hr==6
    A=pdf_6;
else if arrival_hr==7
         A=pdf_7;
         else if arrival_hr==8
                  A=pdf_8;
                 else if arrival_hr==9
                          A=pdf_9;
                          else if arrival_hr==10
                                  A=pdf_10;
                                  else if arrival_hr==11
                                            A=pdf_11;
                                          else if arrival_hr==12
                                                    A=pdf_12;
                                                  else if arrival_hr==13
                                                            A=pdf_13;
                                                  else
                                                        A=pdf_14;
                                                  end
                                          end
                                  end
                          end
                 end
         end
end
end

A3=A(:,3);
[val,idx]=min(abs(A3-n));
minVal=A3(idx);
a=minVal;

size_A=size(A);
size_A(2)=[];

for i=1:size_A
    if (a==A(i,3))
        parking_duration=A(i,1);
    end
end



end