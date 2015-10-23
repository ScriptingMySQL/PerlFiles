#!/usr/bin/perl
 
use Net::Twitter::Lite::WithAPIv1_1;
use DBI;
use DBD::mysql;
use Data::Dumper;
use Scalar::Util 'blessed';
#use Encode;
use JSON;
  
# -----------------------------------
# get the API rate limits for my user
# -----------------------------------

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

	eval {
    			my $user_info = $nt->rate_limit_status;

#	print "---DUMPER START---\n";
print Dumper $user_info;
#	print "---DUMPER END---\n\n";

			if ( my $err = $@ ) {
				die $@ unless blessed $err && $err->isa('Net::Twitter::Lite::Error');

				warn "\n - HTTP Response Code: ", $err->code, "\n",
				"\n - HTTP Message......: ", $err->message, "\n",
				"\n - Twitter error.....: ", $err->error, "\n";
			
			# end if
			};

# end - eval
}

exit;