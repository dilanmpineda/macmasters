#include <winsock2.h>
#include <windows.h>
#include <stdio.h>

static HANDLE iocp;

static DWORD WINAPI worker(void *arg)
{
    DWORD bytes = 0;
    ULONG_PTR key = 0;
    OVERLAPPED *ov = NULL;
    BOOL ok = GetQueuedCompletionStatus(iocp, &bytes, &key, &ov, INFINITE);
    printf("worker: GQCS ok=%d err=%lu\n", ok, ok ? 0 : GetLastError());
    return 0;
}

int main(void)
{
    WSADATA wsa;
    SOCKET listener, client, server;
    struct sockaddr_in addr = {0};
    int len = sizeof(addr);
    char buf[512];
    WSABUF wbuf = { sizeof(buf), buf };
    DWORD flags = 0, recvd = 0;
    OVERLAPPED ov = {0};
    HANDLE thread;

    WSAStartup(MAKEWORD(2, 2), &wsa);
    listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    bind(listener, (struct sockaddr *)&addr, sizeof(addr));
    getsockname(listener, (struct sockaddr *)&addr, &len);
    listen(listener, 1);

    client = WSASocketW(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, WSA_FLAG_OVERLAPPED);
    connect(client, (struct sockaddr *)&addr, sizeof(addr));
    server = accept(listener, NULL, NULL);

    iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 0);
    CreateIoCompletionPort((HANDLE)client, iocp, 0x1234, 0);
    WSARecv(client, &wbuf, 1, &recvd, &flags, &ov, NULL); /* pending: 997 */

    thread = CreateThread(NULL, 0, worker, NULL, 0, NULL);
    Sleep(500);
    closesocket(client);
    WaitForSingleObject(thread, 5000);

    closesocket(server);
    closesocket(listener);
    return 0;
}
