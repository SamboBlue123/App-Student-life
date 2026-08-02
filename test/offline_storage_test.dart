import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appstudentlife/services/offline_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores and loads notes offline', () async {
    SharedPreferences.setMockInitialValues({});

    await OfflineStorage.addNote('Review math formulas');
    await OfflineStorage.addNote('Pack laptop charger');

    final notes = await OfflineStorage.loadNotes();

    expect(notes, ['Review math formulas', 'Pack laptop charger']);
  });
}
