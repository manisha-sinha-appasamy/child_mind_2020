function joblist = getjobid

try
    [res,txt] = system('squeue -u arno');

    rows = textscan(txt, '%s', 'delim', char(9));
    rows = rows{1}
    joblist = [];
    iJob = 1;

    for iRow = 2:length(rows)
        tmp = textscan(rows{iRow}, '%s', 'delim', ' ');
        tmp = tmp{1};
        tmp(cellfun(@isempty, tmp)) = [];
        if isequal(tmp{5}, 'R')
            joblist(iJob).jobid     = tmp{1};
            joblist(iJob).partition = tmp{2};
            joblist(iJob).jobname   = tmp{3};
            joblist(iJob).status    = tmp{4};
            joblist(iJob).time      = datenum(tmp{6});
            iJob = iJob+1;
        end
    end

    if ~isempty(joblist)
        [~,ind] = min([joblist.time]);
        joblist = joblist(ind);
    end
catch
    joblist.jobid = datestr(now, 'yyyy-mm-dd_HH:MM');
end
if isempty(joblist)
    joblist.jobid = datestr(now, 'yyyy-mm-dd_HH:MM');
end
