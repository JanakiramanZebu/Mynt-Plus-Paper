class SortConfig {
  final int? sortColumnIndex;
  final bool sortAscending;

  const SortConfig({
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  SortConfig copyWith({
    int? sortColumnIndex,
    bool? sortAscending,
  }) {
    return SortConfig(
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  SortConfig toggleSort(int columnIndex) {
    if (sortColumnIndex == columnIndex) {
      // Same column - toggle direction
      return copyWith(sortAscending: !sortAscending);
    } else {
      // New column - sort ascending
      return SortConfig(
        sortColumnIndex: columnIndex,
        sortAscending: true,
      );
    }
  }
}
