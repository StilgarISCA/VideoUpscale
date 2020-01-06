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
##############################################################################
#use strict;
use warnings;
use POSIX();

$| = 1;

my $username = getpwuid( $< );

# User-defined parameters

my $FFMPEG = "/usr/local/bin/ffmpeg"; # path to ffmpeg executable
my $WAIFU2X = "/usr/local/bin/waifu2x"; # path to waifu2x executable https://github.com/imxieyi/waifu2x-mac

my $TMP = "/Users/$username/upscale/temp/";  # path to temporary file storage
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

  return;
}

#
# Upscales all images in a folder
#
# Accepts:
# -path to source folder
# -path to destination folder
#
sub UpscaleFrames
{
  my ( $src, $dst ) = @_;

  opendir( DIR, $src ) or die( "Could not open folder\n" );
  while( readdir( DIR ) ){
  	
  	next if (-d -z $_ );
  	
  	print "file: $_\n";
  	
  	local ($name, $ext) = split( /\./, $_ );
  	
  	local $cur_file_path = $src . $_;
  	local $dst_file_path = $dst . $name . ".png";
  	  
    system( "$WAIFU2X -t p -s 2 -n 4 -i $cur_file_path -o $dst_file_path" );
  }
  closedir( DIR );
  
  return;
}

### Start Main Program ###

print "Starting Execution\n";

# Test if file exists
die( "File does not exist or is empty\n $SRC\n" ) if not ( -s $SRC);

DumpFrames( $SRC, $TMP );

# Extract audio

UpscaleFrames( $TMP, $DST );

# Sharpen frames
# Interpolate
# Reassemble frames
# Reassemble audio

print "Execution Complete\n";
exit( 0 );