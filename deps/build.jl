
include("build_LLVM.v6.0.0.jl")


mkpath("build")
mkpath("usr/lib")


CXX="g++"


CXX_ABI_SETTING="-D_GLIBCXX_USE_CXX11_ABI=1"
INCLUDE_DIRECTORIES = ["-I$(Sys.BINDIR)/../include", "-Iusr/include", "-IclangCodeGenHeaders"]
LLVM_EXTRA_CPPFLAGS = "-DLLVM_NDEBUG"

cmd = `$CXX $(CXX_ABI_SETTING) -fno-rtti -DLIBRARY_EXPORTS -fPIC -O0 -g -std=c++11 $INCLUDE_DIRECTORIES $LLVM_EXTRA_CPPFLAGS -c ../src/bootstrap.cpp -o build/bootstrap.o`

run(cmd)


LINK_DIRECTORIES = ["-L$(Sys.BINDIR)/../lib", "-L$(Sys.BINDIR)/../lib/julia", "-Lusr/lib"]

LINK_LIBS = ["-lclangFrontendTool", "-lclangBasic", "-lclangLex", "-lclangDriver", "-lclangFrontend", "-lclangParse", "-lclangAST", "-lclangASTMatchers", "-lclangSema", "-lclangAnalysis", "-lclangEdit", "-lclangRewriteFrontend", "-lclangRewrite", "-lclangSerialization", "-lclangStaticAnalyzerCheckers", "-lclangStaticAnalyzerCore", "-lclangStaticAnalyzerFrontend", "-lclangTooling", "-lclangToolingCore", "-lclangCodeGen", "-lclangARCMigrate", "-lclangFormat"]

cmd = `$CXX -shared -fPIC $LINK_DIRECTORIES -ljulia -lLLVM -o usr/lib/libcxxffi.so -Wl,--whole-archive $LINK_LIBS -Wl,--no-whole-archive build/bootstrap.o`

run(cmd)


cmd = `$CXX -E -P $INCLUDE_DIRECTORIES -DJULIA ../src/cenumvals.jl.h`
cenumvals = readstring(cmd)
write("build/clang_constants.jl", cenumvals)
