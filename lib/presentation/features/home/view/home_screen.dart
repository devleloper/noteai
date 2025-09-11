import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/recording.dart';
import '../../recording/bloc/recording_bloc.dart';
import '../../recording/bloc/recording_event.dart';
import '../../recording/bloc/recording_state.dart';
import '../../recording/view/recording_screen.dart';
import '../../search/view/search_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../widgets/recording_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecordingBloc>().add(LoadRecordingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          // Remove redundant LoadRecordingsRequested call to prevent race condition
          // The RecordingBloc already emits RecordingsLoaded after RecordingCompleted
        },
        builder: (context, state) {
          if (state is RecordingLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is RecordingsLoaded) {
            if (state.recordings.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildRecordingsList(context, state.recordings);
          } else if (state is RecordingError) {
            return _buildErrorState(context, state.message);
          }
          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RecordingScreen(),
            ),
          );
        },
        icon: const Icon(Icons.mic),
        label: const Text('Record'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No recordings yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the microphone button to start your first recording',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecordingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Start Recording'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingsList(BuildContext context, recordings) {
    return BlocListener<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is TranscriptionCompleted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transcription completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TranscriptionError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcription failed: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<RecordingBloc>().add(LoadRecordingsRequested());
        },
        child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          final recording = recordings[index];
          return BlocBuilder<RecordingBloc, RecordingState>(
            builder: (context, state) {
              // Get the most up-to-date recording from the current state
              Recording? updatedRecording;
              if (state is RecordingsLoaded) {
                updatedRecording = state.recordings.firstWhere(
                  (r) => r.id == recording.id,
                  orElse: () => recording,
                );
              } else {
                updatedRecording = recording;
              }
              
              return RecordingCard(
                recording: updatedRecording!,
                onTap: () {
                  // TODO: Navigate to recording detail
                },
                onDelete: () {
                  _showDeleteDialog(context, updatedRecording!.id);
                },
              );
            },
          );
        },
      ),
    ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<RecordingBloc>().add(LoadRecordingsRequested());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String recordingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Are you sure you want to delete this recording? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RecordingBloc>().add(DeleteRecordingRequested(recordingId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
