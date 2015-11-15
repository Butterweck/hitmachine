function [ ratio ] = ratioOfScalicNotes( notes )
%ratioOfScalicNotes returns ratio of scalic notes to #notes
%   Input:
%           notes:  nmat
%   Output:
%           ratio:  ratio of scalic notes to #notes

% get key
[gt g] = mapToPitchFirst( kkkey( notes ) );
notes = notes(:,4);
n = length(notes);

% get scale from key
sc = scale(g, gt);

% count scalic notes
ratio = arrayfun(@(x) test(notes(x), sc), 1:n);
ratio = sum(ratio);
ratio = ratio / n;

end