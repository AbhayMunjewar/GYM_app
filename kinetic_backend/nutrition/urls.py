from django.urls import path
from . import views

urlpatterns = [
    path('generate-plan/', views.GeneratePlanView.as_view()),
    path('generate-meals/', views.GenerateMealsView.as_view()),
    path('grocery-list/', views.GroceryListView.as_view()),
    path('food-replacement/', views.FoodReplacementView.as_view()),
    path('log/', views.DietLogView.as_view()),
    path('compliance/', views.ComplianceView.as_view()),
    path('coach/chat/', views.DietCoachView.as_view()),
]
