import '../../app/generalImports.dart';

class PromocodeRepository {
  Future<DataOutput<PromocodeModel>> fetchPromocodes({
    required int offset,
  }) async {
    final Map<String, dynamic> response = await Api.post(
        url: Api.getPromocodes,
        parameter: {Api.limit: Constant.limit, Api.offset: offset},
        useAuthToken: true,);
    final List<PromocodeModel> promocodeList = (response['data'] as List).map((value) {
      return PromocodeModel.fromJson(value);
    }).toList();

    return DataOutput<PromocodeModel>(
        total: int.parse(response['total'] ?? '0' ?? '0'), modelList: promocodeList,);
  }

  Future createPromocode(
    CreatePromocodeModel model,
  ) async {
    final Map<String, dynamic> parameters = model.toJson();
    if (parameters['image'] != null) {
      parameters['image'] = await MultipartFile.fromFile(parameters['image'].path);
    }
    final Map<String, dynamic> response = await Api.post(
      url: Api.managePromocode,
      parameter: parameters,
      useAuthToken: true,
    );
    return response['data'];
  }

  Future<void> deletePromocode(int id) async {
    await Api.post(
      url: Api.deletePromocode,
      parameter: {'promo_id': id},
      useAuthToken: true,
    );
  }
}
