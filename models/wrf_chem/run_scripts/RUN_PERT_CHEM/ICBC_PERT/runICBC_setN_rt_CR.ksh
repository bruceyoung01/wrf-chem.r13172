#!/bin/ksh -x
unalias ls
export YEAR=${YYYY}
export MONTH=${MM}
export DAY=${DD}
export HOUR=${HH}
export IC_METDIR=${WRFCHEM_MET_IC_DIR}
export BC_METDIR=${WRFCHEM_MET_BC_DIR}
export CHEMDIR=${RUN_DIR}/${YEAR}${MONTH}${DAY}${HOUR}/wrfchem_chem_icbc
let MEM=1
while [[ ${MEM} -le  ${NUM_MEMBERS} ]]; do
   export IENS=${MEM}
   if [[ ${MEM} -lt 100 ]]; then export IENS=0${MEM}; fi
   if [[ ${MEM} -lt 10  ]]; then export IENS=00${MEM}; fi
   export WRFINP=wrfinput_d01_${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00.e${IENS}
   export WRFBDY=wrfbdy_d01_${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00.e${IENS}
   echo 'get inp'
   cp ${IC_METDIR}/${WRFINP} ./.
   cp ${BC_METDIR}/${WRFBDY} ./.
   ls set${MEM}
   rm -f mozbc.ic.inp.set${MEM}
   cat mozbc.ic.inp set${MEM} > mozbc.ic.inp.set${MEM}
   rm -f mozbc.bc.inp.set${MEM}
   cat mozbc.bc.inp set${MEM} > mozbc.bc.inp.set${MEM}
   echo  'run mozbc'
   ./run_mozbc_rt_CR.csh type=ic mozbc_inp=mozbc.ic.inp.set${MEM} ens=${IENS}
   ./run_mozbc_rt_CR.csh type=bc mozbc_inp=mozbc.bc.inp.set${MEM} ens=${IENS}
   echo 'put files'
   echo 'OK'
   let MEM=MEM+1
done
