import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/utils_mock_data.dart';

/**
 * A network data provider to handler endpoints and network requests.
 *
 * Dio is the HTTP library used to make network requests.
 * Initialize [NetworkProvider] with baseURL endpoint.
 * To make a network request to a non-baseURL endpoint, use the full URL.
 */
class NetworkProviderMock {
  NetworkProviderMock() {}

  // BEGIN Mock Responses
  Future<StatusResponse> getMockSuccessSimple() async {
    return Future.delayed(Duration(milliseconds: 500), () {
      return StatusResponse.success();
    });
  }

  Future<StatusResponse> getMockErrorNoConnection() async {
    return StatusResponse.withError(ErrorWrapper.errorCode(7));
  }
  // END Mock Responses

  // BEGIN Group
  Future<DataResponse> getMockGroupChat(int group_id,
      {int limit = 40, int offset = 0}) async {
    Map<String, dynamic> data = Map<String, dynamic>();
    data["messages"] = groupChats;
    return DataResponse.fromData(data);
  }
  // End Group
}
