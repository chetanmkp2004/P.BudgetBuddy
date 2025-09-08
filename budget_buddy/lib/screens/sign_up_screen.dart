import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 1
  final _email = TextEditingController();
  final _password = TextEditingController();
  // Step 2
  final _income = TextEditingController();
  final _preferences = TextEditingController();
  // Step 3
  bool _biometric = false;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  Future<void> _next() async {
    if (!_formKeys[_step].currentState!.validate()) return;
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // Final submit: register with Firebase Auth
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account created')));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        final msg = _mapAuthError(e);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _ProgressBar(step: _step),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Form(
                      key: _formKeys[0],
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator:
                                (v) =>
                                    (v == null || v.length < 6)
                                        ? 'Min 6 chars'
                                        : null,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Step 1: Credentials',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKeys[1],
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _income,
                            decoration: const InputDecoration(
                              labelText: 'Monthly Income (USD)',
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Enter income'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _preferences,
                            decoration: const InputDecoration(
                              labelText: 'Spending Preferences / Notes',
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Step 2: Financial Profile',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKeys[2],
                      child: ListView(
                        children: [
                          SwitchListTile(
                            value: _biometric,
                            title: const Text(
                              'Enable biometric sign-in (mock)',
                            ),
                            onChanged: (v) => setState(() => _biometric = v),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Step 3: Security Options',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(onPressed: _back, child: const Text('Back')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_step == 2 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed:
                    () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _mapAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'An account already exists for that email.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'operation-not-allowed':
      return 'Email/password accounts are not enabled.';
    case 'weak-password':
      return 'Password is too weak.';
    default:
      return 'Registration failed. (${e.code})';
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i <= step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1E40AF) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
