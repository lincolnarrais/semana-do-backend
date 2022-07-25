import 'package:backend/backend.dart' as backend;
import 'package:shelf/shelf_io.dart' as io;

Future<void> main(List<String> arguments) async {
  final handler = await backend.startShelfModular();
  final server = await io.serve(handler, '0.0.0.0', 4466);
  print('Online - ${server.address.address}:${server.port}');
}
