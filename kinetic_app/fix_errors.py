import os, re

def replace_str(filepath, old, new):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = content.replace(old, new)
    if content != new_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Fixed {filepath}')

def fix_all():
    files_with_icons = [
        r'lib\screens\owner\billing_payments_screen.dart',
        r'lib\screens\owner\communication_center_screen.dart',
        r'lib\screens\owner\member_management.dart',
        r'lib\screens\owner\owner_dashboard_screen.dart'
    ]
    for f in files_with_icons:
        replace_str(f, 'Icons.monitoring', 'Icons.analytics')
        replace_str(f, 'Icons.exercise', 'Icons.fitness_center')
        
    f_billing = r'lib\screens\owner\billing_payments_screen.dart'
    with open(f_billing, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'glass_card.dart' not in content:
        content = "import '../../components/glass_card.dart';\n" + content
        with open(f_billing, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Added glass_card import')

    f_gym = r'lib\screens\owner\gym_settings_screen.dart'
    replace_str(f_gym, 'BorderStyle.dashed', 'BorderStyle.solid')
    
    with open(f_gym, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'const Color kSecondaryContainer' not in content:
        content = content.replace('const Color kPrimary = Color(0xFFCAF300);', 'const Color kPrimary = Color(0xFFCAF300);\nconst Color kSecondaryContainer = Color(0xFF4B8EFF);')
        with open(f_gym, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Added kSecondaryContainer')

    f_mem = r'lib\screens\owner\member_management.dart'
    # Need to see line 144 for member_management.dart, but I will just regex remove border: Border.all(...) inside CircleAvatar if that's what it is, wait, CircleAvatar doesn't take 'border' argument. Container does.
    # The error is: named parameter 'border' isn't defined. member_management.dart:144:7
    with open(f_mem, 'r', encoding='utf-8') as f:
        content = f.read()
    content = re.sub(r'CircleAvatar\s*\(\s*.*?border:\s*Border\.all[^,]+,\s*', 'CircleAvatar(', content, flags=re.DOTALL)
    with open(f_mem, 'w', encoding='utf-8') as f:
        f.write(content)

fix_all()
