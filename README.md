FIRRTL Emacs Mode
========================================

[![MELPA](https://melpa.org/packages/firrtl-mode-badge.svg)](https://melpa.org/#/firrtl-mode)

Adds support for syntax highlighting and indentation for [FIRRTL (Flexible Intermediate Representation of RTL)](https://github.com/freechipsproject/firrtl).

Two options for installation: as a package from MELPA and manually.

### Install from MELPA

Enable MELPA if you haven't already. See: [Getting Started](http://melpa.org/#/getting-started).

Start up the package manager with `M-x packages-list-packages`. Find `firrtl-mode` and install it (`i` then `x`).

### Install Manually

Add the following to your `.emacs`:
```elisp
(add-to-list 'load-path "[path-to-this-repo]")
(require `firrtl-mode)
```
