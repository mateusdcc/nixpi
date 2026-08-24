#!/usr/bin/env python3
"""DuckDB Evidence Ledger Manager for Legal Tech Product-Opportunity Research."""

import argparse
import json
import os
import sys
import duckdb

DEFAULT_DB_PATH = os.path.expanduser("~/.local/share/nixpi/evidence/ledger.duckdb")
SCHEMA_PATH = os.path.join(os.path.dirname(__file__), "schema.sql")
SEED_PATH = os.path.join(os.path.dirname(__file__), "seed.sql")


def get_connection(db_path: str):
    """Open or create a DuckDB database connection."""
    os.makedirs(os.path.dirname(os.path.abspath(db_path)), exist_ok=True)
    return duckdb.connect(db_path)


def init_db(con):
    """Initialize database tables and seed baseline taxonomy."""
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        con.execute(f.read())
    if os.path.exists(SEED_PATH):
        with open(SEED_PATH, "r", encoding="utf-8") as f:
            con.execute(f.read())
    print("Evidence ledger initialized successfully.")


def check_integrity(con):
    """Verify table presence and view validity."""
    tables = [
        "sources", "raw_evidence", "pain_instances", "pain_clusters",
        "lawyer_segments", "workflows", "products", "companies",
        "feature_gaps", "spend_signals", "country_validation",
        "opportunity_scores", "rejected_opportunities"
    ]
    for table in tables:
        count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"Table '{table}': {count} rows")
    con.execute("SELECT * FROM validated_opportunities_view LIMIT 0")
    print("Integrity check passed: all 13 tables and validation view ready.")


def insert_raw_evidence(con, payload_json: str):
    """Insert a raw evidence record."""
    data = json.loads(payload_json)
    query = """
    INSERT INTO raw_evidence (
        evidence_id, source_id, source_type, source_url,
        publication_date, country, language, author_anonymized_id,
        exact_quote, translated_quote, lawyer_segment, practice_area,
        workflow, current_workaround, tool_mentioned,
        engagement_signal, spend_signal, duplicate_group_id, confidence
    ) VALUES (
        $evidence_id, $source_id, $source_type, $source_url,
        $publication_date, $country, $language, $author_anonymized_id,
        $exact_quote, $translated_quote, $lawyer_segment, $practice_area,
        $workflow, $current_workaround, $tool_mentioned,
        $engagement_signal, $spend_signal, $duplicate_group_id, $confidence
    )
    """
    con.execute(query, data)
    print(f"Inserted evidence record {data.get('evidence_id')}")


def query_validated(con):
    """Query and print validated opportunities."""
    res = con.execute("SELECT * FROM validated_opportunities_view ORDER BY total_score DESC").fetchall()
    print(json.dumps(res, default=str, indent=2))


def main():
    parser = argparse.ArgumentParser(description="DuckDB Evidence Ledger Manager")
    parser.add_argument("--db", default=DEFAULT_DB_PATH, help="Path to DuckDB database")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("init", help="Initialize schema and seed taxonomy")
    subparsers.add_parser("check", help="Check integrity of database")
    subparsers.add_parser("validated", help="List validated opportunities")

    insert_parser = subparsers.add_parser("insert-evidence", help="Insert evidence JSON")
    insert_parser.add_argument("payload", help="JSON string with evidence fields")

    args = parser.parse_args()
    con = get_connection(args.db)

    commands = {
        "init": lambda: init_db(con),
        "check": lambda: check_integrity(con),
        "validated": lambda: query_validated(con),
        "insert-evidence": lambda: insert_raw_evidence(con, args.payload),
    }

    cmd = commands.get(args.command)
    if cmd:
        cmd()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
