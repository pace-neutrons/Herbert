jm = JobDispatcher();
[outputs, n_failed,~,jd] = jm.start_job('testRunner', [1], 10, true, 4);
disp(outputs);
disp(n_filed);
disp(jd);