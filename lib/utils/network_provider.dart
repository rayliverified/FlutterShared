import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_notification_settings.dart';
import 'package:nocd/model/model_user_profile.dart';
import 'package:nocd/page/data_collection/page_data_collection.dart';
import 'package:nocd/page/feed/page_post_thread.dart';
import 'package:nocd/page/notifications/page_notifications.dart';
import 'package:nocd/page/page_delete_account.dart';
import 'package:nocd/utils/utils_misc.dart';

/**
 * A network data provider to handler endpoints and network requests.
 *
 * Dio is the HTTP library used to make network requests.
 * Initialize [NetworkProvider] with baseURL endpoint.
 * To make a network request to a non-baseURL endpoint, use the full URL.
 */
class NetworkProvider {
  Dio _dio;
  final String endpoint;
  final String accessToken;

  NetworkProvider(this.endpoint, this.accessToken) {
    print("Init NetworkProvider: " + this.endpoint ??
        "NULL endpoint" + " " + this.accessToken ??
        "NULL acess token");
    BaseOptions options = new BaseOptions(
        baseUrl: this.endpoint, headers: {"Authorization": this.accessToken});
    _dio = Dio(options);
  }

  /// Handle Dio errors and log request details.
  /// Returns the error code or -1 if error code is null.
  int _getErrorCode(DioError e) {
    print("Exception occured:");
    //Send error to error reporting.
    errorHelper.reportError(e.error, e.stackTrace);
    //The request was made and the server responded with a status code that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      print("Error Data [" + e.response.data.toString() + "]");
      print("Error Code [" + e.response.statusCode.toString() + "]");
      print(e.response.headers);
      print(e.response.request);

      return e.response.statusCode;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Response Null");
      print(e.request);
      print(e.message);
      if (e.error != null && e.error is SocketException) {
        print("Error Code [" +
            (e.error as SocketException).osError.errorCode.toString() +
            "]");
        return (e.error as SocketException).osError.errorCode;
      }
    }

    return -1;
  }

  /// If the error contains an error message, display error message to user.
  String _getErrorMessage(DioError e) {
    if (e.response != null && e.response.data != null) {
      if (e.response.data is String) {
        return e.response.data;
      } else if (e.response.data.containsKey("message")) {
        return e.response.data["message"];
      }
    }

    return "";
  }

  StatusResponse _getErrorResponse(DioError e) {
    //Error codes are known errors, priority handling.
    int errorCode = _getErrorCode(e);
    if (errorCode == 7 || errorCode == 8) {
      return StatusResponse.withError(ErrorWrapper.errorCode(errorCode));
    }
    //Handle error message.
    String errorMessage = _getErrorMessage(e);
    if (errorMessage != "") {
      return StatusResponse.withError(ErrorWrapper(errorMessage));
    }
    //No know error code or bundled message. Return error object message.
    return StatusResponse.withError(ErrorWrapper(e.message));
  }

  /// [DeleteAccountPage.buildDeleteAccountPage1]
  Future<StatusResponse> postFeedback(String feedback, String source,
      {String metadata = ""}) async {
    try {
      return postStatusResponseRequest(
        "v1/feedback",
        data: json.encode(
            {"feedback": feedback, "source": source, "metadata": metadata}),
      );
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  // BEGIN [DeleteAccountPage]
  /// [DeleteAccountPage.buildDeleteAccountPage2]
  Future<StatusResponse> postDeleteAccount() async {
    try {
      return postStatusResponseRequest("delete_account");
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }
  // END [DeleteAccountPage]

  // BEGIN [DataCollectionBloc]
  /// [DataCollectionBloc]
  // ignore: non_constant_identifier_names
  Future<StatusResponse> getDataCollectionInput(String flow_type) async {
    return getDataResponseRequest("v1/data_profile?flow_type=$flow_type");
  }

  Future<StatusResponse> postDataProfile(Object payload) async {
    try {
      return postStatusResponseRequest("v1/data_profile",
          data: json.encode(payload));
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  Future<StatusResponse> postTreatmentRecommendationClick(
      String recommendation) async {
    try {
      return postStatusResponseRequest("v1/treatment_recommendation_clicks",
          data: json.encode({"recommendation": recommendation}));
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }
  // END [DataCollectionBloc]

  // BEGIN [UserProfileBloc]
  /// [UserProfileBloc]
  Future<StatusResponse> getUserProfile(int user_id) async {
    return getDataResponseRequest("v1/community/user_profile?user_id=$user_id");
  }

  Future<StatusResponse> postUserProfile(UserProfileModel model) async {
    try {
      return postStatusResponseRequest("v1/community/user_profile",
          data: model.toJson());
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  Future<StatusResponse> getUserData() async {
    return getDataResponseRequest("/v1/user_data");
  }
  // END [UserProfileBloc]

  // BEGIN [PostThreadBloc]
  /// [PostThreadBloc]
  Future<StatusResponse> getPostThread(int postId) async {
    return getDataResponseRequest("v1/posts/$postId");
  }

  Future<StatusResponse> postLike(int postId, bool like) async {
    return like
        ? postStatusResponseRequest("v1/posts/$postId/like")
        : deleteStatusResponseRequest("v1/posts/$postId/like");
  }

  Future<StatusResponse> postPostBookmark(int postId, bool bookmark) async {
    return postStatusResponseRequest("v1/community/bookmarks",
        data: json.encode({"postID": postId, "delete": !bookmark}));
  }

  Future<StatusResponse> deletePost(int postId) async {
    return deleteStatusResponseRequest("v1/posts/$postId");
  }

  Future<StatusResponse> postReply(int postId, String reply,
      {int replyId}) async {
    try {
      return postStatusResponseRequest("v1/posts/$postId/reply",
          data: json.encode({"body": reply, "reply_id": replyId}));
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }
  // END [FeedThreadBloc]

  // BEGIN [NotificationsBloc]
  /// [NotificationsBloc]
  Future<StatusResponse> getNotifications() async {
    try {
      Response response = await _dio.get("v1/notifications?group_by_thread=0");
      NetworkUtils.debugPrintResponse(response);
      return DataResponse.fromData(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  Future<StatusResponse> getNotificationSettings() async {
    try {
      Response response = await _dio.get("v1/notification_settings");
      NetworkUtils.debugPrintResponse(response);
      return DataResponse.fromData(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  Future<StatusResponse> postNotificationSettings(
      NotificationSettingsModel model) async {
    try {
      Response response =
          await _dio.post("v1/notification_settings", data: model.toJson());
      NetworkUtils.debugPrintResponse(response);
      return DataResponse.fromData(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }
  // END [NotificationsBloc]

  /// BEGIN [Group Chat]
  Future<StatusResponse> getGroupChatHome() async {
    return getDataResponseRequest("v1/group_chat/screen_launch");
  }

  Future<StatusResponse> getGroupInformation(int groupId) async {
    return getDataResponseRequest("v1/group_chat/group?group_id=$groupId");
  }

  Future<StatusResponse> getGroupDailyModule(int groupId) async {
    return getDataResponseRequest(
        "/v1/group_chat/daily_module?group_id=$groupId");
  }

  Future<StatusResponse> postJoinGroup(int groupId) async {
    return postStatusResponseRequest("v1/group_chat/group/join",
        data: json.encode({"group_id": groupId}));
  }

  Future<StatusResponse> postLeaveGroup(int groupId) async {
    return postStatusResponseRequest("v1/group_chat/group/leave",
        data: json.encode({"group_id": groupId}));
  }

  Future<StatusResponse> getGroupChatMessages(int groupId, String requestType,
      {int limit, int paginationId}) async {
    return getDataResponseRequest(
        "/v1/group_chat/chat?group_id=$groupId&request_type=$requestType&limit=$limit&pagination_id=$paginationId");
  }

  Future<StatusResponse> postGroupChatMessage(
      int groupId, String message, String traceId) async {
    try {
      Response response = await _dio.post("/v1/group_chat/chat",
          data: json.encode({"group_id": groupId, "message": message}),
          options: Options(headers: {"X-TraceID": traceId}));
      NetworkUtils.debugPrintResponse(response);
      return StatusResponse.fromJsonMap(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  Future<StatusResponse> postDeleteGroupChatMessage(int id) {
    return deleteStatusResponseRequest("v1/group_chat/chat?message_id=$id");
  }

  /// Report message by [message_id].
  /// Set report [category] and [reason].
  Future<StatusResponse> postReportMessage(
      int message_id, String category, String reason) async {
    return postStatusResponseRequest("v1/group_chat/report",
        data: json.encode({"message_id": message_id, "category": category, "comment": reason}));
  }

  Future<StatusResponse> getGroupNotificationEnabled(int groupId) {
    return getDataResponseRequest(
        "v1/group_chat/notifications_enabled?group_id=$groupId");
  }

  Future<StatusResponse> postGroupNotificationEnabled(
      int groupId, bool enabled) {
    return postStatusResponseRequest("v1/group_chat/notifications_enabled",
        data: json.encode({
          "group_id": groupId,
          "group_chat_notifications_enabled": enabled
        }));
  }

  /// END [Group Chat]

  /// A request wrapper for [StatusResponse] with try/catch error handling.
  Future<StatusResponse> postStatusResponseRequest(String endpoint,
      {String data}) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      NetworkUtils.debugPrintResponse(response);
      return StatusResponse.fromJsonMap(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  /// A request wrapper for [StatusResponse] with try/catch error handling.
  Future<StatusResponse> deleteStatusResponseRequest(String endpoint) async {
    try {
      Response response = await _dio.delete(endpoint);
      NetworkUtils.debugPrintResponse(response);
      return StatusResponse.fromJsonMap(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }

  /// A request wrapper for [DataResponse] with try/catch error handling.
  Future<StatusResponse> getDataResponseRequest(String endpoint) async {
    try {
      Response response = await _dio.get(endpoint);
      NetworkUtils.debugPrintResponse(response);
      return DataResponse.fromData(response.data);
    } on DioError catch (e) {
      return _getErrorResponse(e);
    }
  }
}

/***
 * A response wrapper for simple success/failure requests.
 *
 * This callback wrapper returns success [status]
 * or a preprocessed [error] message.
 * Success and Error are mutually exclusive variables.
 */
class StatusResponse {
  final String status;
  final ErrorWrapper error;

  StatusResponse.fromJsonMap(Map<String, dynamic> map)
      : status = map["status"],
        error = null;

  StatusResponse.success()
      : status = "OK",
        error = null;

  StatusResponse.withError(ErrorWrapper error)
      : status = null,
        this.error = error;
}

/***
 * A response wrapper that returns request data.
 *
 * Extends [StatusResponse] type to support error handling.
 * This callback wrapper returns [data] as a [Map].
 */
class DataResponse extends StatusResponse {
  final Map data;

  DataResponse.fromData(Map<String, dynamic> map)
      : data = map,
        super.fromJsonMap({"status": "OK"});
}

/// Error types.
enum ErrorCode { NO_CONNECTION }

/**
 * A class to format error responses.
 *
 * Returns an [ErrorCode] enum for type switching
 * and a [errorMessage].
 */
class ErrorWrapper {
  ErrorCode errorCode;
  String errorMessage = "";

  /// Set [errorMessage].
  ErrorWrapper(String errorMessage) {
    this.errorMessage = errorMessage;
  }

  /// Map error code to [ErrorCode] type and [errorMessage].
  ErrorWrapper.errorCode(int errorCode) {
    switch (errorCode) {
      case 7:
      case 8:
        this.errorCode = ErrorCode.NO_CONNECTION;
        this.errorMessage = "No connection";
        break;
      default:
        break;
    }
  }
}

class ResponseWrapper {
  StatusResponse statusResponse;
  Object object;

  ResponseWrapper(this.statusResponse, {this.object});
}
