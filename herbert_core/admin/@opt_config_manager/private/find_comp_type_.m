function [pc_type,nproc,mem_size] = find_comp_type_(obj)
% find pc type as function of the pc properties, like memory size number of
% processors, etc.
%
% TO DO:
% Does not currently identify number of processors properly. Only rough
% estimate or no estimate at all. (Dealt with this issue elsewhere, but future
% improvements/merging may be necessary to address this)
% 

types = obj.known_pc_types_;
Gb = 1024*1024*1024;
nproc = 1;

if ispc
    [~,sys] = memory();
    mem_size = sys.PhysicalMemory.Total;
    if mem_size <  32*Gb
        pc_type = types{1}; %windows small
    else
        if sys.PhysicalMemory.Available >= 0.5*sys.PhysicalMemory.Total
            nproc = idivide(int64(mem_size),int64(obj.mem_size_per_worker_*Gb),'floor');
            if nproc >1
                pc_type = types{2}; %windows large
            else
                pc_type = types{1};  %windows small
            end
        else
            pc_type = types{1};%windows small
        end
    end
    if is_jenkins()
        pc_type = types{8};  % 'jenkins_win'
    end
elseif isunix
    
    [ok,mem_string] = system('free | grep Mem');
    if ~ok
        mem_size = 16*Gb;
    else
        mem_size = parse_mem_string(mem_string);
    end
    
    if ismac %MAC
        pc_type = types{3};
        return;
    end
    [nok,mess] = system('lscpu');
    if nok  %still MAC or strange unix without lscpu. Assuming mac.
        pc_type = types{3};
        return;
    end
    
    rez=strfind(mess,'NUMA node');
    % if lscpu returns more then one numa node strigs, first string defines
    % the number of numa nodes and all subsequent strings describe each
    % node. So, if there are more then 2 string, its more then one numa
    % node and we consider this computer to be an hpc system.
    if numel(rez)>2; hpc_computer = true;
    else;          hpc_computer = false;
    end
    is_virtual = is_idaaas();
    if is_virtual
        n_profile = 6; %verid iDaaaS machine
    else
        n_profile = 4; % normal unix machine
    end
    
    if hpc_computer
        n_profile=n_profile+1;
    end
    pc_type = types{n_profile};
    %
    if is_jenkins()
        pc_type = types{9};  % 'jenkins_unix'
        return;
    end
end


function mem_size = parse_mem_string(mem_string)
cont = regexp(mem_string,'\s+','split');
mem_size =  sscanf(cont{2},'%d');
