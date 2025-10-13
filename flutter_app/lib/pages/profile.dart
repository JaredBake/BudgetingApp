import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> user;
  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _pwFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPwController;
  late final TextEditingController _newPwController;
  late final TextEditingController _confirmPwController;

  bool _saving = false;
  bool _savingPassword = false;
  bool _receiveNotifications = true;
  bool _showEmail = false;
  bool _allowMarketing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.user['name'] ??
            widget.user['userName'] ??
            widget.user['username'] ??
            '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _currentPwController = TextEditingController();
    _newPwController = TextEditingController();
    _confirmPwController = TextEditingController();

    _receiveNotifications =
        widget.user['receiveNotifications'] ?? _receiveNotifications;
    _showEmail = widget.user['showEmail'] ?? _showEmail;
    _allowMarketing = widget.user['allowMarketing'] ?? _allowMarketing;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  void _showPlaceholder(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action — not implemented yet')),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    widget.user['name'] = _nameController.text.trim();
    widget.user['email'] = _emailController.text.trim();
    widget.user['receiveNotifications'] = _receiveNotifications;
    widget.user['showEmail'] = _showEmail;
    widget.user['allowMarketing'] = _allowMarketing;
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved (local only)')),
    );
  }

  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _currentPwController.clear();
    _newPwController.clear();
    _confirmPwController.clear();
    setState(() => _savingPassword = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed (placeholder)')),
    );
  }

  Future<void> _confirmLogout() async {
    final doLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out? This is a placeholder.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );

    if (doLogout == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out (placeholder)')),
      );
    }
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validateName(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateCurrentPw(String? v) {
    if ((v ?? '').isEmpty) return 'Enter your current password';
    return null;
  }

  String? _validateNewPw(String? v) {
    final p = v ?? '';
    if (p.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPw(String? v) {
    if (v != _newPwController.text) return 'Passwords do not match';
    return null;
  }

  Widget _buildPermissions() {
    return Column(
      children: [
        SwitchListTile(
          value: _receiveNotifications,
          onChanged: (v) => setState(() => _receiveNotifications = v),
          title: const Text('Receive notifications'),
        ),
        SwitchListTile(
          value: _showEmail,
          onChanged: (v) => setState(() => _showEmail = v),
          title: const Text('Show email on profile'),
        ),
        SwitchListTile(
          value: _allowMarketing,
          onChanged: (v) => setState(() => _allowMarketing = v),
          title: const Text('Allow marketing emails'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = (widget.user['userName'] ??
            widget.user['username'] ??
            widget.user['name'])
        ?.toString() ??
        'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showPlaceholder('Settings');
                  break;
                case 'logout':
                  _confirmLogout();
                  break;
                default:
                  _showPlaceholder(value);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Welcome, $username', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissions(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _saveProfile,
                            child: _saving
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save changes'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showPlaceholder('Edit avatar'),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit avatar (placeholder)',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Form(
                key: _pwFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Change password', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPwController,
                      decoration: const InputDecoration(labelText: 'Current password'),
                      obscureText: true,
                      validator: _validateCurrentPw,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPwController,
                      decoration: const InputDecoration(labelText: 'New password'),
                      obscureText: true,
                      validator: _validateNewPw,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPwController,
                      decoration: const InputDecoration(labelText: 'Confirm new password'),
                      obscureText: true,
                      validator: _validateConfirmPw,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _savingPassword ? null : _changePassword,
                            child: _savingPassword
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Change password'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}