import sqlite3

conn = sqlite3.connect(input())
cur = conn.cursor()

cur.execute("BEGIN;")

cur.execute("""
CREATE TABLE lang (
	id INTEGER PRIMARY KEY,
    word TEXT NOT NULL,
    definition TEXT NOT NULL
);
""")

cur.execute("""
INSERT INTO lang (id, word, definition)
    SELECT idx AS id, word AS word, short AS definition
    FROM data;
""")

cur.execute("drop TABLE data;")

cur.execute("drop table properties;")

cur.execute("COMMIT;")
conn.execute("VACUUM;")
cur.close()
conn.commit()
conn.close()