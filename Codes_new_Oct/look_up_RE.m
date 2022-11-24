function [RE,SOC]=look_up_RE(n);


load('pdf_RE.mat')
A=pdf_RE;

A3=A(:,3);
[val,idx]=min(abs(A3-n));
minVal=A3(idx);
a=minVal;

size_A=size(A);
size_A(2)=[];

for i=1:size_A
    if (a==A(i,3))
        RE_min=A(i,1);
    end
end

RE=RE_min*randi([1 2]);
SOC=(0.9*66-RE)/66*100;
end