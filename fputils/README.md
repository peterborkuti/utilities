fputils.sh - lister and searcher
Function extension for fp-dev-tool
==================================

LISTER
------
It can list or copy all hotfixes of a given customer

SEARCHER
--------

It can find hotfixes for a given LPE.
if you give the name of the customer, the script checks all
the hotfixes and says if there is no collision with it.


usage
-----

<pre>
	
	fputils.sh [-l|-s|-h] -p portal-version -c customer [-d] [-g] 
	
	examples:
	
	fputils.sh -h
		this help message
	fputils.sh -v
		print program version number
	fputils.sh -l -p portal-version -c customer
		lists hotfixes for a customer (default mode)
		example: fputils.sh -l -p 6120 -c ALNA
		
	fputils.sh -s lpe-number -p portal-version
		searches after hotfixes which fixes the LPE
		example: fputils.sh -s LPE-1234 -p 6120
		 									
	fputils.sh -d
		delete the ../fixes directory before collecting hotfixes
	fputils.sh -g
		copy the listed hotfixes into ../fixes directory (g means gather)
	
</pre>	
	
Output of fputils.sh
--------------------
<pre>
	
	$ fputils.sh -p 6120 -s LPE-7464 -c BKX
	program will run in search mode, for customer BKX, portal: 6120
	mkdir: cannot create directory `tmp': File exists
	mkdir: cannot create directory `../fixes': File exists

	WARNING: ../fixes directory is not empty. You may delete the files in it before	running this script or use option '-d'.

	INFO: searching hotfix list for LPE-7464, version 6120
	not blacklisted hotfixes which fixes LPE-7464 :
	hotfix-10-6120
	hotfix-134-6120
	hotfix-135-6120
	hotfix-201-6120
	hotfix-202-6120
	hotfix-27-6120
	hotfix-40-6120
	hotfix-55-6120
	plugin-deployment-1-6120
	INFO: checking hotfixes for BKX which fixes LPE-7464, portal version 6120
	No collision with hotfix-10
	No collision with hotfix-134
	No collision with hotfix-135
	No collision with hotfix-201
	No collision with hotfix-202
	No collision with hotfix-27
	No collision with hotfix-40
	No collision with hotfix-55
	No collision with plugin-deployment-1
	you can check fp-dev output in file: ..//c/_app/fp-dev-tool-7/scripts/tmp/fpdevoutput-LPE-7464-BKX-6120.tmp

</pre>
