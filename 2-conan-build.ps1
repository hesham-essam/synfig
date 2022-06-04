$env:CONAN_DEFAULT_PACKAGE_ID_MODE = "full_package_mode"
$env:PKG_CONFIG_PATH = "$([RegEx]::Escape($PSScriptRoot))/conan_build/modules"

cd $PSScriptRoot
mkdir conan_build
cd conan_build

conan install .. -if ./modules/ --build=missing
if ($?) {
    try {
        ./modules/activate_run.ps1
        cmake -DCMAKE_MODULE_PATH="$([RegEx]::Escape($PSScriptRoot))/conan_build/modules" -DCMAKE_BUILD_TYPE=Release..
        cmake --build . --config Release -j8
    } finally {
        ./modules/deactivate_run.ps1
    }
}
