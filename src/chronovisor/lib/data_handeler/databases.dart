import 'dart:io';

import 'package:path/path.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';


part 'databases.g.dart';



class ArchivesTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get user => text()();
}

@DriftDatabase(tables: [ArchivesTable])
class ArchivesDatabase extends _$ArchivesDatabase 
{
  ArchivesDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() 
  {
    final file = File(join('save', 'archives.sqlite'));
    final absolutePath = file.absolute;

    return NativeDatabase(absolutePath);
  }
}

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
class MessagesDatabase extends _$ArchivesDatabase 
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