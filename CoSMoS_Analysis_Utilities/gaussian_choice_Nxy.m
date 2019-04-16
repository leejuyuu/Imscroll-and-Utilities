function pc=gaussian_choice_Nxy(xy_std_mat)
%
% function gaussian_choice_Nxy(xy_std_mat)
%
% xy_std_mat==  [xi yi std(xi) std(yi) ] 

%  This function is intended to be used while bootstrapping fits.    
%  The user inputs a set of data specifying the set of
%  x values (xi) and y values (yi) together with the uncertainties (standard
%  deviation) for each x and y.  The output will be a set of x and y values
%  The function will then output a set of x and y values (equal in number
%  to that of the input set) in which each of the xy pairs is stochastically 
%  chosen from the x and y gaussian distributions
% in both x and y.
[rose col]=size(xy_std_mat);
if col~=4
    error('input matrix must contain 4 columns')
end
outs=zeros(rose,2);     % reserve space for output
for indx=1:rose
                % Each cycle through the loop stocastically chooses one
                % xy pair
  %[gaussian_choice(xi,std(xi)  gaussian_choice(yi,std(yi))]
    outs(indx,:)=[gaussian_choice(xy_std_mat(indx,1),xy_std_mat(indx,3)) ...
        gaussian_choice(xy_std_mat(indx,2),xy_std_mat(indx,4))];
end
pc=outs;
