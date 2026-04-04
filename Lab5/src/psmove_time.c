/**
* PS Move API - An interface for the PS Move Motion Controller
* Copyright (c) 2011, 2012 Thomas Perl <m@thp.io>
**/

#include "psmove.h"
#include "psmove_private.h"

#ifdef _WIN32
#include <windows.h>
#include <WinSock2.h>
#endif

#ifndef _MSC_VER
#include <unistd.h>
#include <sys/time.h>
#include <time.h> 
#endif

// Na macOS CLOCK_MONOTONIC jest już zdefiniowane w <time.h>
#if defined(_MSC_VER)
#define CLOCK_MONOTONIC 0
static const unsigned __int64 epoch = ((unsigned __int64)116444736000000000ULL);
#define FILE_TIME_UNITS_PER_SECOND 10000000LL
#define FILE_TIME_UNITS_PER_MICROSECOND 10LL
#endif

#ifdef _WIN32
LARGE_INTEGER g_startup_time = { .QuadPart = 0 };
LARGE_INTEGER g_frequency = { .QuadPart = 0 };
#else
long g_startup_time = 0;
#endif

#if defined(_MSC_VER)
static int gettimeofday(struct timeval * tp, struct timezone * tzp) {
    FILETIME file_time;
    ULARGE_INTEGER ularge; 
    GetSystemTimeAsFileTime(&file_time);
    ularge.LowPart = file_time.dwLowDateTime;
    ularge.HighPart = file_time.dwHighDateTime;
    ularge.QuadPart -= epoch;
    tp->tv_sec = (long)(ularge.QuadPart / FILE_TIME_UNITS_PER_SECOND);
    tp->tv_usec = (long)((ularge.QuadPart % FILE_TIME_UNITS_PER_SECOND) / FILE_TIME_UNITS_PER_MICROSECOND);
    return 0;
}

static int clock_gettime(int unused, struct timespec *ts) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    ts->tv_sec = tv.tv_sec;
    ts->tv_nsec = tv.tv_usec * 1000;
    return 0;
}
#endif

void psmove_sleep(unsigned long milliseconds) {
#ifdef _MSC_VER
    Sleep(milliseconds);
#else
    sleep(milliseconds);
#endif
}

void psmove_usleep(__int64_t usec) {
#ifdef _MSC_VER
    HANDLE timer;
    LARGE_INTEGER ft;
    ft.QuadPart = -(10 * usec);
    timer = CreateWaitableTimer(NULL, TRUE, NULL);
    SetWaitableTimer(timer, &ft, 0, NULL, NULL, 0);
    WaitForSingleObject(timer, INFINITE);
    CloseHandle(timer);
#else
    usleep(usec);
#endif
}

enum PSMove_Bool psmove_time_init() {
#ifdef _WIN32
    psmove_return_val_if_fail(QueryPerformanceFrequency(&g_frequency), PSMove_False);
    psmove_return_val_if_fail(QueryPerformanceCounter(&g_startup_time), PSMove_False);
    return PSMove_True;
#else
    struct timeval tv;
    psmove_return_val_if_fail(gettimeofday(&tv, NULL) == 0, PSMove_False);
    g_startup_time = (tv.tv_sec * 1000 + tv.tv_usec / 1000);
    return PSMove_True;
#endif
}

PSMove_timestamp psmove_timestamp() {
    struct timespec ts;
    // macOS użyje teraz swojej systemowej funkcji clock_gettime
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts;
}

PSMove_timestamp psmove_timestamp_diff(PSMove_timestamp a, PSMove_timestamp b) {
    struct timespec ts;
    if (a.tv_nsec >= b.tv_nsec) {
        ts.tv_sec = a.tv_sec - b.tv_sec;
        ts.tv_nsec = a.tv_nsec - b.tv_nsec;
    } else {
        ts.tv_sec = a.tv_sec - b.tv_sec - 1;
        ts.tv_nsec = 1000000000 + a.tv_nsec - b.tv_nsec;
    }
    return ts;
}

double psmove_timestamp_value(PSMove_timestamp ts) {
    return ts.tv_sec + ts.tv_nsec * 0.000000001;
}

long psmove_util_get_ticks() {
#ifdef _WIN32
    LARGE_INTEGER now;
    psmove_return_val_if_fail(QueryPerformanceCounter(&now), 0);
    return (long)((now.QuadPart - g_startup_time.QuadPart) * 1000 / g_frequency.QuadPart);
#else
    long now;
    struct timeval tv;
    psmove_return_val_if_fail(gettimeofday(&tv, NULL) == 0, 0);
    now = (tv.tv_sec * 1000 + tv.tv_usec / 1000);
    return (now - g_startup_time);
#endif
}