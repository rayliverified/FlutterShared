import 'package:flutter/material.dart';
import 'package:nocd/page/user_profile/page_user_profile.dart';
import 'package:nocd/ui/ui_page_wrapper.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:provider/provider.dart';

class UserAvatarEditModel with ChangeNotifier {
  UserProfileBloc userProfileBloc;

  UserAvatarEditModel(context) {
    userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
  }

  void backClick() {
    print("BackClick");
    userProfileBloc.previousPage();
  }

  void saveClick() {
    // TODO Save data.
    userProfileBloc.previousPage();
  }
}

/// A wrapper to provide [DataCollectionSeverityPage] with [DataCollectionSeverityModel].
class UserAvatarEditWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserAvatarEditModel>(
      builder: (context) => UserAvatarEditModel(context),
      child: UserAvatarEditPage(),
    );
  }
}

class UserAvatarEditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserAvatarEditModel>(builder: (context, model, child) {
      return PageWrapper(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[],
          ),
        ),
      );
    });
  }
}
