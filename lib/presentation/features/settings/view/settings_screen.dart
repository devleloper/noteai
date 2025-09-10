import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (state is AuthAuthenticated) ...[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: state.user.photoUrl != null
                                ? NetworkImage(state.user.photoUrl!)
                                : null,
                            child: state.user.photoUrl == null
                                ? Text(
                                    state.user.displayName.isNotEmpty
                                        ? state.user.displayName[0].toUpperCase()
                                        : 'U',
                                  )
                                : null,
                          ),
                          title: Text(
                            state.user.displayName.isNotEmpty ? state.user.displayName : 'User',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            state.user.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ] else ...[
                        const ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text('Not signed in'),
                          subtitle: Text('Sign in to access your account'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Settings Options
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      subtitle: const Text('Manage notification preferences'),
                      trailing: Switch(
                        value: true, // TODO: Implement notification settings
                        onChanged: (value) {
                          // TODO: Implement notification toggle
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Storage'),
                      subtitle: const Text('Manage local storage and cache'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to storage settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy'),
                      subtitle: const Text('Privacy and data settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help and contact support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to help screen
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Account Actions
              Card(
                child: Column(
                  children: [
                    if (state is AuthAuthenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text('Sign out of your account'),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.login, color: Colors.blue),
                        title: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.blue),
                        ),
                        subtitle: const Text('Sign in to your account'),
                        onTap: () {
                          context.read<AuthBloc>().add(AuthSignInWithGoogleRequested());
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Info
              Center(
                child: Text(
                  'NoteAI v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your local recordings will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
