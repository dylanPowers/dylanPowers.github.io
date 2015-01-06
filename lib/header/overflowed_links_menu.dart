part of intro_header;

const String OVERFLOWED_LINKS_MENU_TAG = 'overflowed-links-menu';
@CustomTag(OVERFLOWED_LINKS_MENU_TAG)
class OverflowedLinksMenuElement extends PolymerElement {
  dynamic overflowedLinks; // TODO

  factory OverflowedLinksMenuElement() {
    return new Element.tag(OVERFLOWED_LINKS_MENU_TAG);
  }

  OverflowedLinksMenuElement.created() : super.created();
}