import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nocd/main.dart';
import 'package:nocd/model/model_group.dart';
import 'package:nocd/page/group_chat/page_group_chat.dart';
import 'package:nocd/ui/ui_components.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/back_helper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/utils_misc.dart';
import 'package:provider/provider.dart';

class GroupChatGuideline {
  final String title;
  final String body;
  bool isExpanded = false;

  GroupChatGuideline(this.title, this.body);
}

class GroupChatGuidelinesPageModel with ChangeNotifier {
  AppBloc appBloc;
  BuildContext buildContext;
  StreamSubscription backEventListener;

  final String screenEventName = "group_chat_guidelines";
  final bool showAcceptButton;
  final int groupId;
  final GroupChatModel groupChatModel;

  List<GroupChatGuideline> guidelines = [
    GroupChatGuideline("Posts should add to the discussion or build community",
        "Sometimes conversations get a little hectic, whether online or in-person. To make sure these discussions are as helpful as possible, we ask that everyone try to contribute to the overall topic. Getting to know one another and building friendships is always okay too."),
    GroupChatGuideline("Be kind and respectful",
        "We should all try to act like we’re meeting each other in person, with the same kind of respect that we would normally bring. It’s everyone’s job to make sure we all feel comfortable in Group Chat, and basic kindness is a good place to start. It doesn’t hurt to give people the benefit of the doubt, either."),
    GroupChatGuideline("Don’t promote self-harm or suicide",
        "Many people with OCD have thoughts about self-harm or suicide. But most people in Group Chat aren’t professionally equipped to deal with these serious topics in the best possible way. Suicidal ideation, attempted or completed suicide, and actual self-harm should be discussed with a professional—not with others in Group Chat. If you see these posts, please report them so we’re aware of the situation.<br><br><i>If you believe you’re in danger of harming yourself or anyone else, go to the emergency room or call 9-1-1 (or your local emergency number) immediately.</i>"),
    GroupChatGuideline("Don’t try to diagnose or treat anyone",
        "Part of the value of Group Chat is to discuss symptoms, subtypes, treatment options, and so on. But we’re not here to try to diagnose one another or offer advice about new or existing treatments. For example, it’s okay to talk about Prozac, but we ask that you don’t tell someone to start or stop taking it.<br><br>Encourage people to explore different ways to get help, and direct them toward the resources that have been helpful for you. But please don’t tell them what they “have,” try to sell them on a particular treatment method, or argue that what they’re doing is incorrect. Everybody responds to treatment differently, and a trained professional is better equipped to make these determinations.<br>"),
    GroupChatGuideline("Remember that reassurance makes things worse ",
        """Because OCD causes such intense anxiety, it’s normal to seek reassurance wherever you can. And it’s natural to want to reassure someone in distress. But because reassurance actually makes it harder for people to get better, we should try to recognize when people are seeking reassurance and find other ways to help them instead.<br><br>There are many helpful resources on reassurance and its negative effects on people with OCD. Here’s something we wrote about it, as a place to start: <a href="https://www.treatmyocd.com/blog/reassurance-how-it-prevents-recovery/">https://www.treatmyocd.com/blog/reassurance-how-it-prevents-recovery/</a>"""),
    GroupChatGuideline("Let us know if something doesn’t seem right ",
        "This isn’t about getting people in trouble, and we’re not out here to look for every issue. But mental health is important, and we have a bunch of licensed therapists on our team who are prepared to guide us through potentially difficult situations.<br><br>So, think of reporting as a way to look out for one another. For the most part, we should all feel free to discuss whatever is on our mind. Only in very rare cases would we even consider limiting someone’s access to the community based on repeated violations of these guidelines."),
  ];

  ScrollController scrollController;
  double scrollOffset;

  bool loading = false;
  bool isExpanded1 = false;
  bool showReportOverlay = true;

  final double hideReportOverlayScrollOffset = 10.0;
  final int reportOverlayAnimationDurationMs = 500;

  GroupChatGuidelinesPageModel(
      context, this.showAcceptButton, this.groupId, this.groupChatModel) {
    appBloc = BlocProvider.of<AppBloc>(context);
    backEventListener = appBloc.backEventController.listen((_) {
      print("Guidelines Back Event Received");
      Navigator.maybePop(context);
    });
    buildContext = context;
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    scrollOffset = 0;
    appBloc.sendFlutterScreenStartEvent(screenEventName);
  }

  @override
  void dispose() {
    appBloc.sendFlutterScreenEndEvent(screenEventName);
    backEventListener.cancel();
    super.dispose();
  }

  void scrollListener() {
    // scroll offset could be negative, so let's bound it to non-negative values
    scrollOffset = max(0, scrollController.offset);
    if (scrollOffset == 0) {
      showReportOverlay = true;
    } else if (scrollOffset > hideReportOverlayScrollOffset) {
      Timer(Duration(milliseconds: reportOverlayAnimationDurationMs),
          () => {showReportOverlay = false});
    }
    notifyListeners();
  }

  void onToggleExpand1() {
    isExpanded1 = !isExpanded1;
    notifyListeners();
  }

  void onAcceptGuidelines(BuildContext context) async {
    loading = true;
    notifyListeners();
    await networkProvider.postJoinGroup(groupId).then((value) async {
      if (value.status != null) {
        loading = false;
        final groupChatPage = GroupChatPage(
          groupId: this.groupId,
          groupChatModel: this.groupChatModel,
        );

        Navigator.pop(context);
        Navigator.pop(context, true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => groupChatPage));
      } else {
        loading = false;
        alertError(context, value.error.errorMessage, () {
          onAcceptGuidelines(context);
          Navigator.pop(context);
        });
      }
      notifyListeners();
    });
  }

  void onGuidelineTapped(int guidelineIndex) {
    guidelines[guidelineIndex].isExpanded =
        !guidelines[guidelineIndex].isExpanded;
    notifyListeners();
  }
}

/// A wrapper to provide [GroupChatPage] with [GroupChatPageModel].
class GroupChatGuidelinesPageWrapper extends StatelessWidget {
  final bool showAcceptButton;
  final int groupId;
  final GroupChatModel groupChatModel;

  GroupChatGuidelinesPageWrapper(
      this.showAcceptButton, this.groupId, this.groupChatModel,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChatGuidelinesPageModel>(
      builder: (context) => GroupChatGuidelinesPageModel(
          context, showAcceptButton, groupId, groupChatModel),
      child: GroupChatGuidelinesPage(),
    );
  }
}

class GroupChatGuidelinesPage extends StatelessWidget {
  List<Widget> buildGuidelines(
      BuildContext context, GroupChatGuidelinesPageModel model) {
    List<Widget> widgets = List<Widget>();

    model.guidelines.asMap().forEach((index, guidelineModel) {
      widgets.add(GestureDetector(
        onTap: () => {model.onGuidelineTapped(index)},
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                    margin:
                        EdgeInsets.only(top: 5, left: 20, right: 16, bottom: 5),
                    child: Text(
                      guidelineModel.title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000)),
                    ))),
            Container(
                margin: EdgeInsets.only(top: 10, bottom: 20, right: 20),
                width: 8,
                height: 12,
                child: Image.asset("assets/images/icon_menu_selection.png")),
          ],
        ),
      ));
      widgets.add(Visibility(
        visible: model.guidelines[index].isExpanded,
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Html(
            data: guidelineModel.body,
            onLinkTap: (url) {
              AppBloc appBloc = BlocProvider.of<AppBloc>(context);
              DeviceUtils().openUrl(appBloc, url);
            },
            defaultTextStyle: TextStyle(
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
        ),
      ));
    });

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupChatGuidelinesPageModel>(
        builder: (context, model, child) {
      return PageWrapper(
        child: Stack(
          children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              BackHelper(
                child: BackButtonCustom(
                    Image.asset("assets/images/back_blue.png"),
                    () => BackHelper.navigateBack(context)),
              ),
              /*
        Title
         */
              Row(children: [
                Container(
                  margin: EdgeInsets.only(left: 24),
                  child: Text(
                    "Group guidelines",
                    style: TextStyle(
                        color: Color.fromARGB(255, 21, 21, 21),
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ]),
              /*
        Body
         */
              Expanded(
                  child: Container(
                margin: EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage("assets/images/flowers.png"),
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.contain,
                  ),
                  color: Color(0xFFF5F5F5),
                  border: Border.all(
                      color: Color(0xFFF5F5F5),
                      width: 1.0,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          ListView(
                            padding: EdgeInsets.only(bottom: 10),
                            controller: model.scrollController,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: Text(
                                  """Welcome to Groups. To make sure this discussion is helpful and comfortable for everyone, here are some important guidelines we all need to follow: A Notification related to scrolling.""",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  ...buildGuidelines(context, model),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 5,
                                          left: 20,
                                          right: 16,
                                          bottom: 5),
                                      child: Text(
                                        "Enjoy the Group Chat community, and let us know if we can help make it better! ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF000000)),
                                      ))
                                ],
                              ),
                              Container(height: 180),
                            ],
                          ),
                          /*
                    Overlay widget
                     */
                          /*
                    Top blur
                     */
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: new LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFF5F5F5),
                                  Color(0x00F5F5F5),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: <Widget>[
                                  /*
                            Bottom blur
                             */
                                  Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: new LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0x00F5F5F5),
                                          Color(0xFFF5F5F5)
                                        ],
                                      ),
                                    ),
                                  ),
                                  /*
                            Report post overlay
                             */
                                  if (model.showReportOverlay)
                                    AnimatedOpacity(
                                      opacity: 1 -
                                          (min(
                                                  model.scrollOffset,
                                                  model
                                                      .hideReportOverlayScrollOffset) /
                                              model
                                                  .hideReportOverlayScrollOffset), //model.scrollAtTop ? 1.0 : 0.0,
                                      duration: Duration(
                                          milliseconds: model
                                              .reportOverlayAnimationDurationMs),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: new LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0x00F5F5F5),
                                                  Color(0xFFF5F5F5)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            color: Color(0xFFF5F5F5),
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 0, 20, 16),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                                border: Border.all(
                                                    color: Color(0xFF00A3AD),
                                                    width: 3.0,
                                                    style: BorderStyle.solid),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.all(14),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "Help us make this community a helpful and comfortable place for everyone by reporting posts that don't seem right. Click the dots next to the posts to report: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    Container(
                                                      width: 30,
                                                      child: Image.asset(
                                                          "assets/images/icon_more.png"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    /*
            Accept button
             */
                    Center(
                      child: Container(
                          margin:
                              EdgeInsets.only(left: 50, right: 50, bottom: 18),
                          width: 210,
                          height: 43,
                          child: Visibility(
                              visible: model.showAcceptButton,
                              child: FlatButton(
                                color: Color(0xFF00A3AD),
                                textColor: Colors.white,
                                padding: EdgeInsets.all(8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(3.0),
                                ),
                                onPressed: () {
                                  model.onAcceptGuidelines(context);
                                },
                                child: Text(
                                  "I accept",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ))),
                    ),
                  ],
                ),
              )),
            ]),
            Visibility(
                child: Center(child: CupertinoActivityIndicator(radius: 16)),
                visible: model.loading),
          ],
        ),
      );
    });
  }
}
