<div align="center">
  <h1 align="center">Lights-Up</h1>
  <h3 align="center">Philips Hue controller for elementary OS.</h3>
</div>


## Installation

### Dependencies
These dependencies must be present before building
 - `meson (>=0.40)`
 - `valac (>=0.16)`
 - `debhelper (>= 9)`
 - `libgranite-dev`
 - `libgtk-3-dev`
 - `libsoup`


 ### Building

```
meson build && cd build
meson configure -Dprefix=/usr
ninja
sudo ninja install
com.github.philip-scott.lights-up
```

### License

This project is licensed under the GPL3 License - see the [LICENSE](LICENSE.md) file for details.
