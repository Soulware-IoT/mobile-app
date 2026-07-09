import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:cocina360/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Card-first payment bottom sheet: captures a card via Stripe's
/// [CardFormField] (the app never sees raw card digits — only brand, last4
/// and expiry, which Stripe's SDK exposes for PCI-compliant display) and
/// then drives the existing [SubscriptionCubit.changePlan] call, reusing its
/// `updating`/`updateError` states for the loading/error UI.
///
/// The "Banco" tab is presentation-only: the backend's `StripeBillingGateway`
/// only supports card payment methods today, so submitting from that tab
/// surfaces [AppLocalizations.paymentSheetBankUnavailable] instead of a real
/// charge.
///
/// Returns `true` once the plan change succeeds, `false`/`null` otherwise.
Future<bool?> showPaymentSheet(
  BuildContext context, {
  required String organizationId,
  required SubscriptionPlan plan,
}) {
  // showModalBottomSheet pushes a new route that is a sibling of the current
  // page route, not a descendant of it, so the SubscriptionCubit provided by
  // the enclosing GoRoute isn't reachable via context lookup inside the
  // sheet. Capture it here and re-provide it explicitly.
  final subscriptionCubit = context.read<SubscriptionCubit>();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    isDismissible: false,
    enableDrag: false,
    builder: (_) => BlocProvider.value(
      value: subscriptionCubit,
      child: _PaymentSheet(organizationId: organizationId, plan: plan),
    ),
  );
}

enum _Phase { form, loading, success }

enum _PaymentMode { card, bank }

class _PaymentSheet extends StatefulWidget {
  final String organizationId;
  final SubscriptionPlan plan;

  const _PaymentSheet({required this.organizationId, required this.plan});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _bankHolderController = TextEditingController();
  final _clabeController = TextEditingController();

  _Phase _phase = _Phase.form;
  _PaymentMode _mode = _PaymentMode.card;
  bool _awaitingResult = false;

  CardFieldInputDetails? _cardDetails;
  String? _cardError;
  String? _clabeError;

  @override
  void dispose() {
    _bankHolderController.dispose();
    _clabeController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final l10n = AppLocalizations.of(context)!;

    if (_mode == _PaymentMode.bank) {
      final clabe = _clabeController.text.trim();
      setState(() {
        _clabeError = clabe.length == 18 ? null : l10n.paymentSheetClabeInvalid;
      });
      if (_clabeError != null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.paymentSheetBankUnavailable)));
      return;
    }

    setState(() => _cardError = null);

    if (_cardDetails == null || !_cardDetails!.complete) {
      setState(() => _cardError = l10n.subscriptionCardIncomplete);
      return;
    }
    if (Stripe.publishableKey.isEmpty) {
      setState(() => _cardError = l10n.subscriptionStripeNotConfigured);
      return;
    }

    setState(() => _phase = _Phase.loading);

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      if (!mounted) return;
      _awaitingResult = true;
      context.read<SubscriptionCubit>().changePlan(
        widget.organizationId,
        widget.plan,
        paymentMethodId: paymentMethod.id,
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.form;
        _cardError = e.error.localizedMessage ?? e.error.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.form;
        _cardError = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listenWhen: (_, _) => _awaitingResult,
      listener: (context, state) {
        if (state is! SubscriptionLoaded || state.updating) return;
        _awaitingResult = false;
        setState(() {
          if (state.updateError != null) {
            _phase = _Phase.form;
            _cardError = '${state.updateError}';
          } else {
            _phase = _Phase.success;
          }
        });
      },
      child: PopScope(
        canPop: _phase != _Phase.loading,
        // The form is captured card-first as a bottom sheet; the loading and
        // success results are short, so they float centered like a dialog to
        // avoid being clipped at the bottom edge.
        child: _phase == _Phase.form
            ? _buildBottomSheet(theme, mq)
            : _buildCenteredResult(theme, mq),
      ),
    );
  }

  Widget _buildBottomSheet(ThemeData theme, MediaQueryData mq) {
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.96),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: _buildForm(theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A dialog-like card centered over the (already dimmed) barrier. The sheet
  /// fills the screen with a transparent background so only this card is
  /// opaque and the darkened page shows around it.
  Widget _buildCenteredResult(ThemeData theme, MediaQueryData mq) {
    return SizedBox(
      height: mq.size.height,
      width: mq.size.width,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
            ),
            child: switch (_phase) {
              _Phase.loading => _buildLoading(theme),
              _Phase.success => _buildSuccess(theme),
              _Phase.form => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.paymentSheetTotalToPay,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.plan.displayPriceUsd,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            _CloseButton(onTap: () => Navigator.of(context).pop(false)),
          ],
        ),
        const SizedBox(height: 20),
        _ModeSegmentedControl(
          value: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(anim),
              child: child,
            ),
          ),
          child: _mode == _PaymentMode.card
              ? _CardPreview(
                  key: const ValueKey('card-preview'),
                  details: _cardDetails,
                )
              : const SizedBox.shrink(key: ValueKey('no-preview')),
        ),
        const SizedBox(height: 20),
        if (_mode == _PaymentMode.card) _buildCardFields(theme) else _buildBankFields(theme),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _pay,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.paymentSheetPayButton(widget.plan.displayPriceUsd)),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.paymentSheetSecurityNotice,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardFormField(
          enablePostalCode: false,
          style: CardFormStyle(
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            borderColor: theme.dividerColor.withValues(alpha: 0.4),
            borderRadius: 12,
            textColor: theme.colorScheme.onSurface,
            placeholderColor: theme.colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
          onCardChanged: (details) => setState(() => _cardDetails = details),
        ),
        if (_cardError != null) ...[
          const SizedBox(height: 8),
          Text(
            _cardError!,
            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildBankFields(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _bankHolderController,
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration(
            theme,
            label: l10n.paymentSheetBankAccountHolderLabel,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _clabeController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(18),
          ],
          decoration: _fieldDecoration(
            theme,
            label: l10n.paymentSheetClabeLabel,
            hint: l10n.paymentSheetClabeHint,
            errorText: _clabeError,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.paymentSheetDirectDebitNotice,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(
    ThemeData theme, {
    required String label,
    String? hint,
    String? errorText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerLow,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          l10n.paymentSheetProcessingTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paymentSheetProcessingSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SuccessCheck(),
        const SizedBox(height: 20),
        Text(
          l10n.paymentSheetSuccessTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.paymentSheetSuccessBody(widget.plan.displayPriceUsd),
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.paymentSheetDone),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ModeSegmentedControl extends StatelessWidget {
  final _PaymentMode value;
  final ValueChanged<_PaymentMode> onChanged;

  const _ModeSegmentedControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(context, _PaymentMode.card, l10n.paymentSheetTabCard),
          ),
          Expanded(
            child: _segment(context, _PaymentMode.bank, l10n.paymentSheetTabBank),
          ),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, _PaymentMode mode, String label) {
    final theme = Theme.of(context);
    final active = mode == value;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Live preview mirroring only the data Stripe's SDK exposes for a card in
/// progress (brand, last 4 digits, expiry) — the full number/CVC are never
/// available to the app, by design, for PCI compliance.
class _CardPreview extends StatelessWidget {
  final CardFieldInputDetails? details;

  const _CardPreview({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final last4 = details?.last4;
    final brand = details?.brand;
    final expiry = (details?.expiryMonth != null && details?.expiryYear != null)
        ? '${details!.expiryMonth!.toString().padLeft(2, '0')}/${(details!.expiryYear! % 100).toString().padLeft(2, '0')}'
        : 'MM/YY';

    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Color.lerp(primary, Colors.black, 0.35)!],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8B2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (brand != null && brand != 'Unknown')
                Text(
                  brand.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            '•••• •••• •••• ${last4 ?? '••••'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              expiry,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Self-contained draw-in checkmark, avoiding a new animation package for a
/// single one-off effect.
class _SuccessCheck extends StatefulWidget {
  const _SuccessCheck();

  @override
  State<_SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<_SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, _) =>
            CustomPaint(painter: _CheckPainter(progress: _progress.value)),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  const _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, size.width / 2, Paint()..color = const Color(0xFFD7F2DD));

    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.34);

    final checkPaint = Paint()
      ..color = const Color(0xFF1B7A3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        checkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
