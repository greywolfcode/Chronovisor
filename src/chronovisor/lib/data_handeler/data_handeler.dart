import 'databases.dart';

final _archiveDatabase = ArchivesDatabase();

Future<void> addArchive(String path, String user) async 
{
  await _archiveDatabase
      .into(_archiveDatabase.archivesTable)
      .insert(ArchivesTableCompanion.insert(path: path, user: user));
}

Future<List<ArchivesTableData>> getAllArchives() async
{
  return await _archiveDatabase.select(_archiveDatabase.archivesTable).get();
}
