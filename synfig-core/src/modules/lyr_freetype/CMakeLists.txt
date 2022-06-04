add_library(lyr_freetype MODULE
        "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/lyr_freetype.cpp"
)

if(FONT_CONFIG_FOUND)
  add_definitions(-DWITH_FONTCONFIG)
endif()

if (HARFBUZZ_FOUND)
	target_compile_definitions(lyr_freetype PUBLIC -DHAVE_HARFBUZZ=1)
endif()

target_include_directories(lyr_freetype PRIVATE ${FT_INCLUDE_DIRS} ${FONT_CONFIG_INCLUDE_DIRS} ${HARFBUZZ_INCLUDE_DIRS} ${FRIBIDI_INCLUDE_DIRS})
target_link_libraries(lyr_freetype synfig ${FT_LINK_LIBRARIES} ${FONT_CONFIG_LINK_LIBRARIES} ${HARFBUZZ_LINK_LIBRARIES} ${FRIBIDI_LINK_LIBRARIES})

if (FRIBIDI_STATIC_LIBRARIES)
  target_compile_definitions(lyr_freetype PRIVATE -DFRIBIDI_LIB_STATIC)
endif()

install (
    TARGETS lyr_freetype
    DESTINATION lib/synfig/modules
)
