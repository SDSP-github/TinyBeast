/*++

Copyright (c) microsemi Corporation

Module Name:

	mpci_class.h

Abstract:

	This module defines the mpci class and the
	values neccessary for Window operation and IOCTL control.
	and provide interface between Driver and GUI.


Environment:

	User Mode Win2k or Later

--*/

#pragma once

#include <windows.h>
#include <setupapi.h>

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "public.h"




//#define SPIN_COUNT_FOR_CS       0x4000

//#define DEFAULT_READ_BUFFER_SIZE 8
//#define DEFAULT_WRITE_BUFFER_SIZE 8
//
//#define DEFAULT_THREAD_COUNT 2
//
//
//#define LED_CONTROL 1
//
//#define SRAM_WRITE 2
//#define SRAM_READ 3
//#define DIP_SWITCH 4
//
//#define OFF 1
//#define ON 0

constexpr ULONG PFBASE_IO_CTRL = 0x10000000;
constexpr ULONG PFBASE_MEMTEST_LSRAM = 0x30000000;
constexpr ULONG PFBASE_MEMTEST_DDR4 = 0x40000000;
// Address Offset Register for BAR2
constexpr ULONG PFREG_BASEADDR = (0x8648 >> 2);



//#define PCI_TYPE0_ADDRESSES   6

//#define BAR0                  0
//#define BAR1                  1
#define BAR2				  2

//#define SG_DMA_WRITE_STATUS   0x3F04
//#define SG_DMA_READ_STATUS    0x3F08

//#define HP_DMA_CLK_CYCLES     0x2005
//#define HP_DMA_STATUS         0x2006

//#define FB_DMA_WRITE_STATUS   0x2040
//#define FB_DMA_READ_STATUS    0x2042

//#define FDMA_FREQ			  0x200E

//-----------------------------------------------------------------------------   
// Device LED and GPIO Off sets.
//-----------------------------------------------------------------------------   
//#define LED1_OFFSET 0x4C00
//#define LED2_OFFSET 0x4C01
//#define LED3_OFFSET 0x4C02
//#define LED4_OFFSET 0x4C03
//#define LED5_OFFSET 0x4C04
//#define LED6_OFFSET 0x4C05
//#define LED7_OFFSET 0x4C06
//#define LED8_OFFSET 0x4C07
//
//#define GPIO9_OFFSET 0x4C08
//#define GPIO10_OFFSET 0x4C09
//#define GPIO11_OFFSET 0x4C0A
//#define GPIO12_OFFSET 0x4C0B
//
//#define GPIO_LINE_OUTPUT 0x0005 
//#define GPIO_LINE_INPUT 0x0003 


//#ifdef SF2
//#define LED_GLOW_REG_OFFSET 0x4C22 /* SF2 offset */
//#else
//#define LED_GLOW_REG_OFFSET 0x28 /* IGL2 Led Offset */
//#endif

//#ifdef SF2
//#define DIP_SWITCH_STATUS_REGISTER 0x4C21 /* SF2 Dip Switch offset */
//#else
//functions proto typess

// for normal dma operation
//#define DMA_DIR_START					0x2003 
//#define DMA_SIZE						0x2002
//#define DMA_STATUS						0x2006
//#define DMA_CLK_COUNT					0x2005
//#define DMA_BASE_ADDRESS_WRITE			0x2009
//#define DMA_BASE_ADDRESS_READ			0x200A

// for scatter gather dma operation

//#define DMA_RW_REG         0x3F00
//#define DMA_WR_START       0x3F01
//#define DMA_BDA_CH0        0x3F02
//#define DMA_SR_CH0         0x3F04
//#define DMA_BDA_CH1        0x3F06
//#define DMA_SR_CH1         0x3F08
//
#define DIAG_EXIT_MENU 99
//#define ACTIVE_ADDR_SPACE_NEEDS_INIT 0xFF
//#define DEVICE_DETECTION 0xE053
//#define DEVICE_DMA_TYPE 0xE052
//#define DEVICE_SF2_DMA 0xA031
//
//#define G5_DMA_WRITE_TH   0x8
//#define G5_DMA_READ_TH    0x9
//#define G5_FREQ			  0x14
#define G5_DEVICE_DETECT  0x40
  // 0x100 ?

//enum {
//	MENU_CDMA_DDR3_WRITE_OFFSET = 1,
//	MENU_CDMA_DDR3_READ_OFFSET,
//	MENU_CDMA_DDR3_WRITE_READ_OFFSET,
//	MENU_CDMA_DDR4_WRITE_OFFSET,
//	MENU_CDMA_DDR4_READ_OFFSET,
//	MENU_CDMA_DDR4_WRITE_READ_OFFSET,
//	MENU_CDMA_LSRAM_WRITE_OFFSET,
//	MENU_CDMA_LSRAM_READ_OFFSET,
//	MENU_CDMA_LSRAM_WRITE_READ_OFFSET,
//	MENU_COREDMA_DDR3_LSRAM_WRITE_OFFSET,
//	MENU_COREDMA_DDR3_LSRAM_READ_OFFSET,
//	MENU_COREDMA_DDR3_LSRAM_WRITE_READ_OFFSET,
//	MENU_COREDMA_DDR4_LSRAM_WRITE_OFFSET,
//	MENU_COREDMA_DDR4_LSRAM_READ_OFFSET,
//	MENU_COREDMA_DDR4_LSRAM_WRITE_READ_OFFSET,
//	MENU_COREDMA_DDR3_DDR4_WRITE_OFFSET,
//	MENU_COREDMA_DDR3_DDR4_READ_OFFSET,
//	MENU_COREDMA_DDR3_DDR4_WRITE_READ_OFFSET,
//	MENU_SGDMA_DDR3_WRITE_OFFSET,
//	MENU_SGDMA_DDR3_READ_OFFSET,
//	MENU_SGDMA_DDR3_WRITE_READ_OFFSET,
//	MENU_SGDMA_DDR4_WRITE_OFFSET,
//	MENU_SGDMA_DDR4_READ_OFFSET,
//	MENU_SGDMA_DDR4_WRITE_READ_OFFSET,
//	MENU_LABVIEW_TEST,
//	MENU_DMA_THROUGHPUT,
//	MENU_DMA_TEST_ALL,
//	MENU_DMA_EXIT = DIAG_EXIT_MENU,
//};
//enum {
//	SF2 = 1,
//	IGLOO,
//	RTG4,
//	POLARFIRE,
//};

/* Dma tpye (scatter/gather ,hpdma,fabric) */
//enum {
//	DMA_SCATTER_GATHER = 1,
//	DMA_HPDMA,
//	DMA_FABRIC,
//};



/** Structure used in IOCTL to get PCIe state from driver */

/** Structure used in IOCTL to set the normal dma registers */
//typedef struct {
//	USHORT DmaSize;
//	USHORT DmaDirStart;
//	USHORT DmaCh0Status;
//	USHORT DmaCh1Status;
//	USHORT DmaClkCount;
//	USHORT DmaAddWrite;
//	USHORT DmaAddRead;
//}DmaRegisters;
/** Structure used in IOCTL to set the Scatter/gather dma registers */
//typedef struct {
//
//	USHORT DmaSgReadWrite;
//	USHORT DmaSgStart;
//	USHORT DmaSgBDCh0;
//	USHORT DmaSgBDCh1;
//	USHORT DmaSgSRCH0;
//	USHORT DmaSgSRCH1;
//
//}DmaSgRegisters;
/** Structure used in IOCTL to set the LED  registers */
//typedef struct {
//	ULONG Led1offset;
//	ULONG Led2offset;
//	ULONG Led3offset;
//	ULONG Led4offset;
//	ULONG Led5offset;
//	ULONG Led6offset;
//	ULONG Led7offset;
//	ULONG Led8offset;
//	ULONG LedGlowoffset;
//}LedRegisters;

/** Structure used in IOCTL to set the dip switch registers */
typedef struct {
	ULONG Gpio9offset;
	ULONG Gpio10offset;
	ULONG Gpio11offset;
	ULONG Gpio12offset;
	ULONG DipSwitchStatus;
}DipSwitchRegisters;

typedef struct {
	ULONG offset;
	ULONG data;
	ULONG bar;
}config_write_read;

/* Device type */
enum {
	DEVICE_SF2_FDMA = 1,
	DEVICE_IGLOO2_FDMA,
	DEVICE_SF2_HPDMA,
	DEVICE_IGLOO2_HPDMA,
	DEVICE_SF2_SG,
	DEVICE_RTG4_FDMA,
	DEVICE_G5_PF
};

struct dma_operation
{
	ULONG throughput_tx;//pc to ddr
	ULONG throughput_rx;//ddr to pc
	ULONG bd_tx;
	ULONG bd_rx;

};


typedef struct
{
	ULONG Devicetype;
	ULONG Dmasupport;
	ULONG ControlPlan;
	ULONG Dma;
}devtype;
//typedef struct
//{
//	DmaSgRegisters DmasgR;
//	DmaRegisters   DmaR;
//	LedRegisters   LedR;
//	DipSwitchRegisters DipSR;
//	devtype Devtype;
//	int Led_status;
//	int DipS_status;
//	int Dma_status;
//	int dmatpye;
//	int Barw_status;
//	int BAR_LSRAM_status;
//	int BAR_DDR3_status;
//	int BAR_DDR4_status;
//	int lab_w_status, lab_r_status;
//}globle_dev_info;

class mpci
{


public:
	mpci()
	{

		hDevInfo = NULL;
		pDeviceInterfaceDetail = NULL;
		hDevice = INVALID_HANDLE_VALUE;
		console = TRUE;
		device = FALSE;
	}
	~mpci()
	{

		if (hDevInfo) {
			SetupDiDestroyDeviceInfoList(hDevInfo);
		}

		if (pDeviceInterfaceDetail) {
			free(pDeviceInterfaceDetail);
		}

		if (hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(hDevice);
			hDevice = INVALID_HANDLE_VALUE;
		}

	}

	inline BOOL Initialize()
	{
		if (m_initialized)
		{
			return TRUE;
		}
		BOOL retValue = GetDevicePath();
		if ((retValue == TRUE) && (hDevice == INVALID_HANDLE_VALUE)) {
			retValue = GetDeviceHandle();
		}
		if (retValue == FALSE)
		{
			return false;
		}
		else
		{
			m_initialized = true;

			return true;
		}
	}
	inline bool IsInitialized()
	{
		return m_initialized;
	}
	inline bool WriteDMA(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
	{
		ULONG bytesReturned = 0;
		G5_DmaRegisters ldma_config = { 0,0,0,0,0,0 };

		ldma_config.Dma_Destaddr32 = offset + baseAddress;
		ldma_config.Dma_length = sizeof(ULONG) * numberOfItems;

		if (!DeviceIoControl(hDevice,
			(DWORD)IOCTL_G5_DMA_CONFIG,
			&ldma_config,
			sizeof(ldma_config),
			NULL,
			NULL,
			&bytesReturned,
			NULL))
		{
			return false;
		}
		if (DeviceIoControl(hDevice,
			(DWORD)IOCTL_G5_CN_DMA_WRITE,
			buffer,
			ldma_config.Dma_length,
			NULL,
			NULL,
			&bytesReturned,
			NULL))
		{
			return false;
		}
		return true;
	}

	inline bool ReadDMA(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
	{
		ULONG bytesReturned = 0;
		G5_DmaRegisters ldma_config = { 0,0,0,0,0,0 };

		ldma_config.Dma_Srcaddr32 = offset + baseAddress;
		ldma_config.Dma_length = sizeof(ULONG) * numberOfItems;

		if (!DeviceIoControl(hDevice,
			(DWORD)IOCTL_G5_DMA_CONFIG,
			&ldma_config,
			sizeof(ldma_config),
			NULL,
			NULL,
			&bytesReturned,
			NULL)) {
			return false;

		}

		if (!DeviceIoControl(hDevice,
			(DWORD)IOCTL_G5_CN_DMA_READ,
			NULL,
			NULL,
			buffer,
			ldma_config.Dma_length,
			&bytesReturned,
			NULL)) {
			return false;

		}

		return true;
	}
	inline bool ReadDirect(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
	{
		int ret = mpci_bar_write(0, PFREG_BASEADDR, baseAddress);
		for (ULONG pos = 0; pos < numberOfItems; pos++)
		{
			buffer[pos] = mpci_bar_read(2, (offset + pos));
		}

		ret = mpci_bar_write(0, PFREG_BASEADDR, PFBASE_IO_CTRL);
		return ret;
	}
	inline bool WriteDirect(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
	{
		int ret = mpci_bar_write(0, PFREG_BASEADDR, baseAddress);
		for (ULONG pos = 0; pos < numberOfItems; pos++)
		{
			mpci_bar_write(2, (offset + pos), buffer[pos]);
		}

		ret = mpci_bar_write(0, PFREG_BASEADDR, PFBASE_IO_CTRL);
		return ret;

	}
	int GetDeviceinfo(device_info& devInfo)
	{
		int status = 1;
		int bar = 0, i = 0, j = 0;
		int device = 0, device_dma = 0;



		PCIState* pcistate = new PCIState();

		bar_info lbar_info = { 0,0,0,0,0,0 };
		if (IsInitialized())
		{
			devInfo.device_status = "Device detected";
		}
		else
		{
			devInfo.device_status = "Device not found";
			delete pcistate;
			return FALSE;
		}

		devInfo.demo_type_id = 0;  // NEED TO DEFINE THESE!
		devInfo.demo_type = "PolarFire PCIe Demo";
		device = mpci_bar_read(BAR2, G5_DEVICE_DETECT);
		devInfo.device_type_id = device;

		if (device == 0x332211)
		{
			devInfo.device_type = "PolarFire Evaluation kit";
		}
		else if (device == 0x332222)
		{
			devInfo.device_type = "PolarFire Splash kit";
		}
		else
		{
			devInfo.device_type = "Unknown device";
		}
		pcistate = (PCIState*)mpci_config_read();
		pcistate->Link_cap_register = pcistate->Link_cap_register & 0x1FF;
		pcistate->Link_status_register = pcistate->Link_status_register & 0x1FF;

		switch ((pcistate->Link_cap_register >> 4 & 0x3F))
		{
		case 0x1:
			devInfo.support_width = "x1  (1 lanes)";
			break;
		case 0x2:
			devInfo.support_width = "x2  (2 lanes)";
			break;
		case 0x4:
			devInfo.support_width = "x4  (4 lanes)";
			break;
		case 0x8:
			devInfo.support_width = "x8  (8 lanes)";
			break;
		case 0xC:
			devInfo.support_width = "x12  (12 lanes)";
			break;
		case 0x10:
			devInfo.support_width = "x16  (16 lanes)";
			break;
		case 0x20:
			devInfo.support_width = "x32  (32 lanes)";
			break;

		};
		switch ((pcistate->Link_status_register >> 4 & 0x3F))
		{
		case 0x1:
			devInfo.n_width = "x1  (1 lanes)";
			break;
		case 0x2:
			devInfo.n_width = "x2  (2 lanes)";
			break;
		case 0x4:
			devInfo.n_width = "x4  (4 lanes)";
			break;
		case 0x8:
			devInfo.n_width = "x8  (8 lanes)";
			break;
		case 0xC:
			devInfo.n_width = "x12  (12 lanes)";
			break;
		case 0x10:
			devInfo.n_width = "x16  (16 lanes)";
			break;
		case 0x20:
			devInfo.n_width = "x32  (32 lanes)";
			break;

		};

		switch ((pcistate->Link_cap_register & 0xF))
		{
		case 1:
			devInfo.support_speed = "2.5 Gbps (Gen 1)";
			break;
		case 2:
			devInfo.support_speed = "5 Gbps (Gen 2)";
			break;
		}

		switch ((pcistate->Link_status_register & 0xF))
		{
		case 1:
			devInfo.n_speed = "2.5 Gbps (Gen 1)";
			break;
		case 2:
			devInfo.n_speed = "5 Gbps (Gen 2)";
			break;
		}
		j = 0;
		for (i = 0; i < 6; i++)
		{
			if (pcistate->u.type0.BaseAddresses[i] != 0)
				j++;
			else if ((i & 1) && (pcistate->u.type0.BaseAddresses[i - 1] & 0x4))
				j++;
		}
		devInfo.num_bar = j;

		devInfo.driver_version = "6.1.7600.16385";
		devInfo.driver_timestamp = "03:13:01 14/11/2017";
		status = mpci_bar_info(&lbar_info);
		if (status == FALSE)
		{
			return FALSE;
		}
		devInfo.bar0_add = pcistate->u.type0.BaseAddresses[0];
		devInfo.bar0_size = lbar_info.bar0_size;

		devInfo.bar1_add = pcistate->u.type0.BaseAddresses[1];
		devInfo.bar1_size = lbar_info.bar1_size;

		devInfo.bar2_add = pcistate->u.type0.BaseAddresses[2];
		devInfo.bar2_size = lbar_info.bar2_size;

		devInfo.bar3_add = pcistate->u.type0.BaseAddresses[3];
		devInfo.bar3_size = lbar_info.bar3_size;

		devInfo.bar4_add = pcistate->u.type0.BaseAddresses[4];
		devInfo.bar4_size = lbar_info.bar4_size;

		devInfo.bar5_add = pcistate->u.type0.BaseAddresses[5];
		devInfo.bar5_size = lbar_info.bar5_size;

		return TRUE;
	}

private:

	BOOL GetDevicePath()
	{
		SP_DEVICE_INTERFACE_DATA DeviceInterfaceData;
		SP_DEVINFO_DATA DeviceInfoData;

		SP_DRVINFO_DATA DriverInfoData;
		SP_DRVINFO_DETAIL_DATA DriverInfoDetailData;

		ULONG size;
		int count, i, index;
		BOOL status = TRUE;
		TCHAR* DeviceName = NULL;
		TCHAR* DeviceLocation = NULL;

		hDevInfo = SetupDiGetClassDevs(&GUID_MPCI_INTERFACE,
			NULL,
			NULL,
			DIGCF_DEVICEINTERFACE |
			DIGCF_PRESENT);

		DeviceInterfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

		count = 0;
		while (SetupDiEnumDeviceInterfaces(hDevInfo,
			NULL,
			&GUID_MPCI_INTERFACE,
			count++,  //Cycle through the available devices.
			&DeviceInterfaceData)
			);


		count--;


		if (count == 0) {
			return FALSE;
		}

		DeviceInterfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);
		DeviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

		i = 0;
		while (SetupDiEnumDeviceInterfaces(hDevInfo,
			NULL,
			(LPGUID)&GUID_MPCI_INTERFACE,
			i,
			&DeviceInterfaceData)) {

			SetupDiGetDeviceInterfaceDetail(hDevInfo,
				&DeviceInterfaceData,
				NULL,
				0,
				&size,
				NULL);

			if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
				return FALSE;
			}

			pDeviceInterfaceDetail = (PSP_DEVICE_INTERFACE_DETAIL_DATA)malloc(size);

			if (!pDeviceInterfaceDetail) {
				return FALSE;
			}

			pDeviceInterfaceDetail->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);
			status = SetupDiGetDeviceInterfaceDetail(hDevInfo,
				&DeviceInterfaceData,
				pDeviceInterfaceDetail,
				size,
				NULL,
				&DeviceInfoData);

			free(pDeviceInterfaceDetail);

			if (!status) {
				return FALSE;
			}

			SetupDiGetDeviceRegistryProperty(hDevInfo,
				&DeviceInfoData,
				SPDRP_DEVICEDESC,
				NULL,
				(PBYTE)DeviceName,
				0,
				&size);

			if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
				return FALSE;
			}

			DeviceName = (TCHAR*)malloc(size);
			if (!DeviceName) {
				return FALSE;
			}

			status = SetupDiGetDeviceRegistryProperty(hDevInfo,
				&DeviceInfoData,
				SPDRP_DEVICEDESC,
				NULL,
				(PBYTE)DeviceName,
				size,
				NULL);
			if (!status) {
				free(DeviceName);
				return status;
			}

			SetupDiGetDeviceRegistryProperty(hDevInfo,
				&DeviceInfoData,
				SPDRP_LOCATION_INFORMATION,
				NULL,
				(PBYTE)DeviceLocation,
				0,
				&size);

			if (GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
				DeviceLocation = (TCHAR*)malloc(size);

				if (DeviceLocation != NULL) {

					status = SetupDiGetDeviceRegistryProperty(hDevInfo,
						&DeviceInfoData,
						SPDRP_LOCATION_INFORMATION,
						NULL,
						(PBYTE)DeviceLocation,
						size,
						NULL);
					if (!status) {
						free(DeviceLocation);
						DeviceLocation = NULL;
					}
				}

			}
			else {
				DeviceLocation = NULL;
			}
			free(DeviceName);
			DeviceName = NULL;

			if (DeviceLocation) {
				free(DeviceLocation);
				DeviceLocation = NULL;
			}

			i++;
		}

		index = 0;
		if (count > 1) {
			if (scanf_s("%d", &index) == 0) {
				return ERROR_INVALID_DATA;
			}
		}

		status = SetupDiEnumDeviceInterfaces(hDevInfo,
			NULL,
			(LPGUID)&GUID_MPCI_INTERFACE,
			index,
			&DeviceInterfaceData);

		if (!status) {

			return status;
		}

		SetupDiGetDeviceInterfaceDetail(hDevInfo,
			&DeviceInterfaceData,
			NULL,
			0,
			&size,
			NULL);

		if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {

			return FALSE;
		}

		pDeviceInterfaceDetail = (PSP_DEVICE_INTERFACE_DETAIL_DATA)malloc(size);

		if (!pDeviceInterfaceDetail) {
			return FALSE;
		}

		pDeviceInterfaceDetail->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

		status = SetupDiGetDeviceInterfaceDetail(hDevInfo,
			&DeviceInterfaceData,
			pDeviceInterfaceDetail,
			size,
			NULL,
			&DeviceInfoData);
		if (!status) {
			return status;
		}

		//driver info
		DriverInfoData.cbSize = sizeof(SP_DRVINFO_DATA);
		DriverInfoDetailData.cbSize = sizeof(SP_DRVINFO_DETAIL_DATA);

	
		return status;
	}



	int mpci_isr_control(int data)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		int test = data;

		retValue = Mpci.Initialize();

		if (!retValue) {

			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_PCI_INTERRUPT_CONTROL,
				&test,
				sizeof(test),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}



		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		return status;

	}
	void* mpci_isr_count_all(ULONG);
	int mpci_isr_count(void)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		int data = 0;

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_ISR_COUNT,
				NULL,
				NULL,
				&data,
				sizeof(data),
				&bytesReturned,
				NULL);
		}


		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		return data;
	}

	int mpci_bar_write(ULONG bar, ULONG offset, ULONG data)
	{
		ULONG bytes = 0;
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		DWORD IoctlTpye = IOCTL_BAR_WRITE;
		config_write_read info = { 0,0,0 };


		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}


		info.offset = offset;
		info.data = data;
		info.bar = bar;



		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				IoctlTpye,
				&info,
				sizeof(info),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		return status;


	}
	int mpci_bar_read(ULONG bar, ULONG offset)
	{
		ULONG bytes = 0;

		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		ULONG data = 0, useroffset = 0;
		DWORD IoctlTpye = IOCTL_BAR_READ;
		config_write_read info;
		IoctlTpye = IOCTL_BAR_READ;
		useroffset = offset;

		info.offset = offset;
		info.data = data;
		info.bar = bar;

		if (status)
		{
			DeviceIoControl(hDevice,
				IoctlTpye,
				&info,
				sizeof(info),
				&data,
				sizeof(data),
				&bytesReturned,
				NULL);
		}

		if (status)
		{
			return data;

		}
		else
		{
			return status;
		}


	}
	int mpci_bar_info(bar_info* pbar)
	{

		ULONG bytes = 0;
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		bar_info lbar = { 0,0,0,0,0,0,0,0,0,0,0,0 };

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}


		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_BAR_INFO,
				NULL,
				NULL,
				&lbar,
				sizeof(lbar),
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		pbar->bar0_addr = lbar.bar0_addr;
		pbar->bar0_size = lbar.bar0_size;
		pbar->bar1_addr = lbar.bar1_addr;
		pbar->bar1_size = lbar.bar1_size;
		pbar->bar2_addr = lbar.bar2_addr;
		pbar->bar2_size = lbar.bar2_size;
		pbar->bar3_addr = lbar.bar3_addr;
		pbar->bar3_size = lbar.bar3_size;
		pbar->bar4_addr = lbar.bar4_addr;
		pbar->bar4_size = lbar.bar4_size;
		pbar->bar5_addr = lbar.bar5_addr;
		pbar->bar5_size = lbar.bar5_size;

		if (status)
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}

	void* mpci_config_read(void)
	{

		ULONG bytes = 0;
		int data = 0;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		PCIState* pcistate = new PCIState();
		PCIState xpcistate = { 0,0,0,0,0,0,0,0,0,0,0 };

		if (!retValue) {
			return NULL;
		}

		if (status)
		{
			DeviceIoControl(hDevice,
				(DWORD)IOCTL_PCI_CONFIG_SPACE_ALL_READ,
				NULL,
				NULL,
				&xpcistate,
				sizeof(xpcistate),
				&bytesReturned,
				NULL);

		}
		CopyMemory(pcistate, &xpcistate, sizeof(xpcistate));

		return pcistate;
	}
	int mpci_config_write(int offset, int data)
	{

		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		config_write_read cnf_wr = { 0,0 };

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		cnf_wr.offset = offset;
		cnf_wr.data = data;

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_PCI_CONFIG_SPACE_WRITE,
				&cnf_wr,
				sizeof(cnf_wr),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}


		return status;
	}
	int mpci_config_read_offset(int offset)
	{

		ULONG bytes = 0;
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		int data = 0, useroffset = 0;

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		useroffset = offset;
		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_PCI_CONFIG_READ_OFFSET,
				&useroffset,
				sizeof(useroffset),
				&data,
				sizeof(data),
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		if (status)
		{
			return data;
		}
		else
		{
			return status;
		}
	}
	int mpci_dma_operation(int data)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		int test = data;
		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_OPERAION,
				&test,
				sizeof(test),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		return status;

	}
	int mpci_dma_configuration(void* x, int size)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_CONFIGURATION,
				x,
				size,
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		return status;
	}
	int mpci_dma_read_write(ULONG offset1, ULONG size1, ULONG offset2, ULONG size2, void* type)
	{

		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		ULONG  j = 0;
		ULONG heap_size1 = 0;
		ULONG heap_size2 = 0;
		ULONG* data1 = (ULONG*)malloc(size1 * sizeof(ULONG));
		ULONG* data2 = (ULONG*)malloc(size2 * sizeof(ULONG));
		config_write_read wr = { 0,0 };
		config_write_read* x = (config_write_read*)type;

		if (data1 == NULL && data2 == NULL)
		{
			return FALSE;
		}

		heap_size1 = sizeof(ULONG) * size1;
		heap_size2 = sizeof(ULONG) * size2;

		for (j = 0; j < size2; j++)
		{
			data2[j] = 5;

		}

		if (x->offset = DEVICE_SF2_FDMA)
		{
			if (x->data == 1)
			{
				wr.offset = 0x11AA0001;
				wr.data = 0x11AA0002;
			}
			else
			{
				wr.offset = 0x11AA0005;
				wr.data = 0x11AA0006;
			}
		}
		else
		{
			return 0;

		}

		heap_size1 = sizeof(ULONG) * size1;
		heap_size2 = sizeof(ULONG) * size2;
		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data2);
			free(data1);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_TYPE,
				&wr,
				sizeof(wr),
				NULL,
				NULL,
				&bytesReturned,
				NULL);


			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_WRITE_READ,
				data2,
				heap_size2,
				data1,
				heap_size1,
				&bytesReturned,
				NULL);
		}


		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		free(data2);
		free(data1);
		return status;

	}

	int mpci_dma_sg_read(ULONG offset, ULONG size)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		int  j = 0;
		int heap_size = 0;
		int test = 0;

		int* data = (int*)malloc(sizeof(int) * size);

		if (data == NULL)
		{
			return FALSE;
		}

		heap_size = sizeof(int) * size;

		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			ReadFile(Mpci.hDevice,
				data,
				heap_size,
				&bytesReturned,
				NULL);
		}


		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		test = heap_size / 4;
		free(data);

		return status;
	}
	int mpci_dma_sg_write(ULONG offset, ULONG size)
	{

		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		int heap_size = 0;
		ULONG j = 0;
		ULONG dummy = 0;
		ULONG TR = 0, TW = 0, Th_Wput = 0, i = 0, FR = 0, Th_Rput = 0, size1 = 0;

		heap_size = sizeof(ULONG) * size;
		ULONG* data = (ULONG*)malloc(sizeof(ULONG) * size);

		if (data == NULL)
		{
			return FALSE;
		}

		dummy = heap_size / 4;

		for (j = 0; j < dummy; j++)
		{
			data[j] = j + 1;
		}

		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}
		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_WOFFSET,
				&offset,
				sizeof(ULONG),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_SG_DMA_WRITE,
				data,
				heap_size,
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}
		free(data);
		return status;
	}


	int mpci_dma_sg_read_write(ULONG offset1, ULONG size1, ULONG offset2, ULONG size2)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		ULONG  j = 0;
		ULONG heap_size1 = 0, heap_size2 = 0;
		ULONG* data1 = (ULONG*)malloc(sizeof(ULONG) * size1);
		ULONG* data2 = (ULONG*)malloc(sizeof(ULONG) * size2);
		ULONG test1 = 0, test2 = 0;

		ULONG TR = 0, TW = 0, Th_Wput = 0, i = 0, FR = 0, Th_Rput = 0;


		data1 = (ULONG*)malloc(sizeof(ULONG) * size1);
		data2 = (ULONG*)malloc(sizeof(ULONG) * size2);

		if ((data1 == NULL) || (data2 == NULL))
		{
			return FALSE;

		}
		heap_size1 = sizeof(int) * size1;
		heap_size2 = sizeof(int) * size2;

		test2 = heap_size2 / 4;
		test1 = heap_size1 / 4;


		for (j = 0; j < test2; j++)
		{
			data2[j] = j + 1;

		}


		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data1);
			free(data2);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_ROFFSET,
				&offset1,
				sizeof(ULONG),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_WOFFSET,
				&offset2,
				sizeof(ULONG),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_SG_DMA_WRITE_READ,
				data2,
				heap_size2,
				data1,
				heap_size1,
				&bytesReturned,
				NULL);
		}

		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		free(data1);
		free(data2);

		return status;

	}
	int mpci_dma_sg_read_ioctl(ULONG offset, ULONG size)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		ULONG  j = 0;
		ULONG heap_size = 0;
		int* data1 = (int*)malloc(size * sizeof(int));
		int* data2 = (int*)malloc(size * sizeof(int));
		ULONG test = 0;
		ULONG TR = 0, TW = 0, Th_Wput = 0, i = 0, FR = 0, Th_Rput = 0, size2 = 0;

		if ((data1 == NULL))
		{
			return FALSE;
		}
		heap_size = sizeof(int) * size;
		test = heap_size / 4;
		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data1);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_ROFFSET,
				&offset,
				sizeof(ULONG),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_SG_DMA_READ,
				NULL,
				NULL,
				data1,
				heap_size,
				&bytesReturned,
				NULL);
		}

		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		free(data1);
		free(data2);
		return status;

	}
	int mpci_dma_bd_count(config_write_read* bd_ct)
	{

		ULONG bytes = 0;
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned;
		config_write_read lbd_ct = { 0,0,0 };

		retValue = Mpci.Initialize();

		if (!retValue) {
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}


		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_BD_COUNT,
				NULL,
				NULL,
				&lbd_ct,
				sizeof(lbd_ct),
				&bytesReturned,
				NULL);
		}
		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}

		bd_ct->offset = lbd_ct.offset;
		bd_ct->data = lbd_ct.data;

		if (status)
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}


	int mpci_G5_CN_Dma_Write(ULONG offset, ULONG size, ULONG type);
	int mpci_G5_CN_Dma_Read(ULONG offset, ULONG size, ULONG** p, ULONG* buf_offset);
	int mpci_G5_SG_Dma_Write(ULONG offset, ULONG size, ULONG type);
	int mpci_G5_SG_Dma_Read(ULONG offset, ULONG size, ULONG** ptr, ULONG* buf_offset);
	int mpci_G5_CN_FDma_Write(ULONG offset, ULONG size, void* type)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		ULONG  j = 0;
		ULONG heap_size = 0;
		ULONG* data = (ULONG*)malloc(sizeof(ULONG) * size);
		config_write_read wr = { 0,0 };
		config_write_read* x = (config_write_read*)type;
		if (data == NULL)
		{
			return FALSE;
		}

		heap_size = sizeof(ULONG) * size;
		if (x->offset == DEVICE_SF2_FDMA)
		{
			if (x->data == 1)
			{
				wr.offset = 0x11AA0001;
				wr.data = 0;
			}
			else
			{
				wr.offset = 0x11AA0005;
				wr.data = 0;
			}
		}

		for (j = 0; j < size; j++)
		{
			data[j] = j + 1;

		}

		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_TYPE,
				&wr,
				sizeof(wr),
				NULL,
				NULL,
				&bytesReturned,
				NULL);
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_G5_CN_FDMA_WRITE,
				data,
				heap_size,
				NULL,
				NULL,
				&bytesReturned,
				NULL);
		}



		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		free(data);
		return status;
	}

	int mpci_G5_CN_FDma_Read(ULONG offset, ULONG size, void* type)
	{
		mpci Mpci;
		BOOL status = TRUE;
		BOOL retValue = TRUE;
		ULONG bytesReturned = 0;
		ULONG count = 0;
		ULONG  j = 0;
		ULONG heap_size = 0;
		ULONG test = 0;
		ULONG* data2 = (ULONG*)malloc(size * sizeof(ULONG));
		config_write_read wr = { 0,0 };
		config_write_read* x = (config_write_read*)type;
		heap_size = sizeof(ULONG) * size;

		if (x->offset == DEVICE_SF2_FDMA)
		{
			if (x->data == 1)
			{
				wr.offset = 0;
				wr.data = 0x11AA0002;
			}
			else
			{
				wr.offset = 0;
				wr.data = 0x11AA0006;
			}
		}

		retValue = Mpci.Initialize();

		if (!retValue) {
			free(data2);
			return retValue;
		}

		if ((status == TRUE) && (Mpci.hDevice == INVALID_HANDLE_VALUE)) {
			status = Mpci.GetDeviceHandle();
		}

		if (status)
		{
			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_DMA_TYPE,
				&wr,
				sizeof(wr),
				NULL,
				NULL,
				&bytesReturned,
				NULL);

			DeviceIoControl(Mpci.hDevice,
				(DWORD)IOCTL_G5_CN_FDMA_READ,
				NULL,
				NULL,
				data2,
				heap_size,
				&bytesReturned,
				NULL);
		}


		if (Mpci.hDevice != INVALID_HANDLE_VALUE) {
			CloseHandle(Mpci.hDevice);
			Mpci.hDevice = INVALID_HANDLE_VALUE;
		}
		test = heap_size / 4;
		for (j = 0; j < test; j++)
		{
			if (data2[j] != (j + 1))
			{
				free(data2);
				status = FALSE;
				return status;
			}
		}

		free(data2);

		return status;


	}


private:

	BOOL
		GetDeviceHandle()
	{
		BOOL status = TRUE;

		if (pDeviceInterfaceDetail == NULL) {
			status = GetDevicePath();
		}
		if (pDeviceInterfaceDetail == NULL) {
			status = FALSE;
		}

		if (status) {

			hDevice = CreateFile(pDeviceInterfaceDetail->DevicePath,
				GENERIC_READ | GENERIC_WRITE,
				FILE_SHARE_READ | FILE_SHARE_WRITE,
				NULL,
				OPEN_EXISTING,
				0,
				NULL);

			if (hDevice == INVALID_HANDLE_VALUE) {
				status = FALSE;
			}
		}

		return status;
	}

	HDEVINFO hDevInfo;
	PSP_DEVICE_INTERFACE_DETAIL_DATA pDeviceInterfaceDetail;
	HANDLE hDevice;
		
	BOOL device;

	BOOL console;
	bool m_initialized = false;
	};

