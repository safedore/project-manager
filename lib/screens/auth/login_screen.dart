import 'package:flutter/material.dart';
import 'package:project_manager/screens/home/dashboard_screen.dart';
import '../../common/form_validators.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _error;
  bool _isEmailFilled = false;
  bool _isPassFilled = false;
  bool _hidePass = true;

  void _login() async {
    if (_isEmailFilled || _isPassFilled) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final error = await _authService.login(email, password);

      if (error == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        setState(() => _error = 'Incorrect mail/password. Please try again');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Image.network(
              'https://placehold.co/200x200.png',
              errorBuilder: (context, error, stackTrace) => SizedBox(height: 200, width: 200, child: Text('Could not load image'),),
            ),
            const SizedBox(height: 20),
            _textFormField(_emailController, 'Email', false, TextInputType.emailAddress),
            SizedBox(height: 8),
            _textFormField(_passwordController, 'Password', _hidePass, TextInputType.visiblePassword),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  _isEmailFilled && _isPassFilled ? Colors.blue : Colors.grey,
                ),
              ),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              ),
              child: const Text(
                'Don’t have an account? Sign Up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textFormField(controller, label, obscureText, keyboardType) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: label == 'Password'
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _hidePass = !_hidePass;
                  });
                },
                icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: (value) {
        setState(() {
          if (value.isNotEmpty) {
            if (label == 'Email') {
              if (TextFieldValidation.emailValidate(value)) {
                _isEmailFilled = true;
              } else {
                _isEmailFilled = false;
              }
            } else if (label == 'Password') {
              _isPassFilled = true;
            }
          }
        });
      },
    );
  }
}
