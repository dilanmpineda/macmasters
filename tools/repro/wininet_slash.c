/* Repro: InternetOpenUrlW with a path starting with "//". Prints the HTTP
 * status; builtin wininet in CrossOver 26.3 sends a trailing '/' and gets 404. */
#include <windows.h>
#include <wininet.h>
#include <stdio.h>

int main(void)
{
    static const WCHAR url[] = L"https://ladmo-image.gameking.com//A8D2778BF7C497C6DDB06259063B66C0F5E20F37AEF85342B3239F6D8BFFBF5A.bin";
    HINTERNET inet, req;
    DWORD status = 0, size = sizeof(status), total = 0, got;
    char buf[65536];

    inet = InternetOpenW(L"file_download", INTERNET_OPEN_TYPE_PRECONFIG, NULL, NULL, 0);
    req = InternetOpenUrlW(inet, url, NULL, 0, INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE, 0);
    if (!req) {
        printf("InternetOpenUrlW failed: %lu\n", GetLastError());
        return 1;
    }
    HttpQueryInfoW(req, HTTP_QUERY_STATUS_CODE | HTTP_QUERY_FLAG_NUMBER, &status, &size, NULL);
    while (InternetReadFile(req, buf, sizeof(buf), &got) && got)
        total += got;
    printf("HTTP %lu, %lu bytes (expected 200, 2940909)\n", status, total);
    InternetCloseHandle(req);
    InternetCloseHandle(inet);
    return status == 200 ? 0 : 2;
}
