import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_analysis_service.dart';

class FlightCompanion extends StatefulWidget {
  final String message;
  final bool isWarning;
  final Map<String, dynamic>? flightContext;

  const FlightCompanion({
    super.key,
    required this.message,
    this.isWarning = false,
    this.flightContext,
  });

  @override
  State<FlightCompanion> createState() => _FlightCompanionState();
}

class _FlightCompanionState extends State<FlightCompanion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _hasVibratedForCurrentWarning = false;

  // ---- IA ----
  String? _aiAdvice;
  bool _isLoadingAdvice = false;
  // ------------

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlightCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isWarning &&
        widget.isWarning &&
        !_hasVibratedForCurrentWarning) {
      HapticFeedback.vibrate();
      _hasVibratedForCurrentWarning = true;
    }

    if (oldWidget.isWarning && !widget.isWarning) {
      _hasVibratedForCurrentWarning = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _askAiAdvice() async {
    if (widget.flightContext == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Contexte de vol indisponible pour l'IA (flightContext null)."),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingAdvice = true;
    });

    try {
      final advice = await AiAnalysisService.quickAdviceFromContext(
        contextData: widget.flightContext!,
      );
      setState(() {
        _aiAdvice = advice;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur IA : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAdvice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 70,
            top: 0,
            child: _buildBubble(),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Expertise de Vol"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Statut : ${widget.isWarning ? 'Attention (Limites de vol)' : 'Navigation en zone sûre'}",
                      ),
                      const SizedBox(height: 8),
                      Text("Dernière analyse mécanique : ${widget.message}"),
                      const SizedBox(height: 12),
                      if (_aiAdvice != null) ...[
                        const Divider(),
                        const Text(
                          "Conseil IA (pilotage) :",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(_aiAdvice!),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: _isLoadingAdvice ? null : _askAiAdvice,
                      child: _isLoadingAdvice
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("Conseil IA"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Compris !"),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/flight_companion.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.smart_toy, size: 40, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble() {
    if (widget.isWarning) {
      return Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_aiAdvice != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _aiAdvice!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 220),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[900],
              ),
            ),
            if (_aiAdvice != null) ...[
              const SizedBox(height: 6),
              Text(
                _aiAdvice!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[800],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    }
  }
}