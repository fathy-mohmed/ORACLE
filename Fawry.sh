export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE=/u01/app/oracle
export ORACLE_SID=FWRYUATDB
export ORACLE_PDB_SID=FAWRYUAT

sqlplus -s / as sysdba << EOF
SET ECHO OFF        -- Prevents SQL queries from being shown
SET FEEDBACK OFF    -- Prevents row count (like "14 rows selected") from being shown
SET HEADING ON      -- Ensures column headers are displayed
SET TERMOUT OFF     -- Prevents output from being displayed to the screen

SET PAGESIZE 40000
SET NUM 24
spool /home/oracle/fawry/myxlsfile_$(date +%d_%m_%Y_%H_%M_%S).xls
SET MARKUP HTML ON ENTMAP ON PREFORMAT OFF

#OURPUT_DIR='/home/oracle/fawry/'

SELECT
    To_char(To_timestamp(TRANSACTIONS_DETAILS.GATEWAY_PMT_CREATION_time, 'dd/mm/YYYY HH:MI:SS AM'), 'MM/DD/YYYY HH:MI:SS AM' ) AS "B-Trans_date",
    TRANSACTIONS_DETAILS.bank_swift_code as "B-Bank_Code",
    TRANSACTIONS_DETAILS.bill_type_code as "B-Bill_type_Code",
    TRANSACTIONS_DETAILS.customer_ref_number as "B-Fawry_Trans_No",
To_char(To_timestamp(TRANSACTIONS_DETAILS.GATEWAY_PMT_CREATION_time, 'dd/mm/YYYY HH:MI:SS AM'), 'MM/DD/YYYY HH:MI:SS AM' )as "B-Trans_Time",
    TRANSACTIONS_DETAILS.billing_account_number as "B-Billing_AC_No",
    COALESCE(TRANSACTIONS_DETAILS.BILL_REFERENCE_NUMBER, '0') as "B-Bill_Ref_No",
    TRANSACTIONS_DETAILS.biller_pmt_transaction_id as "B-Biller_Trans_No",
    COALESCE(TRANSACTIONS_DETAILS.DEBIT_TRANSACTION_ID, '0') as "B-Trans_Debit_Ref_No",
    REPLACE(REPLACE(TRANSACTIONS_DETAILS.collection_account, CHR(13), ''), CHR(10), '') as "B-Collection_Account_No",
    CASE
        WHEN TRANSACTIONS_DETAILS.PNTURE = 'REV'
        THEN TRANSACTIONS_DETAILS.BILL_AMOUNT + TRANSACTIONS_DETAILS.BILLER_CHARGES_AMOUNT * -7
        ELSE TRANSACTIONS_DETAILS.BILL_AMOUNT + TRANSACTIONS_DETAILS.BILLER_CHARGES_AMOUNT
    END as "B-Trans_Amount",
    CASE
        WHEN TRANSACTIONS_DETAILS.PNTURE = 'REV'
        THEN TRANSACTIONS_DETAILS.FEES_AMOUNT * -1
        ELSE TRANSACTIONS_DETAILS.FEES_AMOUNT
     END as "B-Customer_Fee",
    TRANSACTIONS_DETAILS.channel_type_name as "B-Channel_Type",
    COALESCE(TRANSACTIONS_DETAILS.TERMINAL_ID, '0') as "B-TERMINAL_ID",
    TRANSACTIONS_DETAILS.CLIENT_TERMINAL_SEQUENCE_ID as "B-Channel_Receipt_No",
    TRANSACTIONS_DETAILS.PAYMENT_STATUS_CODE as "B-Trans_Status",
    COALESCE(TRANSACTIONS_DETAILS.TOTAL_AMOUNT_DUE, 0) as "B-Bill_Amount",
    CASE
        WHEN TRANSACTIONS_DETAILS.BANK_ACCOUNT_TYPE = 'CCA' THEN 'Credit Account'
        WHEN TRANSACTIONS_DETAILS.BANK_ACCOUNT_TYPE = 'CSH' THEN 'Cash'
        ELSE 'Debit Account'
    END as "B-Customer_account_type",
    TRANSACTIONS_DETAILS.GATEWAY_PMT_TRANSACTION_ID as BNKPTN,
    TRANSACTIONS_DETAILS.ORIGINAL_TRX_ID as OBNKPTN,
    TRANSACTIONS_DETAILS.GATEWAY_PMT_TRANSACTION_ID as FPTN,
    TRANSACTIONS_DETAILS.PAYMENT_TYPE_CODE as PTYPE,
    TRANSACTIONS_DETAILS.PNTURE as PNTURE 
FROM
    ebpp_core.transactions_details 
WHERE
    ebpp_core.transactions_details.GATEWAY_PMT_CREATION_DATE =to_char(sysdate -1 , 'dd-mon-yy');

spool off


EOF
