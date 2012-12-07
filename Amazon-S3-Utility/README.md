S3Utility
=========

This utility can list/delete files on Amazon S3 store. It can be controlled by command line options, see "java -jar s3utils -h".


Building with Eclipse
---------------------

click on the jar.jardesc file and the exporting window will come up. Just click on "Finish" button.
The jar file will be in "dist" directory with all the necessary libs.

Running S3Utils.jar
-------------------

In Eclipse:
You should fill in the src/AwsCredentials.properties file, then "Run configuration" and fill in the "Args" panel with the command line arguments.

With "java" from the command line:
You should fill in the dist/AwsCredentials.properties file, then in the dist directory, write :
java -jar s3utility -h


Example output
--------------

<pre>
C:\_repo\utilities\Amazon-S3-Utility\dist>java -jar s3utility.jar -h
usage: java -jar s3utility.jar [--delete-files-from-bucket <bucket-name>]
       [-h] [-l <bucket-name>] [-p <prefix>] [-Q] [-q]

You need a filled-in AwsCredentials.properties in the same dir as this app
and lib dir with the appropriate jars.
    --delete-files-from-bucket <bucket-name>   delete files from bucket
 -h,--help                                     help
 -l,--list-files-in-bucket <bucket-name>       list files in bucket/all
                                               buckets
 -p,--prefix-for-file-list <prefix>            list files in bucket/all
                                               buckets when file name
                                               starts with prefix
 -Q,--give-only-size-of-files                  quiet mode, exit code
                                               equals the size of files in
                                               kilobytes
 -q,--give-only-number-of-files                quiet mode, exit code
                                               equals the number of files
</pre>
											   
Peter Borkuti, version:1.0


