%% glsql_xcorrTableCreate
% 7 Mar 2022
% Perry Hong
%
% Creates xcorr table and its entry in the metadata table
%
% === INPUTS ===
% xtbname: name of table, this name will be used for inserts and other functions
% frequency: center frequency (Hz)
% fs: sampling rate (Hz)
% cutoutlen: length of xcorr (samples)
% s1, s2: names of sensors
% options: Optional Name-Value pair arguments, if unstated, default values are used (refer to arguments below)
%   - fdoa, rfdoa: Booleans for whether or not these values are to be stored in the table
%   - for MATLAB versions before R2021a, input like this: ..., 'fdoa', 1, ...
%   - for MATLAB versions at or after R2021a, can use the above syntax, or ..., fdoa = 1, ...

%% Begin function

function glsql_xcorrTableCreate(dbid, xtbname, frequency, fs, cutoutlen, s1, s2, options)

    arguments
    
        dbid int16
        xtbname char 
        frequency int64
        fs int32
        cutoutlen int32
        s1 char
        s2 char
        options.fdoa logical = 0 
        options.rfdoa logical = 0
    
    end

    %% Optional parameters
    
    options_str = '';

    if options.fdoa
        options_str = [options_str ', fdoa REAL, fdoa_sigma REAL'];
    end

    if options.rfdoa
        options_str = [options_str ', rfdoa REAL, rfdoa_sigma REAL'];
    end
 
    %% CREATE table and INSERT entry into metadata table
    
    mksqlite(dbid, ['CREATE TABLE ' xtbname ' (xidx INTEGER PRIMARY KEY, time REAL, tidx INTEGER, qf2 REAL, tdoa REAL, tdoa_sigma REAL' options_str ')']); % will throw error if table with that name already exists
    mksqlite(dbid, 'INSERT INTO meta_xcorrs (xtbname, frequency, fs, cutoutlen, s1, s2, fdoa, rfdoa) VALUES (?,?,?,?,?,?,?,?)', {xtbname, frequency, fs, cutoutlen, s1, s2, options.fdoa, options.rfdoa});

    disp(['xcorr table "' xtbname '" created.']);
    
end
