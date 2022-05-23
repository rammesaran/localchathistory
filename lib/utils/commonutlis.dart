class CommonUtils {
  String queryBuilder(
      String operationMode, String tableName, String attributes) {
    late String query;
    if (operationMode == "CREATE") {
      query = "CREATE TABLE " + tableName + "(" + attributes + ")";
    }
    return query;
  }
}
