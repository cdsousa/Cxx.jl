using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libLLVM"], :libLLVM),
    LibraryProduct(prefix, String["libLTO"], :libLTO),
    LibraryProduct(prefix, String["libclang"], :libclang),
    # ExecutableProduct(prefix, "llvm-config", :llvm_config),
    FileProduct(prefix, "tools/llvm-config", :llvm_config),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/staticfloat/LLVMBuilder/releases/download/v6.0.0-5"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/LLVM.v6.0.0.aarch64-linux-gnu.tar.gz", "e37c09a3e7bf137de34bf29131b4a782fa8f3a9b3361a3079d5e7228dbf34ee0"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/LLVM.v6.0.0.arm-linux-gnueabihf.tar.gz", "655b00eef1982255d1e6a5b7d69d590e5db2ace869fde03fb76b0b93e0300970"),
    Linux(:i686, :glibc) => ("$bin_prefix/LLVM.v6.0.0.i686-linux-gnu.tar.gz", "5ba884b5936149ddfe71368dd86cf8f5eb0eb7fd98a968d769574e54b62d9fa8"),
    Windows(:i686) => ("$bin_prefix/LLVM.v6.0.0.i686-w64-mingw32.tar.gz", "ba546bd1e34f4dca867d5ca5ae5e202c7b32ba32e16d7290e0a2ae2801921267"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/LLVM.v6.0.0.powerpc64le-linux-gnu.tar.gz", "aa2c0f4e340a1dd099840276dc192c1853c556fc38df0e1e9ab31ff264dd0e71"),
    MacOS(:x86_64) => ("$bin_prefix/LLVM.v6.0.0.x86_64-apple-darwin14.tar.gz", "3dced12c16a72257a411adf04454750817cc009e65bb0346096d4aa4d752d5f4"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/LLVM.v6.0.0.x86_64-linux-gnu.tar.gz", "cb9b2e0f624eef014c0ce4a74ad83574ade637d2d053cd49c95758581aad5f2a"),
    Windows(:x86_64) => ("$bin_prefix/LLVM.v6.0.0.x86_64-w64-mingw32.tar.gz", "057695a5838af2a56f4c560d5e1096bc9fd85a4af387420426ca96fc2b588d21"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
