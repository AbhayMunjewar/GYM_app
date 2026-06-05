from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/accounts/', include('accounts.urls')),
    path('api/gyms/', include('gyms.urls')),
    path('api/members/', include('members.urls')),
    path('api/trainers/', include('trainers.urls')),
]
