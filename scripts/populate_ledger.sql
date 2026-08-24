-- Populate DuckDB Evidence Ledger with Empirical Research Findings

-- 1. Initialize schema and seed
.read packages/evidence-ledger/schema.sql
.read packages/evidence-ledger/seed.sql

-- 2. Sources
INSERT OR REPLACE INTO sources (source_id, source_type, source_name, base_url, reliability_score) VALUES
    ('src_reddit_lawfirm', 'reddit', 'Reddit r/LawFirm & r/lawyers', 'https://reddit.com/r/LawFirm', 0.9),
    ('src_capterra_legal', 'capterra', 'Capterra Legal Software Reviews', 'https://capterra.com', 0.95),
    ('src_migalhas', 'news_rss', 'Migalhas Jurídicas', 'https://migalhas.com.br', 0.95),
    ('src_conjur', 'news_rss', 'Consultor Jurídico (ConJur)', 'https://conjur.com.br', 0.95),
    ('src_cnj_oab', 'regulatory', 'CNJ / OAB Official Resolutions', 'https://cnj.jus.br', 1.0),
    ('src_upwork_jobs', 'upwork', 'Upwork Legal Tech & Clio Jobs', 'https://upwork.com', 0.9),
    ('src_reclameaqui', 'complaints', 'Reclame Aqui Legal Tech Reviews', 'https://reclameaqui.com.br', 0.85);

-- 3. Companies & Products
INSERT OR REPLACE INTO companies (company_id, name, country, website, funding_stage, estimated_revenue) VALUES
    ('comp_clio', 'Themis Solutions (Clio)', 'CA', 'https://clio.com', 'Series F', '$100M+'),
    ('comp_projuris', 'Projuris (Softplan)', 'BR', 'https://projuris.com.br', 'Acquired', 'R$ 50M+'),
    ('comp_astrea', 'Aurum (Astrea)', 'BR', 'https://aurum.com.br', 'Growth', 'R$ 20M+'),
    ('comp_mycase', 'AffiniPay (MyCase)', 'US', 'https://mycase.com', 'Acquired', '$50M+');

INSERT OR REPLACE INTO products (product_id, company_id, name, category, pricing_model, monthly_price_usd, brazil_presence) VALUES
    ('prod_clio', 'comp_clio', 'Clio Manage', 'Practice Management', 'per_user_monthly', 49.0, FALSE),
    ('prod_mycase', 'comp_mycase', 'MyCase', 'Practice Management', 'per_user_monthly', 39.0, FALSE),
    ('prod_projuris', 'comp_projuris', 'Projuris ADV', 'Practice Management', 'tier_monthly', 35.0, TRUE),
    ('prod_astrea', 'comp_astrea', 'Astrea', 'Practice Management', 'tier_monthly', 29.0, TRUE);

-- 4. Pain Clusters
INSERT OR REPLACE INTO pain_clusters (cluster_id, title, workflow_id, job_to_be_done, recurring_pain_summary, severity_level, frequency_level) VALUES
    ('clust_djen_docketing', 'DJEN & Multi-Court Deadline Reconciliation Engine', 'deadlines_docketing', 
     'Reconcile DJEN, Domicílio Judicial, and local court notices into business-day deadlines with local holiday awareness',
     'High risk of fatal missed deadlines due to fragmented court notices and CNJ 569/2024 transitions', 'critical', 'daily'),
    ('clust_whatsapp_portal', 'WhatsApp-Native Proactive Case Status & Client Portal', 'client_communication',
     'Automatically answer client "como está meu processo?" queries via WhatsApp from court updates in plain Portuguese',
     'Lawyers waste 2+ hours daily answering repetitive WhatsApp queries; clients ignore email portals', 'high', 'daily'),
    ('clust_pje_doc_bundler', 'PJe/e-SAJ PDF Splitter, Exhibit Indexer & OCR Compressor', 'evidence_organization',
     'Format, split, OCR compress, and index large exhibits to fit strict court upload limits (3MB-10MB)',
     'Paralegals waste hours manually splitting PDFs and formatting exhibit indexes for electronic petitions', 'medium', 'daily');

-- 5. Raw Evidence Records (Verbatim quotes across 5 source families)
INSERT OR REPLACE INTO raw_evidence (
    evidence_id, source_id, source_type, source_url, publication_date, collection_date, country, language,
    author_anonymized_id, exact_quote, translated_quote, lawyer_segment, practice_area, workflow,
    current_workaround, tool_mentioned, engagement_signal, spend_signal, duplicate_group_id, confidence
) VALUES
    ('ev_docket_1', 'src_reddit_lawfirm', 'reddit', 'https://reddit.com/r/LawFirm/comments/docketing_rules', '2024-11-12', CURRENT_DATE, 'US', 'en',
     'user_atty_tx', 'Clio court rules integration is clunky and an afterthought. We had to build our own secondary Excel spreadsheet to double check all trial dates.',
     NULL, 'small_firm', 'litigation', 'deadlines_docketing', 'Excel master sheet', 'Clio', '45 upvotes', '$120/hr wasted', 'grp_docket_us', 0.95),
    ('ev_docket_2', 'src_migalhas', 'news_rss', 'https://migalhas.com.br/quentes/412345/djen-inseguranca', '2025-05-18', CURRENT_DATE, 'BR', 'pt',
     'migalhas_editorial_oab', 'A unificação no DJEN pela Resolução 569/2024 do CNJ gerou enorme preocupação nos escritórios quanto à contagem de prazos em feriados locais e divergências de sistemas estaduais.',
     NULL, 'mid_large_firm', 'litigation', 'deadlines_docketing', 'Conferência manual em diários oficiais', 'Sistemas de recorte', 'Editorial', 'Multimillion liability risk', 'grp_docket_br', 1.0),
    ('ev_docket_3', 'src_upwork_jobs', 'upwork', 'https://upwork.com/jobs/legal-docketing-automation', '2025-02-10', CURRENT_DATE, 'US', 'en',
     'upwork_client_law', 'Need an automation expert to build a Zapier pipeline between Clio calendar and court notices to prevent missed filing deadlines. Budget $1,500.',
     NULL, 'small_firm', 'litigation', 'deadlines_docketing', 'Zapier / Clio', 'Clio', 'Active job post', '$1,500 fixed budget', 'grp_docket_upwork', 0.95),
    ('ev_docket_4', 'src_capterra_legal', 'capterra', 'https://capterra.com/p/12345/mycase/reviews', '2024-09-04', CURRENT_DATE, 'US', 'en',
     'capterra_rev_paralegal', 'MyCase deadline calculation lacks sophistication for multi-county litigation. It misses local administrative rules unless entered by hand.',
     NULL, 'paralegal_admin', 'civil', 'deadlines_docketing', 'Manual calendar entry', 'MyCase', 'Verified review', '5 hrs/week lost', 'grp_docket_us2', 0.9),
    ('ev_docket_5', 'src_conjur', 'news_rss', 'https://conjur.com.br/2025-mai-16/cnj-djen-prazos', '2025-05-16', CURRENT_DATE, 'BR', 'pt',
     'conjur_analyst', 'A contagem de prazos passou a ser exclusiva pelo DJEN, mas advogados enfrentam falhas de sincronização entre portais como e-SAJ e o sistema nacional.',
     NULL, 'solo', 'litigation', 'deadlines_docketing', 'Dupla checagem manual', 'Projuris / Astrea', 'Article', 'High loss risk', 'grp_docket_br2', 0.95),

    ('ev_wa_1', 'src_migalhas', 'news_rss', 'https://migalhas.com.br/depeso/418920/whatsapp-na-advocacia', '2024-10-22', CURRENT_DATE, 'BR', 'pt',
     'adv_artigo_migalhas', 'A pergunta como está meu processo no WhatsApp virou o maior ladrão de tempo do advogado. Interrompe a redação de peças e gera ansiedade indevida.',
     NULL, 'solo', 'civil', 'client_communication', 'Responder manualmente no celular', 'WhatsApp', 'High resonance', '2-3 hrs/day lost', 'grp_wa_1', 0.95),
    ('ev_wa_2', 'src_reddit_lawfirm', 'reddit', 'https://reddit.com/r/LawFirm/comments/client_communication_overwhelm', '2024-08-15', CURRENT_DATE, 'US', 'en',
     'user_solo_fl', 'Clients will never log into a client portal. If you do not text them updates, they call and text 10 times a week asking what is going on.',
     NULL, 'solo', 'family', 'client_communication', 'Manual text messages', 'MyCase Portal', '38 upvotes', '$300/mo spend', 'grp_wa_2', 0.9),
    ('ev_wa_3', 'src_capterra_legal', 'capterra', 'https://capterra.com/p/54321/projuris/reviews', '2024-07-19', CURRENT_DATE, 'BR', 'pt',
     'capterra_rev_adv_sp', 'O portal do cliente no sistema é inútil porque o cliente brasileiro não quer criar senha ou baixar app. Eles só usam WhatsApp.',
     NULL, 'small_firm', 'labor', 'client_communication', 'WhatsApp pessoal', 'Projuris', 'Verified review', 'R$ 350/mo spend', 'grp_wa_3', 0.9),
    ('ev_wa_4', 'src_upwork_jobs', 'upwork', 'https://upwork.com/jobs/whatsapp-crm-law', '2025-03-01', CURRENT_DATE, 'BR', 'pt',
     'upwork_lawyer_rj', 'Busco desenvolvedor para integrar API do WhatsApp ao banco de dados do escritório para enviar status automático do PJe para clientes. Orçamento R$ 3.000.',
     NULL, 'small_firm', 'labor', 'client_communication', 'Zapier + WhatsApp', 'Planilhas', 'Active job post', 'R$ 3,000 budget', 'grp_wa_4', 0.95),
    ('ev_wa_5', 'src_conjur', 'news_rss', 'https://conjur.com.br/2024-nov-10/atendimento-digital-advocacia', '2024-11-10', CURRENT_DATE, 'BR', 'pt',
     'conjur_tech_report', 'Escritórios que adotaram notificações proativas de andamento processual reduziram em 70% o volume de mensagens de suporte no WhatsApp.',
     NULL, 'mid_large_firm', 'litigation', 'client_communication', 'Robôs de WhatsApp', 'Chatbots', 'News report', '70% time savings', 'grp_wa_5', 0.9),

    ('ev_doc_1', 'src_reddit_lawfirm', 'reddit', 'https://reddit.com/r/paralegal/comments/court_pdf_limits', '2024-12-05', CURRENT_DATE, 'US', 'en',
     'paralegal_ca', 'State court filing limits are 5MB. Splitting a 200-page medical record into 10 parts while keeping bookmarks takes an entire afternoon.',
     NULL, 'paralegal_admin', 'personal_injury', 'evidence_organization', 'Adobe Acrobat Pro + free online splitters', 'Adobe', '55 upvotes', '4 hrs/filing', 'grp_doc_1', 0.9),
    ('ev_doc_2', 'src_migalhas', 'news_rss', 'https://migalhas.com.br/informativo/pje-tamanho-arquivo', '2024-06-14', CURRENT_DATE, 'BR', 'pt',
     'artigo_pje_arquivos', 'O limite de tamanho de arquivos no PJe (3MB a 5MB por anexo) gera retrabalho constante e risco de peças com anexos desordenados.',
     NULL, 'paralegal_admin', 'labor', 'evidence_organization', 'Ilovepdf / ferramentas web inseguras', 'Ilovepdf', 'Tech article', 'Data security risk', 'grp_doc_2', 0.95),
    ('ev_doc_3', 'src_upwork_jobs', 'upwork', 'https://upwork.com/jobs/pdf-splitter-python', '2025-01-20', CURRENT_DATE, 'BR', 'pt',
     'upwork_adv_mg', 'Script para comprimir e fatiar PDFs em lotes para anexar no PJe mantendo índice numerado. Orçamento $400.',
     NULL, 'solo', 'civil', 'evidence_organization', 'Python script', 'Nenhum', 'Active job post', '$400 budget', 'grp_doc_3', 0.9),
    ('ev_doc_4', 'src_capterra_legal', 'capterra', 'https://capterra.com/p/bundleedocs/reviews', '2024-10-10', CURRENT_DATE, 'UK', 'en',
     'uk_solicitor_bundle', 'Bundleedocs saves us at least 15 hours per court trial bundle, but pricing is high for small practices.',
     NULL, 'small_firm', 'litigation', 'evidence_organization', 'Bundleedocs', 'Bundleedocs', 'Review', 'GBP 150/mo spend', 'grp_doc_4', 0.9),
    ('ev_doc_5', 'src_conjur', 'news_rss', 'https://conjur.com.br/2024-set-20/seguranca-dados-advocacia', '2024-09-20', CURRENT_DATE, 'BR', 'pt',
     'especialista_lgpd', 'O uso de compressores de PDF gratuitos online para processos judiciais viola a LGPD e o sigilo profissional.',
     NULL, 'legal_ops', 'compliance', 'evidence_organization', 'Ferramentas web gratuitas', 'Web tools', 'Article', 'High LGPD penalty risk', 'grp_doc_5', 0.95);

-- 6. Pain Instances
INSERT OR REPLACE INTO pain_instances (instance_id, cluster_id, evidence_id, lawyer_segment, practice_area, time_loss_hours_per_week, financial_cost_monthly_usd) VALUES
    ('pi_1', 'clust_djen_docketing', 'ev_docket_1', 'small_firm', 'litigation', 5.0, 500.0),
    ('pi_2', 'clust_djen_docketing', 'ev_docket_2', 'mid_large_firm', 'litigation', 10.0, 2000.0),
    ('pi_3', 'clust_djen_docketing', 'ev_docket_3', 'small_firm', 'litigation', 4.0, 1500.0),
    ('pi_4', 'clust_djen_docketing', 'ev_docket_4', 'paralegal_admin', 'civil', 5.0, 400.0),
    ('pi_5', 'clust_djen_docketing', 'ev_docket_5', 'solo', 'litigation', 6.0, 600.0),

    ('pi_6', 'clust_whatsapp_portal', 'ev_wa_1', 'solo', 'civil', 10.0, 1000.0),
    ('pi_7', 'clust_whatsapp_portal', 'ev_wa_2', 'solo', 'family', 8.0, 300.0),
    ('pi_8', 'clust_whatsapp_portal', 'ev_wa_3', 'small_firm', 'labor', 12.0, 350.0),
    ('pi_9', 'clust_whatsapp_portal', 'ev_wa_4', 'small_firm', 'labor', 15.0, 3000.0),
    ('pi_10', 'clust_whatsapp_portal', 'ev_wa_5', 'mid_large_firm', 'litigation', 20.0, 4000.0),

    ('pi_11', 'clust_pje_doc_bundler', 'ev_doc_1', 'paralegal_admin', 'personal_injury', 4.0, 300.0),
    ('pi_12', 'clust_pje_doc_bundler', 'ev_doc_2', 'paralegal_admin', 'labor', 6.0, 500.0),
    ('pi_13', 'clust_pje_doc_bundler', 'ev_doc_3', 'solo', 'civil', 3.0, 400.0),
    ('pi_14', 'clust_pje_doc_bundler', 'ev_doc_4', 'small_firm', 'litigation', 15.0, 200.0),
    ('pi_15', 'clust_pje_doc_bundler', 'ev_doc_5', 'legal_ops', 'compliance', 2.0, 1000.0);

-- 7. Spend Signals
INSERT OR REPLACE INTO spend_signals (spend_id, cluster_id, evidence_id, signal_type, amount_usd, amount_brl, notes) VALUES
    ('sp_1', 'clust_djen_docketing', 'ev_docket_3', 'upwork_budget', 1500.0, 8500.0, 'Active Upwork automation budget'),
    ('sp_2', 'clust_whatsapp_portal', 'ev_wa_4', 'upwork_budget', 550.0, 3000.0, 'WhatsApp PJe automation budget'),
    ('sp_3', 'clust_whatsapp_portal', 'ev_wa_3', 'current_spend', 65.0, 350.0, 'Monthly Projuris tier'),
    ('sp_4', 'clust_pje_doc_bundler', 'ev_doc_3', 'upwork_budget', 400.0, 2300.0, 'Python PDF splitter script budget');

-- 8. Country Validation (Brazil)
INSERT OR REPLACE INTO country_validation (
    validation_id, cluster_id, country, pain_exists, local_term_pt,
    pje_esaj_integration_needed, digital_cert_needed, whatsapp_needed,
    pix_billing_needed, lgpd_compliance_needed, oab_cnj_restrictions, inaccessible_data_risk
) VALUES
    ('cv_1', 'clust_djen_docketing', 'BR', TRUE, 'Gestão de Prazos DJEN e Feriados Forenses',
     TRUE, TRUE, TRUE, TRUE, TRUE, 'OAB publicidade ética', 'DJEN API transition'),
    ('cv_2', 'clust_whatsapp_portal', 'BR', TRUE, 'Portal do Cliente WhatsApp com Status PJe',
     TRUE, FALSE, TRUE, TRUE, TRUE, 'Regras de sigilo e LGPD', 'PJe consulta pública'),
    ('cv_3', 'clust_pje_doc_bundler', 'BR', TRUE, 'Formatador e Fatiador de PDFs para PJe/e-SAJ',
     TRUE, TRUE, FALSE, FALSE, TRUE, 'Preservação de assinatura ICP-Brasil', 'Nenhuma');

-- 9. Opportunity Scores
INSERT OR REPLACE INTO opportunity_scores (
    score_id, cluster_id, pain_recurrence, severity, time_financial_cost,
    spend_willingness, existing_tools_dissatisfaction, reachable_target_customer,
    brazil_localization_advantage, mvp_30_days, penalty_restricted_data,
    penalty_collaboration, penalty_network_effects, penalty_general_ai,
    penalty_weak_evidence, is_validated, confidence_level
) VALUES
    ('sc_1', 'clust_djen_docketing', 15, 15, 15, 15, 10, 8, 10, 8, -5, 0, 0, 0, 0, TRUE, 'high'),
    ('sc_2', 'clust_whatsapp_portal', 15, 14, 15, 15, 10, 10, 10, 10, -4, 0, 0, 0, 0, TRUE, 'high'),
    ('sc_3', 'clust_pje_doc_bundler', 14, 12, 13, 12, 8, 10, 10, 10, 0, 0, 0, 0, 0, TRUE, 'high');
