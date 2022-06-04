from conans import ConanFile, Meson, tools
from conan.tools.files import rename
from conans.errors import ConanInvalidConfiguration
from conan.tools.microsoft import is_msvc
import os

# TODO remove this
import shutil


class GtkmmConan(ConanFile):
    name = "gtkmm"
    description = "gtkmm is a GUI toolkit and nothing more, and it strives to be the best C++ GUI toolkit."
    topics = "gui", "gtk", "widgets", "wrapper"
    url = "https://github.com/conan-io/conan-center-index"
    homepage = "https://www.gtkmm.org/"
    license = "LGPL-2.1"
    generators = "pkg_config"

    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "with_atkmm": [True, False],
        "with_x11": [True, False],
        "build_demos": [True, False]
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "with_atkmm": False,
        "build_demos": False,
        "with_x11": False
    }

    exports_sources = "patches/**"

    @property
    def _is_gtkmm3(self):
        return tools.Version(self.version) >= "3.0.0"

    @property
    def _is_gtkmm4(self):
        return tools.Version(self.version) >= "1.4.0" and tools.Version(
            self.version) < "2.48.0"

    @property
    def _api_version(self):
        return "3.0" if self._is_gtkmm3 else "4.0"

    @property
    def _source_subfolder(self):
        return "source_subfolder"

    @property
    def _build_subfolder(self):
        return "build_subfolder"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

        if self.settings.os != "Linux":
            del self.options.with_x11

    def build_requirements(self):
        self.build_requires("meson/0.62.1")
        self.build_requires("pkgconf/1.7.4")

    def requirements(self):
        # FIXME: remove once dependency conflict is fixed
        self.requires("glib/2.73.0")

        self.requires("gtk/3.24.34")
        self.requires("glibmm/2.66.4")
        self.requires("cairomm/1.14.3")
        self.requires("pangomm/2.46.2")
        self.requires("gdk-pixbuf/2.42.8")
        if self.options.with_atkmm:
           self.requires("atkmm/2.28.2")
        if self.options.build_demos:
           self.requires("epoxy/1.5.10")

    def source(self):
        # tools.get(**self.conan_data["sources"][self.version], strip_root=True, destination=self._source_subfolder)
        shutil.copytree("E:/gtk/gtkmm-3.24.6", self._source_subfolder)

    def _configure_meson(self):
        meson = Meson(self)
        defs = {
            "build-atkmm-api": "true" if self.options.with_atkmm else "false",
            "build-x11-api": "true" if "with_x11" in self.options and self.options.with_x11 else "false",
            "build-tests": "false",
            "build-documentation": "false",
            "msvc14x-parallel-installable": "false",
        }

        meson.configure(
            defs=defs,
            build_folder=self._build_subfolder,
            source_folder=self._source_subfolder,
            pkg_config_paths=[self.install_folder],
        )

        return meson

    def _patch_sources(self):
        for patch in self.conan_data.get("patches", {}).get(self.version, []):
            tools.patch(**patch)

        # glibmm_generate_extra_defs library does not provide any standard way
        # for discovery, which is why pangomm uses "find_library" method instead
        # of "dependency". this patch adds a hint to where this library is
        glibmm_generate_extra_defs_dir = [
            os.path.join(self.deps_cpp_info["glibmm"].rootpath, libdir) for
            libdir in self.deps_cpp_info["glibmm"].libdirs]

        tools.replace_in_file(
            os.path.join(self._source_subfolder, "tools",
                         "extra_defs_gen", "meson.build"),
            "required: glibmm_dep.type_name() != 'internal',",
            f"required: glibmm_dep.type_name() != 'internal', dirs: {glibmm_generate_extra_defs_dir}")


    def build(self):
        self._patch_sources()

        with tools.environment_append(tools.RunEnvironment(self).vars):
            meson = self._configure_meson()
            meson.build()

    def package(self):
        self.copy("COPYING", dst="licenses", src=self._source_subfolder)
        meson = self._configure_meson()
        meson.install()

        shutil.move(
            os.path.join(self.package_folder, "lib",
                         f"gtkmm-{self._api_version}", "include",
                         "gtkmmconfig.h"),
            os.path.join(self.package_folder, "include",
                         f"gtkmm-{self._api_version}", "gtkmmconfig.h"))
        shutil.move(
            os.path.join(self.package_folder, "lib",
                         f"gdkmm-{self._api_version}", "include",
                         "gdkmmconfig.h"),
            os.path.join(self.package_folder, "include",
                         f"gdkmm-{self._api_version}", "gdkmmconfig.h"))

        tools.rmdir(os.path.join(self.package_folder, "lib", "pkgconfig"))
        tools.rmdir(
            os.path.join(self.package_folder, "lib",
                         "gtkmm-{self._api_version}", "include"))
        tools.rmdir(
            os.path.join(self.package_folder, "lib",
                         "gdkmm-{self._api_version}", "include"))

        if is_msvc(self):
            tools.remove_files_by_mask(
                os.path.join(self.package_folder, "bin"), "*.pdb")
            if not self.options.shared:
                rename(
                    self,
                    os.path.join(self.package_folder, "lib",
                                 f"libgtkmm-{self._api_version}.a"),
                    os.path.join(self.package_folder, "lib",
                                 f"gtkmm-{self._api_version}.lib"),
                )
                rename(
                    self,
                    os.path.join(self.package_folder, "lib",
                                 f"libgdkmm-{self._api_version}.a"),
                    os.path.join(self.package_folder, "lib",
                                 f"gdkmm-{self._api_version}.lib"),
                )

    def package_info(self):
        if self._is_gtkmm3:
            self.cpp_info.components["gdkmm-3.0"].names["pkg-config"] = "gdkmm-3.0"
            self.cpp_info.components["gdkmm-3.0"].libs = ["gdkmm-3.0"]
            self.cpp_info.components["gdkmm-3.0"].includedirs = [
                    os.path.join("include", "gdkmm-3.0")
            ]
            self.cpp_info.components["gdkmm-3.0"].requires = [
                "glibmm::giomm-2.4", "gtk::gtk+-3.0", "cairomm::cairomm-1.0",
                "pangomm::pangomm-1.4", "gdk-pixbuf::gdk-pixbuf"
            ]

            self.cpp_info.components["gtkmm-3.0"].names["pkg-config"] = "gtkmm-3.0"
            self.cpp_info.components["gtkmm-3.0"].libs = ["gtkmm-3.0"]
            self.cpp_info.components["gtkmm-3.0"].includedirs = [
                    os.path.join("include", "gtkmm-3.0")
            ]
            self.cpp_info.components["gtkmm-3.0"].requires = [
                "glibmm::giomm-2.4", "gtk::gtk+-3.0", "cairomm::cairomm-1.0",
                "pangomm::pangomm-1.4", "gdk-pixbuf::gdk-pixbuf", "gdkmm-3.0"
            ]

            # FIXME: remove once dependency conflict is fixed
            self.cpp_info.components["gtkmm-3.0"].requires.append("glib::glib-2.0")

        elif self._is_gtkmm4:
            pass
