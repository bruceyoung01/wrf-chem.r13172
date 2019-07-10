#!/bin/bash
#sacct -u mizzi -S 2018-09-20 -E 2018-08-21 --format=Cluster,Partition,Priority,JobID,JobName,MaxRSS,Elapsed,NNodes,ReqNodes,NCPUS,ReqCPUS,CPUTime,AveCPU,TotalCPU,ExitCode,submit,start,end
sacct -u mizzi -S 2018-09-26 -E 2018-09-28 --format=JobID,JobName,Elapsed,NNodes,NCPUS,CPUTime,submit,start,end

