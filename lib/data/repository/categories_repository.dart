import '../../app/generalImports.dart';

class CategoriesRepository {
  Future<DataOutput<CategoryModel>> fetchCategories({
    required int offset,
    required int limit,
  }) async {
    final Map<String, dynamic> response = await Api.post(
        url: Api.getServiceCategories,
        parameter: {/*Api.offset: offset, Api.limit: limit*/},
        useAuthToken: true,);

    final List<CategoryModel> result = (response['data'] as List).map((element) {
      return CategoryModel.fromJson(element);
    }).toList();

    return DataOutput<CategoryModel>(total: int.parse(response['total'] ?? '0'), modelList: result);
  }
}
