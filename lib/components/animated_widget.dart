import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimatedWidgets extends StatelessWidget {
  final Widget? child;
  final double? verticalOffset;
  final double? horizontalOffset;
  final double? durationMilli;

  const AnimatedWidgets(
      {super.key,
      this.child,
      this.verticalOffset,
      this.horizontalOffset,
      this.durationMilli});

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: Duration(
          milliseconds: durationMilli != null ? durationMilli!.toInt() : 500),
      child: SlideAnimation(
        curve: Curves.easeInOut,
        horizontalOffset: horizontalOffset ?? 0,
        verticalOffset: verticalOffset ?? 50,
        child: FadeInAnimation(
          child: child!,
        ),
      ),
    );
  }
}

class ListAnimator extends StatefulWidget {
  final List<Widget>? data;
  final int? durationMilli;
  final double? verticalOffset;
  final double? horizontalOffset;
  final ScrollController? controller;
  final direction;
  final bool addPadding;
  final bool reverse;
  final bool scroll;
  final customPadding;
  final Stream<int>? scrollControllerStream;

  const ListAnimator({
    this.controller,
    super.key,
    this.data,
    this.durationMilli,
    this.verticalOffset,
    this.horizontalOffset,
    this.direction,
    this.addPadding = true,
    this.reverse = false,
    this.customPadding,
    this.scrollControllerStream,
    this.scroll = true,
  });

  @override
  _ListAnimatorState createState() => _ListAnimatorState();
}

class _ListAnimatorState extends State<ListAnimator> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: widget.scrollControllerStream,
        builder: (context, snapshot) {
          // if(snapshot.hasData){
          //   autoScroll.scrollToIndex(snapshot.data ,preferPosition: AutoScrollPosition.middle );
          // }
          return AnimationLimiter(
            child: SingleChildScrollView(
              controller: widget.controller,
              padding: widget.customPadding ??
                  EdgeInsets.only(top: widget.addPadding ? 0 : 0),
              physics: widget.scroll
                  ? const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics())
                  : const NeverScrollableScrollPhysics(),
              reverse: widget.reverse,
              scrollDirection: widget.direction ?? Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.data!.length, (index) {
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      duration:
                          Duration(milliseconds: widget.durationMilli ?? 400),
                      child: SlideAnimation(
                          verticalOffset: widget.verticalOffset ?? 1.0,
                          child: FadeInAnimation(child: widget.data![index])));
                }),
              ),
            ),
          );
        });
  }
}
