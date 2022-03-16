%% glsql_glTableList
% 7 Mar 2022
% Perry Hong
%
% Returns metadata of all GL tables in the database

%% Begin function

function glTables = glsql_glTableList(dbid) 

    glTables = mksqlite(dbid, 'SELECT * FROM meta_gls');
        
end