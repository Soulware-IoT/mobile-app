package site.soulware.cocina360

import io.flutter.embedding.android.FlutterFragmentActivity

// flutter_stripe requires a FragmentActivity host (it uses the Activity Result
// APIs for 3D Secure/Google Pay flows), so this can't be a plain FlutterActivity.
class MainActivity : FlutterFragmentActivity()
