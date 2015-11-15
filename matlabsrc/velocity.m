function [ vel ] = velocity( notes, mode )
%velocity returns max/sum of velocity of nmat notes
%   Input:
%           notes:  nmat
%           mode:   'max' or 'sum'
%           (maximum or summed up velocity)
%   Output:
%           vel:    max/summed up velocity

if (strcmp(mode, 'max'))
    vel = unique(max(notes(:,5)));
elseif (strcmp(mode, 'sum'))
    vel = sum(notes(:,5));
end

if (isempty(vel))
    vel = 0;
end

end

