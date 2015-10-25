#!/usr/bin/perl
# Updated 2015-10-25

use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';
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

print "\n----------------------------------------------------------------------------\n";
print "Begin importing - $DateTime....\n";
       
# ----------------------------------------------------------------------------
# get list of followers for a certain user name - who is similar to what you will be doing
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


$count=1;

# twitter user name without the @
$user_to_find_followers = "Cat";

$dbh = ConnectToMySql($Database);
$query = "select user_id, next_cursor FROM user_cursorswhere user_id = '$user_to_find_followers' order by id desc limit 1";	
$sth = $dbh->prepare($query);
$sth->execute();

print "\n$query\n";

$count_users = 0;

#			print "name | friends_count | followers_count | statuses_count | percent_follow\% |$time_zone | description | creation_datetime\n";
# loop through our results - one tweet at a time
while (@data = $sth->fetchrow_array()) {
$cursor = $data[1];

if ($cursor == 0)

{
	$cursor = "-1";
}

}

print "Starting at cursor: $data[1]\n";
# Use the optional cursor parameter to retrieve IDs in pages of 5000. When the cursor parameter is used, 
# the return value is a reference to a hash with keys previous_cursor, next_cursor, and ids. 
# The value of ids is a reference to an array of IDS of the user's followers. 
# Set the optional cursor parameter to -1 to get the first page of IDs. 
# Set it to the prior return's value of previous_cursor or next_cursor to page forward or backwards. 
# When there are no prior pages, the value of previous_cursor will be 0. 
# When there are no subsequent pages, the value of next_cursor will be 0.

  eval {

		my $followers_list = $nt->followers_ids({
        screen_name => "$user_to_find_followers",
        cursor      => "$cursor",
        });

#		count => 1
#    print "---DUMPER START---\n";
#	print Dumper $followers_list;
#    print "---DUMPER END---\n\n";

			$next_cursor = $followers_list->{next_cursor_str};
			$previous_cursor = $followers_list->{previous_cursor_str};
			
			print "next_cursor $next_cursor - previous_cursor $previous_cursor \n";

		for my $status2 ( @{$followers_list->{ids}} ) {
        # print "$count $status $next_cursor\n";

			$follower_id = $status2;
		
			# uncomment to watch as it prints each user
			#print "$count $user_to_find_followers $follower_id\n";

			$dbh = ConnectToMySql($Database);	
			$query = "insert into follows_other_users(user_to_find_followers, follower_id) values ('$user_to_find_followers','$follower_id')";
			#print "\n $query\n";
			$sth = $dbh->prepare($query);
			$sth->execute();

		#sleep 1;

		$count++;

	# end for my $status
    }

# end eval    
};
			if ( my $err = $@ ) {
				die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

				warn "HTTP Response Code: ", $err->code, "\n",
          	 "HTTP Message......: ", $err->message, "\n",
         	  "Twitter error.....: ", $err->error, "\n";
			}
		# put this into a database in case you want to search for more of their followers
		print "\n$user_to_find_followers $next_cursor $previous_cursor\n";

		$user_id = $user_to_find_followers;

		$dbh = ConnectToMySql($Database);	
		$query = "insert into user_cursors(user_id, next_cursor, previous_cursor) values ('$user_id','$next_cursor','$previous_cursor')";
		print "\n $query\n";
		$sth = $dbh->prepare($query);
		$sth->execute();

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


print "Finished importing - $DateTime....\n";
print "\n----------------------------------------------------------------------------\n";

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
