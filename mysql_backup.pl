#!/usr/bin/perl
# Perform a mysqldump on all the databases specified in the dbbackup.config file

use warnings;
use File::Basename;
use Net::FTP;

# example config file
# You may use a comment (#) to bypass any database that you don't want to backup
# # Unwanted_DB    (commented - will not be backed up)
# database_01
# database_02

# set the directory where you will keep the backup files
$backup_folder = '/Users/tonydarnell/cron/mysqlbackups';

# the config file is a text file with a list of the databases to backup
# this should be in the same location as this script, but you can modify this
# if you want to put the file somewhere else
my $config_file = dirname($0) . "/mysql_backup.config";

# retrieve a list of the databases from the config file
my @databases = removeComments(getFileContents($config_file));

# change to the directory of the backup files.
chdir($backup_folder) or die("Cannot go to folder '$backup_folder'");

# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------
# grab the local time variables
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$mon++;
#Zero padding
$mday = '0'.$mday if ($mday<10);
$mon = '0'.$mon if ($mon<10);
$hour = "0$hour" if $hour < 10;
$min = "0$min" if $min < 10;

$DateTime = "$year-$mon-$mday-$hour:$min:$sec";

# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------

print "Beginning $DateTime\n";

# create the name of the backup folder that will contain all of the backup files
	my $folder = "$year-$mon-$mday-$hour$min";
	mkdir($folder) or die("Cannot create a folder called '$folder'");

# Here is where you will put your FTP server name (or IP address)
# and your username and password
my $host = "server_name.com";
my $user = "username";
my $password = "password";

# login to the FTP site
my $f = Net::FTP->new($host) or die "Can't open $host\n";
$f->login($user, $password) or die "Can't log $user in\n";

# uncomment the last three lines if you can't set the home directory of the FTP user to a specific directory
# the directory on the FTP server where you want to save the backup files
# my $dir = "mysqlbackups";
# print "Accessing FTP - changing to $dir folder\n";
# $f->cwd($dir) or die "Can't cwd to $dir\n";

# backup each database contained in the @databases array
foreach my $database (@databases) {
	next if ($database eq '');
	chomp($database);

	my $table = '';
	# Get just 1 table in the database - if there is a ' '(space) in the db name
	if(index($database,' ')+1) { 
		my @parts = split(' ',$database);
		$database = $parts[0];
		$table = $parts[1];
	}

	print "Backing up $database - $folder ... ";

 	my $file = $database;
 	$file .= '_' . $table if($table ne '');
 	$file .= ".sql";

	# perform a mysql dump on each database
	# change the path of mysqldump to match your system's location
	# make sure that you change the root password to match the correct password

 	`/usr/local/mysql/bin/mysqldump -R --events --triggers -u root --password=PassWord --routines --add-drop-database --set-gtid-purged=OFF --add-drop-table $database $table | compress > $folder/$file.Z`;

	print "Finished exporting $database - as $folder/$file.Z\n";

}

$output = "Compressing backup as:  $folder\.tar\.gz";

print "------------------------------------------------------------------\n";
print " $output \n";
print "------------------------------------------------------------------\n";
print "Creating a tar file from the backup...\n"
# tar the folder and compress it
print "tar -czf $folder\.tar\.gz $folder\n";
system("tar -czf $folder\.tar\.gz '$folder'");

# set the file name of the backup
my $file_to_put = "$folder\.tar\.gz";

# put the file on the FTP server
print "FTP'ing the file - $folder\.tar\.gz \n";
$f->binary();
$f->put($file_to_put) or die "Can't put $file_to_put\n";

print "Deleting the original backup directory and files.";
# delete the original backup directory and files - since we have put them all into a tar file
system("rm -r $folder");

# close the FTP connection
$f->quit();	

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

$DateTime = "$year2-$mon2-$mday2-$hour2:$min2:$sec2";

print "Finished $DateTime\n";

# ------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------

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

