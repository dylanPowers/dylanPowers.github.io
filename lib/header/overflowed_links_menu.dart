part of intro_header;

const String OVERFLOWED_LINKS_MENU_TAG = 'overflowed-links-menu';
@CustomTag(OVERFLOWED_LINKS_MENU_TAG)
class OverflowedLinksMenuElement extends PolymerElement {
  static const OPEN_DROPDOWN_CLASSNAME = 'core-opened';

  Rectangle get buttonDimensions =>
      shadowRoot.getElementById('links-menu-button').getBoundingClientRect();

  @published bool get isMenuOpen => readValue(#isMenuOpen, () => false);
                  set isMenuOpen(bool value) {
    if (_linksDropdown != null) {
      if (value) {
        _linksDropdown.classes.add(OPEN_DROPDOWN_CLASSNAME);
      } else {
        _linksDropdown.classes.remove(OPEN_DROPDOWN_CLASSNAME);
      }
    }

    writeValue(#isMenuOpen, value);
  }

  @published List overflowedLinks = new List<OverflowedHeaderLink>();

  HtmlElement _linksDropdown;

  factory OverflowedLinksMenuElement() {
    return new Element.tag(OVERFLOWED_LINKS_MENU_TAG);
  }

  OverflowedLinksMenuElement.created() : super.created();

  @override
  void attached() {
    _linksDropdown = shadowRoot.getElementById('links-dropdown');
    if (isMenuOpen) {
      _linksDropdown.classes.add(OPEN_DROPDOWN_CLASSNAME);
    }
  }
}