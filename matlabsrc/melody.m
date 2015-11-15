function [ var ratioMax ratioMin ratioLength ] = melody( notes, p )
%melody examines a melody-notematrix in terms
%of contour and structure
%   Input:
%           notes: nmat containing a melody (no harmony track!)
%           p:     critical value for distinguishing 
%                  between short and long notes
%   Output:
%           var:         variance of the melody
%           ratioMax:    ratio of #appearances of highest
%                        note to duration of nmat
%           ratioMin:    ratio of #appearances of lowest
%                        note to duration of nmat
%           ratioLength: ratio of short notes (<=p) to #notes
duration = notes(end,6) + notes(end,7);
notesPitch = notes(:,4);
notesDurBeat = notes(:,2);
maximum = max(notesPitch);
minimum = min(notesPitch);
n = length(notesPitch);

% variance
avg = mean(notesPitch);
var = sum((notesPitch - avg).^2)/(n-1);

% count maximum's and minimum's appearances
ratioMax = length(find(notesPitch == maximum))/duration;
ratioMin = length(find(notesPitch == minimum))/duration;

% count "short" (<p) notes
ratioLength = length(find(notesDurBeat <= p))/n;
end

