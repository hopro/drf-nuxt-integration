# Generated by Django 5.1.6 on 2025-02-26 11:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0002_alter_customuser_address_alter_customuser_avatar_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='customuser',
            name='avatar',
            field=models.ImageField(blank=True, null=True, upload_to='static/avatars/', verbose_name='Аватар'),
        ),
    ]
