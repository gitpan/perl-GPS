use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$AUTHOR       = 'Joao Pedro Goncalves <joaop@co.sapo.pt>';

WriteMakefile(
    'NAME'	=> "GPS::Garmin",
    'DISTNAME'  => "perl-GPS",
    'VERSION'   => '0.14',
    'PREREQ_PM' => {
	$^O eq 'MSWin32' ?
		('Win32::SerialPort' => 0.07) :
		('Device::SerialPort' => 0.07) # This is only a "COREQ"
	},
    'PMLIBDIRS' => [qw(Garmin NMEA)],
    'AUTHOR'    => $AUTHOR,
    'NO_META'   => 1,
);

sub MY::postamble {
    <<'EOF';
release: sf-release cpan-release

sf-release:
	[ -e $(DISTVNAME).tar$(SUFFIX) ]
	sf-upload -pr perl-gps -p perl-gps -f $(DISTVNAME).tar$(SUFFIX)

cpan-release:
	[ -e $(DISTVNAME).tar$(SUFFIX) ]
	cpan-upload $(DISTVNAME).tar$(SUFFIX)

EOF
}
