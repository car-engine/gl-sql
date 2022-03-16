%% glsql_glTablePull_xcorrSingle
% 7 Mar 2022
% Perry Hong
%
% Pulls GLs fulfilling specified criteria
% This function is only usable when each GL is generated from a single xcorr (npairs = 1, multi = 0)
%
% === INPUTS ===
% gtbname: GL table from which data is to be pulled 
% options: optional name-value pair arguments for filtering 
%   - time, qf2, tdoa, fdoa, rfdoa, latitude, longitude: [lower_limit upper_limit]
%   - for MATLAB versions before R2021a, input like this: ..., 'qf2', [0.6 1], ...
%   - for MATLAB versions at or after R2021a, can use the above syntax, or ..., qf2 = [0.6 1], ...

%% Begin function

function output = glsql_glTablePull_xcorrSingle(dbid, gtbname, options)

    arguments

        dbid int16
        gtbname char 
        options.time (1,2) double 
        options.qf2 (1,2) double
        options.tdoa (1,2) double
        options.latitude (1,2) double
        options.longitude (1,2) double
        
    end

    %% Do check to ensure npairs = 1, multi = 0

    gtb_options = mksqlite(dbid, ['SELECT npairs, multi, ecef, lla, error FROM meta_gls WHERE gtbname = "' gtbname '"']);

    if gtb_options.npairs ~= 1 

        error('Require npairs = 1 to use glsql_glTablePull_single! Check GL table parameters!');

    elseif gtb_options.multi
        
        error('Require multi = 0 to use glsql_glTablePull_single! Check GL table parameters!')

    end

    %% Check parameters to pull for this GL table

    gl_select_str = '';

    if gtb_options.ecef
        gl_select_str = [gl_select_str ', g.x, g.y, g.z'];
    end

    if gtb_options.lla
        gl_select_str = [gl_select_str ', g.latitude, g.longitude, g.altitude'];
    end

    if gtb_options.error
        gl_select_str = [gl_select_str ', g.major, g.minor, g.angle'];
    end

     
    %% Filters

    sql_filters = {};

    if isfield(options, 'time')
        sql_filters = [sql_filters ['x.time > ' num2str(options.time(1))]];
        sql_filters = [sql_filters ['x.time < ' num2str(options.time(2))]];
    end

    if isfield(options, 'qf2')
        sql_filters = [sql_filters ['x.qf2 > ' num2str(options.qf2(1))]];
        sql_filters = [sql_filters ['x.qf2 < ' num2str(options.qf2(2))]];
    end

    if isfield(options, 'tdoa')
        sql_filters = [sql_filters ['x.tdoa > ' num2str(options.tdoa(1))]];
        sql_filters = [sql_filters ['x.tdoa < ' num2str(options.tdoa(2))]];
    end

    if isfield(options, 'fdoa')
        sql_filters = [sql_filters ['x.fdoa > ' num2str(options.fdoa(1))]];
        sql_filters = [sql_filters ['x.fdoa < ' num2str(options.fdoa(2))]];
    end

    if isfield(options, 'rfdoa')
        sql_filters = [sql_filters ['x.rfdoa > ' num2str(options.rfdoa(1))]];
        sql_filters = [sql_filters ['x.rfdoa < ' num2str(options.rfdoa(2))]];
    end
    
    if isfield(options, 'latitude')
        sql_filters = [sql_filters ['g.latitude > ' num2str(options.latitude(1))]];
        sql_filters = [sql_filters ['g.latitude < ' num2str(options.latitude(2))]];
    end
    
    if isfield(options, 'longitude')
        sql_filters = [sql_filters ['g.longitude > ' num2str(options.longitude(1))]];
        sql_filters = [sql_filters ['g.longitude < ' num2str(options.longitude(2))]];
    end

    filter_str = '';

    if ~isempty(sql_filters)

        for n = 1:length(sql_filters)
            filter_str = [filter_str ' AND ' sql_filters{n} ];
        end

    end

    %% Loop over all xtbidx and SELECT

    unique_xtbidx = mksqlite(dbid, ['SELECT DISTINCT xtbidx1 FROM ' gtbname]);

    output = [];
    
    for current_xtbidx = unique_xtbidx.'

        % Name of table with this xtbidx
        current_xtbname = mksqlite(dbid, ['SELECT xtbname FROM meta_xcorrs WHERE xtbidx = ' num2str(current_xtbidx.xtbidx1)]);
        xtbname = current_xtbname.xtbname;

        xcorr_select_str = 'x.time, x.tidx, x.qf2, x.tdoa, x.tdoa_sigma';

        % Check optional parameters to pull from this xcorr table
        xtb_options = mksqlite(dbid, ['SELECT fdoa, rfdoa FROM meta_xcorrs WHERE xtbname = "' xtbname '"']);
     
        if xtb_options.fdoa
            xcorr_select_str = [xcorr_select_str ', x.fdoa, x.fdoa_sigma'];
        end
        
        if xtb_options.rfdoa
            xcorr_select_str = [xcorr_select_str ', x.rfdoa, x.rfdoa_sigma'];
        end

        output = [output; mksqlite(dbid, ['SELECT g.xtbidx1, g.xidx1, ' xcorr_select_str gl_select_str ' FROM ' gtbname ' g INNER JOIN ' xtbname  ' x ON g.xidx1 = x.xidx ' ...
            'WHERE g.xtbidx1 = ' num2str(current_xtbidx.xtbidx1) filter_str])];

    end

end