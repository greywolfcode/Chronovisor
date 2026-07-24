import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';


part 'messages_database.g.dart';


class MessagesTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get userType => text()();
  DateTimeColumn get createdDate => dateTime()();
  TextColumn get messageText => text()();
  TextColumn get topicId => text()();
}

@DriftDatabase(tables: [MessagesTable])
class MessagesDatabase extends _$MessagesDatabase
{
  MessagesDatabase(File databasePath, [QueryExecutor? executor]) : super(executor ?? _openConnection(databasePath));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(File databasePath) 
  {
    final file = databasePath;
    final absolutePath = file.absolute;

    return NativeDatabase(absolutePath);
  }
}