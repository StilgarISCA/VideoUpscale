#!/usr/bin/perl
##############################################################################
# Script: video-upscale.pl
# Author: Glenn Hoeppner
# License: MIT
# Repository: https://github.com/StilgarISCA/VideoUpscale
#
# Script which makes use of other libraries and executibiles to upscale 
# videos.
#
# https://github.com/imxieyi/waifu2x-mac
##############################################################################
use strict;
use warnings;
use POSIX();

my $username = getpwuid( $< );

# User-defined parameters

my $FFMPEG = "/usr/local/bin/ffmpeg"; # path to ffmpeg executable
my $WAIFU2x = ""; # path to waifu2x executable

my $TMP = "";  # path to temporary file storage
my $SRC = "/Users/$username/upscale/source/test.mp4";  # path to video to upscale
my $DST = "/Users/$username/upscale/output/";  # path for final video

# No user-defined parameters beyond this point

#
# Dump frames from a video
#
# Accepts:
# -path to source file
# -path to destination folder
#
sub DumpFrames
{
  my ( $src, $dst ) = @_;
  
  $dst .= "image%06d.jpg";
  
  system( $FFMPEG, "-i", $src , $dst, "-hide_banner" );
}

### Start Main Program ###

print "Starting Execution\n";

# Test if file exists
die( "File does not exist or is empty\n $SRC\n" ) if not ( -s $SRC);

DumpFrames( $SRC, $DST );

# Extract audio
# Upscale frames
# Sharpen frames
# Interpolate
# Reassemble frames
# Reassemble audio

print "Execution Complete\n";
exit( 0 );