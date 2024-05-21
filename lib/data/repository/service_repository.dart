import '../../app/generalImports.dart';

class ServiceRepository {
  //
  Future<DataOutput<ServiceModel>> fetchService({
    required int offset,
    String? searchQuery,
    ServiceFilterDataModel? filter,
  }) async {
    //pass filter data in parms

    final Map<String, dynamic> parameters = {Api.offset: offset};

    if (searchQuery != null) {
      parameters[Api.search] = searchQuery;
      parameters.remove(Api.offset);
    }

    if (filter != null) {
      parameters.addAll(filter.toMap());
    }
    /*  if (parameters["max_budget"] == "1.0" && parameters["min_budget"] == "0.0") {
      parameters.remove("min_budget");
      parameters.remove("max_budget");
    }*/
    final Map<String, dynamic> response = await Api.post(
      url: Api.getServices,
      parameter: parameters,
      useAuthToken: true,
    );

    final List<ServiceModel> modelList =
    (response['data'] as List).map((element) {
      return ServiceModel.fromJson(element);
    }).toList();
    return DataOutput<ServiceModel>(
      extraData: ExtraData(
        data: {
          'max_price': response['max_price'],
          'min_price': response['min_price'],
          'min_discount_price': response['min_discount_price'],
          'max_discount_price': response['max_discount_price'],
        },
      ),
      total: int.parse(
        response['total'] ?? '0',
      ),
      modelList: modelList,
    );
  }

//
  Future<DataOutput<ServiceCategoryModel>> fetchCategories({
    required int offset,
    required int limit,
  }) async {
    final Map<String, dynamic> parameters = {
      /*Api.limit: limit, Api.offset: offset*/
    };
    final Map<String, dynamic> response = await Api.post(
      url: Api.getServiceCategories,
      parameter: parameters,
      useAuthToken: true,);

    final List<ServiceCategoryModel> modelList =
    (response['data'] as List).map((element) {
      return ServiceCategoryModel.fromJson(element);
    }).toList();

    return DataOutput<ServiceCategoryModel>(
      total: int.parse(response['total'] ?? '0'),
      modelList: modelList,
    );
  }

  //
  Future<Map<String, dynamic>> fetchTaxes() async {
    final Map<String, dynamic> response =
    await Api.post(url: Api.getTaxes, parameter: {}, useAuthToken: true);

    final List<Taxes> taxesList = (response['data'] as List).map((element) {
      return Taxes.fromJson(element);
    }).toList();

    return {
      'taxesDataList': taxesList,
      'error': response['error'],
      'message': response['message']
    };
  }

//
  Future<ServiceModel> createService(CreateServiceModel dataModel) async {
    try {
      final Map<String, dynamic> parameters = dataModel.toJson();
      if (parameters['image'] != null && parameters['image'] != '') {
        parameters['image'] = await MultipartFile.fromFile(parameters['image']);
      }

      if (parameters.containsKey("other_images")) {
        for (int i = 0; i < parameters["other_images"].length; i++) {
          parameters['other_images[$i]'] =
          await MultipartFile.fromFile(parameters["other_images"][i]);
        }
      }
      if (parameters.containsKey("files")) {
        for (int i = 0; i < parameters["files"].length; i++) {
          parameters['files[$i]'] =
          await MultipartFile.fromFile(parameters["files"][i]);
        }
      }

      parameters.remove("other_images");
      parameters.remove("files");
      final Map<String, dynamic> response = await Api.post(
        url: Api.manageService,
        parameter: parameters,
        useAuthToken: true,
      );
      if (response['error']) {
        throw ApiException(response["message"].toString());
      }
      return ServiceModel.fromJson(response['data'][0]);
    }catch(e){
      throw ApiException(e.toString());
    }
  }

  Future<void> deleteService({required int id}) async {
    await Api.post(
      url: Api.deleteService,
      parameter: {Api.serviceId: id},
      useAuthToken: true,);
  }

  Future<DataOutput<ReviewsModel>> fetchReviews(int serviceId,
      {required int offset,}) async {
    final Map<String, dynamic> response = await Api.post(
      url: Api.getServiceRatings,
      parameter: {
        Api.serviceId: serviceId,
        Api.offset: offset,
        Api.limit: Constant.limit
      },
      useAuthToken: true,
    );

    final List<ReviewsModel> modelList = (response['data'] as List)
        .map((element) => ReviewsModel.fromJson(element))
        .toList();

    return DataOutput<ReviewsModel>(
      total: int.parse(
        response['total'] ?? '0',
      ),
      modelList: modelList,
      extraData: ExtraData<RatingsModel>(
        data: RatingsModel.fromJson(response['ratings'][0]),
      ),
    );
  }
}
