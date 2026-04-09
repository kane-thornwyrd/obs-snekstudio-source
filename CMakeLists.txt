cmake_minimum_required(VERSION 3.20)

project(snekstudio_obs_source_mvp VERSION 0.1.0 LANGUAGES C)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBOBS REQUIRED IMPORTED_TARGET libobs)

set(SNEKSTUDIO_PACKAGE_NAME "obs-snekstudio-source")

add_library(snekstudio-source MODULE
    src/snekstudio_source_plugin.c
)

add_library(snekstudio-publisher-draft STATIC
    drafts/snekstudio_publisher_draft.c
)

target_include_directories(snekstudio-source
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_include_directories(snekstudio-publisher-draft
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/drafts
)

target_compile_options(snekstudio-source
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
)

target_compile_options(snekstudio-publisher-draft
    PRIVATE
        -Wall
        -Wextra
        -Wpedantic
)

target_link_libraries(snekstudio-source
    PRIVATE
        PkgConfig::LIBOBS
)

set_target_properties(snekstudio-source PROPERTIES
    PREFIX ""
    OUTPUT_NAME "snekstudio-source"
)

install(TARGETS snekstudio-source
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/obs-plugins
)

install(FILES include/snekstudio_frame_protocol.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/snekstudio-source
)

install(FILES include/snekstudio_frame_protocol.h
    DESTINATION ${CMAKE_INSTALL_DATADIR}/obs/obs-plugins/snekstudio-source
)

install(PROGRAMS scripts/snekstudio_demo_publisher.py
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME snekstudio-demo-publisher
)

install(FILES MVP.md SPEC.md
    DESTINATION ${CMAKE_INSTALL_DATADIR}/doc/${SNEKSTUDIO_PACKAGE_NAME}
)