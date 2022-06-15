import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openvisu_bloc/openvisu_bloc.dart';

class AuthWidget extends StatefulWidget {
  final Widget outside;
  final Widget inside;

  const AuthWidget({
    required this.outside,
    required this.inside,
    Key? key,
  }) : super(key: key);

  @override
  AuthWidgetState createState() => AuthWidgetState();
}

class AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        Widget? child;
        if (state is AuthenticationUninitialized) {
          child = const Center(child: CircularProgressIndicator());
        }
        if (state is AuthenticationLoading) {
          child = const Center(child: CircularProgressIndicator());
        }
        if (state is AuthenticationUnauthenticated) {
          child = widget.outside;
        }
        if (state is AuthenticationAuthenticated) {
          child = widget.inside;
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: child,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final inAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.01),
              end: const Offset(0.0, 0.0),
            ).animate(animation);
            final outAnimation = Tween<Offset>(
              begin: const Offset(0.0, -1.01),
              end: const Offset(0.0, 0.0),
            ).animate(animation);

            return ClipRect(
              child: SlideTransition(
                position:
                    (child != widget.outside) ? inAnimation : outAnimation,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
