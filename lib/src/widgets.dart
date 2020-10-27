import 'base.dart';
import 'package:flutter/material.dart';

typedef ValuableConsumerBuilder = Widget Function(
    BuildContext, ValuableWatcher, Widget);

class ValuableConsumer extends StatefulWidget {
  final Widget child;
  final ValuableConsumerBuilder builder;

  const ValuableConsumer({this.child, this.builder, Key key}) : super(key: key);

  @override
  _ValuableConsumerState createState() => _ValuableConsumerState();

  static _ValuableConsumerState of(BuildContext context) =>
      context?.findAncestorStateOfType<_ValuableConsumerState>();
}

class _ValuableConsumerState extends State<ValuableConsumer>
    with ValuableWatcherMixin {
  bool _markNeedBuild = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (BuildContext context) =>
            widget.builder(context, watch, widget.child));
  }

  @override
  void didUpdateWidget(ValuableConsumer old) {
    super.didUpdateWidget(old);

    // remove all previous watched Valuable
    cleanWatched();
  }

  T _watch<T>(Valuable<T> valuable, [ValuableContext context]) =>
      watch(valuable, context);

  @override
  ValuableContext get valuableContext => ValuableContext(context: context);

  @override
  void onValuableChange() {
    if (_markNeedBuild == false) {
      _markNeedBuild = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _markNeedBuild = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    cleanWatched();
  }
}

extension WidgetValuable<T> on Valuable<T> {
  T watch(BuildContext context) {
    ValuableContext vContext = ValuableContext(context: context);
    _ValuableConsumerState state = ValuableConsumer.of(context);

    // If a consumer exists in the current UI tree, we make it watch the current Valuable
    return state != null
        ? state._watch(this, vContext)
        : this.getValue(vContext);
  }
}
