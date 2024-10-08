#include <iostream>
#include <numeric>
#include <chrono>
#include <cstdlib>
#include <cmath>

#include "pf_SDK.hpp"

#include <time.h>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <boost/program_options.hpp>

//using namespace std;
using namespace SDSP;

void TestDMAMemory(SDSP::PolarFireSDK& pfsdk, uint32_t baseAddress, ULONG numberOfItems, int offset)
{
	{ // test DDR4 read/write
		std::vector<ULONG> write_buffer(numberOfItems);
		// for testing use random initial value
		int random = rand();
		std::iota(write_buffer.begin(), write_buffer.end(), random);

		pfsdk.WriteDMA(write_buffer, offset, baseAddress);

		// create read buffer
		std::vector<ULONG> read_buffer(numberOfItems);

		pfsdk.ReadDMA(read_buffer, offset, baseAddress);

		// print read buffer
		bool errorDetected = false;
		for (int i = 0; i < numberOfItems; i++)
		{
			if (write_buffer[i] != read_buffer[i])
			{
				errorDetected = true;
				std::cout << "error: at" << i << " write=" << write_buffer[i] << " read=" << read_buffer[i] << std::endl;
				break;
			}
		}
		if (errorDetected)
		{
			std::cout << "Error Detected" << std::endl;
		}
		else
		{
			std::cout << "No Error Detected" << std::endl;
		}
	}
}
void TestLSRAM(SDSP::PolarFireSDK& pfsdk, int dma_size, int offset)
{
	TestDMAMemory(pfsdk, PFBASE_MEMTEST_LSRAM, dma_size / sizeof(ULONG), offset);
}

void TestDDR(SDSP::PolarFireSDK& pfsdk, int dma_size, int offset)
{
	TestDMAMemory(pfsdk, PFBASE_MEMTEST_DDR4, dma_size / sizeof(ULONG), offset);
}


void SpeedTest(SDSP::PolarFireSDK& pfsdk, uint32_t  baseAddress, int nWords, int nReps, int offset)
{

	clock_t          timeStart;
	double           fTimeElapsed;
	std::vector<ULONG> speed_buffer(nWords);

	for (int i = 0; i < speed_buffer.size(); i++)
	{
		// for testing just create a buffer with incremental values
		speed_buffer[i] = i;
	}

	std::cout << "Speed Test: writing " << (nWords * 4) << " bytes " << nReps << " times." << std::endl;

	timeStart = clock();

	for (int rep = 0; rep < nReps; rep++)
		pfsdk.WriteDMA(speed_buffer, 0, baseAddress);

	fTimeElapsed = (clock() - timeStart) / (double)CLOCKS_PER_SEC;

	std::cout << "   Took " << fTimeElapsed << " seconds = " << ((nWords * sizeof(ULONG) * nReps) / fTimeElapsed / (1 << 20))
		<< " MB/s." << std::endl;

	std::cout << "\treading " << (nWords * 4) << " bytes " << nReps << " times." << std::endl;

	timeStart = clock();

	for (int rep = 0; rep < nReps; rep++)
		pfsdk.ReadDMA(speed_buffer, offset, baseAddress);

	fTimeElapsed = (clock() - timeStart) / (double)CLOCKS_PER_SEC;

	std::cout << "   Took " << fTimeElapsed << " seconds = " << ((nWords * sizeof(ULONG) * nReps) / fTimeElapsed / (1 << 20))
		<< " MB/s." << std::endl;

}

namespace po = boost::program_options;

struct ProgramOptions
{
	int ddr4;
	int lsram;
	int dma_size_code; // this is code (1,2,3,4) which is getting from user on command line
	int dma_size;      // this is actual size which is calculated from user input
	int offset;
};

int main(int argc, char** argv)
{
	std::string version = "1.0";
	ProgramOptions programOptions;

	std::cout << "Program started (V2.0): use -h to get help" << std::endl;
	std::cout << "size of ulong " << sizeof(ULONG) << std::endl;



	SDSP::PolarFireSDK pfsdk;

	if (!pfsdk.Init())
	{
		std::cout << "can not init Polarfire SDK" << std::endl;
		return -1;
	}
	po::options_description desc("Allowed options");
	desc.add_options()
		("help,h", "Produce help message")
		("dd4,d", po::value<int>(&programOptions.ddr4)->default_value(1), "Number of DDR4 read/write")
		("LSRAM,l", po::value<int>(&programOptions.lsram)->default_value(1), "Number of LSRAM read/write")
		("dma_size_code,c", po::value<int>(&programOptions.dma_size_code)->default_value(2), "DMA size (0=1k, 1=2k, 2=4k, 3=8k, 4=16k, 5=32k, 6=64k)")
		("offset", po::value<int>(&programOptions.offset)->default_value(0), "offset of DDR4/LSRAM for testing")
		;
	po::variables_map vm;
	try {

		po::store(po::parse_command_line(argc, argv, desc), vm);
		po::notify(vm);
	}
	catch (const std::exception& ex)
	{
		std::cerr << ex.what();
		std::cerr << "\n----------------------\n" << "usage:" << std::endl;
		std::cerr << desc << "\n";
		return -1;

	}

	if (vm.count("help") || vm.count("h")) {
		std::cout << desc << "\n";
		return 1;
	}
	programOptions.dma_size = 1024 * std::pow(2, programOptions.dma_size_code);


	std::filesystem::path dataDir = std::filesystem::current_path() / "data";
	std::filesystem::create_directories(dataDir);



	// Get the current time
	std::time_t currentTime = std::time(nullptr);

	// Convert the time to a string
	std::stringstream ss;
	ss << std::put_time(std::localtime(&currentTime), "%Y-%m-%d %H:%M:%S");

	// write current time
	std::cout << "Current time: " << ss.str() << std::endl;
	std::cout << "program options (version " << version << "): " << std::endl;
	std::cout << "DDR4 test iteration: " << programOptions.ddr4 << std::endl;
	std::cout << "LSRAM test iteration: " << programOptions.lsram << std::endl;
	std::cout << "DMA size code: " << programOptions.dma_size_code << std::endl;
	std::cout << "DMA size: " << programOptions.dma_size << "(" << programOptions.dma_size / 1024 << "k)" << std::endl;
	std::cout << "offset: " << programOptions.offset << std::endl;

	pfsdk.PrintDeviceInfo();

	for (int i = 0; i < programOptions.lsram; i++)
	{
		// test LSRAM DMA
		std::cout << "Test LSRAM DMA " << i << " : ";
		TestLSRAM(pfsdk, programOptions.dma_size, programOptions.offset);
	}

	for (int i = 0; i < programOptions.ddr4; i++)
	{
		// test DDR4 DMA
		std::cout << "Test DDR4 DMA " << i << " : ";
		TestDDR(pfsdk, programOptions.dma_size, programOptions.offset);
	}


	int repeat_base = 1000;
	// Speed tests of LSRAM and DDRR
	std::cout << "Speed tests for LSRAM" << std::endl;
	SpeedTest(pfsdk, PFBASE_MEMTEST_LSRAM, 1024, repeat_base, programOptions.offset);

	std::cout << "\nSpeed test for DDR4" << std::endl;
	SpeedTest(pfsdk, PFBASE_MEMTEST_DDR4, 1024, repeat_base, programOptions.offset);

	return 0;
}
