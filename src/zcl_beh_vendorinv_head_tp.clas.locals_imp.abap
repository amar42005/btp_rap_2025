CLASS lhc_VendorInvoiceHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    CONSTANTS:
      BEGIN OF cs_proc_status,
        new               TYPE string VALUE 'NEW',
        validated         TYPE string VALUE 'VALIDATED',
        error_validation  TYPE string VALUE 'ERROR_VALIDATION',
        posting_attempt   TYPE string VALUE 'POSTING_ATTEMPT',
        posted            TYPE string VALUE 'POSTED',
        error_posting     TYPE string VALUE 'ERROR_POSTING',
        error_bapi_commit TYPE string VALUE 'ERROR_BAPI_COMMIT',
      END OF cs_proc_status.


    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR VendorInvoiceHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR VendorInvoiceHeader RESULT result.

    METHODS PostVendorInvoice FOR MODIFY
      IMPORTING keys FOR ACTION VendorInvoiceHeader~PostVendorInvoice RESULT result.

    METHODS SetInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR VendorInvoiceHeader~SetInitialStatus.

    METHODS SetAuditFields FOR DETERMINE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~SetAuditFields.

    METHODS ValidateCompanyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~ValidateCompanyCode.

    METHODS ValidateCurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~ValidateCurrency.

    METHODS ValidateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~ValidateDates.

    METHODS ValidateReferenceDoc FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~ValidateReferenceDoc.

    METHODS ValidateVendor FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceHeader~ValidateVendor.

    METHODS get_localized_message
      IMPORTING
        iv_msgid          TYPE symsgid
        iv_msgno          TYPE symsgno
        iv_attr1          TYPE any OPTIONAL
        iv_attr2          TYPE any OPTIONAL
        iv_attr3          TYPE any OPTIONAL
        iv_attr4          TYPE any OPTIONAL
      RETURNING
        VALUE(rv_message) TYPE string.


ENDCLASS.

CLASS lhc_VendorInvoiceHeader IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SetInitialStatus.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
    ENTITY VendorInvoiceHeader
      FIELDS ( ProcessingStatus )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header) WHERE ProcessingStatus IS INITIAL.
      MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
          UPDATE FIELDS ( ProcessingStatus )
          WITH VALUE #( ( %tky = ls_header-%tky ProcessingStatus = cs_proc_status-new ) ).
    ENDLOOP.


  ENDMETHOD.

  METHOD SetAuditFields.

    DATA: lv_current_timestamp TYPE timestampl.
    GET TIME STAMP FIELD lv_current_timestamp.

    " For Create
    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers_create)
        FAILED DATA(lt_headers_failed).

    LOOP AT lt_headers_create INTO DATA(ls_header_create) WHERE %data-createdby IS INITIAL.
      MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
      ENTITY VendorInvoiceHeader
          UPDATE FIELDS ( CreatedBy CreatedAt LastChangedBy LastChangedAt )
          WITH VALUE #( ( %tky          = ls_header_create-%tky
                           CreatedBy     = sy-uname
                           CreatedAt     = lv_current_timestamp
                           LastChangedBy = sy-uname
                           LastChangedAt = lv_current_timestamp ) ).
    ENDLOOP.

    " For Update (excluding create, which is handled above)
    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers_update)
        FAILED DATA(lt_headers_failed_u). " Re-read or filter to ensure we only get updates

    LOOP AT lt_headers_update INTO DATA(ls_header_update).
      IF ls_header_update-%data-createdby IS NOT INITIAL AND ls_header_update-%data-lastchangedby IS INITIAL. " Check if it's an update
        MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
            UPDATE FIELDS ( LastChangedBy LastChangedAt )
            WITH VALUE #( ( %tky          = ls_header_update-%tky
                             LastChangedBy = sy-uname
                             LastChangedAt = lv_current_timestamp ) ).
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateCompanyCode.


    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
       ENTITY VendorInvoiceHeader
         FIELDS ( CompanyCode )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-CompanyCode IS INITIAL.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Company Code is mandatory.' )
                        %element-CompanyCode = if_abap_behv=>mk-on )
          TO reported-vendorinvoiceheader.
        CONTINUE.
      ENDIF.

*      SELECT SINGLE @abap_true FROM t001 WHERE bukrs = @ls_header-CompanyCode INTO @DATA(lv_exists).
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
*        APPEND VALUE #( %tky = ls_header-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Company Code '{ ls_header-CompanyCode }' is invalid.| )
*                        %element-CompanyCode = if_abap_behv=>mk-on )
*          TO reported-vendorinvoiceheader.
*      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateCurrency.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
          FIELDS ( DocumentCurrency )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-DocumentCurrency IS INITIAL.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Document Currency is mandatory.' )
                        %element-DocumentCurrency = if_abap_behv=>mk-on )
          TO reported-vendorinvoiceheader.
        CONTINUE.
      ENDIF.
*      SELECT SINGLE @abap_true FROM tcurc WHERE waers = @ls_header-DocumentCurrency INTO @DATA(lv_exists).
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
*        APPEND VALUE #( %tky = ls_header-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Currency '{ ls_header-DocumentCurrency }' is invalid.| )
*                        %element-DocumentCurrency = if_abap_behv=>mk-on )
*          TO reported-vendorinvoiceheader.
*      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateDates.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
       ENTITY VendorInvoiceHeader
         FIELDS ( InvoiceDate PostingDate )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-InvoiceDate IS INITIAL OR ls_header-PostingDate IS INITIAL.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Invoice Date and Posting Date are mandatory.' )
                        %element-InvoiceDate = COND #( WHEN ls_header-InvoiceDate IS INITIAL THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off )
                        %element-PostingDate = COND #( WHEN ls_header-PostingDate IS INITIAL THEN if_abap_behv=>mk-on ELSE if_abap_behv=>mk-off ) )
          TO reported-vendorinvoiceheader.
        CONTINUE.
      ENDIF.
      " Add more date logic if needed, e.g., posting date not too far from invoice date
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateReferenceDoc.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
      ENTITY VendorInvoiceHeader
        FIELDS ( ReferenceDocumentNumber )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-ReferenceDocumentNumber IS INITIAL.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Reference Document Number is mandatory.' )
                        %element-ReferenceDocumentNumber = if_abap_behv=>mk-on )
          TO reported-vendorinvoiceheader.
      ENDIF.
      " Potentially check for duplicate reference for the same vendor if business rule requires
    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateVendor.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceHeader
          FIELDS ( VendorNumber CompanyCode )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-VendorNumber IS INITIAL.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Vendor Number is mandatory.' )
                        %element-VendorNumber = if_abap_behv=>mk-on )
          TO reported-vendorinvoiceheader.
        CONTINUE.
      ENDIF.

      " Check vendor existence in company code
*      SELECT SINGLE @abap_true FROM lfb1 WHERE lifnr = @ls_header-VendorNumber AND bukrs = @ls_header-CompanyCode INTO @DATA(lv_exists).
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-vendorinvoiceheader.
*        APPEND VALUE #( %tky = ls_header-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Vendor '{ ls_header-VendorNumber }' not found in Company Code '{ ls_header-CompanyCode }' or is blocked.| )
*                        %element-VendorNumber = if_abap_behv=>mk-on
*                        %element-CompanyCode = if_abap_behv=>mk-on )
*          TO reported-vendorinvoiceheader.
*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD PostVendorInvoice.

*    DATA: ls_header_data      TYPE zstg_vend_inv_h,
*          lt_item_data        TYPE STANDARD TABLE OF zstg_vend_inv_i,
*          ls_bapi_doc_header  TYPE bapiache09,
*          lt_bapi_accountgl   TYPE STANDARD TABLE OF bapiacgl09,
*          lt_bapi_accountpay  TYPE STANDARD TABLE OF bapiacap09,
*          lt_bapi_currencyamt TYPE STANDARD TABLE OF bapiaccr09,
*          lt_bapi_return      TYPE STANDARD TABLE OF bapiret2,
*          ls_bapi_return      TYPE bapiret2,
*          lv_bapi_obj_key     TYPE bapiache09-obj_key,
*          lv_posted_doc_no    TYPE belnr_d,
*          lv_posted_fis_yr    TYPE gjahr,
*          lv_error_message    TYPE string,
*          lv_item_num_gl      TYPE i,
*          lv_current_status   TYPE string.
*
*
*    LOOP AT keys INTO DATA(ls_key).
*      CLEAR: lv_error_message, lv_posted_doc_no, lv_posted_fis_yr.
*      DATA(lv_action_failed) = abap_false.
*
*      " 1. Read current data of the instance including items
*      READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*        ENTITY VendorInvoiceHeader
*          ALL FIELDS WITH CORRESPONDING #( VALUE #( ( %tky = ls_key-%tky ) ) )
*        RESULT DATA(lt_header_read).
*      IF lt_header_read IS INITIAL.
*        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-vendorinvoiceheader.
*        APPEND VALUE #( %tky = ls_key-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Failed to read header data for posting.' ) ) TO reported-vendorinvoiceheader.
*        CONTINUE.
*      ENDIF.
*      ASSIGN lt_header_read[ 1 ] TO FIELD-SYMBOL(<fs_header_read>).
*      MOVE-CORRESPONDING <fs_header_read> TO ls_header_data.
*      lv_current_status = <fs_header_read>-ProcessingStatus.
*
*      " Check if invoice is already posted or in a non-reprocessable error state
*      IF lv_current_status = cs_proc_status-posted.
*        APPEND VALUE #( %tky        = ls_key-%tky
*                        Success     = abap_true  " Or false if re-posting is an error
*                        SapDocumentNumber = <fs_header_read>-SapDocumentNumber
*                        SapFiscalYear = <fs_header_read>-SapFiscalYear
*                        Message     = |Invoice already posted: { <fs_header_read>-SapDocumentNumber }/{ <fs_header_read>-SapFiscalYear }| )
*        TO result.
*        CONTINUE. " Skip to next invoice if already posted
*      ENDIF.
*      IF lv_current_status = cs_proc_status-error_bapi_commit. " Example of non-reprocessable without intervention
*        APPEND VALUE #( %tky        = ls_key-%tky
*                        Success     = abap_false
*                        Message     = |Invoice in error state '{ lv_current_status }'. Cannot reprocess automatically.| )
*        TO result.
*        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-vendorinvoiceheader. " Report action failure
*        APPEND VALUE #( %tky = ls_key-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Invoice in error state '{ lv_current_status }'. Cannot reprocess automatically.| ) ) TO reported-vendorinvoiceheader.
*        CONTINUE.
*      ENDIF.
*
*
*      READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*        ENTITY VendorInvoiceHeader BY \_Items
*          ALL FIELDS WITH CORRESPONDING #( VALUE #( ( %tky = ls_key-%tky ) ) )
*        RESULT DATA(lt_items_read).
*      MOVE-CORRESPONDING lt_items_read TO lt_item_data.
*
*      IF lt_item_data IS INITIAL.
*        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-vendorinvoiceheader.
*        APPEND VALUE #( %tky = ls_key-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'No G/L items found for the invoice.' ) ) TO reported-vendorinvoiceheader.
*        lv_action_failed = abap_true.
*      ENDIF.
*
*      " Perform pre-BAPI validations again if necessary, or rely on save validations
*      " For simplicity, assuming validations on save have passed or user corrected them.
*
*      IF lv_action_failed = abap_true.
*        MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*          ENTITY VendorInvoiceHeader
*            UPDATE FIELDS ( ProcessingStatus ErrorMessage )
*            WITH VALUE #( ( %tky             = ls_key-%tky
*                             ProcessingStatus = cs_proc_status-error_validation " Or a specific pre-posting error status
*                             ErrorMessage     = 'Pre-posting validation failed. Check messages.' ) ).
*        APPEND VALUE #( %tky = ls_key-%tky Success = abap_false Message = 'Pre-posting validation failed.' ) TO result.
*        CONTINUE.
*      ENDIF.
*
*      " Update status to 'Posting Attempt'
*      MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*        ENTITY VendorInvoiceHeader
*          UPDATE FIELDS ( ProcessingStatus ErrorMessage )
*          WITH VALUE #( ( %tky             = ls_key-%tky
*                           ProcessingStatus = cs_proc_status-posting_attempt
*                           ErrorMessage     = '' ) ). " Clear previous error messages for this attempt
*
*      " 2. Map to BAPI Structures
*      CLEAR: ls_bapi_doc_header, lt_bapi_accountgl, lt_bapi_accountpay, lt_bapi_currencyamt, lt_bapi_return.
*
*      ls_bapi_doc_header-comp_code = ls_header_data-company_code.
*      ls_bapi_doc_header-doc_date  = ls_header_data-invoice_date.
*      ls_bapi_doc_header-pstng_date = ls_header_data-posting_date.
*      ls_bapi_doc_header-doc_type  = 'KR'. " Typically KR for Vendor Invoice. Make this configurable if needed.
*      ls_bapi_doc_header-currency  = ls_header_data-document_currency.
*      ls_bapi_doc_header-ref_doc_no = ls_header_data-reference_document_number.
*      ls_bapi_doc_header-header_txt = ls_header_data-document_header_text.
*      ls_bapi_doc_header-username  = sy-uname. " Or a dedicated API user
*      IF ls_header_data-exchange_rate IS NOT INITIAL AND ls_header_data-exchange_rate <> 0.
*        ls_bapi_doc_header-exch_rate = ls_header_data-exchange_rate.
*      ENDIF.
*
*      " Vendor Line Item (Payable)
*      APPEND INITIAL LINE TO lt_bapi_accountpay ASSIGNING FIELD-SYMBOL(<fs_bapi_pay>).
*      <fs_bapi_pay>-itemno_acc = '001'. " First item for vendor
*      <fs_bapi_pay>-vendor_no  = ls_header_data-vendor_number.
*      <fs_bapi_pay>-pmnttrms   = ls_header_data-payment_terms.
*      <fs_bapi_pay>-blinedate  = ls_header_data-baseline_date.
*      " Add other relevant fields for vendor line: e.g. payment block, etc.
*
*      APPEND INITIAL LINE TO lt_bapi_currencyamt ASSIGNING FIELD-SYMBOL(<fs_bapi_curr_v>).
*      <fs_bapi_curr_v>-itemno_acc = <fs_bapi_pay>-itemno_acc.
*      <fs_bapi_curr_v>-currency   = ls_header_data-document_currency.
*      <fs_bapi_curr_v>-amt_doccur = ls_header_data-gross_invoice_amount * -1. " Vendor is credit
*
*      " G/L Account Line Items
*      lv_item_num_gl = 1.
*      LOOP AT lt_item_data INTO DATA(ls_item).
*        lv_item_num_gl += 1.
*        APPEND INITIAL LINE TO lt_bapi_accountgl ASSIGNING FIELD-SYMBOL(<fs_bapi_gl>).
*        <fs_bapi_gl>-itemno_acc = |{ lv_item_num_gl ALPHA = OUT }|.
*        <fs_bapi_gl>-gl_account = ls_item-gl_account_number.
*        <fs_bapi_gl>-comp_code  = ls_header_data-company_code. " Can be derived if G/L is cross-company
*        <fs_bapi_gl>-pstng_date = ls_header_data-posting_date.
*        <fs_bapi_gl>-tax_code   = ls_item-tax_code.
*        <fs_bapi_gl>-costcenter = ls_item-cost_center.
*        <fs_bapi_gl>-profit_ctr = ls_item-profit_center.
*        <fs_bapi_gl>-orderid    = ls_item-order_number.
*        <fs_bapi_gl>-wbs_elem   = ls_item-wbs_element.
*        <fs_bapi_gl>-alloc_nmbr = ls_item-assignment_number.
*        <fs_bapi_gl>-item_text  = ls_item-item_text.
*
*        APPEND INITIAL LINE TO lt_bapi_currencyamt ASSIGNING FIELD-SYMBOL(<fs_bapi_curr_gl>).
*        <fs_bapi_curr_gl>-itemno_acc = <fs_bapi_gl>-itemno_acc.
*        <fs_bapi_curr_gl>-currency   = ls_header_data-document_currency.
*        <fs_bapi_curr_gl>-amt_doccur = ls_item-amount_in_doc_curr.
*        IF ls_item-tax_code IS NOT INITIAL.
*          <fs_bapi_curr_gl>-amt_base = ls_item-amount_in_doc_curr. " Base for tax calculation on this item
*        ENDIF.
*      ENDLOOP.
*
*      " 3. Call BAPI
*      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*        EXPORTING
*          documentheader = ls_bapi_doc_header
*        IMPORTING
*          obj_key        = lv_bapi_obj_key
*        TABLES
*          accountgl      = lt_bapi_accountgl
*          accountpayable = lt_bapi_accountpay
*          currencyamount = lt_bapi_currencyamt
*          return         = lt_bapi_return.
*      " Note: For taxes, BAPI_ACC_DOCUMENT_POST can calculate them automatically based on tax codes on G/L lines.
*      " If explicit tax lines are needed, populate ACCOUNTAX table.
*
*      " 4. Process BAPI Return
*      DATA(lv_bapi_has_error) = abap_false.
*      CLEAR lv_error_message.
*
*      LOOP AT lt_bapi_return INTO ls_bapi_return.
*        IF ls_bapi_return-type = 'E' OR ls_bapi_return-type = 'A'.
*          lv_bapi_has_error = abap_true.
*        ENDIF.
*        CONCATENATE lv_error_message
*                    |{ ls_bapi_return-type }: { ls_bapi_return-message } (ID: { ls_bapi_return-id }, No: { ls_bapi_return-number })|
*                    cl_abap_char_utilities=>cr_lf INTO lv_error_message.
*        " Report detailed BAPI messages back to the RAP framework (optional, can be verbose)
*        APPEND VALUE #( %tky = ls_key-%tky
*                        %msg = new_message( id = ls_bapi_return-id
*                                            number = ls_bapi_return-number
*                                            severity = COND #( WHEN ls_bapi_return-type = 'E' THEN if_abap_behv_message=>severity-error
*                                                               WHEN ls_bapi_return-type = 'A' THEN if_abap_behv_message=>severity-error " Abort is also error
*                                                               WHEN ls_bapi_return-type = 'W' THEN if_abap_behv_message=>severity-warning
*                                                               ELSE if_abap_behv_message=>severity-information )
*                                            v1 = ls_bapi_return-message_v1
*                                            v2 = ls_bapi_return-message_v2
*                                            v3 = ls_bapi_return-message_v3
*                                            v4 = ls_bapi_return-message_v4 ) )
*          TO reported-vendorinvoiceheader.
*      ENDLOOP.
*
*      IF lv_bapi_has_error = abap_true.
*        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*          ENTITY VendorInvoiceHeader
*            UPDATE FIELDS ( ProcessingStatus ErrorMessage )
*            WITH VALUE #( ( %tky             = ls_key-%tky
*                             ProcessingStatus = cs_proc_status-error_posting
*                             ErrorMessage     = lv_error_message ) ).
*        APPEND VALUE #( %tky = ls_key-%tky Success = abap_false Message = |BAPI posting failed. Details: { lv_error_message }| ) TO result.
*        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-vendorinvoiceheader. " Report action failure
*      ELSE.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = abap_true.
*        IF sy-subrc = 0.
*          lv_posted_doc_no = lv_bapi_obj_key(10).
*          lv_posted_fis_yr = lv_bapi_obj_key+14(4). " BKPF-BELNR (10), BKPF-BUKRS (4), BKPF-GJAHR (4)
*
*          MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*            ENTITY VendorInvoiceHeader
*              UPDATE FIELDS ( ProcessingStatus ErrorMessage SapDocumentNumber SapFiscalYear )
*              WITH VALUE #( ( %tky                = ls_key-%tky
*                               ProcessingStatus    = cs_proc_status-posted
*                               ErrorMessage        = 'Successfully posted.'
*                               SapDocumentNumber   = lv_posted_doc_no
*                               SapFiscalYear       = lv_posted_fis_yr ) ).
*          APPEND VALUE #( %tky              = ls_key-%tky
*                           Success           = abap_true
*                           SapDocumentNumber = lv_posted_doc_no
*                           SapFiscalYear     = lv_posted_fis_yr
*                           Message           = |Invoice posted successfully: { lv_posted_doc_no }/{ lv_posted_fis_yr }| )
*            TO result.
*        ELSE.
*          " Commit failed - this is a critical error
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'. " Attempt rollback, though state might be inconsistent
*          lv_error_message = |Critical error: BAPI_TRANSACTION_COMMIT failed with SY-SUBRC { sy-subrc } after BAPI_ACC_DOCUMENT_POST was successful.|.
*          MODIFY ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
*            ENTITY VendorInvoiceHeader
*              UPDATE FIELDS ( ProcessingStatus ErrorMessage )
*              WITH VALUE #( ( %tky             = ls_key-%tky
*                               ProcessingStatus = cs_proc_status-error_bapi_commit
*                               ErrorMessage     = lv_error_message ) ).
*          APPEND VALUE #( %tky = ls_key-%tky Success = abap_false Message = lv_error_message ) TO result.
*          APPEND VALUE #( %tky = ls_key-%tky ) TO failed-vendorinvoiceheader.
*          APPEND VALUE #( %tky = ls_key-%tky %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = lv_error_message ) ) TO reported-vendorinvoiceheader.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.


  ENDMETHOD.

  METHOD get_localized_message.

    MESSAGE ID iv_msgid TYPE 'S' NUMBER iv_msgno
            WITH iv_attr1 iv_attr2 iv_attr3 iv_attr4
            INTO rv_message.
    IF sy-subrc <> 0.
      rv_message = |Message { iv_msgid }-{ iv_msgno } not found.|.
    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_VendorInvoiceItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS ValidateGlAccount FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceItem~ValidateGlAccount.

    METHODS ValidateTaxCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR VendorInvoiceItem~ValidateTaxCode.

ENDCLASS.

CLASS lhc_VendorInvoiceItem IMPLEMENTATION.

  METHOD ValidateGlAccount.

    " Read the item's GlAccountNumber and also populate the _Header association
    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE " Root BO name
      ENTITY VendorInvoiceItem                             " Alias of the child entity (item)
        FIELDS ( GlAccountNumber )                 " Request GlAccountNumber and fill the _Header association
        WITH CORRESPONDING #( keys )                       " 'keys' must contain %tky for VendorInvoiceItem instances
      RESULT DATA(lt_items)
      FAILED DATA(ls_read_failed)       " It's good practice to handle failed reads
      REPORTED DATA(ls_read_reported).   " And reported messages from the read

    " Handle potential read failures before proceeding
    IF ls_read_failed-vendorinvoiceitem IS NOT INITIAL.
      LOOP AT ls_read_failed-vendorinvoiceitem INTO DATA(ls_failed_item_read).
        APPEND VALUE #( %tky = ls_failed_item_read-%tky ) TO failed-vendorinvoiceitem.
        APPEND VALUE #( %tky = ls_failed_item_read-%tky
                        " Corrected: Access the specific key field (e.g., ItemUuid) from %tky structure
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Failed to read item data for key (ItemUuid: { ls_failed_item_read-%tky-ItemUuid }) for validation.| ) )
          TO reported-vendorinvoiceitem.
      ENDLOOP.
      " Depending on logic, you might want to return or skip further processing for these failed reads.
    ENDIF.

    LOOP AT lt_items INTO DATA(ls_item).
*      DATA lv_company_code TYPE bukrs.
*      DATA ls_associated_header LIKE LINE OF ls_item-_Header. " Work area for the associated header

      IF ls_item-GlAccountNumber IS INITIAL.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-vendorinvoiceitem.
        APPEND VALUE #( %tky = ls_item-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'G/L Account is mandatory for item.' )
                        %element-GlAccountNumber = if_abap_behv=>mk-on )
          TO reported-vendorinvoiceitem.
        CONTINUE.
      ENDIF.

*      " Check G/L account existence in company code
*      SELECT SINGLE @abap_true FROM skb1 WHERE saknr = @ls_item-GlAccountNumber AND bukrs = @lv_company_code INTO @DATA(lv_exists_skb1).
*      IF sy-subrc <> 0.
*        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-vendorinvoiceitem.
*        APPEND VALUE #( %tky = ls_item-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |G/L Account '{ ls_item-GlAccountNumber }' not found or not valid for company code '{ lv_company_code }'.| )
*                        %element-GlAccountNumber = if_abap_behv=>mk-on )
*          TO reported-vendorinvoiceitem.
*      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateTaxCode.

    READ ENTITIES OF zi_vendorinvoicehead_tp IN LOCAL MODE
        ENTITY VendorInvoiceItem
        FIELDS ( TaxCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items)
        FAILED DATA(ls_read_failed)       " It's good practice to handle failed reads
        REPORTED DATA(ls_read_reported).   " And reported messages from the read

    " Handle potential read failures before proceeding
    IF ls_read_failed-vendorinvoiceitem IS NOT INITIAL.
      LOOP AT ls_read_failed-vendorinvoiceitem INTO DATA(ls_failed_item_read).
        APPEND VALUE #( %tky = ls_failed_item_read-%tky ) TO failed-vendorinvoiceitem.
        APPEND VALUE #( %tky = ls_failed_item_read-%tky
                        " Corrected: Access the specific key field (e.g., ItemUuid) from %tky structure
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Failed to read item data for key (ItemUuid: { ls_failed_item_read-%tky-ItemUuid }) for validation.| ) )
          TO reported-vendorinvoiceitem.
      ENDLOOP.
      " Depending on logic, you might want to return or skip further processing for these failed reads.
    ENDIF.

*    LOOP AT lt_items INTO DATA(ls_item).
*      IF ls_item-TaxCode IS NOT INITIAL. " Tax code is optional for some G/L accounts
*        DATA(lv_company_code) = ls_item-_Header-CompanyCode.
*        " Get country from company code for tax validation
*        SELECT SINGLE land1 FROM t001 WHERE bukrs = @lv_company_code INTO @DATA(lv_country).
*        IF sy-subrc = 0.
*          SELECT SINGLE @abap_true FROM t007a WHERE kschl = 'MWS' " Schema for output tax, adjust if needed for input tax schema
*                                          AND land1 = @lv_country
*                                          AND mwskz = @ls_item-TaxCode
*                                          INTO @DATA(lv_exists_t007a).
*          IF sy-subrc <> 0.
*            APPEND VALUE #( %tky = ls_item-%tky ) TO failed-vendorinvoiceitem.
*            APPEND VALUE #( %tky = ls_item-%tky
*                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = |Tax Code '{ ls_item-TaxCode }' is not valid for country '{ lv_country }'.| )
*                            %element-TaxCode = if_abap_behv=>mk-on )
*              TO reported-vendorinvoiceitem.
*          ENDIF.
*        ELSE.
*          APPEND VALUE #( %tky = ls_item-%tky ) TO failed-vendorinvoiceitem.
*          APPEND VALUE #( %tky = ls_item-%tky
*                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-warning text = |Could not determine country for company code '{ lv_company_code }' to validate tax code.| ) )
*            TO reported-vendorinvoiceitem.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
