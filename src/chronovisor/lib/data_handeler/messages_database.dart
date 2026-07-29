import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'messages_database.g.dart';


class MessagesTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get userType => text().nullable()();
  DateTimeColumn get createdDate => dateTime().nullable()();
  TextColumn get messageText => text().nullable()();
  TextColumn get topicId => text().nullable()();
  TextColumn get messageId => text().nullable()();
}

// Annotations Class
//---------------------
class AnnotationsTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId => integer().references(MessagesTable, #id)();
  IntColumn get startIndex => integer()();
  IntColumn get length => integer()();

  // Url Metadata
  TextColumn get imageUrl => text().nullable()(); 
  TextColumn get title => text().nullable()();
  TextColumn get snippet => text().nullable()();
  TextColumn get privateDoNotAccessOrElseSafeUrlWrappedValue => text().nullable()();

  // Video Call Metadata
  TextColumn get meetingUrl => text().nullable()();

  // Format Metadata
  TextColumn get formatType => text().nullable()();
}

// Attached Files Class
//----------------------
class FilesTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId => integer().references(MessagesTable, #id)();
  TextColumn get originalName => text()();
  TextColumn get exportName => text()();
}

// Reactions Classes
//-------------------
class ReactionTable extends Table
{
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reactionId => integer().references(ReactionTable, #id)();
  TextColumn get emails => text().map(const ReactionEmailConverter())();
  TextColumn get emoji => text()();
}
class ReactionEmailConverter extends TypeConverter<List<String>, String> 
{
  const ReactionEmailConverter();
  
  @override
  List<String> fromSql(String dbString)
  {
    List<String> emails = dbString.split("\n");
    return emails;
  }
  @override
  String toSql(List<String> emails)
  {
    StringBuffer sql = StringBuffer(); 

    for (String email in emails)
    {
      sql.writeln(email);
    }
    return sql.toString();
  }
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