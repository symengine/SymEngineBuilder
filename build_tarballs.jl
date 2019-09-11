# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build MPCBuilder
name = "SymEngine"
version = v"0.5.0"
sources = [
    "https://github.com/symengine/symengine/releases/download/v$version/symengine-$version.tar.gz" =>
    "5d02002f00d16a0928d1056e6ecb8f34fd59f3bfd8ed0009a55700334dbae29b",
]

# Bash recipe for building across all platforms

script = """cd symengine-$version
"""*raw"""
if [[ ${target} == x86_64-* ]]; then
    export CXXFLAGS=-march=core2
fi
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DBUILD_TESTS=no -DBUILD_BENCHMARKS=no  -DBUILD_SHARED_LIBS=yes -DWITH_MPC=yes -DBUILD_FOR_DISTRIBUTION=yes -DWITH_SYMENGINE_THREAD_SAFE=yes .
make -j
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
a = supported_platforms()
deleteat!(a, findfirst(x->x==Windows(:x86_64), a))
platforms = BinaryBuilder.expand_gcc_versions(Windows(:x86_64))
platforms = vcat(platforms, a)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libsymengine", :libsymengine)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl"
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/MPFR-v4.0.2-0/build_MPFR.v4.0.2.jl"
    "https://github.com/isuruf/MPCBuilder/releases/download/v1.1.0-3/build_MPC.v1.1.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
