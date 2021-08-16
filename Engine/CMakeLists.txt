file(GLOB_RECURSE HEADERS "src/*.h")
if(APPLE)
  file(GLOB_RECURSE SOURCES "src/*.c" "src/*.m")
else()
  file(GLOB_RECURSE SOURCES "src/*.c")
endif()

add_library(${ENGINE} STATIC ${HEADERS} ${SOURCES})
target_include_directories(${ENGINE} PUBLIC src)