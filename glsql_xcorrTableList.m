%% glsql_xcorrTableList
% 7 Mar 2022
% Perry Hong
%
% Returns metadata of all xcorr tables in the database

%% Begin function

function xcorrTables = glsql_xcorrTableList(dbid) 

    xcorrTables = mksqlite(dbid, 'SELECT * FROM meta_xcorrs');
        
end