function  test_rundataOldMatlab()
%The test written in a way, it can run by old matlab and the new one (using
%xUnittests to verify brifely old matlab consistency. 
%run=rundata();
[~,path] = herbert_root();



log_level = get(herbert_config,'log_level');
set(herbert_config,'log_level',-1,'-buffer'); 
cleanupObj = onCleanup(@() set(herbert_config,'log_level',log_level,'-buffer'));
try
     run=rundata(fullfile(path,'MAP10001.spe'),fullfile(path,'demo_par.PAR'));
     run.is_crystal=false;
     run.efix = 200;
     run=get_rundata(run,'-this');
catch
     error('RUNDATAOLD:spe_loader',lasterr());
end

try
    run=rundata(fullfile(path,'MAP11020.spe_h5'),fullfile(path,'demo_par.PAR'));
    run.is_crystal=false;    
    run.efix = 200;    
    run=get_rundata(run,'-this');        
catch
    error('RUNDATAOLD:h5_loader',lasterr());
end

try
     run=rundata(fullfile(path,'MAP11014.nxspe'));
     run.is_crystal=false;     
     run.efix = 200;     
     run=get_rundata(run,'-this');     
catch
     error('RUNDATAOLD:nxspe_loader',lasterr());
end




