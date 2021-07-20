function psidisp(filename, varargin)

    mpi = MPI_State.instance();

    if isempty(mpi)
        fid = fopen(filename, 'w')
    else
        [fp, bn, ext] = fileparts(filename);
        fid = fopen(fullfile(fp, [bn, num2str(mpi.labIndex), ext]), 'w');
    end

     for i=1:numel(varargin)
         fprintf(fid, "%s\n", evalc('varargin{i}'));
     end
     fclose(fid);

end