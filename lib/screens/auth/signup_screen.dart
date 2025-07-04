import 'package:flutter/material.dart';
import '../../common/form_validators.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cPasswordController = TextEditingController();
  final _authService = AuthService();
  String? _error;
  bool _isEmailFilled = false;
  bool _isPassFilled = false;
  bool _hidePass = true;
  bool _isLoading = false;

  void _signup() async {
    if (_isEmailFilled && _isPassFilled) {
      setState(() {
        _isLoading = true;
      });
      final email = _emailController.text;
      final password = _passwordController.text;
      final error = await _authService.signUp(email, password);

      if (error == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _error = error;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Image.asset('assets/auth_img.jpg'),
                  const SizedBox(height: 20),
                  _textFormField(
                    _emailController,
                    'Email',
                    false,
                    'johndoe@anon.com',
                    TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _textFormField(
                    _passwordController,
                    'Password',
                    _hidePass,
                    'Minimum 8 characters',
                    TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 10),
                  _textFormField(
                    _cPasswordController,
                    'Confirm Password',
                    _hidePass,
                    'Same as Password',
                    TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _signup,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        _isEmailFilled && _isPassFilled
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _textFormField(
    controller,
    label,
    obscureText,
    hintText,
    keyboardType,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: label != 'Email'
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _hidePass = !_hidePass;
                  });
                },
                icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
              )
            : null,
        hintText: hintText,
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
          if (TextFieldValidation.emailValidate(_emailController.text)) {
            if (TextFieldValidation.confirmPasswordValidate(
              _passwordController.text,
              _cPasswordController.text,
            )) {
              _isEmailFilled = true;
              _isPassFilled = true;
            } else {
              _isPassFilled = false;
            }
          } else {
            _isEmailFilled = false;
          }
        });
      },
    );
  }
}
