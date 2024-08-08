// ****************************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2015 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: 
//
// SVN Revision Information:
// SVN $Revision: 34698 $
// SVN $Date: 2019-10-29 19:08:55 +0530 (Tue, 29 Oct 2019) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//       SAR108962 - Added support for 32-bit AXI interface
//
// ****************************************************************************/
module COREAXITOAHBL_WSTRBPopCntr (
    WSTRBIn,
    noValidBytes
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI_DWIDTH = 64;    // Sets the AXI data width - 32/64.
parameter AXI_STRBWIDTH = 8;  // Sets the AXI strobe width depending on AXI data width.

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
input   [AXI_STRBWIDTH-1:0] WSTRBIn;
output  [3:0]           noValidBytes;

reg     [3:0]           noValidBytes;

////////////////////////////////////////////////////////////////////////////////
// ROM Table - Returns the population count of WSTRB
////////////////////////////////////////////////////////////////////////////////
always @ (*)
begin
    if(AXI_DWIDTH == 64)
        case (WSTRBIn) // 256*4 ROM table
            8'b10000000,8'b01000000,8'b00100000,8'b00010000,8'b00001000,8'b00000100,8'b00000010,8'b00000001 : noValidBytes <= 4'd1;
            8'b11000000,8'b01100000,8'b00110000,8'b00011000,8'b00001100,8'b00000110,8'b00000011             : noValidBytes <= 4'd2;
            8'b11100000,8'b01110000,8'b00111000,8'b00011100,8'b00001110,8'b00000111                         : noValidBytes <= 4'd3;
            8'b11110000,8'b01111000,8'b00111100,8'b00011110,8'b00001111                                     : noValidBytes <= 4'd4;
            8'b11111000,8'b01111100,8'b00111110,8'b00011111                                                 : noValidBytes <= 4'd5;
            8'b11111100,8'b01111110,8'b00111111                                                             : noValidBytes <= 4'd6;
            8'b11111110,8'b01111111                                                                         : noValidBytes <= 4'd7;
            8'b11111111                                                                                     : noValidBytes <= 4'd8;
            default                                                                                         : noValidBytes <= 4'd0;
        endcase
    else if(AXI_DWIDTH == 32) // SAR108962
        case (WSTRBIn) // 16*4 ROM table
            4'b1000,4'b0100,4'b0010,4'b0001 : noValidBytes <= 4'd1;
            4'b1100,4'b0110,4'b0011         : noValidBytes <= 4'd2;
            4'b1110,4'b0111                 : noValidBytes <= 4'd3;
            4'b1111                         : noValidBytes <= 4'd4;
            default                         : noValidBytes <= 4'd0;
        endcase
end

endmodule // COREAXITOAHBL_WSTRBPopCntr
