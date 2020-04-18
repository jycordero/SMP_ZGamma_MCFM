TOPDIR=$PWD

TEST=false
if [ "$1" = test ] || [ "$1"  = Test ] || [ "$1" = TEST ]; then
	TEST=true
else
	TEST=false
fi

cmsenv
cd condor

if [ -z "$1" ]; then
	echo "Please provide the first input variable"
elif [ -z "$2" ]; then
	echo "Please provide the second input variable"
elif [ "$( hcoupling $2 )" == "false" ]; then 
	echo "$2 is not a valid input"
elif [ -z "$3" ]; then
	echo "Please provide the third argument"
else
	DATE=`date '+%Y_%m_%d_%H%M%S'`
	OUTDIR=$1_$2_$DATE

	echo "Creating outdirectory batch/$OUTDIR"
	mkdir -p batch/$OUTDIR

	echo "Initializing directory"
	cd batch/$OUTDIR
	mkdir reports
	
	echo "Creating batch config file"
        BATCHFILE=batch_${1}_mcfm
	createBatch $2 $DATE $TEST

	cp -r ../../* .

	createMCFM $2 $3
	cp $CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input/input_${2}.ini .
	
	rm -r batch 

	if [ "$TEST" = false ]; then
		echo "This was NOT a TEST" 
		tar --exclude='batch/*' -czf source.tar.gz $CMSSW_BASE/..
		condor_submit $BATCHFILE

		#rm source.tar.gz
	else
		if [ "$2" = test ] || [ "$2"  = Test ] || [ "$2" = TEST ]; then
			echo "This was SUBMIT a TEST" 
			tar --exclude='batch/*' -czf source.tar.gz $CMSSW_BASE/..
			condor_submit $BATCHFILE

			#rm source.tar.gz
		else
			echo "This was a TEST"
		fi
	fi
fi 
	
cd $TOPDIR


#######################################################

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
        BATCHFILE=batch_${1}_mcfm

        echo "Universe              = vanilla" >  $BATCHFILE
        echo "Should_Transfer_Files = YES"     >> $BATCHFILE
        echo "WhenToTransferOutput  = ON_EXIT" >> $BATCHFILE
        echo "Notification          = Never"   >> $BATCHFILE
        echo "Requirements          = OpSys == \"LINUX\" && (Arch != \"DUMMY\" )">> $BATCHFILE
        echo "request_disk          = 4000000" >> $BATCHFILE
        echo "request_memory        = 2048"    >> $BATCHFILE
        echo "" >> $BATCHFILE
	echo "Arguments             = input_${1}.ini" >> $BATCHFILE
        echo "Executable            = execTheory.sh"  >> $BATCHFILE
        echo "Transfer_Input_Files  = source.tar.gz"  >> $BATCHFILE
	if [ "$3" = true ];then
		echo "Output                = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).stdout" >> $BATCHFILE
		echo "Error                 = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).stderr" >> $BATCHFILE
		echo "Log                   = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).log"    >> $BATCHFILE
	else
		echo "Output                = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).stdout" >> $BATCHFILE
		echo "Error                 = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).stderr" >> $BATCHFILE
		echo "Log                   = reports/${1}_${2}_mcfm_\$(Cluster)_\$(Process).log"    >> $BATCHFILE
	fi

        echo "Queue">> $BATCHFILE
}

createMCFM () {
	INIFILE=input_${1}.ini
	INIOUT=$CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input/$INIFILE

	cat $CMSSW_BASE/src/SMP_ZGamma_MCFM/mcfm/input_ini.ini > $INIOUT
	
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
                modifyCoupling $curVar $1 $2 $INIOUT
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

modifyCoupling () {
        # 1 current variable to write
        # 2 coupling variable
        # 3 coupling value
        # 4 output file

        if [ "$1" = "$2" ]; then
                echo "    # $1" >> $4
                echo "    $1 = $3">> $4
        else
                echo "    # $1" >> $4
                echo "    $1 = 0">> $4
        fi
}
