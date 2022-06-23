List<String> getListFromJSONArray(dynamic jsonArray) {
  List<String> list = [];
  try {
    list = (jsonArray as List).map((e) => e as String).toList();
  } catch (error) {
    1 + 1; //Nothing to do
  }
  return list;
}