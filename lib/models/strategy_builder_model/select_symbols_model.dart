/// Direct lookup request for /select-symbols with exact expiry and strike
class SelectSymbolsDirectRequest {
  final String exchange;
  final String symbol;
  final String optionType; // CE, PE
  final String expiry; // e.g. "27-MAR-2026"
  final String strikeprice; // e.g. "22000" or "" for no specific strike

  SelectSymbolsDirectRequest({
    required this.exchange,
    required this.symbol,
    required this.optionType,
    required this.expiry,
    this.strikeprice = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'exchange': exchange,
      'symbol': symbol,
      'option_type': optionType,
      'expiry': expiry,
      'strikeprice': strikeprice,
    };
  }
}

/// Request model for a single leg sent to POST /select-symbols
class SelectSymbolsLegRequest {
  final String exchange; // NFO, BFO, MCX
  final String symbol; // Underlying symbol (e.g. NIFTY, BANKNIFTY)
  final String underlyingType; // CASH or FUT
  final String optionType; // CE, PE, FUT
  final String? optionExpiryType; // W (weekly) or M (monthly) - required for CE/PE
  final int optionExpiryOffset; // 0=nearest, 1=next, etc.
  final String? strikeType; // ATM, ITM, OTM, PREMIUM - required for CE/PE
  final int strikeOffset; // Steps from ATM (used with ATM/ITM/OTM)
  final String? underlyingExpiryType; // W or M - required when underlyingType=FUT
  final int underlyingExpiryOffset; // 0=nearest, 1=next, etc.
  final double? nearestPrice; // For PREMIUM mode
  final double? abovePrice; // For PREMIUM mode
  final double? belowPrice; // For PREMIUM mode

  SelectSymbolsLegRequest({
    required this.exchange,
    required this.symbol,
    this.underlyingType = 'CASH',
    required this.optionType,
    this.optionExpiryType,
    this.optionExpiryOffset = 0,
    this.strikeType,
    this.strikeOffset = 0,
    this.underlyingExpiryType,
    this.underlyingExpiryOffset = 0,
    this.nearestPrice,
    this.abovePrice,
    this.belowPrice,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'exchange': exchange,
      'symbol': symbol,
      'option_type': optionType,
    };

    // underlying_type is required for ATM/ITM/OTM and FUT
    if (underlyingType.isNotEmpty) {
      data['underlying_type'] = underlyingType;
    }

    // underlying_expiry_type required when underlying_type=FUT
    if (underlyingType == 'FUT' && underlyingExpiryType != null) {
      data['underlying_expiry_type'] = underlyingExpiryType;
      data['underlying_expiry_offset'] = underlyingExpiryOffset;
    }

    // option_expiry_type required for CE/PE
    if (optionType != 'FUT' && optionExpiryType != null) {
      data['option_expiry_type'] = optionExpiryType;
      data['option_expiry_offset'] = optionExpiryOffset;
    }

    // For FUT option_type, only option_expiry_offset is needed
    if (optionType == 'FUT') {
      data['option_expiry_offset'] = optionExpiryOffset;
    }

    // strike_type and strike_offset required for CE/PE
    if (optionType != 'FUT' && strikeType != null) {
      data['strike_type'] = strikeType;

      if (strikeType == 'PREMIUM') {
        if (nearestPrice != null) data['nearest_price'] = nearestPrice;
        if (abovePrice != null) data['above_price'] = abovePrice;
        if (belowPrice != null) data['below_price'] = belowPrice;
      } else {
        data['strike_offset'] = strikeOffset;
      }
    }

    return data;
  }

  factory SelectSymbolsLegRequest.fromJson(Map<String, dynamic> json) {
    return SelectSymbolsLegRequest(
      exchange: json['exchange'] ?? 'NFO',
      symbol: json['symbol'] ?? '',
      underlyingType: json['underlying_type'] ?? 'CASH',
      optionType: json['option_type'] ?? 'CE',
      optionExpiryType: json['option_expiry_type'],
      optionExpiryOffset: json['option_expiry_offset'] ?? 0,
      strikeType: json['strike_type'],
      strikeOffset: json['strike_offset'] ?? 0,
      underlyingExpiryType: json['underlying_expiry_type'],
      underlyingExpiryOffset: json['underlying_expiry_offset'] ?? 0,
      nearestPrice: (json['nearest_price'] as num?)?.toDouble(),
      abovePrice: (json['above_price'] as num?)?.toDouble(),
      belowPrice: (json['below_price'] as num?)?.toDouble(),
    );
  }
}

/// Response model for a single leg from POST /select-symbols
class SelectSymbolsLegResponse {
  final String? symbol;
  final String? optionType;
  final String? selectedSymbol; // e.g. "NIFTY27FEB25C24000"
  final String? token;
  final String? exch;
  final String? expiry; // e.g. "27-Feb-2025"
  final String? strike;
  final String? lotSize;
  final String? tickSize;
  final String? undTok; // Underlying token
  final String? undSym; // Underlying symbol
  final String? undExch; // Underlying exchange
  final double? underlyingPrice;
  final double? optionPrice;
  final String? error;

  SelectSymbolsLegResponse({
    this.symbol,
    this.optionType,
    this.selectedSymbol,
    this.token,
    this.exch,
    this.expiry,
    this.strike,
    this.lotSize,
    this.tickSize,
    this.undTok,
    this.undSym,
    this.undExch,
    this.underlyingPrice,
    this.optionPrice,
    this.error,
  });

  factory SelectSymbolsLegResponse.fromJson(Map<String, dynamic> json) {
    return SelectSymbolsLegResponse(
      symbol: json['symbol'],
      optionType: json['option_type'],
      selectedSymbol: json['selected_symbol'],
      token: json['token']?.toString(),
      exch: json['exch'],
      expiry: json['expiry'],
      strike: json['strike']?.toString(),
      lotSize: json['lot_size']?.toString(),
      tickSize: json['tick_size']?.toString(),
      undTok: json['und_tok']?.toString(),
      undSym: json['und_sym'],
      undExch: json['und_exch'],
      underlyingPrice: (json['underlying_price'] as num?)?.toDouble(),
      optionPrice: (json['option_price'] as num?)?.toDouble(),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'option_type': optionType,
      'selected_symbol': selectedSymbol,
      'token': token,
      'exch': exch,
      'expiry': expiry,
      'strike': strike,
      'lot_size': lotSize,
      'tick_size': tickSize,
      'und_tok': undTok,
      'und_sym': undSym,
      'und_exch': undExch,
      'underlying_price': underlyingPrice,
      'option_price': optionPrice,
      'error': error,
    };
  }

  bool get hasError => error != null && error!.isNotEmpty;
}
