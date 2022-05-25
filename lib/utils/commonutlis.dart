import 'package:shared_preferences/shared_preferences.dart';

class CommonUtils {
  static late SharedPreferences sharedPreferences;

  String queryBuilder(
      String operationMode, String tableName, String attributes) {
    late String query;
    if (operationMode == "CREATE") {
      query = "CREATE TABLE " + tableName + "(" + attributes + ")";
    }
    return query;
  }
}
