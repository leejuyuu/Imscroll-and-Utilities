function opts = em_defaults()
    opts = struct(...
             'threshold', 1e-5, ...
             'max_iter', 100, ...
             'ignore', 'none');