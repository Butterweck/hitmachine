function [ avg s2 ] = computeD( notes, step, timeSigNum )
%computeD returns distance index of nmat notes
%   Input:
%           notes: notematrix
%           step: vector of numbers of bars to shift
%           timeSigNum: numerator of time signature
%           (= beats per bar)
%   Output:
%           avg: average difference of signal and
%           signal shifted by step bars
%           s2: variance
%
avg = zeros(length(step),1);
s2 = zeros(length(step),1);

dur = notes(end, 7);
beat = notes(end, 2);
beatsPerSec = beat/dur;
SecPerBeat = dur/beat;
trackLength = max(notes(:,6) + notes(:,7)); 
nBeats = beatsPerSec * trackLength;

nBars = nBeats / timeSigNum;
f = @(x,y) abs(x-y);
m = SecPerBeat/4;

% segment notes in m intervals
c = cache(notes, m);

% distance matrix
mat = computeMatrix(c, f);

nIntervals = size(mat, 1);
b = ceil(nIntervals/nBars);

% function handle for accesing mat at column j
% and corresponding row for computing distance
p = @(j,s) mat(mod(j + b*s - 1, nIntervals) + 1, j);

% compute avg and s2 for every given step
for count = 1 : length(step)
    coefficients = arrayfun(@(j) p(j, step(count)), 1 : nIntervals);
    avg(count) = sum(coefficients/nIntervals);
    s2(count) = sum((coefficients - avg(count)).^2)/(nIntervals - 1);
end

avg = avg';
s2 = s2';

end