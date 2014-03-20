#!/usr/bin/perl

use strict;
use Getopt::Std;

my $USAGE=<<"USAGE";
Usage:
  $0 [-j,n,p,1,2,3]
Report:
    -j  maJor only      -1  major
    -n  miNor only      -2  major.minor        (DEFAULT)
    -p  Patch           -3  major.minor.patch
    -s output bourne shell commands to set and export os_{major,minor,patch}
USAGE

#### TODO
# Compare currently running OS: (and exit true / false)
#    -g N   return true if current >= N
#    -G N   return true if current >  N
#    -l N   return true if current <= N
#    -L N   return true if current <  N
# Test the fix for cygwin reports version of cygwin.dll, not Win OS
# $ os-version -3
# 1.5.24

my %opts;
getopts("dhjnps123", \%opts);
if ( defined $opts{h} ) {
    print $USAGE;
    exit 0;
}

my ($major, $minor, $patch);
my @flags = qw( -r -v -a );
unshift @flags, "-o" if ( `os.sh` =~ m{cygwin}i );
for my $flag (@flags) {
    my $str;
    if ( $opts{d} ) {
        $str = <STDIN>;                     ## test w/ manual input
    } else {
        $str = `uname $flag 2>/dev/null`;   ## live system data
    }
    chomp $str;
    if ( $str =~ m{(\d+)[\.\-_ ]+(\d+)(?:[\.\-_ ]+(\d+))?} ) {
        ( $major, $minor, $patch ) = ( $1, $2, $3 );
        last;
    }
}
if ( $opts{s} ) {
    print "os_major=$major
os_minor=$minor
os_patch=$patch
export os_major os_minor os_patch
"
} elsif ( $opts{j} || $opts{1} ) {
    print "$major\n";
} elsif ( $opts{n} ) {
    print "$minor\n";
} elsif ( $opts{p} ) {
    print "$patch\n";
} elsif ( $opts{2} ) {
    print "$major.$minor\n";
} elsif ( $opts{3} ) {
    print "$major.$minor.$patch\n";
} else {
    print "$major.$minor\n";
}
