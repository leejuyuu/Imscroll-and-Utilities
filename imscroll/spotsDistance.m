function distance = spotsDistance(centerXY,pointsXY)
if numel(pointsXY)~=0
difference(:,1) = pointsXY(:,1) - centerXY(1);
difference(:,2) = pointsXY(:,2) - centerXY(2);
distance = sqrt(sum(difference.^2,2));
else
    distance = [inf, inf];
end
end