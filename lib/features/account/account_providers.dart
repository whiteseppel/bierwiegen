import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The player's display name shown on the account screen. Kept in memory only;
/// the app persists no personal data.
final profileNameProvider = StateProvider<String>((_) => '');
