# TODO for Professor Login Implementation

- [x] Add shared_preferences dependency to pubspec.yaml
- [x] Update lib/login_screen.dart to save professorId locally after login
- [x] Update lib/professor_interface.dart to subscribe to "${professorId}/give_me_class" topic
- [x] Update lib/professor_interface.dart to handle received payload and populate professor details and classes
- [x] Update lib/professor_interface.dart UI to display name and firstname in navbar, grid of class-subject cards
- [x] Update lib/professor_interface.dart onTap to publish to "This_is_the_class" with payload
