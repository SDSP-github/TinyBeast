#pragma once

#include <windows.h>
#include <cstdint>
#include <vector>
#include <iostream>
#include <iomanip>
#include <setupapi.h>
#include <initguid.h>
#include "mpci.hpp"


namespace SDSP
{
	class PolarFireSDK
	{


	public:
		bool Init()
		{
			m_mpci.Initialize();
			int result = m_mpci.GetDeviceinfo(m_devInfo);
			m_deviceFound = (result != 0);
			return IsInit();

		}
		bool IsInit()
		{
			return m_deviceFound;
		}
		void PrintDeviceInfo()
		{
			std::ios_base::fmtflags old_flags = std::cout.flags();
			std::cout << std::setw(20) << "---------------------" << "\n";
			std::cout << std::setw(20) << "Printing Device info" << std::endl;
			std::cout << std::setw(20) << "device_status = " << m_devInfo.device_status << std::endl;
			std::cout << std::setw(20) << "device_type = " << "0x" << std::hex << m_devInfo.device_type_id << " -> "
				<< m_devInfo.device_type << std::endl;
			std::cout << std::setw(20) << "support_width = " << m_devInfo.support_width << std::endl;
			std::cout << std::setw(20) << "n_width = " << m_devInfo.n_width << std::endl;
			std::cout << std::setw(20) << "support_speed = " << m_devInfo.support_speed << std::endl;
			std::cout << std::setw(20) << "n_speed = " << m_devInfo.n_speed << std::endl;
			std::cout << std::setw(20) << "num_bar = " << m_devInfo.num_bar << std::endl;

			std::cout << std::setw(20) << "BAR0 info = " << ((m_devInfo.bar0_add & 6) ? "64-bit" : "32-bit") << ", Prefetchable: " << ((m_devInfo.bar0_add & 8) ? "Yes" : "No") << std::endl;

			if ((m_devInfo.bar0_add & 6) == 4) { // A 64-bit BAR, which also consumes BAR1
				std::cout << std::setw(20) << "bar0_add = " << "0x" << std::hex << std::noshowbase << std::setw(8) << std::setfill('0') << m_devInfo.bar1_add
					<< ":" << std::setw(8) << (m_devInfo.bar0_add & 0xFFFFFFF0) << std::endl << std::setfill(' ');
				std::cout << std::setw(20) << "bar0_size = " << std::showbase << m_devInfo.bar0_size << std::endl;
			}
			else {  // 32-bit BAR, BAR1 is independent

				std::cout << std::setw(20) << "bar0_add = " << std::hex << std::showbase << (m_devInfo.bar0_add & 0xFFFFFFF0) << std::endl;
				std::cout << std::setw(20) << "bar0_size = " << m_devInfo.bar0_size << std::endl;

				if (m_devInfo.num_bar > 1) {
					std::cout << std::setw(20) << "bar1 info = " << "32-bit, Prefetchable: " << ((m_devInfo.bar1_add & 8) ? "Yes" : "No") << std::endl;
					std::cout << std::setw(20) << "bar1_add = " << std::hex << std::showbase << (m_devInfo.bar1_add & 0xFFFFFFF0) << std::endl;
					std::cout << std::setw(20) << "bar1_size = " << m_devInfo.bar1_size << std::endl;
				}
			}

			if (m_devInfo.num_bar > 2) {

				std::cout << std::setw(20) << "BAR2 info = " << ((m_devInfo.bar2_add & 6) ? "64-bit" : "32-bit") << ", Prefetchable: " << ((m_devInfo.bar2_add & 8) ? "Yes" : "No") << std::endl;

				if ((m_devInfo.bar2_add & 6) == 4) { // a 64-bit BAR, which also consumes BAR3
					std::cout << std::setw(20) << "bar2_add = " << "0x" << std::hex << std::noshowbase << std::setw(8) << std::setfill('0') << m_devInfo.bar3_add
						<< ":" << std::setw(8) << (m_devInfo.bar2_add & 0xFFFFFFF0) << std::endl << std::setfill(' ');
					std::cout << std::setw(20) << "bar2_size = " << std::showbase << m_devInfo.bar2_size << std::endl;
				}
				else {  // 32-bit BAR, BAR3 is independent

					std::cout << std::setw(20) << "bar2_add = " << std::hex << std::showbase << (m_devInfo.bar2_add & 0xFFFFFFF0) << std::endl;
					std::cout << std::setw(20) << "bar2_size = " << m_devInfo.bar2_size << std::endl;

					if (m_devInfo.num_bar > 3) {
						std::cout << std::setw(20) << "bar3 info = " << "32-bit, Prefetchable: " << ((m_devInfo.bar3_add & 8) ? "Yes" : "No") << std::endl;
						std::cout << std::setw(20) << "bar3_add = " << std::hex << std::showbase << (m_devInfo.bar3_add & 0xFFFFFFF0) << std::endl;
						std::cout << std::setw(20) << "bar3_size = " << m_devInfo.bar3_size << std::endl;
					}
				}
			}
			std::cout.flags(old_flags);
			std::cout << std::dec;
		}

		bool WriteDMA(std::vector<ULONG>& buffer, ULONG offset, ULONG baseAddress)
		{
			return WriteDMA(buffer.data(), buffer.size(), offset, baseAddress);

		}
		bool WriteDMA(ULONG* buffer, ULONG NumberOfItems, ULONG offset, ULONG baseAddress)
		{
			return m_mpci.WriteDMA(buffer, NumberOfItems, offset, baseAddress);

		}
		bool ReadDMA(std::vector<ULONG>& buffer, ULONG offset, ULONG baseAddress)
		{
			return ReadDMA(buffer.data(), buffer.size(), offset, baseAddress);

		}
		bool ReadDMA(ULONG* buffer, ULONG NumberOfItems, ULONG offset, ULONG baseAddress)
		{
			return m_mpci.ReadDMA(buffer, NumberOfItems, offset, baseAddress);
		}

		// read/write
		bool ReadDirect(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
		{
			return m_mpci.ReadDirect(buffer, numberOfItems, offset, baseAddress);

		}

		bool ReadDirect(std::vector<ULONG>& buffer, ULONG offset, ULONG baseAddress)
		{
			return ReadDirect(buffer.data(), buffer.size(), offset, baseAddress);
		}

		bool WriteDirect(ULONG* buffer, ULONG numberOfItems, ULONG offset, ULONG baseAddress)
		{
			return m_mpci.WriteDirect(buffer, numberOfItems, offset, baseAddress);
		}

		bool WriteDirect(std::vector<ULONG>& buffer, ULONG offset, ULONG baseAddress)
		{
			return WriteDirect(buffer.data(), buffer.size(), offset, baseAddress);
		}

	private:

		struct device_info m_devInfo;
		bool m_deviceFound = false;
		mpci m_mpci;
	};
}
