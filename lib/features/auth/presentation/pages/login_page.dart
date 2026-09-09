import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_shape.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../store/auth_store.dart';
import 'auth_scaffold.dart';

/// Signing in.
///
/// One filled coral action and nothing beside it. "สมัครสมาชิก" is a ghost
/// button underneath rather than a second button on the same row — a screen
/// with two equally weighted choices is a screen where neither is the answer.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthStore _store;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _store = sl<AuthStore>()..reset();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    // The router's guard sends a signed-in user out of here on its own — the
    // session is what it watches, so there is nothing to navigate to by hand.
    await _store.signIn();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'ยินดีต้อนรับกลับ',
      subtitle: 'เข้าสู่ระบบเพื่อฝากซื้อของ หรือเปิดทริปรับหิ้ว',
      footer: Observer(
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'เข้าสู่ระบบ',
              size: AppButtonSize.large,
              fullWidth: true,
              loading: _store.isSubmitting,
              onPressed: _store.canSignIn ? _submit : null,
            ),
            const SizedBox(height: AppSpace.x2),
            AppButton(
              label: 'ยังไม่มีบัญชี? สมัครสมาชิก',
              variant: AppButtonVariant.ghost,
              fullWidth: true,
              onPressed: _store.isSubmitting
                  ? null
                  : () => context.push(AppRoutes.register),
            ),
          ],
        ),
      ),
      children: [
        Observer(
          builder: (_) => _store.hasError
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x5),
                  child: AppNotice(
                    tone: AppTone.error,
                    message: _store.errorMessage!,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AppTextField(
          label: 'อีเมล',
          hint: 'you@example.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.mail_outline_rounded,
          onChanged: _store.setEmail,
        ),
        const SizedBox(height: AppSpace.x5),
        Observer(
          builder: (_) => AppTextField(
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
            onSubmitted: (_) => _store.canSignIn ? _submit() : null,
          ),
        ),
      ],
    );
  }
}
