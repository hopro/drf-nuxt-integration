from rest_framework import viewsets
from .models import Post, BlogComment
from .serializers import PostSerializer, CommentSerializer

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all().order_by('-id')
    serializer_class = PostSerializer

class CommentViewSet(viewsets.ModelViewSet):
    queryset = BlogComment.objects.all().order_by('-id')
    serializer_class = CommentSerializer