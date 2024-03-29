/* --------------------------------------------------------------------------------
-- Company:        apertus° Association
-- Engineer:       Abd-ElRhman Sobhy
-- 
-- Create Date:    28/6/2019 
-- Design Name:    seed Generation 
-- Module Name:      
-- Target Devices: Zynq-7000  xc7z020clg400-1
-- Tool versions:  xilinx vivado
-- Description:    seed generation for the PRNG to check the logest path before it loops again
--				   also checks for the internal substrings that may result for a reset value"00000000"
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation, either version
-- 3 of the License, or (at your option) any later version.
----------------------------------------------------------------------------------*/


#include <iostream>
#include <string>
#include <vector>
#include <set>

using namespace std;

void main() {

	string seed = "11100111";
	int Size = 8;
	char a = '0';
	bool loopDetect = false;
	int iterate = 1;
	vector<string> generatedBytes;
	set<string> checkLoop;
	checkLoop.insert(seed);
	generatedBytes.push_back(seed);

	while (!loopDetect) {
		int bit0 = (int)seed[7] - a;
		int bit2 = (int)seed[5] - a;
		int bit3 = (int)seed[4] - a;
		int bit5 = (int)seed[2] - a;


		int feed =  (((bit0 ^ bit2) ^ bit3) ^ bit5);

		seed = to_string(feed) + seed.substr(0, Size -1);
		if (iterate % Size == 0) {
			if (checkLoop.find(seed) != checkLoop.end()) { // found loop
				loopDetect = true;
				cout << "collision byte :" << seed << endl;
			}
			else { // insert the new byte
				checkLoop.insert(seed);
				generatedBytes.push_back(seed);
			}

		}
		iterate++;

	}
	cout << "length " << generatedBytes.size()<<endl;
	 
	if (checkLoop.find("00000000") != checkLoop.end()) {
		cout << "found reset";
		for (int i = 0; i < generatedBytes.size(); i++) {
			if (generatedBytes[i] == "00000000"){
				cout << "index = " << i << endl;
				break;
			}
		}
	}
	else cout << "free of ZEROs" << endl;

}