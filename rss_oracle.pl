#!/usr/bin/perl -w

use LWP::Simple 'get';
use Encode;
use utf8;
use Text::Unidecode;
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use XML::FeedPP;

	my $source = 'https://www.oracle.com/corporate/press/rss/rss-pr.xml';
    my $feed = XML::FeedPP->new( $source );

foreach my $item ( $feed->get_item() ) {

	$post_id = $item->guid();
	$title = $item->title();


	# this is where you have to replace non-ASCII characters
	# each RSS feed will use different non-ASCII characters
	$title = decode_utf8( $title );
	$title =~ s/’/\^/g;
	$title =~ s/\&\#8217;/^/g;
	$title =~ s/\&\#8216;/^/g;
	$title =~ s/\&\#8212;/-/g;
	$title =~ s/\&\#8230;/-/g;
	$title =~ s/'/\^/g;
	$title =~ s/‘/\^/g;
	$title =~ s/’/^/g;
	$title =~ s/…/.../g;
	$title =~ s/—/-/g;
	$title =~ s/-/-/g;
	$title =~ s/–/-/g;
	$title =~ s/ 8212 /-/g;
	$title =~ s/ 8230 /-/g;
	$title =~ s/<em>//g;
	$title =~ s/<\/em>//g;
	$title =~ s/[^a-zA-Z0-9 ~,._*:?\$^-]//g;

	$link = $item->link();

	# uncomment this line to test
	#print "$post_id | $title | $link\n";
			
	# see if we already have this post in the RSS database	
	$dbh = ConnectToMySql($Database);
	$query = "select id_post FROM rss_oracle where id_post = '$post_id' limit 1";	
	$sth = $dbh->prepare($query);
	$sth->execute();

			#print "\n$query\n\n";

	# loop through our results - one user at a time
	while (@data = $sth->fetchrow_array()) {
		$id_post_found = $data[0];
	# end - while
	}

		#print "id_post_found $id_post_found \n";

		if (length($id_post_found) > 1)
			
		{
			#print "Found $id_post_found...\n";
			$id_post_found = "";
		}
			
		else
			
		{
			$dbh2 = ConnectToMySql($Database);
			$query2 = "insert into rss_oracle (id_post, post_title, post_url) values ('$post_id', '$title', '$link')";	
			$sth2 = $dbh2->prepare($query2);
			# during testing, comment this next line to prevent the data from being inserted into the database
			$sth2->execute();
			#print "$query2\n";

			$title = "";
			$link = "";
			$id_post_found = "";
			
		}

	# foreach my $item
    }

exit;


#----------------------------------------------------------------------
sub ConnectToMySql {
#----------------------------------------------------------------------

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