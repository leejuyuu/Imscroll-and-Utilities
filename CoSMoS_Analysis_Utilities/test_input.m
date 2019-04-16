function pc=test_input(a,varargin)
if exist(varargin{1})
    sprintf('yes')
    pc=1
else
    pc=0
end

