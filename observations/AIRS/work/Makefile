# Makefile created by mkmf $Id$ 

include ../../../mkmf/mkmf.template


.DEFAULT:
	-touch $@
all: fixsys convert_airs_L2
fixsys: 
	@ (cd ../../../mpi_utilities; ./fixsystem $(FC) )
time_manager_mod.o: ../../../time_manager/time_manager_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../time_manager/time_manager_mod.f90
assim_model_mod.o: ../../../assim_model/assim_model_mod.f90 types_mod.o location_mod.o time_manager_mod.o utilities_mod.o model_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../assim_model/assim_model_mod.f90
airs_JPL_mod.o: ../../../observations/AIRS/airs_JPL_mod.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../observations/AIRS/airs_JPL_mod.f90
airs_obs_mod.o: ../../../observations/AIRS/airs_obs_mod.f90 types_mod.o obs_def_mod.o time_manager_mod.o utilities_mod.o location_mod.o obs_kind_mod.o obs_sequence_mod.o airs_JPL_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../observations/AIRS/airs_obs_mod.f90
model_mod.o: ../../../models/template/model_mod.f90 types_mod.o time_manager_mod.o location_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../models/template/model_mod.f90
obs_kind_mod.o: ../../../obs_kind/obs_kind_mod.f90 utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../obs_kind/obs_kind_mod.f90
obs_def_mod.o: ../../../obs_def/obs_def_mod.f90 types_mod.o utilities_mod.o location_mod.o time_manager_mod.o assim_model_mod.o obs_kind_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../obs_def/obs_def_mod.f90
null_mpi_utilities_mod.o: ../../../mpi_utilities/null_mpi_utilities_mod.f90 types_mod.o utilities_mod.o time_manager_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../mpi_utilities/null_mpi_utilities_mod.f90
random_seq_mod.o: ../../../random_seq/random_seq_mod.f90 types_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../random_seq/random_seq_mod.f90
convert_airs_L2.o: ../../../observations/AIRS/convert_airs_L2.f90 types_mod.o obs_sequence_mod.o airs_JPL_mod.o utilities_mod.o airs_obs_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../observations/AIRS/convert_airs_L2.f90
obs_sequence_mod.o: ../../../obs_sequence/obs_sequence_mod.f90 types_mod.o location_mod.o obs_def_mod.o obs_kind_mod.o time_manager_mod.o utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../obs_sequence/obs_sequence_mod.f90
location_mod.o: ../../../location/threed_sphere/location_mod.f90 types_mod.o utilities_mod.o random_seq_mod.o obs_kind_mod.o null_mpi_utilities_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../location/threed_sphere/location_mod.f90
utilities_mod.o: ../../../utilities/utilities_mod.f90 types_mod.o
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../utilities/utilities_mod.f90
types_mod.o: ../../../common/types_mod.f90
	$(FC) $(FFLAGS) $(OTHERFLAGS) -c	../../../common/types_mod.f90
./obs_sequence_mod.f90: ../../../obs_sequence/obs_sequence_mod.f90
	cp ../../../obs_sequence/obs_sequence_mod.f90 .
./null_mpi_utilities_mod.f90: ../../../mpi_utilities/null_mpi_utilities_mod.f90
	cp ../../../mpi_utilities/null_mpi_utilities_mod.f90 .
./airs_obs_mod.f90: ../../../observations/AIRS/airs_obs_mod.f90
	cp ../../../observations/AIRS/airs_obs_mod.f90 .
./time_manager_mod.f90: ../../../time_manager/time_manager_mod.f90
	cp ../../../time_manager/time_manager_mod.f90 .
./utilities_mod.f90: ../../../utilities/utilities_mod.f90
	cp ../../../utilities/utilities_mod.f90 .
./location_mod.f90: ../../../location/threed_sphere/location_mod.f90
	cp ../../../location/threed_sphere/location_mod.f90 .
./convert_airs_L2.f90: ../../../observations/AIRS/convert_airs_L2.f90
	cp ../../../observations/AIRS/convert_airs_L2.f90 .
./obs_kind_mod.f90: ../../../obs_kind/obs_kind_mod.f90
	cp ../../../obs_kind/obs_kind_mod.f90 .
./types_mod.f90: ../../../common/types_mod.f90
	cp ../../../common/types_mod.f90 .
./model_mod.f90: ../../../models/template/model_mod.f90
	cp ../../../models/template/model_mod.f90 .
./assim_model_mod.f90: ../../../assim_model/assim_model_mod.f90
	cp ../../../assim_model/assim_model_mod.f90 .
./airs_JPL_mod.f90: ../../../observations/AIRS/airs_JPL_mod.f90
	cp ../../../observations/AIRS/airs_JPL_mod.f90 .
./obs_def_mod.f90: ../../../obs_def/obs_def_mod.f90
	cp ../../../obs_def/obs_def_mod.f90 .
./random_seq_mod.f90: ../../../random_seq/random_seq_mod.f90
	cp ../../../random_seq/random_seq_mod.f90 .
SRC = ../../../time_manager/time_manager_mod.f90 ../../../assim_model/assim_model_mod.f90 ../../../observations/AIRS/airs_JPL_mod.f90 ../../../observations/AIRS/airs_obs_mod.f90 ../../../models/template/model_mod.f90 ../../../obs_kind/obs_kind_mod.f90 ../../../obs_def/obs_def_mod.f90 ../../../mpi_utilities/null_mpi_utilities_mod.f90 ../../../random_seq/random_seq_mod.f90 ../../../observations/AIRS/convert_airs_L2.f90 ../../../obs_sequence/obs_sequence_mod.f90 ../../../location/threed_sphere/location_mod.f90 ../../../utilities/utilities_mod.f90 ../../../common/types_mod.f90
OBJ = time_manager_mod.o assim_model_mod.o airs_JPL_mod.o airs_obs_mod.o model_mod.o obs_kind_mod.o obs_def_mod.o null_mpi_utilities_mod.o random_seq_mod.o convert_airs_L2.o obs_sequence_mod.o location_mod.o utilities_mod.o types_mod.o
OFF = ../../../obs_sequence/obs_sequence_mod.f90 ../../../mpi_utilities/null_mpi_utilities_mod.f90 ../../../observations/AIRS/airs_obs_mod.f90 ../../../time_manager/time_manager_mod.f90 ../../../utilities/utilities_mod.f90 ../../../location/threed_sphere/location_mod.f90 ../../../observations/AIRS/convert_airs_L2.f90 ../../../obs_kind/obs_kind_mod.f90 ../../../common/types_mod.f90 ../../../models/template/model_mod.f90 ../../../assim_model/assim_model_mod.f90 ../../../observations/AIRS/airs_JPL_mod.f90 ../../../obs_def/obs_def_mod.f90 ../../../random_seq/random_seq_mod.f90
clean: neat
	-rm -f .cppdefs $(OBJ) convert_airs_L2
neat:
	-rm -f $(TMPFILES)
localize: $(OFF)
	cp $(OFF) .
TAGS: $(SRC)
	etags $(SRC)
tags: $(SRC)
	ctags $(SRC)
convert_airs_L2: $(OBJ)
	$(LD) $(OBJ) -o convert_airs_L2 -I/home/vy57456/zzbatmos_user/application/gfortran/HDF-EOS5.1.16/include -I/home/vy57456/zzbatmos_user/application/gfortran/hdf5-1.10.4/include -I/home/vy57456/zzbatmos_user/application/gfortran/jpeg-9b/include -L/home/vy57456/zzbatmos_user/application/gfortran/HDF-EOS5.1.16/lib     -L/home/vy57456/zzbatmos_user/application/gfortran/hdf5-1.10.4/lib     -L/home/vy57456/zzbatmos_user/application/gfortran/jpeg-9b/lib -lhdfeos5 -lmfhdf -ldf -ljpeg -lz  -lm $(LDFLAGS)
