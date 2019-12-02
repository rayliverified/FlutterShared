import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nocd/channel_events.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_post.dart';
import 'package:nocd/model/model_post_thread.dart';
import 'package:nocd/model/model_reply_to.dart';
import 'package:nocd/page/feed/feed_components.dart';
import 'package:nocd/page/feed/feed_post.dart';
import 'package:nocd/page/feed/page_post_thread_loaded.dart';
import 'package:nocd/page/feed/post_thread_event.dart';
import 'package:nocd/page/feed/post_thread_state.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/repository/repository_feed.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart' as prefix0;
import 'package:nocd/utils/error_helper.dart';
import 'package:nocd/utils/network_provider.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:nocd/utils/utils_text.dart';
import 'package:rxdart/rxdart.dart';

class PostThreadBloc extends Bloc<PostThreadEvent, PostThreadState> {
  AppBloc appBloc;
  FeedRepository feedRepository;
  int postId;
  BuildContext context;
  PostThread postThread;
  Timer _debounce;
  FocusNode replyTextFocus = FocusNode();
  TextEditingController replyTextController;
  ScrollController postThreadController;
  ReplyTo replyTo;
  StreamController<ReplyTo> replyToController = StreamController();
  Stream get getReplyTo => replyToController.stream;
  StreamSubscription backEventListener;

  PostThreadBloc(BuildContext context, int postId) {
    this.context = context;
    appBloc = prefix0.BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      Navigator.maybePop(context);
    });
    feedRepository = FeedRepository();
    replyTextController = TextEditingController();
    postThreadController = ScrollController();
    if (postId == null) {
      this.postId = getPostId(appBloc.data);
    } else {
      this.postId = postId;
    }
    if (this.postId > 0) {
      add(PostThreadGetData());
    } else {
      // Default to [PostThreadLoadingState] and show error.
      showError("Invalid Post ID: ${this.postId}");
    }
    showKeyboard();
  }

  @override
  Future<void> close() {
    backEventListener.cancel();
    _debounce?.cancel();
    replyTextFocus.dispose();
    replyTextController.dispose();
    postThreadController.dispose();
    replyToController.close();
    return super.close();
  }

  @override
  PostThreadState get initialState => PostThreadLoadingState();

  @override
  Stream<PostThreadState> mapEventToState(PostThreadEvent event) async* {
    print("State type: ${state}");
    if (event is PostThreadGetData) {
      yield* postThreadRefresh();
    }
    if (event is PostThreadRefresh) {
      yield* postThreadRefresh();
    }
    if (event is PostLike) {
      print("Liked: ${event.like}");
      StatusResponse response =
          await networkProvider.postLike(event.postId, event.like);
      if (response.error?.errorMessage != null) {
        showError(response.error?.errorMessage);
        return;
      }
      postThreadRefreshDebounce();
    }
    // Set ReplyTo object and update UI.
    if (event is PostComment) {
      print("Comment: ${event.replyTo.id}");
      updateReplyTo(event.replyTo);
    }
    if (event is PostBookmark) {
      print("Bookmark: ${event.postId}");
      StatusResponse response =
          await networkProvider.postPostBookmark(event.postId, event.bookmark);
      if (response.error?.errorMessage != null) {
        showError(response.error?.errorMessage);
        return;
      }
      postThreadRefreshDebounce();
    }
    // Remove post and update UI.
    if (event is PostDelete) {
      print("Delete: ${event.postId}");
      StatusResponse response = await networkProvider.deletePost(event.postId);
      if (response.error?.errorMessage != null) {
        showError(response.error?.errorMessage);
        return;
      }
      // Immediately refresh posts.
      yield* postThreadRefresh();
    }
    // Navigate to native Flag Post screen.
    if (event is PostReport) {
      Map<String, dynamic> data = {
        "event": EVENT_POST_REPORT,
        "post_id": event.postId
      };
      appBloc.sendFlutterEvent(data);
    }
    // Send Reply to server and update UI with reply animation.
    if (event is PostReply) {
      print("Reply: ${event.text}");
      print("Reply ID: ${replyTo?.id}");
      // Save reply object because original needs to be cleared.
      ReplyTo replyToHolder = replyTo;
      // Clear reply and reset UI.
      replyTextController.text = "";
      updateReplyTo(null);
      // Create reply copy.
      List<PostModel> repliesHolder = postThread.replies;
      // Display different UI animation depending on reply level.
      // 1. Reply to header - replyToHolder/id is null and placeholder reply is added.
      // 2. Reply to reply - id is not null and placeholder is added to thread.
      if (replyToHolder?.id != null) {
        PostModel replyItem =
            repliesHolder.firstWhere((i) => i.id == replyToHolder.id);
        int replyIndex = 0;
        if (replyItem.replies.length == 0) {
          replyIndex = repliesHolder.indexWhere((i) => i.id == replyItem.id);
        } else {
          replyIndex = repliesHolder
              .lastIndexWhere((i) => i.postRepliedTo == replyItem.id);
        }
        repliesHolder.insert(
            replyIndex + 1, PostModel(depth: 2, loading: true));
      } else {
        // Add placeholder reply.
        repliesHolder.add(PostModel(loading: true));
      }
      // Update post thread with new replies.
      postThread = postThread.copyWith(replies: repliesHolder);
      // Update UI with placeholder reply immediately.
      yield PostThreadRefreshingState(postThread: postThread);
      // Reply to header post behavior.
      if (replyToHolder?.id == null) {
        // Jump immediately to bottom because there could be a lot of replies.
        // Scrolling to bottom creates a floating behavior when scroll distance is large.
        postThreadController
            .jumpTo(postThreadController.position.maxScrollExtent);
        // Smooth scroll reply into final position.
        scrollToBottomAsync(postThreadController, 300);
      } else {
        TextUtils().textFieldFocusToggle(context, replyTextFocus, false);
      }
      // Send reply to server.
      StatusResponse response = await networkProvider
          .postReply(postId, event.text, replyId: replyToHolder?.id);
      if (response.error?.errorMessage != null) {
        showError(response.error?.errorMessage);
        return;
      }
      // Immediately refresh posts.
      yield* postThreadRefresh();
      // Reply to header post behavior.
      if (replyToHolder?.id == null) {
        // Smooth scroll to final position because placeholder
        // and actual reply size is not exactly the same.
        scrollToBottomAsync(postThreadController, 100);
      }
    }
  }

  @override
  Stream<PostThreadState> transformEvents(
    Stream<PostThreadEvent> events,
    Stream<PostThreadState> Function(PostThreadEvent event) next,
  ) {
    print("Event type: ${(events as Observable<PostThreadEvent>)}");
    if ((events as Observable<PostThreadEvent>) is PostThreadRefresh) {
      return super.transformEvents(
        (events as Observable<PostThreadEvent>).debounceTime(
          Duration(milliseconds: 5000),
        ),
        next,
      );
    }

    return super.transformEvents(events, next);
  }

  /**
   * Get refreshed [PostThread] from server.
      */
  Stream<PostThreadState> postThreadRefresh() async* {
    //Cancel any ongoing queued events.
    _debounce?.cancel();
    ResponseWrapper response = await feedRepository.getPostThread(postId);
    if (response.statusResponse.status != null) {
      postThread = response.object;
    } else {
      showError(response.statusResponse.error.errorMessage);
      return;
    }
    if (state is PostThreadLoadedState) {
      yield PostThreadRefreshingState(postThread: postThread);
    } else {
      yield PostThreadLoadedState(postThread: postThread);
    }
  }

  /**
    * Delay UI update for 1000 milliseconds.
    *
    * Delay UI to give animations enough time to complete.
    */
  void postThreadRefreshDebounce() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      add(PostThreadRefresh());
    });
  }

  void showError(String errorMessage) {
    // PostFrameCallback enables dialog on page load error.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      alertError(context, errorMessage, () {
        add(PostThreadGetData());
        Navigator.pop(context);
      });
    });
  }

  /**
     * Update Reply To tag and keyboard focus.
     *
     * Update reply tag to [replyTo] value.
     * If [replyTo] is null, hide tag and keyboard.
     */
  void updateReplyTo(ReplyTo replyTo) {
    this.replyTo = replyTo;
    replyToController.sink.add(replyTo);
    if (replyTo != null) {
      TextUtils().textFieldFocusToggle(context, replyTextFocus, true);
    }
  }

  int getPostId(String data) {
    // Set route if data is not empty.
    if (data.isNotEmpty) {
      try {
        Map jsonMap = json.decode(data);
        if (jsonMap.containsKey("post_id")) {
          return parseToInt(jsonMap["post_id"]);
        }
      } on FormatException catch (e) {
        ErrorHelper().reportException(e);
      }
    }

    return -1;
  }

  void openUserProfile(BuildContext context, int userId) async {
    backEventListener.cancel();
    final userProfilePage = UserProfilePageWrapper(userId: userId);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => userProfilePage),
    ).then((_) => {
          backEventListener = appBloc.backEventController.listen((_) {
            print("User Profile Back Event Received");
            Navigator.maybePop(context);
          })
        });
  }

  void showKeyboard() {
    Timer(Duration(seconds: 3), () {
      replyTextFocus.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
      showKeyboard();
    });
  }
}

class PostThreadPage extends StatelessWidget {
  final int postId;

  PostThreadPage({Key key, this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BlocProvider(
          builder: (context) => PostThreadBloc(context, postId),
          child: BlocBuilder<PostThreadBloc, PostThreadState>(
            builder: (context, state) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BackHelper(
                          child: BackButtonCustom(
                              Image.asset(
                                "assets/images/back_blue.png",
                              ),
                              () => BackHelper.navigateBack(context)),
                        ),
                        if (state is PostThreadLoadingState)
                          FeedPost(PostModel(loading: true)),
                        if (state is PostThreadRefreshingState) ...[
                          PostThreadLoadedPage(),
                        ],
                        if (state is PostThreadLoadedState) ...[
                          PostThreadLoadedPage(),
                        ]
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ReplyBox(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
