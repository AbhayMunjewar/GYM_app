import datetime
import uuid
import json
from django.core.management.base import BaseCommand
from django.utils import timezone
from tenancy.models import Subscription, Invoice, AuditLog

class Command(BaseCommand):
    help = "SaaS Background Cron Tasks (Trial/Subscription Expiries, Renewal Alerts, Invoice Auto-Generation, and Audit logs cleanup)"

    def handle(self, *args, **options):
        today = datetime.date.today()
        self.stdout.write(f"[{timezone.now()}] Starting SaaS Cron checks...")

        # 1. Trial Expiry check
        trials_expired = Subscription.objects.filter(status='TRIAL', end_date__lt=today)
        for sub in trials_expired:
            sub.status = 'EXPIRED'
            sub.save(update_fields=['status'])
            self.stdout.write(self.style.WARNING(f"Trial expired for tenant: {sub.tenant.name}"))
            # Log audit
            AuditLog.objects.create(
                tenant=sub.tenant,
                action="TRIAL_EXPIRED",
                details_str=json.dumps({"message": "Trial period ended."})
            )

        # 2. Subscription Expiry check
        active_expired = Subscription.objects.filter(status='ACTIVE', end_date__lt=today)
        for sub in active_expired:
            sub.status = 'EXPIRED'
            sub.save(update_fields=['status'])
            self.stdout.write(self.style.WARNING(f"Active subscription expired for tenant: {sub.tenant.name}"))
            # Log audit
            AuditLog.objects.create(
                tenant=sub.tenant,
                action="SUBSCRIPTION_EXPIRED",
                details_str=json.dumps({"message": "Active plan period ended."})
            )

        # 3. Renewal Reminder notifications (3 days remaining)
        reminder_date = today + datetime.timedelta(days=3)
        expiring_soon = Subscription.objects.filter(status='ACTIVE', end_date=reminder_date)
        for sub in expiring_soon:
            self.stdout.write(f"Renewal alert generated for: {sub.tenant.name}")
            AuditLog.objects.create(
                tenant=sub.tenant,
                action="RENEWAL_REMINDER_SENT",
                details_str=json.dumps({"message": f"Renewal reminder alert registered for date {reminder_date}."})
            )

        # 4. Invoice Auto-Generation (for auto_renew subscriptions expiring tomorrow)
        tomorrow = today + datetime.timedelta(days=1)
        auto_renews = Subscription.objects.filter(status='ACTIVE', end_date=tomorrow, auto_renew=True)
        for sub in auto_renews:
            plan = sub.plan
            price = plan.price_monthly
            tax = price * 18 // 100
            inv_num = f"INV-AUTO-{uuid.uuid4().hex[:8].upper()}"
            invoice = Invoice.objects.create(
                tenant=sub.tenant,
                invoice_number=inv_num,
                amount=price + tax,
                tax=tax,
                due_date=tomorrow + datetime.timedelta(days=7),
                status='UNPAID'
            )
            self.stdout.write(self.style.SUCCESS(f"Auto-generated invoice {inv_num} for tenant: {sub.tenant.name}"))
            AuditLog.objects.create(
                tenant=sub.tenant,
                action="INVOICE_AUTO_GENERATE",
                details_str=json.dumps({"invoice_number": inv_num, "amount": float(price + tax)})
            )

        # 5. Audit Log cleanup (delete entries older than 90 days)
        cutoff = timezone.now() - datetime.timedelta(days=90)
        deleted_count, _ = AuditLog.objects.filter(created_at__lt=cutoff).delete()
        if deleted_count > 0:
            self.stdout.write(self.style.SUCCESS(f"Cleaned up {deleted_count} old audit logs."))

        self.stdout.write(self.style.SUCCESS("SaaS background cron execution completed successfully."))
