use GPS::Garmin;
use GPS::Garmin::Constant ':all';

#This is a small test script for uploads, it allows you to upload
#the portuguese borders into a Garmin device
#This is very experimental, it's here mainly for development

$g= new GPS::Garmin(verbose=>0);

open(BRDR,"./Borders.log");

my $i;
my $t = time - 1900000;
my $first = 1;
while(<BRDR>) {
	chomp;
	my($lat,$lon) = split(',');
	$t += 250;
	push (@test,pack("llLb",$g->deg_semicirc($lat),$g->deg_semicirc($lon),($t+GRMN_UTC_DIFF),$first));
	$first = 0;
}
print "TEST: ", scalar @test;
$g->upload_data(GRMN_TRK_DATA,\@test);
