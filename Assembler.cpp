#define _CRT_SECURE_NO_WARNINGS 1
#include <vector>
#include <map>
#include <set>
#include <bitset>
#include <algorithm>
#include <numeric>
#include <unordered_map>
#include <sstream>
#include <iostream>
#include <cmath>
#include<cstring>
#include <cstdio>
#include <stack>
#include<iomanip>
#include<queue>
#include<functional>
#include<iterator>
#include<new>
#include<cstdlib>
#include<math.h>
#include<fstream>
using namespace std;
#define pi 3.141592653589793
#define ii  pair<int,int>
#define ll long long
#define p10(ans) printf("%0.10f\n", ans)
#define pr(ans) printf("%d\n", ans)
#define scc(x)  scanf("%c\n", &c)
#define pll(ans) printf("%lld\n", ans)
#define scll(x) scanf("%lld",&x)
#define scd(a)  scanf("%lf", &a)
#define sci(x)  scanf("%d",&x)
#define pc(ans)  printf("%c", ans)
#define pd(a)    printf("%lf\n", a)
#define scanfchararray(arr) scanf("%s", arr)
#define printfstring(s)    printf("%s\n", s.c_str())
#define all(v)             v.begin(),v.end()
#define rall(v) v.rbegin(),v.rend()
#define sz(v)            ((int)((v).size()))
#define mod 1000000007
#define mem(arr,d) memset(arr,d,sizeof(arr))
#define inf 10000000000000000
#define ninf -10000000000000000;
#define eps 1e-7
#define nearestPowerOfTwo(S) ((int)pow(2.0, (int)((log((double)S) / log(2.0)) + 0.5)))


// assumption : lazem el label ykon fe satr lw7do 
// assumption : el no2ten ely fo2 b3d bto3 el label ykono laz2en feh 
 
struct instruction
{
	int operand_type,location_in_ram;
	string operation,first_operand, second_operand, label;
	instruction() {};
	instruction(int ot, string op,string fo, string so, string l,int loc) :operand_type(ot), operation(op),first_operand(fo), second_operand(so), label(l),location_in_ram(loc){};
};
enum addressing_modes{registerr,auto_increment,auto_decrement,index};
const int N = 10e5 + 10;
map<string, int>labels;
int ram_counter = 0;
int instruction_address[N];  // bt3br 3n hwa geh emta fel code ya3ni 
string branching[] = { "BR","BNE","BEQ","BLO","BLS","BHI","BHS","BGE","BGT" };
map<string, string>mp;
vector<instruction>vec;
vector<pair<string,string>>out;
ofstream myfile;
string x = "XXXXXXXXXXXXXXXX";
string instruction_for_ram="";
const int MEMORY_SIZE = 2048;
const unsigned int maxint = (1<<32)-1;
string dectoHexa(int rkm)
{
	if (rkm == 0)return "0";
	string s = "";
	int i = 0;
	while (rkm != 0)
	{

		int temp = 0;
		temp = rkm % 16;
		if (temp < 10)
		{
			s += (temp + 48); //3shan el asci ygbny 0+48 3nd el 0 ka character
		}
		else
		{
			s += (temp + 87); //3shan 10+55 ygbni 3nd el a ka character
		}
		++i;
		rkm = rkm / 16;
	}
	reverse(s.begin(), s.end());
	return s;
}
void fillout() {
	
	for (int i = 0; i < MEMORY_SIZE; ++i) { 
		string s = "@";
		string hexa = dectoHexa(i);
		if (hexa.size() == 1)s = "  " + s;
		else if (hexa.size() == 2)s = " " + s;
		out.push_back({ s+hexa,x }); 
	
	
	}
}
string to_binary(unsigned int rkm) {
	stack<char>st;
	while (rkm > 0) {
		if ((rkm & 1) == 0)st.push('0');
		else st.push('1');
		(rkm >>= 1);
	}
	string binaryrkm = "";
	while (!st.empty()) { binaryrkm += st.top(); st.pop();}

	int ba2y = 32 - binaryrkm.size();
	for (int i = 0; i < ba2y; ++i)binaryrkm = "0"+binaryrkm ;
	
	return binaryrkm;
}
void fill_map() {

	// Registers
	mp["R0"] = "000";  mp["R6"] = "110";
	mp["R1"] = "001";  mp["R7"] = "111";
	mp["R2"] = "010";
	mp["R3"] = "011";
	mp["R4"] = "100";
	mp["R5"] = "101";

	// 2 operand operations 4 bits

	mp["MOV"] = "0001";
	mp["ADD"] = "0010";
	mp["ADC"] = "0011";
	mp["SUB"] = "0100";
	mp["SBC"] = "0101";
	mp["BIC"] = "0110";
	mp["BIS"] = "1001";
	mp["XOR"] = "1010";
	mp["OR"] = "1011";
	mp["AND"] = "1100";
	mp["CMP"] = "1101";

	// branching 

	mp["BR"] = "10000001", mp["BNE"] = "10000010", mp["BEQ"] = "10000011", mp["BLO"] = "10000100", mp["BLS"] = "10000101", mp["BHI"] = "10000110", mp["BHS"] = "10000111", mp["BGE"] = "10001000", mp["BGT"] = "10001001";

	// 1 operand instructions
	mp["INC"] = "0000000001", mp["DEC"] = "0000000010", mp["CLR"] = "0000000011", mp["INV"] = "0000000100", mp["LSR"] = "0000000101", mp["ROR"] = "0000000110", mp["RRC"] = "0000000111", mp["ASR"] = "0000001000", mp["LSL"] = "0000001001", mp["ROL"] = "0000001010", mp["RLC"] = "0000001011";

	// zero operand instructions
	//lsa el jumb subroutine w el return bt3tha 
	mp["HLT"] = "0000000000000000", mp["NOB"] = "0000000010100000", mp["RESET"] = "0000000000001000", mp["JSR"] = "0000000000000001", mp["RTS"] = "0000000000000010";
	// addressing modes
	mp["rr"] = "00";  mp["ai"] = "01"; mp["ad"] = "10"; mp["index"] = "11";
}
void check_two_operand(string s) {
	//hal fel index addressing mode lazem el rkm yb2a value mtnf3ch variable sa7 ? 
	int awl_space = s.find(' ');
	string operation = s.substr(0, awl_space);
	string ba2y = s.substr(awl_space + 1, s.size() - awl_space + 1);
	int comma = ba2y.find(',');
	string first_operand = ba2y.substr(0, comma);
	
	string second_operand = ba2y.substr(comma+1, ba2y.size()-comma+1);
	vec.push_back(instruction(2,operation, first_operand, second_operand, "-1",ram_counter));
	if (first_operand.find('(') != -1 && (first_operand.find('+') == -1 && first_operand.find('-') == -1)) {
		++ram_counter;
	}
	if (second_operand.find('(') != -1 && (second_operand.find('+') == -1 && second_operand.find('-') == -1)) {
		++ram_counter;
	}
}
void check_one_operand(string s) {
	int awl_space = s.find(' ');
	string operation = s.substr(0, awl_space);
	string first_operand = s.substr(awl_space + 1, s.size() - awl_space + 1);
	vec.push_back(instruction(1, operation,first_operand, "-1", "-1",ram_counter));
	if (first_operand.find('(') != -1 && (first_operand.find('+') == -1 && first_operand.find('-') == -1)) {
		++ram_counter;
	}
}
void check_branching(string s) {
	int awl_space = s.find(' ');
	string operation = s.substr(0, awl_space);
	string label = s.substr(awl_space + 1, s.size() - awl_space - 1);
	vec.push_back(instruction(-1,operation, "-1", "-1",label,ram_counter));
}
void check_JSR(string s) {
	int awl_space = s.find(' ');
	string operation = s.substr(0, awl_space);
	string label = s.substr(awl_space + 1, s.size() - awl_space - 1);
	vec.push_back(instruction(0, operation, "-1", "-1", label, ram_counter));
	ram_counter+=2;
}
void check_no_operand(string s) {
	vec.push_back(instruction(0,s, "-1", "-1", "-1",ram_counter));
}
int check_addressing_mode(string operand) {
	if (operand.find('(') != -1 && (operand.find('+') == -1 && operand.find('-') == -1))return index;
	else if (operand.find('(') != -1 && (operand.find('+') != -1 && operand.find('-') == -1))return auto_increment; 
	else if (operand.find('(') != -1 && (operand.find('+') == -1 && operand.find('-') != -1))return auto_decrement;
	else return registerr;
}
string  handle_index_mode(string operand) {
	int j; string temp = "";
	for (j = 0; j < operand.size(); ++j) {
		if (isdigit(operand[j]))temp += operand[j];
		else break;
	}
	stringstream ss(temp);
	int rkm = 0;
	ss >> rkm;
	string binary_rkm = to_binary(rkm);
	string anhy_register = "";
	anhy_register += operand[j + 1];
	anhy_register += operand[j + 2];
	instruction_for_ram += mp[anhy_register];
	//myfile << mp[anhy_register] << " ";
	return binary_rkm;
}
void handle_auto_increment_mode(string operand) {
	string anhy_register = "";
	anhy_register += operand[1];
	anhy_register += operand[2];
	instruction_for_ram += mp[anhy_register];
	//myfile << mp[anhy_register] << " ";
}
void handle_auto_decrement_mode(string operand) {
	string anhy_register = "";
	anhy_register += operand[2];
	anhy_register += operand[3];
	instruction_for_ram += mp[anhy_register];
	//myfile << mp[anhy_register] << " ";
}
int main() {
	fill_map();
	fillout();
	ifstream infile("Test2.txt");
	string line;
	while (!infile.eof())
	{
		getline(infile, line);
		if (line.size() != 0) {
			if (line[0] == '/')continue;
			if (line == "RESET")continue;
			int spacee = line.find(' '); int label = line.find(':');
			if (spacee != -1&&label==-1&& ((line.substr(0, spacee) == "POP" || line.substr(0, spacee) == "PUSH"))) {
				string s = line.substr(0, spacee);
				string rigsterr = line.substr(spacee + 1, line.size() - spacee + 1);
				if (s == "POP")line = "MOV +(R6)," + rigsterr;
				else if (s == "PUSH")line = "MOV " + rigsterr + ",-(R6)";
			}
			
			
			if (label != -1) {
				string l = line.substr(0, label);
				labels[l] = ram_counter;
			}
			else if (isdigit(line[0])) {
				int awl_space = line.find(' ');
				string address = line.substr(0, awl_space);
				string val = line.substr(awl_space + 1, line.size() - awl_space);
				stringstream ss(address);
				ll  mkan = 0;
				ss >> mkan;
				stringstream ss2(val);
				ll rkm = 0;
				ss2 >> rkm;
				if (rkm > maxint) { printf("ERRRRRRRRRRRROOOOR rkm kbeeeeeer\n"); return 0; }
				string binary_string = to_binary(rkm);
				string awl7eta = binary_string.substr(binary_string.size() - 16, 16);
				string tany7eta = binary_string.substr(0, 16);
				if (mkan > (MEMORY_SIZE - 1)) { printf("ERROOOOOOOOOOOOR mfech mkan fel raaaaaam\n"); return 0; }
				out[mkan].second = awl7eta;
				out[mkan + 1].second = tany7eta;
			}
			else {
				int comma = line.find(',');
				if (comma != -1) {   // yb2a kda 2 operand
					check_two_operand(line);
					++ram_counter;
				}
				else {
					int space = line.find(' ');
					if (space != -1) {   // ya branch ya one operand
						string operation = line.substr(0, space);
						if (operation == branching[0] || operation == branching[1] || operation == branching[2] || operation == branching[3] || operation == branching[4] || operation == branching[5] || operation == branching[6] || operation == branching[7] || operation == branching[8])
						{
							// kda yb2a branch
							check_branching(line);
							++ram_counter;

						}
						else {   // yb2a one operand
							if (line[0] == 'J'&&line[1] == 'S'&&line[2] == 'R'){check_JSR(line); //e3tbrtha hna bs one operand 3shan el space w m3aha label
                                                      
							}
							else check_one_operand(line);
							++ram_counter;
						}
					}
					else {   // no operand instruction
						
						 check_no_operand(line);
						++ram_counter;
					}

				}
			}
		}
	}

	
	myfile.open("out.txt");
	myfile << "// memory data file (do not edit the following line - required for mem load use)" << "\n";
	myfile << "// instance=/pu/RAM_LAB/MEMORY" << "\n";
	myfile << "// format=bin addressradix=h dataradix=b version=1.0 wordsperline=1"<<"\n";
		for (int i = 0; i < vec.size(); ++i) {
		instruction_for_ram = "";
		if (vec[i].operand_type == 2){
			vector<string>values_for_index_mode; //3shan el X bta3t el index mode
			int addressingmode_first_operand = check_addressing_mode(vec[i].first_operand);
			if (addressingmode_first_operand==index){  
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["index"];
				//myfile << mp[vec[i].operation] << " "<<"0"<<" "<<mp["index"]<<" ";
				string binary_rkm = handle_index_mode(vec[i].first_operand);
				values_for_index_mode .push_back(binary_rkm.substr(binary_rkm.size()-16,16));
			}
			else if (addressingmode_first_operand == auto_increment) {
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["ai"];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["ai"] << " ";
				handle_auto_increment_mode(vec[i].first_operand);
			}
			else if (addressingmode_first_operand == auto_decrement) {
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["ad"];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["ad"] << " ";
				handle_auto_decrement_mode(vec[i].first_operand);
			}
			else if (addressingmode_first_operand == registerr) {
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["rr"];
				instruction_for_ram += mp[vec[i].first_operand];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["rr"] << " ";
				//myfile << mp[vec[i].first_operand] << " ";
			}
			instruction_for_ram += "0";
			//myfile << "0" << " ";
			int addressingmode_second_operand = check_addressing_mode(vec[i].second_operand);
			if (addressingmode_second_operand == index) {
				instruction_for_ram += mp["index"];
				//myfile << mp["index"] << " ";
				string binary_rkm = handle_index_mode(vec[i].second_operand);
				values_for_index_mode.push_back(binary_rkm.substr(binary_rkm.size()-16,16));
			}
			else if (addressingmode_second_operand == auto_increment) {
				instruction_for_ram += mp["ai"];
				//myfile << mp["ai"] << " ";
				handle_auto_increment_mode(vec[i].second_operand);
			}
			else if (addressingmode_second_operand == auto_decrement) {
				instruction_for_ram += mp["ad"];
				//myfile <<mp["ad"] << " ";
				handle_auto_decrement_mode(vec[i].second_operand);
			}
			else if (addressingmode_second_operand == registerr) {
				instruction_for_ram += mp["rr"];
				instruction_for_ram += mp[vec[i].second_operand];
				//myfile << mp["rr"] << " ";
				//myfile << mp[vec[i].second_operand] << " ";
			}
			for (int k = 0; k < values_for_index_mode.size(); ++k) {
				out[vec[i].location_in_ram + k + 1].second = values_for_index_mode[k];
				//myfile <<"\n"<<values_for_index_mode[k] << "\n";
			}
		}
		else if (vec[i].operand_type == 1) {
			int addressingmode = check_addressing_mode(vec[i].first_operand);
			if (addressingmode == index) {
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["index"];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["index"] << " ";
				string binaryrkm=handle_index_mode(vec[i].first_operand);
				string ba2y = binaryrkm.substr(binaryrkm.size() - 16, 16);
				out[vec[i].location_in_ram + 1].second = ba2y;
				//myfile <<"\n"<<binaryrkm;
			}
			else if (addressingmode == auto_increment) {
				instruction_for_ram += mp[vec[i].operation];
				instruction_for_ram += "0"; instruction_for_ram += mp["ai"];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["ai"] << " ";
				handle_auto_increment_mode(vec[i].first_operand);
			}
			else if (addressingmode == auto_decrement) {
				instruction_for_ram += mp[vec[i].operation]; instruction_for_ram += "0";
				instruction_for_ram += mp["ad"];
				myfile << mp[vec[i].operation] << " " << "0" << " " << mp["ad"] << " ";
				handle_auto_decrement_mode(vec[i].first_operand);
			}
			else if (addressingmode == registerr) {
				instruction_for_ram += mp[vec[i].operation]; instruction_for_ram += "0";
				instruction_for_ram += mp["rr"]; instruction_for_ram += mp[vec[i].first_operand];
				//myfile << mp[vec[i].operation] << " " << "0" << " " << mp["rr"] << " ";
				//myfile << mp[vec[i].first_operand] << " ";
			}
			//myfile << "\n";
		}
		else if (vec[i].operand_type == 0) {

			instruction_for_ram += mp[vec[i].operation];
			if (vec[i].label != "-1") {
				string labell = vec[i].label;
				string binary_rkm = to_binary(labels[labell]);
				out[vec[i].location_in_ram + 1].second = binary_rkm.substr(binary_rkm.size() - 16, 16);
			}
			//myfile << mp[vec[i].operation] << "\n";
		}
		else if (vec[i].operand_type == -1) {  //branching ya3ni
			string labell = vec[i].label;
			bool flag = false;
			int offset = (labels[labell] - 1) - vec[i].location_in_ram;
			if (offset < 0) { flag = true; offset *= -1;}
			string binary_rkm = to_binary(offset);
			string ss= binary_rkm.substr(binary_rkm.size() - 8, 8);
			if (flag) {
				int o;
				for ( o = ss.size() - 1; o >= 0; --o) {
					if (ss[o] == '1')break;
				}
				for (int k = o - 1; k >= 0; --k) {
					if (ss[k] == '1')ss[k] = '0';
					else ss[k] = '1';
				}
			}
			if (!flag&&ss[0] == '1') { printf("lalalalalalala mynf3ch\n"); return 0; }
			instruction_for_ram += mp[vec[i].operation];
			instruction_for_ram += ss;
			//myfile << mp[vec[i].operation] << " " << binary_rkm.substr(binary_rkm.size() - 8 + 1, 8)<<"\n";
		}
		out[vec[i].location_in_ram].second=instruction_for_ram;
	}

	for (int i = 0; i < MEMORY_SIZE; ++i)myfile << out[i].first << " " << out[i].second <<"\n";

	myfile.close();


















}