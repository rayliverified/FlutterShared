import 'package:flutter/material.dart';
import 'package:nocd/main.dart';
import 'package:nocd/utils/bloc_provider.dart';
import 'package:nocd/utils/utils_misc.dart';

class FlavorBanner extends StatelessWidget {
  final Widget child;
  BannerConfig bannerConfig;
  FlavorBanner({@required this.child});

  @override
  Widget build(BuildContext context) {
    if (DeviceUtils.isRelease()) return child;

    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
    bannerConfig ??= BannerConfig(
        bannerName: appBloc.flavorConfig.flavor,
        bannerColor: appBloc.flavorConfig.flavorColor());

    return Container(
        child: Stack(children: <Widget>[child, _buildBanner(context)]));
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: BannerPainter(
            message: bannerConfig.bannerName,
            textDirection: Directionality.of(context) ?? TextDirection.ltr,
            layoutDirection: Directionality.of(context) ?? TextDirection.ltr,
            location: BannerLocation.topStart,
            color: bannerConfig.bannerColor),
      ),
    );
  }
}

class BannerConfig {
  final String bannerName;
  final Color bannerColor;
  BannerConfig({@required this.bannerName, @required this.bannerColor});
}