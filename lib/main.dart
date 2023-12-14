// main.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:import_erc20_tokens/token.dart';
import 'package:provider/provider.dart';
import 'token_provider.dart';

Future<void> main() async {
  //for calling GraphQL
  await initHiveForFlutter();
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();

  bool _areFieldsEditable = true;

  void _onAddressChanged(BuildContext context, String value) async {
    // Your logic to update Token Symbol, Token Decimal, and Token Logo
    // Fetch token details and update the corresponding fields
    final TokenProvider tokenProvider = context.read<TokenProvider>();
    final token = await tokenProvider.fetchTokenDetails(value);

    if (token != null) {
      _symbolController.text = token['symbol'];
      _decimalController.text = token['decimals'];
      _logoController.text = token['logoURI'];
      // Set the flag to make fields read-only
      _areFieldsEditable = false;
    } else {
      clearFields();

      // Show an alert dialog when token is null
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Data is Empty'),
              content:
                  Text('Token data is empty. Please check the token address.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
    setState(() {});
  }

  void clearFields() {
    // Clear Token Symbol, Token Decimal, and Token Logo if no valid token is found
    _symbolController.clear();
    _decimalController.clear();
    _logoController.clear();
    _areFieldsEditable = true;
  }

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
                    filled: true,
                    fillColor: Colors.white),
                onChanged: (value) {
                  _onAddressChanged(context, value);
                }),
            SizedBox(height: 16),
            TextField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: 'Token Symbol',
                filled: true,
                fillColor: _areFieldsEditable ? Colors.white : Colors.grey,
              ),
              readOnly: !_areFieldsEditable,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _decimalController,
              decoration: InputDecoration(
                labelText: 'Token Decimal',
                filled: true,
                fillColor: _areFieldsEditable ? Colors.white : Colors.grey,
              ),
              readOnly: !_areFieldsEditable,
            ),
            SizedBox(height: 16),
            _buildTokenLogo(_logoController.text),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importToken(context),
              child: Text('Import Token'),
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
                Text(
                    'Price: \$${token.currentPriceUSD} (${token.changePercent24hr}%)'),
                Text(
                    'Coin Gecko: \$${token.coinGeckoPriceUSD} (${token.coinGeckoChangePercent24hr}%)'),
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
          child: ClipOval(
            child: Image.network(
              logoURI,
              fit: BoxFit.contain,
            ),
          ));
    } else {
      // If no logo URL is provided, you can display a placeholder or omit the logo
      return Container();
    }
  }

  void _importToken(BuildContext context) async {
    final String address = _addressController.text;
    final TokenProvider tokenProvider = context.read<TokenProvider>();

    await tokenProvider.addToken(address);
    // Clear the Token Address field
    _addressController.clear();
    clearFields();
    setState(() {});
  }

  void _deleteToken(BuildContext context, Token token) {
    // Delete the token from the provider
    context.read<TokenProvider>().deleteToken(token.id);
  }
}
