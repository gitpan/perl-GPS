# Copyright (c) 1999-2000 João Pedro Gonçalves <joaop@sl.pt>.
#All rights reserved. This program is free software;
#you can redistribute it and/or modify it under the same terms as Perl itself.

package GPS::Garmin::Constant;
 
require Exporter;
@ISA = ("Exporter");

@EXPORT_OK = ( grep /^GRMN_/, keys %{'GPS::Garmin::Constant::'} );
%EXPORT_TAGS = ( 

	'all' => \@EXPORT_OK,

	'pids' => [qw[
			GRMN_ACK_BYTE 	    GRMN_COMMAND_DATA 
			GRMN_ETX_BYTE
			GRMN_XFER_CMPLT 	GRMN_DATE_TIME_DATA 
			GRMN_DLE_BYTE		GRMN_POSITION_DATA 
			GRMN_PRX_WPT_DATA 	GRMN_NAK_BYTE
			GRMN_RECORDS 		GRMN_RTE_HDR 
			GRMN_RTE_WPT_DATA 	GRMN_ALMANAC_DATA 
			GRMN_TRK_DATA 		GRMN_WPT_DATA 
			GRMN_PVT_DATA 		GRMN_PROTOCOL_ARRAY 
			GRMN_PRODUCT_RQST 	GRMN_PRODUCT_DATA]],

	'commands' => [qw[
			GRMN_ABORT_TRANSFER GRMN_TRANSFER_ALM 
			GRMN_TRANSFER_POSN  GRMN_TRANSFER_PRX 
			GRMN_TRANSFER_RTE   GRMN_TRANSFER_TIME 
			GRMN_TRANSFER_TRK   GRMN_TRANSFER_WPT 
			GRMN_TURN_OFF_PWR   GRMN_START_PVT_DATA 
			GRMN_STOP_PVT_DATA
			]],

	'templates' => [qw[
			GRMN_HEADER			GRMN_FOOTER
			GRMN_UTC_DIFF
			]]
);

##
## The constants
##

#PID Types 
sub GRMN_NUL			() { 0x00 } 
sub GRMN_ETX			() { 0x03 }
sub GRMN_ETX_BYTE		() { 0x03 }
sub GRMN_ACK			() { 0x06 } 
sub GRMN_ACK_BYTE		() { 0x06 } 
sub GRMN_COMMAND_DATA	() { 0x0A }
sub GRMN_XFER_CMPLT		() { 0x0C }
sub GRMN_DATE_TIME_DATA	() { 0x0E }
sub GRMN_ESC			() { 0x0E }
sub GRMN_DLE			() { 0x10 }
sub GRMN_DLE_BYTE		() { 0x10 }
sub GRMN_POSITION_DATA	() { 0x11 }
sub GRMN_PRX_WPT_DATA	() { 0x13 }
sub GRMN_NAK			() { 0x15 }
sub GRMN_NAK_BYTE		() { 0x15 }
sub GRMN_RECORDS		() { 0x1B }
sub GRMN_RTE_HDR		() { 0x1D }
sub GRMN_RTE_WPT_DATA	() { 0x1E }
sub GRMN_ALMANAC_DATA	() { 0x1F }
sub GRMN_TRK_DATA		() { 0x22 }
sub GRMN_WPT_DATA		() { 0x23 }
sub GRMN_PVT_DATA		() { 0x33 }
sub GRMN_PROTOCOL_ARRAY	() { 0xFD }
sub GRMN_PRODUCT_RQST	() { 0xFE }
sub GRMN_PRODUCT_DATA	() { 0xFF }

#Command ID's
sub GRMN_ABORT_TRANSFER	() { 0x00 }
sub GRMN_TRANSFER_ALM	() { 0x01 }
sub GRMN_TRANSFER_POSN	() { 0x02 }
sub GRMN_TRANSFER_PRX	() { 0x03 }
sub GRMN_TRANSFER_RTE	() { 0x04 }
sub GRMN_TRANSFER_TIME	() { 0x05 }
sub GRMN_TRANSFER_TRK	() { 0x06 }
sub GRMN_TRANSFER_WPT	() { 0x07 }
sub GRMN_TURN_OFF_PWR	() { 0x08 }
sub GRMN_START_PVT_DATA	() { 0x31 } #Only works in GPS III
sub GRMN_STOP_PVT_DATA	() { 0x50 } #

#Templates

sub GRMN_HEADER 		() { pack "C1",GRMN_DLE }
sub GRMN_FOOTER 		() { pack "C2",GRMN_DLE,GRMN_ETX };
sub GRMN_PACKET_FILL	() { 0x01 }

#Constant vars
sub GRMN_UTC_DIFF 		() { 631065600 }; #UTC to Unix time epoch

1;
__END__
