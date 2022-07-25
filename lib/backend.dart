import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'src/app_module.dart';

startShelfModular() {
  final handler = Modular(module: AppModule(), middlewares: [
    logRequests(),
  ]);
  return handler;
}
