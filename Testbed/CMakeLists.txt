file(GLOB_RECURSE HEADERS "src/*.h")
file(GLOB_RECURSE SOURCES "src/*.c")

add_executable(${TESTBED} ${HEADERS} ${SOURCES})
target_link_libraries(${TESTBED} ${ENGINE})