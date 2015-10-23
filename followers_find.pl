#!/usr/bin/perl
 
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';

# ------------------------------------------------------
# get list of followers for a certain user name 
# that is similar to what you will be doing with twitter
# ------------------------------------------------------

# Credentials for your twitter application - scripting
my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
      traits              => [qw/API::RESTv1_1/],
      consumer_key        => "$consumer_key",
      consumer_secret     => "$consumer_secret",
      access_token        => "$access_token",
      access_token_secret => "$access_token_secret",
      apiurl => 'http://api.twitter.com/1.1',
      ssl                 => 1
);

$count=1;

# You will need to change this Twitter User Name 
# as you will grab the user ID's of this user's followers
# Do not add the @ symbol in front of their name
$user_to_find_followers = "mysql";

$dbh = ConnectToMySql($Database);
$query = "select user_id, next_cursor FROM user_cursors where user_id = '$user_to_find_followers' order by id desc limit 1";	
$sth = $dbh->prepare($query);
$sth->execute();

#print "\n$query\n";

$count_users = 0;

# loop through our results from mysql - even though it is only one line
while (@data = $sth->fetchrow_array()) {

	$cursor = $data[1];

# end while
}

# set the cursor to -1 for the first time you run this script
if (length($cursor) followers_ids({
        screen_name => "$user_to_find_followers",
        cursor      => "$cursor",
        });

# WARNING - for this script, you are grabbing 5,000 users 
# so that is a lot of output
# uncomment these lines to see what information is being returned
#    print "---DUMPER START---\n";
#    print Dumper $followers_list;
#    print "---DUMPER END---\n\n";

			$next_cursor = $followers_list->{next_cursor_str};
			$previous_cursor = $followers_list->{previous_cursor_str};
			
			print "next_cursor $next_cursor - previous_cursor $previous_cursor \n";

		for my $status2 ( @{$followers_list->{ids}} ) {

			$follower_id = $status2;
		
			# uncomment to watch as it prints each user
			#print "$count $user_to_find_followers $follower_id\n";

			$dbh = ConnectToMySql($Database);	
			$query = "insert into follows_other_users (user_to_find_followers, follower_id) values ('$user_to_find_followers','$follower_id')";
			#print "\n $query\n";
			$sth = $dbh->prepare($query);
			$sth->execute();

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
		$query = "insert into user_cursors (user_id, next_cursor, previous_cursor) values ('$user_id','$next_cursor','$previous_cursor')";
		print "\n $query\n";
		$sth = $dbh->prepare($query);
		$sth->execute();

#----------------------------------------------------------------------
sub ConnectToMySql {
#----------------------------------------------------------------------

# place the following information into a file named accessTweets
# and place this file in the directory BEFORE the directory where this script is located
# MySQL database name
# MySQL host name (IP address)
# MySQL user name
# MySQL user's password

   my ($db) = @_;

   open(PW, "<..\/accessTweets") || die "Can't access login credentials";
   my $db= ;
   my $host= ;
   my $userid= ;
   my $passwd= ;

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