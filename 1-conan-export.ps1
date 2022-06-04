$Cd = Get-Location
cd $PSScriptRoot/conan-recipes/gtk/all
conan export . gtk/3.24.34@
cd $PSScriptRoot/conan-recipes/gtkmm/all
conan export . gtkmm/3.24.6@
cd $PSScriptRoot/conan-recipes/autoconf/all
conan export . autoconf/2.71@
cd $Cd
