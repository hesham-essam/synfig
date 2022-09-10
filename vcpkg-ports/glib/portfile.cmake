set(GLIB_MAJOR_MINOR 2.73)
set(GLIB_PATCH 3)

vcpkg_download_distfile(GLIB_ARCHIVE
    URLS "https://download.gnome.org/sources/glib/${GLIB_MAJOR_MINOR}/glib-${GLIB_MAJOR_MINOR}.${GLIB_PATCH}.tar.xz"
    FILENAME "glib-${GLIB_MAJOR_MINOR}.${GLIB_PATCH}.tar.xz"
    SHA512 f965323be1d17dbc322ae329748b99365720977bd313519279a5236973532fed36a63726a3bffd2795eb5a627776cda3ebcbd3456cc2388f65ffe8afacbcc167
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${GLIB_ARCHIVE}
    REF "${GLIB_MAJOR_MINOR}.${GLIB_PATCH}"
    PATCHES
        use-libiconv-on-windows.patch
        libintl.patch
)

if (selinux IN_LIST FEATURES)
    if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
        message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
    endif()
    list(APPEND OPTIONS -Dselinux=enabled)
else()
    list(APPEND OPTIONS -Dselinux=disabled)
endif()

if (libmount IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlibmount=enabled)
else()
    list(APPEND OPTIONS -Dlibmount=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Diconv=external)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dinstalled_tests=false
        ${OPTIONS}
        -Dtests=false
        -Dxattr=false
        -Dlibelf=disabled
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

set(GLIB_TOOLS gdbus
               gio
               gio-querymodules
               glib-compile-resources
               glib-compile-schemas
               gobject-query
               gresource
               gsettings
               )

if(NOT VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_IS_OSX)
        list(APPEND GLIB_TOOLS gapplication)
    endif()
    list(APPEND GLIB_TOOLS glib-gettextize gtester)
endif()
set(GLIB_SCRIPTS gdbus-codegen glib-genmarshal glib-mkenums gtester-report)


if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "x64|arm64")
    list(APPEND GLIB_TOOLS  gspawn-win64-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win64-helper-console${VCPKG_EXECUTABLE_SUFFIX})
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND GLIB_TOOLS  gspawn-win32-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win32-helper-console${VCPKG_EXECUTABLE_SUFFIX})
endif()
vcpkg_copy_tools(TOOL_NAMES ${GLIB_TOOLS} AUTO_CLEAN)
foreach(script IN LISTS GLIB_SCRIPTS)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

IF(VCPKG_TARGET_IS_WINDOWS)
    set(SYSTEM_LIBRARIES dnsapi iphlpapi winmm lshlwapi)
else()
    set(SYSTEM_LIBRARIES resolv mount blkid selinux)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${prefix}/tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${prefix}/../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${prefix}/tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${prefix}/../tools/${PORT}")
endif()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES ${SYSTEM_LIBRARIES})

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Fix python scripts
set(_file "${CURRENT_PACKAGES_DIR}/tools/${PORT}/gdbus-codegen")
file(READ "${_file}" _contents)
string(REPLACE "elif os.path.basename(filedir) == 'bin':" "elif os.path.basename(filedir) == 'tools':" _contents "${_contents}")
string(REPLACE "path = os.path.join(filedir, '..', 'share', 'glib-2.0')" "path = os.path.join(filedir, '../..', 'share', 'glib-2.0')" _contents "${_contents}")
string(REPLACE "path = os.path.join(filedir, '..')" "path = os.path.join(filedir, '../../share/glib-2.0')" _contents "${_contents}")
string(REPLACE "path = os.path.join('${CURRENT_PACKAGES_DIR}/share', 'glib-2.0')" "path = os.path.join('unuseable/share', 'glib-2.0')" _contents "${_contents}")

file(WRITE "${_file}" "${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/gdb")
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/glib/glib-gettextize")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/glib/glib-gettextize" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
endif()
