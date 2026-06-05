enum UserRole {
  unauthenticated,
  member,
  trainer,
  owner,
}

class AuthState {
  final UserRole userRole;
  final bool isAuthenticated;

  AuthState({required this.userRole, required this.isAuthenticated});

  AuthState copyWith({
    UserRole? userRole,
    bool? isAuthenticated,
  }) {
    return AuthState(
      userRole: userRole ?? this.userRole,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
