#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <iostream>
#include <chrono>
#include <cstdlib>

using namespace std;
 
int dir_empty_c(const char *path)
{
	struct dirent *ent;
	int ret = 1;
 
	DIR *d = opendir(path);
	if (!d) {
		fprintf(stderr, "%s: ", path);
		perror("");
		return -1;
	}
 
	while ((ent = readdir(d))) {
		if (!strcmp(ent->d_name, ".") || !(strcmp(ent->d_name, "..")))
			continue;
		ret = 0;
		break;
	}
 
	closedir(d);
	return ret;
}

int dir_empty_shell(const char *path)
{
    char buf[512];
    snprintf(buf, sizeof(buf), "test -n \"$(ls -A %s)\"", path);
    int status = system(buf);
    int exitcode = WEXITSTATUS(status);
    return (exitcode == 1);
}

void test_dir_empty(int (*cb)(const char *path), const char *path)
{
    auto start = chrono::steady_clock::now();

    auto ret = cb(path);
    if (ret >= 0)
			printf("%s: %sempty\n", path, ret ? "" : "not ");

    auto end = chrono::steady_clock::now();
    std::cout << "Elapsed time " << chrono::duration_cast<chrono::microseconds>(end-start).count()
        << " us" << std::endl;
}
 
int main(int c, char **v)
{
	if (c < 2) return -1;

	for (int i = 1; i < c; i++) {
		test_dir_empty(dir_empty_c, v[i]);
        test_dir_empty(dir_empty_shell, v[i]);
	}
 
	return 0;
}
