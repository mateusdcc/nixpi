-- Baseline seed data for lawyer segments and workflows

INSERT OR IGNORE INTO lawyer_segments (segment_id, name, description) VALUES
    ('solo', 'Solo Practitioner', 'Independent lawyer handling all operations, billing, and casework'),
    ('small_firm', 'Small Law Firm', 'Firms with 2-10 attorneys, basic administrative staff'),
    ('mid_large_firm', 'Mid & Large Law Firm', '10+ attorneys, specialized departments, IT, and ops teams'),
    ('in_house', 'In-House Legal Department', 'Corporate legal counsel managing business risk and external counsel'),
    ('legal_ops', 'Legal Operations', 'Professionals optimizing legal service delivery, tech, and processes'),
    ('paralegal_admin', 'Paralegals & Legal Admins', 'Support staff managing filings, docketing, schedules, and document prep');

INSERT OR IGNORE INTO workflows (workflow_id, name, category, description) VALUES
    ('client_intake', 'Client Intake & Onboarding', 'client_facing', 'Lead capture, conflict checks, retainer agreements, client portal'),
    ('billing_collections', 'Billing, Invoicing & Collections', 'financial', 'Hourly/flat billing, trust accounting, Pix/card invoicing, collections'),
    ('time_tracking', 'Time Tracking & Fee Capture', 'financial', 'Passive and active time logging, task classification, billable rate tracking'),
    ('doc_automation', 'Document Automation & Assembly', 'document', 'Template generation, clause libraries, contract drafting, batch assembly'),
    ('contract_review', 'Contract Review & Redlining', 'document', 'Risk identification, redline comparison, negotiation playbooks'),
    ('deadlines_docketing', 'Deadlines, Calendar & Docketing', 'compliance', 'Court calendar calculation, rule-based deadlines, reminders'),
    ('court_filing', 'Court Filing & Electronic Submissions', 'litigation', 'PJe, e-SAJ, Projudi, DJe, federal and state portal filings'),
    ('legal_research', 'Legal Research & Jurisprudence', 'analysis', 'Case law search, statutory interpretation, doctrinal summaries'),
    ('case_management', 'Case & Matter Management', 'operations', 'Dossier organization, milestone tracking, party relationships'),
    ('evidence_organization', 'Evidence & Exhibit Management', 'litigation', 'Document numbering, audio/video indexing, chain of custody, OCR'),
    ('client_communication', 'Client Communication & Updates', 'client_facing', 'WhatsApp, email updates, secure document sharing, query status'),
    ('compliance_regulatory', 'Compliance & Regulatory Monitoring', 'compliance', 'LGPD, OAB ethics rules, CNJ directives, industry regulation'),
    ('legal_ai', 'Legal AI Workflows', 'ai_automation', 'Summarization, translation, automated drafting, pattern discovery');
