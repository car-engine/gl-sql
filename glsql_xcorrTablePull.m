%% glsql_xcorrTablePull
% 7 Mar 2022
% Perry Hong
%
% Pulls xcorrs fulfilling specified criteria
%
% === INPUTS ===
% xtbname: xcorr table from which data is to be pulled 
% options: optional name-value pair arguments for filtering 
%   - time, qf2, tdoa, fdoa, rfdoa: [lower_limit upper_limit]
%   - for MATLAB versions before R2021a, input like this: ..., 'qf2', [0.6 1], ...
%   - for MATLAB versions at or after R2021a, can use the above syntax, or ..., qf2 = [0.6 1], ...

%% Begin function

function output = glsql_xcorrTablePull(dbid, xtbname, options)

    arguments

        dbid int16
        xtbname char 
        options.time (1,2) double 
        options.qf2 (1,2) double
        options.tdoa (1,2) double
        options.fdoa (1,2) double
        options.rfdoa (1,2) double
        
    end

    %% Check if this xcorr table has optional parameters
    bools = mksqlite(dbid, ['SELECT fdoa, rfdoa FROM meta_xcorrs WHERE xtbname = "' xtbname '"']);

    select_str = 'SELECT time, tidx, qf2, tdoa, tdoa_sigma';
    
    % Pull fdoa and rfdoa if they exist
    if bools.fdoa
        select_str = [select_str ', fdoa, fdoa_sigma'];
    end
    
    if bools.rfdoa
        select_str = [select_str ', rfdoa, rfdoa_sigma'];
    end
    
    %% Filter
    sql_filters = {};

    if isfield(options, 'time')
        sql_filters = [sql_filters ['time > ' num2str(options.time(1))]];
        sql_filters = [sql_filters ['time < ' num2str(options.time(2))]];
    end
    
    if isfield(options, 'tidx')
        sql_filters = [sql_filters ['tidx > ' num2str(options.tidx(1))]];
        sql_filters = [sql_filters ['tidx < ' num2str(options.tidx(2))]];
    end

    if isfield(options, 'qf2')
        sql_filters = [sql_filters ['qf2 > ' num2str(options.qf2(1))]];
        sql_filters = [sql_filters ['qf2 < ' num2str(options.qf2(2))]];
    end

    if isfield(options, 'tdoa')
        sql_filters = [sql_filters ['tdoa > ' num2str(options.tdoa(1))]];
        sql_filters = [sql_filters ['tdoa < ' num2str(options.tdoa(2))]];
    end

    if isfield(options, 'fdoa')
        sql_filters = [sql_filters ['fdoa > ' num2str(options.fdoa(1))]];
        sql_filters = [sql_filters ['fdoa < ' num2str(options.fdoa(2))]];
    end

    if isfield(options, 'rfdoa')
        sql_filters = [sql_filters ['rfdoa > ' num2str(options.rfdoa(1))]];
        sql_filters = [sql_filters ['rfdoa < ' num2str(options.rfdoa(2))]];
    end
    
    filter_str = '';

    if ~isempty(sql_filters)

        filter_str = ' WHERE ';

        for n = 1:length(sql_filters)-1
            filter_str = [filter_str sql_filters{n} ' AND ' ];
        end

        filter_str = [filter_str sql_filters{end}]; 

    end

    %% SELECT

    output = mksqlite(dbid, [select_str ' FROM ' xtbname filter_str]);

end