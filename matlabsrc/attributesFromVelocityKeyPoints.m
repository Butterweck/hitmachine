function [ ratio intervals ] = attributesFromVelocityKeyPoints( keyPoints, notes )
%attributesFromKeyPoints computes ratio of scalic key points
%and most common intervals at key points
%   Input:
%           keyPoints:  vector of keyPoints
%           notes:      nmat
%   Output:
%           ratio:      ratio of scalic key points
%           intervals:  three (or less) most common 
%                       intervals at key points
%                       (if less, filled with -1)

% get key
[gt g] = mapToPitchFirst( kkkey( notes ) );

%eliminate keyPoints with no notes playing (may result from drum solo parts)
for i = 1 : length(keyPoints)
    if (isempty(seekActiveNotes(keyPoints(i), notes, 'time')))
        keyPoints(i) = -1;
    end
end
keyPoints(keyPoints == -1) = [];

n = length(keyPoints);
sc = scale(g, gt);

% handle for testing wether a key point is scalic
isScalic = @(x) test(mapToPitchFirst(kkkey(seekActiveNotes(x, notes, 'time'))), sc);
 
ratio = sum(arrayfun(isScalic, keyPoints))/n;

% computes set of differences between key point pitch and it's
% forerunner's/follower's pitch

forerunners = arrayfun(@(x) diff(x, notes, 'down'), keyPoints);
followers = arrayfun(@(x) diff(x, notes, 'up'), keyPoints);
forerunners(forerunners == -1) = [];
followers(followers == -1) = [];

% map to lowest octave
forerunners = mod(forerunners, 12);
followers = mod(followers, 12);


frequencies = zeros(12,2);
% first column determines interval
frequencies(:,1) = 0:11;

% count frequencies
for j = 0 : 11
    frequencies(j+1,2) = length(find(forerunners == j));
    frequencies(j+1,2) = frequencies(j+1,2) + length(find(followers == j));
end

% sort and get three most common intervals
[~, idx] = sort(frequencies(:,end),'descend');
frequencies = frequencies(idx,:);

% we dont want intervals, that dont occur
% delete them
nonZeroValues = find(frequencies(:,end) ~= 0);
frequencies = frequencies(nonZeroValues, :);

% are there three ore more intervals?
if (size(frequencies,1) < 3)
    % return less than three if there are less
    % fill with -1
    numF = size(frequencies,1);
    intervals = frequencies(1:numF, 1)';
    intervals(numF+1:3) = -1;
else
    % three else
    intervals = frequencies(1:3, 1)';
end

end

function d = diff(x, notes, mode)
    
    % handle for computing pitch at point in time x
    pitch = @(x) mapToPitchOrig(kkkey(seekActiveNotes(x, notes, 'time')), seekActiveNotes(x, notes, 'time'));
    
    neighb = neighbour(x, notes, mode);
    % test wether neighbour has no notes playing
    if (isempty(seekActiveNotes(neighb, notes, 'time'))) 
        d = -1;
    else
        d = abs(pitch(x) - pitch(neighb));
    end
end

function nb = neighbour( x, notes, mode)
    off = notes(end,1) + notes(end,2);
    nb = 0;
    
    % search for forerunner or follower?
    if (strcmp(mode, 'up'))
        i = x+(1/32);
    elseif (strcmp(mode, 'down'))
        i = x-(1/32);
    end
    
    % search for first i such that notes playing at i 
    % and playing at x are not the same
    while (i >= 0) && (i <= off)
        I = seekActiveNotes(i, notes, 'beat');
        X = seekActiveNotes(x, notes, 'beat');
        
        % compare the number of notes
        if ( size(I) == size(X) )
            % if they're the same, compare the notematrices
            if ( I ~= X )
                % neighbour found
                nb = i;
                return;
            end
        else
            % neighbour found
            nb = i;
            return;
        end
        
        % neighbour not found
        if (strcmp(mode, 'up'))
            i = i+(1/32);
        elseif (strcmp(mode, 'down'))
            i = i-(1/32);
        end
        
    end
end




















