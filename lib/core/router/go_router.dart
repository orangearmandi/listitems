import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:listitems/list/cubit/apitcubit.dart';
import 'package:listitems/list/view/ApiListPage.dart';
import 'package:listitems/list/view/ApiDetailPage.dart';
import 'package:listitems/list/view/ApiEditPage.dart';
import 'package:listitems/list/view/PrefsNewPage.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const ApiListPage()),
    GoRoute(path: '/api-list', builder: (_, __) => const ApiListPage()),
    GoRoute(
      path: '/api/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ApiDetailPage(id: id);
      },
    ),
    GoRoute(path: '/prefs/new', builder: (_, __) => const PrefsNewPage()),

    GoRoute(
      path: '/api/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        // Need to get the item, but since state is not available, perhaps pass the item or find it.
        // For simplicity, assume we have the item from context or something.
        // Since ApiDetailPage has the item, perhaps navigate with extra.
        // But for now, let's assume we can get it from ApiCubit.
        final apiState = context.read<ApiCubit>().state;
        if (apiState is ApiLoaded) {
          final item = apiState.items.firstWhere((item) => item.id == id);
          return ApiEditPage(itemToEdit: item);
        }
        return const ApiListPage(); // fallback
      },
    ),
  ],
);
