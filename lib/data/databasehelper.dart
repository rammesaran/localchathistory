import 'package:localchathistory/data/tableobjects.dart';
import 'package:localchathistory/utils/commonutlis.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  CommonUtils commonUtils = CommonUtils();

  factory DatabaseHelper() => _instance;
  Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

//initalize the DB
  initDb() async {
    Sqflite.setDebugModeOn(true);
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "chathistory.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);

    return theDb;
  }

// Creating the tables
  Future _onCreate(Database db, int version) async {
    await db.execute(commonUtils.queryBuilder(
        "CREATE", TableObjects.tbchatHistory, TableObjects.attrlabor));
  }

//inserting the bulk chat message
  Future saveChatResult(dynamic chatResults) async {
    var dbClient = await db;
    try {
      if (chatResults.isNotEmpty) {
        for (int i = 0; i < chatResults.length; i++) {
          await dbClient!.insert(TableObjects.tbchatHistory, chatResults[i],
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    } catch (exception, stacktrace) {
      print("exception in saveChatResult $exception and trace is $stacktrace");
    }
  }

  //insert while sending messages

  Future insertChatMessage(Map<String, dynamic> chatData) async {
    try {
      var dbClient = await db;
      dbClient!.insert(TableObjects.tbchatHistory, chatData);
    } catch (exception, stacktrace) {
      print(
          "exception in insertChatMessage $exception and trace is $stacktrace");
    }
  }

//getting total message count
  Future<int> getmessageCount() async {
    try {
      var dbClient = await db;
      late List getChatList;

      getChatList = await dbClient!
          .rawQuery("select count(*) as chatcount from tchathistory");
      return getChatList[0]['chatcount'];
    } catch (exception, stacktrace) {
      print("exception in getChatCount $exception and trace is $stacktrace");
      return 0;
    }
  }

//Fetch the chat message based on pagination
  Future<List<Map<String, dynamic>>> fetchChatMessage(
      {required int limit}) async {
    var dbClient = await db;
    try {
      List fetchedChatMessage = [];
      late List<Map<String, dynamic>> resultList = <Map<String, dynamic>>[];

      fetchedChatMessage = await dbClient!.rawQuery(
          "select * from tchathistory order by tchatid desc limit $limit ,20");
      for (int i = 0; i < fetchedChatMessage.length; i++) {
        resultList.add(Map.from(fetchedChatMessage[i]));
      }
      return resultList;
    } catch (exception, stacktrace) {
      print("exception in getChatCount $exception and trace is $stacktrace");
      return [];
    }
  }
}
