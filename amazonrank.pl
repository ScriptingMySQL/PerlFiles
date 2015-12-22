#!/usr/bin/perl -w

##############################################################################################
# Copyright 2009,2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file 
# except in compliance with the License. A copy of the License is located at
#
#	   http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS"
# BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under the License. 
#
#############################################################################################
#
#  Amazon Product Advertising API
#  Signed Requests Sample Code
#
#  API Version: 2009-03-31/2013-08-01
#
#############################################################################################

#use strict;
#use warnings;

#no warnings 'uninitialized';

use Data::Dumper;
use DBD::mysql;
use DBI;

use RequestSignatureHelper;
use LWP::UserAgent;
use XML::Simple;

use constant myAWSId		=> 'Access Key ID';
use constant myAWSSecret	=> 'Secret Access Key';
use constant myEndPoint		=> 'ecs.amazonaws.com';

my $Database = "amazonrank";

# see if user provided ItemId on command-line
# my $itemId = shift @ARGV || '0545010225';

# ----------------------------------------------------------------------------------
# this has to be near the top - as other parts of the script rely on these figures
# ----------------------------------------------------------------------------------

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;

$year = $year + 1900;
$mon = $mon + 1;

# add a zero if the value is less than 10

if ($sec < 10) { $sec = "0$sec"; }
if ($min < 10) { $min = "0$min"; }
if ($hour < 10) { $hour = "0$hour"; }
if ($mday < 10) { $mday = "0$mday"; }
if ($mon < 10) { $mon = "0$mon"; }
if ($year < 10) { $year = "0$year"; }
if ($wday < 10) { $wday = "0$wday"; }
if ($yday < 10) { $yday = "0$yday"; }
if ($isdst < 10) { $isdst = "0$isdst"; }

$DateTime = "$year-$mon-$mday $hour:$min:$sec";

print "$DateTime\n";

foreach $itemId ("B00R0ZM5W4", "1680920006")

{

$fileout = "$itemId" . ".txt";

open(OUT,">$fileout") or die print "Couldn't open log_file: $!";

print "Retrieving rank for $itemId - ";

# Set up the helper
my $helper = new RequestSignatureHelper (
	+RequestSignatureHelper::kAWSAccessKeyId => myAWSId,
	+RequestSignatureHelper::kAWSSecretKey => myAWSSecret,
	+RequestSignatureHelper::kEndPoint => myEndPoint,
);

# A simple ItemLookup request
my $request = {
	Service => 'AWSECommerceService',
	Operation => 'ItemLookup',
	Version => '2013-08-01',
	ItemId => $itemId,
	AssociateTag => 'scmy-20',
	ResponseGroup => 'Large',
};

# Sign the request
my $signedRequest = $helper->sign($request);

# We can use the helper's canonicalize() function to construct the query string too.
my $queryString = $helper->canonicalize($signedRequest);
my $url = "http://" . myEndPoint . "/onca/xml?" . $queryString;
#print "Sending request to URL: $url \n";

my $ua = new LWP::UserAgent();
my $response = $ua->get($url);
my $content = $response->content();
#print "Recieved Response: $content \n";

my $xmlParser = new XML::Simple();
my $xml = $xmlParser->XMLin($content);

# This prints out all of the item information into a text file
print OUT "Parsed XML is: " . Dumper($xml) . "\n";

if ($response->is_success()) {

	# Here is where you extract the information for each item
	my $title = $xml->{Items}->{Item}->{ItemAttributes}->{Title};
	my $rank = $xml->{Items}->{Item}->{SalesRank};
	my $price = $xml->{Items}->{Item}->{Offers}->{Offer}->{OfferListing}->{Price}->{FormattedPrice};

	# option to print to screen - uncomment this next line
	#	print "Item $itemId is titled \"$title\" and ranked $rank\n";

if (length($rank) > 1)

{

	$dbh = ConnectToMySql($Database);	
	$query = "insert into ranks (product_id, product_rank, rank_datetime, product_title) values ('$itemId', '$rank', '$DateTime','$title')";
	$sth = $dbh->prepare($query);
	$sth->execute();
	$dbh->disconnect;

	print "$rank || $title || $itemId || \$$price\n\n";

}

else

{
	print "Rank for: $title is unavailable.\n\n";
}

# optional sleep 
# sleep 5;


} else {
	my $error = findError($xml);
	if (defined $error) {
	print "Error: " . $error->{Code} . ": " . $error->{Message} . "\n";
	} else {
	print "Unknown Error!\n";
	}
}


sub findError {
	my $xml = shift;
	
	return undef unless ref($xml) eq 'HASH';

	if (exists $xml->{Error}) { return $xml->{Error}; };

	for (keys %$xml) {
	my $error = findError($xml->{$_});
	return $error if defined $error;
	}

	return undef;
}


# end - foreach
}

#----------------------------------------------------------------------
sub ConnectToMySql {
#----------------------------------------------------------------------

  # my ($db) = @_;

   open(PW, "<..\/accessAMAZON") || die "Can't access login credentials";
   my $db= <PW>;
   my $host= <PW>;
   my $userid= <PW>;
   my $passwd= <PW>;

   chomp($db);
   chomp($host);
   chomp($userid);
   chomp($passwd);
   
   my $connectionInfo="dbi:mysql:$db;$host:3306";
   close(PW);

   # make connection to database
   my $l_dbh = DBI->connect($connectionInfo,$userid,$passwd);
   return $l_dbh;

}


