from rest_framework import serializers
from django.contrib.auth import get_user_model
from tenancy.models import Tenant, TenantSettings, SubscriptionPlan, Subscription, License, Invoice, BillingHistory, FeatureFlag
from gyms.models import Gym, Branch

User = get_user_model()

class RegisterTenantSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    full_name = serializers.CharField(max_length=255)
    phone_number = serializers.CharField(max_length=20, required=False, default='')
    gym_name = serializers.CharField(max_length=255)
    address = serializers.CharField()
    city = serializers.CharField(max_length=100)
    state = serializers.CharField(max_length=100)
    pincode = serializers.CharField(max_length=20)
    contact_number = serializers.CharField(max_length=20)

class SubscriptionPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = SubscriptionPlan
        fields = '__all__'

class SubscriptionSerializer(serializers.ModelSerializer):
    plan_details = SubscriptionPlanSerializer(source='plan', read_only=True)
    remaining_days = serializers.SerializerMethodField()

    class Meta:
        model = Subscription
        fields = ['id', 'status', 'start_date', 'end_date', 'trial_start_date', 'trial_end_date', 'auto_renew', 'plan_details', 'remaining_days']

    def get_remaining_days(self, obj):
        import datetime
        today = datetime.date.today()
        if obj.end_date >= today:
            return (obj.end_date - today).days
        return 0

class LicenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = License
        fields = '__all__'

class InvoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invoice
        fields = '__all__'

class BillingHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = BillingHistory
        fields = '__all__'

class FeatureFlagSerializer(serializers.ModelSerializer):
    class Meta:
        model = FeatureFlag
        fields = ['feature_name', 'is_enabled']

class BranchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Branch
        fields = '__all__'
        read_only_fields = ['gym']
