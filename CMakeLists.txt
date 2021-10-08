cmake_minimum_required(VERSION 3.16)

# Target Names
set(ENGINE Selene)
set(TESTBED Testbed)
set(TESTS Tests)

project(ENGINE)

find_package(Vulkan)

if(UNIX AND NOT APPLE)
	set(LINUX true)
	find_package(X11)
endif()

# Debug flag
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -MD -Werror=vla -fdeclspec")

if(WIN32)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUNICODE")
elseif(APPLE)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
elseif(LINUX)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  	find_package(Threads REQUIRED)
endif()

# Set preprocessor defines
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DNOMINMAX -D_USE_MATH_DEFINES")

# Clang specific
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-switch-enum")

# Apple Clang specific
if(APPLE)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ObjC")
endif()

add_definitions(-D_CRT_SECURE_NO_WARNINGS)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(WIN32)
	link_libraries(Vulkan::Vulkan)
elseif(APPLE)
	link_libraries(Vulkan::Vulkan "-framework AppKit" "-framework QuartzCore")
elseif(LINUX)
	link_libraries(Vulkan::Vulkan X11::xcb X11::X11_xcb)
endif()

add_subdirectory(Engine)
add_subdirectory(Testbed)
add_subdirectory(Tests)