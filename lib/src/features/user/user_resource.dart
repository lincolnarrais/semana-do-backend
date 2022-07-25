import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import '../../core/services/database/remote_database.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUsers),
        Route.get('/user/:id', _getUserById),
        Route.post('/user', _createUser),
        Route.put('/user', _updateUser),
        Route.delete('/user/:id', _deleteUser),
      ];

  FutureOr<Response> _getAllUsers(Injector injector) async {
    final database = injector.get<RemoteDatabase>();
    final queryText = 'SELECT id, name, email, role FROM "User";';
    final result = await database.query(queryText);
    final userList = result.map((e) => e['User']).toList();
    return Response.ok(jsonEncode(userList));
  }

  FutureOr<Response> _getUserById(
      ModularArguments arguments, Injector injector) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    final queryText = 'SELECT id, name, email, role'
        ' FROM "User"'
        ' WHERE id = @id;';
    final result = await database.query(queryText, variables: {'id': id});
    final userMap = result.map((e) => e['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _createUser(
      ModularArguments arguments, Injector injector) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>()
      ..remove('id');
    final database = injector.get<RemoteDatabase>();
    final queryText = 'INSERT INTO "User"'
        ' (name, email, password)'
        ' VALUES (@name, @email, @password)'
        ' RETURNING id, name, email, role;';
    final result = await database.query(queryText, variables: userParams);
    final userMap = result.map((e) => e['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _updateUser(
      ModularArguments arguments, Injector injector) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();

    final columns = userParams.keys
        .where((key) => key != 'id' || key != 'password')
        .map((key) => '$key=@$key')
        .toList();

    final database = injector.get<RemoteDatabase>();
    final queryText =
        'UPDATE "User" SET ${columns.join(', ')} WHERE id = @id RETURNING id, name, email, role;';
    final result = await database.query(queryText, variables: userParams);
    final userMap = result.map((e) => e['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _deleteUser(
      ModularArguments arguments, Injector injector) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    final queryText = 'DELETE FROM "User" WHERE id = @id;';
    final result = await database.query(queryText, variables: {'id': id});
    return Response.ok(jsonEncode({'message': 'deleted $id'}));
  }
}
