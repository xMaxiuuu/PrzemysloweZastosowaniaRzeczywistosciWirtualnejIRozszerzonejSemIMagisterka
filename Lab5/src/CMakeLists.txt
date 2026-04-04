cmake_minimum_required(VERSION 3.5)
project(PSMOVEAPI)

# WYMUSZENIE ARCHITEKTURY I STANDARDU
set(CMAKE_OSX_ARCHITECTURES "arm64")
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")

set(PSMOVEAPI_REQUIRED_LIBS)
set(PSMOVEAPI_PLATFORM_SRC)

# ŚCIEŻKI HOMEBREW (M1/M2)
include_directories(/opt/homebrew/include)
include_directories(/opt/homebrew/include/hidapi)
include_directories(/opt/homebrew/include/eigen3)
link_directories(/opt/homebrew/lib)
list(APPEND PSMOVEAPI_REQUIRED_LIBS hidapi)

# ŚCIEŻKI PROJEKTU (Naprawia błąd "psmove.h not found")
include_directories(${CMAKE_CURRENT_LIST_DIR})
include_directories(${ROOT_DIR}/include)
include_directories(${ROOT_DIR}/external/stb)

# FRAMEWORKI MAC
if(APPLE)
    find_library(FOUNDATION Foundation)
    find_library(AVFOUNDATION AVFoundation)
    find_library(IOKIT IOKit)
    find_library(COREFOUNDATION CoreFoundation)
    find_library(IOBLUETOOTH IOBluetooth)
    list(APPEND PSMOVEAPI_REQUIRED_LIBS ${FOUNDATION} ${AVFOUNDATION} ${IOKIT} ${COREFOUNDATION} ${IOBLUETOOTH})
    list(APPEND PSMOVEAPI_PLATFORM_SRC ${ROOT_DIR}/src/platform/psmove_osxsupport.m)
endif()

# WSZYSTKIE PLIKI ŹRÓDŁOWE
file(GLOB PSMOVEAPI_SRC 
    "${CMAKE_CURRENT_LIST_DIR}/*.c" 
    "${CMAKE_CURRENT_LIST_DIR}/*.cpp" 
    "${CMAKE_CURRENT_LIST_DIR}/math/*.c"
    "${CMAKE_CURRENT_LIST_DIR}/math/*.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/daemon/*.c"
)

# BUDOWANIE
add_library(psmoveapi SHARED ${PSMOVEAPI_SRC} ${PSMOVEAPI_PLATFORM_SRC})
target_link_libraries(psmoveapi ${PSMOVEAPI_REQUIRED_LIBS})

add_library(psmoveapi_static STATIC ${PSMOVEAPI_SRC} ${PSMOVEAPI_PLATFORM_SRC})
target_link_libraries(psmoveapi_static ${PSMOVEAPI_REQUIRED_LIBS})

add_executable(psmovepair ${ROOT_DIR}/src/utils/psmovepair.c)
target_link_libraries(psmovepair psmoveapi)