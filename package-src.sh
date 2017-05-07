# Make sure you've tagged release with 'git tag -a v1.0' first.
PROJ=GottaFeeling
git archive master --prefix=$PROJ/ | gzip > $PROJ-`git describe --long master`.tar.gz
