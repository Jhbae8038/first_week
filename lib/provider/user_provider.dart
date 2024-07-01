
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kaist_summer_camp/model/user_model.dart';
import 'package:kaist_summer_camp/provider/hive_db_provider.dart';




final userProvider = StateNotifierProviderFamily<UserNotifier, UserModelBase, String>((ref, userKey) {
  final dbAsync = ref.watch(hiveProvider);

  return dbAsync.when(
    data: (db) {
      return UserNotifier(db.userBox, key: userKey);
    },
    loading: () => UserNotifier(null),
    error: (error, stack) => UserNotifier(null),
  );
});

class UserNotifier extends StateNotifier<UserModelBase> {

  final CollectionBox<UserModel>? userBox;
  final String key;

  UserNotifier(this.userBox, {this.key = 'owner'}) : super(UserLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (userBox == null) {
      return;
    }
    final user = await userBox!.get(key);

    if (user != null) {
      state = user;
    } else {
      state = UserError('User not found');
    }
  }

  Future<void> updateUserInfo({String? name, int? age, String? imagePath}) async {
    if( state is UserModel) {
      final user = state as UserModel;
      final newUser = user.copyWith(
        name: name,
        age: age,
        imagePath: imagePath,
      );
      await userBox!.put(key, newUser);
      state = newUser;
    }
  }
}