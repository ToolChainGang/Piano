#!/usr/bin/perl
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2018 PeterWalsh, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      GetMutopiaSongs.pl
##
##  DESCRIPTION
##      Get all piano songs from the Mutopia website (with .mid extension)
##
##  USAGE
##      perl GetMutopiaSongs.pl
##
########################################################################################################################
########################################################################################################################
##
##  MIT LICENSE
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy of
##    this software and associated documentation files (the "Software"), to deal in
##    the Software without restriction, including without limitation the rights to
##    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
##    of the Software, and to permit persons to whom the Software is furnished to do
##    so, subject to the following conditions:
##
##  The above copyright notice and this permission notice shall be included in
##    all copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
##    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
##    PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
##    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
##    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
##    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##
########################################################################################################################
########################################################################################################################

use strict;
use warnings;
use Carp;

our $VERSION = '1.0';

use LWP::UserAgent;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

my $MainURL = "http://www.mutopiaproject.org/cgibin/make-table.cgi?startat=%d&searchingfor=&Composer=&Instrument=Piano&Style=&collection=&id=&solo=&recent=&timelength=1&timeunit=week&lilyversion=&preview=";

my $Browser = LWP::UserAgent->new;
$Browser->agent("Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:44.0) Gecko/20100101 Firefox/44.0");

my $FileCount = 0;

########################################################################################################################
########################################################################################################################
##
## Get songs
##
########################################################################################################################
########################################################################################################################

#
# Go through the Mutopia website one page at a time, each page should contain 10 MID files.
#
for( my $Start = 0; $Start < 1000; $Start += 10 ) {
    my $URL = sprintf($MainURL,$Start);

#    print "URL: $URL\n";
    my $HTTP = $Browser->get($URL);
#    print $HTTP->status_line() . "\n";

    #
    # Any problems, assume we reached the end of their list (about 700 files, as of this writing)
    #
    last
        unless defined $HTTP;

    #
    # <td><a href="http://www.mutopiaproject.org/ftp/Anonymous/lesgraces/lesgraces.mid">.mid file</a></td>
    #
    my @Lines;

    @Lines = split /\n/,$HTTP->decoded_content;
    @Lines = grep { /\.mid file/ } @Lines;

    last
        if scalar @Lines <= 0;

    foreach my $Line (@Lines) {
        $Line = After ($Line,"<td><a href=\"");
        $Line = Before($Line,"\">.mid file</a></td>");

        print "Getting: $Line\n";

        print `wget $Line`;
#        `echo $Line >foo.txt`;

        $FileCount++;
        }
  
    }

print "Done! $FileCount files downloaded\n";
exit(1);


########################################################################################################################
########################################################################################################################
#
# Before - Return part of string before another
#
# Inputs:   String to cut
#           Pattern to cut on
#
# Outputs:  Everything before Pattern, in string
#
sub Before {
    my $String  = shift;
    my $Pattern = shift;

    my $Offset = index($String,$Pattern);
    return substr($String,0,$Offset);
    }


########################################################################################################################
########################################################################################################################
#
# After - Return everything in string after pattern
#
# Inputs:   String to cut
#           Pattern to cut on
#
# Outputs:  Everything after Pattern, in string
#
sub After {
    my $String  = shift;
    my $Pattern = shift;

    my $Offset = index($String,$Pattern) + length($Pattern);
    return substr($String,$Offset);
    }
