Amazon S3 file lister/deleter
=============================

Lists or delete files on Amazon S3.
If you use in quiet mode (-q or -Q) gives the number/size of files in the exit code.

Usage 
-----

<pre>
$ java -jar s3utility.jar  -h
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

