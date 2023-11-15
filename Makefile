all:
	pandoc -t revealjs -s -o index.html main.md  --mathjax --standalone -V theme=simple --include-in-header=slides.css