file(GLOB_RECURSE HEADERS "src/*.h")
file(GLOB_RECURSE SOURCES "src/*.c")

add_executable(${TESTBED} ${HEADERS} ${SOURCES})
add_definitions(-DSLN_EXPORT)
target_link_libraries(${TESTBED} ${ENGINE})