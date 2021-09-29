CREATE TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] (
    [periodo_val] varchar(50),
    [cod_sbs_val] varchar(50),
    [score_desembolso] varchar(50),
    [GRUPO_PROPENSION] varchar(50),
    [GRUPO_PROPENSION_FINO] varchar(50),
    [target_desembolso_f2m_mayor_30_menor_180] varchar(50),
    [_categoryc_nroregs_reactiva_bcos] varchar(50),
    [_categoryc_sow_ibk] varchar(50),
    [_categoryc_porc_coloc_direct_vig_no_ibk] varchar(50),
    [_categoryc_sow_cajas] varchar(50),
    [_categoryc_coloc_direct_vig_bcos] varchar(50),
    [_categoryc_nroregs_fae_bcos] varchar(50),
    [_categoryc_coloc_direct_vig_no_ibk] varchar(50),
    [_categoryc_coloc_direct_vig_competencia] varchar(50),
    [_categoryc_coloc_direct_vig_cajas] varchar(50),
    [_categoryc_coloc_direct_vig_ibk] varchar(50),
    [_categoryc_porc_coloc_direct_vig_cmpt] varchar(50),
    [_categoryc_porc_coloc_direct_vig_cajas] varchar(50),
    [_categoryc_porc_coloc_direct_vig_ibk] varchar(50),
    [_categoryc_sow_otros_bancos] varchar(50),
    [_categoryc_porc_coloc_direct_vig_bcos] varchar(50),
    [_range_coloc_indirectas] varchar(50),
    [_range_reactiva] varchar(50),
    [_range_coloc_direct_vig_cmpt] varchar(50),
    [_range_coloc_direct_vig_cajas] varchar(50),
    [_range_coloc_direct_vig_bcos] varchar(50),
    [_range_coloc_direct_vig_ibk] varchar(50),
    [_range_fae] varchar(50),
    [_range_coloc_directas] varchar(50),
    [_range_coloc_direct_vig_no_ibk] varchar(50),
    [sow_ibk] varchar(50),
    [porc_coloc_direct_vig_cmpt] varchar(50),
    [porc_coloc_direct_vig_cajas] varchar(50),
    [porc_coloc_direct_vig_no_ibk] varchar(50),
    [porc_coloc_direct_vig_bcos] varchar(50),
    [sow_otros_bancos] varchar(50),
    [porc_coloc_direct_vig_ibk] varchar(50),
    [sow_cajas] varchar(50),
    [saldo_coloc_direct_vig_cmpt] varchar(50),
    [ult_var_saldo_ajustado_amt] varchar(50),
    [saldo_coloc_direct_vig_no_ibk] varchar(50),
    [saldo_coloc_direct_vig_cajas] varchar(50),
    [saldo_reactiva] varchar(50),
    [saldo_coloc_indirectas] varchar(50),
    [var_neta_saldo_ajustado_u3_amt] varchar(50),
    [saldo_fae] varchar(50),
    [saldo_coloc_directas] varchar(50),
    [saldo_coloc_direct_vig_bcos] varchar(50),
    [saldo_coloc_direct_vig_ibk] varchar(50),
    [saldo_coloc_direct_tc] varchar(50),
    [_cuartil_saldo_coloc_directas] varchar(50),
    [deuda_sf_prom_ult9m] varchar(50),
    [prom_reprog_u12m] varchar(50),
    [nro_entid_financ_prom_ult9m_cnt] varchar(50),
    [monto_adquirido_u6_amt] varchar(50),
    [nro_var_10k_30k_negativa_u6] varchar(50),
    [prom_gar_u12m] varchar(50),
    [nroregs_reactiva_bcos] varchar(50),
    [monto_pagado_u3_amt] varchar(50),
    [nro_entidades] varchar(50),
    [monto_pagado_ult_rcc_amt] varchar(50),
    [tendencia_nro_coloc_direct_bancos_v2] varchar(50),
    [prom_fae_u12m] varchar(50),
    [nro_var_10k_30k_negativa_u3] varchar(50)
)

ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [score_desembolso] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [target_desembolso_f2m_mayor_30_menor_180] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [score_desembolso] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [sow_ibk] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [porc_coloc_direct_vig_cmpt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [porc_coloc_direct_vig_cajas] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [porc_coloc_direct_vig_no_ibk] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [porc_coloc_direct_vig_bcos] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [porc_coloc_direct_vig_ibk] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [sow_cajas] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_vig_cmpt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [ult_var_saldo_ajustado_amt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_vig_no_ibk] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_vig_cajas] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_reactiva] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_indirectas] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [var_neta_saldo_ajustado_u3_amt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_fae] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_directas] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_vig_bcos] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_vig_ibk] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [saldo_coloc_direct_tc] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [deuda_sf_prom_ult9m] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [prom_reprog_u12m] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [nro_entid_financ_prom_ult9m_cnt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [monto_adquirido_u6_amt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [nro_var_10k_30k_negativa_u6] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [prom_gar_u12m] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [nroregs_reactiva_bcos] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [monto_pagado_u3_amt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [nro_entidades] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [monto_pagado_ult_rcc_amt] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [tendencia_nro_coloc_direct_bancos_v2] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [prom_fae_u12m] FLOAT
ALTER TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE] ALTER COLUMN [nro_var_10k_30k_negativa_u3] FLOAT





SELECT * 
INTO ODS.HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE
FROM seguimiento_aws_to_campania
--[ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE]



DROP TABLE [ODS].[HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE]