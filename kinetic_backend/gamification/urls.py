from django.urls import path
from .views import (
    PointsBalanceView, PointsHistoryView, StreaksListView,
    BadgeListView, MyBadgesListView, ChallengeListView, ChallengeDetailView,
    JoinChallengeView, MyJoinedChallengesView, LeaderboardView,
    RewardCatalogView, RedeemRewardView, RedemptionHistoryView,
    ApproveRedemptionView, RejectRedemptionView
)

urlpatterns = [
    # Rewards / Points
    path('rewards/points/', PointsBalanceView.as_view(), name='points-balance'),
    path('rewards/history/', PointsHistoryView.as_view(), name='points-history'),
    path('rewards/streaks/', StreaksListView.as_view(), name='streaks-list'),
    path('rewards/badges/', BadgeListView.as_view(), name='badges-list'),
    path('rewards/my-badges/', MyBadgesListView.as_view(), name='my-badges-list'),
    path('rewards/catalog/', RewardCatalogView.as_view(), name='rewards-catalog'),
    path('rewards/redeem/', RedeemRewardView.as_view(), name='redeem-reward'),
    path('rewards/redemptions/', RedemptionHistoryView.as_view(), name='redemptions-history'),
    path('rewards/redemptions/<uuid:id>/approve/', ApproveRedemptionView.as_view(), name='approve-redemption'),
    path('rewards/redemptions/<uuid:id>/reject/', RejectRedemptionView.as_view(), name='reject-redemption'),

    # Challenges
    path('challenges/', ChallengeListView.as_view(), name='challenges-list'),
    path('challenges/join/', JoinChallengeView.as_view(), name='join-challenge'),
    path('challenges/my/', MyJoinedChallengesView.as_view(), name='my-joined-challenges'),
    path('challenges/<uuid:id>/', ChallengeDetailView.as_view(), name='challenge-detail'),

    # Leaderboard
    path('leaderboards/', LeaderboardView.as_view(), name='leaderboard'),
]
