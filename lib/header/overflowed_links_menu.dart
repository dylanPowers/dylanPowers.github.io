part of intro_header;

const String OVERFLOWED_LINKS_MENU_TAG = 'overflowed-links-menu';
@CustomTag(OVERFLOWED_LINKS_MENU_TAG)
class OverflowedLinksMenuElement extends PolymerElement {
  static const OPEN_DROPDOWN_CLASSNAME = 'core-opened';

  Rectangle get buttonDimensions =>
      shadowRoot.getElementById('links-menu-button').getBoundingClientRect();

  /**
   * Keeping track of the state of the menu is unreliable and complicated.
   * We only keep track of whether it's possibly opened. Set to false to close
   * the menu.
   */
  @published bool menuPossiblyOpened = false;
  @published List overflowedLinks = new List<OverflowedHeaderLink>();

  PaperDropdown _linksDropdown;
  StreamSubscription _linksMenuButtonClickListener;
  StreamSubscription _observableListener;

  factory OverflowedLinksMenuElement() {
    return new Element.tag(OVERFLOWED_LINKS_MENU_TAG);
  }

  OverflowedLinksMenuElement.created() : super.created();

  @override
  void attached() {
    _linksDropdown = shadowRoot.getElementById('links-dropdown');
    if (menuPossiblyOpened) {
      _linksDropdown.classes.add(OPEN_DROPDOWN_CLASSNAME);
    }

    // Listen for changes to menuPossiblyOpened
    _observableListener = changes.listen((List<ChangeRecord> records) {
      records.forEach((PropertyChangeRecord<bool> record) {
        if (record.name == #menuPossiblyOpened) {
          if (!record.newValue) {
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
    menuPossiblyOpened = true;
  }
}
