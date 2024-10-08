/*++
    Copyright (c) Microsoft Corporation.  All rights reserved.

    THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
    KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
    PURPOSE.

Module Name:

    Public.h

Abstract:

    This module contains the common declarations shared by driver
    and user applications.

Environment:

    user and kernel

--*/
  

#include <winioctl.h>
#include <initguid.h>



// {CFBC8BC3-500E-4A6A-84FE-2690F17DD9EF}
DEFINE_GUID(GUID_MPCI_INTERFACE, 
0xcfbc8bc3, 0x500e, 0x4a6a, 0x84, 0xfe, 0x26, 0x90, 0xf1, 0x7d, 0xd9, 0xef);


//
// Device type           -- in the "User Defined" range."
//
#define MICRO_PCI_TYPE 50001
//
// The IOCTL function codes from 0x800 to 0xFFF are for customer use.
//
#define IOCTL_PCI_CONFIG_SPACE_ALL_READ \
    CTL_CODE( MICRO_PCI_TYPE, 0x900, METHOD_BUFFERED, FILE_ANY_ACCESS  )

#define IOCTL_PCI_LED_CONTROL \
    CTL_CODE( MICRO_PCI_TYPE, 0x901, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_INTERRUPT_CONTROL \
    CTL_CODE( MICRO_PCI_TYPE, 0x902, METHOD_BUFFERED, FILE_ANY_ACCESS  )

#define IOCTL_DEVICE_INFO \
    CTL_CODE( MICRO_PCI_TYPE, 0x903, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SRAM_WRITE \
    CTL_CODE( MICRO_PCI_TYPE, 0x904, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SRAM_READ \
    CTL_CODE( MICRO_PCI_TYPE, 0x905, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DIP_SWITCH \
	CTL_CODE( MICRO_PCI_TYPE, 0x906, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_CONFIG_SPACE_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x907, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_ISR_COUNT \
	CTL_CODE( MICRO_PCI_TYPE, 0x908, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_CONFIG_READ_OFFSET \
	CTL_CODE( MICRO_PCI_TYPE, 0x909, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x90A, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x90B, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x90C, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x90D, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_WRITE_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x90E, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR0_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x90F, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR0_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x910, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR1_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x911, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR1_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x912, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_OPERAION \
	CTL_CODE( MICRO_PCI_TYPE, 0x913, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_WOFFSET \
	CTL_CODE( MICRO_PCI_TYPE, 0x914, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_CONFIGURATION \
	CTL_CODE( MICRO_PCI_TYPE, 0x915, METHOD_BUFFERED , FILE_ANY_ACCESS  )	


#define IOCTL_DMA_WRITE_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x916, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_ROFFSET \
	CTL_CODE( MICRO_PCI_TYPE, 0x917, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_TYPE \
	CTL_CODE( MICRO_PCI_TYPE, 0x918, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x919, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x920, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_SG_DMA_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x921, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_SG_DMA_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x922, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_DMA_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x923, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_DMA_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x924, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_FDMA_WRITE \
	CTL_CODE( MICRO_PCI_TYPE, 0x925, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_FDMA_READ \
	CTL_CODE( MICRO_PCI_TYPE, 0x926, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_INFO \
	CTL_CODE( MICRO_PCI_TYPE, 0x927, METHOD_BUFFERED , FILE_ANY_ACCESS  )
	
#define IOCTL_ISR_COUNT_ALL \
	CTL_CODE( MICRO_PCI_TYPE, 0x928, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BD_COUNT \
	CTL_CODE( MICRO_PCI_TYPE, 0x929, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_DMA_CONFIG \
	CTL_CODE( MICRO_PCI_TYPE, 0x930, METHOD_BUFFERED , FILE_ANY_ACCESS  )


#define PCI_TYPE0_ADDRESSES             6


/** Structure used in IOCTL to get PCIe state from driver */
typedef struct {

  USHORT  VendorID;
  USHORT  DeviceID;
  USHORT  Command;
  USHORT  Status;
  UCHAR   RevisionID;
  UCHAR  ProgIf;
  UCHAR  SubClass;
  UCHAR  BaseClass;
  UCHAR  CacheLineSize;
  UCHAR  LatencyTimer;
  UCHAR  HeaderType;
  UCHAR  BIST;

     union
   {
	   struct _PCI_HEADER_TYPE_0 {
      ULONG  BaseAddresses[PCI_TYPE0_ADDRESSES];
      ULONG  CIS;
      USHORT  SubVendorID;
      USHORT  SubSystemID;
      ULONG  ROMBaseAddress;
      UCHAR  CapabilitiesPtr;
      UCHAR  Reserved1[3];
      ULONG  Reserved2;
      UCHAR  InterruptLine;
      UCHAR  InterruptPin;
      UCHAR  MinimumGrant;
      UCHAR  MaximumLatency;
    } type0;
}u;


	 struct _PCI_MSI_MESSAGE_CONTROL {
    USHORT  MSIEnable:1;
    USHORT  MultipleMessageCapable:3;
    USHORT  MultipleMessageEnable:3;
    USHORT  CapableOf64Bits:1;
    USHORT  PerVectorMaskCapable:1;
    USHORT  Reserved:7;
  } MessageControl;

	struct {
	USHORT  MessageData;
	} Option32Bit;
	struct {
	ULONG  MessageAddressUpper;
	USHORT  MessageData;
	USHORT  Reserved;
	ULONG  MaskBits;
	ULONG  PendingBits;
	} Option64Bit;
	
	ULONG Link_cap_register;
	USHORT Link_control_register;
	USHORT Link_status_register;
	ULONG Device_cap_register;
	USHORT Device_control_register;
	USHORT Device_status_register;

} PCIState;

typedef struct
{
	USHORT DeviceID;
	USHORT VendorID;
	ULONG isr_count;
}mydevice;





typedef struct
{
	ULONG data;
	ULONG lenth;
	ULONG offset;
}dma_write_read;

struct device_info 
{
	const char* device_status;
	const char* device_type;
	const char* driver_version;
	const char* driver_timestamp;
	const char* demo_type;
	const char* support_width;
	const char* n_width;
	const char* support_speed;
	const char* n_speed;
	int device_type_id;
	int demo_type_id;
	int num_bar;
	int bar0_add;
	int bar0_size;
	int bar1_add;
	int bar1_size;
	int bar2_add;
	int bar2_size;
	int bar3_add;
	int bar3_size;
	int bar4_add;
	int bar4_size;
	int bar5_add;
	int bar5_size;
	int bar6_add;
	int bar6_size;
};
struct devinfo
{
	//int link_info;
	char *dev;
	char *hi;
	int x;
	
};

struct devinfo1
{
	int x;
	int y;
	int link_info;
};

typedef struct
{
	
	ULONG bar0_addr;
	ULONG bar0_size;
	ULONG bar1_addr;
	ULONG bar1_size;
	ULONG bar2_addr;
	ULONG bar2_size;
	ULONG bar3_addr;
	ULONG bar3_size;
	ULONG bar4_addr;
	ULONG bar4_size;
	ULONG bar5_addr;
	ULONG bar5_size;
} bar_info;

struct isr_count
{
	ULONG isr1;
	ULONG isr2;
	ULONG isr3;
	ULONG isr4;


};

enum {
	BAR_DEFAULT = 1,
	BAR_DDR3,
	BAR_LSRAM,
	BAR_WRITE,
	BAR_READ,
	BAR_DDR4
};
enum {
	DMA_BUF_INC = 1,
	DMA_BUF_DEC,
	DMA_BUF_RAND,
	DMA_BUF_ZEROS,
	DMA_BUF_ONES,
	DMA_BUF_AAA,
	DMA_BUF_555
};
typedef struct{
	unsigned int       Dma_Srcaddr32;
	unsigned int       Dma_Srcaddr64;
	unsigned int       Dma_Destaddr32;
	unsigned int       Dma_Destaddr64;
	unsigned int       Dma_length;
	unsigned int       Dma_Status;
}G5_DmaRegisters;
