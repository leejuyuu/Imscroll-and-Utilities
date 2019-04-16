function rv=func_return_nearest_TOIs2(trajectory, selected, toGraph)

% func_return_nearest_TOIs(trajectory)
%This function returns an n by 3 matrix of trajectories of interest.
%
%
% input:
%   trajectory == trajectory matrix from pkfnd
%                [x y time trajectory_id]
%        the four columns are the x and y coordinates, time, and the id of the selected
%        trajectory.
%output:
%  rv == an n by 3 matrix of trajectories of interest.
%                [x y trajectory id]
%        the three colums are the nearest x y coordinates in the matrix 
%        trajectory relative to those selected in ginpput a        
%        and the trajectory id of the nearest trajectory to the point
%        selected by ginput.
% AO Nov. 2007

global pk_master
if isempty(toGraph)
    toGraph=pk_master;
end
if isempty(selected)
    plot(toGraph(:,1),toGraph(:,2),'k.','markersize',6);
    axis ij equal;axis([1 256 1 300]);
    selected=ginput();
end
[r,c]= size(selected);
result=[];
if c > 3
    result=selected(1,:);
    result=[result(1) result(2) result(4)];
else
    points=[];
    for i=1:r
        store=sqrt((trajectory(:,1)-selected(i,1)).^2 + (trajectory(:,2)-selected(i,2)).^2);
        points=[points;unique(trajectory(find(store==min(store)),4))];
    end
    result=[selected(:,1:2) points];
end
rv=result;