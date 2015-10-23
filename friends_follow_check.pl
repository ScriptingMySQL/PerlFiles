#!/usr/bin/perl
 
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';

# --------------------------------------------------------
# see if a user follows me and unfollow them if they don't
# --------------------------------------------------------

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

# limit must be 100 or less
$limit = 100;

# how many days do you want to wait until you unfriend someone?
$date_to_delete = "2015-10-13";


# find the stats and info for the following users

$dbh = ConnectToMySql($Database);
$query = "select user_id, sent_request_datetime FROM twitter_users_wild where sent_follow_request = 'yes' and sent_request_datetime prepare($query);
$sth->execute();

print "\n$query\n\n\n";

$count_users = 0;
$count = 0;

# loop through our results - one tweet at a time
while (@data = $sth->fetchrow_array()) {

	$user_id = $data[0];
	$sent_request_datetime{$user_id} = $data[1];

	if ($count_users > 0)

	{
		$users_to_get = "$users_to_get, $user_id";
		push(@data2, "$user_id");
	}

	else

	{
		$users_to_get = "$user_id";
		push(@data2, "$user_id");
	}

$count_users++;

# end - while
}

# Optional output
print "$users_to_get\n\n";

eval {

	my $friend = $nt->lookup_friendships({ user_id => "$users_to_get" });
#	my $friend = $nt->lookup_friendships({ target_id => '278605279' });
    
#    print "---DUMPER START---\n";
#	print Dumper $friend;
#    print "---DUMPER END---\n\n";

			if ( my $err = $@ ) {
				die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

				warn "\n - HTTP Response Code: ", $err->code, "\n",
				"\n - HTTP Message......: ", $err->message, "\n",
				"\n - Twitter error.....: ", $err->error, "\n";
			
			# end if
			};

	for $data_list ( @$friend ) {

	$count++;
   
		for $role ( keys %$data_list ) {
        	
        	if ($role =~ "id_str")
        	
        	{
        			# since the connection info is an array, find the values
        			$user_id_str = $data_list->{$role};
 
 					$user_id = $user_id_str;
 
 			# once you have the status of the connection and the user_id
 			# you can check to see if they are following you or not
 
				if ($status_friend =~ "followed_by")
        	
				{
        	
					print "*************\nThis person $user_id_str follows you. - $sent_request_datetime";
					print "Status: $status_connection1 $status_connection2\n*************\n";

					$dbh2 = ConnectToMySql($Database);
					$query2 = "update twitter_users_wild set followed_me = 'yes' where user_id = '$user_id_str'";	
					$sth2 = $dbh2->prepare($query2);
					$sth2->execute();

					print "\n$query2\n";
					print "########\n $count of $limit sleeping....\n########\n";
					sleep 155;
    		
				}
    		
				else
    		
				{
    		
					print "This person $user_id_str DOES NOT follow you. - $sent_request_datetime{$user_id}\n";
					print "Status: $status_connection1 $status_connection2\n";

	eval {

		my $friend = $nt->destroy_friend({ user_id => "$user_id" });
		#	my $friend = $nt->lookup_friendships({ target_id => '278605279' });
    
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

					$dbh3 = ConnectToMySql($Database);
					$query3 = "update twitter_users_wild set followed_me = 'no' where user_id = '$user_id_str'";	
					$sth3 = $dbh3->prepare($query3);
					$sth3->execute();

print "\n$query3\n";

					$dbh4 = ConnectToMySql($Database);
					$query4 = "update twitter_users_wild set unfollowed_them = 'yes' where user_id = '$user_id_str'";	
					$sth4 = $dbh4->prepare($query4);
					$sth4->execute();

print "\n$query4\n";
print "########\n $count of $limit sleeping ";
# pause for a random time so twitter doesn't think you are a robot
# minimum and maximum time in seconds to sleep
$minimum = 60; 
$maximum = 120;
$random_sleep = int($minimum + rand($maximum - $minimum));

print " for $random_sleep seconds\n";
sleep $random_sleep;

				# unfollow this user
				}
 
 			# end - if ($role =~ "id_str")
 			}

        	# check the status of the connection        	
        	if ($role =~ "connections")
        	
        	{
        			# since the connection info is an array, find the values
        			$status_connection1 = $data_list->{$role}[0];
        			$status_connection2 = $data_list->{$role}[1];
        			$status_connection3 = $data_list->{$role}[2];
        	
        	$status_friend = "$status_connection1 $status_connection2 $status_connection3";
    		
    		# end - if ($role =~ "connections")
    		}

    		
    		# end - for $role ( keys %$data_list ) {
    		}
   		
    		# end - for $data_list ( @$friend ) {
    		}

# end - eval
};

# end - while
#}

print "\n\n";

exit;


#----------------------------------------------------------------------
sub ConnectToMySql {
#----------------------------------------------------------------------

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