import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/written_sign_model.dart';

const List<String> _editorCategories = [
  'Alfabeto',
  'Números',
  'Cumprimentos',
  'Família',
  'Tempo',
  'Alimentos',
  'Cores',
  'Animais',
  'Verbos',
  'Outros',
];

const List<String> _symbolGroups = [
  'Mãos',
  'Movimento',
  'Rosto',
  'Corpo',
  'Marcas',
];

const List<_SymbolDefinition> _symbolPalette = [
  _SymbolDefinition(
    id: 'hand-open',
    label: 'Mão aberta',
    group: 'Mãos',
    icon: Icons.back_hand_outlined,
    color: Colors.blue,
  ),
  _SymbolDefinition(
    id: 'hand-point',
    label: 'Apontar',
    group: 'Mãos',
    icon: Icons.touch_app_outlined,
    color: Colors.blue,
  ),
  _SymbolDefinition(
    id: 'hand-fist',
    label: 'Punho',
    group: 'Mãos',
    icon: Icons.front_hand_outlined,
    color: Colors.blue,
  ),
  _SymbolDefinition(
    id: 'move-up',
    label: 'Mover cima',
    group: 'Movimento',
    icon: Icons.arrow_upward,
    color: Colors.deepOrange,
  ),
  _SymbolDefinition(
    id: 'move-down',
    label: 'Mover baixo',
    group: 'Movimento',
    icon: Icons.arrow_downward,
    color: Colors.deepOrange,
  ),
  _SymbolDefinition(
    id: 'move-repeat',
    label: 'Repetir',
    group: 'Movimento',
    icon: Icons.sync,
    color: Colors.deepOrange,
  ),
  _SymbolDefinition(
    id: 'face-neutral',
    label: 'Rosto neutro',
    group: 'Rosto',
    icon: Icons.sentiment_neutral,
    color: Colors.green,
  ),
  _SymbolDefinition(
    id: 'face-happy',
    label: 'Rosto feliz',
    group: 'Rosto',
    icon: Icons.sentiment_satisfied_alt,
    color: Colors.green,
  ),
  _SymbolDefinition(
    id: 'face-focus',
    label: 'Olhar',
    group: 'Rosto',
    icon: Icons.visibility_outlined,
    color: Colors.green,
  ),
  _SymbolDefinition(
    id: 'body-center',
    label: 'Corpo',
    group: 'Corpo',
    icon: Icons.accessibility_new,
    color: Colors.purple,
  ),
  _SymbolDefinition(
    id: 'body-lean',
    label: 'Inclinar',
    group: 'Corpo',
    icon: Icons.directions_run,
    color: Colors.purple,
  ),
  _SymbolDefinition(
    id: 'body-head',
    label: 'Cabeça',
    group: 'Corpo',
    icon: Icons.emoji_people,
    color: Colors.purple,
  ),
  _SymbolDefinition(
    id: 'mark-contact',
    label: 'Contato',
    group: 'Marcas',
    icon: Icons.radio_button_checked,
    color: Colors.teal,
  ),
  _SymbolDefinition(
    id: 'mark-line',
    label: 'Linha',
    group: 'Marcas',
    icon: Icons.horizontal_rule,
    color: Colors.teal,
  ),
  _SymbolDefinition(
    id: 'mark-cross',
    label: 'Cruz',
    group: 'Marcas',
    icon: Icons.close,
    color: Colors.teal,
  ),
];

_SymbolDefinition _getSymbolDefinition(String symbolId) {
  for (final symbol in _symbolPalette) {
    if (symbol.id == symbolId) return symbol;
  }
  return const _SymbolDefinition(
    id: 'unknown',
    label: 'Símbolo',
    group: 'Outros',
    icon: Icons.help_outline,
    color: Colors.grey,
  );
}

class WriteSignEditorScreen extends StatefulWidget {
  final WrittenSignModel? initialSign;

  const WriteSignEditorScreen({
    super.key,
    this.initialSign,
  });

  @override
  State<WriteSignEditorScreen> createState() => _WriteSignEditorScreenState();
}

class _WriteSignEditorScreenState extends State<WriteSignEditorScreen> {
  static const double _symbolSize = 56;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _glossController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late String _selectedCategory;

  String _selectedGroup = _symbolGroups.first;
  String? _selectedPlacedSymbolId;
  int _symbolCounter = 0;
  List<_PlacedSymbol> _placedSymbols = [];

  bool get _isEditing => widget.initialSign != null;

  _PlacedSymbol? get _selectedPlacedSymbol {
    for (final symbol in _placedSymbols) {
      if (symbol.instanceId == _selectedPlacedSymbolId) {
        return symbol;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final sign = widget.initialSign;
    _titleController = TextEditingController(text: sign?.title ?? '');
    _glossController = TextEditingController(text: sign?.glossPt ?? '');
    _descriptionController = TextEditingController(text: sign?.description ?? '');
    _tagsController = TextEditingController(text: sign?.tags.join(', ') ?? '');
    _selectedCategory = sign?.category ?? _editorCategories.last;
    _restorePlacedSymbols(sign?.layoutJson);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glossController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar sinal' : 'Novo sinal'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPreviewCard(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Nome do sinal',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do sinal.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _glossController,
                decoration: const InputDecoration(
                  labelText: 'Gloss em português',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o gloss em português.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _editorCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Ex: saudação, escola, básico',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Editor visual',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este editor nativo e simples monta o layout do sinal enquanto a versão web-first ainda não foi integrada.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symbolGroups
                    .map(
                      (group) => ChoiceChip(
                        label: Text(group),
                        selected: _selectedGroup == group,
                        onSelected: (_) {
                          setState(() {
                            _selectedGroup = group;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              _buildPalette(),
              const SizedBox(height: 12),
              _buildCanvas(context),
              const SizedBox(height: 12),
              _buildSelectedSymbolActions(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Salvar sinal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prévia do sinal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _titleController.text.trim().isEmpty
                ? 'O sinal montado aparecerá abaixo.'
                : _titleController.text.trim(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: _buildCanvasContent(
                interactive: false,
                symbolSize: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalette() {
    final symbols = _symbolPalette
        .where((symbol) => symbol.group == _selectedGroup)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symbols
          .map(
            (symbol) => SizedBox(
              width: 102,
              child: InkWell(
                onTap: () => _addSymbol(symbol),
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: symbol.color.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(symbol.icon, color: symbol.color),
                      const SizedBox(height: 6),
                      Text(
                        symbol.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Área do sinal',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: _buildCanvasContent(
              interactive: true,
              symbolSize: _symbolSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasContent({
    required bool interactive,
    required double symbolSize,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            if (_placedSymbols.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Escolha um símbolo na paleta e toque nele para adicionar na área do sinal.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ..._placedSymbols.map(
              (symbol) => _buildPlacedSymbol(
                symbol: symbol,
                width: width,
                height: height,
                symbolSize: symbolSize,
                interactive: interactive,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlacedSymbol({
    required _PlacedSymbol symbol,
    required double width,
    required double height,
    required double symbolSize,
    required bool interactive,
  }) {
    final definition = symbol.definition;
    final maxLeft = (width - symbolSize).clamp(0.0, double.infinity);
    final maxTop = (height - symbolSize).clamp(0.0, double.infinity);
    final left = maxLeft * symbol.x;
    final top = maxTop * symbol.y;
    final isSelected = symbol.instanceId == _selectedPlacedSymbolId;

    Widget child = Container(
      width: symbolSize,
      height: symbolSize,
      decoration: BoxDecoration(
        color: definition.color.withValues(alpha: isSelected ? 0.18 : 0.1),
        border: Border.all(
          color: isSelected
              ? definition.color
              : definition.color.withValues(alpha: 0.4),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: symbol.rotationQuarterTurns,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(symbol.mirrored ? -1 : 1, 1, 1),
              child: Icon(
                definition.icon,
                color: definition.color,
                size: symbolSize * 0.42,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              symbol.shortLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );

    if (interactive) {
      child = GestureDetector(
        onTap: () {
          setState(() {
            _selectedPlacedSymbolId = symbol.instanceId;
          });
        },
        onPanUpdate: (details) {
          final deltaX = maxLeft == 0 ? 0 : details.delta.dx / maxLeft;
          final deltaY = maxTop == 0 ? 0 : details.delta.dy / maxTop;
          _updatePlacedSymbol(
            symbol.instanceId,
            (current) => current.copyWith(
              x: (current.x + deltaX).clamp(0.0, 1.0),
              y: (current.y + deltaY).clamp(0.0, 1.0),
            ),
          );
        },
        child: child,
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }

  Widget _buildSelectedSymbolActions() {
    final selectedSymbol = _selectedPlacedSymbol;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações do símbolo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: selectedSymbol == null ? null : () => _rotateSelectedSymbol(-1),
              icon: const Icon(Icons.rotate_left),
              label: const Text('Girar -'),
            ),
            OutlinedButton.icon(
              onPressed: selectedSymbol == null ? null : () => _rotateSelectedSymbol(1),
              icon: const Icon(Icons.rotate_right),
              label: const Text('Girar +'),
            ),
            OutlinedButton.icon(
              onPressed: selectedSymbol == null ? null : _mirrorSelectedSymbol,
              icon: const Icon(Icons.flip),
              label: const Text('Espelhar'),
            ),
            OutlinedButton.icon(
              onPressed: selectedSymbol == null ? null : _duplicateSelectedSymbol,
              icon: const Icon(Icons.content_copy),
              label: const Text('Duplicar'),
            ),
            OutlinedButton.icon(
              onPressed: selectedSymbol == null ? null : _centerSelectedSymbol,
              icon: const Icon(Icons.center_focus_strong),
              label: const Text('Centralizar'),
            ),
            TextButton.icon(
              onPressed: selectedSymbol == null ? null : _deleteSelectedSymbol,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
            ),
            TextButton.icon(
              onPressed: _placedSymbols.isEmpty ? null : _clearAllSymbols,
              icon: const Icon(Icons.layers_clear),
              label: const Text('Limpar tudo'),
            ),
          ],
        ),
      ],
    );
  }

  void _restorePlacedSymbols(String? layoutJson) {
    if (layoutJson == null || layoutJson.trim().isEmpty) return;

    try {
      final decoded = json.decode(layoutJson);
      final dynamic rawSymbols;
      if (decoded is Map<String, dynamic>) {
        rawSymbols = decoded['symbols'];
      } else {
        rawSymbols = decoded;
      }

      if (rawSymbols is! List) return;

      _placedSymbols = rawSymbols
          .whereType<Map>()
          .map((raw) => _PlacedSymbol.fromMap(Map<String, dynamic>.from(raw)))
          .toList();

      if (_placedSymbols.isNotEmpty) {
        _selectedPlacedSymbolId = _placedSymbols.first.instanceId;
      }

      final maxSuffix = _placedSymbols
          .map((item) => int.tryParse(item.instanceId.split('_').last) ?? 0)
          .fold<int>(0, (current, value) => value > current ? value : current);
      _symbolCounter = maxSuffix;
    } catch (_) {
      _placedSymbols = [];
      _selectedPlacedSymbolId = null;
    }
  }

  void _addSymbol(_SymbolDefinition definition) {
    setState(() {
      _symbolCounter++;
      final symbol = _PlacedSymbol.fromDefinition(
        definition,
        instanceId: 'symbol_$_symbolCounter',
      );
      _placedSymbols = [..._placedSymbols, symbol];
      _selectedPlacedSymbolId = symbol.instanceId;
    });
  }

  void _updatePlacedSymbol(
    String instanceId,
    _PlacedSymbol Function(_PlacedSymbol current) transform,
  ) {
    setState(() {
      _placedSymbols = _placedSymbols
          .map((symbol) => symbol.instanceId == instanceId ? transform(symbol) : symbol)
          .toList();
    });
  }

  void _rotateSelectedSymbol(int delta) {
    final selectedSymbol = _selectedPlacedSymbol;
    if (selectedSymbol == null) return;

    _updatePlacedSymbol(
      selectedSymbol.instanceId,
      (current) => current.copyWith(
        rotationQuarterTurns: (current.rotationQuarterTurns + delta) % 4,
      ),
    );
  }

  void _mirrorSelectedSymbol() {
    final selectedSymbol = _selectedPlacedSymbol;
    if (selectedSymbol == null) return;

    _updatePlacedSymbol(
      selectedSymbol.instanceId,
      (current) => current.copyWith(mirrored: !current.mirrored),
    );
  }

  void _duplicateSelectedSymbol() {
    final selectedSymbol = _selectedPlacedSymbol;
    if (selectedSymbol == null) return;

    setState(() {
      _symbolCounter++;
      final duplicate = selectedSymbol.copyWith(
        instanceId: 'symbol_$_symbolCounter',
        x: (selectedSymbol.x + 0.08).clamp(0.0, 1.0),
        y: (selectedSymbol.y + 0.08).clamp(0.0, 1.0),
      );
      _placedSymbols = [..._placedSymbols, duplicate];
      _selectedPlacedSymbolId = duplicate.instanceId;
    });
  }

  void _centerSelectedSymbol() {
    final selectedSymbol = _selectedPlacedSymbol;
    if (selectedSymbol == null) return;

    _updatePlacedSymbol(
      selectedSymbol.instanceId,
      (current) => current.copyWith(x: 0.5, y: 0.5),
    );
  }

  void _deleteSelectedSymbol() {
    final selectedId = _selectedPlacedSymbolId;
    if (selectedId == null) return;

    setState(() {
      _placedSymbols = _placedSymbols
          .where((symbol) => symbol.instanceId != selectedId)
          .toList();
      _selectedPlacedSymbolId =
          _placedSymbols.isEmpty ? null : _placedSymbols.last.instanceId;
    });
  }

  void _clearAllSymbols() {
    setState(() {
      _placedSymbols = [];
      _selectedPlacedSymbolId = null;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_placedSymbols.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um símbolo antes de salvar.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final sign = widget.initialSign;
    final result = WrittenSignModel(
      id: sign?.id ?? now.millisecondsSinceEpoch.toString(),
      userId: sign?.userId ?? 'local_user',
      title: _titleController.text.trim(),
      glossPt: _glossController.text.trim(),
      description: _emptyToNull(_descriptionController.text),
      category: _selectedCategory,
      tags: _parseTags(_tagsController.text),
      fsw: _buildGeneratedCode(),
      layoutJson: _buildLayoutJson(),
      previewSvg: sign?.previewSvg,
      status: WrittenSignModel.statusDraft,
      createdAt: sign?.createdAt ?? now,
      updatedAt: now,
      publishedAt: null,
    );

    Navigator.of(context).pop(result);
  }

  String _buildGeneratedCode() {
    if (_placedSymbols.isEmpty) return '';

    final ordered = [..._placedSymbols]
      ..sort((a, b) {
        final byY = a.y.compareTo(b.y);
        if (byY != 0) return byY;
        return a.x.compareTo(b.x);
      });

    final parts = ordered
        .map(
          (symbol) =>
              '${symbol.symbolId}@${symbol.x.toStringAsFixed(2)},${symbol.y.toStringAsFixed(2)},r${symbol.rotationQuarterTurns},m${symbol.mirrored ? 1 : 0}',
        )
        .join('|');

    return 'SW-MVP:$parts';
  }

  String _buildLayoutJson() {
    return json.encode({
      'version': 1,
      'symbols': _placedSymbols.map((symbol) => symbol.toMap()).toList(),
    });
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

class _SymbolDefinition {
  final String id;
  final String label;
  final String group;
  final IconData icon;
  final Color color;

  const _SymbolDefinition({
    required this.id,
    required this.label,
    required this.group,
    required this.icon,
    required this.color,
  });
}

class _PlacedSymbol {
  final String instanceId;
  final String symbolId;
  final double x;
  final double y;
  final int rotationQuarterTurns;
  final bool mirrored;

  const _PlacedSymbol({
    required this.instanceId,
    required this.symbolId,
    required this.x,
    required this.y,
    this.rotationQuarterTurns = 0,
    this.mirrored = false,
  });

  factory _PlacedSymbol.fromDefinition(
    _SymbolDefinition definition, {
    required String instanceId,
  }) {
    return _PlacedSymbol(
      instanceId: instanceId,
      symbolId: definition.id,
      x: 0.5,
      y: 0.5,
    );
  }

  factory _PlacedSymbol.fromMap(Map<String, dynamic> map) {
    return _PlacedSymbol(
      instanceId: (map['instanceId'] ?? '') as String,
      symbolId: (map['symbolId'] ?? 'unknown') as String,
      x: ((map['x'] as num?) ?? 0.5).toDouble().clamp(0.0, 1.0),
      y: ((map['y'] as num?) ?? 0.5).toDouble().clamp(0.0, 1.0),
      rotationQuarterTurns: ((map['rotationQuarterTurns'] as num?) ?? 0).toInt() % 4,
      mirrored: (map['mirrored'] ?? false) as bool,
    );
  }

  _SymbolDefinition get definition => _getSymbolDefinition(symbolId);

  String get shortLabel {
    final parts = definition.label.split(' ');
    if (parts.length == 1) return definition.label;
    return '${parts.first} ${parts.last}'.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'instanceId': instanceId,
      'symbolId': symbolId,
      'x': x,
      'y': y,
      'rotationQuarterTurns': rotationQuarterTurns,
      'mirrored': mirrored,
    };
  }

  _PlacedSymbol copyWith({
    String? instanceId,
    double? x,
    double? y,
    int? rotationQuarterTurns,
    bool? mirrored,
  }) {
    return _PlacedSymbol(
      instanceId: instanceId ?? this.instanceId,
      symbolId: symbolId,
      x: x ?? this.x,
      y: y ?? this.y,
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      mirrored: mirrored ?? this.mirrored,
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0DCC7)
      ..strokeWidth = 1;

    const divisions = 4;
    for (var i = 1; i < divisions; i++) {
      final dx = size.width * i / divisions;
      final dy = size.height * i / divisions;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
