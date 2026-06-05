from django.urls import path
from accounts.views import RegisterView, LoginView, CustomTokenRefreshView, LogoutView, UserMeView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='auth_register'),
    path('login/', LoginView.as_view(), name='auth_login'),
    path('token/refresh/', CustomTokenRefreshView.as_view(), name='auth_token_refresh'),
    path('logout/', LogoutView.as_view(), name='auth_logout'),
    path('me/', UserMeView.as_view(), name='auth_me'),
]
