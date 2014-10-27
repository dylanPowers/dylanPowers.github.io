part of about_me_tests;

class HeaderTests {
  static void run() {
    group('The intro header', () {
      test('element factory constructor works', introHeaderFactoryWorks);

      setUp(headerSetUp);
      tearDown(headerTearDown);

      test('banner is present until the first card is reached',
           bannerIsPresentUntilFirstCardReached);
    });
  }

  static void headerSetUp() {
    var el = new IntroHeaderElement();
    el.id = 'header-test-el';
    document.body.append(el);
  }

  static void headerTearDown() {
    var el = document.getElementById('header-test-el');
    el.remove();
  }

  static void introHeaderFactoryWorks() {
    expect(() => new IntroHeaderElement(), returnsNormally);
  }

  static Future bannerIsPresentUntilFirstCardReached() {
    var extraHeight = new Element.div();
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);

    return new Future(() => window.scroll(0, 600)).then((_) {
      return new Future(() {
        var shadowRoot = document.getElementById('header-test-el').shadowRoot;
        var panel = shadowRoot.getElementById('panel');
        expect(panel.classes, contains('panel-displayed'));
      });
    });
  }
}