#!/bin/ksh -x
export YEAR=${YYYY}
export MONTH=${MM}
export DAY=${DD}
export HOUR=${HH}
export METDIR=${REAL_DIR}
export CHEMDIR=${RUN_DIR}/${DATE}/wrfchem_chem_icbc
export WRFINP_FR=wrfinput_d02_${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00
cp ${METDIR}/${WRFINP_FR} ./.
mv ${WRFINP_FR} wrfinput_d02_${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00.e000
rm -f mozbc.ic.inp.set00
cat mozbc.ic.inp set00 > mozbc.ic.inp.set00
./run_mozbc_rt_FR.csh type=ic mozbc_inp=mozbc.ic.inp.set00 ens=000
mv wrfinput_d02_${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00.e000 ${WRFINP_FR}

