# 此Makefile有些操作的封装可能比原先的还麻烦，但是该博客不是经常更新，所以将这些命令直接写在这里，也作为记录使用

new:
	hexo new ${f}

preview:
	hexo clean
	hexo g
	hexo s