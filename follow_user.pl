#!/usr/bin/perl
# Updated 2015-10-25

use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';

# ----------------------------------------------------------------------------
# follow users from database
# ----------------------------------------------------------------------------
# Credentials for your twitter application - blog
my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
      traits              => [qw/API::RESTv1_1/],
      consumer_key        => "$consumer_key",
      consumer_secret     => "$consumer_secret",
      access_token        => "$access_token",
      access_token_secret => "access_token_secret",
      apiurl => 'http://api.twitter.com/1.1',
      ssl                 => 1
);

# find the stats and info for the following users

$limit = 250;
$percent_follow_minimum = 80;
$percent_follow_maximum = 140;
$statuses_count_minimum = 30;

$dbh = ConnectToMySql($Database);
$query = "select user_id FROM twitter_users where sent_follow_request IS NULL and percent_follow > $percent_follow_minimum and percent_follow < $percent_follow_maximum and statuses_count > $statuses_count_minimum limit $limit";	
$sth = $dbh->prepare($query);
$sth->execute();

print "\n$query\n\n";

$count_users = 1;

# loop through our results - one tweet at a time
while (@data = $sth->fetchrow_array()) {

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

# ----------------------------------------------------------------------------------

	$user_id = $data[0];

	print "$user_id - $count_users of $limit - Followed at: $DateTime - ";


	eval {

		my $friend = $nt->create_friend({ user_id => "$user_id" });
    
#		    print "---DUMPER START---\n";
#			print Dumper $friend;
#		    print "---DUMPER END---\n\n";

			if ( my $err = $@ ) {
				die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

				warn "\n - HTTP Response Code: ", $err->code, "\n",
				"\n - HTTP Message......: ", $err->message, "\n",
				"\n - Twitter error.....: ", $err->error, "\n";
			
			# end if
			};
			
			
	# end - eval
	};

			$dbh2 = ConnectToMySql($Database);	
			$query2 = "update twitter_users SET sent_follow_request = 'yes', sent_request_datetime  = '$DateTime' where user_id = '$user_id'";
			#print " $query2\n";
			#print " database updated.\n"
			$sth2 = $dbh2->prepare($query2);
			$sth2->execute();

# pause for a random time so twitter doesn't think you are a robot
# minimum and maximum time in seconds to sleep
$minimum = 360; 
$maximum = 720;
$random_sleep = int($minimum + rand($maximum - $minimum));

print " - sleeping for $random_sleep seconds\n";
sleep $random_sleep;

$count_users++;

# end - while (@data = $sth->fetchrow_array())
};

exit;

#----------------------------------------------------------------------
sub ConnectToMySql {
#----------------------------------------------------------------------

   my ($db) = @_;

   open(PW, "<..\/accessTweets") || die "Can't access login credentials";
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

exit;
