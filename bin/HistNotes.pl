#!/usr/bin/perl
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2018 PeterWalsh, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      HistNotes.pl
##
##  DESCRIPTION
##      Print out a histogram of all notes contained in all MIDI files in the current directory.
##
##  USAGE
##      perl HistNotes.pl
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

use MIDI;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

my @Hist;

my @Files = <*.mid>;

########################################################################################################################
########################################################################################################################
##
## HistNotes
##
########################################################################################################################
########################################################################################################################

die "No MIDI files in directory"
    unless @Files;

foreach my $File (@Files) {

    my @Lines;

    @Lines = `perl ../bin/MidiDump.pl $File`;
    @Lines = grep { /note_on/ } @Lines;

    foreach my $Line (@Lines) {
        my ($Prefix,$DTime,$Chan,$Note,$Vel) = split /,/,$Line;
        chop $Vel;      # Remove trailing bracket

        if( $Note < 21 || $Note > 108 ) {
            print "File $File has notes out of range\n";
            last;
            }

        #
        # Velocity == 0 is an alias for "note off". Disregard these.
        #
        next
            if $Vel == 0;

        $Hist[$Note]++;
        }
    }

for( my $i=0; $i < @Hist; $i++ ) {
    $Hist[$i] //= 0;
    printf "%3d: %d\n",$i,$Hist[$i];
    }
