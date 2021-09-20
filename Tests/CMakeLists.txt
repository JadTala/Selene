file(GLOB_RECURSE HEADERS "src/*.h")
file(GLOB_RECURSE SOURCES "src/*.c")

add_executable(${TESTS} ${HEADERS} ${SOURCES})
add_definitions(-DSLN_IMPORT)
target_link_libraries(${TESTS} ${ENGINE})