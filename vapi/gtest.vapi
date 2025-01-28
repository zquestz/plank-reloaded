[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "gtest/gtest.h")]
namespace GTest {
  [CCode (cname = "testing::Test")]
  public class Test {
  }

  [CCode (cname = "RUN_ALL_TESTS")]
  public static int run_all_tests ();

  [CCode (cname = "testing::InitGoogleTest")]
  public static void init (ref int argc, char* * argv);
}
