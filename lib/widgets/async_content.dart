import 'package:flutter/material.dart';

import 'state_views.dart';

/// Loads data once and shows loading, error (with retry), empty or content.
///
/// Every data-driven screen uses this so state handling is consistent.
/// To reload when an input changes (e.g. the language), give it a new
/// `key`, such as `ValueKey(languageCode)`.
class AsyncContent<T> extends StatefulWidget {
  const AsyncContent({
    super.key,
    required this.load,
    required this.builder,
    this.isEmpty,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_rounded,
    this.emptyAction,
    this.loading,
    this.compact = false,
  });

  final Future<T> Function() load;

  /// Builds the content. `reload` refetches the data.
  final Widget Function(BuildContext context, T data, VoidCallback reload)
  builder;

  /// Return `true` to show the empty state instead of [builder].
  final bool Function(T data)? isEmpty;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? emptyAction;

  /// Custom loading widget (defaults to a spinner).
  final Widget? loading;

  /// Use smaller state views (for sections inside a page).
  final bool compact;

  @override
  State<AsyncContent<T>> createState() => _AsyncContentState<T>();
}

class _AsyncContentState<T> extends State<AsyncContent<T>> {
  late Future<T> _future = widget.load();

  void _reload() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.connectionState != ConnectionState.done) {
          child =
              widget.loading ??
              (widget.compact
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const LoadingView());
        } else if (snapshot.hasError) {
          child = ErrorView(
            message: widget.compact
                ? 'Could not load this section.'
                : 'We could not load this content. Please try again.',
            onRetry: _reload,
          );
        } else {
          final data = snapshot.data as T;
          if (widget.isEmpty?.call(data) ?? false) {
            child = EmptyView(
              title: widget.emptyTitle,
              message: widget.emptyMessage,
              icon: widget.emptyIcon,
              action: widget.emptyAction,
              compact: widget.compact,
            );
          } else {
            child = widget.builder(context, data, _reload);
          }
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(
              snapshot.connectionState == ConnectionState.done
                  ? (snapshot.hasError ? 'error' : 'data')
                  : 'loading',
            ),
            child: child,
          ),
        );
      },
    );
  }
}
