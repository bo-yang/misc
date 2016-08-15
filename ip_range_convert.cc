#include <iostream>
#include <stdio.h>
#include <cmath>
#include <string>
#include <arpa/inet.h>

// ip_range_convert.cc - approximate IP range with IP address and netmasks

using std::string;
using std::cout;
using std::endl;

#define PRINT_IP(x) \
    ((x) >> 24) & 0xff, \
    ((x) >> 16) & 0xff, \
    ((x) >>  8) & 0xff, \
    (x) & 0xff

string ip_unparse(uint32_t ip)
{
    char ipstr[16];
    snprintf(ipstr, sizeof(ipstr), "%d.%d.%d.%d", PRINT_IP(ip));
    return string(ipstr);
}

uint32_t ip_to_uint32(uint8_t *ip)
{
    return ((ip[0] << 24) | (ip[1] << 16) |
            (ip[2] << 8) | ip[3]);
}

string convert_ip_range(int ip_start, int ip_end, bool include_end = true)
{
    uint32_t start = ip_start;
    uint32_t end = ip_end;
    if (end < start) {
        // swap start ip and end ip
        uint32_t tmp = start;
        start = end;
        end = tmp;
    }

    string rule;
    rule = "(";
    int cnt = 0;
    while (start < end) { // check cnt to make sure it never loop forever
        uint32_t expo = (uint32_t)log2((double)(end - start));
        uint32_t netmask = 0xFFFFFFFFU << expo;
        uint32_t new_end = start | ~netmask;
        if (cnt > 0)
            rule += " or ";
        rule += ip_unparse(start) + "/" + std::to_string(32 - expo);

        start = new_end + 1;
        cnt++;
    }
    if (include_end)
        rule += " or " + ip_unparse(end) + "/32";

    rule += ")";

    return rule;
}


int main()
{
    uint8_t ip_start[4] = {192, 168, 0, 100};
    uint8_t ip_end[4] = {192, 168, 2, 200};
    uint32_t ip_start_int = ip_to_uint32(ip_start);
    uint32_t ip_end_int = ip_to_uint32(ip_end);

    cout << "IP range: " << ip_unparse(ip_start_int) << " - " << ip_unparse(ip_end_int) << endl;
    cout << "IP/netmask: " << convert_ip_range(ip_start_int, ip_end_int) << endl;
}
