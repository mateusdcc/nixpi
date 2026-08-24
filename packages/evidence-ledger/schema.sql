-- DuckDB Evidence Ledger Schema
-- Evidence-first product-opportunity research database

CREATE TABLE IF NOT EXISTS sources (
    source_id VARCHAR PRIMARY KEY,
    source_type VARCHAR NOT NULL, -- reddit, capterra, g2, upwork, youtube, news_rss, etc.
    source_name VARCHAR NOT NULL,
    base_url VARCHAR,
    reliability_score DOUBLE DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lawyer_segments (
    segment_id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL, -- solo, small_firm, mid_large_firm, in_house, legal_ops, paralegal_admin
    description VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS workflows (
    workflow_id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL, -- client_intake, billing_collections, time_tracking, doc_automation, court_filing, etc.
    category VARCHAR,
    description VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL,
    country VARCHAR,
    website VARCHAR,
    funding_stage VARCHAR,
    estimated_revenue VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR PRIMARY KEY,
    company_id VARCHAR REFERENCES companies(company_id),
    name VARCHAR NOT NULL,
    category VARCHAR,
    pricing_model VARCHAR,
    monthly_price_usd DOUBLE,
    brazil_presence BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_evidence (
    evidence_id VARCHAR PRIMARY KEY,
    source_id VARCHAR REFERENCES sources(source_id),
    source_type VARCHAR NOT NULL,
    source_url VARCHAR NOT NULL,
    publication_date DATE,
    collection_date DATE DEFAULT CURRENT_DATE,
    country VARCHAR NOT NULL, -- US, UK, BR, DE, CA, etc.
    language VARCHAR NOT NULL, -- en, pt, etc.
    author_anonymized_id VARCHAR NOT NULL,
    exact_quote VARCHAR NOT NULL,
    translated_quote VARCHAR,
    lawyer_segment VARCHAR,
    practice_area VARCHAR, -- litigation, transactional, labor, civil, criminal, tax, etc.
    workflow VARCHAR,
    current_workaround VARCHAR,
    tool_mentioned VARCHAR,
    engagement_signal VARCHAR, -- upvotes, comments, shares, views
    spend_signal VARCHAR, -- budget, price paid, hourly loss
    duplicate_group_id VARCHAR,
    confidence DOUBLE DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pain_clusters (
    cluster_id VARCHAR PRIMARY KEY,
    title VARCHAR NOT NULL,
    workflow_id VARCHAR REFERENCES workflows(workflow_id),
    job_to_be_done VARCHAR NOT NULL,
    recurring_pain_summary VARCHAR NOT NULL,
    severity_level VARCHAR, -- low, medium, high, critical
    frequency_level VARCHAR, -- daily, weekly, monthly
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pain_instances (
    instance_id VARCHAR PRIMARY KEY,
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    evidence_id VARCHAR REFERENCES raw_evidence(evidence_id),
    lawyer_segment VARCHAR,
    practice_area VARCHAR,
    time_loss_hours_per_week DOUBLE,
    financial_cost_monthly_usd DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS feature_gaps (
    gap_id VARCHAR PRIMARY KEY,
    product_id VARCHAR REFERENCES products(product_id),
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    missing_feature VARCHAR NOT NULL,
    complaint_count INTEGER DEFAULT 1,
    switching_reason VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS spend_signals (
    spend_id VARCHAR PRIMARY KEY,
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    evidence_id VARCHAR REFERENCES raw_evidence(evidence_id),
    signal_type VARCHAR NOT NULL, -- current_spend, willingness_to_pay, hourly_rate_wasted, upwork_budget
    amount_usd DOUBLE,
    amount_brl DOUBLE,
    notes VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS country_validation (
    validation_id VARCHAR PRIMARY KEY,
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    country VARCHAR NOT NULL,
    pain_exists BOOLEAN NOT NULL,
    local_term_pt VARCHAR,
    pje_esaj_integration_needed BOOLEAN DEFAULT FALSE,
    digital_cert_needed BOOLEAN DEFAULT FALSE,
    whatsapp_needed BOOLEAN DEFAULT FALSE,
    pix_billing_needed BOOLEAN DEFAULT FALSE,
    lgpd_compliance_needed BOOLEAN DEFAULT FALSE,
    oab_cnj_restrictions VARCHAR,
    inaccessible_data_risk VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS opportunity_scores (
    score_id VARCHAR PRIMARY KEY,
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    pain_recurrence DOUBLE DEFAULT 0, -- max 15
    severity DOUBLE DEFAULT 0, -- max 15
    time_financial_cost DOUBLE DEFAULT 0, -- max 15
    spend_willingness DOUBLE DEFAULT 0, -- max 15
    existing_tools_dissatisfaction DOUBLE DEFAULT 0, -- max 10
    reachable_target_customer DOUBLE DEFAULT 0, -- max 10
    brazil_localization_advantage DOUBLE DEFAULT 0, -- max 10
    mvp_30_days DOUBLE DEFAULT 0, -- max 10
    penalty_restricted_data DOUBLE DEFAULT 0, -- up to -30
    penalty_collaboration DOUBLE DEFAULT 0, -- up to -20
    penalty_network_effects DOUBLE DEFAULT 0, -- up to -20
    penalty_general_ai DOUBLE DEFAULT 0, -- up to -15
    penalty_weak_evidence DOUBLE DEFAULT 0, -- up to -15
    total_score DOUBLE GENERATED ALWAYS AS (
        pain_recurrence + severity + time_financial_cost + spend_willingness +
        existing_tools_dissatisfaction + reachable_target_customer +
        brazil_localization_advantage + mvp_30_days +
        penalty_restricted_data + penalty_collaboration +
        penalty_network_effects + penalty_general_ai + penalty_weak_evidence
    ),
    is_validated BOOLEAN DEFAULT FALSE,
    confidence_level VARCHAR, -- low, medium, high
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rejected_opportunities (
    rejection_id VARCHAR PRIMARY KEY,
    cluster_id VARCHAR REFERENCES pain_clusters(cluster_id),
    reason_code VARCHAR NOT NULL, -- general_ai_adequate, network_effect_barrier, inaccessible_court_api, weak_evidence
    explanation VARCHAR NOT NULL,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Validation View: enforces the 6 evidence standards
CREATE OR REPLACE VIEW validated_opportunities_view AS
SELECT 
    c.cluster_id,
    c.title,
    c.job_to_be_done,
    COUNT(DISTINCT r.source_type) AS source_family_count,
    COUNT(DISTINCT r.author_anonymized_id) AS independent_user_count,
    COUNT(DISTINCT r.evidence_id) AS quotation_count,
    COUNT(DISTINCT s.spend_id) AS spend_signal_count,
    COALESCE(cv.pain_exists, FALSE) AS brazil_validated,
    sc.total_score
FROM pain_clusters c
JOIN pain_instances pi ON c.cluster_id = pi.cluster_id
JOIN raw_evidence r ON pi.evidence_id = r.evidence_id
LEFT JOIN spend_signals s ON c.cluster_id = s.cluster_id
LEFT JOIN country_validation cv ON c.cluster_id = cv.cluster_id AND cv.country = 'BR'
LEFT JOIN opportunity_scores sc ON c.cluster_id = sc.cluster_id
GROUP BY c.cluster_id, c.title, c.job_to_be_done, cv.pain_exists, sc.total_score
HAVING 
    COUNT(DISTINCT r.source_type) >= 3 AND
    COUNT(DISTINCT r.author_anonymized_id) >= 3 AND
    COUNT(DISTINCT r.evidence_id) >= 5 AND
    COUNT(DISTINCT s.spend_id) >= 1 AND
    COALESCE(cv.pain_exists, FALSE) = TRUE;
