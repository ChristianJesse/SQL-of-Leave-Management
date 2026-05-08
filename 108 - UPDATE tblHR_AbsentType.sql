UPDATE tblHR_AbsentType
SET ChargeToLeavedType = 
    CASE LEAVECODE
        WHEN 'BL' THEN 'BL'
        WHEN 'EL' THEN 'EL'
        WHEN 'ELBRVL' THEN 'EL'
        WHEN 'ELPL' THEN 'PL'
        WHEN 'LWP' THEN 'LWP'
        WHEN 'MAND' THEN 'VL'
        WHEN 'ML' THEN 'LWP'
        WHEN 'SSSPL' THEN 'PL'
        WHEN 'SL' THEN 'SL'
        WHEN 'SLWOP' THEN 'LWP'
        WHEN 'SPL' THEN 'SPL'
        WHEN 'SSSL' THEN 'LWP'
        WHEN 'UL' THEN 'UL'
        WHEN 'VL' THEN 'VL'
        WHEN 'VLWOP' THEN 'LWP'
        WHEN 'PL' THEN 'PL'
        WHEN 'SSL' THEN 'LWP'
    END
WHERE LEAVECODE IN (
    'BL','EL','ELBRVL','ELPL','LWP','MAND','ML',
    'SSSPL','SL','SLWOP','SPL','SSSL','UL','VL','VLWOP','PL','SSL'
);







