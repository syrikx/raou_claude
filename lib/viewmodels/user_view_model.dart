import '../models/user.dart';
import '../services/user_service.dart';
import 'base_view_model.dart';

class UserViewModel extends BaseViewModel {
  final UserService _userService = UserService();
  
  List<User> _users = [];
  User? _currentUser;

  List<User> get users => _users;
  User? get currentUser => _currentUser;

  Future<void> fetchUsers() async {
    await handleAsyncOperation(() async {
      _users = await _userService.getUsers();
      notifyListeners();
    });
  }

  Future<void> fetchUserById(String id) async {
    await handleAsyncOperation(() async {
      _currentUser = await _userService.getUserById(id);
      notifyListeners();
    });
  }

  Future<void> createUser(User user) async {
    await handleAsyncOperation(() async {
      final newUser = await _userService.createUser(user);
      if (newUser != null) {
        _users.add(newUser);
        notifyListeners();
      }
    });
  }

  Future<void> updateUser(User user) async {
    await handleAsyncOperation(() async {
      final updatedUser = await _userService.updateUser(user);
      if (updatedUser != null) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
          notifyListeners();
        }
      }
    });
  }

  Future<void> deleteUser(String id) async {
    await handleAsyncOperation(() async {
      final success = await _userService.deleteUser(id);
      if (success) {
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
      }
    });
  }
}