import 'package:flutter/widgets.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Turns an error object into a user-facing, localized message.
///
/// - [ApiGatewayException]: the message already comes localized from the server
///   (the gateway forwards `Accept-Language`); status `0` means the gateway URL
///   isn't configured, which is a client-side condition we localize here.
/// - [NoConnectionException]: localized offline message.
/// - anything else: a generic localized fallback.
String localizedError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;

  if (error is NoConnectionException) {
    return l10n.errorNoConnection;
  }
  if (error is ApiGatewayException) {
    if (error.statusCode == 0) return l10n.errorGatewayNotConfigured;
    return error.message;
  }
  return l10n.errorGeneric;
}
