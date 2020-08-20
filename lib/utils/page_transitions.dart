import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

const kDefaultDuration = 1000.0;

Route<T> fadeThrough<T>(var page, [double duration = kDefaultDuration]) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: (duration * 1000).round()),
    pageBuilder: (context, animation, secondaryAnimation) => page(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child);
    },
  );
}

Route<T> fadeScale<T>(var page, [double duration = kDefaultDuration]) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: (duration * 1000).round()),
    pageBuilder: (context, animation, secondaryAnimation) => page(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(animation: animation, child: child);
    },
  );
}

Route<T> sharedAxis<T>(var page,
    [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
    double duration = kDefaultDuration]) {
  return PageRouteBuilder<T>(
    transitionDuration: Duration(milliseconds: (duration * 1000).round()),
    pageBuilder: (context, animation, secondaryAnimation) => page(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        child: child,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
      );
    },
  );
}
