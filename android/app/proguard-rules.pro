# react-native-stripe-sdk's push-provisioning (tap-to-pay card issuing) proxy
# references com.stripe.android.pushProvisioning.* classes that ship in a
# separate Stripe artifact we deliberately exclude (it drags in an
# unresolvable Google Play Services dependency and isn't used by this app's
# card-payment flow). The references are real but never reached at runtime,
# so R8 just needs to stop treating them as missing.
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**
