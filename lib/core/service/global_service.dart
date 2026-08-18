/// App-wide mutable state that isn't tied to a single feature.
///
/// Holds the current Firebase ID token so [BaseClient] can attach it to
/// authorized API requests without every call site needing a direct
/// dependency on Firebase Auth. Kept in sync by [AuthRepository].
class GlobalService {
  GlobalService._();

  static final GlobalService instance = GlobalService._();

  String? idToken;
}