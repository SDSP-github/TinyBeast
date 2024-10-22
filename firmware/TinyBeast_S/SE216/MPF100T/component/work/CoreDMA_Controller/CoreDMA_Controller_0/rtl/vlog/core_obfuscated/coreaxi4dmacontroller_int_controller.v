// Microsemi Corporation Proprietary and Confidential
// Copyright 2017 Microsemi Corporation.  All rights reserved.
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
// SVN Revision Information:
// SVN $Revision: 28772 $
// SVN $Date: 2017-02-09 20:06:50 +0000 (Thu, 09 Feb 2017) $
module
CAXI4DMAIO0OI
(
CAXI4DMAI
,
CAXI4DMAl
,
CAXI4DMAll1l
,
CAXI4DMAO01l
,
CAXI4DMAI01l
,
CAXI4DMAl01l
,
CAXI4DMAO11l
,
valid
,
CAXI4DMAlIlOI
,
CAXI4DMAOllOI
,
CAXI4DMAIllOI
,
CAXI4DMAOI0OI
,
intDscrptrNum
,
CAXI4DMAII0OI
,
CAXI4DMAlI0OI
,
strDscrptr
,
CAXI4DMAOIO0
,
CAXI4DMAIIO0
,
waitDscrptr
,
waitStrDscrptr
,
CAXI4DMAOl0OI
,
CAXI4DMAIl0OI
,
CAXI4DMAll0OI
,
CAXI4DMAO00OI
)
;
parameter
NUM_INT_BDS
=
4
;
parameter
CAXI4DMAOIO1
=
2
;
parameter
INT_0_QUEUE_DEPTH
=
0
;
parameter
INT_1_QUEUE_DEPTH
=
0
;
parameter
INT_2_QUEUE_DEPTH
=
0
;
parameter
INT_3_QUEUE_DEPTH
=
0
;
`include "../../../coreaxi4dmacontroller_interrupt_parameters.v"
input
CAXI4DMAI
;
input
CAXI4DMAl
;
input
CAXI4DMAll1l
;
input
CAXI4DMAO01l
;
input
[
10
:
0
]
CAXI4DMAI01l
;
input
[
31
:
0
]
CAXI4DMAl01l
;
input
[
3
:
0
]
CAXI4DMAO11l
;
input
valid
;
input
CAXI4DMAlIlOI
;
input
CAXI4DMAOllOI
;
input
CAXI4DMAIllOI
;
input
CAXI4DMAOI0OI
;
input
[
CAXI4DMAOIO1
-
1
:
0
]
intDscrptrNum
;
input
CAXI4DMAII0OI
;
input
[
31
:
0
]
CAXI4DMAlI0OI
;
input
strDscrptr
;
output
[
31
:
0
]
CAXI4DMAOIO0
;
output
CAXI4DMAIIO0
;
output
[
NUM_INT_BDS
-
1
:
0
]
waitDscrptr
;
output
waitStrDscrptr
;
output
CAXI4DMAOl0OI
;
output
CAXI4DMAIl0OI
;
output
CAXI4DMAll0OI
;
output
CAXI4DMAO00OI
;
wire
[
31
:
0
]
CAXI4DMAl1Oll
;
wire
fifoFullQueue0
;
wire
[
31
:
0
]
CAXI4DMAOOIll
;
wire
fifoFullQueue1
;
wire
[
31
:
0
]
CAXI4DMAIOIll
;
wire
fifoFullQueue2
;
wire
[
31
:
0
]
CAXI4DMAlOIll
;
wire
fifoFullQueue3
;
wire
[
4
:
0
]
CAXI4DMAOIIll
;
`include "../../../coreaxi4dmacontroller_interrupt_mapping.v"
wire
[
3
:
0
]
CAXI4DMAIIIll
;
wire
[
3
:
0
]
CAXI4DMAlIIll
;
assign
CAXI4DMAIIO0
=
1
'b
1
;
assign
CAXI4DMAIIIll
[
3
:
0
]
=
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
01
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
4
'b
0001
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
02
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
4
'b
0010
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
03
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
4
'b
0100
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
04
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
4
'b
1000
:
4
'b
0000
;
assign
CAXI4DMAlIIll
[
3
:
0
]
=
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
01
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
&&
(
CAXI4DMAO01l
==
1
'b
1
)
)
?
4
'b
0001
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
02
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
&&
(
CAXI4DMAO01l
==
1
'b
1
)
)
?
4
'b
0010
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
03
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
&&
(
CAXI4DMAO01l
==
1
'b
1
)
)
?
4
'b
0100
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
04
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
&&
(
CAXI4DMAO01l
==
1
'b
1
)
)
?
4
'b
1000
:
4
'b
0000
;
assign
CAXI4DMAOIO0
[
31
:
0
]
=
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
01
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
CAXI4DMAl1Oll
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
02
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
CAXI4DMAOOIll
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
03
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
CAXI4DMAIOIll
:
(
(
CAXI4DMAI01l
[
10
:
4
]
==
7
'h
04
)
&&
(
CAXI4DMAll1l
==
1
'b
1
)
)
?
CAXI4DMAlOIll
:
32
'd
0
;
assign
CAXI4DMAOIIll
=
{
{
(
5
-
CAXI4DMAOIO1
)
{
1
'b
0
}
}
,
intDscrptrNum
}
;
generate
if
(
NUM_INT_0_BDS
>=
1
)
begin
CAXI4DMAOlIll
#
(
.CAXI4DMAIlIll
(
INT_0_QUEUE_DEPTH
)
)
CAXI4DMAllIll
(
.CAXI4DMAI
(
CAXI4DMAI
)
,
.CAXI4DMAl
(
CAXI4DMAl
)
,
.CAXI4DMAll1l
(
CAXI4DMAIIIll
[
0
]
)
,
.CAXI4DMAO01l
(
CAXI4DMAlIIll
[
0
]
)
,
.CAXI4DMAI01l
(
CAXI4DMAI01l
[
3
:
2
]
)
,
.CAXI4DMAl01l
(
CAXI4DMAl01l
)
,
.CAXI4DMAO11l
(
CAXI4DMAO11l
[
0
]
)
,
.valid
(
intValidQueue0
)
,
.CAXI4DMAlIlOI
(
CAXI4DMAlIlOI
)
,
.CAXI4DMAOllOI
(
CAXI4DMAOllOI
)
,
.CAXI4DMAIllOI
(
CAXI4DMAIllOI
)
,
.CAXI4DMAOI0OI
(
CAXI4DMAOI0OI
)
,
.intDscrptrNum
(
CAXI4DMAOIIll
)
,
.CAXI4DMAII0OI
(
CAXI4DMAII0OI
)
,
.CAXI4DMAlI0OI
(
CAXI4DMAlI0OI
)
,
.strDscrptr
(
strDscrptr
)
,
.CAXI4DMAOIO0
(
CAXI4DMAl1Oll
)
,
.CAXI4DMAO0Ill
(
fifoFullQueue0
)
,
.CAXI4DMAI0Ill
(
CAXI4DMAOl0OI
)
)
;
end
endgenerate
generate
if
(
NUM_INT_1_BDS
>=
1
)
begin
CAXI4DMAOlIll
#
(
.CAXI4DMAIlIll
(
INT_1_QUEUE_DEPTH
)
)
CAXI4DMAl0Ill
(
.CAXI4DMAI
(
CAXI4DMAI
)
,
.CAXI4DMAl
(
CAXI4DMAl
)
,
.CAXI4DMAll1l
(
CAXI4DMAIIIll
[
1
]
)
,
.CAXI4DMAO01l
(
CAXI4DMAlIIll
[
1
]
)
,
.CAXI4DMAI01l
(
CAXI4DMAI01l
[
3
:
2
]
)
,
.CAXI4DMAl01l
(
CAXI4DMAl01l
)
,
.CAXI4DMAO11l
(
CAXI4DMAO11l
[
0
]
)
,
.valid
(
intValidQueue1
)
,
.CAXI4DMAlIlOI
(
CAXI4DMAlIlOI
)
,
.CAXI4DMAOllOI
(
CAXI4DMAOllOI
)
,
.CAXI4DMAIllOI
(
CAXI4DMAIllOI
)
,
.CAXI4DMAOI0OI
(
CAXI4DMAOI0OI
)
,
.intDscrptrNum
(
CAXI4DMAOIIll
)
,
.CAXI4DMAII0OI
(
CAXI4DMAII0OI
)
,
.CAXI4DMAlI0OI
(
CAXI4DMAlI0OI
)
,
.strDscrptr
(
strDscrptr
)
,
.CAXI4DMAOIO0
(
CAXI4DMAOOIll
)
,
.CAXI4DMAO0Ill
(
fifoFullQueue1
)
,
.CAXI4DMAI0Ill
(
CAXI4DMAIl0OI
)
)
;
end
endgenerate
generate
if
(
NUM_INT_2_BDS
>=
1
)
begin
CAXI4DMAOlIll
#
(
.CAXI4DMAIlIll
(
INT_2_QUEUE_DEPTH
)
)
CAXI4DMAO1Ill
(
.CAXI4DMAI
(
CAXI4DMAI
)
,
.CAXI4DMAl
(
CAXI4DMAl
)
,
.CAXI4DMAll1l
(
CAXI4DMAIIIll
[
2
]
)
,
.CAXI4DMAO01l
(
CAXI4DMAlIIll
[
2
]
)
,
.CAXI4DMAI01l
(
CAXI4DMAI01l
[
3
:
2
]
)
,
.CAXI4DMAl01l
(
CAXI4DMAl01l
)
,
.CAXI4DMAO11l
(
CAXI4DMAO11l
[
0
]
)
,
.valid
(
intValidQueue2
)
,
.CAXI4DMAlIlOI
(
CAXI4DMAlIlOI
)
,
.CAXI4DMAOllOI
(
CAXI4DMAOllOI
)
,
.CAXI4DMAIllOI
(
CAXI4DMAIllOI
)
,
.CAXI4DMAOI0OI
(
CAXI4DMAOI0OI
)
,
.intDscrptrNum
(
CAXI4DMAOIIll
)
,
.CAXI4DMAII0OI
(
CAXI4DMAII0OI
)
,
.CAXI4DMAlI0OI
(
CAXI4DMAlI0OI
)
,
.strDscrptr
(
strDscrptr
)
,
.CAXI4DMAOIO0
(
CAXI4DMAIOIll
)
,
.CAXI4DMAO0Ill
(
fifoFullQueue2
)
,
.CAXI4DMAI0Ill
(
CAXI4DMAll0OI
)
)
;
end
endgenerate
generate
if
(
NUM_INT_3_BDS
>=
1
)
begin
CAXI4DMAOlIll
#
(
.CAXI4DMAIlIll
(
INT_3_QUEUE_DEPTH
)
)
CAXI4DMAI1Ill
(
.CAXI4DMAI
(
CAXI4DMAI
)
,
.CAXI4DMAl
(
CAXI4DMAl
)
,
.CAXI4DMAll1l
(
CAXI4DMAIIIll
[
3
]
)
,
.CAXI4DMAO01l
(
CAXI4DMAlIIll
[
3
]
)
,
.CAXI4DMAI01l
(
CAXI4DMAI01l
[
3
:
2
]
)
,
.CAXI4DMAl01l
(
CAXI4DMAl01l
)
,
.CAXI4DMAO11l
(
CAXI4DMAO11l
[
0
]
)
,
.valid
(
intValidQueue3
)
,
.CAXI4DMAlIlOI
(
CAXI4DMAlIlOI
)
,
.CAXI4DMAOllOI
(
CAXI4DMAOllOI
)
,
.CAXI4DMAIllOI
(
CAXI4DMAIllOI
)
,
.CAXI4DMAOI0OI
(
CAXI4DMAOI0OI
)
,
.intDscrptrNum
(
CAXI4DMAOIIll
)
,
.CAXI4DMAII0OI
(
CAXI4DMAII0OI
)
,
.CAXI4DMAlI0OI
(
CAXI4DMAlI0OI
)
,
.strDscrptr
(
strDscrptr
)
,
.CAXI4DMAOIO0
(
CAXI4DMAlOIll
)
,
.CAXI4DMAO0Ill
(
fifoFullQueue3
)
,
.CAXI4DMAI0Ill
(
CAXI4DMAO00OI
)
)
;
end
endgenerate
endmodule
