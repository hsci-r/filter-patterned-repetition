mysql = mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} -P ${DB_PORT} -D ${DB_NAME}

all: analysis

data/repetition.tsv:
	$(mysql) < code/query.sql > $@

analysis: data/repetition.tsv
	make -C analysis analysis
