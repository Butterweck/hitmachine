function [ keyPoints ] = keyPointsFromVelocity( notes, r, t )
%keyPointsFromVelocity returns set of
%local velocity maxima in notes
%   Input:
%           notes:      nmat
%           t:          resolution for segmentation of time
%           r:          interval in which local maximum
%                       is to be found    
%   Output:
%           keyPoints:  set of local maxima (=key points)

keyPoints = [];

if (size(notes,1) == 0)
    return;
end

% end of track
off = notes(end, 6) + notes(end, 7);

% find local maxima
for i = 0 : t : off
    isMax = true;
    for j = outOfRange(i-r, off) : t : outOfRange(i+r, off)
        if (velocity(seekActiveNotes(j, notes, 'time'), 'sum') >= velocity(seekActiveNotes(i, notes, 'time'), 'sum')) && (i ~= j)
            isMax = false;
        end
    end
    if (isMax)
        keyPoints(end+1) = i;
    end
end

end

function num = outOfRange(x, n)
    if (x < 0)
        num = 0;
    elseif (x > n)
        num = n;
    else
        num = x;
    end
end