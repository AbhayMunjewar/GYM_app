import os
import shutil
import datetime
from django.core.management.base import BaseCommand
from django.conf import settings

class Command(BaseCommand):
    help = "Automated local backups of SQLite/PostgreSQL database and Media files with retention policies"

    def handle(self, *args, **options):
        self.stdout.write("Starting backup process...")
        
        backup_dir = settings.BASE_DIR / 'backups'
        os.makedirs(backup_dir, exist_ok=True)
        
        timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        
        # 1. Database backup (checks if using SQLite or PostgreSQL)
        db_engine = settings.DATABASES['default']['ENGINE']
        if 'sqlite' in db_engine:
            sqlite_path = settings.DATABASES['default']['NAME']
            if os.path.exists(sqlite_path):
                db_backup_file = backup_dir / f"db_backup_{timestamp}.sqlite3"
                shutil.copy2(sqlite_path, db_backup_file)
                self.stdout.write(self.style.SUCCESS(f"Database backed up successfully to {db_backup_file}"))
            else:
                self.stdout.write(self.style.ERROR("SQLite database file not found."))
        else:
            db_name = settings.DATABASES['default']['NAME']
            db_user = settings.DATABASES['default']['USER']
            db_host = settings.DATABASES['default']['HOST']
            db_port = settings.DATABASES['default']['PORT']
            dump_file = backup_dir / f"pg_backup_{db_name}_{timestamp}.sql"
            os.environ['PGPASSWORD'] = settings.DATABASES['default']['PASSWORD']
            cmd = f'pg_dump -h {db_host} -p {db_port} -U {db_user} {db_name} > "{dump_file}"'
            try:
                res = os.system(cmd)
                if res == 0:
                    self.stdout.write(self.style.SUCCESS(f"PostgreSQL Database backed up successfully to {dump_file}"))
                else:
                    self.stdout.write(self.style.ERROR(f"PostgreSQL dump command returned exit code {res}"))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"PostgreSQL dump failed: {str(e)}"))

        # 2. Media folder backup
        media_root = settings.MEDIA_ROOT
        if os.path.exists(media_root) and os.listdir(media_root):
            media_archive = backup_dir / f"media_backup_{timestamp}"
            shutil.make_archive(str(media_archive), 'zip', media_root)
            self.stdout.write(self.style.SUCCESS(f"Media files archived successfully to {media_archive}.zip"))
        else:
            self.stdout.write(self.style.WARNING("Media folder is empty or not found. Skipping media backup."))

        # 3. Retention policy: delete backups older than 7 days
        cutoff = datetime.datetime.now() - datetime.timedelta(days=7)
        for filename in os.listdir(backup_dir):
            file_path = os.path.join(backup_dir, filename)
            if os.path.isfile(file_path):
                file_time = datetime.datetime.fromtimestamp(os.path.getctime(file_path))
                if file_time < cutoff:
                    os.remove(file_path)
                    self.stdout.write(self.style.NOTICE(f"Removed expired backup: {filename}"))

        self.stdout.write(self.style.SUCCESS("Backup run complete."))
