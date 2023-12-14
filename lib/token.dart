class Token {
  late int id;
  final String name;
  final String symbol;
  final String address;
  final String decimals;
  final String logoURI;
  final String currentPriceUSD;
  final String changePercent24hr;
  final String coinGeckoPriceUSD;
  final String coinGeckoChangePercent24hr;

  Token({
    required this.id,
    required this.name,
    required this.symbol,
    required this.address,
    required this.decimals,
    required this.logoURI,
    required this.currentPriceUSD,
    required this.changePercent24hr,
    required this.coinGeckoPriceUSD,
    required this.coinGeckoChangePercent24hr,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'symbol': symbol,
      'address': address,
      'decimals': decimals,
      'logoURI': logoURI,
      'currentPriceUSD': currentPriceUSD,
      'changePercent24hr': changePercent24hr,
      'coinGeckoPriceUSD': coinGeckoPriceUSD,
      'coinGeckoChangePercent24hr': coinGeckoChangePercent24hr,
    };
  }

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'] ?? 0,
      name: json['name'],
      symbol: json['symbol'],
      address: json['address'],
      decimals: json['decimals'].toString(),
      logoURI: json['logoURI'],
      currentPriceUSD: json['currentPriceUSD'] ?? '',
      changePercent24hr: json['changePercent24hr'] ?? '',
      coinGeckoPriceUSD: json['coinGeckoPriceUSD'] ?? '',
      coinGeckoChangePercent24hr: json['coinGeckoChangePercent24hr'] ?? '',
    );
  }
}
