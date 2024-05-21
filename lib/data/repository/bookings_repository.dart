import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../app/generalImports.dart';

class BookingsRepository {
  //
  Future<DataOutput<BookingsModel>> fetchBooking({
    required int offset,
    required String? status,
  }) async {
    // Map<String, dynamic> parameters = {Api.page: pageNumber};

    final Map<String, dynamic> response = await Api.post(
        url: Api.getBookings,
        parameter: {
          Api.limit: Constant.limit,
          Api.offset: offset,
          Api.status: status,
          'order': 'DESC'
        },
        useAuthToken: true,);
    List<BookingsModel> modelList;
    if (response['data'].isEmpty) {
      modelList = [];
    } else {
      //creating model list from json
      modelList = (response['data']['data'] as List).map((element) {
        return BookingsModel.fromJson(element);
      }).toList();
    }

//adding model list and total count to data output class
    return DataOutput<BookingsModel>(
      total: int.parse(response['total'] ?? '0'),
      modelList: modelList,
    );
  }

  Future<Map<String, dynamic>> updateBookingStatus(
      {required int orderId,
      required int customerId,
      required String status,
      required String otp,
      List<Map<String, dynamic>>? proofData,
      String? date,
      String? time,}) async {
    try {
      final Map<String, dynamic> parameters = {
        'order_id': orderId,
        'customer_id': customerId,
        'status': status
      };
      if (date != null && time != null) {
        parameters['date'] = date;
        parameters['time'] = time;
      }

      if (otp != '' && status == 'completed') {
        parameters['otp'] = otp;
      }

      if (proofData != null) {
        final List list = [];
        for (int i = 0; i < proofData.length; i++) {
          final element = proofData[i]['file'];

          final MultipartFile imagePart = await MultipartFile.fromFile(element.path,
              filename: p.basename(element.path),
              contentType: MediaType('image', proofData[i]['fileType']),);
          list.add(imagePart);
          if (status == 'started') {
            parameters['work_started_files[$i]'] = imagePart;
          } else {
            parameters['work_complete_files[$i]'] = imagePart;
          }
        }
      }
      final Map<String, dynamic> response =
          await Api.post(url: Api.updateBookingStatus, parameter: parameters, useAuthToken: true);

      return {'error': response['error'], 'message': response['message'], 'data': response['data']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<DataOutput<TimeSlotModel>> getAllTimeSlots(String date) async {
    try {
      final Map<String, dynamic> response = await Api.post(
        url: Api.getAvailableSlots,
        parameter: {Api.date: date},
        useAuthToken: true,
      );

      final List<TimeSlotModel> timeSlotList = (response['data']['all_slots'] as List).map((element) {
        return TimeSlotModel.fromMap(element);
      }).toList();
      // TimeSlotModel timeSlotModel = TimeSlotModel.fromJson(response['data']);

      return DataOutput<TimeSlotModel>(
          total: 0,
          modelList: timeSlotList,
          extraData: ExtraData(data: {
            'error': response['error'],
            'message': response['message'],
          },),);
    } catch (e) {
      rethrow;
    }
  }
}
