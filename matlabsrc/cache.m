function [ c ] = cache( notes, m )
%cache returns vector of segmentation
%of notes in nmat into m intervals
%   Input:
%       notes: nmat
%       m: segment size
%   Output:
%       c: segmented vector
%

ons = notes(:,6);
offs = ons + notes(:,7);
n = max(offs);
t = 0 : m : n;
t = t(1:end-1);

c = arrayfun(@(x) toPitch(x, notes), t);

end

function pitch = toPitch( t, notes )
notes = seekActiveNotes(t, notes, 'time');

if (~isempty(notes))
    % return key of chord in order to represent set of notes 
    pitch = mapToPitchOrig(kkkey(notes), notes);
else
    pitch = 0;
end

end