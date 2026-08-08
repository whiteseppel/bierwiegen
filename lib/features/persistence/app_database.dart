import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

/// Opens the app's local sembast database in the platform documents directory.
/// Uses the IO factory, so this targets mobile/desktop; a web build would need
/// `sembast_web`'s factory instead.
Future<Database> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return databaseFactoryIo.openDatabase('${dir.path}/bierwiegen.db');
}
