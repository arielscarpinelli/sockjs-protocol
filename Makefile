
build: venv/.ok
	./venv/bin/pycco sockjs-protocol*.py

venv/.ok:
	rm -rf venv
	virtualenv venv
	./venv/bin/pip install pycco
	./venv/bin/pip install unittest2
	-rm distribute-*.tar.gz
	touch venv/.ok

clean:
	rm -rf venv *.pyc

serve: venv/.ok
	@while [ 1 ]; do			\
		make build;			\
		sleep 0.1;			\
		inotifywait -r -q -e modify .;	\
	done

upload: build
	@node -v > /dev/null
	[ -e ../sockjs-protocol-gh-pages ] || 				\
		git clone `git remote -v|tr "[:space:]" "\t"|cut -f 2`	\
			--branch gh-pages ../sockjs-protocol-gh-pages
	(cd ../sockjs-protocol-gh-pages; git pull;)
	cp docs/* ../sockjs-protocol-gh-pages
	(cd ../sockjs-protocol-gh-pages; git add sockjs*html; git commit sockjs*html -m "Content regenerated";)
	(cd ../sockjs-protocol-gh-pages; node generate_index.js > index.html;)
	@echo ' [*] Now run:'
	@echo '(cd ../sockjs-protocol-gh-pages; git push;)'
