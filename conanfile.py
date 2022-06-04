from conans import ConanFile

class SynfigConan(ConanFile):
    name = "Synfig"
    homepage = "https://www.synfig.org/"
    license = "GPL-3"
    settings = "os", "compiler", "build_type", "arch"

    # the new CMakeToolchain and CMakeDeps require newer version of cmake
    generators = "cmake_find_package", "pkg_config", "virtualrunenv"

    def build_requirements(self):
        self.build_requires("pkgconf/1.7.4")
        self.build_requires("gettext/0.21")

    def requirements(self):
        self.requires("openexr/3.1.5")
        self.requires("boost/1.79.0")
        self.requires("fftw/3.3.9")
        self.requires("glib/2.73.0")
        self.requires("pango/1.50.7")
        self.requires("cairo/1.17.4")
        self.requires("atk/2.38.0")
        self.requires("gdk-pixbuf/2.42.6")
        self.requires("gtk/3.24.34")
        self.requires("libxmlpp/2.42.1")
        self.requires("glibmm/2.66.4")
        self.requires("cairomm/1.14.3")
        self.requires("pangomm/2.46.2")
        self.requires("libsigcpp/2.10.8")
        self.requires("gtkmm/3.24.6")
        self.requires("freetype/2.12.1")
        self.requires("libxml2/2.9.14")
        self.requires("libxmlpp/2.42.1")
        self.requires("libtool/2.4.6")
        self.requires("gettext/0.21")

    def config_options(self):
        self.options["glib"].shared = True
        self.options["pango"].shared = True
        self.options["cairo"].shared = True
        self.options["atk"].shared = True
        self.options["gdk-pixbuf"].shared = True
        self.options["gtk"].shared = True
        self.options["libsigcpp"].shared = True
        self.options["glibmm"].shared = True
        self.options["cairomm"].shared = True
        self.options["pangomm"].shared = True
        self.options["gtkmm"].shared = True
        self.options["libxmlpp"].shared = True
