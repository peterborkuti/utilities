/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
import java.io.IOException;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.PropertiesCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.Bucket;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.S3ObjectSummary;

/**
 * This is file lister/deleter command-line utility for Amazon S3
 * <p>
 * <b>Prerequisites:</b> You must have a valid Amazon Web Services developer
 * account, and be signed up to use Amazon S3. For more information on Amazon
 * S3, see http://aws.amazon.com/s3.
 * <p>
 * <b>Important:</b> Be sure to fill in your AWS access credentials in the
 * AwsCredentials.properties file before you try to run this sample.
 * http://aws.amazon.com/security-credentials
 */
class MyState {
	boolean quiet = false;
	boolean printSize = false;
	boolean deleteFiles = false;
	String bucketName = "";
	String prefix = "";
	int numOfFiles = 0;
	int sumOfFileSizes = 0;
}

public class S3Utility {

	final static String verNum = "1.0";

	final static String helpHeader =
			"\nYou need a filled-in AwsCredentials.properties in the same dir as "+
			"this app and lib dir with the appropriate jars.";

	final static String helpFooter =
			"\n\nPeter Borkuti, version:"+verNum;

	public static void main(String[] args) throws IOException{
		/*
		 * Important: Be sure to fill in your AWS access credentials in the
		 * AwsCredentials.properties file before you try to run this sample.
		 * http://aws.amazon.com/security-credentials
		 */

		MyState state = commandLine(args);

		PropertiesCredentials cred = 
				new PropertiesCredentials(
						S3Utility.class.getResourceAsStream("AwsCredentials.properties")
						);

		AmazonS3 s3 = new AmazonS3Client(cred);
		if (state.deleteFiles) {
			message("Deleting files from bucket ",state);
			deleteAllFromBucket(s3,state);
		};

		listFiles(s3,state);

		int exitCode = 0;
		if (state.quiet) {
			if (state.printSize) {
				exitCode = state.sumOfFileSizes/1024;
			} else {
				exitCode = state.numOfFiles;
			}
		}
		
		System.exit( exitCode );

	}

	private static void message(String s, MyState state) {
		if (!state.quiet) {
			System.out.println(s);
		}
	}

	private static MyState commandLine(String[] args) {
		Options o = setupCommandLine();
		CommandLine c;
		MyState state = null;
		try {
			c = parseCommandLine(o, args);
			state = validateCommandLine(c);
		} catch (ParseException e) {
			System.err.println(e.getMessage());
			System.exit(2);
		}
		return state;
	}

	@SuppressWarnings("static-access")
	private  static Options setupCommandLine(){
		// create Options object
		Options options = new Options();

		options.addOption(
				OptionBuilder.withLongOpt("list-files-in-bucket")
							 .hasOptionalArg()
							 .withDescription("list files in bucket/all buckets")
							 .withArgName("bucket-name")
							 .create("l"));
		options.addOption(
				OptionBuilder.withLongOpt("delete-files-from-bucket")
							 .withDescription("delete files from bucket")
							 .hasArg(true)
							 .withArgName("bucket-name")
							 .create());

		options.addOption("q", "give-only-number-of-files", false, "quiet mode, exit code equals the number of files");
		options.addOption("Q", "give-only-size-of-files", false, "quiet mode, exit code equals the size of files in kilobytes");
		options.addOption("h", "help", false, "help");
		options.addOption(
				OptionBuilder.withLongOpt("prefix-for-file-list")
							 .withDescription("list files in bucket/all buckets when file name starts with prefix")
							 .hasArg(true)
							 .withArgName("prefix")
							 .create("p"));

		return options;

	}

	private  static CommandLine parseCommandLine(Options o, String[] args) throws ParseException{
		CommandLineParser parser = new PosixParser();
		CommandLine line = null;

		line = parser.parse( o, args );
		if (line.hasOption("h")) {
			// automatically generate the help statement
			
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("java -jar s3utility.jar", helpHeader, o, helpFooter, true);
			System.exit(-1);
		}

		return line;

	}

	private static MyState validateCommandLine(CommandLine line) throws ParseException{
		MyState state = new MyState();
		
		final String hint = " Use -h for help.";

		if (line.hasOption("delete-files-from-bucket") && line.hasOption("l")) {
			throw new ParseException("Only one of the options for listing or deleting must be given."+hint);
		}

		if (!line.hasOption("delete-files-from-bucket") && !line.hasOption("l")) {
			throw new ParseException("One of the options for listing or deleting must be given."+hint);
		}

		if (line.hasOption("delete-files-from-bucket")) {
			state.bucketName = line.getOptionValue("delete-files-from-bucket");
		}

		if (line.hasOption("p")) {
			state.prefix = line.getOptionValue("p");
		}


		if (state.bucketName == null || "".equals(state.bucketName)) {
			state.bucketName = line.getOptionValue("l","");
		}

		state.deleteFiles = line.hasOption("delete-files-from-bucket");
		state.printSize = line.hasOption("Q");
		state.quiet = line.hasOption("Q") || line.hasOption("q");
		
		return state;

	}

	private static void printObjectSummary(String prefix, S3ObjectSummary s, int b, MyState state){
		message(String.format("%s%4d %8d %s", prefix, b,
				s.getSize(), s.getKey()), state);
	}


	private static void deleteAllFromBucket(AmazonS3 s3, MyState state) {
		String bucketName = state.bucketName;
		try {
			message("Bucket:" + bucketName, state);
			ObjectListing objects = s3.listObjects(bucketName);
			int b = 0;
			do {
				for (S3ObjectSummary objectSummary : objects
						.getObjectSummaries()) {
					printObjectSummary("Deleting:",objectSummary,b++,state);
					s3.deleteObject(bucketName, objectSummary.getKey());
				}

				objects = s3.listNextBatchOfObjects(objects);
			} while (objects.isTruncated());

		} catch (AmazonServiceException ase) {
			System.err.println("Error Message:    " + ase.getMessage());
			System.err.println("HTTP Status Code: " + ase.getStatusCode());
			System.err.println("AWS Error Code:   " + ase.getErrorCode());
			System.err.println("Error Type:       " + ase.getErrorType());
			System.err.println("Request ID:       " + ase.getRequestId());
		} catch (AmazonClientException ace) {
			System.err.println("Error Message: " + ace.getMessage());
		}
	}

	/*
	 * Amazon S3
	 * 
	 * The AWS S3 client allows you to manage buckets and programmatically put
	 * and get objects to those buckets.
	 * 
	 * In this sample, we use an S3 client to iterate over all the buckets owned
	 * by the current user, and all the object metadata in each bucket, to
	 * obtain a total object and space usage count. This is done without ever
	 * actually downloading a single object -- the requests work with object
	 * metadata only.
	 */
	private static void listFiles(AmazonS3 s3, MyState state) {
		String prefix = state.prefix == null ? "" : state.prefix;
		boolean bucketFound = false;

		try {
			List<Bucket> buckets = s3.listBuckets();

			for (Bucket bucket : buckets) {
				/*
				 * In order to save bandwidth, an S3 object listing does not
				 * contain every object in the bucket; after a certain point the
				 * S3ObjectListing is truncated, and further pages must be
				 * obtained with the AmazonS3Client.listNextBatchOfObjects()
				 * method.
				 */
				if (state.bucketName != null && !"".equals(state.bucketName) &&
						!state.bucketName.equals(bucket.getName())) {
					continue;
				} else {
					bucketFound = true;
				}
				message("Bucket:" + bucket.getName(), state);
				ObjectListing objects = s3.listObjects(bucket.getName(),prefix);
				int b = 0;
				do {
					for (S3ObjectSummary objectSummary : objects
							.getObjectSummaries()) {
						printObjectSummary("",objectSummary,b++,state);
						state.numOfFiles += 1;
						state.sumOfFileSizes += objectSummary.getSize();
					}
					objects = s3.listNextBatchOfObjects(objects);
				} while (objects.isTruncated());
			}
			
			if (!bucketFound) {
				System.err.println("Bucket '"+state.bucketName+"' not found.");
			}

		} catch (AmazonServiceException ase) {
			/*
			 * AmazonServiceExceptions represent an error response from an AWS
			 * services, i.e. your request made it to AWS, but the AWS service
			 * either found it invalid or encountered an error trying to execute
			 * it.
			 */
			System.err.println("Error Message:    " + ase.getMessage());
			System.err.println("HTTP Status Code: " + ase.getStatusCode());
			System.err.println("AWS Error Code:   " + ase.getErrorCode());
			System.err.println("Error Type:       " + ase.getErrorType());
			System.err.println("Request ID:       " + ase.getRequestId());
		} catch (AmazonClientException ace) {
			/*
			 * AmazonClientExceptions represent an error that occurred inside
			 * the client on the local host, either while trying to send the
			 * request to AWS or interpret the response. For example, if no
			 * network connection is available, the client won't be able to
			 * connect to AWS to execute a request and will throw an
			 * AmazonClientException.
			 */
			System.err.println("Error Message: " + ace.getMessage());
		}
	}

}
