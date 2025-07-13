#!/bin/sh
export MESA_GLSL_VERSION_OVERRIDE=310
export MESA_GL_VERSION_OVERRIDE=3.1
cmake --build build
