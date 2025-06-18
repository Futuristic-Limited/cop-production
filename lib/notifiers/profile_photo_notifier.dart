import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfilePhotoNotifier {
  static final ValueNotifier<String> profilePhotoUrl = ValueNotifier('');
  static final ValueNotifier<String> username = ValueNotifier('');
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> firstValueListenable;
  final ValueListenable<B> secondValueListenable;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    Key? key,
    required this.firstValueListenable,
    required this.secondValueListenable,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: firstValueListenable,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: secondValueListenable,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}