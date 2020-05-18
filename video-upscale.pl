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
use File::Basename;

$| = 1;

my $username = getpwuid( $< );

# User-defined parameters

my $FFMPEG = "/usr/local/bin/ffmpeg"; # path to ffmpeg executable
my $WAIFU2X = "/usr/local/bin/waifu2x"; # path to waifu2x executable https://github.com/imxieyi/waifu2x-mac
my $IMAGEMAGICK = "/usr/local/bin/convert"; # path to imagemagick executable

my $TMP = "/Users/$username/upscale/temp/";  # path to temporary file storage
my $SRC = "/Users/$username/upscale/test.mp4";  # path to video to upscale
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
# Gets a list of filepaths from a dir
# Excludes . and ..
#
# Accepts:
# -path to dir
# Returns:
# -Array of full paths to files
sub GetFilesFromDir
{
  my ( $dir ) = @_;

  my @arr_filepaths = ();

  opendir( DIR, $dir ) or die( "Could not open folder\n" );

  while ( readdir( DIR ) ) {
  	next if ( -d -z -B $_ );
  	next if ( $_ eq "." or $_ eq ".." or $_ eq ".DS_Store" );
    push( @arr_filepaths, ("$dir" . "$_") ); 	
  }

  close( DIR );

  return @arr_filepaths;
}

#
# Sharpens image in a given path
#
# Accepts:
# -path to source file
# -path to destination folder
sub SharpenFrame
{
  my ( $src, $dst ) = @_;

  print "Sharpening file: $src\n";

  local ($name, $path, $ext) = fileparse( $src );
  local $dst_file_path = $dst . "tmp_" . $name;

  system( "$IMAGEMAGICK $src -sharpen 0x1 $dst_file_path" );
 
  # Maybe a better sharpen depending on the source
  # system( "$IMAGEMAGICK $cur_file_path -unsharp 10x4+1+0 $dst_file_path" );
 
  return;
}

#
# Upscales image in a given path
#
# Accepts:
# -path to source file
# -path to destination folder
#
sub UpscaleFrame
{
  my ( $src, $dst ) = @_;

  print "Upscaling file: $src\n";
 
  local ($name, $path, $ext) = fileparse( $src );
  local ($name, $ext) = split( /\./, $name );
  local $dst_file_path = $dst . $name . ".png";

  system( "$WAIFU2X -t p -s 2 -n 3 -i $src -o $dst_file_path" );

  return;
}

### Start Main Program ###

print "Starting Execution\n";

# Test if file exists
die( "File does not exist or is empty\n $SRC\n" ) if not ( -s $SRC);

DumpFrames( $SRC, $TMP );

# Extract audio

# Upscale Frames
my @raw_frames = GetFilesFromDir( $TMP );
foreach $frame ( @raw_frames ) {
  UpscaleFrame( $frame, $DST );
}

# Sharpen Frames
my @upscaled_frames = GetFilesFromDir( $DST );
foreach $frame ( @upscaled_frames ) {
  SharpenFrame( $frame, $DST );
}

# Apply gausian blur to smooth artifacts?
# convert src.png -gaussian-blur 2x10 dst.png
# convert src.png -gaussian-blur .5x30 dst.png

# Interpolate
# Reassemble frames
# Reassemble audio

print "Execution Complete\n";
exit( 0 );