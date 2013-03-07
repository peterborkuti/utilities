#!/bin/bash
#This script gathers all the liferay-hotfixes for a customer and saves them into a directory
#INSTALL
# 1. create a 'scripts' directory in fp-dev-tool dir and copy this script into that.
# 2. customize this file (look for the CUSTOMIZATION AREA in this text)
#
#it uses the hotfix-list.txt and blacklist.txt
#PREREQUISITES 
#   git-bash (or linux)
#   fp-dev-tool (you must have a fresh cache directory for the portal version)
#	hotfix-list.txt must begin with the name of a hotfix
#WARNING
#this collect only hotfixes name "liferay-hotfix-...". We do not know
#which other fixes (ex. core, security, etc. are installed at the customer)
#
#USAGE
# see help: fputils.sh -h
#


############################################################################
#                                                                          #
#                    CUSTOMIZATION AREA BEGIN                              #
#                                                                          #
############################################################################

#directory where the hotfix-files will be saved
myfixes='../fixes'

#directory where all the hotfixes are. Must end with a slash!
fixesdir='/x/Support/Fix Packs/'

fpdevtool='java -jar lib/fp-dev.jar'

############################################################################
#                                                                          #
#                    CUSTOMIZATION AREA END                                #
#                                                                          #
############################################################################


#DONT TOUCH ANYTHING BELOW THIS LINE UNLESS YOU REALLY KNOW WHAT TO DO

############################################################################
#                                                                          #
#                    GLOBAL VARIABLES                                      #
#                                                                          #
############################################################################


ver="1.04";
options='hvp:c:dlgs:G:';
myname=`basename $0`;

cachedir='../cache';
hotfixlist="${cachedir}/hotfix-list.txt";
blacklist="${cachedir}/blacklist.txt";
xmldir="$cachedir";

customer="";
version="";
lpenum="";
delete=0;
gather=0;
GATHER=0;
fixpackinfofile='';
MODE='list';


############################################################################
#                                                                          #
#                    FUNCTIONS                                             #
#                                                                          #
############################################################################

function msgErr(){

	echo "ERROR: $@" >&2;

}

function helpMsg(){
cat << HERE_MSG
	$myname gives some xtended functions for fp-dev-tool, like listing or searching hotfixes.
	
	usage:
	
	$myname [-l|-s|-h] -p portal-version -c customer [-d] [-g] [-G path\to\patching-tool-info] 
	
	examples:
	
	$myname -h
		this help message
		
	$myname -v
		print program version number
		
	$myname -l -p portal-version -c customer
		lists hotfixes for a customer (default mode)
		example: $myname -l -p 6120 -c ALNA
		
	$myname -s lpe-number -p portal-version
		searches after hotfixes which fixes the LPE
		example: $myname -s LPE-1234 -p 6120
		 									
	$myname -d
		delete the $myfixes directory before collecting hotfixes
		
	$myname -g
		copy the listed hotfixes into $myfixes directory (g means gather)
		
	$myname -G pathcing-tool-info-file -c customer -p portal-version
		copy the listed hotfixes based on a patching tool info file's 'Currently installed patches:' info
		example: $myname -G info.txt -c ALNA -p 6120
	
	Peter Borkuti, version: $ver
HERE_MSG
}


function checking(){
	local mydir="$PWD";
	cd "$cachedir";
	if [ "$?" == "1" ]; then
		msgErr "There is no 'cache' directory in my parent-directory. Probably I am not in the fp-dev-tool's 'scripts' directory?"
		exit -1;
	fi;
	cd "$mydir";

	if [ "$version" == "" ]; then
		msgErr 'portal-version must be added with -p option!'
		exit -1;
	fi;

	if [ "${MODE}${customer}" == "list" ] && [ "$GATHER" == "0" ]; then
		msgErr 'customer-name must be added with -c option!'
		exit -1;
	fi;

	if [ "$gather" == "1" ] || [ "$GATHER" == "1" ]; then
		cd "$fixesdir";
		if [ "$?" == "1" ]; then
			msgErr "I can not find the directory where hotfixes are ($fixesdir).";
			msgErr "Did not you forget to set it? See the 'CUSTOMIZATION AREA' in the text of this script.";
			exit -1;
		fi;
		cd "$mydir";
	fi;
	
	if [ "$GATHER" == "1" ]; then
		if [ ! -e "$fixpackinfofile" ]; then
			msgErr "I can not find the fix pack info file : '$fixpackinfofile'. Check it, please.";
			exit -1;
		fi;
	fi;
	
	cd "$mydir";

}

function commandLine(){
	if ( ! getopts $options opt); then
		helpMsg;
		exit $E_OPTERROR;
	fi;

	while getopts "$options" opt; do
	  case $opt in
		h|v)
		  helpMsg;
		  exit 0
		  ;;
		p)
		  version="$OPTARG";
		  ;;
		c)
		  customer="$OPTARG";
		  ;;
		s)
		  MODE='search';
		  lpenum="$OPTARG";
		  echo "$lpenum"|grep -q '^LPE-[0-9]\+$';
		  if [ "$?" == "1" ]; then
			msgErr "$lpenum does not like a real LPE-number string!" 
			exit -1;
		  fi;
		  ;;
		d)
		  delete=1;
		  ;;
		g)
		  gather=1;
		  ;;
		G)
		  GATHER=1;
		  fixpackinfofile="$OPTARG";
		  ;;
		\?)
		  msgErr "Invalid option: -$OPTARG" >&2
		  exit 1
		  ;;
		:)
		  msgErr "Option -$OPTARG requires an argument." >&2
		  exit 1
		  ;;
	  esac
	done

	shift $((OPTIND-1));
}

function listFixes(){
	local f=tmp/tmp.customerlist
	local cf=tmp/tmp.filteredfixes
	echo "INFO: creating hotfix list for $customer, version $version"  
	sed -n -e "/$customer/{s/ .*//;p}" "$hotfixlist"|grep "$version"|sort|uniq > $f

	echo "INFO: filtering hotfix list with blacklisted fixes"

	local found=0;
	for i in `cat $f`; do
		grep -q "$i" "$blacklist";
		if [ "$?" == "1" ]; then
			echo "$i";
			found=1;
		fi;
	done > $cf;
	
	if [ "$found" != "0" ]; then
		
		echo "not blacklisted hotfixes for $customer on portal $version :";
		cat $cf;
		
		if [ "$gather" == "1" ]; then
			echo "INFO: collecting saving fix-packs into directory: $myfixes"

			for i in `cat $cf`; do cp -v "${fixesdir}/liferay-${i}.zip" "$myfixes"; done
		fi;
	else 
		echo "not found hotfixes for $customer on portal $version. You may run fp-dev-tool to refresh the cache directory?";
		exit 0;
	fi;	

}

function listFixesFromInfoFile(){
	local f=tmp/tmp.customerlist
	local cf=tmp/tmp.filteredfixes
	local ff=tmp/tmp.fixeswithfullnames
	echo "INFO: creating hotfix list based on fp-info-file: $fixpackinfofile for $customer, version $version"  
	sed -n -e '/Currently installed patches:/,//{s/^.*://;p;}' "$fixpackinfofile"|tr -d ' \n\r'|tr ',' '\n'|sort|uniq > $f

	
	echo "INFO: collecting saving fix-packs into directory: $myfixes"
	sed -e '/hotfix/s/\(.*\)/liferay-\1/' $f|sed -e '/hotfix/!s/\(.*\)/liferay-fix-pack-\1/' >$ff
	for i in `cat $ff`; do cp -v "${fixesdir}/${i}.zip" "$myfixes";	done

}


function checkFixes(){
	local lpefile="$1";
	local mypath="$PWD";
	local fpdotmp="$mypath/tmp/fpdevoutput.tmp";
	local fpdo="$mypath/tmp/fpdevoutput-${lpenum}-${customer}-${version}.tmp";

	
	echo "check fixes, "`date` > $fpdo
	echo "INFO: checking hotfixes for $customer which fixes $lpenum, portal version $version";

	for fix in `cat "$lpefile"|sed -e "s/-${version}//"`; do
		cd ..;
		$fpdevtool "$version" "check" "$fix" "$customer" > $fpdotmp
		echo >> $fpdo
		echo "-----------------------------------------------" >> $fpdo
		echo "checking $fix for $customer on portal $version:" >> $fpdo
		echo "-----------------------------------------------" >> $fpdo
		echo >> $fpdo
		grep -q -i 'You need' $fpdotmp
		if [ "$?" == "1" ]; then
			echo "No collision with $fix";
		else
			echo "Collision with $fix";
		fi;
		cat $fpdotmp >> $fpdo
		cd "$mypath";
	done;
	
	echo "you can check fp-dev output in file: ../${fpdo}"
}

function searchFixes(){

	local lpetxt="tmp/${lpenum}-all.txt";
	local notblacklistedlpe="tmp/${lpenum}-notblacklisted.txt";
	echo -n '' >$notblacklistedlpe;

	echo "INFO: searching hotfix list for $lpenum, version $version";

	grep -l "$lpenum" "$xmldir/"*.xml|sed 's/^.*fix-pack-//;s/\.xml//'|sort|uniq  > $lpetxt

	local found=0;
	for i in `cat "$lpetxt"`; do 
		grep -q $i "$blacklist";
		if [ "$?" == "1" ]; then
			echo $i >> $notblacklistedlpe;
			found=1;
		fi;
	done

	if [ "$found" != "0" ]; then
		echo "not blacklisted hotfixes which fixes $lpenum :";
		cat $notblacklistedlpe;
		if [ "$customer" != "" ]; then
			checkFixes "$notblacklistedlpe";
		fi;
	else
		echo "not found hotfixes for $lpenum on portal $version. You may run fp-dev-tool to refresh the cache directory?";
		exit 0;
	fi;
	
	
	
}



############################################################################
#                                                                          #
#                    MAIN PROGRAM                                          #
#                                                                          #
############################################################################


commandLine $@;
fixesdir="${fixesdir}${version}";
xmldir="$xmldir/$version";
myfixes="${myfixes}/${customer}-${version}";
checking;

echo "program will run in ${MODE} mode, for customer ${customer}, portal: ${version}"

mkdir tmp;

if [ "$gather" == "1" ] || [ "$GATHER" == "1" ]; then

	mkdir -p "$myfixes";

	if [ "$delete" == "1" ]; then
		rm "$myfixes/*.zip";
	fi;

	zipcount=`find "$myfixes" -name '*.zip'|wc -l`
	if [ "$zipcount"!="0" ]; then
		echo
		echo "WARNING: $myfixes directory is not empty. You may delete the files in it before running this script or use option '-d'."
		echo
	fi;
	
fi;



if [ "$MODE" == "list" ]; then
	if [ "$GATHER" == "1" ]; then
		listFixesFromInfoFile;
	else
		listFixes;
	fi
else
	searchFixes;
fi;
