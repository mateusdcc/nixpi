{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "brazil-localization-test";
  description = "Tests feasibility of localizing foreign legal concepts for the Brazilian legal market.";
  content = ''
    # Brazil Localization Feasibility Test

    ## Objective
    Evaluate whether a validated foreign legal tech software concept can be effectively transplanted and localized for the Brazilian legal system and market dynamics.

    ## Mandatory Localization Checklist

    ### 1. Pain Existence in Brazil
    - Does the underlying workflow exist in Brazilian law practice?
    - How do Brazilian lawyers describe the pain? (e.g. *recorte de publicações*, *intimações eletrônicas*, *contagem de prazos em dias úteis*, *cálculo trabalhista*, *honorários contratuais e sucumbenciais*).

    ### 2. Legal Terminology & Culture
    - Complete translation and alignment with Brazilian legal doctrine and Civil Procedure Code (CPC/2015), CLT, and CF/88.
    - Terminology: Petição Inicial, Contestação, Réplica, Agravo, Apelação, Embargos, Despacho, Sentença, Acórdão.

    ### 3. Court Platform Integrations
    - Electronic Court Systems: PJe (Federal, State, Labor), e-SAJ (TJSP, TJSC, etc.), Projudi (TJPR, etc.), Eproc (TRF4, TJRS, etc.).
    - Electronic Gazette (DJe / DJEN / Diário de Justiça Eletrônico Nacional).
    - PDPJ-Br (Plataforma Digital do Poder Judiciário).

    ### 4. Technical & Authentication Requirements
    - Digital Certificates: ICP-Brasil standard (Certificado Digital A1 file-based vs. A3 token/smartcard, BirdID, SafeID).
    - WhatsApp Integration: Standard medium for client updates, document collection, and fee reminders.
    - Billing & Payments: Pix native support, Boleto bancário generation, split payments (honorários).

    ### 5. Regulatory & Compliance Constraints
    - OAB Code of Ethics (Código de Ética e Disciplina da OAB): Rules on advertising, fee sharing, mercantilização da advocacia.
    - CNJ Directives: Resolution 332/2020 on AI in the Judiciary, Resolution 335/2020 on PDPJ.
    - LGPD Compliance: Sensitive legal data, court record privacy, consent requirements.
  '';
}
