function data = bound(data,upperbound,lowerbound)
for i = 1:numel(data)
    data(i)  = min(max(data(i),lowerbound),upperbound);
end
end
