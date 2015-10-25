#!/usr/bin/perl
# Updated 2015-10-25

use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';

# ----------------------------------------------------------------------------
# see if a user follows me and/or if i follow them
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

# limit must be 100 or less
$limit = 100;

# how many days do you want to wait until you unfriend someone?

$date_to_delete = "2015-10-21";

# find the stats and info for the following users

$dbh = ConnectToMySql($Database);
$query = "select user_id, sent_request_datetime FROM twitter_users where sent_follow_request = 'yes' and sent_request_datetime < '$date_to_delete' and followed_me is NULL and unfollowed_them is NULL limit $limit";	
#$query = "select follower_id, user_to_find_followers FROM follows_other_users where looked_up_info = 'err' limit 99";	
$sth = $dbh->prepare($query);
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

print "$users_to_get\n\n";

#exit;

eval {

	my $friend = $nt->lookup_friendships({ user_id => "$users_to_get" });
    
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
 
 			# get user_id
 			
 			#print "$user_id_str - ";
 
 
 
 			# once you have the status of the connection and the user_id
 			# you can check to see if they are following you or not
 
				if ($status_friend =~ "followed_by")
        	
				{
        	
					print "*************\nThis person $user_id_str follows you. - $sent_request_datetime";
					print "Status: $status_connection1 $status_connection2\n*************\n";

					$dbh2 = ConnectToMySql($Database);
					$query2 = "update twitter_users set followed_me = 'yes' where user_id = '$user_id_str'";	
					$sth2 = $dbh2->prepare($query2);
					$sth2->execute();

					print "\n$query2\n";
					print "########\n $count of $limit sleeping....\n########\n";
					sleep 155;

# loop through our results - one tweet at a time
#while (@data2 = $sth2->fetchrow_array()) {

#	$user_id = $data2[0];
#	$sent_request_datetime = $data2[1];
	
#	print "         - you followed them on $sent_request_datetime \n"
	
#	}

    		
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
					$query3 = "update twitter_users set followed_me = 'no' where user_id = '$user_id_str'";	
					$sth3 = $dbh3->prepare($query3);
					$sth3->execute();

					print "\n$query3\n";

					$dbh4 = ConnectToMySql($Database);
					$query4 = "update twitter_users set unfollowed_them = 'yes' where user_id = '$user_id_str'";	
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

    		# if ($role =~ "connections")
    		}
    		
    		# for $role ( keys %$data_list ) {
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
