part of intro_header;

const String OVERFLOWED_LINKS_MENU_TAG = 'overflowed-links-menu';
@CustomTag(OVERFLOWED_LINKS_MENU_TAG)
class OverflowedLinksMenuElement extends PolymerElement {
  static const OPEN_DROPDOWN_CLASSNAME = 'core-opened';

  Rectangle get buttonDimensions =>
      shadowRoot.getElementById('links-menu-button').getBoundingClientRect();

  @published bool menuOpened = false;
  @published List overflowedLinks = new List<OverflowedHeaderLink>();

  PaperDropdown _linksDropdown;
  StreamSubscription _observableListener;

  factory OverflowedLinksMenuElement() {
    return new Element.tag(OVERFLOWED_LINKS_MENU_TAG);
  }

  OverflowedLinksMenuElement.created() : super.created();

  @override
  void attached() {
    _linksDropdown = shadowRoot.getElementById('links-dropdown');
    if (menuOpened) {
      _linksDropdown.classes.add(OPEN_DROPDOWN_CLASSNAME);
    }

    // Listen for changes to menuOpened
    _observableListener = changes.listen((List<ChangeRecord> records) {
      records.forEach((PropertyChangeRecord<bool> record) {
        if (record.name == #menuOpened) {
          if (record.newValue) {
            _linksDropdown.open();
          } else {
            _linksDropdown.close();
          }
        }
      });
    });
  }

  @override detached() {
    // Cleanup event listeners
    _observableListener.cancel();
  }

  void linksMenuButtonClicked() {
    // After event propagation
    window.animationFrame.then((_) =>
      menuOpened = _linksDropdown.opened);
  }
}