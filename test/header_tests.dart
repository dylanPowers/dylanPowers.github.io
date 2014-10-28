part of about_me_tests;

class HeaderTests {
  static void run() {
    group('The intro header', () {
      test('element factory constructor works', introHeaderFactoryWorks);

      setUp(headerSetUp);
      tearDown(headerTearDown);

      test('banner is present until the first card is reached',
           bannerIsPresentUntilFirstCardReached);
      
      test('banner is present when slowly scrolling up past the first card',
           bannerIsPresentWhenSlowlyScrolling);
    });
  }

  static void headerSetUp() {
    var el = new IntroHeaderElement();
    el.id = 'header-test-el';
    document.body.append(el);

    var extraHeight = new Element.div();
    extraHeight.id = 'extra-height';
    extraHeight.style.height = '5000px';
    document.body.append(extraHeight);
  }

  static void headerTearDown() {
    var el = document.getElementById('header-test-el');
    el.remove();
    
    var extraHeight = document.getElementById('extra-height');
    extraHeight.remove();
  }

  static void introHeaderFactoryWorks() {
    expect(() => new IntroHeaderElement(), returnsNormally);
  }

  static Future bannerIsPresentUntilFirstCardReached() {
    return new Future(() => window.scroll(0, 500)).then((_) {
      return new Future(() {
        var shadowRoot = document.getElementById('header-test-el').shadowRoot;
        var panel = shadowRoot.getElementById('panel');
        expect(panel.classes, contains('panel-displayed'));
      });
    });
  }
  
  static Future bannerIsPresentWhenSlowlyScrolling() {
    return new Future(() => window.scroll(0, 502)).then((_) {
      return new Future.delayed(Duration.ZERO, () => window.scroll(0, 500));
    }).then((_) {
      return new Future.delayed(Duration.ZERO, () {
        IntroHeaderElement header = document.getElementById('header-test-el');
        expect(header.panelDisplayStyle, equals('panel-displayed'));
      });
    });
  }
}