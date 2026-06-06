import '../providers/ai_provider.dart';

/// Description Generation Service
/// 
/// Uses AI to generate invoice descriptions based on items and context
class DescriptionGenerationService {
  final AIProvider _provider;

  DescriptionGenerationService(this._provider);

  /// Generate invoice description from items
  /// 
  /// [items] - List of invoice items with description, quantity, unit price
  /// [clientName] - Optional client name for context
  /// [category] - Optional category for context
  /// Returns generated description
  Future<String> generateInvoiceDescription({
    required List<Map<String, dynamic>> items,
    String? clientName,
    String? category,
  }) async {
    // Build the prompt
    final prompt = _buildDescriptionPrompt(items, clientName, category);
    
    // Send to AI provider
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.7,
      maxTokens: 200,
    );
    
    return response;
  }

  /// Generate expense description
  /// 
  /// [category] - Expense category
  /// [amount] - Expense amount
  /// [additionalContext] - Additional context about the expense
  /// Returns generated description
  Future<String> generateExpenseDescription({
    required String category,
    required double amount,
    String? additionalContext,
  }) async {
    final prompt = _buildExpenseDescriptionPrompt(category, amount, additionalContext);
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.7,
      maxTokens: 150,
    );
    
    return response;
  }

  /// Suggest improvements to existing description
  /// 
  /// [currentDescription] - Current invoice/expense description
  /// [items] - Optional items for context
  /// Returns improved description
  Future<String> improveDescription({
    required String currentDescription,
    List<Map<String, dynamic>>? items,
  }) async {
    final prompt = _buildImprovementPrompt(currentDescription, items);
    
    final response = await _provider.completeText(
      prompt: prompt,
      temperature: 0.6,
      maxTokens: 200,
    );
    
    return response;
  }

  String _buildDescriptionPrompt(
    List<Map<String, dynamic>> items,
    String? clientName,
    String? category,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate a professional invoice description based on the following items:');
    buffer.writeln('');
    
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final description = item['description']?.toString() ?? 'Item';
      final quantity = item['quantity']?.toString() ?? '1';
      final unitPrice = item['unit_price']?.toString() ?? '0.00';
      final total = (item['quantity'] as num? ?? 0) * (item['unit_price'] as num? ?? 0);
      
      buffer.writeln('${i + 1}. $description (Qty: $quantity, Price: \$$unitPrice, Total: \$${total.toStringAsFixed(2)})');
    }
    
    if (clientName != null) {
      buffer.writeln('');
      buffer.writeln('Client: $clientName');
    }
    
    if (category != null) {
      buffer.writeln('Category: $category');
    }
    
    buffer.writeln('');
    buffer.writeln('Generate a concise, professional description (max 2 sentences) that summarizes the invoice.');
    buffer.writeln('Return only the description, no additional text.');
    
    return buffer.toString();
  }

  String _buildExpenseDescriptionPrompt(
    String category,
    double amount,
    String? additionalContext,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate a professional expense description:');
    buffer.writeln('');
    buffer.writeln('Category: $category');
    buffer.writeln('Amount: \$${amount.toStringAsFixed(2)}');
    
    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln('Additional context: $additionalContext');
    }
    
    buffer.writeln('');
    buffer.writeln('Generate a concise, professional description (max 1 sentence) for this expense.');
    buffer.writeln('Return only the description, no additional text.');
    
    return buffer.toString();
  }

  String _buildImprovementPrompt(
    String currentDescription,
    List<Map<String, dynamic>>? items,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('Improve the following invoice/expense description to make it more professional and clear:');
    buffer.writeln('');
    buffer.writeln('Current description: $currentDescription');
    
    if (items != null && items.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Invoice items:');
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        buffer.writeln('- ${item['description']?.toString() ?? 'Item'}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('Provide an improved version that is:');
    buffer.writeln('- Professional and clear');
    buffer.writeln('- Concise (max 2 sentences)');
    buffer.writeln('- Accurate based on the context');
    buffer.writeln('Return only the improved description, no additional text.');
    
    return buffer.toString();
  }
}
