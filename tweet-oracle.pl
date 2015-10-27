#!/usr/bin/perl
 
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;

$My_Twitter_User = "YourTwitterNameHere";

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
# retrieve tweet from database
# ----------------------------------------------------------------------------------

	$dbh = ConnectToMySql($Database);
	$query = "select id_post, post_title, post_url FROM rss_oracle where tweet_sent is NULL order by id_post asc limit 1";	
    $sth = $dbh->prepare($query);
    $sth->execute();
    
    #print "$query \n";
    
			while (@data = $sth->fetchrow_array()) {
            
					$id_post = $data[0];
					$post_title = $data[1];
					$post_url = $data[2];

				$post_title =~s/  / /g;
				$post_title =~s/ ampamp / and /g;

			# while (@data = $sth->fetchrow_array()) {
			}
			
			
if (length($post_title) < 2)

{

	exit;

}

	if (length($post_title) > 100)

	{
		$title_trimmed = substr($post_title,0,105);
		$title_trimmed = "$title_trimmed...";
		#print "TRIM $title_trimmed\n";

			if ($title_trimmed =~ " Oracle ")

			{
				$title_trimmed =~ s/ Oracle / \#Oracle /;
			}

			else

			{
				$add_Hashtag = " \#Oracle ";
			}		


	}
	
	else
	
	{
		$title_trimmed = "$post_title";
		$title_trimmed =~ s/ Oracle / \#Oracle /;
		#print "x $title_trimmed\n";
	}


$tweet = "$title_trimmed $add_Hashtag \n\n$post_url";

$tweet =~ s/  / /g;
$tweet =~ s/  / /g;

$add_Hashtag = "";

#print "$tweet \n";

#exit;

# ----------------------------------------------------------------------------
# find carats and substitue for single quote
# ----------------------------------------------------------------------------

$tweet =~ s/\^/\'/g;

# ----------------------------------------------------------------------------
# send tweet
# ----------------------------------------------------------------------------


# Credentials for your twitter application
# You will need to substitute your own values for these variables
my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
      traits              => [qw/API::RESTv1_1/],
      consumer_key        => "$consumer_key",
      consumer_secret     => "$consumer_secret",
      access_token        => "$access_token",
      access_token_secret => "$access_token_secret",
      apiurl => 'http://api.twitter.com/1.1',
      ssl                 => 1
);


	# send the tweet
	my $results = eval { $nt->update("$tweet") };

#		    print "---DUMPER START---\n";
#			print Dumper $results;
#		    print "---DUMPER END---\n\n";


# ----------------------------------------------------------------------------
# update mysql with new date for last_tweet date/time
# ----------------------------------------------------------------------------

$dbh = ConnectToMySql($Database);
$query = "UPDATE rss_oracle SET tweet_sent_date = '$DateTime' , tweet_sent = 'yes' where id_post = '$id_post'";
$sth = $dbh->prepare($query);
$sth->execute();

# ----------------------------------------------------------------------------
# get the status id of the last tweet
# ----------------------------------------------------------------------------

my $statuses = $nt->user_timeline({ user => "$My_Twitter_User", count=> 1 });

for my $status ( @$statuses ) {
	$tweet_id = "$status->{id}";
#	print "Tweet ID $tweet_id\n";
}


# ----------------------------------------------------------------------------
# replace special characters
# ----------------------------------------------------------------------------

$tweet =~ s/\\\n/~/g;
$tweet =~ s/\n/~/g;
$tweet =~ s/\'/^/g;

# update mysql with new date for last_tweet date/time

$dbh = ConnectToMySql($Database);	
$query = "insert into history (tweet,tweet_id,tweet_update) values ('$tweet','$tweet_id','$DateTime')";
$sth = $dbh->prepare($query);
$sth->execute();

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

