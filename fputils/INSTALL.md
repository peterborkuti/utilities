1. create a directory in fp-dev-utils directory, called 'scripts'

2. put fputils.sh into this 'scripts' directory

checkpoint: fp-dev-utils cache directory must be reacheable from the scripts directory with this path: '../cache'

3. set up some values in fputils.sh, look for this:

<pre>
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



</pre>