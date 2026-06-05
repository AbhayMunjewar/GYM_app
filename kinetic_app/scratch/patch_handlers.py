import os
import re
import glob

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # For QuickAction widgets
    content = re.sub(
        r'(class QuickAction.*?onTap):\s*\(\)\s*\{\},',
        r'\1: () => navigateByTitle(context, title),',
        content,
        flags=re.DOTALL
    )

    # For general View All buttons, point to their respective sections
    content = re.sub(
        r"TextButton\(\s*onPressed:\s*\(\)\s*\{\},\s*child:\s*const Text\('View All'",
        r"TextButton(\n              onPressed: () => context.push('/member/challenges'),\n              child: const Text('View All'",
        content
    )

    # For ASK AI COACH
    content = re.sub(
        r"InkWell\(\s*onTap:\s*\(\)\s*\{\},\s*child:\s*Row\([\s\S]*?'ASK AI COACH'[\s\S]*?\),",
        r"InkWell(\n                onTap: () => context.push('/member/chat'),\n                child: Row(\n                  mainAxisSize: MainAxisSize.min,\n                  children: const [\n                    Text('ASK AI COACH', style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold, letterSpacing: 1)),\n                    SizedBox(width: 8),\n                    Icon(Icons.arrow_forward, color: kPrimary, size: 16),\n                  ],\n                ),\n              )",
        content
    )

    # For START WORKOUT
    content = re.sub(
        r"onPressed:\s*\(\)\s*\{\},\s*\n\s*label:\s*const Text\('START WORKOUT'",
        r"onPressed: () => context.push('/workout-center'),\n                      label: const Text('START WORKOUT'",
        content
    )

    # For VIEW ROUTINE
    content = re.sub(
        r"child:\s*const Text\('VIEW ROUTINE'[\s\S]*?\),\s*onPressed:\s*\(\)\s*\{\},",
        r"child: const Text('VIEW ROUTINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),\n                      onPressed: () => context.push('/member/exercise-library'),",
        content
    )

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Patched {filepath}")

patch_file('d:/GYM/kinetic_app/lib/screens/member/member_dashboard.dart')
