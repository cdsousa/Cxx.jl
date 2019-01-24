
LLVM_VER = "6.0.0"



BASE_JULIA_BIN = get(ENV, "BASE_JULIA_BIN", Sys.BINDIR)
BASE_JULIA_SRC = get(ENV, "BASE_JULIA_SRC", joinpath(BASE_JULIA_BIN, "..", ".."))
println("writing path.jl file")
s = """
    const BASE_JULIA_BIN=$(sprint(show, BASE_JULIA_BIN))
    export BASE_JULIA_BIN
    const BASE_JULIA_SRC=$(sprint(show, BASE_JULIA_SRC))
    export BASE_JULIA_SRC
    """
f = open(joinpath(dirname(@__FILE__),"path.jl"), "w")
write(f, s)
close(f)



module LLVMBuilder
    import ..LLVM_VER
    include("build_LLVM.v$LLVM_VER.jl")
end


using BinDeps

@BinDeps.setup


cxxffi = library_dependency("libcxxffi")

provides(Sources, URI("http://releases.llvm.org/$LLVM_VER/cfe-$LLVM_VER.src.tar.xz"), cxxffi)


CXX="g++"

@static if Sys.isapple()
  SHLIB_EXT = "dylib"
else
  SHLIB_EXT = "so"
end

@static if Sys.isapple()
  WHOLE_ARCHIVE = ["-Xlinker", "-all_load"]
  NO_WHOLE_ARCHIVE = []
else
  WHOLE_ARCHIVE = "-Wl,--whole-archive"
  NO_WHOLE_ARCHIVE = "-Wl,--no-whole-archive"
end

CLANG_SRC_DIR = "$(BinDeps.srcdir(cxxffi))/cfe-$LLVM_VER.src/lib/"

CXX_ABI_SETTING="-D_GLIBCXX_USE_CXX11_ABI=1"
INCLUDE_DIRECTORIES = ["-I$(Sys.BINDIR)/../include", "-Iusr/include", "-I$(CLANG_SRC_DIR)"]
LLVM_EXTRA_CPPFLAGS = "-DLLVM_NDEBUG"

LINK_DIRECTORIES = ["-L$(Sys.BINDIR)/../lib", "-L$(Sys.BINDIR)/../lib/julia", "-Lusr/lib"]

LINK_LIBS = ["-lclangFrontendTool", "-lclangBasic", "-lclangLex", "-lclangDriver", "-lclangFrontend", "-lclangParse", "-lclangAST", "-lclangASTMatchers", "-lclangSema", "-lclangAnalysis", "-lclangEdit", "-lclangRewriteFrontend", "-lclangRewrite", "-lclangSerialization", "-lclangStaticAnalyzerCheckers", "-lclangStaticAnalyzerCore", "-lclangStaticAnalyzerFrontend", "-lclangTooling", "-lclangToolingCore", "-lclangCodeGen", "-lclangARCMigrate", "-lclangFormat"]


provides(BuildProcess,
    (@build_steps begin
        GetSources(cxxffi)
        CreateDirectory("build")
        @build_steps begin
             `$CXX $(CXX_ABI_SETTING) -fno-rtti -DLIBRARY_EXPORTS -fPIC -O0 -g -std=c++11 $INCLUDE_DIRECTORIES $LLVM_EXTRA_CPPFLAGS -c ../src/bootstrap.cpp -o build/bootstrap.o`
             `$CXX -shared -fPIC $LINK_DIRECTORIES -ljulia -lLLVM -o usr/lib/libcxxffi.$(SHLIB_EXT) $WHOLE_ARCHIVE $LINK_LIBS $NO_WHOLE_ARCHIVE build/bootstrap.o`
             `$CXX -E -P $INCLUDE_DIRECTORIES -DJULIA ../src/cenumvals.jl.h -o build/clang_constants.jl`
        end
    end), cxxffi)


@BinDeps.install Dict(:cxxffi => :cxxffi)
