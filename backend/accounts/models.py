from django.contrib.auth.models import AbstractUser
from django.db import models

class CustomUser(AbstractUser):
    bith_date = models.DateField(blank=True, null=True, verbose_name='Дата рождения')
    mobile_phone = models.CharField(max_length=20, blank=True, null=True, verbose_name='Мобильный телефон')
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True, verbose_name='Аватар')
    address = models.TextField(blank=True, null=True, verbose_name='Адрес')
    comment = models.TextField(blank=True, null=True, verbose_name='Комментарий')

    def __str__(self):
        return self.username