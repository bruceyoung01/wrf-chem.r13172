#!/bin/bash
#sacct -u mizzi -S 2018-08-21 -E 2018-08-27 --format=Cluster,Partition,Priority,JobID,JobName,MaxRSS,Elapsed,NNodes,ReqNodes,NCPUS,ReqCPUS,CPUTime,AveCPU,TotalCPU,ExitCode,submit,start,end
sacct -u mizzi -S 2018-08-29 -E 2018-08-31 --format=JobID,JobName,Elapsed,NNodes,NCPUS,CPUTime,submit,start,end

