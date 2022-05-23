import 'package:localchathistory/data/tableobjects.dart';
import 'package:localchathistory/utils/commonutlis.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  CommonUtils commonUtils = CommonUtils();

  List<Map<String, dynamic>> chatData = [
    {
      "description": 'Bob',
    },
    {
      "description": 'aaa',
    },
    {
      "description": 'dfdf',
    },
    {
      "description": 'rererw',
    },
    {
      "description": 'ewrew',
    },
  ];

  factory DatabaseHelper() => _instance;
  Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Sqflite.setDebugModeOn(true);
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "chathistory.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);

    return theDb;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(commonUtils.queryBuilder(
        "CREATE", TableObjects.tbchatHistory, TableObjects.attrlabor));
    saveChatResult(chatData);
  }

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
      print("the exception is $exception ad trace is $stacktrace");
    }
  }

  Future<List> getChatData() async {
    var dbClient = await db;
    try {
      List contractList = await dbClient!.rawQuery(
          "select * from ${TableObjects.tbchatHistory} order by tchatid desc");

      return contractList;
    } catch (exception, stacktrace) {
      print("the exception is $exception ad trace is $stacktrace");

      return [];
    }
  }

  Future insertChatMessage(Map<String, dynamic> chatData) async {
    var dbClient = await db;
    dbClient!.insert(TableObjects.tbchatHistory, chatData);
  }
}
