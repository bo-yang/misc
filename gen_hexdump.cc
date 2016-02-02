/*
Generate Wireshark-understandable hexdump based on input hex string.

For example, hex string

c2ef0a00 00918843 e138a72b 08004500 003cd373 40004006 58ac0202 020a0a00
0091aae6 0016b446 7f860000 0000a002 39082c11 00000204 05b40402 080acf40
26400000 00000103 0307

will be formated into:

000000 c2 ef 0a 00 00 91 88 43  e1 38 a7 2b 08 00 45 00
000010 00 3c d3 73 40 00 40 06  58 ac 02 02 02 0a 0a 00
000020 00 91 aa e6 00 16 b4 46  7f 86 00 00 00 00 a0 02
000030 39 08 2c 11 00 00 02 04  05 b4 04 02 08 0a cf 40
000040 26 40 00 00 00 00 01 03  03 07

The formated file can be analyzed by Wireshark using "File->Import from Hex Dump" dialog box.

Reference:
    - https://www.wireshark.org/docs/wsug_html_chunked/ChIOImportSection.html
    - http://www.bo-yang.net/network/c/c++/click/2016/01/26/gen-hex-dump/

Usage:
    gen_hexdump [-i input_file] [-n] [-s hex_str] -o out_file

Examples:
1. format a single hex string:
    gen_hexdump -o <output> -s <hex_string>

2. format a single packet in a file:
    gen_hexdump -n -i <input> -o <output>

3. format multiple packets from a file(one packet per line):
    gen_hexdump -i <input> -o <output>

Copyright(c) 2016 by Bo Yang(bonny95@gmail.com).
*/

#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>
#include <cstdlib>
#include <cctype>
#include <cstdio>
#include <cassert>
using namespace std;

static inline string trim(string& str)
{
    size_t first = str.find_first_not_of(' ');
    size_t last = str.find_last_not_of(' ');
    return str.substr(first, (last-first+1));
}

bool valid_letter(char c)
{
    if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <='f'))
        return true;
    else
        return false;
}

/*
 * Remove contents before '|'.
 * Example:
 *
 * chatter: nat_gw_ingress_print:   66 | 00fec82d de788843 e138a72b 08004500 00340000 40004006 2c3d0202 020a0a00 007c0016 d0a9888e 807279f1 171a8012 3908bca5 00000204 05b40101 04020103 0307
 */
void preprocess_hex_str(string &line)
{
    size_t start = line.find('|');
    if (start != std::string::npos)
        line = line.substr(start+1);
    line = trim(line);
}

void gen_hexdump(string &hex_str, ofstream &ofs)
{
    assert(!hex_str.empty());

    preprocess_hex_str(hex_str);
    
    char c, buf[16];
    uint32_t ridx = 0, cidx = 0;
    uint32_t last_space = cidx;
    uint8_t num_hex = 0;
    string line;

    snprintf(buf, sizeof(buf), "%06x ", ridx);
    line.append(buf);
    cidx = line.length();
    last_space = cidx - 1;
    for (int i = 0; i < hex_str.length(); ++i) {
        c = tolower(hex_str[i]);
        if (valid_letter(c)) {
            line.append(1, c);
            cidx++;
        } else {
            continue;
        }

        if (cidx - last_space > 2) {
            num_hex++;
            if (num_hex == 8) {
                // add additional space in the middle of line
                line.append(1, ' ');
                cidx++;
            }

            if (num_hex != 16) {
                line.append(1, ' ');
                last_space = cidx;
                cidx++;
            }
        }

        if (num_hex == 16) {
            ofs << line << endl; // write to file

            ridx += num_hex;
            num_hex = 0;
            line.clear();
            snprintf(buf, sizeof(buf), "%06x ", ridx);
            line.append(buf);
            cidx = line.length();
            last_space = cidx - 1;
        }
    }
    if (num_hex || (cidx - last_space > 1))
        ofs << line << endl; // write the last line
}

uint32_t read_hex_str(const string &fname, string &hex_str)
{
    ifstream ifs(fname.c_str());
    if (!ifs.is_open())
    {
        cout << "Unable to open file" << fname << endl;
        return 0;
    }

    string line;
    while (getline(ifs, line))
        hex_str += (line + '\n');
    ifs.close();

    return hex_str.length();
}

bool read_hex_gen_dump(const string &fin, ofstream &ofs)
{
    ifstream ifs(fin.c_str());
    if (!ifs.is_open())
    {
        cout << "Unable to open file" << fin << endl;
        return false;
    }

    string line;
    while (getline(ifs, line)) {
        // Suppose each line is a packet
        if (!line.empty())
            gen_hexdump(line, ofs);
    }
    ifs.close();

    return true;
}

int main(int argc, char **argv)
{
    string hex_str;
    string in_file;
    string out_file;
    bool mult_pkts = true;
    int c;
    while ((c = getopt (argc, argv, "i:o:s:n")) != -1) {
        switch (c)
        {
            case 's':
                hex_str = optarg;
                mult_pkts = false;
                break;
            case 'i':
                in_file = optarg;
                break;
            case 'o':
                out_file = optarg;
                break;
            case 'n':
                mult_pkts = false;
                break;
            default:
                cout << "Usage: " << argv[0] << " [-i input_file] [-n] [-s hex_str] -o out_file" <<endl;
                abort();
        }
    }

    assert(!out_file.empty());
    ofstream ofs(out_file.c_str());
    if (!ofs.is_open()) {
        cout << "Error: failed to create file " << out_file << endl;
        return 1;
    }

    if ( (!mult_pkts) && (!in_file.empty()) ) {
        // Single packet in multiple lines
        read_hex_str(in_file, hex_str);
        gen_hexdump(hex_str, ofs);
        ofs.close();
        return 0;
    }

    if (!in_file.empty()) {
        read_hex_gen_dump(in_file, ofs);
    } else {
        gen_hexdump(hex_str, ofs);
    }
    ofs.close();

    return 0;
}
