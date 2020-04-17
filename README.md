# SMP_ZGamma_MCFM

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
git clone git@github.com:jycordero/SMP_ZGamma_Theory.git
```

## Folder structure and excecutables

### Folders
Displayed are the folders that are the most relevant for the analysis

```
SMP
|
 ->mcfm # has the contents of the "Bin" folder in the MCFM package
|   |
|   -> 
 -> condor
```
### Excecutables

  * submit.sh
    * 
