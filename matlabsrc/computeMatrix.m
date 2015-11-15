function [ mat ] = computeMatrix( cache, f )
%computeMatrix returns matrix that 
%contains f(cache(i), cache(j)) at mat(i,j)
%   Input:
%           cache: vector of notes
%           f: elementary similarity function for notes
%           (is being passed to similarity(g,h,f))
%   Output:
%           mat: resulting matrix

n = length(cache);
mat = zeros(n,n);

for i = 1 : n
    for j = 1 : n
        mat(i,j) = similarity(cache(i), cache(j), f);
    end
end

end

