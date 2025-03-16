import django_filters
from .models import Patient, D_ychet, Profosmotr, DeathData, Uchastki
from rest_framework import viewsets, filters


class PatientFilter(django_filters.FilterSet):
    name = django_filters.CharFilter(lookup_expr='icontains')
    surname = django_filters.CharFilter(lookup_expr='icontains')
    patronymic = django_filters.CharFilter(lookup_expr='icontains')
    date_of_birth = django_filters.DateFromToRangeFilter()
    date_of_death = django_filters.DateFromToRangeFilter()
    address = django_filters.CharFilter(lookup_expr='icontains')
    age = django_filters.CharFilter(lookup_expr='icontains')
    phone = django_filters.CharFilter(lookup_expr='icontains')
    snils = django_filters.CharFilter(lookup_expr='icontains')
    ychastok = django_filters.CharFilter(lookup_expr='exact')
    MO_prikrepl = django_filters.CharFilter(lookup_expr='icontains')
    lgota = django_filters.CharFilter(lookup_expr='icontains')
    category = django_filters.ChoiceFilter(choices=Patient.Category.choices)

    class Meta:
        model = Patient
        fields = []


class UchastkiFilter(django_filters.FilterSet):
    name = django_filters.CharFilter(lookup_expr='icontains')

    class Meta:
        model = Uchastki
        fields = []
