# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build MPCBuilder
name = "SymEngine"
version = v"0.3.0"
sources = [
    "https://github.com/symengine/symengine/archive/v$version.tar.gz" =>
    "591463cb9e741d59f6dfd39a7943e3865d3afe9eac47d1a9cbf5ca74b9c49476",
]

# Bash recipe for building across all platforms

script = """cd symengine-$version
"""*raw"""
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DBUILD_TESTS=no -DBUILD_BENCHMARKS=no  -DBUILD_SHARED_LIBS=yes -DWITH_MPC=yes -DBUILD_FOR_DISTRIBUTION=yes .
make -j
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libsymengine", :libsymengine)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaMath/GMPBuilder/releases/download/v6.1.2-2/build_GMP.v6.1.2.jl"
    "https://github.com/JuliaMath/MPFRBuilder/releases/download/v4.0.1-3/build_MPFR.v4.0.1.jl"
    "https://github.com/isuruf/MPCBuilder/releases/download/v1.1.0-2/build_MPC.v1.1.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
