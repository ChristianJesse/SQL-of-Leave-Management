SELECT
    A.ID,
    A.LeaveCode,
    B.LeaveDesc,
    A.DTFrom,
    A.DTTo,

    CASE
        WHEN A.PeriodSpecific = 0 THEN A.Quota
        ELSE X.TotalQuota
    END AS Quota,

    A.CreatedBy,
    A.DTCreated,
    A.DTModified,
    A.LastUpdateBy,
    A.PeriodSpecific

FROM tblLEAPLeaveTypeQuota A
JOIN tblHR_AbsentType B
    ON A.LeaveCode = B.LeaveCode

OUTER APPLY
(
    SELECT TOP 1 *
    FROM tblHR_MonthlyEntPerGroup C
    WHERE C.LeaveCode = A.LeaveCode
) C

OUTER APPLY
(
    SELECT
        (
            CASE WHEN MONTH(A.DTFrom) <= 1  AND MONTH(A.DTTo) >= 1  THEN ISNULL(C.LeaveHours01,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 2  AND MONTH(A.DTTo) >= 2  THEN ISNULL(C.LeaveHours02,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 3  AND MONTH(A.DTTo) >= 3  THEN ISNULL(C.LeaveHours03,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 4  AND MONTH(A.DTTo) >= 4  THEN ISNULL(C.LeaveHours04,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 5  AND MONTH(A.DTTo) >= 5  THEN ISNULL(C.LeaveHours05,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 6  AND MONTH(A.DTTo) >= 6  THEN ISNULL(C.LeaveHours06,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 7  AND MONTH(A.DTTo) >= 7  THEN ISNULL(C.LeaveHours07,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 8  AND MONTH(A.DTTo) >= 8  THEN ISNULL(C.LeaveHours08,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 9  AND MONTH(A.DTTo) >= 9  THEN ISNULL(C.LeaveHours09,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 10 AND MONTH(A.DTTo) >= 10 THEN ISNULL(C.LeaveHours10,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 11 AND MONTH(A.DTTo) >= 11 THEN ISNULL(C.LeaveHours11,0) ELSE 0 END +
            CASE WHEN MONTH(A.DTFrom) <= 12 AND MONTH(A.DTTo) >= 12 THEN ISNULL(C.LeaveHours12,0) ELSE 0 END
        ) AS TotalQuota
) X