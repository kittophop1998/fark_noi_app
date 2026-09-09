import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../store/auth_store.dart';
import 'auth_scaffold.dart';

/// Signing up, in two steps: the form, then the code mailed to the address on
/// it.
///
/// The whole form is collected before the code is asked for, so somebody who
/// mistypes their password finds out before they have waited on an email
/// rather than after. The account is created by the same action that verifies
/// the code — `/auth/register` consumes the one-time token, and a verified
/// code with no account behind it is a token that expires unused.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final AuthStore _store;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _store = sl<AuthStore>()..reset();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _back() {
    if (_store.step == SignupStep.otp) {
      _otpCtrl.clear();
      _store.backToForm();
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final onOtp = _store.step == SignupStep.otp;
        return AuthScaffold(
          onBack: _back,
          title: onOtp ? 'ยืนยันอีเมล' : 'สร้างบัญชี',
          subtitle: onOtp
              ? 'เราส่งรหัส 6 หลักไปที่ ${_store.email} แล้ว'
              : 'ใช้เวลาไม่ถึงนาที แล้วเริ่มฝากซื้อได้เลย',
          footer: onOtp ? _otpFooter() : _formFooter(),
          children: onOtp ? _otpFields() : _formFields(),
        );
      },
    );
  }

  // ── Step 1 — the form ───────────────────────────────────────────────────

  Widget _formFooter() {
    return AppButton(
      label: 'ถัดไป',
      size: AppButtonSize.large,
      fullWidth: true,
      loading: _store.isSubmitting,
      onPressed: _store.canSubmitForm
          ? () async {
              FocusScope.of(context).unfocus();
              await _store.requestOtp();
            }
          : null,
    );
  }

  List<Widget> _formFields() {
    return [
      _error(),
      AppTextField(
        label: 'ชื่อที่แสดง',
        hint: 'ชื่อที่คนอื่นจะเห็น',
        controller: _nameCtrl,
        textInputAction: TextInputAction.next,
        prefixIcon: Icons.person_outline_rounded,
        onChanged: _store.setName,
      ),
      const SizedBox(height: AppSpace.x5),
      AppTextField(
        label: 'อีเมล',
        hint: 'you@example.com',
        helper: 'เราจะส่งรหัสยืนยันไปที่อีเมลนี้',
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        prefixIcon: Icons.mail_outline_rounded,
        onChanged: _store.setEmail,
      ),
      const SizedBox(height: AppSpace.x5),
      AppTextField(
        label: 'เบอร์โทรศัพท์',
        hint: '08x-xxx-xxxx',
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        prefixIcon: Icons.phone_outlined,
        onChanged: _store.setPhone,
      ),
      const SizedBox(height: AppSpace.x5),
      AppTextField(
        label: 'รหัสผ่าน',
        hint: 'อย่างน้อย 6 ตัวอักษร',
        controller: _passwordCtrl,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        prefixIcon: Icons.lock_outline_rounded,
        suffix: AppIconButton(
          icon: _obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          iconSize: AppMetrics.icon,
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        onChanged: _store.setPassword,
      ),
      const SizedBox(height: AppSpace.x6),
      // Teal, not coral: this is the product saying something about itself,
      // and it is the one place on the sign-up flow where that belongs.
      const AppNotice(
        tone: AppTone.trust,
        title: 'บัญชีของคุณปลอดภัย',
        message: 'เบอร์โทรจะเห็นได้เฉพาะคู่ของงานที่กำลังส่งของกันเท่านั้น',
      ),
    ];
  }

  // ── Step 2 — the code ───────────────────────────────────────────────────

  Widget _otpFooter() {
    return AppButton(
      label: 'ยืนยันและสมัครสมาชิก',
      size: AppButtonSize.large,
      fullWidth: true,
      loading: _store.isSubmitting,
      onPressed: _store.canVerifyOtp
          ? () async {
              FocusScope.of(context).unfocus();
              await _store.verifyAndRegister();
            }
          : null,
    );
  }

  List<Widget> _otpFields() {
    return [
      _error(),
      AppTextField(
        label: 'รหัสยืนยัน',
        hint: '••••••',
        helper: 'รหัสมีอายุจำกัด ถ้าไม่ได้รับให้กดส่งใหม่',
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        maxLength: 6,
        prefixIcon: Icons.pin_outlined,
        onChanged: _store.setOtpCode,
      ),
      const SizedBox(height: AppSpace.x4),
      Align(
        alignment: Alignment.centerLeft,
        child: AppButton(
          label: 'ส่งรหัสใหม่',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.small,
          icon: Icons.refresh_rounded,
          onPressed: _store.isSubmitting ? null : _store.resendOtp,
        ),
      ),
      const SizedBox(height: AppSpace.x6),
      Text(
        'การสมัครสมาชิกถือว่าคุณยอมรับเงื่อนไขการใช้งานและนโยบายความเป็นส่วนตัว'
        'ของฝากหน่อย',
        style: AppText.caption.copyWith(color: AppColors.faint),
      ),
    ];
  }

  Widget _error() {
    if (!_store.hasError) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x5),
      child: AppNotice(tone: AppTone.error, message: _store.errorMessage!),
    );
  }
}
