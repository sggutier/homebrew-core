class Pmd < Formula
  desc "Source code analyzer for Java, JavaScript, and more"
  homepage "https://pmd.github.io"
  url "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.4.0/pmd-dist-7.4.0-bin.zip"
  sha256 "1dcbb7784a7fba1fd3c6efbaf13dcb63f05fe069fcf026ad5e2933711ddf5026"
  license "BSD-4-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, sonoma:         "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, ventura:        "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, monterey:       "0290c9f34fa86abfd312be6935d27a5468c52057a930883951c6d57afdca7c19"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dcbdf8c85f31d48aa328593d91cde433d72a5766ab46e5e72f512c5059fda9ed"
  end

  depends_on "openjdk"

  def install
    rm Dir["bin/*.bat"]
    libexec.install Dir["*"]
    (bin/"pmd").write_env_script libexec/"bin/pmd", Language::Java.overridable_java_home_env
  end

  test do
    (testpath/"java/testClass.java").write <<~EOS
      public class BrewTestClass {
        // dummy constant
        public String SOME_CONST = "foo";

        public boolean doTest () {
          return true;
        }
      }
    EOS

    output = shell_output("#{bin}/pmd check -d #{testpath}/java " \
                          "-R category/java/bestpractices.xml -f json")
    assert_empty JSON.parse(output)["processingErrors"]
  end
end
