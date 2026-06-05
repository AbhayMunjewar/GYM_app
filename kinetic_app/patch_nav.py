import os
import glob
import re

folders = [
    r'lib\screens\owner\*.dart',
    r'lib\screens\member\*.dart',
    r'lib\screens\trainer\*.dart'
]

nav_tile_pattern = '''
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? kPrimary.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? const Border(left: BorderSide(color: kPrimary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : kOnSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => navigateByTitle(context, title),
      ),
    );
  }
'''

bottom_nav_pattern = '''
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateByTitle(context, title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? kPrimary : kOnSurfaceVariant),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: isActive ? kPrimary : kOnSurfaceVariant, fontSize: 12)),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle)),
          ]
        ],
      ),
    );
  }
'''

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False

    if 'class _NavTile extends StatelessWidget' in content:
        content = re.sub(
            r'@override\s*Widget build\(BuildContext context\) \{\s*return Container\([\s\S]*?child: ListTile\([\s\S]*?leading: Icon\([\s\S]*?title: Text\([\s\S]*?\),\s*\),\s*\);\s*\}',
            nav_tile_pattern.strip(),
            content
        )
        changed = True

    if 'class _BottomNavIcon extends StatelessWidget' in content:
        content = re.sub(
            r'@override\s*Widget build\(BuildContext context\) \{\s*return Column\([\s\S]*?children: \[[\s\S]*?Icon\([\s\S]*?Text\([\s\S]*?if \(isActive\) \.\.\.\[[\s\S]*?\]\s*\],\s*\);\s*\}',
            bottom_nav_pattern.strip(),
            content
        )
        changed = True

    if changed:
        import_stmt = "import '../../utils/nav_utils.dart';"
        if import_stmt not in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)
            if import_stmt not in content:
                content = import_stmt + "\n" + content
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Patched {filepath}')

for pattern in folders:
    for file in glob.glob(pattern):
        patch_file(file)
