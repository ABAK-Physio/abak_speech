import 'dart:convert';
import 'dart:io';

const String addonId = 'abak_whisper';
const String addonName = 'ABAK Dictée vocale';
const String addonVersion = String.fromEnvironment(
  'ABAK_SPEECH_VERSION',
  defaultValue: '0.0.0',
);

Future<void> main(List<String> arguments) async {
  if (arguments.contains('--version')) {
    _writeJson({
      'ok': true,
      'providerId': addonId,
      'providerName': addonName,
      'version': addonVersion,
    });
    return;
  }

  if (arguments.contains('--status')) {
    _writeJson({
      'ok': true,
      'providerId': addonId,
      'providerName': addonName,
      'version': addonVersion,
      'local': true,
      'internetRequired': false,
    });
    return;
  }

  if (arguments.contains('--transcribe')) {
    final commandIndex = arguments.indexOf('--transcribe');

    if (commandIndex + 1 >= arguments.length) {
      _writeJson({
        'ok': false,
        'errorCode': 'missing_audio_file',
        'message': 'Aucun fichier audio fourni.',
      });
      exitCode = 2;
      return;
    }

    final audioFilePath = arguments[commandIndex + 1];

    await _transcribe(audioFilePath);
    return;
  }

  _writeJson(
    {
      'ok': false,
      'errorCode': 'unsupported_command',
      'message': 'Commande non prise en charge.',
    },
  );

  exitCode = 2;
}

Future<void> _transcribe(String audioFilePath) async {
  final audioFile = File(audioFilePath);

  if (!await audioFile.exists()) {
    _writeJson({
      'ok': false,
      'errorCode': 'invalid_audio',
      'message': 'Le fichier audio est introuvable.',
    });
    exitCode = 2;
    return;
  }

  final executable = File(Platform.resolvedExecutable);
  final addonDirectory = executable.parent.path;

  final whisperExecutable = Platform.isWindows
      ? '$addonDirectory\\whisper-cli.exe'
      : '$addonDirectory/whisper-cli';

  final modelPath = Platform.isWindows
      ? '$addonDirectory\\ggml-large-v3-turbo.bin'
      : '$addonDirectory/ggml-large-v3-turbo.bin';

  if (!await File(whisperExecutable).exists()) {
    _writeJson({
      'ok': false,
      'errorCode': 'whisper_not_found',
      'message': 'Le moteur Whisper est introuvable.',
    });
    exitCode = 2;
    return;
  }

  if (!await File(modelPath).exists()) {
    _writeJson({
      'ok': false,
      'errorCode': 'model_not_found',
      'message': 'Le modèle de reconnaissance vocale est introuvable.',
    });
    exitCode = 2;
    return;
  }

  final tempDirectory = await Directory.systemTemp.createTemp(
    'abak_speech_',
  );

  final outputBasePath = '${tempDirectory.path}/transcription';
  final outputTextFile = File('$outputBasePath.txt');

  try {
    final result = await Process.run(
      whisperExecutable,
      [
        '-m',
        modelPath,
        '-f',
        audioFile.path,
        '-l',
        'fr',
        '--output-txt',
        '--output-file',
        outputBasePath,
      ],
    );

    if (result.exitCode != 0) {
      _writeJson({
        'ok': false,
        'errorCode': 'transcription_failed',
        'message': 'La transcription vocale a échoué.',
      });
      exitCode = 2;
      return;
    }

    if (!await outputTextFile.exists()) {
      _writeJson({
        'ok': false,
        'errorCode': 'transcription_failed',
        'message': 'Aucune transcription n’a été produite.',
      });
      exitCode = 2;
      return;
    }

    final text = (await outputTextFile.readAsString()).trim();

    if (text.isEmpty) {
      _writeJson({
        'ok': false,
        'errorCode': 'empty_transcription',
        'message': 'Aucun texte n’a été reconnu.',
      });
      exitCode = 2;
      return;
    }

    _writeJson({
      'ok': true,
      'text': text,
    });
  } finally {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

void _writeJson(Map<String, Object?> data) {
  stdout.writeln(jsonEncode(data));
}
