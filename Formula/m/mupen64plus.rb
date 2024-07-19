class Mupen64plus < Formula
  desc "Cross-platform plugin-based N64 emulator"
  homepage "https://www.mupen64plus.org/"
  url "https://github.com/mupen64plus/mupen64plus-core/releases/download/2.6.0/mupen64plus-bundle-src-2.6.0.tar.gz"
  sha256 "297e17180cd76a7b8ea809d1a1be2c98ed5c7352dc716965a80deb598b21e131"
  license "GPL-2.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 sonoma:       "0f437da2a2cfdf2ced2d2479d2ab607f32b22b9cb3d7a5a1e44ccbe95b8daa03"
    sha256 ventura:      "199fa074563658ae7b6c05a47f9110ee598410f9238f429d929b456f45c9245c"
    sha256 monterey:     "dba7bba059b6b612f87feebf35af939c3fb9508fb3e8fb2e5441f71778e4726a"
    sha256 x86_64_linux: "98724239e9ae73bfcce1db911635ba6cc7947878c1843c488a6408466282bf91"
  end

  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "sdl2"

  on_linux do
    depends_on "vulkan-headers" => :build
    depends_on "mesa"
    depends_on "mesa-glu"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    # Prevent different C++ standard library warning
    if OS.mac?
      inreplace Dir["source/mupen64plus-**/projects/unix/Makefile"],
                /(-mmacosx-version-min)=\d+\.\d+/,
                "\\1=#{MacOS.version}"
    end

    if OS.linux?
      ENV.append "CFLAGS", "-fcommon"
      ENV.append "CFLAGS", "-fpie"
    end

    args = ["install", "PREFIX=#{prefix}", "COREDIR=#{lib}/"]
    args << if OS.mac?
      "INSTALL_STRIP_FLAG=-S"
    else
      "USE_GLES=1"
    end

    cd "source/mupen64plus-core/projects/unix" do
      system "make", *args
    end

    cd "source/mupen64plus-audio-sdl/projects/unix" do
      system "make", *args, "NO_SRC=1", "NO_SPEEX=1"
    end

    cd "source/mupen64plus-input-sdl/projects/unix" do
      system "make", *args
    end

    cd "source/mupen64plus-rsp-hle/projects/unix" do
      system "make", *args
    end

    cd "source/mupen64plus-video-glide64mk2/projects/unix" do
      system "make", *args
    end

    cd "source/mupen64plus-video-rice/projects/unix" do
      system "make", *args
    end

    cd "source/mupen64plus-ui-console/projects/unix" do
      system "make", *args, "PIE=1"
    end

    # fix `bin/Frameworks/libmupen64plus.dylib' (no such file)` error
    if OS.mac? && Hardware::CPU.arm?
      bin.install_symlink lib/"libmupen64plus.dylib" => "Frameworks/libmupen64plus.dylib"
    end
  end

  test do
    resource "homebrew-testrom" do
      url "https://github.com/mupen64plus/mupen64plus-rom/raw/76ef14c876ed036284154444c7bdc29d19381acc/m64p_test_rom.v64"
      sha256 "b5fe9d650a67091c97838386f5102ad94c79232240f9c5bcc72334097d76224c"
    end

    # Disable test in Linux CI because it hangs because a display is not available.
    return if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    testpath.install resource("homebrew-testrom")
    system bin/"mupen64plus", "--testshots", "1", "m64p_test_rom.v64"
  end
end
