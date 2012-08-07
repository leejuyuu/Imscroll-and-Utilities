function [u, L, vb, vit, phi] = eb_hmm(data, u0, varargin)
% [u, L, vb, vit, phi] = eb_hmm(data, u0, varargin)
%
% Runs a empirical Bayes inferenceon a collection of single 
% molecule FRET time series (or traces) using a Hidden Markov Model.
%
% The inference process iteratively performs two steps:
%
% 1. Run Variational Bayes Expectation Maximization (VBEM)
%    on each Time Series. 
%
%    This yields two distributions q(theta | w) and q(z) that approximate
%    the posterior over the model parameters and latent states 
%    for each trace.
%
% 2. Update the hyperparameters for the distribution p(theta | u).
%
%    This distribution, which plays the role of a prior on the 
%    parameters in the VBEM iterations, represents an aggregate
%    over the ensemble of time series, reporting on both the average
%    parameter value and the variability from molecule to molecule.
%    
%
% Inputs
% ------
%
%   data : (N x 1) cell 
%     Time series data on which inference is to be performed.
%     Each data{n} should be a 1d vector of time points.
%   
%   u0 : (M x 1) struct 
%     Initial guesses for hyperparameters of the ensemble distribution
%     p(theta | u) over the model parameters (i.e. the VBEM prior).
%
%     .A : (K x K)
%         Dirichlet prior for each row of transition matrix
%     .pi : (K x 1)
%         Dirichlet prior for initial state probabilities
%     .mu : (K x D)
%         Normal-Wishart prior - state means 
%     .beta : (K x 1)
%         Normal-Wishart prior - state occupation count
%     .W : (K x D x D)
%         Normal-Wishart prior - state precisions
%     .nu : (K x 1)
%         Normal-Wishart prior - degrees of freedom
%         (must be equal to beta+1)
%
%     Note: The current implementation only supports D=1 signals
%
%   w0 : (N x M) or (N x 1) struct (optional)
%     Intial guesses for VBEM variational parameters. 
%    
%
% Variable Inputs
% ---------------
%
%   threshold : float
%     Convergence threshold. Execution halts when fractional increase 
%     in total summed evidence drops below this value.
%
%   max_iter : int (default 100)
%     Maximum number of iterations 
%
%   restarts : int
%     Number of VBEM restarts to perform for each trace.
%
%   do_restarts : {'init', 'always'} (default: 'init')
%     Specifies whether restarts should be performed only when 
%     determining the initial value of w (default, faster), or at 
%     every hierarchical iteration (slower, but in some cases more 
%     accurate).
%
%   soft_kmeans : {'off', 'init', 'always'} (default: 'init')
%     Runs Gaussian Mixture Model EM algorithm on trace when
%     initializing posterior parameters. Can be used on initial
%     iteration only, or all iterations.
%
%   display : {'hstep', 'trace', 'off'} (default: 'off')
%     Print status information.
%
%   shared_priors : cell of {'muLambda', 'A', 'pi'} (default: {})
%     If performing inference over a mixture of priors, this variable 
%     specifies which priors are assumed to be shared between 
%     populations. E.g. {'A', 'pi'} would assume a single prior on
%     A and pi, whilst the emission model parameters mu and Lambda
%     are assumed to have separate priors for each subpopulation.     
%
%   vbem : struct
%     Struct storing variable inputs for VBEM algorithm
%     (see function documentation)
%
%
% Outputs
% -------
%
%   u : (M x 1) struct
%     Optimized hyperparameters (same fields as u0)
%
%   L : (I x 1) 
%     Total lower bound summed over all traces for each 
%     Empirical Bayes iteration 
%
%   vb : (N x M) struct
%     Output of VBEM algorithm for each trace
%
%     .w : struct
%         Variational parameters for appromate posterior q(theta | w) 
%         (same fields as u)
%     .L : float
%         Lower bound for evidence
%
%   vit : (N x 1) struct
%     Viterbi paths for each trace
%
%     .x : (T x 1)
%         FRET level of viterbi path for every time point
%     .y : int
%         Mixture component for trace
%     .z : (T x 1)
%         State index of viterbi path for every time point
%
%   phi : (N x M)
%       Responsibilities for each trace and mixture component
%
% Jan-Willem van de Meent
% $Revision: 1.0$  $Date: 2011/08/04$

% parse inputs
ip = inputParser();
ip.StructExpand = true;
ip.addRequired('data', @iscell);
ip.addRequired('u0', @isstruct);
ip.addOptional('w0', struct(), @(w) isstruct(w) & isfield(w, 'mu'));
ip.addParamValue('threshold', 1e-5, @isscalar);
ip.addParamValue('max_iter', 100, @isscalar);
ip.addParamValue('restarts', 10, @isscalar);
ip.addParamValue('do_restarts', 'init', ...
                  @(s) any(strcmpi(s, {'always', 'init'})));
ip.addParamValue('soft_kmeans', 'init', ...
                  @(s) any(strcmpi(s, {'always', 'init', 'off'})));
ip.addParamValue('shared_priors', {}, ...
                  @(a) iscell(a) & all(cellfun(@(s) any(strcmpi(s, {'muLambda', 'A', 'pi'})), a)));
ip.addParamValue('display', 'off', ...
                  @(s) any(strcmpi(s, {'hstep', 'trace', 'off'})));
ip.addParamValue('vbem', struct(), @isstruct);
ip.parse(data, u0, varargin{:});

try
    % collect inputs
    args = ip.Results;
    data = args.data;
    u0 = args.u0;

    % get dimensions
    N = length(data);
    M = length(u0);
    K = length(u0(1).pi);

    % main loop for empirical bayes inference process
    % (note: we check for convergence in loop)
    it = 1;
    u(it, :) = u0;
    while true
        % initialize guesses for w    
        if (it == 1) | strcmpi(args.do_restarts, 'always')
            R = args.restarts;
            % on first iteration, initial values for w are either 
            % supplied as arguments, or inferred by running a gaussian
            % mixture model on the data
            %
            % on subsequent iterations, the result from the previous
            % iteration is used in the fist restart

            if (strcmpi(args.display, 'hstep') | strcmpi(args.display, 'trace'))
                fprintf('[%s] eb: %d states, it %d, initializing w\n', ...
                         datestr(now, 'yymmdd HH:MM:SS'), K, it)
            end

            % are we doing soft kmeans?
            soft_kmeans = isequal(args.soft_kmeans, 'always') | ((it == 1) & isequal(args.soft_kmeans, 'init'));

            clear w0;
            if (it == 1)
                switch length(args.w0(:))
                    case N*M
                        [w0(:, :, 1)] = orderfields(args.w0, fieldnames(u0));
                    case N
                        for m = 1:M
                            [w0(:, m, 1)] =  orderfields(args.w0(:), fieldnames(u0));
                        end
                    otherwise
                        for n = 1:N
                            if strcmpi(args.display, 'trace')
                                fprintf('[%s] eb: %d states, it %d, trace %d of %d\n', ...
                                         datestr(now, 'yymmdd HH:MM:SS'), K, 0, n, N);
                            end    
                            for m = 1:M
                                % draw w0 from prior u0
                                w0(n, m, 1) =  init_w_hmm(data{n}, u0(m), 'soft_kmeans', soft_kmeans);
                                % % set prior on mixture components
                                % w0(n, m, 1).omega = 1/M + u0(m).omega;
                            end
                        end
                end
            else
                % use value from previous iteration
                w0(:, :, 1) = reshape(w(it-1, :, :), [N M]);
            end

            % additional restarts use a randomized guess for the
            % prior parameters
            for r = 2:R
                for n = 1:N
                    for m = 1:M
                        % draw w0 from prior u for other restarts
                        w0(n, m, r) = init_w_hmm(data{n}, u(it, m), 'soft_kmeans', soft_kmeans);
                        % % set prior on mixture components
                        % w0(n, m, r).omega = 1/M + u(it, m).omega;
                    end
                end
            end
        else
            % only do one restart and use w from last iteration as guess
            R = 1;
            w0(:, :, 1) = reshape(w(it-1, :, :), [N M]);
        end

        if (strcmpi(args.display, 'hstep') | strcmpi(args.display, 'trace'))
            fprintf('[%s] eb: %d states, it %d, running VBEM\n', ...
                     datestr(now, 'yymmdd HH:MM:SS'), K, it)
        end

        % run vbem on each trace 
        L(it,:,:) = -Inf * ones(N, M);
        for n = 1:N
            if strcmpi(args.display, 'trace')
                fprintf('[%s] eb: %d states, it %d, trace %d of %d\n', ...
                         datestr(now, 'yymmdd HH:MM:SS'), K, it, n, N);
            end 
            % loop over prior mixture components
            for m = 1:M
                % loop over restarts
                for r = 1:R
                    [w_, L_, stat_] = vbem_hmm(data{n}, w0(n, m, r), u(it, m), args.vbem);
                    % keep result if L better than previous restarts
                    if L_(end) > L(it, n, m)
                        w(it, n, m) = w_;
                        L(it, n, m) = L_(end);
                        restart(n, m) = r;
                    end
                end
            end
        end

        % normalize evidence to avoid underflow/overflow
        L_it = reshape(L(it, :, :), [N M]);
        L_it0 = bsxfun(@minus, L_it , mean(L_it, 2));

        % EM updates for prior mixture components
        jt = 1;
        sL_(jt) = -inf;
        omega = 1./M * ones(1, M);
        while true
            % E-step: calculate exp value of y(m) under q(y),
            % i.e. posterior p(y | x, omega)
            %
            % phi(n,m) = E_q(y(n)) [y(n,m)]
            %          = p(y(n)=m | x(n), omega)
            
            % calculate joint p(y, omega)
            p_yo = bsxfun(@times, exp(L_it0), omega);
            % catch overflows
            p_yo(isinf(p_yo)) = 1 / eps;
            % normalize to get posterior
            phi = normalize(p_yo, 2);
            
            % calculate summed evidence
            sL_(jt) = sum(sum(phi .* L_it, 2), 1);

            % check for convergence
            if ((jt > 1) ...
                & abs(1 - sL_(jt-1) / sL_(jt)) < args.threshold) ...
                | jt >= args.max_iter
                break;
            end

            % M-step: update omega
            omega = normalize(sum(phi, 1));

            % increment loop counter
            jt = jt + 1;
        end

        % store summed evidence
        sL(it) = sL_(jt);

        if strcmpi(args.display, 'hstep') | strcmpi(args.display, 'trace')
            fprintf('[%s] eb K: %d, M: %d,  it: %d, L: %e, rel increase: %.2e, randomized: %.3f\n', ...
                    datestr(now, 'yymmdd HH:MM:SS'), K, M, it, sL(it), (sL(it)-sL(max(it-1,1)))/sL(it), sum(restart(:)~=1) / length(restart(:)));
        end    

        % check for convergence
        if ((it > 1) & (abs((sL(it) - sL(it-1))) < args.threshold * abs(sL(it-1)))) | (it >= args.max_iter)
            break;
        end

        % run hierarchical updates
        clear u_;
        if any(strcmpi('muLambda', args.shared_priors))
            [u_(1:M)] = deal(hstep_nw(reshape(w(it, :, :), [N*M 1])));
        else
            for m = 1:M
                u_(m) = hstep_nw(w(it, :, m), phi(:, m));
            end
        end
        if any(strcmpi('A', args.shared_priors))
            [u_(1:M).A] = deal(hstep_dir({w(it, :, :).A}));
        else
            for m = 1:M
                u_(m).A = hstep_dir({w(it, :, m).A}, phi(:, m));
            end
        end
        if any(strcmpi('pi', args.shared_priors))
            [u_(1:M).pi] = deal(hstep_dir({w(it, :, :).pi}));
        else
            for m = 1:M
                u_(m).pi = hstep_dir({w(it, :, m).pi}, phi(:, m));
            end
        end

        % proceed with next iteration
        u(it+1, :) = orderfields(u_(:), fieldnames(u));
        it = it + 1;
    end

    % place vbem output in struct 
    for n = 1:N
        for m = 1:M
            vb(n,m) = struct('w', w(it,n,m), ...
                             'L', L(it,n,m), ...
                             'restart', restart(n,m));
        end
    end

    % calculate viterbi paths
    for n = 1:N
        m = find(phi(n,:) == max(phi(n,:)));
        [vit(n).z, vit(n).x] = viterbi_vb(w(it,n,m), data{n});
        vit(n).y = m; 
    end 

    % assign outputs
    L = sL(1:it);
    u = u(it,:);

catch ME
    % ok something went wrong here, so dump workspace to disk for inspection
    day_time =  datestr(now, 'yymmdd-HH.MM');
    save_name = sprintf('crashdump-eb-%s.mat', day_time);
    save(save_name);

    rethrow(ME);
end
