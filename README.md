# SMP_ZGamma_MCFM

This repo is used to calculate the theoretical prediction of the differential cross section @NLO for the process `p+p -> Z+Gamma` using the package https://mcfm.fnal.gov/

Table of Contents
===================
  * [Setup](#setup)
  * [Folder Structure](#folder-structure)
  * [Excecutable](#excecutables)
  * [Testing](#testing)

## Setup

Generate the proper CMSSW enviroment

```bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc491
cmsrel CMSSW_10_2_13
cd CMSSW_10_2_13/src
cmsenv
```

Extract the project directory from github
```bash
git clone git@github.com:jycordero/SMP_ZGamma_MCFM.git
```

## Folder structure

**Note**: when refering to the project directory(PROJDIR) this means `$CMSSW_BASE/SMP_ZGamma_MCFM`, also note PROJDIR is **not** an eviromental variable

Displayed are the folders that are the most relevant for the analysis

```
SMP
|
 ->mcfm # has the contents of the "Bin" folder in the MCFM package
|   |
|   |-> process.DAT # list of all processes, this number is used in the input.ini files
|   |
|   |-> input # Has the input theory and experimental parameters
|
 -> condor # condor excecutable and output 
    |
    |-> batch #folder where all the output of the condor output gets dumped
          |
          -> [$TAG]_[$COUPLING]_[$DATE] # Output of submited job, SHOULD BE TRANSFERED TO EOS, since nobackup has limited space
```
## Excecutables

:warning: Right now the tarball that is sent to the cluster is not very smart, is compresses the entire `$CMSSW_BASE` directory, so you might encounter problems with memory on the cluster size due to this

**submit.sh**
---

**Location** `>PROJDIR`

**Description**

This file creates the configutation files to submit a mcfc job to **condor**. It also creates the **mcfc** config file to 

```bash
. submit.sh [$1] [$2] [$3]
```
  * $1
    * Tag for the process
    * if `tag=test` is tests the submission process
  * $2
    * Coupling variable to set non--zero value
    * coupling can take values { sm, h1Z, h1gamma, h2Z, h2gamma, h3Z, h3gamma, h4Z, h4gamma }
  * $3
    * value to set the coupling constant
    
**execTheory.sh**
---

**Location** `>PROJDIR/condor`

**Description**

This file is the excedutable that will ran at the cluster. It runs the `mcfm_omp` with the input file(`PROJDIR/mcfm/input/iniput_[$COUPLING].ini`) created by the `submit.sh` executable.

## Testing

Run the following code to test the submission

```bash
. submit.sh test test 0
```
