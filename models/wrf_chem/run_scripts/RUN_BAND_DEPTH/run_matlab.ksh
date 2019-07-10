#!/bin/ksh -x
#
# Script to run matlab
bsub -Is -q caldera -W 5:00 -n 1 -P P19010000 matlab
exit
