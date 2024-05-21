import '../../app/generalImports.dart';

class StatisticsRepository {
  Future<StatisticsModel> fetchStatistics() async {
    try {
      final Map<String, dynamic> response =
          await Api.post(url: Api.getStatistics, parameter: {}, useAuthToken: true);

      return StatisticsModel.fromJson(response['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
