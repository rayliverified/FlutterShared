import 'dart:async';

import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/utils/network_provider.dart';

class GroupChatRepository {
  /*
   * Load Group Chat Items.
   *
   * Loading message [request_type]:
   * - latest: initial load
   * - greater_than: load new items based on latest [paginationId].
   * - less_than: paginate items based on oldest [paginationId].
   * [limit] max items returned.
   */
  Future<ResponseWrapper> getGroupChat(int groupId,
      {String requestType = "latest", int limit, int paginationId}) async {
    try {
      DataResponse statusResponse = await networkProvider.getGroupChatMessages(
          groupId, requestType,
          limit: limit, paginationId: paginationId);
      if (statusResponse.status != null) {
        Map<String, dynamic> data = statusResponse.data;
        print("Data $data");
        List<GroupChatItemModel> messages =
            GroupChatItemModel.listDeserializer(data["messages"]);
        GroupChatsModel groupChats = GroupChatsModel(messages: messages);
        return ResponseWrapper(StatusResponse.success(), object: groupChats);
      }
      return ResponseWrapper(statusResponse);
    } on Exception catch (e) {
      print(e);
    }
  }
}
