import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/indices/index_list_model.dart';
import '../../../../../provider/index_list_provider.dart';
import 'index_list_card.dart';

class IndexScreen extends StatelessWidget {
  final List<IndexValue> indexData;
  const IndexScreen({super.key, required this.indexData});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read(indexListProvider).fetchAllIndex();
      },
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: indexData.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(color: Color(0xffDDE2E7), height: 0);
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {},
            child: IndexListCard(
              key: Key(index.toString()),
              indicesData: indexData[index],
            ),
          );
        },
      ),
    );
  }
}
