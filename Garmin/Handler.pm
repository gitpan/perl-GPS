# Copyright (c) 1999-2000 João Pedro Gonçalves <joaop@sl.pt>.
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself. 
 
package GPS::Garmin::Handler;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use GPS::Garmin::Constant ':all';
use Math::Trig;


require Exporter;

@ISA = qw(Exporter AutoLoader);

@EXPORT_OK = ();

$VERSION = '0.11';

use POSIX qw(:termios_h);
use FileHandle;
use Carp;

$|++;

#Fail
sub Nak_byte { 
	shift->read_packet;
	GRMN_NAK 
}
 
# - Ack byte - the GPS ACKnowledged, read the packet and move next.
sub Ack_byte {
	shift->read_packet;
	GRMN_ACK
}

sub Product_data {
	my ($data) = shift->read_packet;
 	unpack("ssZ*",$data);	
}
 
sub Wpt_data {
    my $self = shift;
	$self->{records}--;
	my ($data) = $self->read_packet;
	my (@ident,@comm,$lt,$ln);

	#D103 Waypoint Datatype
	my $ident   = substr($data,0,6,'');
	my $comment = substr($data,12,40,'');
	($lt,$ln) =  unpack("ll",$data);
	$self->send_packet(GRMN_ACK);

	if($self->{records} == 0) { $self->get_reply; }
	return ($ident,
			$self->semicirc_deg($lt),
			$self->semicirc_deg($ln),
			$comment
		   );
}

sub Almanac_data {
    my $self = shift;
	$self->{records}--;
	my ($data) = $self->read_packet;
	my (@ident,@comm,$lt,$ln);

	#D501 Almanac Datatype
	my($wn,$toa,$af0,$af1,$e,$sqrta,$m0,$w,$omg0,$odot,$i,$htlh) = 
		unpack('sf10c',$data);

	$self->send_packet(GRMN_ACK);
	if($self->{records} == 0) { $self->get_reply; }
	return($wn,$toa,$af0,$af1,$e,$sqrta,$m0,$w,$omg0,$odot,$i,$htlh);
}

sub Trk_data {
    my $self = shift;
	$self->{records}--;
	my ($data) = $self->read_packet;
	my (@ident,@comm,$lt,$ln);

	#D301 Track Point Datatype
	my ($lat,$lon,$time,$is_first) = unpack('llLb',$data);	
    $lat = $self->semicirc_deg($lat);
    $lon = $self->semicirc_deg($lon);
    $time += GRMN_UTC_DIFF;

	$self->send_packet(GRMN_ACK);
	if($self->{records} == 0) { $self->get_reply; }
	return($lat,$lon,$time);
}

sub Xfer_cmplt {
	my $self = shift;
	delete $self->{records};
	delete $self->{cur_pid};
	delete $self->{cur_request};
	return(1);
}

#Position from the GPS
sub Position_data {
	my $self = shift;
	my ($lat,$lon,$ltcord,$lncord);
 
	my ($data) = $self->read_packet;
 

	$lat = substr($data,0,8);
	$lon = substr($data,8,8);
	

	$lat = rad2deg(unpack("d*",$lat));
 
	$lon = rad2deg(unpack("d*",$lon));
 
	$ltcord = "N";$ltcord = "S" if $lat < 0;
	$lncord = "E";$lncord = "W" if $lon < 0;
	$lat = abs($lat);$lon = abs($lon);
	$lat = int($lat)+($lat - int($lat))*60/100;
	$lon = int($lon)+($lon - int($lon))*60/100;
 
	$self->send_packet(GRMN_ACK);
	return($ltcord,$lat,$lncord,$lon);
 
}     


sub Date_time_data {
    my $self = shift;
    my(@date);
 
    my $data = $self->safe_read;
 
    for(my $i=0;$i < 8;$i++) {
        $data = $self->safe_read;
 
        if ($i == 2 || $i == 3) {
            $date[2] .= $data;next;
        }
 
        $date[$i] = ord $data;
        $date[$i] =~ s/(\d)/0$1/ if length($date[$i]) == 1;
    }
 
    $date[2] = unpack("s*",$date[2]);
    return ($date[7],$date[6],$date[4],$date[1],$date[0],$date[2],1);
}
 
sub Records {
 
	my ($self,$command) = @_;
	my ($numrec,$buf,$len);
 
	$buf = $self->safe_read;
 
	for (my $i=0;$i<2;$i++) {
		$self->usleep(5);
		$numrec .= $self->safe_read;
	}
 
	$buf = $self->_read(3);
	$numrec = unpack("S*",$numrec);
 
	$self->send_packet(GRMN_ACK);
	$self->{records} = $numrec;
	return $numrec;
} 

1;


__END__
# 

=head1 NAME

GPS::Garmin::Handler - Handlers to Garmin data

=head1 SYNOPSIS

  use GPS::Handler;


=head1 DESCRIPTION

	Used internally

=over

=head1 AUTHOR

Joao Pedro B Gonçalves , joaop@sl.pt

=head1 SEE ALSO

Peter Bennett's GPS www and ftp directory:'

        ftp://sundae.triumf.ca/pub/peter/index.html.
        http://vancouver-webpages.com/peter/idx_garmin.html

Official Garmin Communication Protocol Reference

        http://www.garmin.com/support/protocol.html

=cut
