#pragma once
#include <windows.h>
#include <cstdint>
#include <vector>
#include <iostream>
#include <iomanip>
#include <setupapi.h>
#include <initguid.h>

namespace SDSP
{
	DEFINE_GUID(GUID_MPCI_INTERFACE, 0xcfbc8bc3, 0x500e, 0x4a6a, 0x84, 0xfe, 0x26, 0x90, 0xf1, 0x7d, 0xd9, 0xef);
	// Defines
#define PFBASE_MEMTEST_LSRAM	(0x30000000)
#define PFBASE_MEMTEST_DDR4		(0x40000000)
// Address Offset Register for BAR2
#define PFREG_BASEADDR			(0x8648 >> 2)
#define PFBASE_IO_CTRL			(0x10000000)
#define PCI_TYPE0_ADDRESSES     (6)
#define G5_DEVICE_DETECT		(0x40)
#define BAR0					(0)
#define BAR1					(1)
#define BAR2					(2)
#define MICRO_PCI_TYPE			(50001)


#define IOCTL_PCI_CONFIG_SPACE_ALL_READ CTL_CODE( MICRO_PCI_TYPE, 0x900, METHOD_BUFFERED, FILE_ANY_ACCESS  )

#define IOCTL_PCI_LED_CONTROL CTL_CODE( MICRO_PCI_TYPE, 0x901, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_INTERRUPT_CONTROL CTL_CODE( MICRO_PCI_TYPE, 0x902, METHOD_BUFFERED, FILE_ANY_ACCESS  )

#define IOCTL_DEVICE_INFO CTL_CODE( MICRO_PCI_TYPE, 0x903, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SRAM_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x904, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SRAM_READ CTL_CODE( MICRO_PCI_TYPE, 0x905, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DIP_SWITCH CTL_CODE( MICRO_PCI_TYPE, 0x906, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_CONFIG_SPACE_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x907, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_ISR_COUNT CTL_CODE( MICRO_PCI_TYPE, 0x908, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_PCI_CONFIG_READ_OFFSET CTL_CODE( MICRO_PCI_TYPE, 0x909, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x90A, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_READ CTL_CODE( MICRO_PCI_TYPE, 0x90B, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x90C, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_READ CTL_CODE( MICRO_PCI_TYPE, 0x90D, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_SG_DMA_WRITE_READ CTL_CODE( MICRO_PCI_TYPE, 0x90E, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR0_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x90F, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR0_READ CTL_CODE( MICRO_PCI_TYPE, 0x910, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR1_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x911, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR1_READ CTL_CODE( MICRO_PCI_TYPE, 0x912, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_OPERAION CTL_CODE( MICRO_PCI_TYPE, 0x913, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_WOFFSET CTL_CODE( MICRO_PCI_TYPE, 0x914, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_CONFIGURATION CTL_CODE( MICRO_PCI_TYPE, 0x915, METHOD_BUFFERED , FILE_ANY_ACCESS  )	


#define IOCTL_DMA_WRITE_READ CTL_CODE( MICRO_PCI_TYPE, 0x916, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_ROFFSET CTL_CODE( MICRO_PCI_TYPE, 0x917, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_DMA_TYPE CTL_CODE( MICRO_PCI_TYPE, 0x918, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x919, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_READ CTL_CODE( MICRO_PCI_TYPE, 0x920, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_SG_DMA_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x921, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_SG_DMA_READ CTL_CODE( MICRO_PCI_TYPE, 0x922, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_DMA_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x923, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_DMA_READ CTL_CODE( MICRO_PCI_TYPE, 0x924, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_FDMA_WRITE CTL_CODE( MICRO_PCI_TYPE, 0x925, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_CN_FDMA_READ CTL_CODE( MICRO_PCI_TYPE, 0x926, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BAR_INFO CTL_CODE( MICRO_PCI_TYPE, 0x927, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_ISR_COUNT_ALL CTL_CODE( MICRO_PCI_TYPE, 0x928, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_BD_COUNT CTL_CODE( MICRO_PCI_TYPE, 0x929, METHOD_BUFFERED , FILE_ANY_ACCESS  )

#define IOCTL_G5_DMA_CONFIG CTL_CODE( MICRO_PCI_TYPE, 0x930, METHOD_BUFFERED , FILE_ANY_ACCESS  )

	//typedefs
	typedef PVOID HDEVINFO;

	// Structure 
	struct PCIState {

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
			USHORT  MSIEnable : 1;
			USHORT  MultipleMessageCapable : 3;
			USHORT  MultipleMessageEnable : 3;
			USHORT  CapableOf64Bits : 1;
			USHORT  PerVectorMaskCapable : 1;
			USHORT  Reserved : 7;
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

	};
	struct device_info
	{
		const char* device_status;
		const char* device_type;
		//const char* driver_version;
		//const char* driver_timestamp;
		const char* demo_type;
		const char* support_width;
		const char* n_width;
		const char* support_speed;
		const char* n_speed;
		int device_type_id;
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
	struct bar_info
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
	};
	struct G5_DmaRegisters {
		unsigned int       Dma_Srcaddr32;
		unsigned int       Dma_Srcaddr64;
		unsigned int       Dma_Destaddr32;
		unsigned int       Dma_Destaddr64;
		unsigned int       Dma_length;
		unsigned int       Dma_Status;
	};
	struct config_write_read {
		ULONG offset;
		ULONG data;
		ULONG bar;
	};

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
			m_initialized = FALSE;
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
			if (GetDevicePath() == TRUE && GetDeviceHandle() == TRUE)
			{
				m_initialized = true;
				return true;
			}
			return false;
		}
		int GetDeviceinfo(device_info& devInfo)
		{
			int status = 1;
			int bar = 0, i = 0, j = 0;
			ULONG device = 0;
			int device_dma = 0;
			PCIState* pcistate;

			bar_info lbar_info = { 0,0,0,0,0,0 };
			if (IsInitialized())
			{
				devInfo.device_status = "Device detected";
			}
			else
			{
				devInfo.device_status = "Device not found";
				return FALSE;
			}

			devInfo.demo_type = "PolarFire PCIe Demo";
			mpci_bar_read(BAR2, G5_DEVICE_DETECT, device);
			devInfo.device_type_id = device;

			if (device == 0x332211)
			{
				devInfo.device_type = "PolarFire kit";
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

			if (mpci_bar_info(&lbar_info) == FALSE)
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
			if (!DeviceIoControl(hDevice,
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
				mpci_bar_read(2, (offset + pos), buffer[pos]);
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
	private:
		int mpci_bar_info(bar_info* pbar)
		{
			//ULONG bytes = 0;
			ULONG bytesReturned;
			bar_info lbar = { 0,0,0,0,0,0,0,0,0,0,0,0 };

			if (!DeviceIoControl(hDevice,
				(DWORD)IOCTL_BAR_INFO,
				NULL,
				NULL,
				&lbar,
				sizeof(lbar),
				&bytesReturned,
				NULL))
			{
				return FALSE;
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


			return TRUE;

		}
		int mpci_bar_read(ULONG bar, ULONG offset, ULONG& data)
		{



			ULONG bytesReturned;
			ULONG  useroffset = 0;
			DWORD IoctlTpye = IOCTL_BAR_READ;
			config_write_read info;
			IoctlTpye = IOCTL_BAR_READ;
			useroffset = offset;

			info.offset = offset;
			info.data = data;
			info.bar = bar;

			if (!DeviceIoControl(hDevice,
				IoctlTpye,
				&info,
				sizeof(info),
				&data,
				sizeof(data),
				&bytesReturned,
				NULL))
			{
				return FALSE;
			}




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
		inline bool IsInitialized()
		{
			return m_initialized;
		}
		BOOL GetDeviceHandle()
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

		HDEVINFO hDevInfo;
		PSP_DEVICE_INTERFACE_DETAIL_DATA pDeviceInterfaceDetail;
		HANDLE hDevice;

		BOOL device;

		BOOL console;
		bool m_initialized = false;



	};
}