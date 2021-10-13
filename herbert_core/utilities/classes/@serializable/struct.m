function struc = struct(obj)
% Convert sqw-type object into a structure
%  
% Inputs:
% obj -- the instance of the object to convert to a structure. 
%        the fields to use 
flds = indepFields(obj);

cell_dat = cell(numel(flds),numel(obj));
for j=1:numel(obj)
    for i=1:numel(flds)
        fldn = flds{i};
        val = obj(j).(fldn);
        if isobject(val) % should be convertable to standard structure
            % not fully generic but let's not overcomplicate -- all our
            % classes should have this method
            val= struct(val);
        end
        cell_dat{i,j} = val;
    end
end
struc = cell2struct(cell_dat,flds,1);
if numel(obj)>1
    struc = reshape(struc,size(obj));
end
