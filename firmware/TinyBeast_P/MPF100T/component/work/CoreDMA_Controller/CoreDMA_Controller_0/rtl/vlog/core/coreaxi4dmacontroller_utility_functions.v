// ****************************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: 
//
// SVN Revision Information:
// SVN $Revision: 28772 $
// SVN $Date: 2017-02-10 01:36:50 +0530 (Fri, 10 Feb 2017) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/

////////////////////////////////////////////////////////////////////////////////
// clog2 function implementation. Returns the number of bits required to
// hold the value passed as argument.
////////////////////////////////////////////////////////////////////////////////
function integer clog2;
    input integer x;
    integer x1, tmp, res;
    begin
        tmp = 1;
        res = 0;
        x1 = x + 1;
        while (tmp < x1)
            begin 
                tmp = tmp * 2;
                res = res + 1;
            end
        clog2 = res;
    end
endfunction