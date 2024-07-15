class IndexListOrder {
  final int index;
  final String idxname;
  final String token;
  final String exch;

  IndexListOrder(
      {required this.index,
      required this.idxname,
      required this.token,
      required this.exch});

  @override
  String toString() {
    return "$index:$idxname:$token:$exch";
  }
}
