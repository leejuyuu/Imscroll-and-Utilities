function pc=probability_choice(tbl,N)
%
% function probability_choice(tbl,N)
%
% Each time this function is called it will  return a vector of length 'N' 
% listing table entries (from tbl(:,1)) that occur with a probability based on tbl(:,2)
% That is, the number tbl(i,1) will occur in the list of N values with
% a probability given by tbl(i,2) so long as sum(tbl(:,2))=1;
%
% tbl ==[ number   probability], an Nx2 table (distribution) of possible step sizes
%                   [number(:)] and the probability that each such number(m) will occur in the
%                   output vector list.
% N == the number of values that will be returned in the output vector array

    % First need to put the tbl(:,2) into a monatonically increasing 
    % cumulative format
cumtbl=cumsum(tbl(:,2));        % cumtbl will have same number of entries as tbl(:,2)
                    % Now form the edges matrix
if abs(sum(tbl(:,2))-1)>1E-10
    error('table probabilities do not sum to 1: for such usage consider employing probability_steps( )')
    return
end
edges=[0 cumtbl'];          % Defines the edges of our bins
                            % Each bin will be of a width given by the probabilities
                            % in tbl(:,2).
                            % In picking a random number between 0 and 1,
                            % the probability of landing in any bin will be
                            % proportional to the bin width, i.
                            % proportional to the probability in tbl(:,2)

randoms=rand(1,N);          % Pick N random numbers between 0 and 1
[Num Bins]=histc(randoms,edges);
pc=tbl(Bins,1);         % Bins provides indices into the bins, which is equivalent
                        % to indices into the tbl(:,1)