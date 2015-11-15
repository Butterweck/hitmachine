function [ activeNotes ] = seekActiveNotes( t, notes, mode )
%seekActiveNotes returns set of notes
%currently playing at time t
%   Input:
%           t: point in time
%           notes: set of notes
%           mode: is t in beats
%           or in time ('beat'/'time') ?
%   Output:
%           activeNotes: notes playing at t

activeNotes = zeros(0,7);
i = 1;

if (strcmp(mode,'beat'))
    column = 1;
elseif (strcmp(mode,'time'))
    column = 6;
else
    %default
    println('no mode, choose time as default');
    column = 6;
end
    
for i = 1 : size(notes, 1)
    
    if (notes(i,column) <= t) && (t < notes(i,column) + notes(i,column+1))
        activeNotes(end+1,:) = notes(i,:);
    end
    if (notes(i,column) > t)
    	break;
    end
end

end

