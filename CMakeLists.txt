cmake_minimum_required(VERSION 3.16)

# Target Names
set(ENGINE Selene)
set(TESTBED Testbed)

project(ENGINE)

find_package(Vulkan)

if(UNIX AND NOT APPLE)
  set(LINUX TRUE)
endif()

# Debug flag
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")

if(WIN32)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVK_USE_PLATFORM_WIN32_KHR -DUNICODE -DSLN_EXPORT -D_DEBUG")
elseif(APPLE)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVK_USE_PLATFORM_MACOS_MVK -DVK_EXAMPLE_XCODE_GENERATED")
elseif(LINUX)
  find_package(Threads REQUIRED)
endif()

# Set preprocessor defines
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DNOMINMAX -D_USE_MATH_DEFINES")

# Clang specific
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-switch-enum")

# Apple Clang specific
if(APPLE)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-arc -ObjC")
endif()

add_definitions(-D_CRT_SECURE_NO_WARNINGS)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(WIN32)
	# Nothing here (yet)
elseif(APPLE)
	link_libraries(Vulkan::Vulkan "-framework AppKit" "-framework QuartzCore")
elseif(LINUX)
	link_libraries(Vulkan::Vulkan ${XCB_LIBRARIES})
endif()

add_subdirectory(Engine)
add_subdirectory(Testbed)