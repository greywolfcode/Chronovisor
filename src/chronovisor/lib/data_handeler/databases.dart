import 'dart:io';

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
    return NativeDatabase.createInBackground(File('save/archives.sqlite'));
  }
}