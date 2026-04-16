class ColumnUtils {
  // Check if column is numeric
  static bool isNumericColumn(String header, String tableType) {
    switch (tableType) {
      case 'order':
        return header != 'Instrument' &&
            header != 'Product' &&
            header != 'Type' &&
            header != 'Status';
      case 'trade':
        return header != 'Instrument' &&
            header != 'Product' &&
            header != 'Type' &&
            header != 'Order no';
      case 'gtt':
        return header != 'Instrument' &&
            header != 'Product' &&
            header != 'Type' &&
            header != 'Status';
      default:
        return false;
    }
  }

  // Get column index for header (Order Book)
  static int getOrderBookColumnIndex(String header) {
    switch (header) {
      case 'Instrument':
        return 0;
      case 'Product':
        return 1;
      case 'Type':
        return 2;
      case 'Qty':
        return 3;
      case 'Avg price':
        return 4;
      case 'LTP':
        return 5;
      case 'Price':
        return 6;
      case 'Trigger price':
        return 7;
      case 'Order value':
        return 8;
      case 'Status':
        return 9;
      case 'Time':
        return 10;
      default:
        return -1;
    }
  }

  // Get column index for header (Trade Book)
  static int getTradeBookColumnIndex(String header) {
    switch (header) {
      case 'Instrument':
        return 0;
      case 'Product':
        return 1;
      case 'Type':
        return 2;
      case 'Qty':
        return 3;
      case 'Price':
        return 4;
      case 'Trade value':
        return 5;
      case 'Order no':
        return 6;
      case 'Time':
        return 7;
      default:
        return -1;
    }
  }

  // Get column index for header (GTT)
  static int getGttColumnIndex(String header) {
    switch (header) {
      case 'Instrument':
        return 0;
      case 'Product':
        return 1;
      case 'Type':
        return 2;
      case 'Qty':
        return 3;
      case 'LTP':
        return 4;
      case 'Trigger':
        return 5;
      case 'Status':
        return 6;
      case 'Time':
        return 7;
      default:
        return -1;
    }
  }
}
