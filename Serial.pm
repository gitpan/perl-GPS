# Copyright (c) 1999-2000 João Pedro Gonçalves <joaop@sl.pt>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package GPS::Serial;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $OS_win $has_serialport);
use Carp;

require Exporter;

@ISA = qw(Exporter AutoLoader);

@EXPORT_OK = qw( 
        
);
$VERSION = '0.12';

use POSIX qw(:termios_h);
use FileHandle;
use Carp;

BEGIN {
	#Taken from SerialPort/eg/any_os.plx

	#We try to use Device::SerialPort or 
	#Win32::SerialPort, if it's not windows
	#and there's no Device::SerialPort installed,
	#then we just use the FileHandle module that
	#comes with perl

	$OS_win = ($^O eq "MSWin32") ? 1 : 0;
 
	if ($OS_win) {
		eval "use Win32::SerialPort";
		croak "Must have Win32::SerialPort correctly installed: $@\n" if ($@);
		$has_serialport++;
	} else {
		eval "use Device::SerialPort";
		$has_serialport++ unless $@;
	}
}	# End BEGIN                                                                                                                                        

$|++;

sub _read { 
	#$self->_read(length)
	#sysread wrapper for the serial device
	#length defaults to 1

	my ($self,$len) = @_;
	$len ||=1;

	ref($self->serial) or carp "Read from an uninitialized handle";

	my $buf;
        
	if($self->{serialtype} eq 'FileHandle') {   
		sysread($self->serial,$buf,$len);
	} else {
		(undef, $buf) = $self->serial->read($len);
	}

	if($self->{verbose} && $buf) {
		print "R:(",join(" ", map {$self->Pid_Byte($_)}unpack("C*",$buf)),")\n";
	}

	return $buf;
}

sub safe_read {
    #Reads one byte, escapes DLE bytes
    my $self = shift;
    my $buf = $self->_read;
    $buf eq "\x10" ? $self->_read : $buf;
}                                                                                                                                             

sub _write { 
	#$self->_write(buffer,length)
	#syswrite wrapper for the serial device
	#length defaults to buffer length

	my ($self,$buf,$len,$offset) = @_;
	$self->connect() or croak "Device not ready: $!";

	$len ||= length($buf);

	if($self->{verbose}) {
		print "W:(",join(" ", map {$self->Pid_Byte($_)}unpack("C*",$buf)),")\n";
	}

    ref($self->serial) or croak "Write to an uninitialized handle";

	if($self->{serialtype} eq 'FileHandle') {
		syswrite($self->serial,$buf,$len,$offset);
	} else {
		my $out_len = $self->serial->write($buf);
		carp "Write incomplete ($len != $out_len)\n" if  ( $len != $out_len ); 
	}
}

sub connect {
	my $self = shift;
	return $self->serial if ref($self->serial);

	if($OS_win) {
		$self->{serial} = $self->serialport_connect;
	} else {
		$self->{serial} = $has_serialport ? $self->serialport_connect : $self->unix_connect;
	}
}

sub serialport_connect {
        my $self= shift;
        my $PortObj;
        
        my $PortObj = ( ($^O eq 'MSWin32') ? 
                                (new Win32::SerialPort ($self->{port})) :
                                (new Device::SerialPort ($self->{port})) )
                                        || die "Can't open $$self{port}: $!\n";     

	$PortObj->baudrate($self->{baud});
    $PortObj->parity("none");
    $PortObj->databits(8);
    $PortObj->stopbits(1);      
	$PortObj->read_interval(5) if $^O eq 'MSWin32';
	$PortObj->write_settings;
	$self->{serialtype} = 'SerialPort';
	$PortObj;
}

sub unix_connect { 
        #This was adapted from a script on connecting to a sony DSS, credits to its author (lost his email)
        my $self = shift;
        my $port = $self->{'port'};
        my $baud = $self->{'baud'};
        my($termios,$cflag,$lflag,$iflag,$oflag,$voice);
  
        my $serial = new FileHandle("+>$port") || die "Could not open $port: $!\n";

        $termios = POSIX::Termios->new();
        $termios->getattr($serial->fileno()) || die "getattr: $!\n";
        $cflag = 0 | CS8 | CREAD |CLOCAL;
        $lflag= 0;
        $iflag= 0 | IGNBRK |IGNPAR;
        $oflag=  0;
  
        $termios->setcflag($cflag);
        $termios->setlflag($lflag);
        $termios->setiflag($iflag);
        $termios->setoflag($oflag);
        $termios->setattr($serial->fileno(),TCSANOW) || die "setattr: $!\n";
        eval qq[
                  \$termios->setospeed(POSIX::B$baud) || die "setospeed: \$!\n";
                  \$termios->setispeed(POSIX::B$baud) || die "setispeed: \$!\n";
        ];
  
        die $@ if $@;
  
        $termios->setattr($serial->fileno(),TCSANOW) || die "setattr: $!\n";
  
        $termios->getattr($serial->fileno()) || die "getattr: $!\n";        
        for (0..NCCS) {     
                if ($_ == NCCS) { last; }
                if ($_ == VSTART || $_ == VSTOP) { next; }
                $termios->setcc($_,0);  
        }
        $termios->setattr($serial->fileno(),TCSANOW) || die "setattr: $!\n";

        $self->{serialtype} = 'FileHandle';
        $serial;
}
1;


__END__
# 

=head1 NAME

GPS::Serial - Access to the Serial port for the GPS::* modules

=head1 SYNOPSIS

  use GPS::Serial;


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
