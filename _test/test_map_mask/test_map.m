classdef test_map < TestCaseWithSave
    % test_mask  Tests IX_mask class
    
    methods
        %--------------------------------------------------------------------------
        function self = test_map (name)
            self@TestCaseWithSave(name);
            self.save()
        end
        
        %--------------------------------------------------------------------------
        % Test constructor
        %--------------------------------------------------------------------------
%         function test_empty_constructor (self)
%             % Test the empty constructor
%             wref = IX_map([], 'wkno', 99);
%             assertTrue (isequal(w,wtmp), 'Write+read does not make an identity');
%         end
        
        %--------------------------------------------------------------------------
        % Test constructor
        %--------------------------------------------------------------------------
        % Read in a variety of maps that should be valid
        % ----------------------------------------------
        function test_mapFile_fileConstruct_write_read_1 (self)
            % Test the empty constructor
            fileConstruct_write_read ('map_1_empty.map');
        end
        
        function test_mapFile_fileConstruct_write_read_2 (self)
            % Test the empty constructor
            fileConstruct_write_read ('map_14.map');
        end
        
        function test_mapFile_fileConstruct_write_read_3 (self)
            % Test the empty constructor
            w = IX_map('map_15_1st_empty.map');
            w_out = write_read(w);
            assertTrue (isequal(w, w_out), 'Write+read does not make an identity');
        end
        
        function test_mapFile_fileConstruct_write_read_4 (self)
            % Test the empty constructor
            w = IX_map('map_15_3rd_empty.map');
            w_out = write_read(w);
            assertTrue (isequal(w, w_out), 'Write+read does not make an identity');
        end
        
        function test_mapFile_fileConstruct_write_read_5 (self)
            % Test the empty constructor
            w = IX_map('map_15_last_empty.map');
            w_out = write_read(w);
            assertTrue (isequal(w, w_out), 'Write+read does not make an identity');
        end
        
    end
end

%--------------------------------------------------------------------------
function fileConstruct_write_read (map_file)
% Read a map file, write the IX_map object that is created, then read back in

% Without workspace numbers
w_in = IX_map(map_file);
tmpfile = fullfile(tmp_dir,'tmp.msk');
save(w_in, tmpfile);
w_out = read(IX_map, tmpfile);
assertTrue (isequal(w_in, w_out), 'Write+read does not make an identity');

% With workspace numbers
w_in = IX_map(map_file,'wkno');
tmpfile = fullfile(tmp_dir,'tmp.msk');
save(w_in, tmpfile);
w_out = read(IX_map, tmpfile);
assertTrue (isequal(w_in, w_out), 'Write+read does not make an identity');

end

% %--------------------------------------------------------------------------
% function w_out = write_read (w_in)
% % Read a map file, write the IX_map object that is created, then read back in
% tmpfile = fullfile(tmp_dir,'tmp.msk');
% save(w_in, tmpfile);
% w_out = read(IX_map, tmpfile);
% end
