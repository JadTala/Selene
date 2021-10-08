file(GLOB_RECURSE HEADERS "src/*.h")
file(GLOB_RECURSE SOURCES "src/*.c")

add_executable(${TESTBED} ${HEADERS} ${SOURCES})
add_definitions(-DSLN_EXPORT)
target_link_libraries(${TESTBED} ${ENGINE})

file(GLOB_RECURSE GLSL_FRAG
    "../Assets/Shaders/*.frag.glsl"
)

file(GLOB_RECURSE GLSL_VERT
    "../Assets/Shaders/*.vert.glsl"
)

foreach(GLSL ${GLSL_FRAG})
  get_filename_component(FILE_NAME ${GLSL} NAME)
  set(SPIRV "${PROJECT_BINARY_DIR}/Assets/Shaders/${FILE_NAME}.spv")
  string(REPLACE ".glsl" "" SPIRV "${SPIRV}")
  add_custom_command(
    OUTPUT ${SPIRV}
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/Assets/Shaders/"
    COMMAND glslc -fshader-stage=frag ${GLSL} -o ${SPIRV}
    DEPENDS ${GLSL})
  list(APPEND SPIRV_BINARY_FILES ${SPIRV})
endforeach(GLSL)

foreach(GLSL ${GLSL_VERT})
  get_filename_component(FILE_NAME ${GLSL} NAME)
  set(SPIRV "${PROJECT_BINARY_DIR}/Assets/Shaders/${FILE_NAME}.spv")
  string(REPLACE ".glsl" "" SPIRV "${SPIRV}")
  add_custom_command(
    OUTPUT ${SPIRV}
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BINARY_DIR}/Assets/Shaders/"
    COMMAND glslc -fshader-stage=vert ${GLSL} -o ${SPIRV}
    DEPENDS ${GLSL})
  list(APPEND SPIRV_BINARY_FILES ${SPIRV})
endforeach(GLSL)

add_custom_target(
    Shaders 
    DEPENDS ${SPIRV_BINARY_FILES}
)

add_dependencies(${TESTBED} Shaders)

add_custom_command(TARGET ${TESTBED} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${TESTBED}>/Assets/Shaders/"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${PROJECT_BINARY_DIR}/Assets/Shaders"
        "$<TARGET_FILE_DIR:${TESTBED}>/Assets/Shaders"
)