import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final List<String> tabs;
  final ValueChanged<int> onTabSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExpanded ? 200 : 60,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: isExpanded
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  const Text(
                    'eVetCare',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                final isSelected = widget.selectedIndex == index;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.blue.shade50,
                  leading: SizedBox(
                    width: 32,
                    child: Icon(
                      Icons.chevron_right,
                      color: isSelected ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                  title: isExpanded
                      ? Text(
                          widget.tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        )
                      : const SizedBox(width: 1, height: 1),
                  onTap: () => widget.onTabSelected(index),
                  dense: true,
                  minLeadingWidth: 0,
                  contentPadding: isExpanded ? null : EdgeInsets.zero,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
