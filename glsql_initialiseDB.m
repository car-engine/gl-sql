%% glsql_initialiseDB
% 7 Mar 2022
% Perry Hong
%
% Initialises database with metadata tables for xcorrs and gls

%% Begin function

function dbid = glsql_initialiseDB(dbname)

    if isfile(dbname)
        
        error('Database already exists!');

    else
       
        dbid = mksqlite('open', dbname);

        mksqlite(dbid, 'CREATE TABLE IF NOT EXISTS meta_xcorrs (xtbidx INTEGER PRIMARY KEY, xtbname TEXT, frequency REAL, fs INTEGER, cutoutlen INTEGER, s1 TEXT, s2 TEXT, fdoa NUMERIC, rfdoa NUMERIC)');
        mksqlite(dbid, 'CREATE TABLE IF NOT EXISTS meta_gls (gtbidx INTEGER PRIMARY KEY, gtbname TEXT, npairs INTEGER, multi NUMERIC, ecef NUMERIC, lla NUMERIC, error NUMERIC)');

    end
    
    disp('Database successfully initialised!');
    
end