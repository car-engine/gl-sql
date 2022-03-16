%% glsql_xcorrTableCreate
% 7 Mar 2022
% Perry Hong
%
% Creates GL table and its entry in the metadata table
%
% === INPUTS ===
% xtbname: name of table, this name will be used for inserts and other functions
% options: optional name-value pair arguments, if unstated, default values are used (refer to arguments below)
%   - npairs: Number of xcorr pairs (i.e. tables) that were used to generate this GL point
%   - multi: Boolean for whether or not multiple xcorrs were used from each table to generate this GL point
%   - ecef, lla, error: Booleans for whether or not these values are to be stored in the table
%   - for MATLAB versions before R2021a, input like this: ..., 'ecef', 1, ...
%   - for MATLAB versions at or after R2021a, can use the above syntax, or ..., ecef = 1, ...

%% Begin function

function glsql_glTableCreate(dbid, gtbname, options)

    arguments

        dbid int16
        gtbname char 
        options.npairs int16 {mustBePositive} = 1
        options.multi logical = 0
        options.ecef logical = 0
        options.lla logical = 1
        options.error logical = 1
        
    end

    %% Optional parameters
    
    if ~options.multi
        multi_type = ' INT';
    else
        multi_type = ' BLOB';
    end

    options_str = '';

    % Number of xcorr pairs (tables) used
    for n = 1:options.npairs
        current_xtbidx = ['xtbidx' num2str(n)];
        current_xidx = ['xidx' num2str(n)];
        options_str = [options_str, ',' current_xtbidx ' INTEGER, ' current_xidx multi_type];
    end

    if options.ecef
        options_str = [options_str ', x REAL, y REAL, z REAL'];
    end

    if options.lla
        options_str = [options_str ', latitude REAL, longitude REAL, altitude REAL'];
    end

    if options.error
        options_str = [options_str ', major REAL, minor REAL, angle REAL'];
    end

    %% CREATE table and INSERT entry into metadata table
    
    mksqlite(dbid, ['CREATE TABLE ' gtbname ' (gidx INTEGER PRIMARY KEY' options_str ')'])
    mksqlite(dbid, 'INSERT INTO meta_gls (gtbname, npairs, multi, ecef, lla, error) VALUES (?,?,?,?,?,?)', {gtbname, options.npairs, options.multi, options.ecef, options.lla, options.error});
    
    disp(['GL table "' gtbname '" created.']);
    
end