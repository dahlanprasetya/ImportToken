// main.dart
import 'package:flutter/material.dart';
import 'package:import_erc20_tokens/token.dart';
import 'package:provider/provider.dart';
import 'token_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TokenProvider(),
      child: MaterialApp(
        title: 'Import Token ERC20',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Token ERC20'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Token Address',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importToken(context),
              child: Text('Import Token'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: 'Token Symbol',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _decimalController,
              decoration: InputDecoration(
                labelText: 'Token Decimal',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _logoController,
              decoration: InputDecoration(
                labelText: 'Token Logo',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            Text(
              'Imported Tokens:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildTokenList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenList(BuildContext context) {
    final tokenProvider = context.watch<TokenProvider>();

    return ListView.builder(
      itemCount: tokenProvider.tokens.length,
      itemBuilder: (context, index) {
        final Token token = tokenProvider.tokens[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(token.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Symbol: ${token.symbol}'),
                Text('Decimal: ${token.decimals}'),
              ],
            ),
            leading: _buildTokenLogo(token.logoURI), // Added this line
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteToken(context, token),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTokenLogo(String logoURI) {
    if (logoURI.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        child: Image.network(
          logoURI,
          fit: BoxFit.contain,
        ),
      );
    } else {
      // If no logo URL is provided, you can display a placeholder or omit the logo
      return Container();
    }
  }

  void _importToken(BuildContext context) async {
    final String address = _addressController.text;
    final TokenProvider tokenProvider = context.read<TokenProvider>();

    await tokenProvider.addToken(address);

    // Fetch and update additional token details
    final Token importedToken = tokenProvider.tokens.last;

    _symbolController.text = importedToken.symbol;
    _decimalController.text = importedToken.decimals.toString();
    _logoController.text = importedToken.logoURI;

    // Clear the Token Address field
    _addressController.clear();
  }

  void _deleteToken(BuildContext context, Token token) {
    // Delete the token from the provider
    context.read<TokenProvider>().deleteToken(token.id);
  }
}
