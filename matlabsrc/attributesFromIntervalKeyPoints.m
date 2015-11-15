function [ ratio ] = attributesFromIntervalKeyPoints( notes, p )
%attributesFromIntervalKeyPoints identifies key points
%as intervals greater than p and returns
%ratio of scalic key points to #key points
%   Input:
%           notes:      nmat
%           p:          critical value for determining
%                       key point intervals
%   Output:
%           ratio:      ratio of scalic key points
%                       to #key points

% get key
[gt g] = mapToPitchFirst( kkkey( notes ) );
sc = scale(g, gt);

% sequentialize
notes = sequentialize(notes, 'orig');
n = length(notes);

% handles to find out wether an interval is large/scalic
large = @(x) (abs(notes(x) - notes(x+1)) >= p);
scalic = @(x) (large(x) && test(notes(x), sc) && test(notes(x+1), sc));

numLarge = sum(arrayfun(large, 1:length(notes)-1));
numScalic = sum(arrayfun(scalic, 1:length(notes)-1));

ratio = numScalic/numLarge;
end


