[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "gmock/gmock.h")]
namespace GMock {
  [CCode (cname = "testing::InitGoogleMock")]
  public static void init (ref int argc, char* * argv);
}
