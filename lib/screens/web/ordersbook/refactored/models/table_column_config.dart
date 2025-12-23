class TableColumnConfig {
  final List<String> headers;
  final Map<String, double> columnMinWidth;
  final Map<String, int> columnFlex;

  const TableColumnConfig({
    required this.headers,
    required this.columnMinWidth,
    this.columnFlex = const {},
  });

  // Factory for Order Book columns
  factory TableColumnConfig.orderBook(double screenWidth) {
    return const TableColumnConfig(
      headers: [
        'Instrument',
        'Product',
        'Type',
        'Qty',
        'Avg price',
        'LTP',
        'Price',
        'Trigger price',
        'Order value',
        'Status',
        'Time'
      ],
      columnMinWidth: {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'Avg price': 120,
        'LTP': 100,
        'Price': 100,
        'Trigger price': 150,
        'Order value': 130,
        'Status': 110,
        'Time': 220,
      },
    );
  }

  // Factory for Trade Book columns
  factory TableColumnConfig.tradeBook(double screenWidth) {
    return const TableColumnConfig(
      headers: [
        'Instrument',
        'Product',
        'Type',
        'Qty',
        'Price',
        'Trade value',
        'Order no',
        'Time'
      ],
      columnMinWidth: {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'Price': 100,
        'Trade value': 130,
        'Order no': 120,
        'Time': 220,
      },
      columnFlex: {
        'Instrument': 3,
        'Product': 2,
        'Type': 2,
        'Qty': 1,
        'Price': 2,
        'Trade value': 2,
        'Order no': 2,
        'Time': 2,
      },
    );
  }

  // Factory for GTT Order columns
  factory TableColumnConfig.gttOrders(double screenWidth) {
    return const TableColumnConfig(
      headers: ['Instrument', 'Product', 'Type', 'Qty', 'LTP', 'Trigger', 'Status', 'Time'],
      columnMinWidth: {
        'Instrument': 300,
        'Product': 110,
        'Type': 90,
        'Qty': 80,
        'LTP': 100,
        'Trigger': 120,
        'Status': 110,
        'Time': 220,
      },
    );
  }
}
