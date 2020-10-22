#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use HTML::Strip::Whitespace qw(html_strip_whitespace);
use FileHandle;
use BerkeleyDB;
use BerkeleyDB::Hash;

# grab cli args
# if debug mode (-D) is used, files will not be renamed
# and instead will be orig_name.new
# you can use find . '*.new' -exec rm '{}' \;
# to remove them
my %opts;
getopts( 'Ded:', \%opts );
my $dir     = $opts{ 'd' } || die "missing dir for translation";
our $DEBUG  = $opts{ 'D' };

## timestamp file
my $tsFile = '.stage_last_run';
my $lastRun;

if ( -f $tsFile ) {
	$lastRun = `cat $tsFile`;
	chomp $lastRun;
}

## files to exclude
my $exclude = '(?:ie\.css|ie5_mac\.css|excel\.jsp|index_csv\.jsp|stats_csv_rsvps\.jsp|stats_csv_members\.jsp|stats_csv_joins\.jsp|xls\.jsp|send_defaultmessages_inc\.jsp|admin\/transactions\.jsp|admin\/org_survey\.jsp|email_download.jsp|admin\/pbm_queue\.jsp|admin\/user_testing_query\.jsp|admin\/threshold\.jsp|csv_rsvp_list\.jsp|admin\/.*\/email_copy\.jsp|admin\/ngq\.jsp)';

if ( -d $dir ) {
	# strip trailing / from dir
	$dir =~ s/\/$//;

	# setup berkley db
	my $env = new BerkeleyDB::Env(
		-Cachesize => 4 * 1024 * 1024,
		-Flags     => ( DB_CREATE | DB_INIT_LOCK | DB_INIT_MPOOL )
	) or die( "Failed to create DB env: '$!' ($BerkeleyDB::Error)" );

	my $bdb = new BerkeleyDB::Hash(
		-Filename => $dir . '/.html_opt.bdb',
		-Env      => $env,
		-Flags => DB_CREATE
	) or die( "unable to instantiate bdb store: $!" );

	parseDir( $dir, $bdb );
}
elsif ( -f $dir && $dir =~ /\.(?:jsp|jinc|vm)$/ ) {
	## do stuff
	optimize( $dir );
}
else {
	die "invalid dir/file: $dir\n";
}

# simple logger
# args:
#   $mesg -- mesg to log to STDERR
sub logger {
	my $mesg = shift;
	print STDERR $mesg, "\n" if ( $DEBUG );
}

# parse a directory recursively
# and optimize any css or js
# args:
#   $dir -- starting dir to parse
sub parseDir {
	my $dir = shift;
	my $bdb = shift;

	if ( $dir =~ /broadcast|img|sm|WEB-INF/ ) {
		logger( 'skipping dir due to exlusion rules: ' . $dir );
		return;
	}

	logger( "opening $dir" );
	opendir DIR, $dir;
	my @entries = readdir DIR;
	close DIR;
	logger( "closing $dir" );

	foreach ( @entries ) {

		# skip . and ..
		# skip any CVS dirs, and any vim/emacs backup files
		# skip anything under WEB-INF
		next if ( /^\./ || /CVS/ || /~$/ || /WEB-INF/ );

		my $ent = $dir . '/' . $_;

		if ( -d $ent ) {
			parseDir( $ent, $bdb );
		}
		elsif ( -f $ent && $ent =~ /\.(?:jsp|jinc|vm)$/ ) {
			# check to see if this file needs to be optimized
			my $version = getVersion( $ent );

			my $val;
			$bdb->db_get( $ent, $val );
			if ( $val ) {
				logger( "checking version for $ent: $val -> $version" );
				next if ( $val eq $version );
			}

			optimize( $ent );

			# store version
			$version = getVersion( $ent );
			$bdb->db_put( $ent, $version );
		}
	}
}

sub optimize {
	my $file = shift;

	if ( $file =~ /$exclude/o ) {
		logger( 'skipping file due to exlusion rules: ' . $file );
		return;
	}

	if ( $file =~ /\.(?:jsp|jinc|vm)$/ ) {
		if ( $lastRun ) {
			my @stat = stat $file;

			## if file modified earlier than last run, skip it
			if ( $stat[9] <= $lastRun ) {
				return;
			}
		}

		htmlTidy( $file );
	}
	else {
		print STDERR "unknown file type for $file\n";
		return;
	}
}

sub htmlTidy {
	my $input = shift;

	my $output = $input . '.new';

	## get a filehandle
	my $in = new FileHandle;
	$in->open( "<$input" );

	## actuall strip
	my $out = '';
	html_strip_whitespace( 'source' => $in, 'out' => \$out );
	$in->close;

	## strip jsp comments
	$out =~ s#<%--.*?--%>##gs;

	## collapse jstl tags (except c:out)
	$out =~ s#(</?(?:c|jsp):(?!out )[^>]+>)\s+(?=</?(?:c|jsp):(?!out ))#$1#g;

	## collapse jsp tags (except <%=)
	$out =~ s#(<%[^=].*?%>)\s+#$1#g;

	## clean empty lines
	$out =~ s#\n+#\n#gs;

	open OUT, ">$output";
	print OUT $out;
	close OUT;

	print "optimized $input\n";
	rename $output, $input unless $DEBUG;
}

sub getVersion {
	my $file   = shift;

	my $path = $file;
	unless ( -f $path ) {
		die "unknown file: $path\n";
	}

	my $version = `/usr/bin/md5sum "$path"`;
	chomp $version;

	unless ( $version ) {
		die "unknown file: $path\n";
	}

	my @ver = split /\s+/, $version;
	logger( "$path -> $ver[0]" );
	return $ver[0];
}
