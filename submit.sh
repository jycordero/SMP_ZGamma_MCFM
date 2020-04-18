TOPDIR=$PWD

TAG=$1
ORDER=$2
COUPLING=$3
VALUE=$4

TEST=false
if [ "$TAG" = test ] || [ "$TAG"  = Test ] || [ "$TAG" = TEST ]; then
	TEST=true
else
	TEST=false
fi

cmsenv
cd condor

if [ -z "$TAG" ]; then
	echo "Please provide the first input variable"
elif [ -z "$ORDER" ]; then
	echo "Please provide the second input variable"
elif [ "$( horder $ORDER )" == "false" ]; then 
	echo "$ORDER is not a valid input"
elif [ -z "$COUPLING" ]; then
	echo "Please provide the second input variable"
elif [ "$( hcoupling $COUPLING )" == "false" ]; then 
	echo "$COUPLING is not a valid input"
elif [ -z "$VALUE" ]; then
	echo "Please provide the third argument"
else
	DATE=`date '+%Y_%m_%d_%H%M%S'`
	OUTDIR=${TAG}_${ORDER}_${COUPLING}_${DATE}

	echo "Creating outdirectory batch/$OUTDIR"
	mkdir -p batch/$OUTDIR

	echo "Initializing directory"
	cd batch/$OUTDIR
	mkdir reports
	
	echo "Creating batch config file"
        BATCHFILE=batch_${ORDER}_${COUPLING}__mcfm
	createBatch $ORDER $COUPLING $DATE $TEST

	cp -r ../../* .

	createMCFM $ORDER $COUPLING $VALUE
	cp $CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input/input_${ORDER}_${COUPLING}.ini .
	
	rm -rf batch 

	if [ "$TEST" = false ]; then
		echo "This was NOT a TEST" 
		tar -czf source.tar.gz -X exclude.txt $CMSSW_BASE/..
		#condor_submit $BATCHFILE

		#rm source.tar.gz
	else
		if [ "$TAG" = test ] || [ "$TAG"  = Test ] || [ "$TAG" = TEST ]; then
			echo "This was SUBMIT a TEST" 
			#tar --exclude='batch/*' --exclude='$CMSSW_BASE/src/SMP_ZGamma_Ma*' -czf source.tar.gz $CMSSW_BASE/..
			tar -czf source.tar.gz -X exclude.txt $CMSSW_BASE/..
			#condor_submit $BATCHFILE

			#rm source.tar.gz
		else
			echo "This was a TEST"
		fi
	fi
fi 
	
cd $TOPDIR


#######################################################
horder () {
	if [ "$1" != "lo" ] && \
	   [ "$1" != "nlo" ] && \
	   [ "$1" != "nnlo" ]; then 
		echo "false"
	else
		echo "true"
	fi
}


hcoupling () {
	if [ "$1" != "sm" ] && \
	   [ "$1" != "Test" ] && [ "$1" != "test" ] && [ "$1" != "TEST" ] &&  \
	   [ "$1" != "h1Z" ] && [ "$1" != "h1gamma" ] && \
	   [ "$1" != "h2Z" ] && [ "$1" != "h2gamma" ] && \
	   [ "$1" != "h3Z" ] && [ "$1" != "h3gamma" ] && \
	   [ "$1" != "h4Z" ] && [ "$1" != "h4gamma" ]; then
		echo "false"
	else
		echo "true"
	fi
}

createBatch () {
	ORDER=$1
	COUPLING=$2
	DATE=$3
	TEST=$4	

        BATCHFILE=batch_${ORDER}_${COUPLING}_mcfm

        echo "Universe              = vanilla" >  $BATCHFILE
        echo "Should_Transfer_Files = YES"     >> $BATCHFILE
        echo "WhenToTransferOutput  = ON_EXIT" >> $BATCHFILE
        echo "Notification          = Never"   >> $BATCHFILE
        echo "Requirements          = OpSys == \"LINUX\" && (Arch != \"DUMMY\" )">> $BATCHFILE
        echo "request_disk          = 4000000" >> $BATCHFILE
        echo "request_memory        = 2048"    >> $BATCHFILE
        echo "" >> $BATCHFILE
	echo "Arguments             = input_${ORDER}_${COUPLING}.ini" >> $BATCHFILE
        echo "Executable            = execTheory.sh"  >> $BATCHFILE
        echo "Transfer_Input_Files  = source.tar.gz"  >> $BATCHFILE
	if [ "$TEST" = true ];then
		echo "Output                = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).stdout" >> $BATCHFILE
		echo "Error                 = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).stderr" >> $BATCHFILE
		echo "Log                   = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).log"    >> $BATCHFILE
	else
		echo "Output                = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).stdout" >> $BATCHFILE
		echo "Error                 = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).stderr" >> $BATCHFILE
		echo "Log                   = reports/${ORDER}_${DATE}_mcfm_\$(Cluster)_\$(Process).log"    >> $BATCHFILE
	fi

        echo "Queue">> $BATCHFILE
}

createMCFM () {
	ORDER=$1
	COUPLING=$2
	VALUE=$3

	INIFILE=input_${ORDER}_${COUPLING}.ini
	INIOUT=$CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input/$INIFILE

        echo "mcfm_version = 9.0" > $INIOUT
        echo "  " >> $INIOUT
        echo "[general]" >> $INIOUT
        echo "    # process number" >> $INIOUT
        echo "    nproc = 300" >> $INIOUT
        echo "    # part: lo, nlo, nnlo, nlocoeff, nnlocoeff" >> $INIOUT
        modifyOrder $ORDER $INIOUT
        echo "    # string to identify run" >> $INIOUT
        echo "    runstring = 14TeV" >> $INIOUT
        echo "    sqrts = 14000" >> $INIOUT
        echo "    # ih1, ih2: +1 for proton, -1 for antiproton" >> $INIOUT
        echo "    ih1 = +1" >> $INIOUT
        echo "    ih2 = +1" >> $INIOUT
        echo "    zerowidth = .false." >> $INIOUT
        echo "    removebr = .false." >> $INIOUT
        echo "    # electroweak corrections: none, sudakov or exact" >> $INIOUT
        echo "    ewcorr = none" >> $INIOUT
        echo " " >> $INIOUT
        echo "[nnlo]" >> $INIOUT
        echo "    # optional: tau cutoff for NNLO processes, otherwise default value is chosen" >> $INIOUT
        echo "    #     for less than 1% cutoff effects in the total cross section." >> $INIOUT
        echo "    # taucut = 0.001" >> $INIOUT
        echo "    # optional array of numerical taucut values that should be sampled on the fly in addition." >> $INIOUT
        echo "    # these values can be smaller or larger than the nominal taucut value" >> $INIOUT
        echo "    # tcutarray = 0.001 0.002 0.003 0.004 0.005 0.01 0.02 0.03 0.05 0.1 0.2 0.4 0.8 1.0" >> $INIOUT

	cat $CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input_skeleton_ini.ini >> $INIOUT
	
	echo "# Anomalous couplings of the W and Z" >> $INIOUT
	echo "[anom_wz] " >> $INIOUT
	echo "    # enable anomalous W/Z couplings" >> $INIOUT
	echo "    enable = .true. " >> $INIOUT 
	echo "    # Delta g1(Z)   " >> $INIOUT
	echo "    delg1_z =0      " >> $INIOUT
	echo "    # Delta K(Z)    " >> $INIOUT
	echo "    delk_z = 0      " >> $INIOUT
	echo "    # Delta K(gamma)" >> $INIOUT
	echo "    delk_g = 0      " >> $INIOUT
	echo "    # Lambda(Z)     " >> $INIOUT
	echo "    lambda_z = 0    " >> $INIOUT
	echo "    # Lambda(gamma) " >> $INIOUT
	echo "    lambda_g = 0    " >> $INIOUT

        curentVariable=( h1Z h1gamma h2Z h2gamma h3Z h3gamma h4Z h4gamma )

        for curVar in "${curentVariable[@]}";
        do
                modifyCoupling $curVar $COUPLING $VALUE $INIOUT
        done


	echo "    # Form-factor scale, in TeV">> $INIOUT
	echo "    tevscale = 2.0">> $INIOUT
	echo "            " >> $INIOUT
	echo "# Higgs+jet with mass corrections, process 200" >> $INIOUT
	echo "[hjetmass]  " >> $INIOUT
	echo "    mtex = 0" >> $INIOUT
	echo "            " >> $INIOUT
	echo "[anom_higgs]" >> $INIOUT
	echo "    # Gamma_H / Gamma_H(SM)" >> $INIOUT
	echo "    hwidth_ratio = 1.0" >> $INIOUT
	echo "    cttH = 0.0" >> $INIOUT
	echo "    cWWH = 0.0" >> $INIOUT
}
modifyOrder() {
	ORDER=$1
	OUTFILE=$2

        echo "    part = $ORDER" >> $OUTFILE
}
modifyCoupling () {
        # 1 current variable to write
        # 2 coupling variable
        # 3 coupling value
        # 4 output file
	CURVAL=$1
	COUPLING=$2
	VALUE=$3
	OUTFILE=$4

        if [ "$CURVAL" = "$COUPLING" ]; then
                echo "    # $CURVAL" >> $OUTFILE
                echo "    $CURVAL = $VALUE">> $OUTFILE
        else
                echo "    # $CURVAL" >> $OUTFILE
                echo "    $CURVAL = 0">> $OUTFILE
        fi
}
