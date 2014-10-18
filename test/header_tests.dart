part of about_me_tests;

class HeaderTests {
  static void run() {
    group('The intro header', () {
      test('element factory constructor works', introHeaderFactoryWorks);
//      test('banner is present until the first card is reached',
//           bannerIsPresentUntilFirstCardReached);
    });
  }

  static void introHeaderFactoryWorks() {
    expect(() => new IntroHeaderElement(), returnsNormally);
  }
//
//  static void bannerIsPresentUntilFirstCardReached() {
//    var el = new Element.('intro-header');
//  }
}