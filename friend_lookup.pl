#!/usr/bin/perl
 
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';
use Encode;
       
# ----------------------------------------------------------------------------
# get the relationship between my user name and another user name to see
# if they are following me or if I am following them
# ----------------------------------------------------------------------------

$number = 1;

# you are allowed 180 of these lookups every 15 minutes
# with a 15 second pause at the end of each one, you won't 
# go over the limit
while ($number new(
      traits              => [qw/API::RESTv1_1/],
      consumer_key        => "$consumer_key",
      consumer_secret     => "$consumer_secret",
      access_token        => "$access_token",
      access_token_secret => "$access_token_secret",
      apiurl => 'http://api.twitter.com/1.1',
      ssl                 => 1
);

# 278605279   <- follows me and I follow them 
# 2174997891  dumper_out.txt") || die "Can't redirect stdout";


$dbh = ConnectToMySql($Database);
$query = "select follower_id, user_to_find_followers FROM follows_other_users_book where looked_up_info IS NULL limit 100";	
# run to see if you can debug why some users get an error
#$query = "select follower_id, user_to_find_followers FROM follows_other_users_book where looked_up_info = 'err' limit 100";	
$sth = $dbh->prepare($query);
$sth->execute();

print "\n$query\n";

$count_users = 0;

#			print "name | friends_count | followers_count | statuses_count | percent_follow\% |$time_zone | description | creation_datetime\n";


# loop through our results - one tweet at a time
while (@data = $sth->fetchrow_array()) {

	print "$data[0] ";

	$user_id = $data[0];
	$user_to_find_followers = $data[1];

if (length($data[0])  0)

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

# end - while (@data = $sth->fetchrow_array()) {
}

#print "$users_to_get\n";





$count = 1;

#while (@data2) {



			print "--------------------------------------------------------------------------------------------------\n";


	eval {

    			my $user_info = $nt->lookup_users({ 
    				user_id => [ "$users_to_get" ] 
    			});

	print OUT "---DUMPER START---\n";
	print OUT Dumper $user_info;
	print OUT "---DUMPER END---\n\n";

			if ( my $err = $@ ) {
				die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

				warn "\n - HTTP Response Code: ", $err->code, "\n",
				"\n - HTTP Message......: ", $err->message, "\n",
				"\n - Twitter error.....: ", $err->error, "\n";
			}


		for my $status ( @$user_info ) {

			if (length($status->{name}) {name};
			$name =~ s/[^[:ascii:]]//g;
			$name =~ s/[^!-~\s]//g;
			$name = decode_utf8( $name );
			$name =~ s/\'/\^/g;
			print "Working on $name - ";



			$user_id = $status->{id};
			$following_count = $status->{friends_count};
			$followers_count = $status->{followers_count};
			$statuses_count = $status->{statuses_count};
			$time_zone = $status->{time_zone};

			$screen_name = $status->{screen_name};
			$screen_name =~ s/[^[:ascii:]]//g;
			$screen_name = decode_utf8( $screen_name );
			$screen_name =~ s/[^a-zA-Z0-9 _^-]//g;
			$screen_name =~ s/[^!-~\s]//g;

			$description = $status->{description};
			
			if (length($description)  'Wed Nov 09 19:38:46 +0000 2011',

			$created_at = $status->{created_at};


			@creation_date_array = split(" ",$created_at);
		
			$creation_date_month = $creation_date_array[1];
			
			if ($creation_date_month =~ "Jan") { $creation_date_month = "01"}
			if ($creation_date_month =~ "Feb") { $creation_date_month = "02"}
			if ($creation_date_month =~ "Mar") { $creation_date_month = "03"}
			if ($creation_date_month =~ "Apr") { $creation_date_month = "04"}
			if ($creation_date_month =~ "May") { $creation_date_month = "05"}
			if ($creation_date_month =~ "Jun") { $creation_date_month = "06"}
			if ($creation_date_month =~ "Jul") { $creation_date_month = "07"}
			if ($creation_date_month =~ "Aug") { $creation_date_month = "08"}
			if ($creation_date_month =~ "Sep") { $creation_date_month = "09"}
			if ($creation_date_month =~ "Oct") { $creation_date_month = "10"}
			if ($creation_date_month =~ "Nov") { $creation_date_month = "11"}
			if ($creation_date_month =~ "Dec") { $creation_date_month = "12"}
		
			$creation_date_day_of_month = $creation_date_array[2];
			$creation_date_year = $creation_date_array[5];
			$creation_date_time = $creation_date_array[3];
			$creation_datetime = "$creation_date_year-$creation_date_month-$creation_date_day_of_month $creation_date_time";

			# had to add this as the percentage formula below would fail
			if ($following_count < 1)
			
			{
			
				$following_count = 1;
			
			}
			if ($followers_count prepare($query);
			$sth->execute();


			$dbh2 = ConnectToMySql($Database);	
			$query2 = "update follows_other_users_book set looked_up_info = 'yes' where follower_id = '$user_id'";
			#print " $count ----  $query2\n";
			print "--------------------------------------------------------------------------------------------------\n";
			$sth2 = $dbh2->prepare($query2);
			$sth2->execute();

#sleep 1;

$count++;
		}


# end - eval
};


#599


$number++;



	# if we didn't grab all 100 users, change the last user's status to error
	#print "Count $count\n";
	if ($count prepare($query3);
		$sth3->execute();
		exit;
	}

# if there aren't any more users, quit
if (length($data[0]) fetchrow_array()) {
#}






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


close(OUT);


#sleep 900;

exit;