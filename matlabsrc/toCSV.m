function [  ] = toCSV( M, m )

n=length(M);

count = 0;

for i = n-1:-1:145
    if (length(find(M(:,i)==0))>100)
        M(:,i)=[];
        m(i)=[];
        count = count + 1;
    end
end

M(:,1)=[];
m(1)=[];

M(:,end+1)=M(:,end)<2;
m{end+1}='label2';

M(:,end-1)=[];
m(end-1)=[];

d=cell2dataset(m);
export(d,'file','songdata.csv','delimiter',',');
dlmwrite('songdata.csv',M,'-append');
count
end

