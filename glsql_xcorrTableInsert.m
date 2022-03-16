%% glsql_xcorrTableInsert
% 7 Mar 2022
% Perry Hong
%
% Inserts entry into an existing xcorr table
%
% === INPUTS ===
% xtbname: xcorr table to which data is to be inserted into
% insert_vals: cell array {time, tidx, qf2, tdoa, tdoa_sigma, fdoa, fdoa_sigma, rfdoa, rfdoa_sigma}
%   - ignore optional fields if they don't exist in the table
%   - if a field exists in the table but you want to leave it empty in the entry, replace with []
%
% === OUTPUT ===
% xidx: xidx of row that was just inserted

%% Begin function

function xidx = glsql_xcorrTableInsert(dbid, xtbname, insert_vals)

    arguments

        dbid int16
        xtbname char 
        insert_vals cell

    end
    
    %% Optional parameters
    
    % Check if this xcorr table has optional parameters
    bools = mksqlite(dbid, ['SELECT fdoa, rfdoa FROM meta_xcorrs WHERE xtbname = "' xtbname '"']);

    insert_str = repmat(',?,?', 1, bools.fdoa + bools.rfdoa);
    
    options_str = '';
    
    if bools.fdoa
        options_str = [options_str ', fdoa, fdoa_sigma'];
    end
    
    if bools.rfdoa
        options_str = [options_str ', rfdoa, rfdoa_sigma'];
    end
    
    %% INSERT
    
    % Check if number of arguments in insert_vals is correct
    if length(insert_vals) ~= (5 + 2*(bools.fdoa + bools.rfdoa))
        error('Number of arguments in insert_vals is incorrect! Check xcorr table parameters using glsql_xcorrTableQuery.');
    else
        mksqlite(dbid, ['INSERT INTO ' xtbname ' (time, tidx, qf2, tdoa, tdoa_sigma' options_str ') VALUES (?,?,?,?,?' insert_str ')'], insert_vals);
    end
    
    % Return xidx of row that was just inserted
    xidx = mksqlite(['SELECT xidx FROM ' xtbname ' WHERE rowid = last_insert_rowid()']);
    xidx = xidx.xidx;

end