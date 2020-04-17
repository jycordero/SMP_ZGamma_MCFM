#!/bin/sh

echo "Job submitted on host `hostname` on `date`"
echo ">>> arguments: $@"

### Transfer files, prepare directory ###
TOPDIR=$PWD

# lpc
export SCRAM_ARCH=slc6_amd64_gcc530
export CMSSW_VERSION=CMSSW_10_2_13
source /cvmfs/cms.cern.ch/cmsset_default.sh


echo "Unpacking tarball.."
tar -xzf source.tar.gz
cd $CMSSW_VERSION/src/

echo "Creating project.."
#scramv1 b ProjectRename
echo "--Created in $PWD"
cmsenv
cd mcfm 

echo "MCFM..."
echo "-- Location: $PWD"
echo "-- Folder content: `ls .`"
echo "-- Input Folder content: `ls input`"
echo "-- Input File: $1"
#./mcfm_omp input/$1 
./mcfm_omp input/$1 

### Copy output and cleanup ###
cp input/*.txt ${_CONDOR_SCRATCH_DIR}
cp input/*.dat ${_CONDOR_SCRATCH_DIR}
cp input/*.DAT ${_CONDOR_SCRATCH_DIR}

