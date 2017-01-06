#!/usr/local/bin/perl -w
# a script to delete old FTP backup files

use warnings;
use Net::FTP;

# Here is where you will put your FTP server name (or IP address)
# and your username and password
my $host = "server_name.com";
my $user = "username";
my $password = "password";

# how many copies of the backup do you want to keep?
$total_files_to_keep = 5;

$print_output = "yes";

my $f = Net::FTP->new($host) or die "Can't open $host\n";
$f->login($user, $password) or die "Can't login $user\n";

$, = "\n";
my @files = $f->ls;

# get the total number of files in the directory
$total_files = $#files;

# add one because array starts at zero
$total_files = $total_files + 1;

# subtract two because of the . and ..
$total_files_available = $total_files - 2;


# subtract two because of the . and .. 
$total_files_to_delete = $total_files_available - $total_files_to_keep;

if ($total_files_to_keep > $total_files_available)

{
	if ($print_output eq "yes") { print "There aren't any extra files to delete.\n"; }
	exit;
}

if ($print_output eq "yes") { print "--------------------------------------------\n"; }
if ($print_output eq "yes") { print "           Total files: $total_files\n"; }
if ($print_output eq "yes") { print "    Total backup files: $total_files_available\n"; }
if ($print_output eq "yes") { print "   Total files to keep: $total_files_to_keep\n"; }
if ($print_output eq "yes") { print " Total files to delete: $total_files_to_delete\n"; }
if ($print_output eq "yes") { print "----------------------------------------------\n"; }

# set a counter for looping through the files
$count = 0;

@files2 = sort @files;

foreach my $filename (@files2) {

		# this matches any files ending in tar.gz
		if ($filename =~ "tar.gz")

		{
			# increase the counter
			$count++;

			# how many total records to delete - plus 1 as I am using a less-than comparison
			if ($count < $total_files_to_delete + 1)
		
			{
				if ($print_output eq "yes") { print "| $count of $total_files_available |  Deleting: $filename\n"; }
				# uncomment to delete the backup
				$f->delete($filename);
			}
		
			else
			
			{
				# optional output - remove # to have it print remaining files
				if ($print_output eq "yes") { print "| $count of $total_files_available |   Keeping: $filename\n"; }
				
			}
		
		}
		
		else
		
		{
				if ($print_output eq "yes") { print "| x of $total_files_available |  Skipping: $filename\n"; }
		}

}

# close the FTP connection
$f->quit();

if ($print_output eq "yes") { print "----------------------------------------------\n"; }

# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------

# grab the local time variables
my ($sec2,$min2,$hour2,$mday2,$mon2,$year2,$wday2,$yday2,$isdst2) = localtime(time);
$year2 += 1900;
$mon2++;
#Zero padding
$mday2 = '0'.$mday2 if ($mday2<10);
$mon2 = '0'.$mon2 if ($mon2<10);
$hour2 = "0$hour2" if $hour2 < 10;
$min2 = "0$min2" if $min2 < 10;

$DateTime2 = "$year2-$mon2-$mday2-$hour2:$min2:$sec2";

print "Finished $DateTime2\n";

# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------

exit;

# this subroutine simply creates an array of the list of the databases
sub getFileContents {
	my $file = shift;
	open (FILE,$file) || die("Can't open '$file': $!");
	my @lines=<FILE>;
	close(FILE);

	return @lines;
}

# remove any commented tables from the @lines array
sub removeComments {
	my @lines = @_;

	@cleaned = grep(!/^\s*#/, @lines); #Remove Comments
	@cleaned = grep(!/^\s*$/, @cleaned); #Remove Empty lines

	return @cleaned;
}

