package Music::Tag::OGG;
our $VERSION = 0.32;

# Copyright (c) 2007,2008 Edward Allen III. Some rights reserved.
#
## This program is free software; you can redistribute it and/or
## modify it under the terms of the Artistic License, distributed
## with Perl.
#

=pod

=head1 NAME

Music::Tag::OGG - Plugin module for Music::Tag to get information from ogg-vorbis headers. 

=head1 SYNOPSIS

	use Music::Tag

	my $filename = "/var/lib/music/artist/album/track.ogg";

	my $info = Music::Tag->new($filename, { quiet => 1 }, "OGG");

	$info->get_info();
   
	print "Artist is ", $info->artist;

=head1 DESCRIPTION

Music::Tag::OGG is used to read ogg-vorbis header information. It uses Ogg::Vorbis::Header::PurePerl.  I have gone back and forth with using this
and Ogg::Vorbis::Header.  Finally I have settled on Ogg::Vorbis::Header::PurePerl, because the autoload for Ogg::Vorbis::Header was a pain to work with.

To write Ogg::Vorbis headers I use the program vorbiscomment.  It looks for this in the path, or in the option variable "vorbiscomment."  This tool
is available from L<http://www.xiph.org/> as part of the vorbis-tools distribution.

=head1 REQUIRED VALUES

No values are required (except filename, which is usually provided on object creation).

=head1 SET VALUES

=over 4

=item B<title, track, totaltracks, artist, album, comment, releasedate, genre, disc, label>

Uses standard tags for these

=item B<asin>

Uses custom tag "ASIN" for this

=item B<mb_artistid, mb_albumid, mb_trackid, mip_puid, countrycode, albumartist>

Uses MusicBrainz recommended tags for these.


=cut
use strict;
use Ogg::Vorbis::Header::PurePerl;

our %tagmap = (
	TITLE	=> 'title',
	TRACKNUMBER => 'track',
	TRACKTOTAL => 'totaltracks',
	ARTIST => 'artist',
	ALBUM => 'album',
	COMMENT => 'comment',
	DATE => 'releasedate',
	GENRE => 'genre',
	DISC => 'disc',
	LABEL => 'label',
	ASIN => 'asin',
    MUSICBRAINZ_ARTISTID => 'mb_artistid',
    MUSICBRAINZ_ALBUMID => 'mb_albumid',
    MUSICBRAINZ_TRACKID => 'mb_trackid',
    MUSICBRAINZ_SORTNAME => 'sortname',
    RELEASECOUNTRY => 'countrycode',
    MUSICIP_PUID => 'mip_puid',
    MUSICBRAINZ_ALBUMARTIST => 'albumartist'
);

sub default_options {
	{ vorbiscomment => "vorbiscomment" }
}

our @ISA = qw(Music::Tag::Generic);

sub ogg {
	my $self = shift;
	unless ((exists $self->{_OGG}) && (ref $self->{_OGG})) {
		if ($self->info->filename) {
			$self->{_OGG} = Ogg::Vorbis::Header::PurePerl->new($self->info->filename);
			$self->{_OGG}->load();

		}
		else {
			return undef;
		}
	}
	return $self->{_OGG};
}

sub get_tag {
    my $self     = shift;
    if ( $self->ogg ) {
		foreach ($self->ogg->comment_tags) {
			my $comment = uc($_);
			if (exists $tagmap{$comment}) {
				my $method = $tagmap{$comment};
				$self->info->$method($self->ogg->comment($comment));
			}
			else {
				$self->status("Unknown comment: $comment");
			}
		}
        $self->info->secs( $self->ogg->info->{"length"});
        $self->info->bitrate( $self->ogg->info->{"bitrate_nominal"});
        $self->info->frequency( $self->ogg->info->{"rate"});
	}
	else {
		print STDERR "No ogg object created\n";
	}
    return $self;
}


sub set_tag {
    my $self = shift;
	unless (open(COMMENT, "|-", $self->options->{vorbiscomment} ." -w ". "\"". $self->info->filename . "\"")) {
		$self->status("Failed to open ", $self->options->{vorbiscomment}, ".  Not writing tag.\n");
		return undef;
	}
	while (my ($t, $m) = each %tagmap) {
		if (defined $self->info->$m) {
			print COMMENT $t, "=", $self->info->$m, "\n";
		}
	}
	close (COMMENT);
    return $self;
}

sub close {
	my $self = shift;
	$self->{_OGG} = undef;
}

1;

=back

=head1 METHODS

=over 4

=item B<default_options>

Returns the default options for the plugin.  

=item B<set_tag>

Save info from object back to ogg vorbis file using L<vorbiscomment> 

=item B<get_tag>

Get info for object from ogg vorbis header using Ogg::Vorbis::Header::PurePerl

=item B<close>

Close the file and destroy the Ogg::Vorbis::Header::PurePerl object. 

=item B<ogg>

Returns the Ogg::Vorbis::Header::PurePerl object.

=back


=head1 OPTIONS

=over 4

=item B<vorbiscomment>

The full path to the vorbiscomment program.  Defaults to just "vorbiscomment", which assumes that vorbiscomment is in your path.

=back

=head1 BUGS

No known additional bugs provided by this Module

=head1 SEE ALSO

L<Ogg::Vorbis::Header::PurePerl>, L<Music::Tag>, L<Music::Tag::Amazon>, L<Music::Tag::File>, L<Music::Tag::FLAC>, L<Music::Tag::Lyrics>,
L<Music::Tag::M4A>, L<Music::Tag::MP3>, L<Music::Tag::MusicBrainz>, L<Music::Tag::Option>

=head1 AUTHOR 

Edward Allen III <ealleniii _at_ cpan _dot_ org>

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the Artistic License, distributed
with Perl.

=head1 COPYRIGHT

Copyright (c) 2007,2008 Edward Allen III. Some rights reserved.

=cut


# vim: tabstop=4
