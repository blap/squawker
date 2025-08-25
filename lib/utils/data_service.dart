
class DataService {

  final Map<String, dynamic> map = {};

  static final DataService _instance = DataService._();

  factory DataService() {
    return _instance;
  }

  DataService._();

}
