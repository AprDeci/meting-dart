import 'dart:convert';
import 'dart:math';

import 'package:meting_dart/src/providers/tencent/tencent_api.dart';
import 'package:meting_dart/src/providers/tencent/tencent_mapper.dart';

class TencentUrlResolver {
  TencentUrlResolver({required this.api, required this.headers});

  final TencentApi api;
  final Map<String, dynamic> Function() headers;

  Future<Map<String, dynamic>> resolve(
    Map<String, dynamic> songResponse, {
    required int br,
  }) async {
    final songs = pickList(songResponse, ['data']);
    if (songs.isEmpty) {
      return mapUrl(url: '', size: 0, br: -1);
    }

    final song = asMap(songs.first);
    final file = asMap(song['file']);
    final mediaMid = file['media_mid']?.toString() ?? '';
    final songMid = song['mid']?.toString() ?? '';
    final songType = song['type'] ?? 0;
    if (mediaMid.isEmpty || songMid.isEmpty) {
      return mapUrl(url: '', size: 0, br: -1);
    }

    final candidates = _qualityCandidates(file, mediaMid);
    final payload = {
      'req_0': {
        'module': 'vkey.GetVkeyServer',
        'method': 'CgiGetVkey',
        'param': {
          'guid': _guid(),
          'songmid': candidates.map((_) => songMid).toList(),
          'filename': candidates.map((candidate) => candidate.filename).toList(),
          'songtype': candidates.map((_) => songType).toList(),
          'uin': _uin(),
          'loginflag': 1,
          'platform': '20',
        },
      },
    };

    final response = await api.get(
      'https://u.y.qq.com/cgi-bin/musicu.fcg',
      query: {
        'format': 'json',
        'platform': 'yqq.json',
        'needNewCode': 0,
        'data': jsonEncode(payload),
      },
    );
    final data = asMap(asMap(response['req_0'])['data']);
    final vkeys = data['midurlinfo'] is List ? data['midurlinfo'] as List : const [];
    final sips = data['sip'] is List ? data['sip'] as List : const [];
    final sip = sips.isEmpty ? '' : sips.first.toString();

    for (var i = 0; i < candidates.length && i < vkeys.length; i++) {
      final candidate = candidates[i];
      final vkey = asMap(vkeys[i])['vkey']?.toString() ?? '';
      final purl = asMap(vkeys[i])['purl']?.toString() ?? '';
      if (candidate.br <= br && candidate.size > 0 && vkey.isNotEmpty) {
        return mapUrl(url: '$sip$purl', size: candidate.size, br: candidate.br);
      }
    }

    return mapUrl(url: '', size: 0, br: -1);
  }

  List<_QualityCandidate> _qualityCandidates(
    Map<String, dynamic> file,
    String mediaMid,
  ) {
    const specs = [
      ('size_flac', 999, 'F000', 'flac'),
      ('size_320mp3', 320, 'M800', 'mp3'),
      ('size_192aac', 192, 'C600', 'm4a'),
      ('size_128mp3', 128, 'M500', 'mp3'),
      ('size_96aac', 96, 'C400', 'm4a'),
      ('size_48aac', 48, 'C200', 'm4a'),
      ('size_24aac', 24, 'C100', 'm4a'),
    ];
    return specs.map((spec) {
      return _QualityCandidate(
        size: int.tryParse(file[spec.$1]?.toString() ?? '') ?? 0,
        br: spec.$2,
        filename: '${spec.$3}$mediaMid.${spec.$4}',
      );
    }).toList();
  }

  String _guid() => (Random().nextDouble() * 10000000000).floor().toString();

  String _uin() {
    final cookie = headers()['Cookie']?.toString() ?? '';
    return RegExp(r'uin=(\d+)').firstMatch(cookie)?.group(1) ?? '0';
  }
}

class _QualityCandidate {
  const _QualityCandidate({
    required this.size,
    required this.br,
    required this.filename,
  });

  final int size;
  final int br;
  final String filename;
}
