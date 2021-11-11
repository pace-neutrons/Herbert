function psidisp(filename, varargin)

    mpi = MPI_State.instance();

    if isempty(mpi)
        fid = fopen(filename, 'a')
    else
        [fp, bn, ext] = fileparts(filename);
        fid = fopen(fullfile(fp, [bn, num2str(mpi.labIndex), ext]), 'a');
    end

     for i=1:numel(varargin)
         fprintf(fid, "%s\n", evalc('varargin{i}'));
     end
     fclose(fid);

end