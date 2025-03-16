from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import PatientViewSet, D_ychetViewSet, ProfosmotrViewSet, DeathDataViewSet, VaccinationViewSet, UchastkiViewSet

router = DefaultRouter()

router.register('patients', PatientViewSet)
router.register('d_ychet', D_ychetViewSet)
router.register('profosmotr', ProfosmotrViewSet)
router.register('death_data', DeathDataViewSet)
router.register('vaccinations', VaccinationViewSet)
router.register('uchastki', UchastkiViewSet)


urlpatterns = [
    path('', include(router.urls)),
]
