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

bool valid_letter(char c)
{
    if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <='f'))
        return true;
    else
        return false;
}

void gen_hexdump(const string &hex_str, const string &fname)
{
    assert(!hex_str.empty());
    assert(!fname.empty());

    ofstream ofs(fname.c_str());
    if (!ofs.is_open()) {
        cout << "Error: failed to open file " << fname << endl;
        return;
    }

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

    ofs.close();
}

uint32_t read_hex_str(const string &fname, string &hex_str)
{
    ifstream ifs(fname.c_str());
    if (!ifs.is_open())
    {
        cout << "Unable to open file";
        return 0;
    }

    string line;
    while (getline(ifs, line))
        hex_str += (line + '\n');
    ifs.close();

    return hex_str.length();
}

int main(int argc, char **argv)
{
    string hex_str;
    string in_file;
    string out_file;
    int c;
    while ((c = getopt (argc, argv, "i:o:s:")) != -1) {
        switch (c)
        {
            case 's':
                hex_str = optarg;
                break;
            case 'i':
                in_file = optarg;
                break;
            case 'o':
                out_file = optarg;
                break;
            default:
                cout << "Usage: " << argv[0] << " [-i input_file] [-o out_file] [-s hex_str]" <<endl;
                abort();
        }
    }

    if (!in_file.empty())
        read_hex_str(in_file, hex_str);

    gen_hexdump(hex_str, out_file);

    return 0;
}
