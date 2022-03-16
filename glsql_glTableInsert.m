%% glsql_glTableInsert
% 7 Mar 2022
% Perry Hong
%
% Inserts entry into an existing GL table
%
% === INPUTS ===
% gtbname: GL table to which data is to be inserted into
% insert_vals: cell array {xtbidx1, xidx1, xtbidx2, xidx2, ..., x, y, z, latitude, longitude, altitude, major, minor, angle}
%   - ignore optional fields if they don't exist in the table
%   - if a field exists in the table but you want to leave it empty in the entry, replace with []
%
% === OUTPUT ===
% gidx: gidx of row that was just inserted

%% Begin function

function gidx = glsql_glTableInsert(dbid, gtbname, insert_vals)

    arguments

        dbid int16
        gtbname char 
        insert_vals cell

    end
    
    %% Optional parameters
    
    % Check if this GL table has optional parameters
    options = mksqlite(dbid, ['SELECT npairs, ecef, lla, error FROM meta_gls WHERE gtbname = "' gtbname '"']);

    insert_str = repmat(',?', 1, 2*options.npairs + 3*(options.ecef + options.lla + options.error));
    insert_str = insert_str(2:end); % remove the first ","
    
    options_str = '';
    
    % Number of xcorr pairs (tables) used
    for n = 1:options.npairs
        current_xtbidx = ['xtbidx' num2str(n)];
        current_xidx = ['xidx' num2str(n)];
        options_str = [options_str [', ' current_xtbidx ', ' current_xidx]];
    end
    
    if options.ecef
        options_str = [options_str ', x, y, z'];
    end
    
    if options.lla
        options_str = [options_str ', latitude, longitude, altitude'];
    end
    
    if options.error
        options_str = [options_str ', major, minor, angle'];
    end
    
    options_str = options_str(3:end); % remove the first ", "
    
    %% INSERT
    
    % Check if number of arguments in insert_vals is correct
    if length(insert_vals) ~= (2*options.npairs + 3*(options.ecef + options.lla + options.error))
        error('Number of arguments in insert_vals is incorrect! Check GL table parameters using glsql_glTableQuery.');
    else
        mksqlite(dbid, ['INSERT INTO ' gtbname ' (' options_str ') VALUES (' insert_str ')'], insert_vals);
    end

    % Return xidx of row that was just inserted
    gidx = mksqlite(['SELECT gidx FROM ' gtbname ' WHERE rowid = last_insert_rowid()']);
    gidx = gidx.gidx;

end